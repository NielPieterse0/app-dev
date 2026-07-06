param(
  [string]$Root = (Split-Path -Parent $PSScriptRoot),
  [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path -LiteralPath $Root).Path

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
  $OutputPath = Join-Path $Root "dist/app-dev-workspace.zip"
}

$outputFullPath = [System.IO.Path]::GetFullPath($OutputPath)
$outputDirectory = Split-Path -Parent $outputFullPath
if (-not (Test-Path -LiteralPath $outputDirectory)) {
  New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
}

$stageRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("app-dev-export-" + [System.Guid]::NewGuid().ToString("N"))
$stageApp = Join-Path $stageRoot "app-dev"
$excludedDirectoryNames = @(".git", "node_modules", ".pnpm-store", "dist", "build", ".next", "out", "coverage", "playwright-report", "test-results")
$excludedRelativePrefixes = @("projects/")
$excludedFilePatterns = @("*.log", "npm-debug.log*", "yarn-debug.log*", "yarn-error.log*", "pnpm-debug.log*")

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

function Test-IsExcluded {
  param([Parameter(Mandatory=$true)][System.IO.FileSystemInfo]$Item)

  $relative = Get-RelativePath -Path $Item.FullName
  foreach ($prefix in $excludedRelativePrefixes) {
    if ($relative.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase) -and $relative -ne "projects/.gitkeep") {
      return $true
    }
  }

  foreach ($name in $excludedDirectoryNames) {
    if ($Item.PSIsContainer -and $Item.Name -eq $name) {
      return $true
    }
  }

  if (-not $Item.PSIsContainer) {
    foreach ($pattern in $excludedFilePatterns) {
      if ($Item.Name -like $pattern) {
        return $true
      }
    }
  }

  return $false
}

try {
  New-Item -ItemType Directory -Force -Path $stageApp | Out-Null

  $items = Get-ChildItem -LiteralPath $Root -Force
  foreach ($item in $items) {
    if (Test-IsExcluded -Item $item) {
      continue
    }
    Copy-Item -LiteralPath $item.FullName -Destination $stageApp -Recurse -Force
  }

  Get-ChildItem -LiteralPath $stageApp -Recurse -Force | Where-Object { Test-IsExcluded -Item $_ } | Sort-Object FullName -Descending | ForEach-Object {
    Remove-Item -LiteralPath $_.FullName -Recurse -Force
  }

  if (Test-Path -LiteralPath $outputFullPath) {
    Remove-Item -LiteralPath $outputFullPath -Force
  }

  Compress-Archive -LiteralPath $stageApp -DestinationPath $outputFullPath -Force
  Write-Host "Exported app-dev workspace to $outputFullPath"
} finally {
  if (Test-Path -LiteralPath $stageRoot) {
    Remove-Item -LiteralPath $stageRoot -Recurse -Force
  }
}
