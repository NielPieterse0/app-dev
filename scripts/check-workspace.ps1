$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$required = @(
  "AGENTS.md",
  "PLANS.md",
  ".github/workflows/app-dev-validation.yml",
  ".codex/config.toml",
  ".codex/rules/default.rules",
  ".codex/hooks/pre-command.ps1",
  ".codex/hooks/post-edit.ps1",
  ".codex/hooks/verify-before-finish.ps1",
  "standards/stack.md",
  "standards/workspace.md",
  "standards/codex-capabilities.md",
  "standards/adaptive-layouts.md",
  "standards/testing.md",
  "standards/security.md",
  ".agents/README.md",
  ".agents/skills/README.md",
  ".agents/skills/cross-platform-app-workflow/SKILL.md",
  ".agents/skills/cross-platform-app-workflow/agents/openai.yaml",
  ".agents/skills/cross-platform-app-workflow/references/stack.md",
  ".agents/skills/cross-platform-app-workflow/references/module-contract.md",
  ".agents/skills/cross-platform-app-workflow/references/adaptive-layouts.md",
  ".agents/skills/cross-platform-app-workflow/references/qa-gates.md",
  "scripts/create-app.ps1",
  "scripts/verify-app.ps1",
  "scripts/test-hooks.ps1",
  "scripts/test-workspace.ps1",
  "scripts/validate-codex-assets.ps1",
  "templates/PLAN.template.md",
  "templates/react-vite-capacitor/package.json",
  "templates/next-web-app/package.json",
  "templates/expo-native-app/package.json",
  "projects"
)

$missing = @()
foreach ($item in $required) {
  $path = Join-Path $root $item
  if (-not (Test-Path $path)) {
    $missing += $item
  }
}

if ($missing.Count -gt 0) {
  Write-Error ("Missing required workspace files: " + ($missing -join ", "))
}

Write-Host "app-dev workspace check passed: $root"
