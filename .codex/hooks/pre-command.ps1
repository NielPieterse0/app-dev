param(
  [Parameter(Position=0)]
  [Alias("CommandText")]
  [string]$ShellCommand = ""
)

$ErrorActionPreference = "Stop"

function ConvertTo-HookJson {
  param([Parameter(Mandatory=$true)][object]$Value)
  return ($Value | ConvertTo-Json -Depth 20 -Compress)
}

function Get-EventField {
  param(
    [Parameter(Mandatory=$true)][object]$Event,
    [Parameter(Mandatory=$true)][string[]]$Path
  )

  $current = $Event
  foreach ($part in $Path) {
    if ($null -eq $current) { return $null }
    $property = $current.PSObject.Properties[$part]
    if ($null -eq $property) { return $null }
    $current = $property.Value
  }
  return $current
}

function Get-CommandFromEvent {
  param([Parameter(Mandatory=$true)][object]$Event)

  $candidatePaths = @(
    @("tool_input", "command"),
    @("input", "command"),
    @("arguments", "command"),
    @("params", "command"),
    @("command"),
    @("tool_input", "cmd"),
    @("input", "cmd"),
    @("arguments", "cmd"),
    @("params", "cmd")
  )

  foreach ($path in $candidatePaths) {
    $candidate = Get-EventField -Event $Event -Path $path
    if ($candidate -is [array]) {
      $candidate = ($candidate | ForEach-Object { [string]$_ }) -join " "
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$candidate)) {
      return [string]$candidate
    }
  }

  return ""
}

function Get-HookEventName {
  param([object]$Event)

  if ($null -eq $Event) { return "PreToolUse" }
  $name = Get-EventField -Event $Event -Path @("hook_event_name")
  if ([string]::IsNullOrWhiteSpace([string]$name)) { return "PreToolUse" }
  return [string]$name
}

function New-DenyOutput {
  param(
    [Parameter(Mandatory=$true)][string]$EventName,
    [Parameter(Mandatory=$true)][string]$Reason
  )

  if ($EventName -eq "PermissionRequest") {
    return [ordered]@{
      hookSpecificOutput = [ordered]@{
        hookEventName = "PermissionRequest"
        decision = [ordered]@{
          behavior = "deny"
          message = $Reason
        }
      }
    }
  }

  return [ordered]@{
    hookSpecificOutput = [ordered]@{
      hookEventName = "PreToolUse"
      permissionDecision = "deny"
      permissionDecisionReason = $Reason
    }
  }
}

function New-ContextOutput {
  param(
    [Parameter(Mandatory=$true)][string]$EventName,
    [Parameter(Mandatory=$true)][string]$Message
  )

  return [ordered]@{
    hookSpecificOutput = [ordered]@{
      hookEventName = $EventName
      additionalContext = $Message
    }
  }
}

function Test-BlockedCommand {
  param([Parameter(Mandatory=$true)][string]$CommandText)

  $normalized = ([regex]::Replace($CommandText, "\s+", " ")).Trim()
  if ([string]::IsNullOrWhiteSpace($normalized)) {
    return $null
  }

  $rules = @(
    @{ Name = "git reset hard"; Pattern = "(?i)(^|[\s;&|])git\s+reset\s+(?:[^;&|]*\s+)?--hard(\s|$)"; Reason = "Hard reset can discard user work. Use git status/diff first and ask for an explicit rollback target." },
    @{ Name = "git checkout path restore"; Pattern = "(?i)(^|[\s;&|])git\s+checkout\s+--(\s|$)"; Reason = "Path checkout can silently discard local edits. Use git diff and ask before restoring files." },
    @{ Name = "git clean force"; Pattern = "(?i)(^|[\s;&|])git\s+clean\b(?=.*(?:\s|^)-[^;&|]*f)"; Reason = "git clean may delete untracked files. Ask for explicit approval with exact paths and flags." },
    @{ Name = "git force push"; Pattern = "(?i)(^|[\s;&|])git\s+push\b(?=.*--force(\s|$|=))"; Reason = "Force push can rewrite shared history. Ask the user to perform it manually if required." },
    @{ Name = "recursive Remove-Item"; Pattern = "(?i)(^|[\s;&|])Remove-Item\b(?=.*\s-(Recurse|r)\b)"; Reason = "Recursive PowerShell deletion is blocked. Use targeted edits or a reviewed cleanup script." },
    @{ Name = "rm recursive"; Pattern = "(?i)(^|[\s;&|])rm\s+-(?:[a-z]*r|[a-z]*R)[a-z]*(\s|$)"; Reason = "Recursive rm is blocked. Use targeted file edits or a reviewed cleanup script." },
    @{ Name = "rm force recursive"; Pattern = "(?i)(^|[\s;&|])rm\s+-(?:[a-z]*r[a-z]*f|[a-z]*f[a-z]*r|[a-z]*R[a-z]*f|[a-z]*f[a-z]*R)[a-z]*(\s|$)"; Reason = "Recursive forced deletion is blocked. Use targeted file edits or a reviewed cleanup script." },
    @{ Name = "windows recursive delete"; Pattern = "(?i)(^|[\s;&|])(del|erase)\s+.*\s/(s|q)(\s|$).*\s/(s|q)(\s|$)"; Reason = "Recursive quiet Windows deletion is blocked. Use targeted file edits or a reviewed cleanup script." },
    @{ Name = "npm publish"; Pattern = "(?i)(^|[\s;&|])npm\s+publish(\s|$)"; Reason = "Package publishing must be performed manually by the user after release review." },
    @{ Name = "pnpm publish"; Pattern = "(?i)(^|[\s;&|])pnpm\s+publish(\s|$)"; Reason = "Package publishing must be performed manually by the user after release review." },
    @{ Name = "yarn publish"; Pattern = "(?i)(^|[\s;&|])yarn\s+publish(\s|$)"; Reason = "Package publishing must be performed manually by the user after release review." },
    @{ Name = "global npm install"; Pattern = "(?i)(^|[\s;&|])npm\s+(install|i|add)\b(?=.*\s-g(\s|$))"; Reason = "Global dependency installation is outside this workspace policy. Install project dependencies inside a project with explicit review." },
    @{ Name = "global pnpm add"; Pattern = "(?i)(^|[\s;&|])pnpm\s+add\b(?=.*\s-g(\s|$))"; Reason = "Global dependency installation is outside this workspace policy. Install project dependencies inside a project with explicit review." },
    @{ Name = "global yarn add"; Pattern = "(?i)(^|[\s;&|])yarn\s+global\s+add\b"; Reason = "Global dependency installation is outside this workspace policy. Install project dependencies inside a project with explicit review." },
    @{ Name = "production deploy script"; Pattern = "(?i)(^|[\s;&|])(npm|pnpm|yarn)\s+(run\s+)?deploy(:|-)?(prod|production)?\b"; Reason = "Deployment commands require explicit target/environment approval and should not be run by default hooks." },
    @{ Name = "vercel production deploy"; Pattern = "(?i)(^|[\s;&|])vercel\s+(deploy\s+)?--prod\b"; Reason = "Production deployment requires explicit approval." },
    @{ Name = "netlify production deploy"; Pattern = "(?i)(^|[\s;&|])netlify\s+deploy\b(?=.*--prod\b)"; Reason = "Production deployment requires explicit approval." },
    @{ Name = "firebase deploy"; Pattern = "(?i)(^|[\s;&|])firebase\s+deploy\b"; Reason = "Firebase deployment requires explicit project/environment approval." },
    @{ Name = "wrangler deploy"; Pattern = "(?i)(^|[\s;&|])wrangler\s+deploy\b"; Reason = "Cloudflare deployment requires explicit target/environment approval." },
    @{ Name = "supabase linked db mutation"; Pattern = "(?i)(^|[\s;&|])supabase\s+db\s+(push|reset|remote|deploy)\b.*\s--linked\b"; Reason = "Linked Supabase database mutations require explicit environment approval." },
    @{ Name = "supabase db reset"; Pattern = "(?i)(^|[\s;&|])supabase\s+db\s+reset\b"; Reason = "Database reset can destroy data. Use a local disposable database or ask the user to run it manually." },
    @{ Name = "prisma migration deploy"; Pattern = "(?i)(^|[\s;&|])(npx\s+)?prisma\s+migrate\s+deploy\b"; Reason = "Prisma production migrations require explicit database/environment approval." },
    @{ Name = "kubectl mutation"; Pattern = "(?i)(^|[\s;&|])kubectl\s+(apply|delete|replace|patch|scale|rollout\s+restart)\b"; Reason = "Kubernetes mutations require explicit cluster/namespace approval." },
    @{ Name = "dotenv read"; Pattern = "(?i)(^|[\s;&|])(cat|type|Get-Content)\s+([^;&|]*\s+)?\.env(\s|$|\.)"; Reason = "Reading local environment files is blocked. Use .env.example or documented variable names instead." },
    @{ Name = "private key read"; Pattern = "(?i)(^|[\s;&|])(cat|type|Get-Content)\s+.*\.(pem|key)(\s|$)"; Reason = "Reading private key material is blocked." }
  )

  foreach ($rule in $rules) {
    if ($normalized -match $rule.Pattern) {
      return [ordered]@{
        Name = $rule.Name
        Reason = $rule.Reason
        Command = $normalized
      }
    }
  }

  return $null
}

$event = $null
$isHookInput = $false
$hookEventName = "PreToolUse"

if ([string]::IsNullOrWhiteSpace($ShellCommand)) {
  $rawInput = [Console]::In.ReadToEnd()
  if (-not [string]::IsNullOrWhiteSpace($rawInput)) {
    $isHookInput = $true
    try {
      $event = $rawInput | ConvertFrom-Json -ErrorAction Stop
      $hookEventName = Get-HookEventName -Event $event
      $ShellCommand = Get-CommandFromEvent -Event $event
      if ([string]::IsNullOrWhiteSpace($ShellCommand)) {
        $message = "Hook input did not contain a command field; app-dev policy could not evaluate it."
        ConvertTo-HookJson (New-ContextOutput -EventName $hookEventName -Message $message)
        exit 0
      }
    } catch {
      ConvertTo-HookJson ([ordered]@{
        decision = "block"
        reason = "Could not parse hook input JSON; failing closed."
      })
      exit 0
    }
  }
}

if ([string]::IsNullOrWhiteSpace($ShellCommand)) {
  Write-Error "No shell command supplied and no Codex hook JSON was provided."
}

$blocked = Test-BlockedCommand -CommandText $ShellCommand
if ($null -ne $blocked) {
  $reason = "Blocked by app-dev policy '$($blocked.Name)': $($blocked.Reason) Command: $($blocked.Command)"
  if ($isHookInput) {
    ConvertTo-HookJson (New-DenyOutput -EventName $hookEventName -Reason $reason)
    exit 0
  }

  Write-Error $reason
}

if (-not $isHookInput) {
  Write-Host "pre-command check passed"
}
