param(
  [string]$Root = (Split-Path -Parent $PSScriptRoot),
  [object]$RequirePythonToml = $false,
  [bool]$JsonSummary = $false
)

$ErrorActionPreference = "Stop"
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if ($RequirePythonToml -is [string]) {
  $RequirePythonToml = $RequirePythonToml -match "^(?i:true|1)$"
} else {
  $RequirePythonToml = [bool]$RequirePythonToml
}

function Add-Failure {
  param([Parameter(Mandatory=$true)][string]$Message)
  $failures.Add($Message) | Out-Null
}

function Add-Warning {
  param([Parameter(Mandatory=$true)][string]$Message)
  $warnings.Add($Message) | Out-Null
}

function Resolve-WorkspacePath {
  param([Parameter(Mandatory=$true)][string]$RelativePath)
  return Join-Path $Root $RelativePath
}

function Assert-PathExists {
  param([Parameter(Mandatory=$true)][string]$RelativePath)
  $path = Resolve-WorkspacePath $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    Add-Failure "Missing required path: $RelativePath"
  }
}

function Get-FirstCommand {
  param([string[]]$Names)
  foreach ($name in $Names) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($null -ne $cmd) { return $cmd.Source }
  }
  return $null
}

function Test-TomlWithPython {
  param([Parameter(Mandatory=$true)][string]$ConfigPath)

  $python = Get-FirstCommand -Names @("python", "python3", "py")
  if ($null -eq $python) {
    if ($RequirePythonToml) {
      Add-Failure "Python 3.11+ is required to parse TOML but no Python command was found."
    } else {
      Add-Warning "Python 3.11+ not found; TOML validation fell back to structural checks only."
    }
    return
  }

  $script = @'
import pathlib
import sys
try:
    import tomllib
except Exception as exc:
    print(f"TOMLLIB_MISSING: {exc}", file=sys.stderr)
    sys.exit(3)
path = pathlib.Path(sys.argv[1])
try:
    data = tomllib.loads(path.read_text(encoding="utf-8"))
except Exception as exc:
    print(f"TOML_PARSE_ERROR: {exc}", file=sys.stderr)
    sys.exit(2)
if "sandbox_mode" in data or "sandbox_workspace_write" in data:
    print("LEGACY_SANDBOX_WITH_PERMISSIONS", file=sys.stderr)
    sys.exit(4)
features = data.get("features", {})
if features.get("hooks") is not True:
    print("HOOKS_NOT_ENABLED", file=sys.stderr)
    sys.exit(5)
hooks = data.get("hooks", {})
for event in ("PreToolUse", "PermissionRequest", "PostToolUse"):
    if event not in hooks or not hooks[event]:
        print(f"MISSING_HOOK_EVENT:{event}", file=sys.stderr)
        sys.exit(6)
if "default_permissions" in data:
    permissions = data.get("permissions", {})
    profile_name = data["default_permissions"]
    if profile_name not in permissions:
        print("DEFAULT_PERMISSION_PROFILE_NOT_DEFINED", file=sys.stderr)
        sys.exit(7)
    profile = permissions[profile_name]
    network = profile.get("network", {})
    if network.get("enabled") is not False:
        print("NETWORK_NOT_DISABLED_BY_DEFAULT", file=sys.stderr)
        sys.exit(8)
print("TOML_OK")
'@

  $tempScript = [System.IO.Path]::GetTempFileName() + ".py"
  try {
    Set-Content -LiteralPath $tempScript -Encoding UTF8 -Value $script
    $output = & $python $tempScript $ConfigPath 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 3 -and -not $RequirePythonToml) {
      Add-Warning "Python was found, but tomllib is unavailable. TOML validation fell back to structural checks only."
    } elseif ($exitCode -ne 0) {
      Add-Failure ("TOML validation failed for .codex/config.toml with exit code {0}. {1}" -f $exitCode, ($output -join " "))
    }
  } finally {
    if (Test-Path -LiteralPath $tempScript) {
      Remove-Item -LiteralPath $tempScript -Force
    }
  }
}

function Test-SkillFrontmatter {
  param([Parameter(Mandatory=$true)][string]$SkillPath)

  if (-not (Test-Path -LiteralPath $SkillPath)) {
    Add-Failure "Missing skill file: $SkillPath"
    return
  }

  $lines = Get-Content -LiteralPath $SkillPath
  if ($lines.Count -lt 4 -or $lines[0].Trim() -ne "---") {
    Add-Failure "SKILL.md must start with YAML frontmatter."
    return
  }

  $endIndex = -1
  for ($i = 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Trim() -eq "---") {
      $endIndex = $i
      break
    }
  }

  if ($endIndex -lt 0) {
    Add-Failure "SKILL.md frontmatter is not closed with ---."
    return
  }

  $frontmatter = ($lines[1..($endIndex - 1)] -join "`n")
  $nameMatch = [regex]::Match($frontmatter, "(?m)^name:\s*([a-z0-9-]+)\s*$")
  $descriptionMatch = [regex]::Match($frontmatter, "(?m)^description:\s*(.+)\s*$")

  if (-not $nameMatch.Success) {
    Add-Failure "SKILL.md frontmatter must contain a lowercase hyphenated name field."
  }

  if (-not $descriptionMatch.Success -or [string]::IsNullOrWhiteSpace($descriptionMatch.Groups[1].Value)) {
    Add-Failure "SKILL.md frontmatter must contain a non-empty description field."
  } else {
    $description = $descriptionMatch.Groups[1].Value.Trim()
    if ($description.Length -gt 1024) {
      Add-Failure "SKILL.md description is $($description.Length) characters, above the 1024 character skill specification limit."
    }
    if ($description -notmatch "(?i)Scaffold|React|Vite|Capacitor|Next|Expo") {
      Add-Warning "SKILL.md description may not be front-loaded with app-dev trigger terms."
    }
    if ($description -notmatch "(?i)^app-dev\s+scaffold") {
      Add-Failure "SKILL.md description must be front-loaded with app-dev scaffold trigger terms."
    }
  }

  foreach ($required in @("metadata:", "owner: app-dev", "version:", "maturity:")) {
    if ($frontmatter -notmatch [regex]::Escape($required)) {
      Add-Failure "SKILL.md frontmatter is missing required metadata content: $required"
    }
  }

  if ($nameMatch.Success) {
    $folderName = Split-Path -Leaf (Split-Path -Parent $SkillPath)
    $skillName = $nameMatch.Groups[1].Value.Trim()
    if ($skillName -ne $folderName) {
      Add-Failure "SKILL.md name '$skillName' must match parent folder '$folderName'."
    }
    if ($skillName.StartsWith("-") -or $skillName.EndsWith("-") -or $skillName.Contains("--")) {
      Add-Failure "SKILL.md name violates hyphen placement rules."
    }
  }
}

function Test-MarkdownReferences {
  param([Parameter(Mandatory=$true)][string]$MarkdownPath)

  if (-not (Test-Path -LiteralPath $MarkdownPath)) { return }
  $base = Split-Path -Parent $MarkdownPath
  $content = Get-Content -LiteralPath $MarkdownPath -Raw
  $matches = [regex]::Matches($content, "\[[^\]]+\]\(([^)]+)\)")
  foreach ($match in $matches) {
    $target = $match.Groups[1].Value.Trim()
    if ($target -match "^(https?:|mailto:|#)") { continue }
    $targetPath = ($target -split "#")[0]
    if ([string]::IsNullOrWhiteSpace($targetPath)) { continue }
    $fullTarget = Join-Path $base $targetPath
    if (-not (Test-Path -LiteralPath $fullTarget)) {
      Add-Failure "Broken markdown link in $MarkdownPath -> $target"
    }
  }

  $referenceMatches = [regex]::Matches($content, '(?m)`?references/[A-Za-z0-9_./-]+`?')
  foreach ($match in $referenceMatches) {
    $target = $match.Value.Trim('`')
    $fullTarget = Join-Path $base $target
    if (-not (Test-Path -LiteralPath $fullTarget)) {
      Add-Failure "Broken skill reference in $MarkdownPath -> $target"
    }
  }
}

function Test-AgentsSize {
  param([Parameter(Mandatory=$true)][string]$AgentsPath)

  if (-not (Test-Path -LiteralPath $AgentsPath)) {
    Add-Failure "Missing AGENTS.md."
    return
  }

  $bytes = (Get-Item -LiteralPath $AgentsPath).Length
  if ($bytes -gt 32768) {
    Add-Failure "AGENTS.md is $bytes bytes, above the default Codex project_doc_max_bytes of 32768."
  }
}

function Test-HookReferences {
  param(
    [Parameter(Mandatory=$true)][string]$ConfigPath,
    [Parameter(Mandatory=$true)][string[]]$HookFiles
  )

  $config = Get-Content -LiteralPath $ConfigPath -Raw
  foreach ($hook in $HookFiles) {
    Assert-PathExists $hook
    $normalized = $hook -replace "\\", "/"
    if ($config -notmatch [regex]::Escape($normalized)) {
      Add-Failure "Hook file is not referenced by .codex/config.toml: $hook"
    }
  }

  if (Test-Path -LiteralPath (Resolve-WorkspacePath ".codex/hooks.json")) {
    Add-Failure "Do not use .codex/hooks.json while inline hooks are configured in .codex/config.toml. Use one hook representation per config layer."
  }
}

function Test-ConfigTextChecks {
  param([Parameter(Mandatory=$true)][string]$ConfigPath)

  $config = Get-Content -LiteralPath $ConfigPath -Raw
  foreach ($required in @("[features]", "hooks = true", "[[hooks.PreToolUse]]", "[[hooks.PermissionRequest]]", "[[hooks.PostToolUse]]")) {
    if ($config -notmatch [regex]::Escape($required)) {
      Add-Failure ".codex/config.toml is missing required active setting: $required"
    }
  }

  foreach ($forbidden in @("sandbox_mode", "sandbox_workspace_write", "danger-full-access")) {
    if ($config -match $forbidden) {
      Add-Failure ".codex/config.toml contains forbidden or conflicting setting/text: $forbidden"
    }
  }
}

function Test-RulesFile {
  param([Parameter(Mandatory=$true)][string]$RulesPath)

  if (-not (Test-Path -LiteralPath $RulesPath)) {
    Add-Failure "Missing .codex/rules/default.rules."
    return
  }

  $rules = Get-Content -LiteralPath $RulesPath -Raw
  foreach ($required in @('prefix_rule(', 'decision = "forbidden"', 'decision = "prompt"', 'git reset', 'npm', 'npm version', 'gh release', 'docker system prune', 'supabase', 'supabase", "db", "remote', 'supabase", "db", "deploy', 'prisma')) {
    if ($rules -notmatch [regex]::Escape($required)) {
      Add-Failure ".codex/rules/default.rules is missing expected rule coverage: $required"
    }
  }

  $codex = Get-Command codex -ErrorAction SilentlyContinue
  if ($null -ne $codex) {
    try {
      & $codex.Source execpolicy check --rules $RulesPath -- git reset --hard HEAD *> $null
      if ($LASTEXITCODE -ne 0) {
        Add-Warning "codex execpolicy check returned non-zero. Review .codex/rules/default.rules with the installed Codex version."
      }
    } catch {
      Add-Warning "codex execpolicy validation could not run in this shell. Review .codex/rules/default.rules with the installed Codex version. $($_.Exception.Message)"
    }
  } else {
    Add-Warning "Codex CLI not found; skipped execpolicy validation for .codex/rules/default.rules."
  }
}

function Test-NoDisposableVerificationFolders {
  $projectsPath = Resolve-WorkspacePath "projects"
  if (-not (Test-Path -LiteralPath $projectsPath)) { return }
  $badFolders = Get-ChildItem -LiteralPath $projectsPath -Directory -Force | Where-Object { $_.Name -like "__verify-*" -or $_.Name -eq "__verify-template" }
  foreach ($folder in $badFolders) {
    Add-Failure "Disposable verification folder must not be committed or packaged: projects/$($folder.Name)"
  }
}

function Test-CapabilityRouting {
  param([Parameter(Mandatory=$true)][string]$CapabilityPath)

  if (-not (Test-Path -LiteralPath $CapabilityPath)) {
    Add-Failure "Missing capability routing standard: $CapabilityPath"
    return
  }

  $content = Get-Content -LiteralPath $CapabilityPath -Raw
  foreach ($required in @("Required Local Capability", "Optional External Capabilities", "cross-platform-app-workflow", "ui-change-workflow", "data-change-workflow", "mobile-validation-workflow", "release-readiness-workflow", "workflow-receipts.md", "not repository dependencies")) {
    if ($content -notmatch [regex]::Escape($required)) {
      Add-Failure "standards/codex-capabilities.md is missing P1 capability-separation wording: $required"
    }
  }
}

function Test-PlanAssets {
  param(
    [Parameter(Mandatory=$true)][string]$PlansPath,
    [Parameter(Mandatory=$true)][string]$PlanTemplatePath
  )

  if (-not (Test-Path -LiteralPath $PlansPath)) {
    Add-Failure "Missing root PLANS.md."
  } else {
    $plans = Get-Content -LiteralPath $PlansPath -Raw
    foreach ($required in @("Planning Standard", "projects/<app>/PLAN.md", "templates/PLAN.template.md", "Completion Rule")) {
      if ($plans -notmatch [regex]::Escape($required)) {
        Add-Failure "PLANS.md is missing required planning protocol content: $required"
      }
    }
  }

  if (-not (Test-Path -LiteralPath $PlanTemplatePath)) {
    Add-Failure "Missing templates/PLAN.template.md."
  } else {
    $template = Get-Content -LiteralPath $PlanTemplatePath -Raw
    foreach ($required in @("{{APP_NAME}}", "{{TEMPLATE}}", "{{DATE}}", "Active spec:", "Spec path:", "Verification", "Risks and Assumptions")) {
      if ($template -notmatch [regex]::Escape($required)) {
        Add-Failure "templates/PLAN.template.md is missing required content: $required"
      }
    }
    if ($template -match "\bTBD\b") {
      Add-Failure "templates/PLAN.template.md must not contain unresolved TBD placeholders."
    }
  }
}

function Test-PackageJson {
  param([Parameter(Mandatory=$true)][string]$RelativePath)

  $path = Resolve-WorkspacePath $RelativePath
  if (-not (Test-Path -LiteralPath $path)) {
    Add-Failure "Missing package.json: $RelativePath"
    return
  }

  try {
    $null = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -ErrorAction Stop
  } catch {
    Add-Failure "Invalid package.json JSON: $RelativePath. $($_.Exception.Message)"
  }
}

function Test-ReactTemplatePackageJson {
  $path = Resolve-WorkspacePath "templates/react-vite-capacitor/package.json"
  if (-not (Test-Path -LiteralPath $path)) {
    Add-Failure "Missing package.json: templates/react-vite-capacitor/package.json"
    return
  }

  try {
    $package = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -ErrorAction Stop
  } catch {
    Add-Failure "Invalid package.json JSON: templates/react-vite-capacitor/package.json. $($_.Exception.Message)"
    return
  }

  foreach ($scriptName in @("typecheck", "lint", "test", "build", "e2e")) {
    if ($null -eq $package.scripts -or -not ($package.scripts.PSObject.Properties.Name -contains $scriptName)) {
      Add-Failure "templates/react-vite-capacitor/package.json is missing required script: $scriptName"
    }
  }
}

function Test-TemplateAgents {
  param([Parameter(Mandatory=$true)][string[]]$AgentPaths)

  foreach ($relativePath in $AgentPaths) {
    $path = Resolve-WorkspacePath $relativePath
    if (-not (Test-Path -LiteralPath $path)) {
      Add-Failure "Missing template AGENTS.md: $relativePath"
      continue
    }

    $content = Get-Content -LiteralPath $path -Raw
    foreach ($required in @("Active Specification", "Done When", "verify-app.ps1 -ProjectPath .", "check-spec-artifacts.ps1 -ProjectPath .", "validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence", "workflow-receipts.md", "Missing scripts are reported instead of invented")) {
      if ($content -notmatch [regex]::Escape($required)) {
        Add-Failure "$relativePath is missing generated app reliability wording: $required"
      }
    }
  }
}

function Test-SpecWorkflowAssets {
  foreach ($relativePath in @(
    "standards/spec-driven-workflow.md",
    "standards/command-workflow-contract.md",
    "templates/spec-workflow/spec.template.md",
    "templates/spec-workflow/tasks.template.md",
    "templates/spec-workflow/checklist.template.md",
    "templates/spec-workflow/workflow-receipts.template.md",
    "templates/spec-workflow/converge.template.md",
    "scripts/new-spec.ps1",
    "scripts/check-spec-artifacts.ps1",
    "scripts/validate-workflow-receipts.ps1",
    ".agents/skills/cross-platform-app-workflow/references/spec-driven-workflow.md"
  )) {
    Assert-PathExists $relativePath
  }

  $workflow = Get-Content -LiteralPath (Resolve-WorkspacePath "standards/spec-driven-workflow.md") -Raw
  foreach ($required in @("Numbered Specs", "workflow-receipts.md", "Lean Path", "Gated Path", "Convergence")) {
    if ($workflow -notmatch [regex]::Escape($required)) {
      Add-Failure "standards/spec-driven-workflow.md is missing required workflow content: $required"
    }
  }
}

function Test-WorkflowWrapperAssets {
  foreach ($relativePath in @(
    ".agents/skills/ui-change-workflow/SKILL.md",
    ".agents/skills/data-change-workflow/SKILL.md",
    ".agents/skills/mobile-validation-workflow/SKILL.md",
    ".agents/skills/release-readiness-workflow/SKILL.md",
    ".agents/commands/specify.md",
    ".agents/commands/plan.md",
    ".agents/commands/tasks.md",
    ".agents/commands/implement.md",
    ".agents/commands/verify.md",
    ".agents/commands/release-readiness.md",
    "scripts/get-workflow-obligations.ps1",
    "scripts/validate-workflow-receipts.ps1",
    "scripts/test-workflow-enforcement.ps1"
  )) {
    Assert-PathExists $relativePath
  }

  $skill = Get-Content -LiteralPath (Resolve-WorkspacePath ".agents/skills/cross-platform-app-workflow/SKILL.md") -Raw
  foreach ($required in @("ui-change-workflow", "data-change-workflow", "mobile-validation-workflow", "release-readiness-workflow", "workflow-receipts.md", "validate-workflow-receipts.ps1")) {
    if ($skill -notmatch [regex]::Escape($required)) {
      Add-Failure "cross-platform-app-workflow is missing required workflow-enforcement wording: $required"
    }
  }

  $commandContract = Get-Content -LiteralPath (Resolve-WorkspacePath "standards/command-workflow-contract.md") -Raw
  foreach ($required in @("workflow-receipts.md", "UI", "Data", "Mobile", "Release readiness")) {
    if ($commandContract -notmatch [regex]::Escape($required)) {
      Add-Failure "standards/command-workflow-contract.md is missing required workflow contract content: $required"
    }
  }
}

function Test-SkillReferenceDelegation {
  $skill = Get-Content -LiteralPath (Resolve-WorkspacePath ".agents/skills/cross-platform-app-workflow/SKILL.md") -Raw
  foreach ($required in @(
    "../../../standards/stack.md",
    "../../../standards/adaptive-layouts.md",
    "../../../standards/testing.md",
    "../../../standards/spec-driven-workflow.md",
    "../../../standards/command-workflow-contract.md"
  )) {
    if ($skill -notmatch [regex]::Escape($required)) {
      Add-Failure "cross-platform-app-workflow must reference canonical standards docs directly: $required"
    }
  }

  $delegations = @(
    @{
      RelativePath = ".agents/skills/cross-platform-app-workflow/references/stack.md"
      RequiredText = @(
        "This file intentionally delegates to the canonical workspace standard to prevent drift.",
        'Canonical source: `../../../../standards/stack.md`'
      )
    },
    @{
      RelativePath = ".agents/skills/cross-platform-app-workflow/references/adaptive-layouts.md"
      RequiredText = @(
        "This file intentionally delegates to the canonical workspace standard to prevent drift.",
        'Canonical source: `../../../../standards/adaptive-layouts.md`'
      )
    },
    @{
      RelativePath = ".agents/skills/cross-platform-app-workflow/references/qa-gates.md"
      RequiredText = @(
        "This file intentionally delegates to the canonical workspace standards to prevent drift.",
        '`../../../../standards/testing.md`',
        '`../../../../standards/command-workflow-contract.md`'
      )
    },
    @{
      RelativePath = ".agents/skills/cross-platform-app-workflow/references/spec-driven-workflow.md"
      RequiredText = @(
        "This file intentionally delegates to the canonical workspace standards to prevent drift.",
        '`../../../../standards/spec-driven-workflow.md`',
        '`../../../../standards/command-workflow-contract.md`'
      )
    }
  )

  foreach ($delegation in $delegations) {
    $path = Resolve-WorkspacePath $delegation.RelativePath
    if (-not (Test-Path -LiteralPath $path)) {
      Add-Failure "Missing delegated skill reference: $($delegation.RelativePath)"
      continue
    }

    $content = Get-Content -LiteralPath $path -Raw
    foreach ($required in $delegation.RequiredText) {
      if ($content -notmatch [regex]::Escape($required)) {
        Add-Failure "$($delegation.RelativePath) is missing required delegation text: $required"
      }
    }
  }
}

function Test-TemplateReadiness {
  $requiredPaths = @(
    "templates/common/.github/workflows/verify.yml",
    "templates/react-vite-capacitor/.github/workflows/verify.yml",
    "templates/react-vite-capacitor/eslint/index.js",
    "templates/react-vite-capacitor/eslint/rules/enforce-module-boundaries.js",
    "templates/react-vite-capacitor/capacitor.config.ts",
    "templates/react-vite-capacitor/tailwind.config.ts",
    "templates/react-vite-capacitor/postcss.config.js",
    "templates/react-vite-capacitor/components.json",
    "templates/react-vite-capacitor/scripts/add-native-platforms.ps1",
    "templates/react-vite-capacitor/src/app/routes.tsx",
    "templates/react-vite-capacitor/src/vite-env.d.ts",
    "templates/react-vite-capacitor/src/lib/env.ts",
    "templates/react-vite-capacitor/src/lib/supabase.ts",
    "templates/react-vite-capacitor/src/lib/query-client.ts",
    "templates/react-vite-capacitor/src/components/layout/SettingsLayout.tsx",
    "templates/react-vite-capacitor/src/components/ui/form.tsx",
    "templates/react-vite-capacitor/src/modules/settings/routes/SettingsRoute.tsx",
    "templates/react-vite-capacitor/src/components/state/EmptyState.tsx",
    "templates/react-vite-capacitor/src/components/state/LoadingState.tsx",
    "templates/react-vite-capacitor/src/components/state/ErrorState.tsx",
    "templates/react-vite-capacitor/src/components/state/StatePrimitives.test.tsx",
    "templates/react-vite-capacitor/src/modules/dashboard/components/DashboardModulesTable.tsx",
    "templates/react-vite-capacitor/src/modules/dashboard/components/DashboardSummary.tsx",
    "templates/react-vite-capacitor/src/modules/dashboard/components/DashboardActivityChart.tsx",
    "templates/react-vite-capacitor/src/modules/dashboard/hooks/useDashboardModules.ts",
    "templates/react-vite-capacitor/src/modules/dashboard/routes/DashboardRoute.tsx",
    "templates/react-vite-capacitor/src/modules/dashboard/schemas/dashboard-module.schema.ts",
    "templates/react-vite-capacitor/src/modules/dashboard/services/dashboard-service.ts",
    "templates/react-vite-capacitor/src/modules/dashboard/state/dashboard-view-store.ts",
    "templates/react-vite-capacitor/src/modules/dashboard/tests/DashboardRoute.test.tsx",
    "templates/react-vite-capacitor/src/modules/dashboard/tests/dashboard-module.schema.test.ts",
    "templates/react-vite-capacitor/src/modules/dashboard/tests/DashboardActivityChart.test.tsx",
    "templates/next-web-app/app/layout.tsx",
    "templates/next-web-app/app/page.tsx",
    "templates/next-web-app/tsconfig.json",
    "templates/next-web-app/eslint.config.js",
    "templates/next-web-app/tests/smoke.test.ts",
    "templates/expo-native-app/app.json",
    "templates/expo-native-app/App.tsx",
    "templates/expo-native-app/tsconfig.json",
    "templates/expo-native-app/jest.config.js",
    "templates/expo-native-app/tests/App.test.tsx"
  )

  foreach ($relativePath in $requiredPaths) {
    Assert-PathExists $relativePath
  }

  $reactEslintConfig = Get-Content -LiteralPath (Resolve-WorkspacePath "templates/react-vite-capacitor/eslint.config.js") -Raw
  foreach ($required in @("app-dev/enforce-module-boundaries", 'import appDevEslint from "./eslint/index.js"')) {
    if ($reactEslintConfig -notmatch [regex]::Escape($required)) {
      Add-Failure "React template ESLint config is missing required boundary enforcement wiring: $required"
    }
  }

  $reactNav = Get-Content -LiteralPath (Resolve-WorkspacePath "templates/react-vite-capacitor/src/app/NavigationShell.tsx") -Raw
  foreach ($required in @("NavLink", "/settings")) {
    if ($reactNav -notmatch [regex]::Escape($required)) {
      Add-Failure "React navigation template is missing route readiness content: $required"
    }
  }
}

function Test-CiWorkflow {
  param([Parameter(Mandatory=$true)][string]$WorkflowPath)

  if (-not (Test-Path -LiteralPath $WorkflowPath)) {
    Add-Failure "Missing CI workflow: .github/workflows/app-dev-validation.yml"
    return
  }

  $workflow = Get-Content -LiteralPath $WorkflowPath -Raw
  foreach ($required in @("pull_request", "workflow_dispatch", "actions/checkout@v4", "actions/setup-node@v4", "actions/setup-python@v5", "scripts/check-workspace.ps1", "scripts/validate-codex-assets.ps1", "scripts/test-hooks.ps1", "scripts/test-workflow-enforcement.ps1", "scripts/scan-secrets.ps1", "scripts/test-workspace.ps1")) {
    if ($workflow -notmatch [regex]::Escape($required)) {
      Add-Failure ".github/workflows/app-dev-validation.yml is missing required CI content: $required"
    }
  }
}

function Test-AuditCloseoutLedger {
  param([Parameter(Mandatory=$true)][string]$LedgerPath)

  if (-not (Test-Path -LiteralPath $LedgerPath)) {
    Add-Failure "Missing audit closeout ledger: $LedgerPath"
    return
  }

  $ledger = Get-Content -LiteralPath $LedgerPath -Raw
  foreach ($required in @("P0 Findings", "P1 Findings", "P2 Findings", "Other Findings", "accepted-decision", "open-fixed-by-this-plan", "MCP", "export-workspace.ps1", "scan-secrets.ps1")) {
    if ($ledger -notmatch [regex]::Escape($required)) {
      Add-Failure "Audit closeout ledger is missing required content: $required"
    }
  }
}

function Test-ScriptAssets {
  foreach ($relativePath in @("scripts/scan-secrets.ps1", "scripts/export-workspace.ps1", "scripts/new-spec.ps1", "scripts/check-spec-artifacts.ps1", "scripts/get-workflow-obligations.ps1", "scripts/validate-workflow-receipts.ps1", "scripts/test-workflow-enforcement.ps1")) {
    Assert-PathExists $relativePath
  }

  $verify = Get-Content -LiteralPath (Resolve-WorkspacePath "scripts/verify-app.ps1") -Raw
  foreach ($required in @("bun.lockb", "missing-dependencies", "missing-script", "command-failure", "no-checks-ran")) {
    if ($verify -notmatch [regex]::Escape($required)) {
      Add-Failure "scripts/verify-app.ps1 is missing verification classification content: $required"
    }
  }

  $export = Get-Content -LiteralPath (Resolve-WorkspacePath "scripts/export-workspace.ps1") -Raw
  foreach ($required in @(".git", "projects/", "node_modules", "Compress-Archive")) {
    if ($export -notmatch [regex]::Escape($required)) {
      Add-Failure "scripts/export-workspace.ps1 is missing export exclusion content: $required"
    }
  }
}

function Test-OpenAiAgentMetadata {
  param([Parameter(Mandatory=$true)][string]$MetadataPath)

  if (-not (Test-Path -LiteralPath $MetadataPath)) {
    Add-Failure "Missing OpenAI agent metadata: $MetadataPath"
    return
  }

  $content = Get-Content -LiteralPath $MetadataPath -Raw
  foreach ($required in @("display_name:", "short_description:", "default_prompt:", "external skills/plugins as optional")) {
    if ($content -notmatch [regex]::Escape($required)) {
      Add-Failure "OpenAI agent metadata is missing required P1 wording: $required"
    }
  }
}

$Root = (Resolve-Path -LiteralPath $Root).Path
$configPath = Resolve-WorkspacePath ".codex/config.toml"
$skillPath = Resolve-WorkspacePath ".agents/skills/cross-platform-app-workflow/SKILL.md"
$rulesPath = Resolve-WorkspacePath ".codex/rules/default.rules"
$capabilityPath = Resolve-WorkspacePath "standards/codex-capabilities.md"
$plansPath = Resolve-WorkspacePath "PLANS.md"
$planTemplatePath = Resolve-WorkspacePath "templates/PLAN.template.md"
$workflowPath = Resolve-WorkspacePath ".github/workflows/app-dev-validation.yml"
$openAiAgentMetadataPath = Resolve-WorkspacePath ".agents/skills/cross-platform-app-workflow/agents/openai.yaml"
$auditLedgerPath = Resolve-WorkspacePath "docs/audit/app-dev-audit-closeout.md"

  foreach ($path in @(
  "AGENTS.md",
  "PLANS.md",
  "docs/audit/app-dev-audit-closeout.md",
  ".github/workflows/app-dev-validation.yml",
  ".codex/config.toml",
  ".codex/rules/default.rules",
  ".codex/hooks/pre-command.ps1",
  ".codex/hooks/post-edit.ps1",
  ".codex/hooks/verify-before-finish.ps1",
  ".agents/commands/specify.md",
  ".agents/commands/plan.md",
  ".agents/commands/tasks.md",
  ".agents/commands/implement.md",
  ".agents/commands/verify.md",
  ".agents/commands/release-readiness.md",
  ".agents/README.md",
  ".agents/skills/README.md",
  ".agents/skills/cross-platform-app-workflow/SKILL.md",
  ".agents/skills/ui-change-workflow/SKILL.md",
  ".agents/skills/data-change-workflow/SKILL.md",
  ".agents/skills/mobile-validation-workflow/SKILL.md",
  ".agents/skills/release-readiness-workflow/SKILL.md",
  ".agents/skills/cross-platform-app-workflow/agents/openai.yaml",
  ".agents/skills/cross-platform-app-workflow/references/stack.md",
  ".agents/skills/cross-platform-app-workflow/references/module-contract.md",
  ".agents/skills/cross-platform-app-workflow/references/adaptive-layouts.md",
  ".agents/skills/cross-platform-app-workflow/references/qa-gates.md",
  ".agents/skills/cross-platform-app-workflow/references/spec-driven-workflow.md",
  "standards/command-workflow-contract.md",
  "standards/codex-capabilities.md",
  "standards/spec-driven-workflow.md",
  "templates/PLAN.template.md",
  "templates/spec-workflow/spec.template.md",
  "templates/spec-workflow/tasks.template.md",
  "templates/spec-workflow/checklist.template.md",
  "templates/spec-workflow/workflow-receipts.template.md",
  "templates/spec-workflow/converge.template.md",
  "templates/common/.github/workflows/verify.yml",
  "templates/react-vite-capacitor/.github/workflows/verify.yml",
  "templates/react-vite-capacitor/scripts/add-native-platforms.ps1",
  "scripts/validate-codex-assets.ps1",
  "scripts/get-workflow-obligations.ps1",
  "scripts/validate-workflow-receipts.ps1",
  "scripts/test-workflow-enforcement.ps1",
  "scripts/new-spec.ps1",
  "scripts/check-spec-artifacts.ps1",
  "scripts/scan-secrets.ps1",
  "scripts/export-workspace.ps1"
)) {
  Assert-PathExists $path
}

if (Test-Path -LiteralPath $configPath) {
  Test-ConfigTextChecks -ConfigPath $configPath
  Test-TomlWithPython -ConfigPath $configPath
  Test-HookReferences -ConfigPath $configPath -HookFiles @(
    ".codex/hooks/pre-command.ps1",
    ".codex/hooks/post-edit.ps1"
  )
}

Test-RulesFile -RulesPath $rulesPath
Test-SkillFrontmatter -SkillPath $skillPath
Test-MarkdownReferences -MarkdownPath $skillPath
Test-AgentsSize -AgentsPath (Join-Path $Root "AGENTS.md")
Test-NoDisposableVerificationFolders
Test-CapabilityRouting -CapabilityPath $capabilityPath
Test-PlanAssets -PlansPath $plansPath -PlanTemplatePath $planTemplatePath
Test-SpecWorkflowAssets
Test-WorkflowWrapperAssets
Test-SkillReferenceDelegation
Test-TemplateAgents -AgentPaths @(
  "templates/react-vite-capacitor/AGENTS.md",
  "templates/next-web-app/AGENTS.md",
  "templates/expo-native-app/AGENTS.md"
)
Test-TemplateReadiness
foreach ($packagePath in @(
  "templates/react-vite-capacitor/package.json",
  "templates/next-web-app/package.json",
  "templates/expo-native-app/package.json"
)) {
  Test-PackageJson -RelativePath $packagePath
}
Test-ReactTemplatePackageJson
Test-CiWorkflow -WorkflowPath $workflowPath
Test-OpenAiAgentMetadata -MetadataPath $openAiAgentMetadataPath
Test-AuditCloseoutLedger -LedgerPath $auditLedgerPath
Test-ScriptAssets

$summary = [ordered]@{
  root = $Root
  failures = @($failures)
  warnings = @($warnings)
  failureCount = $failures.Count
  warningCount = $warnings.Count
}

if ($JsonSummary) {
  $summary | ConvertTo-Json -Depth 6
}

foreach ($warning in $warnings) {
  Write-Warning $warning
}

if ($failures.Count -gt 0) {
  Write-Error ("Codex asset validation failed:`n" + ($failures -join "`n"))
}

Write-Host "Codex asset validation passed. Warnings: $($warnings.Count)."
