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
# $Name App Instructions

This file defines the durable app contract for this project.

Keep feature-specific requirements, scenarios, risks, tasks, workflow receipts, and completion criteria in `specs/NNN-<slug>/`.

Follow the root `app-dev/AGENTS.md` standards.

## Active Specification

- Active spec: `specs/001-initial/spec.md` until a later spec becomes active.
- Start new work by creating or updating a numbered spec with `/specify`.
- The first feature spec should live under `specs/001-initial/`.
- Later feature specs live under `specs/NNN-<slug>/`.

## App Type

- Template: $Template

## App Identity

- Users: replace with the target audience when establishing the app identity.
- Core jobs: replace with the primary user jobs the app will support.
- Platforms: replace with the supported platforms for this app.
- Repository model: generated apps remain tracked in the root `app-dev` repository unless a later recorded decision splits them out.

## Durable Constraints

- Cross-module imports use the target module public surface only: `@/modules/<module>`.
- Do not place app dependencies at the workspace root; keep them inside this project.
- Do not store secrets, private keys, service-role keys, or `.env` files in the repository.
- Document required public environment variables in `.env.example`.

## Platform Constraints

- Native requirements: replace with the native requirements for this app type.
- Add native platform folders and native APIs only after an active spec explicitly requires them.

## Verification Baseline

- Run the app's available verification commands through `../../scripts/verify-app.ps1 -ProjectPath .`.
- If a required script is missing, report the missing script instead of inventing commands.
- UI changes require rendered verification on the relevant supported surfaces.
"@
}

$initialSpecDir = Join-Path $target "specs/001-initial"
New-Item -ItemType Directory -Force -Path $initialSpecDir | Out-Null

$planPath = Join-Path $initialSpecDir "plan.md"
$templatePlanPath = Join-Path $root "templates/spec-workflow/plan.template.md"
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
  $planText = $planText.Replace("TODO: artifacts and checks required before completion.", "`AGENTS.md`, `specs/001-initial/plan.md`, `specs/001-initial/`, artifact checks, receipt validation, and app verification.")
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
  $planText = $planText.Replace("TODO: ordering, shared-surface, or same-file constraints that implementation must respect.", "Complete scaffold alignment and verification-baseline work before product-specific module changes; keep shared scaffold surfaces sequential until a later spec narrows ownership.")
  $planText = $planText.Replace("TODO: governed docs, standards, commands, templates, or scripts that must be reconciled during implementation to prevent drift.", "Keep AGENTS, plan, tasks, workflow receipts, verification guidance, and any touched governed workspace docs aligned in the same slice.")
  $planText = $planText.Replace("| TODO: surface | TODO: module or layer | TODO: repo-relative paths | TODO: ownership boundary or coupling note |", "| App scaffold | App root and initial spec surfaces | `AGENTS.md`, `specs/001-initial/plan.md`, `specs/001-initial/`, template app entrypoints | Root governance owns templates and validators; the app owns product-specific follow-on work |")
  $planText = $planText.Replace("| TODO: module name | TODO: owned user workflow and data boundary | TODO: repo-relative files | TODO: focused checks |", "| App foundation | Initial shell, instructions, and verification baseline | `AGENTS.md`, `specs/001-initial/plan.md`, `specs/001-initial/`, template source files | `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, `../../scripts/verify-app.ps1 -ProjectPath .` |")
  $planText = $planText.Replace("TODO: entities, migrations, storage, or state none.", "None for product data; scaffold metadata is created in `specs/001-initial/`.")
  $planText = $planText.Replace("TODO: session, roles, RLS, or state none.", "None for the initial scaffold.")
  $planText = $planText.Replace("TODO: user, admin, file, device, or live-service permission impact.", "None for the initial scaffold.")
  $planText = $planText.Replace("TODO: database, local storage, files, object storage, or state none.", "No product storage; generated files are local repo artifacts.")
  $planText = $planText.Replace("TODO: destructive, credentialed, live-environment, or state none.", "None.")
  $planText = $planText.Replace("TODO: exact package scripts or test files.", "Use the scripts defined by the selected template package.")
  $planText = $planText.Replace('TODO: exact checks to run during implementation before `/converge` and `/verify`.', 'Run artifact validation before convergence handoff and the available template verification wrapper as soon as dependencies are installed.')
  $planText = $planText.Replace("TODO: yes/no.", "yes for templates with a rendered app shell.")
  $planText = $planText.Replace("TODO: route or state.", "Initial app shell route.")
  $planText = $planText.Replace("TODO: interaction or state transition.", "Initial navigation or shell interaction when present.")
  $planText = $planText.Replace("TODO: overflow, clipping, overlap, or state none.", "No known layout risk in the scaffold.")
  $planText = $planText.Replace("| TODO: risk or assumption | assumption | TODO: impact | TODO: mitigation or owner |", "| Later product scope is unknown | assumption | Initial artifacts may need refinement before real feature work | Create a new numbered spec before material product work |")
  $planText = $planText.Replace("TODO: low, medium, or high.", "low")
  $planText = $planText.Replace('TODO: what must already be true before `/implement` starts.', 'AGENTS, plan, spec, tasks, receipts, and verification guidance stay aligned to `specs/001-initial/`, and scaffold dependencies are installed when code verification begins.')
  $planText = $planText.Replace("TODO: list the unknowns that could change sequencing or scope.", "Product-specific modules, backend needs, and release criteria remain intentionally undefined.")
  $planText = $planText.Replace("TODO: smallest acceptable fallback if the preferred implementation stalls.", "Keep the generated scaffold and capture deferred product work in the next numbered spec.")
  $planText = $planText.Replace("TODO: how to recover from migration, deployment, or behavioral regression risk.", "Regenerate the app from the template or revert scaffold-only changes before product work begins.")
  $planText = $planText.Replace("TODO: accepted decision, reason, and date.", "Use $Template as the starting template for $Name on $(Get-Date -Format "yyyy-MM-dd").")
  $planText = $planText.Replace("TODO: rejected option and reason, or state none.", "None.")
  $planText = $planText.Replace("TODO: deferred decision, owner, and trigger to revisit, or state none.", "Product-specific modules, data, auth, and release decisions are deferred to later numbered specs.")
  $planText = $planText.Replace("TODO: state none or document accepted deviation.", "None.")
  $planText = $planText.Replace("TODO: state none or list next slice items.", "Create the first product-specific numbered spec before material app behavior changes.")
  $planText = [regex]::Replace($planText, '(?m)^- Same-repo impact: TODO: .+$', ('- Same-repo impact: The app stays under `projects/' + $Name + '` in the root repository.'))
  $planText = [regex]::Replace($planText, '(?m)^- Workflow shape: TODO: .+$', '- Workflow shape: lean.')
  $planText = [regex]::Replace($planText, '(?m)^- UI workflow: TODO: .+$', '- UI workflow: required for the initial app shell and scaffold evidence.')
  $planText = [regex]::Replace($planText, '(?m)^- Data workflow: TODO: .+$', '- Data workflow: not required; no product data change is introduced.')
  $planText = [regex]::Replace($planText, '(?m)^- Mobile workflow: TODO: .+$', '- Mobile workflow: not required unless the selected template''s baseline mobile wrapper is explicitly validated.')
  $planText = [regex]::Replace($planText, '(?m)^- Release-readiness workflow: TODO: .+$', '- Release-readiness workflow: required to confirm generated-app readiness before handoff.')
  $planText = [regex]::Replace($planText, '(?m)^- Workflow-specific implementation requirements: TODO: .+$', '- Workflow-specific implementation requirements: Keep UI and release-readiness receipt obligations current during implementation; data and mobile implementation obligations remain deferred unless a later spec requires them.')
  $planText = [regex]::Replace($planText, '(?m)^- Desktop viewport: TODO: .+$', '- Desktop viewport: Desktop viewport renders without clipped, overlapping, or overflowing text.')
  $planText = [regex]::Replace($planText, '(?m)^- Mobile viewport: TODO: .+$', '- Mobile viewport: Mobile viewport renders without clipped, overlapping, or overflowing text.')
  if ($planText -match "TODO:|\{\{") {
    $remainingPlaceholderLines = [regex]::Matches($planText, '(?m)^.*(?:TODO:|\{\{).*$') | ForEach-Object { $_.Value.Trim() }
    Write-Error ("Generated plan template still contains unresolved placeholders after scaffold replacement:`n" + ($remainingPlaceholderLines -join "`n"))
  }
  Set-Content -LiteralPath $planPath -Encoding UTF8 -Value $planText
}

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
      $text = @"
# 001 Initial App Foundation Specification

- Status: draft
- Risk level: standard
- App: $Name
- Created: $(Get-Date -Format "yyyy-MM-dd")
- Input/source request: Initial scaffold generation for $Name from the $Template template.

## Summary

Establish the initial app foundation, base shell, workflow artifacts, and delivery constraints for $Name.

## Problem

Provide a concrete starting specification for the first generated version of $Name so implementation can proceed from a numbered spec instead of an empty placeholder.

## Scope

### In Scope

- Generated app instructions, app identity placeholders, and initial verification guidance.
- Initial numbered workflow artifacts under `specs/001-initial/`.
- Template shell behavior and baseline responsive verification expectations.

### Out Of Scope

- Product-specific business workflows, modules, and backend requirements.
- Production auth, data model, storage, and release policy decisions.
- Any feature work beyond the selected scaffold baseline.

## User Scenarios And Testing

### User Story 1 - Initial App Foundation (Priority: P1)

Developers and operators can start from a runnable scaffold with durable spec, plan, task, receipt, and verification artifacts.

**Why this priority**: The foundation must exist before product-specific modules can be planned or implemented.

**Independent Test**: Confirm the app contains aligned AGENTS, plan, and `specs/001-initial/` artifacts and can run the available scaffold checks once dependencies are installed.

**Acceptance Scenarios**:

1. **Given** a new app is generated, **When** the scaffold artifacts are inspected, **Then** AGENTS, plan, spec, tasks, receipts, and checklist artifacts align to the same initial spec.
2. **Given** dependencies and local tooling are available, **When** the scaffold checks are run, **Then** the generated app can complete the governed artifact and workflow validations.

## Edge Cases

- No product-specific modules exist yet, so the scaffold must stay generic without inventing domain behavior.
- Missing dependencies or local tooling are reported as setup blockers rather than hidden behind invented commands.

## Requirements

### Functional Requirements

- **FR-001**: The generated app MUST include a runnable base shell and durable instructions required to continue work from numbered specs.
- **FR-002**: The generated app MUST define planning, tasking, workflow-receipt, and verification hooks before feature-specific implementation begins.
- **FR-003**: The generated app MUST keep the initial workflow artifacts aligned to `specs/001-initial/` until a later spec becomes active.

### Key Entities

- **Initial scaffold artifacts**: AGENTS.md, `specs/001-initial/plan.md`, `specs/001-initial/spec.md`, `specs/001-initial/tasks.md`, `specs/001-initial/workflow-receipts.md`, and `specs/001-initial/checklist.md`.

## Success Criteria

### Measurable Outcomes

- **SC-001**: The app contains AGENTS, plan, and `specs/001-initial/` artifacts that all point to the same initial feature context.
- **SC-002**: The initial scaffold can pass spec artifact and workflow validation once dependencies and local checks are available.
- **SC-003**: The scaffold exposes the selected template shell and verification surfaces without unresolved template placeholders.

## Data, Permissions, And Security

- Data impact: No product entities yet; this slice establishes shell, route, and workflow metadata only.
- Permissions and access: No app-specific roles yet; later feature specs must define access rules before sensitive workflows are added.
- Sensitive operations: None.

## UX And Platform Notes

- Target surfaces: Use the default platform set for $Template unless the app narrows scope later.
- User states: The app shell must preserve the template empty, loading, error, and success state patterns.
- Native or platform needs: None beyond the selected template baseline.
- Rendered verification intent: Rendered desktop and mobile checks are expected when the template defines browser behavior.

## Assumptions

- Product-specific behavior is deferred to later numbered specs.

## Risks And Open Questions

### Risks

- The main risk is drifting away from the scaffolded workflow before the first real feature spec is created.

### Open Questions

- None for scaffold generation; product-specific decisions belong in later specs.

## Verification Intent

- Spec check: This spec is ready for planning when its scope, assumptions, and scaffold-specific constraints are aligned to the generated app.
- Story verification: Confirm the scaffold artifacts stay aligned and the generated app can run its governed verification surfaces.
- Rendered checks: Use rendered desktop and mobile checks for templates that define browser UI; otherwise state not applicable.
"@
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
      $text = $text.Replace("- [ ] Trigger surface: none", "- [ ] Trigger surface: initial scaffold and app shell")
      $text = $text.Replace("- [ ] Command path used: none", "- [ ] Command path used: scaffold generation")
      $text = $text.Replace("- [ ] Files/surfaces reviewed: none", "- [ ] Files/surfaces reviewed: AGENTS.md, specs/001-initial/plan.md, specs/001-initial/")
      $text = $text.Replace("- [ ] Implementation evidence: none", "- [ ] Implementation evidence: generated scaffold artifacts")
      $text = $text.Replace("- [ ] Verification commands: not-run", "- [ ] Verification commands: check-spec-artifacts and verify-app planned")
      $text = $text.Replace("- [ ] Verification result: not-run", "- [ ] Verification result: planned")
      $text = $text.Replace("- [ ] Decision/closure: not-applicable", "- [ ] Decision/closure: deferred")
    }
    Set-Content -LiteralPath $targetPath -Encoding UTF8 -Value $text
  }
}

$required = @("package.json", "AGENTS.md", "specs/001-initial/plan.md", "specs/001-initial/spec.md", "specs/001-initial/tasks.md", "specs/001-initial/workflow-receipts.md", "specs/001-initial/checklist.md")
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
