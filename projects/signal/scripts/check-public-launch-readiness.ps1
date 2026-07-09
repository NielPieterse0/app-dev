$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$migrationDirectory = Join-Path $projectRoot "supabase/migrations"

$blockingFunctions = @(
  @{
    Signature = "save_signal_settings(text[], text[])"
    Message = "Anonymous browser-write access remains enabled for save_signal_settings(...)."
  },
  @{
    Signature = "replace_signal_source_items(jsonb, timestamptz)"
    Message = "Anonymous full-feed reset access remains enabled for replace_signal_source_items(...)."
  },
  @{
    Signature = "upsert_signal_concept(jsonb)"
    Message = "Anonymous browser-write access remains enabled for upsert_signal_concept(...)."
  }
)

$failures = New-Object System.Collections.Generic.List[string]

if (-not (Test-Path -LiteralPath $migrationDirectory)) {
  Write-Error "Signal public-launch readiness failed.`nMissing migration directory: $migrationDirectory"
}

$migrationFiles = @(Get-ChildItem -LiteralPath $migrationDirectory -Filter "*.sql" | Sort-Object Name)
if ($migrationFiles.Count -eq 0) {
  Write-Error "Signal public-launch readiness failed.`nNo SQL migrations found under $migrationDirectory"
}

foreach ($check in $blockingFunctions) {
  $hasGrantToAnon = $false

  foreach ($migrationFile in $migrationFiles) {
    $content = Get-Content -LiteralPath $migrationFile.FullName -Raw
    $escapedSignature = [regex]::Escape($check.Signature)

    foreach ($match in [regex]::Matches($content, "(?im)^\s*grant\s+execute\s+on\s+function\s+public\.$escapedSignature\s+to\s+([^;]+);")) {
      if ($match.Groups[1].Value -match "(?i)\banon\b") {
        $hasGrantToAnon = $true
      }
    }

    foreach ($match in [regex]::Matches($content, "(?im)^\s*revoke\s+execute\s+on\s+function\s+public\.$escapedSignature\s+from\s+([^;]+);")) {
      if ($match.Groups[1].Value -match "(?i)\banon\b" -or $match.Groups[1].Value -match "(?i)\bpublic\b") {
        $hasGrantToAnon = $false
      }
    }
  }

  if ($hasGrantToAnon) {
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
