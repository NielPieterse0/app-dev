param(
  [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$commonPath = Join-Path $PSScriptRoot "common.ps1"
. $commonPath
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([Parameter(Mandatory=$true)][string]$Message)
  Add-HarnessFailure -Failures $failures -Message $Message
}

function Assert-Contains {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string[]]$Needles
  )

  $content = Get-Content -LiteralPath $Path -Raw
  foreach ($needle in $Needles) {
    if ($content -notmatch [regex]::Escape($needle)) {
      Add-Failure "$Path is missing required content: $needle"
    }
  }
  return $content
}

$ProjectPath = Resolve-ProjectPath -ProjectPath $ProjectPath
$agentsPath = Join-Path $ProjectPath "AGENTS.md"
$planPath = Join-Path $ProjectPath "PLAN.md"
$specsPath = Join-Path $ProjectPath "specs"

foreach ($path in @($agentsPath, $planPath, $specsPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    Add-Failure "Missing required spec artifact path: $path"
  }
}

if (-not (Test-Path -LiteralPath $specsPath)) {
  Write-Error ("Spec artifact validation failed:`n" + ($failures -join "`n"))
}

$specDirs = Get-ChildItem -LiteralPath $specsPath -Directory | Sort-Object Name
if ($specDirs.Count -eq 0) {
  Add-Failure "No numbered spec folders exist under $specsPath"
}

$expected = 1
$activeSpecRelative = $null
if (Test-Path -LiteralPath $agentsPath) {
  $agentsContent = Assert-Contains -Path $agentsPath -Needles @("Active Specification", "specs/")
  $match = [regex]::Match($agentsContent, "specs/\d{3}-[a-z0-9-]+/spec\.md")
  if (-not $match.Success) {
    Add-Failure "Missing active spec. Run ./scripts/new-spec.ps1 -ProjectPath <path> -Slug <slug> first."
  } else {
    $activeSpecRelative = $match.Value.Replace("/", "\")
  }
}

if (Test-Path -LiteralPath $planPath) {
  $planContent = Assert-Contains -Path $planPath -Needles @("Active spec:", "Spec path:", "Tasks path:")
  if ($activeSpecRelative) {
    $planExpected = $activeSpecRelative.Replace("\spec.md", "/spec.md").Replace("\", "/")
    if ($planContent -notmatch [regex]::Escape($planExpected)) {
      Add-Failure "PLAN.md must reference the same active spec path as AGENTS.md."
    }
  }
}

foreach ($dir in $specDirs) {
  if ($dir.Name -notmatch "^(\d{3})-([a-z0-9-]+)$") {
    Add-Failure "Spec folder name must match NNN-slug format: $($dir.Name)"
    continue
  }

  $number = [int]$matches[1]
  if ($number -ne $expected) {
    Add-Failure ("Spec numbering must be monotonic and zero-padded. Expected {0:D3}, found {1}" -f $expected, $matches[1])
    $expected = $number
  }
  $expected++

  $specPath = Join-Path $dir.FullName "spec.md"
  $tasksPath = Join-Path $dir.FullName "tasks.md"
  $receiptPath = Join-Path $dir.FullName "workflow-receipts.md"
  $checklistPath = Join-Path $dir.FullName "checklist.md"

  foreach ($requiredPath in @($specPath, $tasksPath, $receiptPath)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
      Add-Failure "Missing required feature artifact: $requiredPath"
    }
  }

  if (Test-Path -LiteralPath $specPath) {
    $specContent = Assert-Contains -Path $specPath -Needles @("## Summary", "## Requirements", "## Verification Intent")
    if ($specContent -match "{{|Replace this line|Replace with") {
      Add-Failure "$specPath still contains unresolved template placeholders."
    }
  }

  if (Test-Path -LiteralPath $tasksPath) {
    $tasksContent = Assert-Contains -Path $tasksPath -Needles @("## Task List", "check-spec-artifacts.ps1", "verify-app.ps1")
    if ($tasksContent -match "{{|Replace this section") {
      Add-Failure "$tasksPath still contains unresolved template placeholders."
    }
  }

  if (Test-Path -LiteralPath $receiptPath) {
    $receiptContent = Assert-Contains -Path $receiptPath -Needles @(
      "## Workflow Classification",
      "## UI Change Workflow Receipt",
      "## Data Change Workflow Receipt",
      "## Mobile Validation Workflow Receipt",
      "## Release Readiness Workflow Receipt"
    )
    foreach ($needle in @("Trigger surface:", "Command path used:", "Local workflow used:", "Verification performed:", "Decision/closure:")) {
      if ($receiptContent -notmatch [regex]::Escape($needle)) {
        Add-Failure "$receiptPath is missing required content: $needle"
      }
    }
  }

  $requiresChecklist = $false
  if (Test-Path -LiteralPath $specPath) {
    $specRaw = Get-Content -LiteralPath $specPath -Raw
    $riskMatch = [regex]::Match($specRaw, "(?im)^-\s*Risk level:\s*(.+)$")
    if ($riskMatch.Success -and (Test-GatedRiskLevel -RiskLevel $riskMatch.Groups[1].Value)) {
      $requiresChecklist = $true
    }
  }

  if ($requiresChecklist) {
    if (-not (Test-Path -LiteralPath $checklistPath)) {
      Add-Failure "Gated spec requires checklist.md. Create it from templates/spec-workflow/checklist.template.md."
    } else {
      $checklistContent = Assert-Contains -Path $checklistPath -Needles @("## Clarify", "## Security And Data Review", "## Implementation Readiness")
      if ($checklistContent -match "{{|Replace with") {
        Add-Failure "$checklistPath still contains unresolved template placeholders."
      }
    }
  }
}

if ($activeSpecRelative) {
  $activeSpecPath = Join-Path $ProjectPath $activeSpecRelative
  if (-not (Test-Path -LiteralPath $activeSpecPath)) {
    Add-Failure "Active spec path does not exist: $activeSpecRelative"
  }
}

if ($failures.Count -gt 0) {
  Write-CorrectiveFailure -Summary "Spec artifact validation failed:" -Failures $failures
}

Write-Host "Spec artifact validation passed for $ProjectPath"
