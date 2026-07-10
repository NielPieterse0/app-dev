param(
  [string]$ProjectPath = (Get-Location).Path,
  [ValidateSet("compatibility", "current-template")]
  [string]$ValidationMode = "compatibility"
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
  $activeSpecRelative = Get-ActiveSpecRelativePath -AgentsPath $agentsPath
  if ([string]::IsNullOrWhiteSpace($activeSpecRelative)) {
    Add-Failure "Missing active spec. Run ./scripts/new-spec.ps1 -ProjectPath <path> -Slug <slug> first."
  }
}

function Test-UnresolvedTemplateText {
  param([Parameter(Mandatory=$true)][string]$Content)

  return $Content -match "{{|Replace this line|Replace with|\bTODO:"
}

if (Test-Path -LiteralPath $planPath) {
  $planContent = Assert-Contains -Path $planPath -Needles @("Active spec:", "Spec path:", "Tasks path:")
  if ($ValidationMode -eq "current-template") {
    foreach ($needle in @("## Technical Context", "## Project Structure And Ownership", "## Complexity Tracking", "## Verification Strategy", "## Rendered UI Verification")) {
      if ($planContent -notmatch [regex]::Escape($needle)) {
        Add-Failure "PLAN.md is missing current-template plan content: $needle"
      }
    }
  }
  if ($activeSpecRelative) {
    $planExpected = $activeSpecRelative
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
    if ($ValidationMode -eq "current-template" -or $specContent -match "## User Scenarios And Testing") {
      foreach ($needle in @("## User Scenarios And Testing", "## Success Criteria")) {
        if ($specContent -notmatch [regex]::Escape($needle)) {
          Add-Failure "$specPath is missing current-template spec content: $needle"
        }
      }
      foreach ($needle in @("## Success Criteria")) {
        if ($specContent -notmatch [regex]::Escape($needle)) {
          Add-Failure "$specPath is missing required content: $needle"
        }
      }
      foreach ($pattern in @("FR-\d{3}", "SC-\d{3}", "Independent Test")) {
        if ($specContent -notmatch $pattern) {
          Add-Failure "$specPath is missing required spec pattern: $pattern"
        }
      }
    }
    if (Test-UnresolvedTemplateText -Content $specContent) {
      Add-Failure "$specPath still contains unresolved template placeholders."
    }
  }

  if (Test-Path -LiteralPath $tasksPath) {
    $tasksContent = Assert-Contains -Path $tasksPath -Needles @("## Task List", "check-spec-artifacts.ps1", "verify-app.ps1")
    if ($ValidationMode -eq "current-template") {
      foreach ($needle in @("## Task Format", "## Dependencies And Order", "## Parallel Opportunities", "[US1]", "[P]", "Repeat the user story phase")) {
        if ($tasksContent -notmatch [regex]::Escape($needle)) {
          Add-Failure "$tasksPath is missing current-template task content: $needle"
        }
      }
    }
    if ($ValidationMode -eq "current-template" -or $tasksContent -match "## Task Format") {
      if ($tasksContent -notmatch "\bT001\b") {
        Add-Failure "$tasksPath is missing required content: T001"
      }
      $taskRows = [regex]::Matches($tasksContent, "(?im)^-\s*\[[ xX]\]\s+(.+)$")
      foreach ($row in $taskRows) {
        $taskText = $row.Groups[1].Value.Trim()
        if ($taskText -notmatch "^T\d{3}\b") {
          Add-Failure "$tasksPath has a checklist task without a T### task id: $taskText"
        }
      }
    }
    if (Test-UnresolvedTemplateText -Content $tasksContent) {
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
    foreach ($needle in @("Trigger surface:", "Command path used:", "Local workflow used:", "Implementation evidence:", "Verification commands:", "Verification result:", "Decision/closure:")) {
      if ($receiptContent -notmatch [regex]::Escape($needle)) {
        if ($needle -in @("Implementation evidence:", "Verification commands:", "Verification result:") -and $receiptContent -match [regex]::Escape("Verification performed:")) {
          continue
        }
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
      if (Test-UnresolvedTemplateText -Content $checklistContent) {
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

Write-Host "Spec artifact validation passed for $ProjectPath ($ValidationMode)"
