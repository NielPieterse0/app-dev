param(
  [string]$ProjectPath = (Get-Location).Path,
  [switch]$AllowNoChecks,
  [switch]$SkipE2E,
  [switch]$JsonSummary
)

$ErrorActionPreference = "Stop"

function New-CheckResult {
  param(
    [Parameter(Mandatory=$true)][string]$Name,
    [Parameter(Mandatory=$true)][string]$Status,
    [Parameter(Mandatory=$true)][string]$Classification,
    [string]$Command = "",
    [int]$ExitCode = 0,
    [string]$Message = ""
  )

  return [ordered]@{
    name = $Name
    status = $Status
    classification = $Classification
    command = $Command
    exitCode = $ExitCode
    message = $Message
  }
}

function Write-SummaryAndFail {
  param(
    [Parameter(Mandatory=$true)][object]$Summary,
    [Parameter(Mandatory=$true)][string]$Message
  )

  if ($JsonSummary) {
    $Summary | ConvertTo-Json -Depth 6
  }
  Write-Error $Message
}

if (-not (Test-Path -LiteralPath $ProjectPath)) {
  Write-Error "Project path does not exist: $ProjectPath"
}

$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path
$packageJson = Join-Path $ProjectPath "package.json"
if (-not (Test-Path -LiteralPath $packageJson)) {
  Write-Error "No package.json found in $ProjectPath"
}

$package = Get-Content -LiteralPath $packageJson -Raw | ConvertFrom-Json
$scripts = $package.scripts
$hasDependencies = (
  ($null -ne $package.dependencies -and $package.dependencies.PSObject.Properties.Count -gt 0) -or
  ($null -ne $package.devDependencies -and $package.devDependencies.PSObject.Properties.Count -gt 0)
)

if (Test-Path -LiteralPath (Join-Path $ProjectPath "bun.lockb")) {
  $runner = "bun"
  $runnerArgs = @("run")
} elseif (Test-Path -LiteralPath (Join-Path $ProjectPath "pnpm-lock.yaml")) {
  $runner = "pnpm"
  $runnerArgs = @("run")
} elseif (Test-Path -LiteralPath (Join-Path $ProjectPath "yarn.lock")) {
  $runner = "yarn"
  $runnerArgs = @()
} else {
  $runner = "npm"
  $runnerArgs = @("run")
}

$checks = @("typecheck", "lint", "test", "build", "e2e")
$results = New-Object System.Collections.Generic.List[object]
$ran = New-Object System.Collections.Generic.List[string]
$skipped = New-Object System.Collections.Generic.List[string]
$failed = New-Object System.Collections.Generic.List[string]
$tempRoot = Join-Path $ProjectPath ".tmp/verify-app"

$summary = [ordered]@{
  projectPath = $ProjectPath
  runner = $runner
  ran = @()
  skipped = @()
  failed = @()
  checks = @()
}

if ($hasDependencies -and -not (Test-Path -LiteralPath (Join-Path $ProjectPath "node_modules"))) {
  $result = New-CheckResult -Name "dependencies" -Status "failed" -Classification "missing-dependencies" -Message "node_modules is missing. Install dependencies inside the project before verification."
  $results.Add($result) | Out-Null
  $failed.Add("dependencies") | Out-Null
  $summary.failed = $failed.ToArray()
  $summary.checks = $results.ToArray()
  Write-SummaryAndFail -Summary $summary -Message "Verification failed: node_modules is missing in $ProjectPath. Run the package manager install inside the project."
}

New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
$originalTemp = $env:TEMP
$originalTmp = $env:TMP
$originalTmpDir = $env:TMPDIR
$env:TEMP = $tempRoot
$env:TMP = $tempRoot
$env:TMPDIR = $tempRoot

try {
  foreach ($check in $checks) {
    if ($check -eq "e2e" -and $SkipE2E) {
      $skipped.Add($check) | Out-Null
      $results.Add((New-CheckResult -Name $check -Status "skipped" -Classification "disabled-script" -Message "E2E verification was disabled by SkipE2E.")) | Out-Null
      Write-Host "Skipping disabled script: $check"
      continue
    }

    if ($null -eq $scripts -or -not ($scripts.PSObject.Properties.Name -contains $check)) {
      $skipped.Add($check) | Out-Null
      $results.Add((New-CheckResult -Name $check -Status "skipped" -Classification "missing-script" -Message "package.json does not define script '$check'.")) | Out-Null
      Write-Host "Skipping missing script: $check"
      continue
    }

    $commandParts = @($runner) + $runnerArgs + @($check)
    $commandText = ($commandParts | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }) -join " "
    Write-Host "Running $commandText in $ProjectPath"
    Push-Location $ProjectPath
    try {
      & $runner @runnerArgs $check
      $exitCode = $LASTEXITCODE
    } finally {
      Pop-Location
    }

    if ($exitCode -ne 0) {
      $failed.Add($check) | Out-Null
      $results.Add((New-CheckResult -Name $check -Status "failed" -Classification "command-failure" -Command $commandText -ExitCode $exitCode -Message "$check failed with exit code $exitCode.")) | Out-Null
      $summary.ran = $ran.ToArray()
      $summary.skipped = $skipped.ToArray()
      $summary.failed = $failed.ToArray()
      $summary.checks = $results.ToArray()
      Write-SummaryAndFail -Summary $summary -Message "$check failed with exit code $exitCode"
    }

    $ran.Add($check) | Out-Null
    $results.Add((New-CheckResult -Name $check -Status "passed" -Classification "passed" -Command $commandText -ExitCode 0 -Message "$check passed.")) | Out-Null
  }

  $summary.ran = $ran.ToArray()
  $summary.skipped = $skipped.ToArray()
  $summary.failed = $failed.ToArray()
  $summary.checks = $results.ToArray()

  if (-not $AllowNoChecks -and $ran.Count -eq 0) {
    $results.Add((New-CheckResult -Name "verification" -Status "failed" -Classification "no-checks-ran" -Message "No verification scripts were available.")) | Out-Null
    $summary.checks = $results.ToArray()
    Write-SummaryAndFail -Summary $summary -Message "Verification failed: no checks ran for $ProjectPath"
  }

  if ($JsonSummary) {
    $summary | ConvertTo-Json -Depth 6
  }

  Write-Host ("Verification completed for {0}. Ran: {1}. Skipped: {2}." -f $ProjectPath, ($ran -join ", "), ($skipped -join ", "))
} finally {
  $env:TEMP = $originalTemp
  $env:TMP = $originalTmp
  $env:TMPDIR = $originalTmpDir
}
