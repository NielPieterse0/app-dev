$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$analyzer = Join-Path $root "scripts/analyze-spec.ps1"
$tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("app-dev-analyze-test-" + [guid]::NewGuid().ToString("N"))

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

function New-AnalyzeFixture {
  param(
    [Parameter(Mandatory=$true)][string]$Name,
    [string]$SpecStatus = "planned",
    [string]$PlanStatus = "planned",
    [string]$TaskLine = "- [ ] Placeholder task",
    [string]$ReceiptVerification = "pending",
    [string]$ReceiptDecision = "planned",
    [switch]$IncludeChecklist,
    [switch]$IncludeClarification,
    [switch]$CreateAuthPath
  )

  $projectPath = Join-Path $tmpRoot $Name
  $specDir = Join-Path $projectPath "specs/001-initial"
  New-Item -ItemType Directory -Force -Path $specDir | Out-Null

  if ($CreateAuthPath) {
    New-Item -ItemType Directory -Force -Path (Join-Path $projectPath "src/modules/auth") | Out-Null
  }

  Write-TextFile -Path (Join-Path $projectPath "AGENTS.md") -Content @"
# Fixture AGENTS

## Active Specification

- specs/001-initial/spec.md
"@

  $planLines = @(
    "# Fixture PLAN",
    "",
    "- Status: $PlanStatus",
    "- Active spec: specs/001-initial/spec.md",
    "- Spec path: specs/001-initial/spec.md",
    "- Tasks path: specs/001-initial/tasks.md"
  )
  Write-TextFile -Path (Join-Path $projectPath "PLAN.md") -Content ($planLines -join "`n")

  $specLines = @(
    "# Fixture Spec",
    "",
    "- Status: $SpecStatus",
    "- Risk level: gated",
    "",
    "## Summary",
    "",
    "Fixture",
    "",
    "## Requirements",
    "",
    "1. Fixture",
    "",
    "## Verification Intent",
    "",
    "- Fixture"
  )
  if ($IncludeClarification) {
    $specLines += "- Clarification: NEEDS CLARIFICATION"
  }
  Write-TextFile -Path (Join-Path $specDir "spec.md") -Content ($specLines -join "`n")

  Write-TextFile -Path (Join-Path $specDir "tasks.md") -Content @"
# Tasks

- Status: $SpecStatus

## Task List

$TaskLine
"@

  Write-TextFile -Path (Join-Path $specDir "workflow-receipts.md") -Content @"
# Receipts

- Status: $SpecStatus

## UI Change Workflow Receipt
- Trigger surface: fixture
- Command path used: fixture
- Local workflow used: fixture
- External skill used or unavailable: fixture
- Files/surfaces reviewed: fixture
- Verification performed: $ReceiptVerification
- Outstanding gaps: none
- Decision/closure: $ReceiptDecision

## Data Change Workflow Receipt
- Trigger surface: fixture
- Command path used: fixture
- Local workflow used: fixture
- External skill used or unavailable: fixture
- Files/surfaces reviewed: fixture
- Verification performed: $ReceiptVerification
- Outstanding gaps: none
- Decision/closure: $ReceiptDecision

## Mobile Validation Workflow Receipt
- Trigger surface: fixture
- Command path used: fixture
- Local workflow used: fixture
- External skill used or unavailable: fixture
- Files/surfaces reviewed: fixture
- Verification performed: n/a
- Outstanding gaps: none
- Decision/closure: deferred

## Release Readiness Workflow Receipt
- Trigger surface: fixture
- Command path used: fixture
- Local workflow used: fixture
- External skill used or unavailable: fixture
- Files/surfaces reviewed: fixture
- Verification performed: $ReceiptVerification
- Outstanding gaps: none
- Decision/closure: $ReceiptDecision
"@

  if ($IncludeChecklist) {
    Write-TextFile -Path (Join-Path $specDir "checklist.md") -Content @"
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
  param([Parameter(Mandatory=$true)][string]$ProjectPath)

  try {
    & $analyzer -ProjectPath $ProjectPath *> $null
    throw "Expected analyze-spec failure for $ProjectPath"
  } catch {
    if ($_.Exception.Message -like "Expected analyze-spec failure*") {
      throw
    }
  }
}

function Assert-Passes {
  param([Parameter(Mandatory=$true)][string]$ProjectPath)

  & $analyzer -ProjectPath $ProjectPath *> $null
}

try {
  New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null

  $fixture = New-AnalyzeFixture -Name "plan-complete-spec-planned" -SpecStatus "planned" -PlanStatus "complete" -IncludeChecklist
  Assert-Fails -ProjectPath $fixture

  $fixture = New-AnalyzeFixture -Name "remove-auth-while-exists" -TaskLine "- [x] Delete 'src/modules/auth'" -IncludeChecklist -CreateAuthPath
  Assert-Fails -ProjectPath $fixture

  $fixture = New-AnalyzeFixture -Name "complete-receipts-pending-verification" -SpecStatus "complete" -PlanStatus "complete" -ReceiptVerification "pending" -ReceiptDecision "complete" -IncludeChecklist
  Assert-Fails -ProjectPath $fixture

  $fixture = New-AnalyzeFixture -Name "completed-spec-needs-clarification" -SpecStatus "complete" -PlanStatus "complete" -ReceiptVerification "done" -ReceiptDecision "complete" -IncludeChecklist -IncludeClarification
  Assert-Fails -ProjectPath $fixture

  $fixture = New-AnalyzeFixture -Name "planned-spec-open-clarification" -IncludeChecklist -IncludeClarification
  foreach ($required in @("AGENTS.md", "PLAN.md", "specs/001-initial/spec.md", "specs/001-initial/tasks.md", "specs/001-initial/workflow-receipts.md", "specs/001-initial/checklist.md")) {
    if (-not (Test-Path -LiteralPath (Join-Path $fixture $required))) {
      throw "Fixture generation failed for ${fixture}: missing $required"
    }
  }
  Assert-Passes -ProjectPath $fixture

  try {
    & $analyzer -ProjectPath (Join-Path $root "projects/signal") *> $null
  } catch {
    throw "Signal analysis should pass while spec 002 remains planned."
  }

  Write-Host "Spec analysis tests passed."
} finally {
  if (Test-Path -LiteralPath $tmpRoot) {
    Remove-Item -LiteralPath $tmpRoot -Recurse -Force
  }
}
