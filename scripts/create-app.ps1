param(
  [Parameter(Mandatory=$true)]
  [ValidatePattern("^_*[a-z0-9][a-z0-9-]*$")]
  [string]$Name,

  [ValidateSet("react-vite-capacitor", "next-web-app", "expo-native-app")]
  [string]$Template = "react-vite-capacitor",

  [bool]$NoInstall = $true,

  [bool]$InitializeGit = $false
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root "templates/$Template"
$target = Join-Path $root "projects/$Name"

if (-not (Test-Path -LiteralPath $source)) {
  Write-Error "Template not found: $source"
}

if (Test-Path -LiteralPath $target) {
  Write-Error "Project already exists: $target"
}

New-Item -ItemType Directory -Force -Path $target | Out-Null
Get-ChildItem -LiteralPath $source -Force | ForEach-Object {
  Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
}

$agentPath = Join-Path $target "AGENTS.md"
if (-not (Test-Path -LiteralPath $agentPath)) {
  Set-Content -LiteralPath $agentPath -Encoding UTF8 -Value @"
# $Name Codex Instructions

This project inherits the app-dev workspace standards.

## Product Decision Record

- Users: TBD
- Core jobs: TBD
- Modules: TBD
- Data model: TBD
- Permissions: TBD
- Platforms: desktop web, Android, iOS unless revised
- Native requirements: none identified yet

## Verification

Use the scripts in package.json. Before completion, run available checks through:

````powershell
..\..\scripts\verify-app.ps1 -ProjectPath .
````
"@
}

$planPath = Join-Path $target "PLAN.md"
$templatePlanPath = Join-Path $root "templates/PLAN.template.md"
if (-not (Test-Path -LiteralPath $planPath)) {
  if (-not (Test-Path -LiteralPath $templatePlanPath)) {
    Write-Error "Plan template not found: $templatePlanPath"
  }

  $planText = Get-Content -LiteralPath $templatePlanPath -Raw
  $planText = $planText.Replace("{{APP_NAME}}", $Name)
  $planText = $planText.Replace("{{TEMPLATE}}", $Template)
  $planText = $planText.Replace("{{DATE}}", (Get-Date -Format "yyyy-MM-dd"))
  Set-Content -LiteralPath $planPath -Encoding UTF8 -Value $planText
}

$required = @("package.json", "AGENTS.md", "PLAN.md")
if ($Template -eq "react-vite-capacitor") {
  $required += @(".env.example", "index.html", "src/main.tsx")
}

foreach ($item in $required) {
  $path = Join-Path $target $item
  if (-not (Test-Path -LiteralPath $path)) {
    Write-Error "Generated project is missing required file: $item"
  }
}

if (-not $NoInstall) {
  Write-Host "Dependency installation is intentionally not automated. Run the package manager inside $target after reviewing package.json."
}

if ($InitializeGit) {
  Push-Location $target
  try {
    git init | Out-Host
    if ($LASTEXITCODE -ne 0) {
      Write-Error "git init failed with exit code $LASTEXITCODE"
    }
  } finally {
    Pop-Location
  }
}

Write-Host "Created $Name from $Template at $target"
Write-Host "Next: review $agentPath and $planPath, install dependencies inside the project, then run ../../scripts/verify-app.ps1 -ProjectPath ."
