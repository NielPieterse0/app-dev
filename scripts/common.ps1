$ErrorActionPreference = "Stop"

$script:AllowedRiskLevels = @("standard", "gated", "sensitive")
$script:GatedRiskLevels = @("gated", "sensitive")
$script:CompletedStatuses = @("complete", "completed", "done")
$script:InvalidVerificationStates = @("pending", "not-run", "none")

function Add-HarnessFailure {
  param(
    [Parameter(Mandatory=$true)]$Failures,
    [Parameter(Mandatory=$true)][string]$Message
  )

  $Failures.Add($Message) | Out-Null
}

function Resolve-ProjectPath {
  param([Parameter(Mandatory=$true)][string]$ProjectPath)

  if (-not (Test-Path -LiteralPath $ProjectPath)) {
    throw "Project path does not exist: $ProjectPath"
  }

  return (Resolve-Path -LiteralPath $ProjectPath).Path
}

function Get-ActiveSpecRelativePath {
  param([Parameter(Mandatory=$true)][string]$AgentsPath)

  $content = Get-Content -LiteralPath $AgentsPath -Raw
  $match = [regex]::Match($content, "specs/\d{3}-[a-z0-9-]+/spec\.md")
  if ($match.Success) {
    return $match.Value
  }

  return $null
}

function Get-ActivePlanRelativePath {
  param([Parameter(Mandatory=$true)][string]$AgentsPath)

  $activeSpecRelativePath = Get-ActiveSpecRelativePath -AgentsPath $AgentsPath
  if ([string]::IsNullOrWhiteSpace($activeSpecRelativePath)) {
    return $null
  }

  $specDir = Split-Path -Parent $activeSpecRelativePath
  return (Join-Path $specDir "plan.md") -replace "\\", "/"
}

function Get-AllowedRiskLevels {
  return @($script:AllowedRiskLevels)
}

function Get-GatedRiskLevels {
  return @($script:GatedRiskLevels)
}

function Get-CompletedStatuses {
  return @($script:CompletedStatuses)
}

function Get-InvalidVerificationStates {
  return @($script:InvalidVerificationStates)
}

function Test-GatedRiskLevel {
  param([Parameter(Mandatory=$true)][string]$RiskLevel)

  return ([string]$RiskLevel).Trim().ToLowerInvariant() -in (Get-GatedRiskLevels)
}

function Test-CompletedStatus {
  param([string]$Status)

  return ([string]$Status).Trim().ToLowerInvariant() -in (Get-CompletedStatuses)
}

function Test-InvalidVerificationState {
  param([string]$Status)

  return ([string]$Status).Trim().ToLowerInvariant() -in (Get-InvalidVerificationStates)
}

function Assert-AllowedRiskLevel {
  param([Parameter(Mandatory=$true)][string]$RiskLevel)

  if (([string]$RiskLevel).Trim().ToLowerInvariant() -notin (Get-AllowedRiskLevels)) {
    throw ("Risk level must be one of: {0}" -f ((Get-AllowedRiskLevels) -join ", "))
  }
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

  return ""
}

function Get-FieldValue {
  param(
    [Parameter(Mandatory=$true)][string]$Section,
    [Parameter(Mandatory=$true)][string]$Field
  )

  $pattern = "(?im)^-\s+(?:\[[ xX]\]\s+)?$([regex]::Escape($Field)):\s*(.+)$"
  $match = [regex]::Match($Section, $pattern)
  if ($match.Success) {
    return $match.Groups[1].Value.Trim()
  }

  return ""
}

function Write-CorrectiveFailure {
  param(
    [Parameter(Mandatory=$true)][string]$Summary,
    [Parameter(Mandatory=$true)][System.Collections.Generic.List[string]]$Failures
  )

  Write-Error ($Summary + "`n" + ($Failures -join "`n"))
}
