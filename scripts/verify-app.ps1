param(
  [string]$ProjectPath = (Get-Location).Path,
  [bool]$RequireAnyCheck = $true,
  [bool]$IncludeE2E = $true,
  [bool]$JsonSummary = $false
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ProjectPath)) {
  Write-Error "Project path does not exist: $ProjectPath"
}

$packageJson = Join-Path $ProjectPath "package.json"
if (-not (Test-Path $packageJson)) {
  Write-Error "No package.json found in $ProjectPath"
}

$package = Get-Content $packageJson -Raw | ConvertFrom-Json
$scripts = $package.scripts

if (Test-Path (Join-Path $ProjectPath "pnpm-lock.yaml")) {
  $runner = "pnpm"
} elseif (Test-Path (Join-Path $ProjectPath "yarn.lock")) {
  $runner = "yarn"
} else {
  $runner = "npm"
}

$checks = @("typecheck", "lint", "test", "build", "e2e")
$ran = @()
$skipped = @()
$failed = @()

foreach ($check in $checks) {
  if ($check -eq "e2e" -and -not $IncludeE2E) {
    $skipped += $check
    Write-Host "Skipping disabled script: $check"
    continue
  }

  if ($null -ne $scripts -and $scripts.PSObject.Properties.Name -contains $check) {
    Write-Host "Running $runner run $check in $ProjectPath"
    Push-Location $ProjectPath
    try {
      & $runner run $check
      if ($LASTEXITCODE -ne 0) {
        $failed += $check
        Write-Error "$check failed with exit code $LASTEXITCODE"
      }
      $ran += $check
    } finally {
      Pop-Location
    }
  } else {
    $skipped += $check
    Write-Host "Skipping missing script: $check"
  }
}

$summary = [ordered]@{
  projectPath = (Resolve-Path $ProjectPath).Path
  runner = $runner
  ran = $ran
  skipped = $skipped
  failed = $failed
}

if ($RequireAnyCheck -and $ran.Count -eq 0) {
  if ($JsonSummary) {
    $summary | ConvertTo-Json -Depth 4
  }
  Write-Error "Verification failed: no checks ran for $ProjectPath"
}

if ($failed.Count -gt 0) {
  if ($JsonSummary) {
    $summary | ConvertTo-Json -Depth 4
  }
  Write-Error ("Verification failed checks: " + ($failed -join ", "))
}

if ($JsonSummary) {
  $summary | ConvertTo-Json -Depth 4
}

Write-Host ("Verification completed for {0}. Ran: {1}. Skipped: {2}." -f $ProjectPath, ($ran -join ", "), ($skipped -join ", "))
