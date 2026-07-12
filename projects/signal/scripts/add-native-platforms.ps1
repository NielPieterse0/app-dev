param(
  [string]$ProjectPath = (Get-Location).Path,
  [switch]$SkipIos
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ProjectPath)) {
  Write-Error "Project path does not exist: $ProjectPath"
}

$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path

foreach ($required in @("package.json", "capacitor.config.ts")) {
  if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath $required))) {
    Write-Error "This script must run inside a generated React/Vite/Capacitor app. Missing: $required"
  }
}

Push-Location $ProjectPath
try {
  & npm install @capacitor/android @capacitor/ios
  if ($LASTEXITCODE -ne 0) {
    Write-Error "npm install for native Capacitor packages failed with exit code $LASTEXITCODE"
  }

  & npm run build
  if ($LASTEXITCODE -ne 0) {
    Write-Error "npm run build failed with exit code $LASTEXITCODE"
  }

  if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath "android"))) {
    & npx cap add android
    if ($LASTEXITCODE -ne 0) {
      Write-Error "npx cap add android failed with exit code $LASTEXITCODE"
    }
  }

  if (-not $SkipIos -and -not (Test-Path -LiteralPath (Join-Path $ProjectPath "ios"))) {
    & npx cap add ios
    if ($LASTEXITCODE -ne 0) {
      Write-Error "npx cap add ios failed with exit code $LASTEXITCODE"
    }
  }

  & npx cap sync
  if ($LASTEXITCODE -ne 0) {
    Write-Error "npx cap sync failed with exit code $LASTEXITCODE"
  }
} finally {
  Pop-Location
}

Write-Host "Native platform setup completed for $ProjectPath"
