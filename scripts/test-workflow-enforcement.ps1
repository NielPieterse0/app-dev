$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$common = Join-Path $root "scripts\common.ps1"
$validator = Join-Path $root "scripts\validate-workflow-receipts.ps1"
$tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("app-dev-workflow-test-" + [guid]::NewGuid().ToString("N"))

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
    [string]$ReceiptOverrides = "",
    [switch]$IncludeChecklist,
    [switch]$UiNotRun
  )

  $projectPath = Join-Path $tmpRoot $Name
  New-Item -ItemType Directory -Force -Path (Join-Path $projectPath "specs\001-initial") | Out-Null

  Write-TextFile -Path (Join-Path $projectPath "AGENTS.md") -Content @"
# Fixture AGENTS

## Active Specification

- specs/001-initial/spec.md
"@

  Write-TextFile -Path (Join-Path $projectPath "PLAN.md") -Content @"
# Fixture PLAN

Active spec: specs/001-initial/spec.md
Spec path: specs/001-initial/spec.md
Tasks path: specs/001-initial/tasks.md
"@

  Write-TextFile -Path (Join-Path $projectPath "specs\001-initial\spec.md") -Content @"
# 001 Fixture Specification

- Risk level: sensitive
"@

  Write-TextFile -Path (Join-Path $projectPath "specs\001-initial\tasks.md") -Content "# tasks"

  $uiVerification = if ($UiNotRun) { "not-run" } else { "rendered desktop and mobile checks" }
  $uiClosure = if ($UiNotRun) { "not-applicable" } else { "complete" }

  $receipts = @"
# 001 Fixture Workflow Receipts

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
- Verification performed: verify-app and workflow validation complete
- Outstanding gaps: none
- Decision/closure: complete
$ReceiptOverrides
"@

  Write-TextFile -Path (Join-Path $projectPath "specs\001-initial\workflow-receipts.md") -Content $receipts

  if ($IncludeChecklist) {
    Write-TextFile -Path (Join-Path $projectPath "specs\001-initial\checklist.md") -Content @"
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

try {
  New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null

  foreach ($risk in @("gated", "sensitive")) {
    if (-not (Test-GatedRiskLevel -RiskLevel $risk)) {
      throw "Expected '$risk' to require gated artifacts."
    }
  }

  $bareSwitchProject = New-FixtureProject -Name "bare-switch" -IncludeChecklist
  try {
    & $validator -ProjectPath $bareSwitchProject -ChangedFilesJson '{"uiChange":{"required":false},"dataChange":{"required":true},"mobileValidation":{"required":false},"releaseReadiness":{"required":false}}' -RequireVerificationEvidence *> $null
  } catch {
    throw "Bare -RequireVerificationEvidence must be accepted."
  }

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

  Write-Host "Workflow enforcement tests passed."
} finally {
  if (Test-Path -LiteralPath $tmpRoot) {
    Remove-Item -LiteralPath $tmpRoot -Recurse -Force
  }
}
