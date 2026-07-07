param(
  [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ProjectPath)) {
  Write-Error "Project path does not exist: $ProjectPath"
}

$packageJson = Join-Path $ProjectPath "package.json"
if (Test-Path $packageJson) {
  Write-Host "JavaScript/TypeScript project detected. Consider running scripts/verify-app.ps1 -ProjectPath `"$ProjectPath`" before handoff."
  $root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
  $obligationScript = Join-Path $root "scripts\get-workflow-obligations.ps1"
  if (Test-Path -LiteralPath $obligationScript) {
    $summary = & $obligationScript -ProjectPath $ProjectPath -JsonSummary:$true | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($null -ne $summary) {
      $required = @()
      foreach ($pair in @(
        @{ Name = "UI"; Bucket = $summary.uiChange },
        @{ Name = "Data"; Bucket = $summary.dataChange },
        @{ Name = "Mobile"; Bucket = $summary.mobileValidation },
        @{ Name = "Release readiness"; Bucket = $summary.releaseReadiness }
      )) {
        if ($pair.Bucket.required) {
          $required += $pair.Name
        }
      }
      if ($required.Count -gt 0) {
        Write-Host ("Workflow receipts likely need updates for: " + ($required -join ", ") + ".")
      }
    }
  }
} else {
  Write-Host "No package.json detected at $ProjectPath. Skipping app verification hint."
}
