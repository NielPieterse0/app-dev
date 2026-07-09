$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$migrationPaths = @(
  "supabase/migrations/003_signal_live_ingestion.sql",
  "supabase/migrations/004_signal_concepts.sql"
) | ForEach-Object { Join-Path $projectRoot $_ }

$blockingPatterns = @(
  @{
    Path = $migrationPaths[0]
    Pattern = "grant execute on function public\.save_signal_settings\(text\[\], text\[\]\) to anon, authenticated;"
    Message = "Anonymous browser-write access remains enabled for save_signal_settings(...)."
  },
  @{
    Path = $migrationPaths[0]
    Pattern = "grant execute on function public\.replace_signal_source_items\(jsonb, timestamptz\) to anon, authenticated;"
    Message = "Anonymous browser-write access remains enabled for replace_signal_source_items(...)."
  },
  @{
    Path = $migrationPaths[1]
    Pattern = "grant execute on function public\.upsert_signal_concept\(jsonb\) to anon, authenticated;"
    Message = "Anonymous browser-write access remains enabled for upsert_signal_concept(...)."
  }
)

$failures = New-Object System.Collections.Generic.List[string]

foreach ($check in $blockingPatterns) {
  if (-not (Test-Path -LiteralPath $check.Path)) {
    $failures.Add("Missing migration required for public-launch readiness inspection: $($check.Path)") | Out-Null
    continue
  }

  $content = Get-Content -LiteralPath $check.Path -Raw
  if ($content -match $check.Pattern) {
    $failures.Add($check.Message) | Out-Null
  }
}

if ($failures.Count -gt 0) {
  Write-Error @"
Signal public-launch readiness failed.

This gate is expected to fail until the internal-MVP anonymous browser-write posture is removed.
$($failures -join "`n")
"@
}

Write-Host "Signal public-launch readiness passed."
