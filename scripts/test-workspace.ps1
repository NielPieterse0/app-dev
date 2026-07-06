$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectName = "__verify-template"
$projectPath = Join-Path $root "projects\$projectName"

function Assert-PathExists {
  param(
    [Parameter(Mandatory=$true)]
    [string]$Path
  )

  if (-not (Test-Path $Path)) {
    Write-Error "Expected path missing: $Path"
  }
}

function Remove-DisposableProject {
  if (-not (Test-Path $projectPath)) {
    return
  }

  $resolvedRoot = (Resolve-Path (Join-Path $root "projects")).Path
  $resolvedTarget = (Resolve-Path $projectPath).Path
  if (-not $resolvedTarget.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Error "Refusing to remove path outside projects: $resolvedTarget"
  }

  Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
}

try {
  & (Join-Path $root "scripts\check-workspace.ps1")
  & (Join-Path $root "scripts\validate-codex-assets.ps1")
  & (Join-Path $root "scripts\test-hooks.ps1")

  Remove-DisposableProject
  & (Join-Path $root "scripts\create-app.ps1") -Name $projectName -Template "react-vite-capacitor"

  $required = @(
    "package.json",
    "AGENTS.md",
    ".env.example",
    "index.html",
    "src\main.tsx",
    "src\app\AppShell.tsx",
    "src\app\NavigationShell.tsx",
    "src\components\layout\ListDetailLayout.tsx",
    "src\components\layout\FormLayout.tsx",
    "src\components\layout\DataTableLayout.tsx",
    "src\modules\README.md"
  )

  foreach ($item in $required) {
    Assert-PathExists (Join-Path $projectPath $item)
  }

  $package = Get-Content (Join-Path $projectPath "package.json") -Raw | ConvertFrom-Json
  foreach ($scriptName in @("typecheck", "lint", "test", "build", "e2e")) {
    if ($null -eq $package.scripts -or -not ($package.scripts.PSObject.Properties.Name -contains $scriptName)) {
      Write-Error "Generated package.json is missing script: $scriptName"
    }
  }

  Write-Host "Workspace tests passed."
} finally {
  Remove-DisposableProject
}
