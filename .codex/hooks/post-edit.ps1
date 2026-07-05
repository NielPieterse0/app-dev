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
} else {
  Write-Host "No package.json detected at $ProjectPath. Skipping app verification hint."
}
