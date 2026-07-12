# /verify Command Contract Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Densify the `/verify` command so it matches the structure, rigor, and owner boundaries now used by `/analyze` and `/converge`, while updating every active repo-owned artifact that would otherwise drift from the live verification contract.

**Architecture:** Treat this as a workflow-governance slice, not a single markdown edit. `.agents/commands/verify.md` is the human-facing Verify-phase contract, `workflow-receipts.md` remains the evidence ledger, `validate-workflow-receipts.ps1` and `verify-app.ps1` remain the mechanical evidence gates, and active standards, templates, manifest entries, validator assertions, and workflow tests must move with the command so `/verify` stays narrow: verify the converged state, record evidence, and close completion honestly.

**Tech Stack:** Markdown command docs and plans, PowerShell validators and workflow tests, JSON standards registries, spec-workflow templates, receipt evidence artifacts.

## Global Constraints

- Plan lives under `docs/plans/` per local user instruction, not under `docs/superpowers/plans/`.
- `/verify` must assume convergence is already closed and must not re-own remaining-work discovery.
- `/verify` must be written in the same dense command style as `.agents/commands/analyze.md` and `.agents/commands/converge.md`.
- `/verify` must keep `workflow-receipts.md` as the evidence owner; chat output is not evidence.
- `/verify` may rerun `analyze-spec.ps1` defensively, but it must not expand back into pre-implementation analysis ownership.
- `/verify` must keep rendered UI verification explicit when UI work is in scope.
- Existing app validators remain on `compatibility` mode unless this slice intentionally changes current-template requirements.
- Do not broaden this slice into unrelated release-readiness, app-template, or historical-doc cleanup unless those surfaces are active workflow owners for the Verify-phase contract.

## Implementation Decisions

- Checklist template decision: review required, default **no change** unless `/verify` gains new gated-risk checklist ownership.
- Current evidence suggests `templates/spec-workflow/checklist.template.md` is a gated-readiness artifact, not the owner of Verify-phase command semantics.
- Therefore, the checklist template should change only if the revised `/verify` contract introduces a new gated-only control that is not already covered by:
  - `CHK012` current implementation, verification, and outstanding-gap notes
  - `CHK013` verification commands are current
  - `CHK014` explicit approval before destructive or live operations

## Affected Artifact Map

- Modify `.agents/commands/verify.md`
  - Replace the thin Verify-phase note with a dense command contract in the same style as `/analyze` and `/converge`.
- Review or modify `standards/command-workflow-contract.md`
  - Patch only if the current Verify responsibility line is too thin to match the revised command boundary.
- Review or modify `standards/spec-driven-workflow.md`
  - Patch only if Verify-phase semantics, convergence assumptions, or rendered-evidence wording drift from the revised command.
- Review or modify `standards/workspace.md`
  - Patch only if active workspace-owner wording misstates Verify-phase ownership after the rewrite.
- Review or modify `standards/registry/command-workflow-contract.rules.json`
  - Patch only if machine-readable Verify-phase command responsibility needs to become more explicit.
- Review or modify `standards/registry/spec-driven-workflow.rules.json`
  - Patch only if Verify-phase workflow semantics or evidence wording drift from the revised command.
- Review or modify `standards/registry/workspace.rules.json`
  - Patch only if workspace-level evidence or command-spine rules drift from the revised Verify contract.
- Review or modify `scripts/validate-codex-assets.ps1`
  - Update Verify command-density assertions so enforcement matches the new command shape.
- Review or modify `scripts/test-workflow-enforcement.ps1`
  - Patch only if the test suite currently misses the revised Verify-phase assumptions or command needles.
- Review or modify `scripts/validate-workflow-receipts.ps1`
  - Patch only if receipt validation must recognize new required evidence wording or closure expectations created by the Verify rewrite.
- Review or modify `scripts/check-spec-artifacts.ps1`
  - Patch only if current-template or compatibility checks must enforce new Verify-facing artifact text.
- Review or modify `templates/spec-workflow/workflow-receipts.template.md`
  - Patch only if the revised `/verify` contract requires receipt fields or final-evidence prompts not currently scaffolded.
- Review `templates/spec-workflow/checklist.template.md`
  - Change only if the revised Verify contract introduces a new gated-only checklist responsibility.
- Review `templates/spec-workflow/tasks.template.md`
  - Patch only if downstream verification task wording needs to mention the updated Verify-phase contract more explicitly.
- Review or modify `scripts/create-app.ps1`
  - Patch only if scaffolded plan/receipt/checklist seed text becomes false after the Verify update.
- Modify `docs/plans/2026-07-11-verify-command-contract-update.md`
  - Record implementation decisions, changed surfaces, checklist-template decision, verification results, and drift sweep outcome.

## Task 1: Lock The Verify Boundary Before Editing

**Files:**
- Modify: `docs/plans/2026-07-11-verify-command-contract-update.md`
- Review: `.agents/commands/verify.md`
- Review: `.agents/commands/converge.md`
- Review: `standards/command-workflow-contract.md`
- Review: `standards/spec-driven-workflow.md`
- Review: `templates/spec-workflow/workflow-receipts.template.md`
- Review: `templates/spec-workflow/checklist.template.md`

**Interfaces:**
- Consumes:
  - current thin `/verify` command
  - current dense `/analyze` and `/converge` peer commands
  - current workflow evidence template and gated checklist template
- Produces:
  - one explicit Verify-phase owner boundary
  - one documented checklist-template decision
  - one bounded list of active-owner surfaces to patch

- [ ] **Step 1: Capture the current Verify-phase owner split**

Run:

```powershell
rg -n "/verify|verification evidence|RequireVerificationEvidence|rendered|converged|workflow-receipts" .agents standards templates scripts
```

Expected:
- active-owner hits in `.agents/commands/verify.md`
- matching standard or registry hits for Verify-phase semantics
- receipt-template hits for final verification evidence

- [ ] **Step 2: Record the non-negotiable Verify contract**

Write these decisions into this plan before code changes:

```text
1. `/verify` requires a converged state.
2. `/verify` records verification evidence, rendered checks, blockers, skipped checks, deviations, and final closure.
3. `/verify` does not re-own remaining-work discovery from `/converge`.
4. `workflow-receipts.md` remains the required evidence ledger.
5. The gated checklist remains a risk-control artifact, not the primary owner of Verify-phase command semantics.
```

- [ ] **Step 3: Decide whether the checklist template changes**

Use this rule:

```text
Change `templates/spec-workflow/checklist.template.md` only if the revised `/verify` contract introduces a new gated-only requirement that is not already represented in CHK012-CHK014.
Otherwise leave the checklist template unchanged and record why.
```

Expected:
- the slice avoids blurring workflow-command ownership with gated checklist ownership

## Task 2: Rewrite `.agents/commands/verify.md` In Dense Command Style

**Files:**
- Modify: `.agents/commands/verify.md`
- Review: `.agents/commands/analyze.md`
- Review: `.agents/commands/converge.md`

**Interfaces:**
- Consumes:
  - dense command structure from `/analyze` and `/converge`
  - current Verify-phase boundary
- Produces:
  - a dense `/verify` command with stable sections matching peer commands

- [ ] **Step 1: Replace the thin command with the dense structure**

Ensure `.agents/commands/verify.md` includes:

```text
## Purpose
## User Input
## Working Directory
## Start Gate
## Required Reads
## Required Writes
## Pre-Step Checks
## Execution Steps
## Post-Step Checks
## Receipt Updates
## Stop Conditions
## Completion Report
## Next Command
```

- [ ] **Step 2: Keep the Purpose section narrow and explicit**

State, in substance:

```md
`/verify` is the post-convergence verification gate. It confirms the converged state still matches the active spec package, runs governed verification commands, records rendered and non-rendered evidence, updates workflow receipts, and closes completion honestly.
```

- [ ] **Step 3: Add explicit User Input, Required Reads, and Required Writes**

The command should make these boundaries explicit:

```text
- user arguments can narrow verification focus or reporting depth but cannot override required evidence or safety gates
- required reads include active `spec.md`, `plan.md`, `tasks.md`, `workflow-receipts.md`, gated `checklist.md` when required, verification scripts, and project verification configuration
- required writes primarily target `workflow-receipts.md`, with narrow reconciliation updates to `tasks.md`, `plan.md`, or `spec.md` only when verified reality requires it
```

- [ ] **Step 4: Use phase-based execution**

Restructure `Execution Steps` around phases such as:

```text
Phase 1: Read The Converged State
Phase 2: Close Final Artifact Drift Before Running Gates
Phase 3: Run Governed Verification Commands
Phase 4: Run Rendered Verification
Phase 5: Review Evidence And Closure State
Phase 6: Assign Severity
Phase 7: Produce Verification Report
Phase 8: Receipt Handling
Phase 9: Run Verification Review
```

- [ ] **Step 5: Keep convergence dependency explicit**

The command must say, in substance:

```text
- `/verify` assumes `/converge` already closed remaining implementation work
- if verification reveals actual remaining feature work rather than evidence-only drift, that is a blocker and must route back through the owning artifact or `/converge`/`/implement` path rather than being silently absorbed here
```

## Task 3: Reconcile Active Owner Surfaces And Enforcement

**Files:**
- Review or modify: `standards/command-workflow-contract.md`
- Review or modify: `standards/spec-driven-workflow.md`
- Review or modify: `standards/workspace.md`
- Review or modify: `standards/registry/command-workflow-contract.rules.json`
- Review or modify: `standards/registry/spec-driven-workflow.rules.json`
- Review or modify: `standards/registry/workspace.rules.json`
- Review or modify: `scripts/validate-codex-assets.ps1`
- Review or modify: `scripts/test-workflow-enforcement.ps1`

**Interfaces:**
- Consumes:
  - revised Verify command
  - current standards, registries, and validator expectations
- Produces:
  - no active-owner drift between human workflow docs and enforcement layers

- [ ] **Step 1: Patch standards only where they are materially thinner or false**

Update active-owner prose only if needed so it matches the revised Verify contract:

```text
- verify requires a converged state
- verify owns verification evidence and final closure
- verify records rendered UI evidence when required
```

- [ ] **Step 2: Patch matching registry rules only when the machine-readable contract is thinner or false**

Update only the relevant Verify-phase rule entries. Do not churn unrelated registry families.

- [ ] **Step 3: Tighten validator command-density checks**

In `scripts/validate-codex-assets.ps1`, make the Verify command needles reflect the denser shape, for example:

```text
## User Input
## Required Reads
## Required Writes
Run Governed Verification Commands
Run Rendered Verification
Produce Verification Report
converged state
workflow-receipts.md
```

- [ ] **Step 4: Patch workflow tests only if the current tests miss the new contract**

Update `scripts/test-workflow-enforcement.ps1` only if needed to keep command-shape or Verify-phase contract enforcement live.

## Task 4: Reconcile Templates And Scaffold Inputs

**Files:**
- Review or modify: `templates/spec-workflow/workflow-receipts.template.md`
- Review: `templates/spec-workflow/checklist.template.md`
- Review or modify: `templates/spec-workflow/tasks.template.md`
- Review or modify: `scripts/validate-workflow-receipts.ps1`
- Review or modify: `scripts/check-spec-artifacts.ps1`
- Review or modify: `scripts/create-app.ps1`

**Interfaces:**
- Consumes:
  - revised Verify command
  - current receipt template, checklist template, validators, and scaffold seed text
- Produces:
  - scaffolded artifacts and validators that still match the live Verify contract

- [ ] **Step 1: Review the workflow receipts template first**

Change `templates/spec-workflow/workflow-receipts.template.md` only if the revised `/verify` contract requires new receipt prompts or clearer final-evidence wording.

- [ ] **Step 2: Make the checklist-template decision explicit**

If no change is needed, record:

```text
No checklist-template update required because gated checklist ownership did not expand; Verify-phase evidence continues to live in workflow receipts and existing CHK012-CHK014 already cover verification-readiness and approval state.
```

If a change is needed, keep it minimal and gated-only.

- [ ] **Step 3: Patch scaffold and validators only when their text becomes false**

Only edit `tasks.template.md`, `validate-workflow-receipts.ps1`, `check-spec-artifacts.ps1`, or `create-app.ps1` when the Verify rewrite makes their current wording or required fields false.

## Task 5: Verify The Slice And Record Drift Outcome

**Files:**
- Modify: `docs/plans/2026-07-11-verify-command-contract-update.md`
- Review: all files touched in Tasks 2-4

**Interfaces:**
- Consumes:
  - revised command
  - any updated standards, registries, validators, tests, or templates
- Produces:
  - a verified no-drift Verify-phase slice

- [ ] **Step 1: Run focused governance checks first**

Run:

```powershell
./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true
./scripts/test-workflow-enforcement.ps1
```

Expected:
- command density and workflow enforcement pass

- [ ] **Step 2: Run narrower validators only if their contract changed**

If receipt/template/validator surfaces changed, run the narrowest relevant checks such as:

```powershell
./scripts/check-spec-artifacts.ps1 -ProjectPath projects/signal
./scripts/validate-workflow-receipts.ps1 -ProjectPath projects/signal
```

- [ ] **Step 3: Run a repo-wide stale-reference sweep for active owners**

Run:

```powershell
rg -n "/verify|verification evidence|converged state|Rendered UI verification|workflow-receipts.md" .agents standards templates scripts
```

Patch only active-owner drift, not historical plan evidence.

- [ ] **Step 4: Append closeout evidence to this plan**

Append:

```text
- files changed
- checklist-template decision
- validators/tests changed
- checks run
- drift sweep result
- remaining blockers
```

## Reporting Checklist

- [x] The plan treats `/verify` as a workflow-governance slice, not a single markdown edit.
- [x] All likely active-owner drift surfaces for Verify-phase updates are identified.
- [x] The checklist-template decision is explicit and bounded.
- [x] The plan moves from drafting directly into implementation.
- [x] Validators, tests, templates, and scaffold inputs are included conditionally rather than assumed.

## Closeout Evidence

- Implementation status: complete for the Verify-phase contract slice.
- Files changed:
  - `.agents/commands/verify.md`
  - `scripts/validate-codex-assets.ps1`
  - `docs/plans/2026-07-11-verify-command-contract-update.md`
- Checklist-template decision:
  - no change required to `templates/spec-workflow/checklist.template.md`
  - reason: the revised `/verify` contract did not add a new gated-only checklist responsibility
  - existing `CHK012`, `CHK013`, and `CHK014` already cover verification-readiness, current verification commands, and explicit approval state for gated work
- Workflow-receipts template decision:
  - no change required to `templates/spec-workflow/workflow-receipts.template.md`
  - reason: the existing receipt template already owns final verification evidence, rendered UI verification, skipped checks, and final decision prompts
- Standards and registry decision:
  - no active-owner prose or machine-readable registry change was required because the current workspace standards already describe `/verify` as a post-convergence evidence-and-closure command
- Validators and tests changed:
  - `scripts/validate-codex-assets.ps1` now enforces the denser `/verify` command structure directly
- Checks run:
  - `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`
  - `./scripts/test-workflow-enforcement.ps1`
- Verification result:
  - both focused governance checks passed
- Drift sweep result:
  - active-owner surfaces under `.agents/`, `standards/`, `templates/`, and `scripts/` were reviewed
  - no additional active-owner drift requiring patching was found beyond the command contract and its validator enforcement surface
- Remaining blockers: none in this slice
