$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectMatrix = @(
  @{
    Name = "__verify-react"
    Template = "react-vite-capacitor"
    Required = @(
      "package.json",
      "AGENTS.md",
      "PLAN.md",
      ".env.example",
      "index.html",
      "src/main.tsx",
      "src/app/AppShell.tsx",
      "src/app/NavigationShell.tsx",
      "src/app/routes.tsx",
      "src/modules/dashboard/routes/DashboardRoute.tsx",
      "src/modules/settings/routes/SettingsRoute.tsx",
      "src/components/state/EmptyState.tsx",
      "src/components/state/LoadingState.tsx",
      "src/components/state/ErrorState.tsx",
      "src/components/layout/FormLayout.tsx",
      "tailwind.config.ts",
      "postcss.config.js",
      "components.json",
      "capacitor.config.ts"
    )
    Scripts = @("typecheck", "lint", "test", "build", "e2e")
  },
  @{
    Name = "__verify-next"
    Template = "next-web-app"
    Required = @(
      "package.json",
      "AGENTS.md",
      "PLAN.md",
      ".env.example",
      "app/layout.tsx",
      "app/page.tsx",
      "next.config.ts",
      "tsconfig.json",
      "eslint.config.js",
      "tests/smoke.test.ts"
    )
    Scripts = @("typecheck", "lint", "test", "build")
  },
  @{
    Name = "__verify-expo"
    Template = "expo-native-app"
    Required = @(
      "package.json",
      "AGENTS.md",
      "PLAN.md",
      ".env.example",
      "app.json",
      "App.tsx",
      "tsconfig.json",
      "babel.config.js",
      "jest.config.js",
      "tests/App.test.tsx"
    )
    Scripts = @("typecheck", "lint", "test")
  }
)

function Assert-PathExists {
  param(
    [Parameter(Mandatory=$true)]
    [string]$Path
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    Write-Error "Expected path missing: $Path"
  }
}

function Remove-DisposableProject {
  param([Parameter(Mandatory=$true)][string]$ProjectPath)

  if (-not (Test-Path -LiteralPath $ProjectPath)) {
    return
  }

  $resolvedRoot = (Resolve-Path -LiteralPath (Join-Path $root "projects")).Path
  $resolvedTarget = (Resolve-Path -LiteralPath $ProjectPath).Path
  if (-not $resolvedTarget.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Error "Refusing to remove path outside projects: $resolvedTarget"
  }

  Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
}

function Assert-GeneratedProject {
  param(
    [Parameter(Mandatory=$true)][hashtable]$Project
  )

  $projectPath = Join-Path $root "projects/$($Project.Name)"
  foreach ($item in $Project.Required) {
    Assert-PathExists (Join-Path $projectPath $item)
  }

  $plan = Get-Content -LiteralPath (Join-Path $projectPath "PLAN.md") -Raw
  if ($plan -match "{{APP_NAME}}|{{TEMPLATE}}|{{DATE}}|\bTBD\b") {
    Write-Error "Generated PLAN.md contains unresolved placeholders for $($Project.Name)."
  }
  if ($plan -notmatch [regex]::Escape($Project.Name)) {
    Write-Error "Generated PLAN.md does not contain the project name for $($Project.Name)."
  }

  $agents = Get-Content -LiteralPath (Join-Path $projectPath "AGENTS.md") -Raw
  foreach ($required in @("Product Decision Record", "Done When", "verify-app.ps1 -ProjectPath .")) {
    if ($agents -notmatch [regex]::Escape($required)) {
      Write-Error "Generated AGENTS.md for $($Project.Name) is missing: $required"
    }
  }

  $package = Get-Content -LiteralPath (Join-Path $projectPath "package.json") -Raw | ConvertFrom-Json
  foreach ($scriptName in $Project.Scripts) {
    if ($null -eq $package.scripts -or -not ($package.scripts.PSObject.Properties.Name -contains $scriptName)) {
      Write-Error "Generated package.json for $($Project.Name) is missing script: $scriptName"
    }
  }
}

try {
  & (Join-Path $root "scripts/check-workspace.ps1")
  & (Join-Path $root "scripts/validate-codex-assets.ps1")
  & (Join-Path $root "scripts/test-hooks.ps1")

  foreach ($project in $projectMatrix) {
    $projectPath = Join-Path $root "projects/$($project.Name)"
    Remove-DisposableProject -ProjectPath $projectPath
    & (Join-Path $root "scripts/create-app.ps1") -Name $project.Name -Template $project.Template
    Assert-GeneratedProject -Project $project
  }

  Write-Host "Workspace tests passed."
} finally {
  foreach ($project in $projectMatrix) {
    Remove-DisposableProject -ProjectPath (Join-Path $root "projects/$($project.Name)")
  }
}
