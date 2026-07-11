# App AGENTS Contract Trim Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Trim app-level `AGENTS.md` artifacts in `app-dev` down to the durable app contract from the attached proposal, move planning ownership from the former app-level plan surface to spec-local `plan.md`, and reconcile every generator, validator, test, and live repo artifact that still assumes the older layout.

**Architecture:** Treat this as a contract migration across four layers: canonical guidance, generated app templates, app generation logic, and workspace enforcement. Keep workflow/capability detail in root standards and local skills, while app-level `AGENTS.md` files retain only durable app identity, constraints, and verification baseline. Each spec now owns its own `plan.md` inside `specs/NNN-<slug>/` instead of using an app-root plan file. Merge carefully with the existing dirty worktree instead of replacing user edits in already-modified workflow files.

**Tech Stack:** Markdown, PowerShell, repo template assets, workspace validators, generated-app scaffold tests.

## Global Constraints

- Keep durable app contract in app-level `AGENTS.md`; move operational workflow sequencing and optional capability routing to canonical root standards and local skills.
- Preserve the root `AGENTS.md` as the owner of workspace-wide governance, stack defaults, routing pointers, and workflow ownership.
- Use `scripts/check-spec-artifacts.ps1 -ValidationMode current-template` only for template/generated-app validation; keep compatibility mode behavior intact for established apps unless this slice intentionally refreshes them.
- Do not overwrite unrelated pending edits in `.agents/skills/`, `.agents/commands/`, `standards/`, or receipt templates; merge only the lines required by this contract change.
- Keep generated app dependencies and verification commands unchanged unless the contract trim requires wording changes only.
- Validation updates must cover both direct template files and generated app output from `scripts/create-app.ps1`.

---

## Verified Current State

- The attached target contract removes app-level sections such as `Capability Routing`, `Required Before Feature Work`, and `Done When`, and keeps only durable app identity, constraints, platform constraints, and verification baseline.
- `templates/react-vite-capacitor/AGENTS.md`, `templates/next-web-app/AGENTS.md`, `templates/expo-native-app/AGENTS.md`, and `projects/signal/AGENTS.md` still contain heavier workflow/capability content.
- `scripts/create-app.ps1` still generates fallback app `AGENTS.md` content with the older `Done When`-style contract and still scaffolds the former app-level plan surface.
- `scripts/validate-codex-assets.ps1` and `scripts/test-workspace.ps1` still enforce the older app-template `AGENTS.md` shape, including `Done When`.
- `scripts/check-spec-artifacts.ps1`, `scripts/analyze-spec.ps1`, and `scripts/validate-workflow-receipts.ps1` still assume the former app-level plan path and must be switched to the active spec's `plan.md`.
- The current worktree is dirty in `.agents/commands/release-readiness.md`, `.agents/skills/cross-platform-app-workflow/SKILL.md`, `.agents/skills/data-change-workflow/SKILL.md`, `.agents/skills/mobile-validation-workflow/SKILL.md`, `.agents/skills/release-readiness-workflow/SKILL.md`, `.agents/skills/ui-change-workflow/SKILL.md`, `standards/codex-capabilities.md`, `standards/spec-driven-workflow.md`, and `templates/spec-workflow/workflow-receipts.template.md`.

## File Structure

- `templates/react-vite-capacitor/AGENTS.md`: primary template to trim to the new durable contract.
- `templates/next-web-app/AGENTS.md`: trim to the same durable pattern with Next-specific app type/platform wording.
- `templates/expo-native-app/AGENTS.md`: trim to the same durable pattern with Expo/native wording.
- `projects/signal/AGENTS.md`: normalize the live app instructions to the durable app contract while preserving Signal-specific identity and current active spec pointer.
- `scripts/create-app.ps1`: update fallback generated `AGENTS.md` content, move generated plan output to `specs/001-initial/plan.md`, and remove any seeded wording that assumes `Done When` or heavier app-local workflow instructions.
- `scripts/validate-codex-assets.ps1`: replace app-template `AGENTS.md` assertions so they validate the new durable contract instead of the removed sections.
- `scripts/test-workspace.ps1`: update generated-project expectations to the new app `AGENTS.md` contract and keep scaffold verification aligned.
- `standards/codex-capabilities.md`: confirm it fully owns optional external capability routing after the trim; patch only if a removed app-level statement is not already represented here.
- `standards/spec-driven-workflow.md`: confirm it fully owns workflow sequencing and plan/tasks/receipts alignment rules after the trim, including spec-local `plan.md` ownership.
- `.agents/skills/cross-platform-app-workflow/SKILL.md`: confirm it owns the operational “before feature work” behavior that is being removed from app-level `AGENTS.md`; patch only if there is a true gap.
- `docs/superpowers/plans/2026-07-11-app-agents-contract-trim.md`: execution record for this migration.

---

### Task 1: Lock The Durable App AGENTS Contract

**Files:**
- Modify: `docs/superpowers/plans/2026-07-11-app-agents-contract-trim.md`
- Review: `AGENTS.md`
- Review: `standards/codex-capabilities.md`
- Review: `standards/spec-driven-workflow.md`
- Review: `.agents/skills/cross-platform-app-workflow/SKILL.md`

**Interfaces:**
- Consumes: attached trimmed template, root `AGENTS.md`, canonical routing/workflow standards.
- Produces: the exact app-level section set to enforce everywhere else.

- [ ] **Step 1: Re-read the canonical owners**

Run:

```powershell
Get-Content AGENTS.md
Get-Content standards/codex-capabilities.md
Get-Content standards/spec-driven-workflow.md
Get-Content .agents/skills/cross-platform-app-workflow/SKILL.md
```

Expected: confirms root ownership of workflow, routing, verification, and local wrapper skills.

- [ ] **Step 2: Record the exact retained app-level sections**

Capture this target structure in the plan notes before editing files:

```md
# <App> Instructions

This file defines the durable app contract for this project.

Keep feature-specific requirements, scenarios, risks, tasks, workflow receipts, and completion criteria in `specs/NNN-<slug>/`.

Follow the root `app-dev/AGENTS.md` standards.

## Active Specification
## App Type
## App Identity
## Durable Constraints
## Platform Constraints
## Verification Baseline
```

- [ ] **Step 3: Record the removed sections and new owners**

Record this mapping in the plan and use it during implementation:

```text
Capability Routing -> standards/codex-capabilities.md and cross-platform-app-workflow
Required Before Feature Work -> standards/spec-driven-workflow.md and cross-platform-app-workflow
Done When -> specs/* plus /verify flow and standards/spec-driven-workflow.md
Optional plugin/global capability wording -> standards/codex-capabilities.md
Rendered verification workflow wording -> ui-change-workflow and verify command
```

- [ ] **Step 4: Stop if a canonical owner is missing required wording**

Run:

```powershell
rg -n "Optional External Capabilities|workflow-receipts|Lean Path|Gated Path|cross-platform-app-workflow|verify-app.ps1" standards .agents
```

Expected: every removed app-local concern already has a canonical owner, or the gap is explicitly listed for Task 4.

- [ ] **Step 5: Commit the locked migration scope**

```bash
git add docs/superpowers/plans/2026-07-11-app-agents-contract-trim.md
git commit -m "docs: define app agents contract trim plan"
```

### Task 2: Trim Template And Live App AGENTS Files

**Files:**
- Modify: `templates/react-vite-capacitor/AGENTS.md`
- Modify: `templates/next-web-app/AGENTS.md`
- Modify: `templates/expo-native-app/AGENTS.md`
- Modify: `projects/signal/AGENTS.md`

**Interfaces:**
- Consumes: locked section set from Task 1.
- Produces: repo templates and live app instructions that all follow the same durable app contract.

- [ ] **Step 1: Rewrite the React/Vite/Capacitor template**

Replace the current heavy contract with exact durable wording shaped like:

```md
# React Vite Capacitor App Instructions

This file defines the durable app contract for this project.

Keep feature-specific requirements, scenarios, risks, tasks, workflow receipts, and completion criteria in `specs/NNN-<slug>/`.

Follow the root `app-dev/AGENTS.md` standards.

## Active Specification

- Start new work by creating or updating a numbered spec with `/specify`.
- The first feature spec should live under `specs/001-initial/`.
- Later feature specs live under `specs/NNN-<slug>/`.

## App Type

Default cross-platform app: React + Vite + React Router + Capacitor.
```

Then keep React-template-specific `App Identity`, `Durable Constraints`, `Platform Constraints`, and `Verification Baseline` content from the attached proposal.

- [ ] **Step 2: Rewrite the Next and Expo templates to the same contract**

Keep only app-type-specific identity and platform text. Remove sections such as `Capability Routing` and `Done When`. Preserve app-appropriate verification wording, for example:

```md
## Verification Baseline

- Run the app's available verification commands through `../../scripts/verify-app.ps1 -ProjectPath .`.
- If a required script is missing, report the missing script instead of inventing commands.
- UI changes require rendered verification on the relevant supported surfaces.
```

For Expo, replace the final bullet with native/mobile rendered validation wording if that is the durable constraint chosen during implementation.

- [ ] **Step 3: Normalize `projects/signal/AGENTS.md`**

Keep:
- the current active spec pointer
- Signal-specific product identity
- Signal-specific durable constraints that still belong at app level

Remove:
- app-local capability routing
- app-local “required before feature work” workflow rules
- app-local `Done When` closure checklist

- [ ] **Step 4: Run focused artifact validation**

Run:

```powershell
scripts/check-spec-artifacts.ps1 -ProjectPath projects/signal
scripts/check-spec-artifacts.ps1 -ProjectPath projects/signal -ValidationMode compatibility
```

Expected: Signal still passes the durable minimum contract after the trim.

- [ ] **Step 5: Commit the AGENTS migration**

```bash
git add templates/react-vite-capacitor/AGENTS.md templates/next-web-app/AGENTS.md templates/expo-native-app/AGENTS.md projects/signal/AGENTS.md
git commit -m "docs: trim app agents contracts to durable guidance"
```

### Task 3: Update App Generation To Emit The New Contract

**Files:**
- Modify: `scripts/create-app.ps1`

**Interfaces:**
- Consumes: trimmed template contract from Task 2.
- Produces: generated apps and fallback AGENTS content aligned to the new durable contract.

- [ ] **Step 1: Update fallback AGENTS scaffolding**

Replace the fallback `Set-Content` block so it emits the same durable sections and removes the old `Done When` content. Use exact replacement content shaped like:

```md
# <name> App Instructions

This file defines the durable app contract for this project.

Keep feature-specific requirements, scenarios, risks, tasks, workflow receipts, and completion criteria in `specs/NNN-<slug>/`.

Follow the root `app-dev/AGENTS.md` standards.
```

Then keep:
- `## Active Specification`
- `## App Identity`
- `## Durable Constraints`
- `## Platform Constraints`
- `## Verification Baseline`

- [ ] **Step 2: Remove stale seeded wording**

Delete or rewrite any `create-app.ps1` generated text that still assumes:

```text
Done When
Keep the active plan artifact, `tasks.md`, and `workflow-receipts.md` aligned...
review the starter AppShell...
optional external capabilities...
```

Keep spec creation and receipt generation behavior unchanged unless the wording itself must move.

- [ ] **Step 3: Verify generated-file assumptions still hold**

Run:

```powershell
rg -n "Done When|Optional external capabilities|Keep the active plan artifact, `tasks.md`, and `workflow-receipts.md` aligned|Use `standards/codex-capabilities.md`" scripts/create-app.ps1
```

Expected: no stale app-contract strings remain in the generator.

- [ ] **Step 4: Commit the generator update**

```bash
git add scripts/create-app.ps1
git commit -m "feat: generate trimmed app agents contracts"
```

### Task 4: Reconcile Validators, Tests, And Canonical Owners

**Files:**
- Modify: `scripts/validate-codex-assets.ps1`
- Modify: `scripts/test-workspace.ps1`
- Modify if needed: `standards/codex-capabilities.md`
- Modify if needed: `standards/spec-driven-workflow.md`
- Modify if needed: `.agents/skills/cross-platform-app-workflow/SKILL.md`

**Interfaces:**
- Consumes: new app-level contract and existing canonical owners.
- Produces: workspace validation that enforces the trimmed contract without losing the moved guidance.

- [ ] **Step 1: Replace template AGENTS validator assertions**

Update `scripts/validate-codex-assets.ps1` so template AGENTS checks assert the new durable sections instead of the removed ones. The required needle set should look like:

```text
This file defines the durable app contract for this project.
Active Specification
Durable Constraints
Platform Constraints
Verification Baseline
verify-app.ps1 -ProjectPath .
report the missing script instead of inventing commands
```

Remove assertions for:

```text
Done When
check-spec-artifacts.ps1 -ProjectPath .
validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence
workflow-receipts.md is current ...
```

- [ ] **Step 2: Update generated-project test expectations**

Rewrite the `AGENTS.md` expectations in `scripts/test-workspace.ps1` to match the new durable contract. Keep scaffold file existence and spec/receipt generation checks, but stop requiring removed sections in generated app `AGENTS.md`.

- [ ] **Step 3: Patch canonical owners only where gaps remain**

If Task 1 found missing owner text, patch only those gaps:

- `standards/codex-capabilities.md` for optional plugin/global capability routing
- `standards/spec-driven-workflow.md` for plan/tasks/receipt alignment and completion ownership
- `.agents/skills/cross-platform-app-workflow/SKILL.md` for operational before-feature-work expectations

Do not restate the removed content in app-level templates.

- [ ] **Step 4: Review dirty-file merge safety**

Run:

```powershell
git status --short
git diff -- scripts/validate-codex-assets.ps1 scripts/test-workspace.ps1 standards/codex-capabilities.md standards/spec-driven-workflow.md .agents/skills/cross-platform-app-workflow/SKILL.md
```

Expected: only intended hunks are edited, and existing user changes in already-dirty files are preserved.

- [ ] **Step 5: Commit the enforcement changes**

```bash
git add scripts/validate-codex-assets.ps1 scripts/test-workspace.ps1 standards/codex-capabilities.md standards/spec-driven-workflow.md .agents/skills/cross-platform-app-workflow/SKILL.md
git commit -m "test: align workspace validation to trimmed app agents contract"
```

### Task 5: Prove The Migration With Workspace-Level Verification

**Files:**
- Modify: `docs/superpowers/plans/2026-07-11-app-agents-contract-trim.md`

**Interfaces:**
- Consumes: all prior tasks.
- Produces: verified closeout evidence for the contract migration.

- [ ] **Step 1: Run focused governance checks first**

Run:

```powershell
scripts/validate-codex-assets.ps1 -RequirePythonToml:$true
scripts/test-workspace.ps1
git diff --check
```

Expected: all exit 0, and generated-app tests pass with the new app `AGENTS.md` shape.

- [ ] **Step 2: Run the canonical full governance gate**

Run:

```powershell
scripts/check-all.ps1
```

Expected: full workspace governance passes after the contract migration.

- [ ] **Step 3: Inspect the final repo scope**

Run:

```powershell
git status --short
git diff --stat
git diff -- AGENTS.md templates projects scripts standards .agents docs/superpowers/plans
```

Expected: the diff contains only the contract-trim migration and any intentional canonical-owner gap fixes.

- [ ] **Step 4: Record the closeout evidence**

Append plan notes covering:
- final affected files
- commands run
- whether `projects/signal/AGENTS.md` was migrated in the same slice
- any canonical-owner wording added to standards or skills
- any skipped check and exact blocker

- [ ] **Step 5: Commit final closeout**

```bash
git add templates projects scripts standards .agents docs/superpowers/plans
git commit -m "docs: finalize app agents contract trim"
```

## Self-Review

- Spec coverage: the plan covers every currently discovered affected surface: templates, live app instructions, app generation, validator enforcement, generated-app tests, and canonical owner docs/skills if gaps exist.
- Placeholder scan: no `TODO`, `TBD`, or “implement later” markers remain.
- Type consistency: the migration consistently uses `Active Specification`, `Durable Constraints`, `Platform Constraints`, and `Verification Baseline` as the retained app-level contract sections.
- Drift check: the plan explicitly separates template/current-template enforcement from compatibility-mode behavior for established apps.
- Dirty-worktree safety: the plan requires diff review before editing already-modified standards and skills.
