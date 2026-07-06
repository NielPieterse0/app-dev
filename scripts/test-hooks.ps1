$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$hook = Join-Path $root ".codex\hooks\pre-command.ps1"

if (-not (Test-Path $hook)) {
  Write-Error "pre-command hook not found: $hook"
}

$blocked = @(
  "git reset --hard HEAD",
  "git checkout -- AGENTS.md",
  "git clean -fd",
  "git push --force origin main",
  "Remove-Item -LiteralPath projects\demo -Recurse -Force",
  "ri projects\demo -Recurse -Force",
  "del projects\demo -Recurse -Force",
  "rm -rf dist",
  "rm -r dist",
  "node -e ""require('fs').rmSync('dist', { recursive: true, force: true })""",
  "python -c ""import shutil; shutil.rmtree('dist')""",
  "gh release create v1.0.0",
  "npm publish --access public",
  "npm version patch",
  "pnpm publish",
  "yarn publish",
  "npm install -g create-vite",
  "npm run deploy:prod",
  "vercel deploy --prod",
  "netlify deploy --prod",
  "firebase deploy",
  "wrangler deploy",
  "docker system prune -a",
  "supabase db push",
  "supabase db push --linked",
  "supabase db remote commit",
  "supabase db deploy",
  "supabase db reset",
  "npx prisma migrate deploy",
  "kubectl apply -f deployment.yaml",
  "cat .env",
  "Get-Content .env.local"
)

$allowed = @(
  "npm run build",
  "npm run test",
  "git status --short",
  "git diff -- AGENTS.md",
  "rg --files",
  "pwsh -NoProfile -File scripts\check-workspace.ps1"
)

$failures = @()

foreach ($sample in $blocked) {
  try {
    & $hook -ShellCommand $sample *> $null
    $failures += "Expected block but passed: $sample"
  } catch {
    Write-Host "Blocked as expected: $sample"
  }
}

foreach ($sample in $allowed) {
  try {
    & $hook -ShellCommand $sample *> $null
    Write-Host "Allowed as expected: $sample"
  } catch {
    $failures += "Expected allow but blocked: $sample"
  }
}

$malformed = "{ not valid json" | powershell -NoProfile -ExecutionPolicy Bypass -File $hook
if ($LASTEXITCODE -ne 0 -or $malformed -notmatch '"decision":"block"') {
  $failures += "Expected malformed hook JSON to return block JSON without crashing."
} else {
  Write-Host "Malformed hook JSON failed closed as expected."
}

$jsonBlocked = '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git reset --hard HEAD"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File $hook
if ($LASTEXITCODE -ne 0 -or $jsonBlocked -notmatch '"permissionDecision":"deny"') {
  $failures += "Expected PreToolUse JSON command to return deny JSON."
} else {
  Write-Host "PreToolUse JSON command denied as expected."
}

$jsonPermissionBlocked = '{"hook_event_name":"PermissionRequest","tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File $hook
if ($LASTEXITCODE -ne 0 -or $jsonPermissionBlocked -notmatch '"behavior":"deny"') {
  $failures += "Expected PermissionRequest JSON command to return deny JSON."
} else {
  Write-Host "PermissionRequest JSON command denied as expected."
}

$jsonAllowed = '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"git status --short"}}' | powershell -NoProfile -ExecutionPolicy Bypass -File $hook
if ($LASTEXITCODE -ne 0 -or -not [string]::IsNullOrWhiteSpace($jsonAllowed)) {
  $failures += "Expected allowed hook JSON command to produce no output and exit 0."
} else {
  Write-Host "Allowed hook JSON command passed silently as expected."
}

if ($failures.Count -gt 0) {
  Write-Error ("Hook tests failed:`n" + ($failures -join "`n"))
}

Write-Host "Hook tests passed."
