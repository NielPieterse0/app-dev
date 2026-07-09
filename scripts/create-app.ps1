param(
  [Parameter(Mandatory=$true)]
  [ValidatePattern("^_*[a-z0-9][a-z0-9-]*$")]
  [string]$Name,

  [ValidateSet("react-vite-capacitor", "next-web-app", "expo-native-app")]
  [string]$Template = "react-vite-capacitor",

  [switch]$NoInstall = $true,

  [switch]$InitializeGit
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root "templates/$Template"
$target = Join-Path $root "projects/$Name"
$specTemplateDir = Join-Path $root "templates/spec-workflow"

if (-not (Test-Path -LiteralPath $source)) {
  Write-Error "Template not found: $source"
}

if (-not (Test-Path -LiteralPath $specTemplateDir)) {
  Write-Error "Spec workflow templates not found: $specTemplateDir"
}

if (Test-Path -LiteralPath $target) {
  Write-Error "Project already exists: $target"
}

New-Item -ItemType Directory -Force -Path $target | Out-Null
$excludedTemplateEntries = @(
  ".github",
  "node_modules",
  "dist",
  "coverage",
  "playwright-report",
  "test-results"
)

if ($Template -eq "react-vite-capacitor") {
  $excludedTemplateEntries += @("android", "ios")
}

Get-ChildItem -LiteralPath $source -Force | Where-Object {
  $excludedTemplateEntries -notcontains $_.Name
} | ForEach-Object {
  Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
}

$agentPath = Join-Path $target "AGENTS.md"
if (-not (Test-Path -LiteralPath $agentPath)) {
  Set-Content -LiteralPath $agentPath -Encoding UTF8 -Value @"
# $Name Codex Instructions

This project inherits the app-dev workspace standards.
Use this project's `PLAN.md` for architecture, module, risk, and verification decisions.

## Active Specification

- Start with `specs/001-initial/spec.md`.
- Create later feature specs under `specs/NNN-<slug>/`.
- Keep `PLAN.md`, `tasks.md`, and `workflow-receipts.md` aligned to the active spec before implementation starts.

## Verification

Use the scripts in package.json. Before completion, run available checks through:

````powershell
../../scripts/verify-app.ps1 -ProjectPath .
````

## Done When

- Active specification and task artifacts are current for the feature being built.
- `workflow-receipts.md` is current for any UI, data, mobile, or release-readiness work.
- `PLAN.md` is current for architecture, data model, auth, routing, deployment, migration, or multi-module work.
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` passes before completion.
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` passes before completion.
- Available checks pass through `../../scripts/verify-app.ps1 -ProjectPath .`.
- Missing scripts are reported instead of invented.
- UI changes include rendered desktop and mobile checks.
- Handoff notes record deviations, skipped checks, and unresolved decisions.
"@
}

$planPath = Join-Path $target "PLAN.md"
$templatePlanPath = Join-Path $root "templates/PLAN.template.md"
if (-not (Test-Path -LiteralPath $planPath)) {
  if (-not (Test-Path -LiteralPath $templatePlanPath)) {
    Write-Error "Plan template not found: $templatePlanPath"
  }

  $planText = Get-Content -LiteralPath $templatePlanPath -Raw
  $planText = $planText.Replace("{{APP_NAME}}", $Name)
  $planText = $planText.Replace("{{TEMPLATE}}", $Template)
  $planText = $planText.Replace("{{DATE}}", (Get-Date -Format "yyyy-MM-dd"))
  Set-Content -LiteralPath $planPath -Encoding UTF8 -Value $planText
}

$initialSpecDir = Join-Path $target "specs/001-initial"
New-Item -ItemType Directory -Force -Path $initialSpecDir | Out-Null

$specReplacements = @{
  "{{SPEC_NUMBER}}" = "001"
  "{{SPEC_TITLE}}" = "Initial App Foundation"
  "{{SPEC_DIR}}" = "001-initial"
  "{{RISK_LEVEL}}" = "standard"
  "{{APP_NAME}}" = $Name
  "{{DATE}}" = (Get-Date -Format "yyyy-MM-dd")
}

foreach ($templateName in @("spec.template.md", "tasks.template.md", "workflow-receipts.template.md", "checklist.template.md")) {
  $sourcePath = Join-Path $specTemplateDir $templateName
  if (-not (Test-Path -LiteralPath $sourcePath)) {
    Write-Error "Spec workflow template not found: $sourcePath"
  }

  $targetName = $templateName.Replace(".template", "")
  $targetPath = Join-Path $initialSpecDir $targetName
  if (-not (Test-Path -LiteralPath $targetPath)) {
    $text = Get-Content -LiteralPath $sourcePath -Raw
    foreach ($entry in $specReplacements.GetEnumerator()) {
      $text = $text.Replace($entry.Key, $entry.Value)
    }
    if ($targetName -eq "spec.md") {
      $text = $text.Replace("Replace this line with the user-visible outcome this feature must deliver.", "Establish the initial app foundation, base shell, workflow receipts, and delivery constraints for $Name.")
      $text = $text.Replace("Replace this line with the user problem or workflow gap this feature addresses.", "Provide a concrete starting specification for the first generated version of $Name so implementation can proceed from a numbered spec instead of an empty placeholder.")
      $text = $text.Replace("Replace with the operators or audiences for this feature.", "Developers and operators building the first production-ready workflows in $Name.")
      $text = $text.Replace("Replace with the main workflow this feature unlocks.", "Set up the first runnable app shell, base routes, and delivery guardrails so later features can build on a stable foundation.")
      $text = $text.Replace("Replace with explicit exclusions that keep this feature narrow.", "Shipping product-specific business workflows beyond the initial shell and template foundation.")
      $text = $text.Replace("Replace with the first concrete requirement.", "The generated app must include a runnable base shell and the durable instructions required to continue work from numbered specs.")
      $text = $text.Replace("Replace with the second concrete requirement.", "The generated app must define verification and planning hooks before feature-specific implementation begins.")
      $text = $text.Replace("Replace with the first observable success condition.", "The app contains AGENTS, PLAN, and specs/001-initial artifacts that all point to the same initial feature context.")
      $text = $text.Replace("Replace with the second observable success condition.", "The initial scaffold can pass spec artifact validation once dependencies and checks are available.")
      $text = $text.Replace("Replace with affected entities, fields, or state changes.", "No product entities yet; this feature establishes the shell, route structure, and workflow metadata.")
      $text = $text.Replace("Replace with roles, access rules, or state none.", "No app-specific roles yet; later feature specs must define access rules before sensitive workflows are added.")
      $text = $text.Replace("Replace with risky actions or state none.", "None in the initial scaffold.")
      $text = $text.Replace("Replace with desktop web, mobile web, Android, iOS, or another explicit set.", "Use the default platform set for $Template unless the app narrows scope later.")
      $text = $text.Replace("Replace with empty, loading, error, and success expectations.", "The app shell must preserve the template empty, loading, and error state patterns.")
      $text = $text.Replace("Replace with required device APIs or state none.", "None yet beyond the baseline template capabilities.")
      $text = $text.Replace("Replace with the main delivery or correctness risks.", "The main risk is drifting away from the scaffolded workflow before the first real feature spec is created.")
      $text = $text.Replace("Replace with unresolved decisions or state none.", "None for scaffold generation; product-specific decisions belong in later specs.")
    }
    if ($targetName -eq "tasks.md") {
      $text = $text.Replace("Replace this section with dependency ordering, deferred items, or release notes specific to this feature.", "Use this initial task list to confirm the scaffold, review the active spec, and prepare the first product-specific feature spec.")
    }
    if ($targetName -eq "workflow-receipts.md") {
      $text = $text.Replace("- [ ] UI workflow required", "- [x] UI workflow required")
      $text = $text.Replace("- [ ] Release-readiness workflow required", "- [x] Release-readiness workflow required")
      $text = $text.Replace("- Trigger surface: none", "- Trigger surface: initial scaffold and app shell")
      $text = $text.Replace("- Command path used: none", "- Command path used: scaffold generation")
      $text = $text.Replace("- Files/surfaces reviewed: none", "- Files/surfaces reviewed: AGENTS.md, PLAN.md, specs/001-initial/")
      $text = $text.Replace("- Verification performed: not-run", "- Verification performed: check-spec-artifacts and verify-app planned")
      $text = $text.Replace("- Decision/closure: not-applicable", "- Decision/closure: deferred")
    }
    Set-Content -LiteralPath $targetPath -Encoding UTF8 -Value $text
  }
}

$required = @("package.json", "AGENTS.md", "PLAN.md", "specs/001-initial/spec.md", "specs/001-initial/tasks.md", "specs/001-initial/workflow-receipts.md", "specs/001-initial/checklist.md")
if ($Template -eq "react-vite-capacitor") {
  $required += @(".env.example", "index.html", "src/main.tsx")
}

foreach ($item in $required) {
  $path = Join-Path $target $item
  if (-not (Test-Path -LiteralPath $path)) {
    Write-Error "Generated project is missing required file: $item"
  }
}

if (-not $NoInstall) {
  Write-Host "Dependency installation is intentionally not automated. Run the package manager inside $target after reviewing package.json."
}

if ($InitializeGit) {
  Push-Location $target
  try {
    git init | Out-Host
    if ($LASTEXITCODE -ne 0) {
      Write-Error "git init failed with exit code $LASTEXITCODE"
    }
  } finally {
    Pop-Location
  }
}

Write-Host "Created $Name from $Template at $target"
Write-Host "Next: review $agentPath, $planPath, and specs/001-initial/, install dependencies inside the project, then run ../../scripts/check-spec-artifacts.ps1 -ProjectPath ., ../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence, and ../../scripts/verify-app.ps1 -ProjectPath ."
