param(
  [string]$Root = (Split-Path -Parent $PSScriptRoot),
  [bool]$RequirePythonToml = $false,
  [bool]$JsonSummary = $false
)

$ErrorActionPreference = "Stop"
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([Parameter(Mandatory=$true)][string]$Message)
  $failures.Add($Message) | Out-Null
}

function Add-Warning {
  param([Parameter(Mandatory=$true)][string]$Message)
  $warnings.Add($Message) | Out-Null
}

function Assert-PathExists {
  param([Parameter(Mandatory=$true)][string]$RelativePath)
  $path = Join-Path $Root $RelativePath
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
if "default_permissions" not in data:
    print("MISSING_DEFAULT_PERMISSIONS", file=sys.stderr)
    sys.exit(4)
if "sandbox_mode" in data or "sandbox_workspace_write" in data:
    print("LEGACY_SANDBOX_WITH_PERMISSIONS", file=sys.stderr)
    sys.exit(5)
features = data.get("features", {})
if features.get("hooks") is not True:
    print("HOOKS_NOT_ENABLED", file=sys.stderr)
    sys.exit(6)
hooks = data.get("hooks", {})
for event in ("PreToolUse", "PermissionRequest", "PostToolUse"):
    if event not in hooks or not hooks[event]:
        print(f"MISSING_HOOK_EVENT:{event}", file=sys.stderr)
        sys.exit(7)
permissions = data.get("permissions", {})
profile_name = data["default_permissions"]
if profile_name not in permissions:
    print("DEFAULT_PERMISSION_PROFILE_NOT_DEFINED", file=sys.stderr)
    sys.exit(8)
profile = permissions[profile_name]
network = profile.get("network", {})
if network.get("enabled") is not False:
    print("NETWORK_NOT_DISABLED_BY_DEFAULT", file=sys.stderr)
    sys.exit(9)
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
  $nameMatch = [regex]::Match($frontmatter, "(?m)^name:\s*([A-Za-z0-9_-]+)\s*$")
  $descriptionMatch = [regex]::Match($frontmatter, "(?m)^description:\s*(.+)\s*$")

  if (-not $nameMatch.Success) {
    Add-Failure "SKILL.md frontmatter must contain a simple name field."
  }

  if (-not $descriptionMatch.Success -or [string]::IsNullOrWhiteSpace($descriptionMatch.Groups[1].Value)) {
    Add-Failure "SKILL.md frontmatter must contain a non-empty description field."
  }

  if ($nameMatch.Success) {
    $folderName = Split-Path -Leaf (Split-Path -Parent $SkillPath)
    $skillName = $nameMatch.Groups[1].Value.Trim()
    if ($skillName -ne $folderName) {
      Add-Failure "SKILL.md name '$skillName' must match parent folder '$folderName'."
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

  if (Test-Path -LiteralPath (Join-Path $Root ".codex/hooks.json")) {
    Add-Failure "Do not use .codex/hooks.json while inline hooks are configured in .codex/config.toml. Use one hook representation per config layer."
  }
}

function Test-ConfigTextChecks {
  param([Parameter(Mandatory=$true)][string]$ConfigPath)

  $config = Get-Content -LiteralPath $ConfigPath -Raw
  foreach ($required in @("default_permissions", "[features]", "hooks = true", "[[hooks.PreToolUse]]", "[[hooks.PermissionRequest]]", "[[hooks.PostToolUse]]")) {
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
  foreach ($required in @('prefix_rule(', 'decision = "forbidden"', 'decision = "prompt"', 'git reset', 'npm', 'supabase', 'prisma')) {
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
  $projectsPath = Join-Path $Root "projects"
  if (-not (Test-Path -LiteralPath $projectsPath)) { return }
  $badFolders = Get-ChildItem -LiteralPath $projectsPath -Directory -Force | Where-Object { $_.Name -like "__verify-*" -or $_.Name -eq "__verify-template" }
  foreach ($folder in $badFolders) {
    Add-Failure "Disposable verification folder must not be committed or packaged: projects/$($folder.Name)"
  }
}

$Root = (Resolve-Path -LiteralPath $Root).Path
$configPath = Join-Path $Root ".codex/config.toml"
$skillPath = Join-Path $Root ".agents/skills/cross-platform-app-workflow/SKILL.md"
$rulesPath = Join-Path $Root ".codex/rules/default.rules"

Assert-PathExists "AGENTS.md"
Assert-PathExists ".codex/config.toml"
Assert-PathExists ".codex/rules/default.rules"
Assert-PathExists ".codex/hooks/pre-command.ps1"
Assert-PathExists ".codex/hooks/post-edit.ps1"
Assert-PathExists ".codex/hooks/verify-before-finish.ps1"
Assert-PathExists ".agents/skills/cross-platform-app-workflow/SKILL.md"
Assert-PathExists "scripts/validate-codex-assets.ps1"

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
