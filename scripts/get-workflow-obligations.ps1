param(
  [string]$ProjectPath = (Get-Location).Path,
  [string[]]$ChangedFiles,
  [bool]$JsonSummary = $false
)

$ErrorActionPreference = "Stop"

function Get-GitChangedFiles {
  param(
    [Parameter(Mandatory=$true)][string]$BasePath
  )

  $commands = @(
    "git diff --name-only --cached 2>nul",
    "git diff --name-only 2>nul"
  )

  $results = New-Object System.Collections.Generic.List[string]

  foreach ($command in $commands) {
    $output = & cmd.exe /d /c $command
    if ($LASTEXITCODE -ne 0) {
      throw "git diff failed while collecting workflow obligations from $BasePath."
    }

    foreach ($line in @($output)) {
      if (-not [string]::IsNullOrWhiteSpace($line)) {
        $results.Add($line) | Out-Null
      }
    }
  }

  return @($results | Select-Object -Unique)
}

function Normalize-RelativePath {
  param(
    [Parameter(Mandatory=$true)][string]$BasePath,
    [Parameter(Mandatory=$true)][string]$Candidate
  )

  $candidatePath = $Candidate
  if (-not [System.IO.Path]::IsPathRooted($candidatePath)) {
    $candidatePath = Join-Path $BasePath $candidatePath
  }

  try {
    $resolvedCandidate = [System.IO.Path]::GetFullPath($candidatePath)
    $resolvedBase = [System.IO.Path]::GetFullPath($BasePath)
    if ($resolvedCandidate.StartsWith($resolvedBase, [System.StringComparison]::OrdinalIgnoreCase)) {
      return ($resolvedCandidate.Substring($resolvedBase.Length).TrimStart('\')).Replace('\', '/')
    }
  } catch {
  }

  return $Candidate.Replace('\', '/')
}

function Add-Match {
  param(
    [Parameter(Mandatory=$true)][hashtable]$Bucket,
    [Parameter(Mandatory=$true)][string]$File,
    [Parameter(Mandatory=$true)][string]$Reason
  )

  $Bucket.required = $true
  if (-not ($Bucket.files -contains $File)) {
    $Bucket.files += $File
  }
  if (-not ($Bucket.reasons -contains $Reason)) {
    $Bucket.reasons += $Reason
  }
}

$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path

if (-not $ChangedFiles -or $ChangedFiles.Count -eq 0) {
  Push-Location $ProjectPath
  try {
    $ChangedFiles = Get-GitChangedFiles -BasePath $ProjectPath
  } finally {
    Pop-Location
  }
}

$normalizedFiles = @(
  $ChangedFiles |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    ForEach-Object { Normalize-RelativePath -BasePath $ProjectPath -Candidate $_ } |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Select-Object -Unique
)

$result = [ordered]@{
  projectPath = $ProjectPath
  changedFiles = $normalizedFiles
  uiChange = [ordered]@{ required = $false; files = @(); reasons = @() }
  dataChange = [ordered]@{ required = $false; files = @(); reasons = @() }
  mobileValidation = [ordered]@{ required = $false; files = @(); reasons = @() }
  releaseReadiness = [ordered]@{ required = $false; files = @(); reasons = @() }
}

foreach ($file in $normalizedFiles) {
  if ($file -match '^(src/(components|routes|app)/|src/modules/[^/]+/(components|routes)/|src/.*\.(css|scss|sass)$|components\.json$)') {
    Add-Match -Bucket $result.uiChange -File $file -Reason "user-facing-ui-surface"
  }

  if ($file -match '^(supabase/|src/lib/supabase|src/modules/[^/]+/(schemas|services)/|.*\.sql$)') {
    Add-Match -Bucket $result.dataChange -File $file -Reason "data-or-schema-surface"
  }

  if ($file -match '^(android/|ios/|capacitor\.config\.)') {
    Add-Match -Bucket $result.mobileValidation -File $file -Reason "mobile-or-native-surface"
  }

  if ($file -match '(^supabase/|.*\.sql$|^android/|^ios/|^capacitor\.config\.|(^|/)(auth|billing|payments?|stripe|subscription|checkout|deploy|migration|public-api|api|upload|storage|secret|rls)(/|\.|-|$))') {
    Add-Match -Bucket $result.releaseReadiness -File $file -Reason "risky-or-release-adjacent-surface"
  }
}

if ($JsonSummary) {
  $result | ConvertTo-Json -Depth 6
  exit 0
}

$result | ConvertTo-Json -Depth 6
