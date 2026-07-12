param(
  [string]$ManifestPath = "templates/react-vite-capacitor/template-parity.manifest.json"
)

$ErrorActionPreference = "Stop"
$workspaceRoot = Split-Path -Parent $PSScriptRoot
$manifestFullPath = Join-Path $workspaceRoot $ManifestPath

if (-not (Test-Path -LiteralPath $manifestFullPath)) {
  throw "Template parity manifest not found: $manifestFullPath"
}

$manifest = Get-Content -LiteralPath $manifestFullPath -Raw | ConvertFrom-Json -ErrorAction Stop
$failures = New-Object System.Collections.Generic.List[string]

foreach ($comparison in @($manifest.comparisons)) {
  $templatePath = Join-Path $workspaceRoot $comparison.template
  if (-not (Test-Path -LiteralPath $templatePath)) {
    $failures.Add("Template parity source is missing: $($comparison.template)") | Out-Null
    continue
  }

  $templateContent = (Get-Content -LiteralPath $templatePath -Raw) -replace "`r`n", "`n"

  foreach ($appPathRelative in @($comparison.apps)) {
    $appPath = Join-Path $workspaceRoot $appPathRelative
    if (-not (Test-Path -LiteralPath $appPath)) {
      $failures.Add("Template parity target is missing: $appPathRelative") | Out-Null
      continue
    }

    $appContent = (Get-Content -LiteralPath $appPath -Raw) -replace "`r`n", "`n"
    if ($templateContent -ne $appContent) {
      $failures.Add("Template parity drift: $($comparison.template) != $appPathRelative") | Out-Null
    }
  }
}

if ($failures.Count -gt 0) {
  Write-Error ("Template parity check failed:`n" + ($failures -join "`n"))
}

Write-Host "Template parity check passed."
