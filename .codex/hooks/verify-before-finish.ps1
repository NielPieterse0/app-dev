param(
  [string]$ProjectPath = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script = Join-Path $root "scripts\verify-app.ps1"

if (-not (Test-Path $script)) {
  Write-Error "verify-app.ps1 not found: $script"
}

& $script -ProjectPath $ProjectPath
