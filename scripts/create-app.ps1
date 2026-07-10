param(
  [Parameter(Mandatory=$true)]
  [ValidatePattern("^_*[a-z0-9][a-z0-9-]*$")]
  [string]$Name,

  [ValidateSet("react-vite-capacitor", "next-web-app", "expo-native-app")]
  [string]$Template = "react-vite-capacitor",

  [switch]$InitializeGit
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root "templates/$Template"
$target = Join-Path $root "projects/$Name"
$specTemplateDir = Join-Path $root "templates/spec-workflow"

if (-not (Test-Path -LiteralPath $source)) {
  Write-Error "Template not found: $source"
}

if (-not (Test-Path -LiteralPath $specTemplateDir)) {
  Write-Error "Spec workflow templates not found: $specTemplateDir"
}

if (Test-Path -LiteralPath $target) {
  Write-Error "Project already exists: $target"
}

New-Item -ItemType Directory -Force -Path $target | Out-Null
$excludedTemplateEntries = @(
  ".github",
  "node_modules",
  "dist",
  "coverage",
  "playwright-report",
  "test-results"
)

if ($Template -eq "react-vite-capacitor") {
  $excludedTemplateEntries += @("android", "ios")
}

Get-ChildItem -LiteralPath $source -Force | Where-Object {
  $excludedTemplateEntries -notcontains $_.Name
} | ForEach-Object {
  Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
}

$agentPath = Join-Path $target "AGENTS.md"
if (-not (Test-Path -LiteralPath $agentPath)) {
  Set-Content -LiteralPath $agentPath -Encoding UTF8 -Value @"
# $Name Codex Instructions

This project inherits the app-dev workspace standards.
Use this project's `PLAN.md` for architecture, module, risk, and verification decisions.

## Active Specification

- Start with `specs/001-initial/spec.md`.
- Create later feature specs under `specs/NNN-<slug>/`.
- Keep `PLAN.md`, `tasks.md`, and `workflow-receipts.md` aligned to the active spec before implementation starts.

## Verification

Use the scripts in package.json. Before completion, run available checks through:

````powershell
../../scripts/verify-app.ps1 -ProjectPath .
````

## Done When

- Active specification and task artifacts are current for the feature being built.
- `workflow-receipts.md` is current for any UI, data, mobile, or release-readiness work.
- `PLAN.md` is current for architecture, data model, auth, routing, deployment, migration, or multi-module work.
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` passes before completion.
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` passes before completion.
- Available checks pass through `../../scripts/verify-app.ps1 -ProjectPath .`.
- Missing scripts are reported instead of invented.
- UI changes include rendered desktop and mobile checks.
- Handoff notes record deviations, skipped checks, and unresolved decisions.
"@
}

$planPath = Join-Path $target "PLAN.md"
$templatePlanPath = Join-Path $root "templates/spec-workflow/PLAN.template.md"
if (-not (Test-Path -LiteralPath $planPath)) {
  if (-not (Test-Path -LiteralPath $templatePlanPath)) {
    Write-Error "Plan template not found: $templatePlanPath"
  }

  $planText = Get-Content -LiteralPath $templatePlanPath -Raw
  $planText = $planText.Replace("{{APP_NAME}}", $Name)
  $planText = $planText.Replace("{{TEMPLATE}}", $Template)
  $planText = $planText.Replace("{{DATE}}", (Get-Date -Format "yyyy-MM-dd"))
  $planText = $planText.Replace("TODO: state the outcome this app, feature, or workflow slice must deliver.", "Establish the initial app foundation, base shell, workflow receipts, and delivery constraints for $Name.")
  $planText = $planText.Replace("TODO: list explicit exclusions that prevent scope drift.", "Product-specific business workflows beyond the initial scaffold are out of scope for the initial plan.")
  $planText = $planText.Replace("TODO: state cost impact or why an exception is needed.", "No paid service usage is introduced by scaffold generation.")
  $planText = $planText.Replace("TODO: state whether work stays inside the root-tracked `projects/<app>` model.", "The app stays under `projects/$Name` in the root repository.")
  $planText = $planText.Replace("TODO: artifacts and checks required before completion.", "`AGENTS.md`, `PLAN.md`, `specs/001-initial/`, artifact checks, receipt validation, and app verification.")
  $planText = $planText.Replace("TODO: React/Vite/Capacitor, Next.js, Expo, or documented project-specific choice.", $Template)
  $planText = $planText.Replace("TODO: desktop web, mobile web, Android, iOS, CLI, or docs.", "Use the default platform set for $Template unless narrowed by a later spec.")
  $planText = $planText.Replace("TODO: Capacitor/Expo/native APIs or state none.", "None beyond the selected template baseline.")
  $planText = $planText.Replace("TODO: pages, routes, or states that require rendered verification.", "Initial app shell first meaningful screen and responsive baseline.")
  $planText = $planText.Replace("TODO: node/runtime expectations and package manager in use.", "Use the workspace-supported Node runtime and the package manager already defined by the generated template.")
  $planText = $planText.Replace("TODO: Supabase, APIs, storage, queues, or state none.", "None for the initial scaffold.")
  $planText = $planText.Replace("TODO: required env groups, local fallbacks, and secret handling boundaries.", "Use `.env.example` only; no live secrets are introduced by scaffold generation.")
  $planText = $planText.Replace("TODO: CI, device, browser, or deployment constraints that shape implementation.", "The scaffold must remain compatible with root CI, app-local verification scripts, and template baseline browser or device constraints.")
  $planText = $planText.Replace("TODO: route structure and navigation model.", "Use the selected template routing model.")
  $planText = $planText.Replace("TODO: client state, server state, validation, and cache decisions.", "Use the selected template defaults until product-specific specs refine them.")
  $planText = $planText.Replace("TODO: backend, auth, storage, and migration choices.", "No product backend, auth, or storage changes are introduced by the initial scaffold.")
  $planText = $planText.Replace("TODO: design system, component library, and token decisions.", "Use the workspace default design system and template styling conventions.")
  $planText = $planText.Replace("TODO: approvals, workflow constraints, and local standards that affect implementation.", "Follow numbered specs, workflow receipts, and local app-dev verification scripts.")
  $planText = $planText.Replace("| TODO: surface | TODO: module or layer | TODO: repo-relative paths | TODO: ownership boundary or coupling note |", "| App scaffold | App root and initial spec surfaces | `AGENTS.md`, `PLAN.md`, `specs/001-initial/`, template app entrypoints | Root governance owns templates and validators; the app owns product-specific follow-on work |")
  $planText = $planText.Replace("| TODO: module name | TODO: owned user workflow and data boundary | TODO: repo-relative files | TODO: focused checks |", "| App foundation | Initial shell, instructions, and verification baseline | `AGENTS.md`, `PLAN.md`, `specs/001-initial/`, template source files | `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, `../../scripts/verify-app.ps1 -ProjectPath .` |")
  $planText = $planText.Replace("TODO: entities, migrations, storage, or state none.", "None for product data; scaffold metadata is created in `specs/001-initial/`.")
  $planText = $planText.Replace("TODO: session, roles, RLS, or state none.", "None for the initial scaffold.")
  $planText = $planText.Replace("TODO: user, admin, file, device, or live-service permission impact.", "None for the initial scaffold.")
  $planText = $planText.Replace("TODO: database, local storage, files, object storage, or state none.", "No product storage; generated files are local repo artifacts.")
  $planText = $planText.Replace("TODO: destructive, credentialed, live-environment, or state none.", "None.")
  $planText = [regex]::Replace($planText, [regex]::Escape("TODO: required or not required, with reason."), "required for the initial app shell and scaffold evidence.", 1)
  $planText = [regex]::Replace($planText, [regex]::Escape("TODO: required or not required, with reason."), "not required; no product data change is introduced.", 1)
  $planText = [regex]::Replace($planText, [regex]::Escape("TODO: required or not required, with reason."), "not required unless the selected template's baseline mobile wrapper is explicitly validated.", 1)
  $planText = [regex]::Replace($planText, [regex]::Escape("TODO: required or not required, with reason."), "required to confirm generated-app readiness before handoff.", 1)
  $planText = $planText.Replace("TODO: exact package scripts or test files.", "Use the scripts defined by the selected template package.")
  $planText = $planText.Replace("TODO: yes/no.", "yes for templates with a rendered app shell.")
  $planText = $planText.Replace("TODO: route or state.", "Initial app shell route.")
  $planText = $planText.Replace("TODO: interaction or state transition.", "Initial navigation or shell interaction when present.")
  $planText = [regex]::Replace($planText, [regex]::Escape("TODO: viewport and expected result."), "Desktop viewport renders without clipped, overlapping, or overflowing text.", 1)
  $planText = [regex]::Replace($planText, [regex]::Escape("TODO: viewport and expected result."), "Mobile viewport renders without clipped, overlapping, or overflowing text.", 1)
  $planText = $planText.Replace("TODO: overflow, clipping, overlap, or state none.", "No known layout risk in the scaffold.")
  $planText = $planText.Replace("| TODO: risk or assumption | assumption | TODO: impact | TODO: mitigation or owner |", "| Later product scope is unknown | assumption | Initial artifacts may need refinement before real feature work | Create a new numbered spec before material product work |")
  $planText = $planText.Replace("TODO: low, medium, or high.", "low")
  $planText = $planText.Replace("TODO: list the unknowns that could change sequencing or scope.", "Product-specific modules, backend needs, and release criteria remain intentionally undefined.")
  $planText = $planText.Replace("TODO: smallest acceptable fallback if the preferred implementation stalls.", "Keep the generated scaffold and capture deferred product work in the next numbered spec.")
  $planText = $planText.Replace("TODO: how to recover from migration, deployment, or behavioral regression risk.", "Regenerate the app from the template or revert scaffold-only changes before product work begins.")
  $planText = $planText.Replace("TODO: accepted decision, reason, and date.", "Use $Template as the starting template for $Name on $(Get-Date -Format "yyyy-MM-dd").")
  $planText = $planText.Replace("TODO: rejected option and reason, or state none.", "None.")
  $planText = $planText.Replace("TODO: deferred decision, owner, and trigger to revisit, or state none.", "Product-specific modules, data, auth, and release decisions are deferred to later numbered specs.")
  $planText = $planText.Replace("TODO: state none or document accepted deviation.", "None.")
  $planText = $planText.Replace("TODO: state none or list next slice items.", "Create the first product-specific numbered spec before material app behavior changes.")
  Set-Content -LiteralPath $planPath -Encoding UTF8 -Value $planText
}

$initialSpecDir = Join-Path $target "specs/001-initial"
New-Item -ItemType Directory -Force -Path $initialSpecDir | Out-Null

$specReplacements = @{
  "{{SPEC_NUMBER}}" = "001"
  "{{SPEC_TITLE}}" = "Initial App Foundation"
  "{{SPEC_DIR}}" = "001-initial"
  "{{RISK_LEVEL}}" = "standard"
  "{{APP_NAME}}" = $Name
  "{{DATE}}" = (Get-Date -Format "yyyy-MM-dd")
}

foreach ($templateName in @("spec.template.md", "tasks.template.md", "workflow-receipts.template.md", "checklist.template.md")) {
  $sourcePath = Join-Path $specTemplateDir $templateName
  if (-not (Test-Path -LiteralPath $sourcePath)) {
    Write-Error "Spec workflow template not found: $sourcePath"
  }

  $targetName = $templateName.Replace(".template", "")
  $targetPath = Join-Path $initialSpecDir $targetName
  if (-not (Test-Path -LiteralPath $targetPath)) {
    $text = Get-Content -LiteralPath $sourcePath -Raw
    foreach ($entry in $specReplacements.GetEnumerator()) {
      $text = $text.Replace($entry.Key, $entry.Value)
    }
    if ($targetName -eq "spec.md") {
      $text = $text.Replace("TODO: quote or summarize the user request, ticket, audit item, or decision that created this spec.", "Initial scaffold generation for $Name from the $Template template.")
      $text = $text.Replace("TODO: state the user-visible outcome this feature or workflow slice must deliver.", "Establish the initial app foundation, base shell, workflow receipts, and delivery constraints for $Name.")
      $text = $text.Replace("TODO: state the user problem, workflow gap, or governance defect this slice addresses.", "Provide a concrete starting specification for the first generated version of $Name so implementation can proceed from a numbered spec instead of an empty placeholder.")
      $text = $text.Replace("TODO: short title", "Initial App Foundation")
      $text = $text.Replace("TODO: describe the independently valuable journey or vertical increment in plain language.", "Developers and operators can start from a runnable scaffold with durable spec, plan, task, and receipt artifacts.")
      $text = $text.Replace("TODO: explain why this is the first slice.", "The foundation must exist before product-specific modules can be planned or implemented.")
      $text = $text.Replace("TODO: describe how this story can be verified by itself.", "Confirm the app contains aligned AGENTS, PLAN, and specs/001-initial artifacts and can run the available scaffold checks.")
      $text = $text.Replace("TODO: initial state", "a new app is generated")
      $text = $text.Replace("TODO: user or agent action", "the scaffold artifacts are inspected")
      $text = $text.Replace("TODO: observable result", "AGENTS.md, PLAN.md, tasks.md, and workflow-receipts.md all point to the same initial spec")
      $text = $text.Replace("TODO: alternate state", "dependencies and local tooling are available")
      $text = $text.Replace("TODO: action", "the scaffold checks are run")
      $text = $text.Replace("TODO: remove this section when the feature has only one independently testable slice.", "No second user story is required for scaffold generation.")
      $text = $text.Replace("TODO: explain priority or remove.", "Not applicable.")
      $text = $text.Replace("TODO: describe standalone verification or remove.", "Not applicable.")
      $text = $text.Replace("TODO: boundary condition or state none.", "No product-specific modules exist yet.")
      $text = $text.Replace("TODO: failure, empty, permission, offline, or conflict scenario or state none.", "Missing dependencies are reported as setup blockers rather than invented commands.")
      $text = $text.Replace("TODO: system or workflow MUST provide a concrete, testable capability.", "The generated app MUST include a runnable base shell and durable instructions required to continue work from numbered specs.")
      $text = $text.Replace("TODO: system or workflow MUST provide a second concrete, testable capability.", "The generated app MUST define verification and planning hooks before feature-specific implementation begins.")
      $text = $text.Replace("TODO: Entity or artifact name", "Initial scaffold artifacts")
      $text = $text.Replace("TODO: describe the entity, durable artifact, or state affected by this feature. Use ""None"" when not applicable.", "AGENTS.md, PLAN.md, specs/001-initial/spec.md, tasks.md, workflow-receipts.md, and checklist.md.")
      $text = $text.Replace("TODO: measurable or observable success condition independent of implementation details.", "The app contains AGENTS, PLAN, and specs/001-initial artifacts that all point to the same initial feature context.")
      $text = $text.Replace("TODO: second measurable or observable success condition.", "The initial scaffold can pass spec artifact validation once dependencies and checks are available.")
      $text = $text.Replace("TODO: affected entities, fields, migrations, or state none.", "No product entities yet; this feature establishes shell, route, and workflow metadata.")
      $text = $text.Replace("TODO: roles, access rules, RLS, local file access, or state none.", "No app-specific roles yet; later feature specs must define access rules before sensitive workflows are added.")
      $text = $text.Replace("TODO: destructive actions, credentials, live services, or state none.", "None.")
      $text = $text.Replace("TODO: desktop web, mobile web, Android, iOS, CLI, docs, or another explicit set.", "Use the default platform set for $Template unless the app narrows scope later.")
      $text = $text.Replace("TODO: empty, loading, error, success, offline, or state none.", "The app shell must preserve the template empty, loading, error, and success state patterns.")
      $text = $text.Replace("TODO: device APIs, app-store packaging, or state none.", "None beyond the selected template baseline.")
      $text = $text.Replace("TODO: desktop/mobile viewport expectations or state not applicable.", "Rendered desktop and mobile checks are expected when the template defines browser behavior.")
      $text = $text.Replace("TODO: reasonable default chosen because the request did not specify it.", "Product-specific behavior is deferred to later numbered specs.")
      $text = $text.Replace("TODO: delivery, correctness, security, data, platform, or workflow risk.", "The main risk is drifting away from the scaffolded workflow before the first real feature spec is created.")
      $text = $text.Replace("TODO: unresolved decision or state none.", "None for scaffold generation; product-specific decisions belong in later specs.")
      $text = $text.Replace("TODO: first meaningful screen, core interaction, desktop viewport, and mobile viewport when UI work is in scope, or state not applicable.", "Use rendered desktop and mobile checks for templates that define browser UI; otherwise state not applicable.")
    }
    if ($targetName -eq "tasks.md") {
      $text = $text.Replace("TODO: short title", "Initial App Foundation")
      $text = $text.Replace("TODO: summarize independently valuable outcome.", "Confirm the scaffold has aligned app instructions, plan, spec, tasks, receipts, and verification hooks.")
      $text = $text.Replace("TODO: describe focused verification for this story.", "Run spec artifact validation and the available app verification wrapper after dependencies are available.")
      $text = $text.Replace("TODO: action in TODO: exact repo-relative path.", "confirm the initial app shell in `src/` or the selected template entrypoint.")
      $text = $text.Replace("TODO: behavior in TODO: exact repo-relative path.", "the initial scaffold behavior in the template test files.")
    }
    if ($targetName -eq "workflow-receipts.md") {
      $text = $text.Replace("- [ ] UI workflow required", "- [x] UI workflow required")
      $text = $text.Replace("- [ ] Release-readiness workflow required", "- [x] Release-readiness workflow required")
      $text = $text.Replace("TODO: explain why each required workflow is required or state none.", "UI is required for the generated app shell; release-readiness is required for scaffold handoff; data and mobile are deferred unless a later spec requires them.")
      $text = $text.Replace("- Trigger surface: none", "- Trigger surface: initial scaffold and app shell")
      $text = $text.Replace("- Command path used: none", "- Command path used: scaffold generation")
      $text = $text.Replace("- Files/surfaces reviewed: none", "- Files/surfaces reviewed: AGENTS.md, PLAN.md, specs/001-initial/")
      $text = $text.Replace("- Implementation evidence: none", "- Implementation evidence: generated scaffold artifacts")
      $text = $text.Replace("- Verification commands: not-run", "- Verification commands: check-spec-artifacts and verify-app planned")
      $text = $text.Replace("- Verification result: not-run", "- Verification result: planned")
      $text = $text.Replace("- Decision/closure: not-applicable", "- Decision/closure: deferred")
    }
    Set-Content -LiteralPath $targetPath -Encoding UTF8 -Value $text
  }
}

$required = @("package.json", "AGENTS.md", "PLAN.md", "specs/001-initial/spec.md", "specs/001-initial/tasks.md", "specs/001-initial/workflow-receipts.md", "specs/001-initial/checklist.md")
if ($Template -eq "react-vite-capacitor") {
  $required += @(".env.example", "index.html", "src/main.tsx")
}

foreach ($item in $required) {
  $path = Join-Path $target $item
  if (-not (Test-Path -LiteralPath $path)) {
    Write-Error "Generated project is missing required file: $item"
  }
}

if ($InitializeGit) {
  Push-Location $target
  try {
    git init | Out-Host
    if ($LASTEXITCODE -ne 0) {
      Write-Error "git init failed with exit code $LASTEXITCODE"
    }
  } finally {
    Pop-Location
  }
}

Write-Host "Created $Name from $Template at $target"
Write-Host "Next: review $agentPath, $planPath, and specs/001-initial/, install dependencies inside the project, then run ../../scripts/check-spec-artifacts.ps1 -ProjectPath ., ../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence, and ../../scripts/verify-app.ps1 -ProjectPath ."
