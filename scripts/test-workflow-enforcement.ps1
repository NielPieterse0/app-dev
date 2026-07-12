$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$common = Join-Path $root "scripts/common.ps1"
$validator = Join-Path $root "scripts/validate-workflow-receipts.ps1"
$obligationsScript = Join-Path $root "scripts/get-workflow-obligations.ps1"
$applicableRulesScript = Join-Path $root "scripts/get-applicable-standard-rules.ps1"
$tmpRoot = Join-Path $root (".tmp/app-dev-workflow-test-" + [guid]::NewGuid().ToString("N"))

. $common

function Write-TextFile {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$Content
  )

  $dir = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
  Set-Content -LiteralPath $Path -Encoding UTF8 -Value $Content
}

function New-FixtureProject {
  param(
    [Parameter(Mandatory=$true)][string]$Name,
    [switch]$IncludeChecklist,
    [switch]$UiNotRun,
    [string]$ReleaseVerification = "verify-app and workflow validation complete",
    [string]$ReleaseDecision = "complete"
  )

  $projectPath = Join-Path $tmpRoot $Name
  New-Item -ItemType Directory -Force -Path (Join-Path $projectPath "specs/001-initial") | Out-Null

  Write-TextFile -Path (Join-Path $projectPath "AGENTS.md") -Content @"
# Fixture AGENTS

## Active Specification

- specs/001-initial/spec.md
- Active plan: `specs/001-initial/plan.md`
"@

  Write-TextFile -Path (Join-Path $projectPath "specs/001-initial/plan.md") -Content @"
# Fixture PLAN

Active spec: specs/001-initial/spec.md
Spec path: specs/001-initial/spec.md
Tasks path: specs/001-initial/tasks.md
"@

  Write-TextFile -Path (Join-Path $projectPath "specs/001-initial/spec.md") -Content @"
# 001 Fixture Specification

- Risk level: sensitive
- Authorization: no-auth internal MVP; public launch remains blocked
"@

  Write-TextFile -Path (Join-Path $projectPath "specs/001-initial/tasks.md") -Content "# tasks"

  $uiVerification = if ($UiNotRun) { "not-run" } else { "rendered desktop and mobile checks" }
  $uiClosure = if ($UiNotRun) { "not-applicable" } else { "complete" }

  $receipts = @"
# 001 Fixture Workflow Receipts

## Workflow Classification
- [x] UI workflow required
- [x] Data workflow required
- [ ] Mobile workflow required
- [ ] Release-readiness workflow required
- [ ] Why these workflows apply: fixture coverage

## Applicable Standards Checklist
- Status: not-started
- Selection basis: fixture defaults
- Registry files reviewed: standards/registry/command-workflow-contract.rules.json
- Prose standards consulted: none
- Critical/high rule summary: none

| Rule | Reference | Severity | Status | Evidence | Reason or next action |
| --- | --- | --- | --- | --- | --- |
| none | none | none | not-applicable | none | no applicable rules selected yet |

Allowed statuses: applied, not-applicable, deferred, blocked

## UI Change Workflow Receipt
- Trigger surface: src/components/Button.tsx
- Command path used: /implement
- Local workflow used: ui-change-workflow
- External skill used or unavailable: unavailable
- Files/surfaces reviewed: src/components/Button.tsx
- Verification performed: $uiVerification
- Outstanding gaps: none
- Decision/closure: $uiClosure

## Data Change Workflow Receipt
- Trigger surface: supabase/migrations/001.sql
- Command path used: /implement
- Local workflow used: data-change-workflow
- External skill used or unavailable: unavailable
- Files/surfaces reviewed: supabase/migrations/001.sql
- Verification performed: migration review complete
- Outstanding gaps: none
- Decision/closure: complete

## Mobile Validation Workflow Receipt
- Trigger surface: capacitor.config.ts
- Command path used: /implement
- Local workflow used: mobile-validation-workflow
- External skill used or unavailable: unavailable
- Files/surfaces reviewed: capacitor.config.ts
- Verification performed: Android and iOS blockers recorded
- Outstanding gaps: emulator unavailable
- Decision/closure: deferred

## Release Readiness Workflow Receipt
- Trigger surface: supabase/migrations/001.sql
- Command path used: /release-readiness
- Local workflow used: release-readiness-workflow
- External skill used or unavailable: unavailable
- Files/surfaces reviewed: supabase/migrations/001.sql
- Verification performed: $ReleaseVerification
- Outstanding gaps: none
- Decision/closure: $ReleaseDecision
"@

  Write-TextFile -Path (Join-Path $projectPath "specs/001-initial/workflow-receipts.md") -Content $receipts

  if ($IncludeChecklist) {
    Write-TextFile -Path (Join-Path $projectPath "specs/001-initial/checklist.md") -Content @"
# checklist

## Clarify
- [x] done

## Security And Data Review
- [x] done

## Implementation Readiness
- [x] done
"@
  }

  return $projectPath
}

function Assert-Fails {
  param(
    [Parameter(Mandatory=$true)][string]$ProjectPath,
    [Parameter(Mandatory=$true)][string]$ChangedFilesJson
  )

  try {
    & $validator -ProjectPath $ProjectPath -ChangedFilesJson $ChangedFilesJson -RequireVerificationEvidence *> $null
    throw "Expected validator failure for $ProjectPath"
  } catch {
    if ($_.Exception.Message -like "Expected validator failure*") {
      throw
    }
  }
}

function Assert-Passes {
  param(
    [Parameter(Mandatory=$true)][string]$ProjectPath,
    [Parameter(Mandatory=$true)][string]$ChangedFilesJson
  )

  & $validator -ProjectPath $ProjectPath -ChangedFilesJson $ChangedFilesJson -RequireVerificationEvidence *> $null
}

function Update-ReceiptContent {
  param(
    [Parameter(Mandatory=$true)][string]$ProjectPath,
    [Parameter(Mandatory=$true)][scriptblock]$Transform
  )

  $receiptPath = Join-Path $ProjectPath "specs/001-initial/workflow-receipts.md"
  $content = Get-Content -LiteralPath $receiptPath -Raw
  $updated = & $Transform $content
  Set-Content -LiteralPath $receiptPath -Encoding UTF8 -Value $updated
}

function Initialize-GitWorkflowFixture {
  $repoPath = Join-Path $tmpRoot "workflow-obligations-git"
  New-Item -ItemType Directory -Force -Path (Join-Path $repoPath "src/components") | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $repoPath "supabase/migrations") | Out-Null

  Push-Location $repoPath
  try {
    git init | Out-Null
    git config user.email "fixture@example.com"
    git config user.name "Fixture"

    Write-TextFile -Path (Join-Path $repoPath "README.md") -Content "# fixture"
    git add .
    git commit -m "base" | Out-Null
    $baseCommit = (git rev-parse HEAD).Trim()

    Write-TextFile -Path (Join-Path $repoPath "src/components/Button.tsx") -Content "export const Button = () => null;"
    Write-TextFile -Path (Join-Path $repoPath "supabase/migrations/001.sql") -Content "select 1;"
    git add .
    git commit -m "feature" | Out-Null

    Write-TextFile -Path (Join-Path $repoPath "src/app.css") -Content ".app { display: grid; }"

    return @{
      RepoPath = $repoPath
      BaseCommit = $baseCommit
    }
  } finally {
    Pop-Location
  }
}

try {
  New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null

  foreach ($risk in @("gated", "sensitive")) {
    if (-not (Test-GatedRiskLevel -RiskLevel $risk)) {
      throw "Expected '$risk' to require gated artifacts."
    }
  }

  $bareSwitchProject = New-FixtureProject -Name "bare-switch" -IncludeChecklist
  Assert-Passes -ProjectPath $bareSwitchProject -ChangedFilesJson '{"uiChange":{"required":false},"dataChange":{"required":true},"mobileValidation":{"required":false},"releaseReadiness":{"required":false}}'

  $uiProject = New-FixtureProject -Name "ui-missing-receipt" -UiNotRun
  Assert-Fails -ProjectPath $uiProject -ChangedFilesJson '{"uiChange":{"required":true},"dataChange":{"required":false},"mobileValidation":{"required":false},"releaseReadiness":{"required":false}}'

  $uiProjectFixed = New-FixtureProject -Name "ui-pass-fixed"
  Assert-Passes -ProjectPath $uiProjectFixed -ChangedFilesJson '{"uiChange":{"required":true},"dataChange":{"required":false},"mobileValidation":{"required":false},"releaseReadiness":{"required":false}}'

  $dataNoChecklist = New-FixtureProject -Name "data-no-checklist"
  Assert-Fails -ProjectPath $dataNoChecklist -ChangedFilesJson '{"uiChange":{"required":false},"dataChange":{"required":true},"mobileValidation":{"required":false},"releaseReadiness":{"required":false}}'

  $dataWithChecklist = New-FixtureProject -Name "data-with-checklist" -IncludeChecklist
  Assert-Passes -ProjectPath $dataWithChecklist -ChangedFilesJson '{"uiChange":{"required":false},"dataChange":{"required":true},"mobileValidation":{"required":false},"releaseReadiness":{"required":false}}'

  $docsOnly = New-FixtureProject -Name "docs-only"
  Assert-Passes -ProjectPath $docsOnly -ChangedFilesJson '{"uiChange":{"required":false},"dataChange":{"required":false},"mobileValidation":{"required":false},"releaseReadiness":{"required":false}}'

  $invalidChecklistStatus = New-FixtureProject -Name "invalid-checklist-status" -IncludeChecklist
  Update-ReceiptContent -ProjectPath $invalidChecklistStatus -Transform {
    param($content)
    $content -replace '\| none \| none \| none \| not-applicable \| none \| no applicable rules selected yet \|', '| SCR-999 | scripting / 2.1 | high | maybe | pending implementation evidence | pending implementation review |'
  }
  Assert-Fails -ProjectPath $invalidChecklistStatus -ChangedFilesJson '{"uiChange":{"required":false},"dataChange":{"required":false},"mobileValidation":{"required":false},"releaseReadiness":{"required":false}}'

  $incompleteCriticalChecklist = New-FixtureProject -Name "incomplete-critical-checklist" -IncludeChecklist
  Update-ReceiptContent -ProjectPath $incompleteCriticalChecklist -Transform {
    param($content)
    $content -replace '\| none \| none \| none \| not-applicable \| none \| no applicable rules selected yet \|', '| SCR-021 | scripting / 4.4 | critical | applied |  |  |'
  }
  Assert-Fails -ProjectPath $incompleteCriticalChecklist -ChangedFilesJson '{"uiChange":{"required":false},"dataChange":{"required":false},"mobileValidation":{"required":false},"releaseReadiness":{"required":false}}'

  $releasePending = New-FixtureProject -Name "release-pending" -IncludeChecklist -ReleaseVerification "pending" -ReleaseDecision "complete"
  Assert-Fails -ProjectPath $releasePending -ChangedFilesJson '{"uiChange":{"required":false},"dataChange":{"required":false},"mobileValidation":{"required":false},"releaseReadiness":{"required":true}}'

  $generatorFixture = New-FixtureProject -Name "applicable-rules-generator" -IncludeChecklist
  $generatedRules = & $applicableRulesScript -ProjectPath $generatorFixture -SpecDir "specs/001-initial" -ChangedFiles @(".agents/commands/implement.md", "scripts/validate-workflow-receipts.ps1", "templates/spec-workflow/workflow-receipts.template.md") -JsonSummary | ConvertFrom-Json
  if (-not ($generatedRules.registryFilesReviewed.Count -gt 0)) {
    throw "Expected applicable-rule generator to report reviewed registries."
  }
  if (-not ($generatedRules.surfaces -contains "commands")) {
    throw "Expected applicable-rule generator to detect command surface changes."
  }
  if (-not ($generatedRules.selectedRules.Count -gt 0)) {
    throw "Expected applicable-rule generator to select at least one rule."
  }

  $analyzeRules = & $applicableRulesScript -ProjectPath $generatorFixture -SpecDir "specs/001-initial" -ChangedFiles @(".agents/commands/analyze.md", ".agents/commands/tasks.md") -Phase "analyze" -JsonSummary | ConvertFrom-Json
  if (-not ($analyzeRules.selectedRules.Count -gt 0)) {
    throw "Expected analyze-phase applicable-rule preflight to select at least one rule."
  }
  if (-not (($analyzeRules.selectedRules | Where-Object { $_.phases -contains "analyze" }).Count -gt 0)) {
    throw "Expected analyze-phase applicable-rule preflight to keep at least one analyze-phase rule."
  }

  $convergeRules = & $applicableRulesScript -ProjectPath $generatorFixture -SpecDir "specs/001-initial" -ChangedFiles @(".agents/commands/converge.md", ".agents/commands/verify.md", "templates/spec-workflow/converge.template.md") -Phase "converge" -JsonSummary | ConvertFrom-Json
  if (-not ($convergeRules.selectedRules.Count -gt 0)) {
    throw "Expected converge-phase applicable-rule review to select at least one rule."
  }
  if (-not (($convergeRules.selectedRules | Where-Object { $_.phases -contains "converge" }).Count -gt 0)) {
    throw "Expected converge-phase applicable-rule review to keep at least one converge-phase rule."
  }

  $gitFixture = Initialize-GitWorkflowFixture
  $obligations = & $obligationsScript -ProjectPath $gitFixture.RepoPath -BaseRef $gitFixture.BaseCommit -JsonSummary | ConvertFrom-Json

  if (-not $obligations.uiChange.required) {
    throw "Expected UI workflow obligation from committed-tree diff."
  }
  if (-not $obligations.dataChange.required) {
    throw "Expected data workflow obligation from committed-tree diff."
  }
  if (-not ($obligations.changedFiles -contains "src/components/Button.tsx")) {
    throw "Expected committed UI file in obligation diff."
  }
  if (-not ($obligations.changedFiles -contains "supabase/migrations/001.sql")) {
    throw "Expected committed migration file in obligation diff."
  }
  if (-not ($obligations.changedFiles -contains "src/app.css")) {
    throw "Expected working-tree file overlay in obligation diff."
  }

  Write-Host "Workflow enforcement tests passed."
} finally {
  if (Test-Path -LiteralPath $tmpRoot) {
    Remove-Item -LiteralPath $tmpRoot -Recurse -Force
  }
}
