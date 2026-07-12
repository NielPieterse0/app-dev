param(
  [Parameter(Mandatory=$true)][string]$ProjectPath,
  [Parameter(Mandatory=$true)][string]$SpecDir,
  [string[]]$ChangedFiles = @(),
  [string]$Phase = "implement",
  [switch]$Markdown,
  [switch]$JsonSummary
)

$ErrorActionPreference = "Stop"
$commonPath = Join-Path $PSScriptRoot "common.ps1"
. $commonPath

function Add-UniqueValue {
  param(
    [Parameter(Mandatory=$true)]$List,
    [Parameter(Mandatory=$true)][string]$Value
  )

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return
  }
  if (-not ($List -contains $Value)) {
    $List.Add($Value) | Out-Null
  }
}

function Normalize-RelativePath {
  param(
    [Parameter(Mandatory=$true)][string]$BasePath,
    [Parameter(Mandatory=$true)][string]$Candidate
  )

  $candidatePath = $Candidate
  if (-not [System.IO.Path]::IsPathRooted($candidatePath)) {
    $candidatePath = Join-Path $BasePath $candidatePath
  }

  try {
    $resolvedCandidate = [System.IO.Path]::GetFullPath($candidatePath)
    $resolvedBase = [System.IO.Path]::GetFullPath($BasePath)
    if ($resolvedCandidate.StartsWith($resolvedBase, [System.StringComparison]::OrdinalIgnoreCase)) {
      return ($resolvedCandidate.Substring($resolvedBase.Length).TrimStart('/', '\') -replace "\\", "/")
    }
  } catch {
  }

  return ($Candidate -replace "\\", "/")
}

function Invoke-GitNameOnlyDiff {
  param([string[]]$Arguments = @())

  $output = & git -c core.safecrlf=false -c core.autocrlf=false diff --name-only @Arguments 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "git diff failed while collecting changed files for applicable-standard selection."
  }

  return @($output)
}

function Invoke-GitUntrackedFiles {
  $output = & git -c core.safecrlf=false -c core.autocrlf=false ls-files --others --exclude-standard 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "git ls-files failed while collecting changed files for applicable-standard selection."
  }

  return @($output)
}

function Get-GitChangedFiles {
  param([Parameter(Mandatory=$true)][string]$BasePath)

  $results = New-Object System.Collections.Generic.List[string]
  foreach ($arguments in @(@("--cached"), @())) {
    foreach ($line in @(Invoke-GitNameOnlyDiff -Arguments $arguments)) {
      if (-not [string]::IsNullOrWhiteSpace($line)) {
        $results.Add($line) | Out-Null
      }
    }
  }

  foreach ($line in @(Invoke-GitUntrackedFiles)) {
    if (-not [string]::IsNullOrWhiteSpace($line)) {
      $results.Add($line) | Out-Null
    }
  }

  return @($results | Select-Object -Unique)
}

function Get-SeverityRank {
  param([string]$Severity)

  switch (([string]$Severity).Trim().ToLowerInvariant()) {
    "critical" { return 0 }
    "high" { return 1 }
    "medium" { return 2 }
    "advisory" { return 3 }
    default { return 4 }
  }
}

function Add-PathSignals {
  param(
    [Parameter(Mandatory=$true)][string]$RelativePath,
    [Parameter(Mandatory=$true)]$Surfaces,
    [Parameter(Mandatory=$true)]$Triggers
  )

  $path = $RelativePath -replace "\\", "/"
  if ($path -match '^\.agents/commands/') {
    foreach ($surface in @("commands", "workflow", "docs")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("command-change", "workflow-change", "governance-change")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($path -match '^\.agents/commands/analyze\.md$') {
    foreach ($surface in @("analysis", "commands")) { Add-UniqueValue -List $Surfaces -Value $surface }
    Add-UniqueValue -List $Triggers -Value "analyze-command"
  }
  if ($path -match '^\.agents/commands/implement\.md$') {
    foreach ($surface in @("implementation", "commands")) { Add-UniqueValue -List $Surfaces -Value $surface }
    Add-UniqueValue -List $Triggers -Value "implement-command"
  }
  if ($path -match '^\.agents/commands/converge\.md$') {
    foreach ($surface in @("convergence", "commands", "handoff")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("converge-command", "convergence", "post-implementation")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($path -match '^\.agents/commands/verify\.md$') {
    foreach ($surface in @("verify", "verification", "commands")) { Add-UniqueValue -List $Surfaces -Value $surface }
    Add-UniqueValue -List $Triggers -Value "verify-command"
  }
  if ($path -match '^\.agents/skills/') {
    foreach ($surface in @("skills", "workflow", "docs")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("skill-change", "workflow-change", "governance-change")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($path -match '^standards/registry/') {
    foreach ($surface in @("standards", "validators", "docs")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("registry-change", "standard-change", "validator-change", "governance-change")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($path -match '^standards/') {
    foreach ($surface in @("standards", "docs")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("standard-change", "docs-change", "governance-change")) { Add-UniqueValue -List $Triggers -Value $trigger }
    if ($path -match 'spec-driven-workflow\.md$') {
      foreach ($surface in @("workflow", "specs", "tasks", "plans", "workflow-receipts")) { Add-UniqueValue -List $Surfaces -Value $surface }
      Add-UniqueValue -List $Triggers -Value "workflow-change"
    }
    if ($path -match 'command-workflow-contract\.md$') {
      foreach ($surface in @("commands", "workflow", "workflow-receipts")) { Add-UniqueValue -List $Surfaces -Value $surface }
      Add-UniqueValue -List $Triggers -Value "command-change"
    }
  }
  if ($path -match '^templates/spec-workflow/') {
    foreach ($surface in @("templates", "specs", "tasks", "plans", "workflow-receipts", "checklists")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("template-change", "artifact-generation", "governance-change")) { Add-UniqueValue -List $Triggers -Value $trigger }
    if ($path -match 'workflow-receipts\.template\.md$') {
      Add-UniqueValue -List $Triggers -Value "receipt-change"
    }
  }
  if ($path -match '^scripts/') {
    foreach ($surface in @("scripts", "validators")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("script-change", "governance-change")) { Add-UniqueValue -List $Triggers -Value $trigger }
    if ($path -match '/?(validate|check|test|get-).+\.ps1$') {
      Add-UniqueValue -List $Triggers -Value "validator-change"
    }
  }
  if ($path -match '^src/(components|app|routes)/|^src/modules/[^/]+/(components|routes)/|\.css$|components\.json$') {
    foreach ($surface in @("ui", "apps")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("ui-change", "frontend-change", "rendered-verification")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($path -match '^supabase/|\.sql$|^src/modules/[^/]+/(schemas|services)/') {
    foreach ($surface in @("data", "database", "migrations", "apps")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("data-change", "database", "migration")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($path -match '^android/|^ios/|^capacitor\.config\.') {
    foreach ($surface in @("mobile", "apps")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("mobile-validation", "capacitor-change", "native-feature")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($path -match 'workflow-receipts\.md$') {
    Add-UniqueValue -List $Surfaces -Value "workflow-receipts"
    Add-UniqueValue -List $Triggers -Value "receipt-change"
  }
  if ($path -match 'checklist\.md$') {
    Add-UniqueValue -List $Surfaces -Value "checklists"
    Add-UniqueValue -List $Triggers -Value "checklist"
  }
  if ($path -match 'tasks\.md$') {
    Add-UniqueValue -List $Surfaces -Value "tasks"
    Add-UniqueValue -List $Triggers -Value "tasks-change"
  }
  if ($path -match 'plan\.md$|plan\.template\.md$|PLAN\.template\.md$') {
    Add-UniqueValue -List $Surfaces -Value "plans"
    Add-UniqueValue -List $Triggers -Value "plan-change"
  }
  if ($path -match 'spec\.md$') {
    Add-UniqueValue -List $Surfaces -Value "specs"
    Add-UniqueValue -List $Triggers -Value "spec-change"
  }
}

function Add-TextSignals {
  param(
    [Parameter(Mandatory=$true)][string]$Content,
    [Parameter(Mandatory=$true)]$Surfaces,
    [Parameter(Mandatory=$true)]$Triggers
  )

  if ($Content -match '(?i)UI workflow required|Rendered UI|desktop viewport|mobile viewport') {
    Add-UniqueValue -List $Surfaces -Value "ui"
    foreach ($trigger in @("ui-change", "rendered-verification")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($Content -match '(?i)Data workflow required|Supabase|migration|RLS|schema|database') {
    foreach ($surface in @("data", "database", "migrations")) { Add-UniqueValue -List $Surfaces -Value $surface }
    foreach ($trigger in @("data-change", "database", "migration", "rls")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($Content -match '(?i)Mobile workflow required|Capacitor|Android|iOS|native') {
    Add-UniqueValue -List $Surfaces -Value "mobile"
    foreach ($trigger in @("mobile-validation", "capacitor-change")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($Content -match '(?i)Release-readiness workflow required|deploy|live migration|rollback|approval') {
    Add-UniqueValue -List $Surfaces -Value "release-readiness"
    foreach ($trigger in @("release-readiness", "deployment", "live-migration", "approval")) { Add-UniqueValue -List $Triggers -Value $trigger }
  }
  if ($Content -match '(?i)\bauth\b|\bpayment|\bsecret|\bpublic api\b|\bupload\b|\bAI tool action\b') {
    foreach ($trigger in @("auth", "payments", "secrets", "public-api", "file-upload", "ai-tool-action", "gated-risk")) {
      Add-UniqueValue -List $Triggers -Value $trigger
    }
  }

  $pathPattern = '(?im)(?:^|[`(\s])((?:\.agents|scripts|standards|templates|src|supabase|android|ios|projects)/[A-Za-z0-9_./-]+)'
  foreach ($match in [regex]::Matches($Content, $pathPattern)) {
    Add-PathSignals -RelativePath $match.Groups[1].Value -Surfaces $Surfaces -Triggers $Triggers
  }
}

function Test-AutomationMatch {
  param(
    [Parameter(Mandatory=$true)]$Rule,
    [Parameter(Mandatory=$true)][string[]]$ChangedFiles
  )

  if ($null -eq $Rule.automation -or $null -eq $Rule.automation.current) {
    return $false
  }

  foreach ($automationPath in @($Rule.automation.current)) {
    $normalizedAutomation = ([string]$automationPath) -replace "\\", "/"
    foreach ($changedFile in $ChangedFiles) {
      $normalizedChanged = ([string]$changedFile) -replace "\\", "/"
      if ($normalizedChanged -eq $normalizedAutomation -or $normalizedChanged.EndsWith($normalizedAutomation, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
      }
    }
  }

  return $false
}

$ProjectPath = Resolve-ProjectPath -ProjectPath $ProjectPath
$specToken = $SpecDir -replace "\\", "/"
$resolvedSpecDir = $null
if ([System.IO.Path]::IsPathRooted($specToken)) {
  $resolvedSpecDir = if (($specToken -replace "\\", "/").EndsWith("/spec.md")) { Split-Path -Parent $specToken } else { $specToken }
} else {
  $relativeSpecDir = if ($specToken -match '/spec\.md$') { Split-Path -Parent $specToken } else { $specToken }
  $resolvedSpecDir = Join-Path $ProjectPath $relativeSpecDir
}

if (-not (Test-Path -LiteralPath $resolvedSpecDir)) {
  throw "Spec directory does not exist: $resolvedSpecDir"
}

if (-not $ChangedFiles -or $ChangedFiles.Count -eq 0) {
  Push-Location $ProjectPath
  try {
    $ChangedFiles = Get-GitChangedFiles -BasePath $ProjectPath
  } finally {
    Pop-Location
  }
}

$normalizedChangedFiles = @(
  $ChangedFiles |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    ForEach-Object { Normalize-RelativePath -BasePath $ProjectPath -Candidate $_ } |
    Sort-Object -Unique
)

$artifactContents = New-Object System.Collections.Generic.List[string]
foreach ($relativeName in @("spec.md", "plan.md", "tasks.md", "workflow-receipts.md", "checklist.md")) {
  $artifactPath = Join-Path $resolvedSpecDir $relativeName
  if (Test-Path -LiteralPath $artifactPath) {
    $artifactContents.Add((Get-Content -LiteralPath $artifactPath -Raw)) | Out-Null
  }
}
$combinedContent = $artifactContents -join "`n"

$surfaces = New-Object System.Collections.Generic.List[string]
$triggers = New-Object System.Collections.Generic.List[string]
foreach ($path in $normalizedChangedFiles) {
  Add-PathSignals -RelativePath $path -Surfaces $surfaces -Triggers $triggers
}
Add-TextSignals -Content $combinedContent -Surfaces $surfaces -Triggers $triggers

$registryRoot = Join-Path (Split-Path -Parent $PSScriptRoot) "standards/registry"
$registryFiles = Get-ChildItem -LiteralPath $registryRoot -Filter "*.rules.json" | Sort-Object Name
$selectedRules = New-Object System.Collections.Generic.List[object]

foreach ($registryFile in $registryFiles) {
  $registry = Get-Content -LiteralPath $registryFile.FullName -Raw | ConvertFrom-Json -ErrorAction Stop
  $sourceFile = ([string]$registry.standard.source_file) -replace "\\", "/"

  foreach ($rule in @($registry.rules)) {
    $phases = @($rule.phases | ForEach-Object { ([string]$_).Trim().ToLowerInvariant() })
    if ($phases.Count -gt 0 -and (([string]$Phase).Trim().ToLowerInvariant() -notin $phases)) {
      continue
    }

    $score = 0
    $matchedSurfaces = @()
    $matchedTriggers = @()

    foreach ($surface in @($rule.applies_to)) {
      $normalizedSurface = ([string]$surface).Trim().ToLowerInvariant()
      if ($normalizedSurface -in @($surfaces | ForEach-Object { ([string]$_).Trim().ToLowerInvariant() })) {
        $score += 2
        $matchedSurfaces += [string]$surface
      }
    }

    foreach ($trigger in @($rule.trigger_kinds)) {
      $normalizedTrigger = ([string]$trigger).Trim().ToLowerInvariant()
      if ($normalizedTrigger -in @($triggers | ForEach-Object { ([string]$_).Trim().ToLowerInvariant() })) {
        $score += 2
        $matchedTriggers += [string]$trigger
      }
    }

    if ($sourceFile -and ($sourceFile -in $normalizedChangedFiles)) {
      $score += 1
    }
    if (Test-AutomationMatch -Rule $rule -ChangedFiles $normalizedChangedFiles) {
      $score += 1
    }

    if ($score -lt 2) {
      continue
    }

    $selectedRules.Add([pscustomobject]@{
      registry = $registryFile.Name
      standard = $registry.standard.id
      source_file = $registry.standard.source_file
      id = $rule.id
      standard_reference = $rule.standard_reference
      section = $rule.section
      title = $rule.title
      severity = $rule.severity
      phases = @($rule.phases)
      enforcement_mode = $rule.enforcement_mode
      applies_to = @($rule.applies_to)
      trigger_kinds = @($rule.trigger_kinds)
      matched_surfaces = @($matchedSurfaces | Sort-Object -Unique)
      matched_triggers = @($matchedTriggers | Sort-Object -Unique)
      status = if (([string]$rule.severity).Trim().ToLowerInvariant() -in @("critical", "high")) { "deferred" } else { "not-applicable" }
      evidence = if (([string]$rule.severity).Trim().ToLowerInvariant() -in @("critical", "high")) { "pending implementation evidence" } else { "not selected for mandatory implementation evidence" }
      reason_or_next_action = if (([string]$rule.severity).Trim().ToLowerInvariant() -in @("critical", "high")) { "pending implementation review and receipt update" } else { "record only if the rule becomes applicable during execution" }
    }) | Out-Null
  }
}

$selectedRules = @(
  $selectedRules |
    Sort-Object @{ Expression = { Get-SeverityRank -Severity $_.severity } }, @{ Expression = { $_.id } } |
    Group-Object id |
    ForEach-Object { $_.Group[0] }
)

$result = [ordered]@{
  projectPath = $ProjectPath
  specDir = Normalize-RelativePath -BasePath $ProjectPath -Candidate $resolvedSpecDir
  phase = $Phase
  changedFiles = @($normalizedChangedFiles)
  surfaces = @($surfaces | Sort-Object -Unique)
  triggerKinds = @($triggers | Sort-Object -Unique)
  registryFilesReviewed = @($registryFiles.Name)
  selectedRules = @($selectedRules)
}

if ($Markdown) {
  if ($selectedRules.Count -eq 0) {
    "| none | none | none | not-applicable | none | no applicable rules selected yet |"
    exit 0
  }

  foreach ($rule in $selectedRules) {
    "| {0} | {1} | {2} | {3} | {4} | {5} |" -f $rule.id, $rule.standard_reference, $rule.severity, $rule.status, $rule.evidence, $rule.reason_or_next_action
  }
  exit 0
}

if ($JsonSummary) {
  $result | ConvertTo-Json -Depth 8
  exit 0
}

$result | ConvertTo-Json -Depth 8
