param(
  [string]$Root = (Split-Path -Parent $PSScriptRoot),
  [bool]$JsonSummary = $false
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path -LiteralPath $Root).Path
$findings = New-Object System.Collections.Generic.List[object]
$warnings = New-Object System.Collections.Generic.List[string]

$excludedDirectoryNames = @(".git", "node_modules", "dist", "build", ".next", "out", "coverage", "playwright-report", "test-results")
$excludedRelativePrefixes = @("projects/")
$allowedFileNames = @(".env.example")
$textExtensions = @(".md", ".txt", ".json", ".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs", ".yml", ".yaml", ".toml", ".ps1", ".css", ".html", ".config", ".example")
$patterns = @(
  @{ Name = "OpenAI API key"; Regex = "sk-[A-Za-z0-9_-]{20,}" },
  @{ Name = "GitHub token"; Regex = "gh[pousr]_[A-Za-z0-9_]{20,}" },
  @{ Name = "Supabase service role JWT"; Regex = "eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}" },
  @{ Name = "Private key block"; Regex = "-----BEGIN (RSA |OPENSSH |EC |DSA |PRIVATE )?PRIVATE KEY-----" },
  @{ Name = "AWS access key"; Regex = "AKIA[0-9A-Z]{16}" },
  @{ Name = "Secret assignment"; Regex = "(?i)(api[_-]?key|secret|token|password)\s*[:=]\s*['""][^'""]{12,}['""]" }
)

function Get-RelativePath {
  param([Parameter(Mandatory=$true)][string]$Path)
  $rootWithSeparator = $Root
  if (-not $rootWithSeparator.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $rootWithSeparator += [System.IO.Path]::DirectorySeparatorChar
  }
  $rootUri = New-Object System.Uri($rootWithSeparator)
  $pathUri = New-Object System.Uri($Path)
  $relative = [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString())
  return ($relative -replace "\\", "/")
}

function Test-IsExcludedPath {
  param([Parameter(Mandatory=$true)][System.IO.FileInfo]$File)

  $relative = Get-RelativePath -Path $File.FullName
  foreach ($prefix in $excludedRelativePrefixes) {
    if ($relative.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
      return $true
    }
  }

  if ($allowedFileNames -contains $File.Name) {
    return $true
  }

  $directory = $File.Directory
  while ($null -ne $directory) {
    if ($excludedDirectoryNames -contains $directory.Name) {
      return $true
    }
    if ($directory.FullName -eq $Root) {
      break
    }
    $directory = $directory.Parent
  }

  return $false
}

function Test-IsTextFile {
  param([Parameter(Mandatory=$true)][System.IO.FileInfo]$File)
  if ($textExtensions -contains $File.Extension) {
    return $true
  }
  if ([string]::IsNullOrWhiteSpace($File.Extension)) {
    return $true
  }
  return $false
}

$gitleaks = Get-Command gitleaks -ErrorAction SilentlyContinue
if ($null -ne $gitleaks) {
  Push-Location $Root
  try {
    & $gitleaks.Source detect --no-git --redact --source $Root
    if ($LASTEXITCODE -ne 0) {
      $findings.Add([ordered]@{
        file = "."
        line = 0
        type = "gitleaks"
        value = "gitleaks reported one or more findings"
      }) | Out-Null
    }
  } finally {
    Pop-Location
  }
} else {
  $warnings.Add("gitleaks not found; using local regex fallback scan.") | Out-Null
}

$files = Get-ChildItem -LiteralPath $Root -Recurse -File -Force | Where-Object {
  -not (Test-IsExcludedPath -File $_) -and (Test-IsTextFile -File $_)
}

foreach ($file in $files) {
  $lines = Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue
  for ($i = 0; $i -lt $lines.Count; $i++) {
    foreach ($pattern in $patterns) {
      if ($lines[$i] -match $pattern.Regex) {
        $findings.Add([ordered]@{
          file = Get-RelativePath -Path $file.FullName
          line = $i + 1
          type = $pattern.Name
          value = "redacted"
        }) | Out-Null
      }
    }
  }
}

$findingArray = $findings.ToArray()
$warningArray = $warnings.ToArray()

$summary = [ordered]@{
  root = $Root
  findings = $findingArray
  warnings = $warningArray
  findingCount = $findings.Count
  warningCount = $warnings.Count
}

if ($JsonSummary) {
  $summary | ConvertTo-Json -Depth 6
}

foreach ($warning in $warnings) {
  Write-Warning $warning
}

if ($findings.Count -gt 0) {
  $messages = $findings | ForEach-Object { "$($_.file):$($_.line) $($_.type)" }
  Write-Error ("Secret scan failed:`n" + ($messages -join "`n"))
}

Write-Host "Secret scan passed. Warnings: $($warnings.Count)."
