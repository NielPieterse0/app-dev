$ErrorActionPreference = "Stop"

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

function Test-GatedRiskLevel {
  param([Parameter(Mandatory=$true)][string]$RiskLevel)

  return $RiskLevel.Trim().ToLowerInvariant() -in @("gated", "sensitive")
}

function Write-CorrectiveFailure {
  param(
    [Parameter(Mandatory=$true)][string]$Summary,
    [Parameter(Mandatory=$true)][System.Collections.Generic.List[string]]$Failures
  )

  Write-Error ($Summary + "`n" + ($Failures -join "`n"))
}
