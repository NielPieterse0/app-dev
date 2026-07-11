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

function Test-ReceiptSection {
  param(
    [Parameter(Mandatory=$true)][string]$ReceiptContent,
    [Parameter(Mandatory=$true)][string]$Heading,
    [switch]$Required,
    [switch]$RequireVerificationEvidence
  )

  $section = Get-SectionBody -Content $ReceiptContent -Heading $Heading
  if ([string]::IsNullOrWhiteSpace($section)) {
    if ($Required) {
      Add-Failure "workflow-receipts.md is missing required section: $Heading"
    }
    return
  }

  foreach ($field in @("Trigger surface", "Command path used", "Local workflow used", "External skill used or unavailable", "Files/surfaces reviewed", "Outstanding gaps", "Decision/closure")) {
    $value = Get-FieldValue -Section $section -Field $field
    if ([string]::IsNullOrWhiteSpace($value)) {
      Add-Failure "$Heading is missing required field content: $field"
    }
  }

  $legacyVerification = Get-FieldValue -Section $section -Field "Verification performed"
  $implementationEvidence = Get-FieldValue -Section $section -Field "Implementation evidence"
  $verificationCommands = Get-FieldValue -Section $section -Field "Verification commands"
  $verificationResult = Get-FieldValue -Section $section -Field "Verification result"
  if ([string]::IsNullOrWhiteSpace($legacyVerification)) {
    foreach ($fieldInfo in @(
      @{ Name = "Implementation evidence"; Value = $implementationEvidence },
      @{ Name = "Verification commands"; Value = $verificationCommands },
      @{ Name = "Verification result"; Value = $verificationResult }
    )) {
      if ([string]::IsNullOrWhiteSpace($fieldInfo.Value)) {
        Add-Failure "$Heading is missing required field content: $($fieldInfo.Name)"
      }
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
    $verification = Get-FieldValue -Section $section -Field "Verification result"
    if ([string]::IsNullOrWhiteSpace($verification)) {
      $verification = Get-FieldValue -Section $section -Field "Verification performed"
    }
    if (Test-InvalidVerificationState -Status $verification) {
      Add-Failure "$Heading is required for this change set but verification evidence is '$verification'."
    }
  }
}

$ProjectPath = Resolve-ProjectPath -ProjectPath $ProjectPath
$agentsPath = Join-Path $ProjectPath "AGENTS.md"
$specsPath = Join-Path $ProjectPath "specs"

foreach ($path in @($agentsPath, $specsPath)) {
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

$planRelative = Get-ActivePlanRelativePath -AgentsPath $agentsPath
if (-not [string]::IsNullOrWhiteSpace($planRelative)) {
  $planPath = Join-Path $ProjectPath $planRelative
  if (-not (Test-Path -LiteralPath $planPath)) {
    $fallbackPlanPath = if ($SpecPath) { Join-Path (Split-Path -Parent $SpecPath) "plan.md" } else { $null }
    if ($fallbackPlanPath -and (Test-Path -LiteralPath $fallbackPlanPath)) {
      $planPath = $fallbackPlanPath
    }
  }
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
  $obligationScript = Join-Path (Split-Path -Parent $PSScriptRoot) "scripts/get-workflow-obligations.ps1"
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
  $applicableHeading = "Applicable Standards Checklist"
  $applicableSection = Get-SectionBody -Content $receiptContent -Heading $applicableHeading
  if (-not [string]::IsNullOrWhiteSpace($applicableSection)) {
    foreach ($field in @("Status", "Selection basis", "Registry files reviewed", "Prose standards consulted", "Critical/high rule summary")) {
      $value = Get-FieldValue -Section $applicableSection -Field $field
      if ([string]::IsNullOrWhiteSpace($value)) {
        Add-Failure "$applicableHeading is missing required field content: $field"
      }
    }

    foreach ($requiredText in @("| Rule | Reference | Severity | Status | Evidence | Reason or next action |", "Allowed statuses:")) {
      if ($applicableSection -notmatch [regex]::Escape($requiredText)) {
        Add-Failure "$applicableHeading is missing required content: $requiredText"
      }
    }

    $checklistRows = New-Object System.Collections.Generic.List[object]
    foreach ($line in ($applicableSection -split "\r?\n")) {
      if ($line -notmatch '^\|\s*.+\|\s*$') {
        continue
      }
      if ($line -match '^\|\s*-+\s*\|') {
        continue
      }

      $cells = @($line.Trim().Trim('|').Split('|') | ForEach-Object { $_.Trim() })
      if ($cells.Count -ne 6) {
        continue
      }
      if ($cells[0] -eq "Rule" -and $cells[1] -eq "Reference") {
        continue
      }

      $checklistRows.Add([pscustomobject]@{
        Rule = $cells[0]
        Reference = $cells[1]
        Severity = $cells[2]
        Status = $cells[3]
        Evidence = $cells[4]
        Reason = $cells[5]
      }) | Out-Null
    }

    $checklistRowsArray = $checklistRows.ToArray()
    if ($checklistRowsArray.Count -eq 0) {
      Add-Failure "$applicableHeading must contain at least one checklist row."
    } else {
      $allowedStatuses = @("applied", "not-applicable", "deferred", "blocked")
      foreach ($row in $checklistRowsArray) {
        $status = ([string]$row.Status).Trim().ToLowerInvariant()
        if ($status -notin $allowedStatuses) {
          Add-Failure "$applicableHeading has invalid status '$($row.Status)' for rule '$($row.Rule)'."
          continue
        }

        $severity = ([string]$row.Severity).Trim().ToLowerInvariant()
        if ($severity -in @("critical", "high")) {
          foreach ($field in @("Rule", "Reference", "Status", "Evidence", "Reason")) {
            $value = [string]$row.$field
            if ([string]::IsNullOrWhiteSpace($value)) {
              Add-Failure "$applicableHeading critical/high row is missing required value '$field'."
            }
          }
        }
      }
    }
  }
  Test-ReceiptSection -ReceiptContent $receiptContent -Heading "UI Change Workflow Receipt" -Required:$obligations.uiChange.required -RequireVerificationEvidence:$RequireVerificationEvidence
  Test-ReceiptSection -ReceiptContent $receiptContent -Heading "Data Change Workflow Receipt" -Required:$obligations.dataChange.required -RequireVerificationEvidence:$RequireVerificationEvidence
  Test-ReceiptSection -ReceiptContent $receiptContent -Heading "Mobile Validation Workflow Receipt" -Required:$obligations.mobileValidation.required -RequireVerificationEvidence:$RequireVerificationEvidence
  Test-ReceiptSection -ReceiptContent $receiptContent -Heading "Release Readiness Workflow Receipt" -Required:$obligations.releaseReadiness.required -RequireVerificationEvidence:$RequireVerificationEvidence
}

if (($obligations.dataChange.required -or $obligations.releaseReadiness.required) -and -not (Test-Path -LiteralPath $checklistPath)) {
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
