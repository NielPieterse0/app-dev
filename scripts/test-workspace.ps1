$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$runSuffix = ([guid]::NewGuid().ToString("N")).Substring(0, 8)
$projectMatrix = @(
  @{
    Name = "__verify-react-vite-capacitor-$runSuffix"
    Template = "react-vite-capacitor"
    Required = @(
      "package.json",
      "AGENTS.md",
      "PLAN.md",
      "specs/001-initial/spec.md",
      "specs/001-initial/tasks.md",
      "specs/001-initial/workflow-receipts.md",
      "specs/001-initial/checklist.md",
      ".env.example",
      "index.html",
      "playwright.config.ts",
      "scripts/add-native-platforms.ps1",
      "supabase/README.md",
      "supabase/migrations/001_template_foundation.sql",
      "src/main.tsx",
      "src/app/AppShell.tsx",
      "src/app/NavigationShell.tsx",
      "src/app/routes.tsx",
      "src/lib/env.ts",
      "src/lib/supabase.ts",
      "src/lib/query-client.ts",
      "src/components/ui/form.tsx",
      "src/modules/dashboard/routes/DashboardRoute.tsx",
      "src/modules/dashboard/index.ts",
      "src/modules/dashboard/components/DashboardModulesTable.tsx",
      "src/modules/dashboard/components/DashboardSummary.tsx",
      "src/modules/dashboard/components/DashboardActivityChart.tsx",
      "src/modules/dashboard/hooks/useDashboardModules.ts",
      "src/modules/dashboard/schemas/dashboard-module.schema.ts",
      "src/modules/dashboard/services/dashboard-service.ts",
      "src/modules/dashboard/state/dashboard-view-store.ts",
      "src/modules/dashboard/tests/DashboardRoute.test.tsx",
      "src/modules/settings/routes/SettingsRoute.tsx",
      "src/components/state/EmptyState.tsx",
      "src/components/state/LoadingState.tsx",
      "src/components/state/ErrorState.tsx",
      "src/components/layout/FormLayout.tsx",
      "src/components/layout/SettingsLayout.tsx",
      "tailwind.config.ts",
      "postcss.config.js",
      "components.json",
      "capacitor.config.ts"
    )
    Scripts = @("typecheck", "lint", "test", "build", "e2e")
  },
  @{
    Name = "__verify-next-$runSuffix"
    Template = "next-web-app"
    Required = @(
      "package.json",
      "AGENTS.md",
      "PLAN.md",
      "specs/001-initial/spec.md",
      "specs/001-initial/tasks.md",
      "specs/001-initial/workflow-receipts.md",
      "specs/001-initial/checklist.md",
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
    Name = "__verify-expo-$runSuffix"
    Template = "expo-native-app"
    Required = @(
      "package.json",
      "AGENTS.md",
      "PLAN.md",
      "specs/001-initial/spec.md",
      "specs/001-initial/tasks.md",
      "specs/001-initial/workflow-receipts.md",
      "specs/001-initial/checklist.md",
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
  foreach ($required in @("Active Specification", "Done When", "verify-app.ps1 -ProjectPath .", "check-spec-artifacts.ps1 -ProjectPath .", "validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence")) {
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
  if (Test-Path -LiteralPath (Join-Path $projectPath ".github")) {
    Write-Error "Generated project must not contain a nested .github directory: $($Project.Name)"
  }
  Push-Location $projectPath
  try {
    $generatedWorkflowRequirements = '{"uiChange":{"required":true},"dataChange":{"required":true},"mobileValidation":{"required":true},"releaseReadiness":{"required":true}}'
    & (Join-Path $root "scripts/check-spec-artifacts.ps1") -ProjectPath "."
    if ($LASTEXITCODE -ne 0) {
      Write-Error "check-spec-artifacts.ps1 failed with exit code $LASTEXITCODE for $($Project.Name)"
    }
    & (Join-Path $root "scripts/analyze-spec.ps1") -ProjectPath "."
    if ($LASTEXITCODE -ne 0) {
      Write-Error "analyze-spec.ps1 failed with exit code $LASTEXITCODE for $($Project.Name)"
    }
    & (Join-Path $root "scripts/validate-workflow-receipts.ps1") -ProjectPath "." -ChangedFilesJson $generatedWorkflowRequirements
    if ($LASTEXITCODE -ne 0) {
      Write-Error "validate-workflow-receipts.ps1 failed with exit code $LASTEXITCODE for $($Project.Name)"
    }
  } finally {
    Pop-Location
  }
}

function Assert-TrackedByRootGitignore {
  param([Parameter(Mandatory=$true)][string]$RelativePath)

  Push-Location $root
  try {
    & git check-ignore -v $RelativePath *> $null
    if ($LASTEXITCODE -eq 0) {
      Write-Error "Expected $RelativePath to remain trackable by the root repository."
    }
  } finally {
    Pop-Location
  }
}

try {
  & (Join-Path $root "scripts/lint-portability.ps1")
  & (Join-Path $root "scripts/check-workspace.ps1")
  & (Join-Path $root "scripts/validate-codex-assets.ps1") -RequirePythonToml:$true
  & (Join-Path $root "scripts/test-hooks.ps1")
  & (Join-Path $root "scripts/test-lint-portability.ps1")
  & (Join-Path $root "scripts/test-workflow-enforcement.ps1")
  & (Join-Path $root "scripts/test-analyze-spec.ps1")
  & (Join-Path $root "scripts/check-template-parity.ps1")
  & (Join-Path $root "scripts/scan-secrets.ps1")

  foreach ($project in $projectMatrix) {
    $projectPath = Join-Path $root "projects/$($project.Name)"
    Remove-DisposableProject -ProjectPath $projectPath
    & (Join-Path $root "scripts/create-app.ps1") -Name $project.Name -Template $project.Template
    Assert-GeneratedProject -Project $project
  }

  Assert-TrackedByRootGitignore -RelativePath "projects/$($projectMatrix[0].Name)/package.json"

  Write-Host "Workspace tests passed."
} finally {
  foreach ($project in $projectMatrix) {
    Remove-DisposableProject -ProjectPath (Join-Path $root "projects/$($project.Name)")
  }
}
