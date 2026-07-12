$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $root "standards/workspace-manifest.psd1"

if (-not (Test-Path -LiteralPath $manifestPath)) {
  Write-Error "Workspace manifest not found: $manifestPath"
}

$manifest = Import-PowerShellDataFile -Path $manifestPath

$required = @($manifest.CheckWorkspace.RequiredPaths)

$missing = @()
foreach ($item in $required) {
  $path = Join-Path $root $item
  if (-not (Test-Path $path)) {
    $missing += $item
  }
}

if ($missing.Count -gt 0) {
  Write-Error ("Missing required workspace files: " + ($missing -join ", "))
}

Write-Host "app-dev workspace check passed: $root"
