param(
  [Parameter(Position=0)]
  [Alias("CommandText")]
  [string]$ShellCommand = ""
)

$ErrorActionPreference = "Stop"

function Get-CommandFromEvent {
  param(
    [Parameter(Mandatory=$true)]
    [object]$Event
  )

  $candidates = @(
    $Event.command,
    $Event.tool_input.command,
    $Event.input.command,
    $Event.arguments.command,
    $Event.params.command,
    $Event.tool_input.cmd,
    $Event.input.cmd,
    $Event.arguments.cmd,
    $Event.params.cmd
  )

  foreach ($candidate in $candidates) {
    if (-not [string]::IsNullOrWhiteSpace([string]$candidate)) {
      return [string]$candidate
    }
  }

  return ""
}

if ([string]::IsNullOrWhiteSpace($ShellCommand)) {
  $rawInput = [Console]::In.ReadToEnd()
  if (-not [string]::IsNullOrWhiteSpace($rawInput)) {
    try {
      $event = $rawInput | ConvertFrom-Json
      $ShellCommand = Get-CommandFromEvent -Event $event
      if ([string]::IsNullOrWhiteSpace($ShellCommand)) {
        Write-Error "Hook input JSON did not contain a shell command field."
      }
    } catch {
      Write-Error "Could not parse hook input JSON; failing closed."
    }
  }
}

$normalized = ([regex]::Replace($ShellCommand, "\s+", " ")).Trim()
$rules = @(
  @{ Name = "git reset hard"; Pattern = "(?i)(^|[\s;&|])git\s+reset\s+--hard(\s|$)" },
  @{ Name = "git checkout path restore"; Pattern = "(?i)(^|[\s;&|])git\s+checkout\s+--(\s|$)" },
  @{ Name = "recursive Remove-Item"; Pattern = "(?i)(^|[\s;&|])Remove-Item\b(?=.*\s-(Recurse|r)\b)" },
  @{ Name = "rm rf"; Pattern = "(?i)(^|[\s;&|])rm\s+-(?:[a-z]*r[a-z]*f|[a-z]*f[a-z]*r)\b" },
  @{ Name = "npm publish"; Pattern = "(?i)(^|[\s;&|])npm\s+publish(\s|$)" },
  @{ Name = "pnpm publish"; Pattern = "(?i)(^|[\s;&|])pnpm\s+publish(\s|$)" },
  @{ Name = "yarn publish"; Pattern = "(?i)(^|[\s;&|])yarn\s+publish(\s|$)" },
  @{ Name = "production deploy"; Pattern = "(?i)(^|[\s;&|])(npm|pnpm|yarn)\s+(run\s+)?deploy(:|-)?(prod|production)\b" },
  @{ Name = "Supabase linked migration"; Pattern = "(?i)(^|[\s;&|])supabase\s+db\s+(push|reset|remote|deploy)\b.*\s--linked\b" },
  @{ Name = "Prisma migration deploy"; Pattern = "(?i)(^|[\s;&|])(npx\s+)?prisma\s+migrate\s+deploy\b" }
)

foreach ($rule in $rules) {
  if ($normalized -match $rule.Pattern) {
    Write-Error "Blocked command by rule '$($rule.Name)': $normalized"
  }
}

Write-Host "pre-command check passed"
