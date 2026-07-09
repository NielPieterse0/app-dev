param(
  [string]$ProjectPath = (Get-Location).Path,
  [string]$SpecPath,
  [string]$ChangedFilesJson,
  [switch]$RequireVerificationEvidence,
  [switch]$JsonSummary
)

$ErrorActionPreference = "Stop"
$commonPath = Join-Path $PSScriptRoot "common.ps1"
. $commonPath
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([Parameter(Mandatory=$true)][string]$Message)
  Add-HarnessFailure -Failures $failures -Message $Message
}

function Get-SectionBody {
  param(
    [Parameter(Mandatory=$true)][string]$Content,
    [Parameter(Mandatory=$true)][string]$Heading
  )

  $pattern = "(?ms)^##\s+$([regex]::Escape($Heading))\s*\r?\n(.*?)(?=^##\s+|\z)"
  $match = [regex]::Match($Content, $pattern)
  if ($match.Success) {
    return $match.Groups[1].Value
  }
  return $null
}

function Get-FieldValue {
  param(
    [Parameter(Mandatory=$true)][string]$Section,
    [Parameter(Mandatory=$true)][string]$Field
  )

  $pattern = "(?m)^-\s+$([regex]::Escape($Field)):\s*(.+)$"
  $match = [regex]::Match($Section, $pattern)
  if ($match.Success) {
    return $match.Groups[1].Value.Trim()
  }
  return $null
}

function Test-ReceiptSection {
  param(
    [Parameter(Mandatory=$true)][string]$ReceiptContent,
    [Parameter(Mandatory=$true)][string]$Heading,
    [Parameter(Mandatory=$true)][bool]$Required,
    [Parameter(Mandatory=$true)][bool]$RequireVerificationEvidence
  )

  $section = Get-SectionBody -Content $ReceiptContent -Heading $Heading
  if ($null -eq $section) {
    if ($Required) {
      Add-Failure "workflow-receipts.md is missing required section: $Heading"
    }
    return
  }

  foreach ($field in @("Trigger surface", "Command path used", "Local workflow used", "External skill used or unavailable", "Files/surfaces reviewed", "Verification performed", "Outstanding gaps", "Decision/closure")) {
    $value = Get-FieldValue -Section $section -Field $field
    if ([string]::IsNullOrWhiteSpace($value)) {
      Add-Failure "$Heading is missing required field content: $field"
    }
  }

  if (-not $Required) {
    return
  }

  $closure = Get-FieldValue -Section $section -Field "Decision/closure"
  if ($closure -match '^(not-applicable|not-started)$') {
    Add-Failure "$Heading is required for this change set but Decision/closure is '$closure'."
  }

  if ($RequireVerificationEvidence) {
    $verification = Get-FieldValue -Section $section -Field "Verification performed"
    if ($verification -match '^(pending|not-run|none)$') {
      Add-Failure "$Heading is required for this change set but Verification performed is '$verification'."
    }
  }
}

$ProjectPath = Resolve-ProjectPath -ProjectPath $ProjectPath
$agentsPath = Join-Path $ProjectPath "AGENTS.md"
$planPath = Join-Path $ProjectPath "PLAN.md"
$specsPath = Join-Path $ProjectPath "specs"

foreach ($path in @($agentsPath, $planPath, $specsPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    Add-Failure "Missing required path for workflow receipt validation: $path"
  }
}

if ([string]::IsNullOrWhiteSpace($SpecPath)) {
  $activeSpecRelative = Get-ActiveSpecRelativePath -AgentsPath $agentsPath
  if ([string]::IsNullOrWhiteSpace($activeSpecRelative)) {
    Add-Failure "Missing active spec. Run ./scripts/new-spec.ps1 -ProjectPath <path> -Slug <slug> first."
  } else {
    $SpecPath = Join-Path $ProjectPath $activeSpecRelative
  }
}

if (-not (Test-Path -LiteralPath $SpecPath)) {
  Add-Failure "Active spec path does not exist for workflow receipt validation: $SpecPath"
}

$specDir = if ($SpecPath) { Split-Path -Parent $SpecPath } else { $null }
$receiptPath = if ($specDir) { Join-Path $specDir "workflow-receipts.md" } else { $null }
$checklistPath = if ($specDir) { Join-Path $specDir "checklist.md" } else { $null }

if ($receiptPath -and -not (Test-Path -LiteralPath $receiptPath)) {
  Add-Failure "Missing workflow receipt file: $receiptPath"
}

$obligations = $null
if (-not [string]::IsNullOrWhiteSpace($ChangedFilesJson)) {
  $payload = $ChangedFilesJson | ConvertFrom-Json -ErrorAction Stop
  $obligations = [ordered]@{
    uiChange = $payload.uiChange
    dataChange = $payload.dataChange
    mobileValidation = $payload.mobileValidation
    releaseReadiness = $payload.releaseReadiness
  }
} else {
  $obligationScript = Join-Path (Split-Path -Parent $PSScriptRoot) "scripts\get-workflow-obligations.ps1"
  $payload = & $obligationScript -ProjectPath $ProjectPath -JsonSummary | ConvertFrom-Json -ErrorAction Stop
  $obligations = [ordered]@{
    uiChange = $payload.uiChange
    dataChange = $payload.dataChange
    mobileValidation = $payload.mobileValidation
    releaseReadiness = $payload.releaseReadiness
  }
}

if (Test-Path -LiteralPath $receiptPath) {
  $receiptContent = Get-Content -LiteralPath $receiptPath -Raw
  Test-ReceiptSection -ReceiptContent $receiptContent -Heading "UI Change Workflow Receipt" -Required ([bool]$obligations.uiChange.required) -RequireVerificationEvidence $RequireVerificationEvidence
  Test-ReceiptSection -ReceiptContent $receiptContent -Heading "Data Change Workflow Receipt" -Required ([bool]$obligations.dataChange.required) -RequireVerificationEvidence $RequireVerificationEvidence
  Test-ReceiptSection -ReceiptContent $receiptContent -Heading "Mobile Validation Workflow Receipt" -Required ([bool]$obligations.mobileValidation.required) -RequireVerificationEvidence $RequireVerificationEvidence
  Test-ReceiptSection -ReceiptContent $receiptContent -Heading "Release Readiness Workflow Receipt" -Required ([bool]$obligations.releaseReadiness.required) -RequireVerificationEvidence $RequireVerificationEvidence
}

if (([bool]$obligations.dataChange.required -or [bool]$obligations.releaseReadiness.required) -and -not (Test-Path -LiteralPath $checklistPath)) {
  Add-Failure "Gated spec requires checklist.md. Create it from templates/spec-workflow/checklist.template.md."
}

$summary = [ordered]@{
  projectPath = $ProjectPath
  specPath = $SpecPath
  receiptPath = $receiptPath
  obligations = $obligations
  failures = @($failures)
  failureCount = $failures.Count
}

if ($JsonSummary) {
  $summary | ConvertTo-Json -Depth 6
}

if ($failures.Count -gt 0) {
  Write-CorrectiveFailure -Summary "Workflow receipt validation failed:" -Failures $failures
}

Write-Host "Workflow receipt validation passed for $ProjectPath"
