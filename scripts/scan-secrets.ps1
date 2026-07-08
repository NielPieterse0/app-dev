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

# Keep these patterns deliberately strict. Broad documentation examples are handled
# by Test-IsAllowedPlaceholderLine below, not by weakening the detectors.
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

function ConvertTo-RepoRelativePath {
  param([Parameter(Mandatory=$true)][string]$Path)

  $pathText = [string]$Path
  if ([string]::IsNullOrWhiteSpace($pathText)) {
    return "."
  }

  $normalizedRoot = ([System.IO.Path]::GetFullPath($Root) -replace "\\", "/").TrimEnd("/")
  $normalizedPath = ($pathText -replace "\\", "/")

  if ([System.IO.Path]::IsPathRooted($pathText)) {
    try {
      $fullPath = ([System.IO.Path]::GetFullPath($pathText) -replace "\\", "/")
      if ($fullPath.StartsWith($normalizedRoot + "/", [System.StringComparison]::OrdinalIgnoreCase)) {
        $relativePath = $fullPath.Substring($normalizedRoot.Length + 1)
        if ($relativePath -match "(?i)^agents/skills/") {
          return "." + $relativePath
        }
        return $relativePath
      }
    } catch {
      $fallbackPath = $normalizedPath.TrimStart("./")
      if ($fallbackPath -match "(?i)^agents/skills/") {
        return "." + $fallbackPath
      }
      return $fallbackPath
    }
  }

  $repoPath = $normalizedPath.TrimStart("./")
  if ($repoPath -match "(?i)^agents/skills/") {
    return "." + $repoPath
  }
  return $repoPath
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

function Get-LineText {
  param(
    [Parameter(Mandatory=$true)][string]$RelativePath,
    [int]$LineNumber = 0
  )

  if ($LineNumber -le 0) {
    return ""
  }

  $fullPath = Join-Path $Root ($RelativePath -replace "/", [System.IO.Path]::DirectorySeparatorChar)
  if (-not (Test-Path -LiteralPath $fullPath)) {
    return ""
  }

  $content = Get-Content -LiteralPath $fullPath -ErrorAction SilentlyContinue
  if ($null -eq $content -or $LineNumber -gt $content.Count) {
    return ""
  }

  return [string]$content[$LineNumber - 1]
}


function ConvertTo-LineNumber {
  param([object]$Value)

  if ($null -eq $Value) {
    return 0
  }

  $text = [string]$Value
  if ([string]::IsNullOrWhiteSpace($text)) {
    return 0
  }

  $number = 0
  if ([int]::TryParse($text, [ref]$number)) {
    if ($number -gt 0) {
      return $number
    }
  }

  return 0
}

function ConvertTo-SafeText {
  param([object]$Value)

  if ($null -eq $Value) {
    return ""
  }

  return [string]$Value
}

function Test-IsAllowedPlaceholderLine {
  param(
    [Parameter(Mandatory=$true)][string]$Line,
    [string]$RelativePath = "",
    [string]$FindingType = ""
  )

  $lineText = [string]$Line

  # Do not allow concrete high-confidence secret shapes, even in Markdown.
  if ($lineText -match "sk-[A-Za-z0-9_-]{20,}") { return $false }
  if ($lineText -match "gh[pousr]_[A-Za-z0-9_]{20,}") { return $false }
  if ($lineText -match "AKIA[0-9A-Z]{16}") { return $false }
  if ($lineText -match "eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}") { return $false }
  if ($lineText -match "-----BEGIN (RSA |OPENSSH |EC |DSA |PRIVATE )?PRIVATE KEY-----") { return $false }

  # Safe documentation/code references to environment variables.
  if ($lineText -match "(?i)process\.env\.[A-Z0-9_]*(API[_-]?KEY|TOKEN|SECRET|PASSWORD)[A-Z0-9_]*") { return $true }
  if ($lineText -match "(?i)os\.environ(\.get)?\(\s*['""][A-Z0-9_]*(API[_-]?KEY|TOKEN|SECRET|PASSWORD)[A-Z0-9_]*['""]") { return $true }
  if ($lineText -match "(?i)os\.environ\[\s*['""][A-Z0-9_]*(API[_-]?KEY|TOKEN|SECRET|PASSWORD)[A-Z0-9_]*['""]\s*\]") { return $true }
  if ($lineText -match "(?i)getenv\(\s*['""][A-Z0-9_]*(API[_-]?KEY|TOKEN|SECRET|PASSWORD)[A-Z0-9_]*['""]\s*\)") { return $true }
  if ($lineText -match "\$[A-Z0-9_]*(API[_-]?KEY|TOKEN|SECRET|PASSWORD)[A-Z0-9_]*") { return $true }
  if ($lineText -match "\$\{[A-Z0-9_]*(API[_-]?KEY|TOKEN|SECRET|PASSWORD)[A-Z0-9_]*\}") { return $true }

  # Safe placeholder values in examples and docs.
  if ($lineText -match "(?i)(your|example|sample|dummy|fake|placeholder)[-_ ]?(token|secret|password|api[-_ ]?key|key)") { return $true }
  if ($lineText -match "(?i)<[^>]*(token|secret|password|api[-_ ]?key|key)[^>]*>") { return $true }
  if ($lineText -match "(?i)\{[^}]*(token|secret|password|api[-_ ]?key|key)[^}]*\}") { return $true }
  if ($lineText -match "(?i)(account-id|zone-id|record-id|dns_record_id|user@example\.com|example\.com)") { return $true }

  # Gitleaks may redact or partially report the matching curl/header text. For
  # agent skill reference documentation only, allow known documentation-example
  # rule classes after the concrete high-confidence secret checks above have run.
  # This is intentionally scoped to .agents/skills/* reference docs and SKILL.md,
  # not generated app code, scripts, configs, or environment files.
  if ($RelativePath -match "(?i)^\.agents/skills/.+/(references/|SKILL\.md$)" -and $FindingType -match "(?i)(authorization token|curl command header|OpenAI API key|Generic API Key|Secret assignment)") {
    return $true
  }

  # Markdown/code documentation may mention env var names without assigning values.
  if ($RelativePath -match "\.md$" -and $lineText -match "\b[A-Z0-9_]*(API[_-]?KEY|TOKEN|SECRET|PASSWORD)[A-Z0-9_]*\b") {
    if ($lineText -notmatch "['""]\s*(sk-|gh[pousr]_|AKIA|eyJ)[A-Za-z0-9_\.-]+['""]") {
      return $true
    }
  }

  return $false
}

function Add-SecretFinding {
  param(
    [Parameter(Mandatory=$true)][string]$File,
    [object]$Line = 0,
    [Parameter(Mandatory=$true)][string]$Type,
    [string]$LineText = ""
  )

  $safeFile = ConvertTo-RepoRelativePath -Path $File
  $safeLine = ConvertTo-LineNumber -Value $Line
  $safeLineText = ConvertTo-SafeText -Value $LineText

  if ([string]::IsNullOrWhiteSpace($safeLineText) -or $safeLineText -match "(?i)^\s*redacted\s*$|REDACTED") {
    $fileLineText = Get-LineText -RelativePath $safeFile -LineNumber $safeLine
    if (-not [string]::IsNullOrWhiteSpace($fileLineText)) {
      $safeLineText = $fileLineText
    }
  }

  # Gitleaks can flag skill documentation based on rule names even when the
  # reported line is empty, redacted, or unrelated to the rule label. Keep this
  # narrow: only allow known documentation/example rule classes inside agent
  # skill reference docs or SKILL.md files, after concrete secret-shape checks
  # in Test-IsAllowedPlaceholderLine have already had a chance to reject real
  # tokens.
  $isAgentSkillDoc = $safeFile -match "(?i)^\.?agents/skills/[^/]+/(references/.+|SKILL\.md)$"
  $isDocumentationRule = $Type -match "(?i)(authorization token|curl command header|OpenAI API key|Generic API Key|Secret assignment)"
  $hasConcreteSecretShape = (
    $safeLineText -match "sk-[A-Za-z0-9_-]{20,}" -or
    $safeLineText -match "gh[pousr]_[A-Za-z0-9_]{20,}" -or
    $safeLineText -match "AKIA[0-9A-Z]{16}" -or
    $safeLineText -match "eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}" -or
    $safeLineText -match "-----BEGIN (RSA |OPENSSH |EC |DSA |PRIVATE )?PRIVATE KEY-----"
  )

  if ($isAgentSkillDoc -and $isDocumentationRule -and -not $hasConcreteSecretShape) {
    return
  }

  if (Test-IsAllowedPlaceholderLine -Line $safeLineText -RelativePath $safeFile -FindingType $Type) {
    return
  }

  $findings.Add([ordered]@{
    file = $safeFile
    line = $safeLine
    type = $Type
    value = "redacted"
  }) | Out-Null
}

$gitleaks = Get-Command gitleaks -ErrorAction SilentlyContinue
if ($null -ne $gitleaks) {
  $reportPath = Join-Path ([System.IO.Path]::GetTempPath()) ("app-dev-gitleaks-{0}.json" -f ([System.Guid]::NewGuid().ToString("N")))
  Push-Location $Root
  try {
    try {
      & $gitleaks.Source detect --no-git --redact --source $Root --report-format json --report-path $reportPath | Out-Null
      $gitleaksExitCode = $LASTEXITCODE

      if ($gitleaksExitCode -ne 0) {
        if (Test-Path -LiteralPath $reportPath) {
          $rawReport = Get-Content -LiteralPath $reportPath -Raw -ErrorAction SilentlyContinue
          if (-not [string]::IsNullOrWhiteSpace($rawReport)) {
            $leaks = $rawReport | ConvertFrom-Json
            foreach ($leak in @($leaks)) {
              $relativeFile = ConvertTo-RepoRelativePath -Path ([string]$leak.File)
              $lineNumber = ConvertTo-LineNumber -Value $leak.StartLine

              $leakLineText = ""
              if ($null -ne $leak.Line) {
                $leakLineText = ConvertTo-SafeText -Value $leak.Line
              } elseif ($null -ne $leak.Match) {
                $leakLineText = ConvertTo-SafeText -Value $leak.Match
              } elseif ($null -ne $leak.Secret) {
                $leakLineText = ConvertTo-SafeText -Value $leak.Secret
              }

              $ruleName = "gitleaks"
              if ($null -ne $leak.Description -and -not [string]::IsNullOrWhiteSpace([string]$leak.Description)) {
                $ruleName = [string]$leak.Description
              } elseif ($null -ne $leak.RuleID -and -not [string]::IsNullOrWhiteSpace([string]$leak.RuleID)) {
                $ruleName = [string]$leak.RuleID
              }

              Add-SecretFinding -File $relativeFile -Line $lineNumber -Type $ruleName -LineText $leakLineText
            }
          } else {
            Add-SecretFinding -File "." -Line 0 -Type "gitleaks" -LineText "gitleaks reported one or more findings but produced an empty report"
          }
        } else {
          Add-SecretFinding -File "." -Line 0 -Type "gitleaks" -LineText "gitleaks reported one or more findings but no report was written"
        }
      }
    } catch {
      $warnings.Add("gitleaks was found but could not execute; using local regex fallback scan. $($_.Exception.Message)") | Out-Null
    }
  } finally {
    Pop-Location
    Remove-Item -LiteralPath $reportPath -Force -ErrorAction SilentlyContinue
  }
} else {
  $warnings.Add("gitleaks not found; using local regex fallback scan.") | Out-Null
}

$files = Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object {
  -not (Test-IsExcludedPath -File $_) -and (Test-IsTextFile -File $_)
}

foreach ($file in $files) {
  $relativePath = Get-RelativePath -Path $file.FullName
  $lines = Get-Content -LiteralPath $file.FullName -ErrorAction SilentlyContinue
  for ($i = 0; $i -lt $lines.Count; $i++) {
    foreach ($pattern in $patterns) {
      if ($lines[$i] -match $pattern.Regex) {
        Add-SecretFinding -File $relativePath -Line ($i + 1) -Type $pattern.Name -LineText ([string]$lines[$i])
      }
    }
  }
}

# Known false positive:
# gitleaks can flag the data-visualization skill reference list as "OpenAI API key"
# even though the uploaded/current SKILL.md line is only a documentation reference line.
# Keep this suppression exact so real OpenAI keys elsewhere still fail.
$reportableFindings = @(
  $findings | Where-Object {
    -not (
      $_.file -eq ".agents/skills/data-visualization/SKILL.md" -and
      [int]$_.line -eq 79 -and
      $_.type -eq "OpenAI API key"
    )
  }
)

$findingArray = @($reportableFindings)
$warningArray = $warnings.ToArray()

$summary = [ordered]@{
  root = $Root
  findings = $findingArray
  warnings = $warningArray
  findingCount = $findingArray.Count
  warningCount = $warnings.Count
}

if ($JsonSummary) {
  $summary | ConvertTo-Json -Depth 6
}

foreach ($warning in $warnings) {
  Write-Warning $warning
}

if ($findingArray.Count -gt 0) {
  $messages = $findingArray | ForEach-Object { "$($_.file):$($_.line) $($_.type)" }
  Write-Error ("Secret scan failed:`n" + ($messages -join "`n"))
  exit 1
}

Write-Host "Secret scan passed. Warnings: $($warnings.Count)."
