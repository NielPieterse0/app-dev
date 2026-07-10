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

function Get-MarkdownStatus {
  param([Parameter(Mandatory=$true)][string]$Content)

  $match = [regex]::Match($Content, "(?im)^-\s*Status:\s*(.+)$")
  if ($match.Success) {
    return $match.Groups[1].Value.Trim().ToLowerInvariant()
  }

  return ""
}

function Test-ChecklistRequired {
  param([Parameter(Mandatory=$true)][string]$SpecContent)

  $riskMatch = [regex]::Match($SpecContent, "(?im)^-\s*Risk level:\s*(.+)$")
  if (-not $riskMatch.Success) {
    return $false
  }

  return Test-GatedRiskLevel -RiskLevel $riskMatch.Groups[1].Value
}

function Test-RelativeTaskPathExists {
  param(
    [Parameter(Mandatory=$true)][string]$ProjectPath,
    [Parameter(Mandatory=$true)][string]$TaskText
  )

  $match = [regex]::Match($TaskText, '(?i)([''`"])([^''`"]+)\1')
  if (-not $match.Success) {
    return $false
  }

  $candidate = $match.Groups[2].Value.Trim()
  if ([string]::IsNullOrWhiteSpace($candidate)) {
    return $false
  }

  return Test-Path -LiteralPath (Join-Path $ProjectPath $candidate)
}

$ProjectPath = Resolve-ProjectPath -ProjectPath $ProjectPath
$agentsPath = Join-Path $ProjectPath "AGENTS.md"

if (-not (Test-Path -LiteralPath $agentsPath)) {
  Write-CorrectiveFailure -Summary "Spec analysis failed:" -Failures ([System.Collections.Generic.List[string]]@("Missing AGENTS.md: $agentsPath"))
}

$activeSpecRelative = Get-ActiveSpecRelativePath -AgentsPath $agentsPath
if ([string]::IsNullOrWhiteSpace($activeSpecRelative)) {
  Write-CorrectiveFailure -Summary "Spec analysis failed:" -Failures ([System.Collections.Generic.List[string]]@("Missing active spec. Run ./scripts/new-spec.ps1 -ProjectPath <path> -Slug <slug> first."))
}

$specPath = Join-Path $ProjectPath $activeSpecRelative
$specDir = Split-Path -Parent $specPath
$planPath = Join-Path $ProjectPath "PLAN.md"
$tasksPath = Join-Path $specDir "tasks.md"
$receiptsPath = Join-Path $specDir "workflow-receipts.md"
$checklistPath = Join-Path $specDir "checklist.md"

foreach ($path in @($specPath, $planPath, $tasksPath, $receiptsPath)) {
  if (-not (Test-Path -LiteralPath $path)) {
    Add-Failure "Missing required artifact for spec analysis: $path"
  }
}

if ($failures.Count -gt 0) {
  Write-CorrectiveFailure -Summary "Spec analysis failed:" -Failures $failures
}

$specContent = Get-Content -LiteralPath $specPath -Raw
$planContent = Get-Content -LiteralPath $planPath -Raw
$tasksContent = Get-Content -LiteralPath $tasksPath -Raw
$receiptsContent = Get-Content -LiteralPath $receiptsPath -Raw

$specStatus = Get-MarkdownStatus -Content $specContent
$planStatus = Get-MarkdownStatus -Content $planContent

if ((Test-CompletedStatus -Status $planStatus) -and -not (Test-CompletedStatus -Status $specStatus)) {
  Add-Failure "PLAN.md is complete while the active spec remains $specStatus."
}

if ((Test-ChecklistRequired -SpecContent $specContent) -and -not (Test-Path -LiteralPath $checklistPath)) {
  Add-Failure "Gated spec requires checklist.md. Create it from templates/spec-workflow/checklist.template.md."
}

$checkedTasks = [regex]::Matches($tasksContent, "(?im)^-\s*\[x\]\s+(.+)$")
foreach ($task in $checkedTasks) {
  $taskText = $task.Groups[1].Value.Trim()
  if ($taskText -match "(?i)\b(remove|delete)\b" -and (Test-RelativeTaskPathExists -ProjectPath $ProjectPath -TaskText $taskText)) {
    Add-Failure "Completed removal task still points to a path that exists: $taskText"
  }
}

foreach ($heading in @(
  "UI Change Workflow Receipt",
  "Data Change Workflow Receipt",
  "Mobile Validation Workflow Receipt",
  "Release Readiness Workflow Receipt"
)) {
  $section = Get-SectionBody -Content $receiptsContent -Heading $heading
  if ([string]::IsNullOrWhiteSpace($section)) {
    continue
  }

  $decision = Get-FieldValue -Section $section -Field "Decision/closure"
  $verification = Get-FieldValue -Section $section -Field "Verification result"
  if ([string]::IsNullOrWhiteSpace($verification)) {
    $verification = Get-FieldValue -Section $section -Field "Verification performed"
  }
  if ((Test-CompletedStatus -Status $decision) -and (Test-InvalidVerificationState -Status $verification)) {
    Add-Failure "$heading is marked complete while verification evidence is '$verification'."
  }
}

if (((Test-CompletedStatus -Status $specStatus) -or (Test-CompletedStatus -Status $planStatus)) -and ($specContent -match "NEEDS CLARIFICATION")) {
  Add-Failure "Completed artifacts may not contain unresolved NEEDS CLARIFICATION markers."
}

$mentionsNoAuth = $specContent -match '(?i)\bno-auth\b|\banon(ymous)?\b'
$hasNoAuthGuardrail = $specContent -match '(?i)(internal[- ]mvp|not production|not production-ready|public launch|public-launch safe|blocks public launch)'
if ($mentionsNoAuth -and -not $hasNoAuthGuardrail) {
  Add-Failure "No-auth or anonymous browser-access wording must also state the internal-MVP or not-production/public-launch guardrail."
}

if ($failures.Count -gt 0) {
  Write-CorrectiveFailure -Summary "Spec analysis failed:" -Failures $failures
}

Write-Host "Spec analysis passed."
