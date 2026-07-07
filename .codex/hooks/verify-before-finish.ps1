param(
  [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script = Join-Path $root "scripts\verify-app.ps1"
$receiptScript = Join-Path $root "scripts\validate-workflow-receipts.ps1"

if (-not (Test-Path $script)) {
  Write-Error "verify-app.ps1 not found: $script"
}

if (-not (Test-Path $receiptScript)) {
  Write-Error "validate-workflow-receipts.ps1 not found: $receiptScript"
}

& $receiptScript -ProjectPath $ProjectPath -RequireVerificationEvidence:$true
& $script -ProjectPath $ProjectPath
