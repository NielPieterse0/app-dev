$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$hook = Join-Path $root ".codex\hooks\pre-command.ps1"

if (-not (Test-Path $hook)) {
  Write-Error "pre-command hook not found: $hook"
}

$blocked = @(
  "git reset --hard HEAD",
  "git checkout -- AGENTS.md",
  "Remove-Item -LiteralPath projects\demo -Recurse -Force",
  "rm -rf dist",
  "npm publish --access public",
  "pnpm publish",
  "yarn publish",
  "npm run deploy:prod",
  "supabase db push --linked",
  "npx prisma migrate deploy"
)

$allowed = @(
  "npm run build",
  "git status --short",
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

try {
  "{ not valid json" | & $hook *> $null
  $failures += "Expected malformed hook JSON to fail closed."
} catch {
  Write-Host "Malformed hook JSON failed closed as expected."
}

try {
  '{"command":"git reset --hard HEAD"}' | & $hook *> $null
  $failures += "Expected JSON command to block."
} catch {
  Write-Host "JSON command blocked as expected."
}

if ($failures.Count -gt 0) {
  Write-Error ("Hook tests failed:`n" + ($failures -join "`n"))
}

Write-Host "Hook tests passed."
