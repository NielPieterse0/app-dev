$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$lintScript = Join-Path $root "scripts/lint-portability.ps1"
$tmpRoot = Join-Path $root (".tmp/app-dev-lint-portability-" + [guid]::NewGuid().ToString("N"))

function Write-TextFile {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$Content
  )

  $directory = Split-Path -Parent $Path
  if (-not (Test-Path -LiteralPath $directory)) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
  }

  Set-Content -LiteralPath $Path -Encoding UTF8 -Value $Content
}

try {
  New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null

  $passDir = Join-Path $tmpRoot "pass"
  Write-TextFile -Path (Join-Path $passDir "sample.ps1") -Content @'
param(
  [switch]$SkipE2E
)

$ErrorActionPreference = "Stop"
$scriptPath = Join-Path $PSScriptRoot "scripts/common.ps1"
& git diff --name-only HEAD 2>$null
Write-Host $scriptPath
'@

  & $lintScript -Root $passDir -TargetPaths @(".") *> $null

  $failDir = Join-Path $tmpRoot "fail"
  Write-TextFile -Path (Join-Path $failDir "sample.ps1") -Content @'
param(
  [bool]$RequireAnyCheck,
  [switch]$IncludeE2E = $true
)

$ErrorActionPreference = "Stop"
& cmd.exe /d /c "git diff --name-only 2>nul"
$hook = "scripts\common.ps1"
$shell = Get-Command powershell
'@

  try {
    & $lintScript -Root $failDir -TargetPaths @(".") *> $null
    throw "Expected portability lint failure fixture to fail."
  } catch {
    if ($_.Exception.Message -like "Expected portability lint failure*") {
      throw
    }
  }

  Write-Host "Portability lint tests passed."
} finally {
  if (Test-Path -LiteralPath $tmpRoot) {
    Remove-Item -LiteralPath $tmpRoot -Recurse -Force
  }
}
