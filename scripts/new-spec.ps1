param(
  [Parameter(Mandatory=$true)]
  [string]$ProjectPath,

  [Parameter(Mandatory=$true)]
  [string]$Name,

  [ValidateSet("standard", "sensitive")]
  [string]$RiskLevel = "standard"
)

$ErrorActionPreference = "Stop"

function Convert-ToSlug {
  param([Parameter(Mandatory=$true)][string]$Value)

  $slug = $Value.ToLowerInvariant()
  $slug = [regex]::Replace($slug, "[^a-z0-9]+", "-")
  $slug = $slug.Trim("-")
  if ([string]::IsNullOrWhiteSpace($slug)) {
    throw "Name must contain at least one letter or number."
  }
  return $slug
}

function Apply-Replacements {
  param(
    [Parameter(Mandatory=$true)][string]$Text,
    [Parameter(Mandatory=$true)][hashtable]$Replacements
  )

  foreach ($entry in $Replacements.GetEnumerator()) {
    $Text = $Text.Replace($entry.Key, $entry.Value)
  }
  return $Text
}

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$templateDir = Join-Path $workspaceRoot "templates/spec-workflow"
$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path
$specsPath = Join-Path $ProjectPath "specs"

if (-not (Test-Path -LiteralPath (Join-Path $ProjectPath "AGENTS.md"))) {
  Write-Error "Project AGENTS.md not found in $ProjectPath"
}

if (-not (Test-Path -LiteralPath $specsPath)) {
  New-Item -ItemType Directory -Force -Path $specsPath | Out-Null
}

$existingDirs = Get-ChildItem -LiteralPath $specsPath -Directory -ErrorAction SilentlyContinue
$nextNumber = 1
if ($existingDirs) {
  $numbers = $existingDirs | ForEach-Object {
    if ($_.Name -match "^(\d{3})-") { [int]$matches[1] }
  } | Where-Object { $_ -ne $null }

  if ($numbers) {
    $nextNumber = ([int](($numbers | Measure-Object -Maximum).Maximum)) + 1
  }
}

$numberText = "{0:D3}" -f $nextNumber
$slug = Convert-ToSlug -Value $Name
$specDirName = "$numberText-$slug"
$specDirPath = Join-Path $specsPath $specDirName

if (Test-Path -LiteralPath $specDirPath) {
  Write-Error "Spec directory already exists: $specDirPath"
}

New-Item -ItemType Directory -Force -Path $specDirPath | Out-Null

$replacements = @{
  "{{SPEC_NUMBER}}" = $numberText
  "{{SPEC_TITLE}}" = $Name
  "{{SPEC_DIR}}" = $specDirName
  "{{RISK_LEVEL}}" = $RiskLevel
  "{{APP_NAME}}" = (Split-Path -Leaf $ProjectPath)
  "{{DATE}}" = (Get-Date -Format "yyyy-MM-dd")
}

$files = @("spec.template.md", "tasks.template.md")
if ($RiskLevel -eq "sensitive") {
  $files += "checklist.template.md"
}

foreach ($templateName in $files) {
  $sourcePath = Join-Path $templateDir $templateName
  if (-not (Test-Path -LiteralPath $sourcePath)) {
    Write-Error "Spec workflow template not found: $sourcePath"
  }

  $targetName = $templateName.Replace(".template", "")
  $targetPath = Join-Path $specDirPath $targetName
  $text = Get-Content -LiteralPath $sourcePath -Raw
  $text = Apply-Replacements -Text $text -Replacements $replacements
  Set-Content -LiteralPath $targetPath -Encoding UTF8 -Value $text
}

Write-Host "Created spec folder $specDirName in $ProjectPath"
