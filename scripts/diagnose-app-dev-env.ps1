<#
.SYNOPSIS
  Read-only environment diagnostic for the app-dev / Codex workspace.

.USAGE
  pwsh -NoProfile -ExecutionPolicy Bypass -File ./diagnose-app-dev-env.ps1

.NOTES
  - Does not install anything.
  - Does not print secrets or dump environment variables.
  - Safe to run from any folder; if run from the app-dev repo root, it also checks repo assets.
#>

[CmdletBinding()]
param(
  [string]$WorkspacePath = (Get-Location).Path,
  [switch]$RunRepoValidation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$rows = New-Object System.Collections.Generic.List[object]
$repoRows = New-Object System.Collections.Generic.List[object]
$notes = New-Object System.Collections.Generic.List[string]

function Add-Row {
  param(
    [string]$Category,
    [string]$Tool,
    [string]$Need,
    [string]$Status,
    [string]$Version = "",
    [string]$Path = "",
    [string]$Note = ""
  )
  $rows.Add([pscustomobject]@{
    Category = $Category
    Tool     = $Tool
    Need     = $Need
    Status   = $Status
    Version  = $Version
    Path     = $Path
    Note     = $Note
  }) | Out-Null
}

function Add-RepoRow {
  param(
    [string]$Path,
    [string]$Status,
    [string]$Note = ""
  )
  $repoRows.Add([pscustomobject]@{
    Path   = $Path
    Status = $Status
    Note   = $Note
  }) | Out-Null
}

function Get-CmdInfo {
  param([string]$Name)
  try {
    $cmd = Get-Command $Name -ErrorAction Stop
    return $cmd.Source
  } catch {
    return ""
  }
}

function Invoke-VersionCommand {
  param(
    [string]$Command,
    [string[]]$Arguments = @("--version"),
    [switch]$UseStdErr
  )
  try {
    $output = & $Command @Arguments 2>&1 | Select-Object -First 5
    $text = ($output | ForEach-Object { $_.ToString() }) -join " | "
    return $text.Trim()
  } catch {
    return "ERROR: $($_.Exception.Message)"
  }
}

function Parse-SemverMajor {
  param([string]$Text)
  if ($Text -match "(\d+)\.(\d+)\.(\d+)") { return [int]$Matches[1] }
  if ($Text -match "v(\d+)\.(\d+)\.(\d+)") { return [int]$Matches[1] }
  return $null
}

function Test-CommandTool {
  param(
    [string]$Category,
    [string]$Tool,
    [string]$Command,
    [string]$Need,
    [string[]]$VersionArgs = @("--version"),
    [int]$MinimumMajor = 0,
    [string]$MissingNote = "",
    [string]$FoundNote = ""
  )
  $path = Get-CmdInfo $Command
  if (-not $path) {
    Add-Row -Category $Category -Tool $Tool -Need $Need -Status "MISSING" -Note $MissingNote
    return
  }

  $version = Invoke-VersionCommand -Command $Command -Arguments $VersionArgs
  $status = "OK"
  $note = $FoundNote

  if ($MinimumMajor -gt 0) {
    $major = Parse-SemverMajor $version
    if ($null -eq $major) {
      $status = "CHECK"
      $note = "Could not parse major version. $note".Trim()
    } elseif ($major -lt $MinimumMajor) {
      $status = "OLD"
      $note = "Expected major version >= $MinimumMajor. $note".Trim()
    }
  }

  Add-Row -Category $Category -Tool $Tool -Need $Need -Status $status -Version $version -Path $path -Note $note
}

function Test-PathTool {
  param(
    [string]$Category,
    [string]$Tool,
    [string]$Need,
    [string[]]$CandidatePaths,
    [string]$MissingNote = "",
    [string]$FoundNote = ""
  )
  foreach ($candidate in $CandidatePaths) {
    if ($candidate -and (Test-Path $candidate)) {
      Add-Row -Category $Category -Tool $Tool -Need $Need -Status "OK" -Path $candidate -Note $FoundNote
      return
    }
  }
  Add-Row -Category $Category -Tool $Tool -Need $Need -Status "MISSING" -Note $MissingNote
}

function Format-MarkdownTable {
  param([object[]]$Items, [string[]]$Columns)
  if (-not $Items -or $Items.Count -eq 0) { return "_No rows._" }
  $header = "| " + ($Columns -join " | ") + " |"
  $sep = "| " + (($Columns | ForEach-Object { "---" }) -join " | ") + " |"
  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add($header) | Out-Null
  $lines.Add($sep) | Out-Null
  foreach ($item in $Items) {
    $vals = foreach ($col in $Columns) {
      $value = [string]$item.$col
      $value = $value -replace "\r?\n", " "
      $value = $value -replace "\|", "/"
      if ($value.Length -gt 160) { $value = $value.Substring(0,157) + "..." }
      $value
    }
    $lines.Add("| " + ($vals -join " | ") + " |") | Out-Null
  }
  return ($lines -join [Environment]::NewLine)
}

# Host / OS
$osCaption = ""
try {
  $osCaption = (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop).Caption
} catch {
  $osCaption = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
}
$arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
Add-Row -Category "Host" -Tool "Operating system" -Need "Required" -Status "OK" -Version "$osCaption / $arch" -Path $env:COMPUTERNAME -Note "Windows is the expected laptop target for this workspace."

$psVersion = $PSVersionTable.PSVersion.ToString()
$psStatus = if ($PSVersionTable.PSVersion.Major -ge 7) { "OK" } else { "OLD" }
$psPath = (Get-Process -Id $PID).Path
Add-Row -Category "Core" -Tool "PowerShell 7+" -Need "Required" -Status $psStatus -Version $psVersion -Path $psPath -Note "PowerShell 7+ is required for the repo scripts."

# Required core tools
Test-CommandTool -Category "Core" -Tool "Git" -Command "git" -Need "Required" -VersionArgs @("--version") -MissingNote "Install Git for Windows."
Test-CommandTool -Category "Core" -Tool "Node.js LTS" -Command "node" -Need "Required" -VersionArgs @("--version") -MinimumMajor 20 -MissingNote "Install current Node.js LTS. Prefer 20+ for these templates."
Test-CommandTool -Category "Core" -Tool "npm" -Command "npm" -Need "Required" -VersionArgs @("--version") -MinimumMajor 10 -MissingNote "npm normally installs with Node.js."
Test-CommandTool -Category "Core" -Tool "npx" -Command "npx" -Need "Required" -VersionArgs @("--version") -MinimumMajor 10 -MissingNote "npx normally installs with npm."

# Python: validate-codex-assets.ps1 can use Python 3.11+ for strict TOML validation.
$pythonCandidates = @(
  @{ Name = "Python launcher 3.11+"; Command = "py"; Args = @("-3.11", "--version") },
  @{ Name = "Python"; Command = "python"; Args = @("--version") },
  @{ Name = "Python 3"; Command = "python3"; Args = @("--version") }
)
$pythonFound = $false
foreach ($candidate in $pythonCandidates) {
  $path = Get-CmdInfo $candidate.Command
  if ($path) {
    $version = Invoke-VersionCommand -Command $candidate.Command -Arguments $candidate.Args
    $major = $null
    $minor = $null
    if ($version -match "(\d+)\.(\d+)\.(\d+)") { $major = [int]$Matches[1]; $minor = [int]$Matches[2] }
    $status = "CHECK"
    $note = "Used for strict TOML validation."
    if (($major -gt 3) -or ($major -eq 3 -and $minor -ge 11)) { $status = "OK"; $pythonFound = $true }
    elseif ($major -eq 3) { $status = "OLD"; $note = "Python 3.11+ preferred for tomllib. $note" }
    Add-Row -Category "Core" -Tool $candidate.Name -Need "Required for strict validation" -Status $status -Version $version -Path $path -Note $note
  }
}
if (-not $pythonFound) {
  Add-Row -Category "Core" -Tool "Python 3.11+" -Need "Required for strict validation" -Status "MISSING" -Note "Install Python 3.11+ or run validation without strict TOML mode."
}

# Codex / OpenAI-specific
Test-CommandTool -Category "Codex" -Tool "Codex CLI" -Command "codex" -Need "Required when using local Codex config/hooks/rules" -VersionArgs @("--version") -MissingNote "Install/configure Codex CLI or use Codex desktop/app if that is your workflow."

# Editors / repo workflow
Test-CommandTool -Category "Workflow" -Tool "VS Code CLI" -Command "code" -Need "Recommended" -VersionArgs @("--version") -MissingNote "Install VS Code and enable 'code' in PATH if you use VS Code."
Test-CommandTool -Category "Workflow" -Tool "GitHub CLI" -Command "gh" -Need "Optional" -VersionArgs @("--version") -MissingNote "Only needed for GitHub PR/issue workflows from terminal."

# Package manager alternatives
Test-CommandTool -Category "Package managers" -Tool "pnpm" -Command "pnpm" -Need "Optional" -VersionArgs @("--version") -MissingNote "Only needed if a project has pnpm-lock.yaml."
Test-CommandTool -Category "Package managers" -Tool "Yarn" -Command "yarn" -Need "Optional" -VersionArgs @("--version") -MissingNote "Only needed if a project has yarn.lock."

# Browser / e2e
Test-CommandTool -Category "Testing" -Tool "Playwright CLI" -Command "playwright" -Need "Optional / e2e" -VersionArgs @("--version") -MissingNote "Project-local Playwright is usually installed by npm install; browsers require 'npx playwright install'."
$pwBrowsers = Join-Path $env:LOCALAPPDATA "ms-playwright"
if (Test-Path $pwBrowsers) {
  Add-Row -Category "Testing" -Tool "Playwright browsers" -Need "Optional / e2e" -Status "OK" -Path $pwBrowsers -Note "Browser binaries appear to be installed."
} else {
  Add-Row -Category "Testing" -Tool "Playwright browsers" -Need "Optional / e2e" -Status "MISSING" -Note "Run inside an app after npm install: npx playwright install"
}

# Android / mobile validation
$androidHome = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } elseif ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { "" }
if ($androidHome -and (Test-Path $androidHome)) {
  Add-Row -Category "Mobile" -Tool "Android SDK env" -Need "Optional / Android" -Status "OK" -Path $androidHome -Note "ANDROID_HOME or ANDROID_SDK_ROOT is set."
} else {
  Add-Row -Category "Mobile" -Tool "Android SDK env" -Need "Optional / Android" -Status "MISSING" -Note "Needed for Capacitor/Expo Android emulator/device validation."
}
Test-PathTool -Category "Mobile" -Tool "Android Studio" -Need "Optional / Android" -CandidatePaths @(
  (Join-Path $env:ProgramFiles "Android/Android Studio/bin/studio64.exe"),
  (Join-Path ${env:ProgramFiles(x86)} "Android/Android Studio/bin/studio64.exe"),
  (Join-Path $env:LOCALAPPDATA "Programs/Android Studio/bin/studio64.exe")
) -MissingNote "Needed for Android emulator and SDK management."
Test-CommandTool -Category "Mobile" -Tool "Java / JDK" -Command "java" -Need "Optional / Android" -VersionArgs @("-version") -MissingNote "Needed for Android builds. Install JDK through Android Studio or separately."
Test-CommandTool -Category "Mobile" -Tool "ADB" -Command "adb" -Need "Optional / Android" -VersionArgs @("version") -MissingNote "Install Android SDK Platform Tools and add to PATH."
Test-CommandTool -Category "Mobile" -Tool "Android emulator" -Command "emulator" -Need "Optional / Android" -VersionArgs @("-version") -MissingNote "Install Android Emulator through Android Studio SDK Manager and add to PATH."

# Expo / deployment optional CLIs
Test-CommandTool -Category "Mobile" -Tool "Expo CLI" -Command "expo" -Need "Optional / Expo" -VersionArgs @("--version") -MissingNote "Usually use via 'npx expo'. Global install is optional."
Test-CommandTool -Category "Mobile" -Tool "EAS CLI" -Command "eas" -Need "Optional / Expo builds" -VersionArgs @("--version") -MissingNote "Only needed for EAS cloud builds/submission."
Test-CommandTool -Category "Deploy" -Tool "Vercel CLI" -Command "vercel" -Need "Optional / Next.js deploy" -VersionArgs @("--version") -MissingNote "Only needed if deploying Next.js to Vercel from terminal."
Test-CommandTool -Category "Data" -Tool "Supabase CLI" -Command "supabase" -Need "Optional / Supabase" -VersionArgs @("--version") -MissingNote "Only needed when using Supabase migrations/local dev."

# Xcode note
if ($IsMacOS) {
  Test-CommandTool -Category "Mobile" -Tool "Xcode tools" -Command "xcodebuild" -Need "Optional / iOS" -VersionArgs @("-version") -MissingNote "Needed for iOS simulator/build validation on macOS."
} else {
  Add-Row -Category "Mobile" -Tool "Xcode tools" -Need "Optional / iOS" -Status "N/A" -Note "iOS simulator/build validation requires macOS; not applicable on Windows."
}

# Repo asset checks if the workspace is present.
$root = Resolve-Path -LiteralPath $WorkspacePath -ErrorAction SilentlyContinue
if ($root) {
  $rootPath = $root.Path
  $expectedPaths = @(
    "AGENTS.md",
    "PLANS.md",
    ".codex/config.toml",
    ".codex/rules/default.rules",
    ".codex/hooks/pre-command.ps1",
    ".agents/skills/cross-platform-app-workflow/SKILL.md",
    "scripts/check-workspace.ps1",
    "scripts/validate-codex-assets.ps1",
    "scripts/test-hooks.ps1",
    "scripts/test-workspace.ps1",
    "templates/react-vite-capacitor/package.json",
    "templates/next-web-app/package.json",
    "templates/expo-native-app/package.json",
    ".github/workflows/app-dev-validation.yml"
  )
  foreach ($rel in $expectedPaths) {
    $full = Join-Path $rootPath $rel
    if (Test-Path $full) { Add-RepoRow -Path $rel -Status "OK" } else { Add-RepoRow -Path $rel -Status "MISSING" -Note "Only relevant if this path is the app-dev repo root." }
  }

  if ($RunRepoValidation) {
    $validator = Join-Path $rootPath "scripts/validate-codex-assets.ps1"
    if (Test-Path $validator) {
      try {
        $validationOutput = & pwsh -NoProfile -ExecutionPolicy Bypass -File $validator -RequirePythonToml:$false 2>&1
        $notes.Add("Repo validation output: " + (($validationOutput | ForEach-Object { $_.ToString() }) -join " | ")) | Out-Null
      } catch {
        $notes.Add("Repo validation failed: $($_.Exception.Message)") | Out-Null
      }
    } else {
      $notes.Add("Repo validation skipped: scripts/validate-codex-assets.ps1 not found under WorkspacePath.") | Out-Null
    }
  }
}

$missingRequired = @($rows | Where-Object { $_.Need -match "Required" -and $_.Status -in @("MISSING", "OLD") })
$warnings = @($rows | Where-Object { $_.Status -in @("MISSING", "OLD", "CHECK") -and $_.Need -notmatch "Optional" -and $_.Need -ne "Recommended" })

Write-Output "# app-dev laptop dependency diagnostic"
Write-Output ""
Write-Output "Generated: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz'))"
Write-Output "WorkspacePath checked: $WorkspacePath"
Write-Output ""
Write-Output "## Summary"
Write-Output ""
Write-Output "Required missing/old count: $($missingRequired.Count)"
Write-Output "Non-optional warnings/checks count: $($warnings.Count)"
Write-Output ""
Write-Output "## Tool checks"
Write-Output ""
Write-Output (Format-MarkdownTable -Items ($rows.ToArray()) -Columns @("Category", "Tool", "Need", "Status", "Version", "Path", "Note"))
Write-Output ""
Write-Output "## Repo asset checks"
Write-Output ""
Write-Output (Format-MarkdownTable -Items ($repoRows.ToArray()) -Columns @("Path", "Status", "Note"))
Write-Output ""
if ($notes.Count -gt 0) {
  Write-Output "## Notes"
  foreach ($note in $notes) { Write-Output "- $note" }
  Write-Output ""
}
Write-Output "## Install priority"
Write-Output ""
Write-Output "1. Required core: PowerShell 7+, Git, Node.js LTS with npm/npx, Python 3.11+."
Write-Output "2. Codex: Codex CLI/app if you want local .codex config, hooks, rules, and AGENTS.md behavior."
Write-Output "3. E2E testing: Playwright browsers after project npm install: npx playwright install."
Write-Output "4. Android validation: Android Studio + SDK + Java/JDK + adb/emulator only when building/testing Android."
Write-Output "5. Optional CLIs: pnpm/yarn, GitHub CLI, Expo/EAS, Vercel, Supabase only when the specific project requires them."
