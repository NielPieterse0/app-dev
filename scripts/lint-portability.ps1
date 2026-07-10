param(
  [string]$Root = (Split-Path -Parent $PSScriptRoot),
  [string[]]$TargetPaths = @("scripts", ".codex/hooks"),
  [switch]$JsonSummary
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path -LiteralPath $Root).Path
$failures = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$ignoredRelativePaths = @(
  "scripts/lint-portability.ps1",
  "scripts/test-lint-portability.ps1"
)

$rules = @(
  @{ Name = "cmd.exe shell wrapper"; Pattern = '(?i)\bcmd\.exe\b'; Message = "Use direct native invocation instead of cmd.exe." },
  @{ Name = "nul stderr suppression"; Pattern = '(?i)2>\s*nul\b'; Message = "Suppress stderr with 2>`$null, never 2>nul." },
  @{ Name = "Windows PowerShell binary"; Pattern = '(?i)(Get-Command\s+powershell\b|\bpowershell(?:\.exe)?\s+-)'; Message = "Use pwsh, never the Windows-only powershell binary name." },
  @{ Name = "slash inversion"; Pattern = '\.Replace\(\s*"/"\s*,\s*"\\"\s*\)'; Message = "Do not rewrite forward slashes into backslashes." },
  @{ Name = "path-like backslashes"; Pattern = '["''](?:[A-Za-z]:\\[^"'']+|[^"'']*(?:scripts|projects|templates|\.codex|\.agents|android|ios)\\[^"'']+|[^"'']*\\[^"'']*\.(?:ps1|md|json|ya?ml|toml|tsx?|jsx?|mjs|cjs|sql|txt|exe))["'']'; Message = "Use forward slashes in path literals." },
  @{ Name = "bool param"; Pattern = '^\s*\[bool\]\$'; Message = "Use [switch] for boolean intent in param blocks." },
  @{ Name = "switch default true"; Pattern = '^\s*\[switch\]\$[A-Za-z0-9_]+\s*=\s*\$true\b'; Message = "Switches must not default to `$true; rename to an opt-out switch." }
)

function Get-RelativePath {
  param([Parameter(Mandatory=$true)][string]$Path)

  $rootWithSeparator = $Root
  if (-not $rootWithSeparator.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $rootWithSeparator += [System.IO.Path]::DirectorySeparatorChar
  }

  $rootUri = New-Object System.Uri($rootWithSeparator)
  $pathUri = New-Object System.Uri($Path)
  return ([System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()) -replace "\\", "/")
}

function Test-IgnoredPath {
  param([Parameter(Mandatory=$true)][string]$RelativePath)

  return $RelativePath -in $ignoredRelativePaths
}

function Get-TargetFiles {
  $files = New-Object System.Collections.Generic.List[System.IO.FileInfo]

  foreach ($targetPath in $TargetPaths) {
    $fullTargetPath = if ([System.IO.Path]::IsPathRooted($targetPath)) {
      $targetPath
    } else {
      Join-Path $Root $targetPath
    }

    if (-not (Test-Path -LiteralPath $fullTargetPath)) {
      $warnings.Add("Skipped missing portability target: $targetPath") | Out-Null
      continue
    }

    $item = Get-Item -LiteralPath $fullTargetPath
    if (-not $item.PSIsContainer) {
      $files.Add($item) | Out-Null
      continue
    }

    foreach ($file in Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Filter "*.ps1") {
      $files.Add($file) | Out-Null
    }
  }

  return @($files | Sort-Object FullName -Unique)
}

foreach ($file in Get-TargetFiles) {
  $relativePath = Get-RelativePath -Path $file.FullName
  if (Test-IgnoredPath -RelativePath $relativePath) {
    continue
  }

  $lines = Get-Content -LiteralPath $file.FullName
  for ($index = 0; $index -lt $lines.Count; $index++) {
    $line = [string]$lines[$index]
    $lineNumber = $index + 1

    foreach ($rule in $rules) {
      if ($rule.Name -eq "path-like backslashes" -and $line -match '(?i)(\[regex\]::|-match|-replace|Pattern\s*=|Regex\s*=)') {
        continue
      }

      if ($line -match $rule.Pattern) {
        $failures.Add(("{0}:{1} [{2}] {3}" -f $relativePath, $lineNumber, $rule.Name, $rule.Message)) | Out-Null
      }
    }
  }
}

$summary = [ordered]@{
  root = $Root
  failures = @($failures)
  warnings = @($warnings)
  failureCount = $failures.Count
  warningCount = $warnings.Count
}

if ($JsonSummary) {
  $summary | ConvertTo-Json -Depth 6
}

foreach ($warning in $warnings) {
  Write-Warning $warning
}

if ($failures.Count -gt 0) {
  Write-Error ("Portability lint failed:`n" + ($failures -join "`n"))
}

Write-Host "Portability lint passed. Warnings: $($warnings.Count)."
