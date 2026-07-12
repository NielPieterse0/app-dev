# /implement Command And Plan Template Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the `/implement` command and `templates/spec-workflow/plan.template.md` so implementation readiness, execution sequencing, standards application, workflow obligations, documentation reconciliation, and downstream verification handoff are explicit, consistent, and enforced across standards, validators, scaffolds, and workflow tests.

**Architecture:** Treat this as a workflow-governance slice, not a pair of markdown edits. The command doc defines `/implement` execution behavior, the plan template defines the implementation-readiness and implementation-constraint shape that later commands consume, and the enforcement layer must move with them so generated apps, validators, tests, standards, and downstream commands do not drift. Keep the contract local to `app-dev`: adopt useful structure from spec-kit implement guidance, but do not import spec-kit runtime hooks, repo-root prerequisite scripts, foreign file layouts, or hard "all tasks complete" semantics that conflict with deferred-work closure in `/verify`.

**Tech Stack:** Markdown command docs and templates, PowerShell validators and scaffolders, workspace governance tests, workflow command contracts.

## Global Constraints

- `/implement` consumes the active `spec.md`, `plan.md`, `tasks.md`, `workflow-receipts.md`, and gated `checklist.md` when required; it must not create or initialize those artifacts.
- `/implement` must make execution sequencing explicit: dependency order, phase completion before proceeding, `[P]` only for truly independent work, and same-file work staying sequential.
- `/implement` must make progress, failure, focused-check, and partial-success handling explicit without claiming closure; `/verify` remains the closure owner.
- `/implement` must include implementation quality rules for scripting, testing, security, workflow-specific requirements, documentation hygiene, and other materially applicable standards.
- Documentation reconciliation belongs inside `/implement` as the final implementation phase before `/verify`, not as an optional follow-up after implementation.
- `templates/spec-workflow/plan.template.md` must expose the plan fields needed to drive implementation readiness and standards-aware execution without turning `plan.md` into a duplicate of `tasks.md`.
- Existing apps remain on validator `compatibility` mode unless a slice explicitly opts into `current-template`.
- Adopt structural ideas from the attached `speckit.implement` drafts only where they align with local workflow ownership; do not import `.specify/extensions.yml`, foreign prerequisite scripts, checklist directories, ignore-file automation, or spec-kit document-layout assumptions.
- Do not create broad churn across historical `projects/*/specs/*` artifacts unless a validator contract change makes a compatibility update unavoidable.

## File Structure

- Modify `.agents/commands/implement.md`
  - Own the executable `/implement` contract: purpose, reads, writes, execution phases, implementation quality rules, receipt updates, stop conditions, and handoff to `/verify`.
- Modify `templates/spec-workflow/plan.template.md`
  - Own the generated `plan.md` shape that implementation depends on: implementation constraints, workflow requirements, documentation ownership/drift constraints, implementation-readiness signals, and exact verification expectations.
- Review `.agents/commands/tasks.md`
  - Ensure `/tasks` hands off to `/implement` with wording that matches the densified execution contract.
- Review `.agents/commands/analyze.md`
  - Confirm whether `/analyze` remains post-implementation or is repositioned as a pre-implementation readiness gate; update only if the `/implement` rewrite changes the surrounding flow contract.
- Review `.agents/commands/verify.md`
  - Ensure `/verify` consumes the revised `/implement` outputs and does not duplicate newly owned implementation behavior.
- Modify `standards/command-workflow-contract.md`
  - Keep `/implement` responsibility aligned with the revised command behavior and any updated `/analyze` adjacency.
- Modify `standards/spec-driven-workflow.md`
  - Keep phase sequencing, lean/gated path wording, implementation narrative, and convergence ownership aligned with the revised `/implement` contract.
- Review `standards/workspace.md`
  - Confirm documentation-hygiene and fact-ownership wording remains the canonical owner for anti-drift rules cited by `/implement`; edit only if the command/template changes require a clearer pointer.
- Modify `scripts/validate-codex-assets.ps1`
  - Update `/implement` command assertions and any plan-template assertions affected by the new implementation-readiness fields.
- Modify `scripts/check-spec-artifacts.ps1`
  - Update plan-artifact checks only if the generated `plan.md` contract changes.
- Review `scripts/validate-workflow-receipts.ps1`
  - Confirm receipt-field expectations still match the revised implementation evidence and focused-check recording guidance.
- Modify `scripts/create-app.ps1`
  - Keep scaffolded `plan.md` content aligned with the revised plan template.
- Modify `scripts/test-workflow-enforcement.ps1`
  - Update fixture expectations if `/implement` command-path, workflow evidence, or implementation-handoff wording changes.
- Modify `scripts/test-workspace.ps1`
  - Update current-template scaffold expectations if the revised plan template changes generated artifact content.
- Review `.agents/skills/cross-platform-app-workflow/SKILL.md`
  - Confirm the wrapper workflow still points at the right implementation sequencing, artifact alignment, and standards surfaces.
- Review `.agents/skills/ui-change-workflow/SKILL.md`
  - Confirm UI workflow handoff text still matches the revised implementation evidence and rendered-verification expectations.
- Review `.agents/skills/data-change-workflow/SKILL.md`
  - Confirm data workflow handoff text still matches implementation evidence and gap-tracking expectations.
- Review `.agents/skills/mobile-validation-workflow/SKILL.md`
  - Confirm mobile workflow handoff text still matches implementation evidence and implementation-time obligations.
- Review `.agents/skills/release-readiness-workflow/SKILL.md`
  - Confirm release-readiness wrapper wording still matches what `/implement` now records versus what `/verify` or `/release-readiness` closes.
- Create `docs/plans/2026-07-11-implement-command-plan-template-update.md`
  - Execution record for this governance slice.

## Task 1: Lock The Revised `/implement` And Plan-Template Contract Before Editing

**Files:**
- Modify: `docs/plans/2026-07-11-implement-command-plan-template-update.md`
- Review: `.agents/commands/implement.md`
- Review: `templates/spec-workflow/plan.template.md`
- Review: `standards/command-workflow-contract.md`
- Review: `standards/spec-driven-workflow.md`
- Review: `standards/workspace.md`

**Interfaces:**
- Consumes:
  - Current `/implement` command sections in `.agents/commands/implement.md`
  - Current plan-template implementation-facing sections in `templates/spec-workflow/plan.template.md`
  - Ownership rules in `standards/command-workflow-contract.md`
  - Phase rules in `standards/spec-driven-workflow.md`
  - Documentation-hygiene and fact-ownership rules in `standards/workspace.md`
  - Attached spec-kit implement comments and pasted review notes
- Produces:
  - Finalized contract decisions for:
    - what is adopted from spec-kit versus explicitly rejected
    - what `plan.md` must tell `/implement` before code changes begin
    - which rules belong in `Start Gate`, `Pre-Step Checks`, implementation phases, or review checks
    - what documentation reconciliation and anti-drift ownership `/implement` must enforce
    - which validator/test surfaces must move in lockstep

- [ ] **Step 1: Capture the current contract and the known densification targets**

Run:

```powershell
rg -n "/implement|plan.template.md|implementation constraints|workflow-receipts.md|focused checks|documentation hygiene|analyze" .agents templates standards scripts docs
```

Expected:
- hits for `.agents/commands/implement.md`
- hits for `templates/spec-workflow/plan.template.md`
- hits for standards, validators, and tests that reference implementation behavior

- [ ] **Step 2: Write the non-negotiable contract decisions into this plan before implementation**

Record these decisions verbatim in the working notes for the slice:

```text
1. `/implement` consumes initialized implementation artifacts; it does not create `tasks.md`, `workflow-receipts.md`, or `checklist.md`.
2. `/implement` must make execution order explicit: dependency order, phase completion before proceeding, same-file sequencing, and limited `[P]` use for truly independent work only.
3. `/implement` must require task progress updates, focused-check recording, blocker reporting, and explicit handling of deferred work and partial parallel success.
4. `/implement` must apply implementation quality rules for scripting, testing, security, workflow-specific requirements, documentation quality, and other materially relevant standards.
5. Documentation reconciliation is the last implementation phase before `/verify`.
6. `plan.template.md` must expose implementation-readiness fields that help `/implement` execute safely without duplicating `tasks.md`.
7. Spec-kit runtime assumptions stay out: no extension hooks, no repo-root prerequisite script runner, no checklist-directory model, no ignore-file automation, and no hard "all tasks complete" closure rule.
```

- [ ] **Step 3: Lock the expected local replacements for adopted spec-kit ideas**

Record these replacements in the slice notes:

```text
- Spec-kit checklist scan -> local gated `checklist.md` readiness gate.
- Spec-kit TDD prescription -> add or update tests before or alongside implementation where practical in the existing repo structure.
- Spec-kit optional supporting docs -> read additional active-spec artifacts only when they exist and materially affect implementation.
- Spec-kit completion validation -> local focused checks plus `/verify` closure ownership.
```

- [ ] **Step 4: Reject unnecessary scope expansion up front**

Record these non-goals in the slice notes:

```text
- Do not add a spec-kit hook runtime or `.specify/`-style command system.
- Do not redesign plan.md into a task checklist; `tasks.md` remains the execution checklist owner.
- Do not rewrite historical app specs or receipts unless compatibility-mode validator changes make a sample update unavoidable.
```

- [ ] **Step 5: Commit the contract-audit checkpoint**

```bash
git add docs/plans/2026-07-11-implement-command-plan-template-update.md
git commit -m "docs: lock /implement densification plan"
```

## Task 2: Rewrite The `/implement` Command Contract

**Files:**
- Modify: `.agents/commands/implement.md`
- Review: `.agents/commands/tasks.md`
- Review: `.agents/commands/analyze.md`
- Review: `.agents/commands/verify.md`

**Interfaces:**
- Consumes:
  - Contract decisions from Task 1
  - Existing command section headings enforced by workspace validators
  - Current `/tasks` handoff wording
  - Current `/verify` convergence and closure wording
- Produces:
  - Revised `/implement` command guidance with stable headings:
    - `Purpose`
    - `Working Directory`
    - `Start Gate`
    - `Required Reads`
    - `Required Writes`
    - `Pre-Step Checks`
    - `Execution Steps`
    - `Post-Step Checks`
    - `Receipt Updates`
    - `Stop Conditions`
    - `Completion Report`
    - `Next Command`

- [ ] **Step 1: Rewrite `Purpose`, `Start Gate`, and `Required Reads` to reflect the densified local contract**

Update `.agents/commands/implement.md` so it states, in substance:

```md
`/implement` executes the active `tasks.md`, updates application files, keeps implementation evidence current, applies implementation quality rules, and reconciles documentation and artifacts before `/verify`.

Start Gate:
- Confirm app `AGENTS.md`, active `spec.md`, active `plan.md`, active `tasks.md`, and active `workflow-receipts.md` exist.
- Confirm gated `checklist.md` exists and blocking items are complete or explicitly approved to proceed when gated risk applies.
- Confirm the active task list is concrete enough to execute without inventing missing scope.

Required Reads:
- active `spec.md`
- active `plan.md`
- active `tasks.md`
- active `workflow-receipts.md`
- active `checklist.md` when required
- broader standards only when they materially affect touched surfaces
```

Reject wording that implies `/implement` initializes artifacts or blindly re-reads every standard every time.

- [ ] **Step 2: Expand `Pre-Step Checks` so they reflect local readiness rather than stale boilerplate**

Ensure `Pre-Step Checks` cover:

```md
- artifacts were initialized by `/tasks`
- task IDs and sequencing are executable
- workflow classification is already set
- required local workflow wrappers are identified before touching affected surfaces
- no unapproved destructive, credentialed, or live-environment action is required
- validator mode remains compatibility unless this slice explicitly opts into current-template
```

Do not duplicate stop logic here that belongs in `Stop Conditions`.

- [ ] **Step 3: Replace the flat execution list with explicit implementation phases**

Restructure `Execution Steps` around phases such as:

```md
### Phase 1: Read The Active Artifacts
### Phase 2: Prepare The Implementation Sequence
### Phase 3: Execute The Work
### Phase 4: Keep Execution Evidence Current
### Phase 5: Apply Implementation Quality Rules
### Phase 6: Run Focused Implementation Checks
### Phase 7: Reconcile Documentation And Artifacts
### Phase 8: Run Implementation Review
```

Use Task 1’s decisions to make each phase concrete rather than generic.

- [ ] **Step 4: Densify Phase 2 with execution-order and parallelism rules adapted from spec-kit**

In `Prepare The Implementation Sequence`, make the command say, in substance:

```md
- order tasks by dependency
- complete setup and foundation before story or vertical-increment work
- complete each phase before proceeding to the next
- keep same-file or shared-surface work sequential
- allow `[P]` only for truly independent work with no unfinished shared dependency
- stop to reconcile blocking artifact drift before continuing implementation
```

Do not import spec-kit phase names, repo-root runners, or foreign file-layout assumptions.

- [ ] **Step 5: Densify Phase 3 and focused failure handling**

In `Execute The Work`, make the command say, in substance:

```md
- implement tasks in dependency order
- mark completed tasks `[x]`
- leave deferred tasks unchecked and record exact reasons
- if a non-deferred blocking task fails, stop and record the blocker
- for independent parallel tasks, keep successful work, record failed work, and reconcile the remaining plan before continuing
- keep behavior aligned to the active spec and active plan
```

Avoid hard "all tasks must be complete" wording that conflicts with intentional deferral.

- [ ] **Step 6: Add a dedicated implementation quality-rules phase**

Add subsections covering:

```md
#### Scripts Standards And Quality
#### Testing Standards And Quality
#### Security Standards And Quality
#### Workflow-Specific Requirements
#### Documentation Standards And Quality
#### Other Applicable Standards And Quality
```

Tie each subsection to the canonical owner where appropriate:

```text
../../standards/scripting.md
../../standards/testing.md
../../standards/security.md
../../standards/workspace.md
required local workflow wrapper skills
```

Keep this phase about applying rules during implementation, not about final verification closure.

- [ ] **Step 7: Make documentation reconciliation an explicit final implementation phase**

In `Reconcile Documentation And Artifacts`, require:

```md
- update task-owned docs as implementation completes
- reconcile `spec.md`, `plan.md`, `tasks.md`, `workflow-receipts.md`, and touched operational or user-facing docs to the implemented state
- reconcile affected repo-wide docs when the slice touches governed surfaces
- record deviations, deferred documentation work, and exact blockers
- finish `/implement` only after code and documentation describe the same implemented reality
```

Point back to `standards/workspace.md` as the owner of documentation hygiene and fact ownership, not the command itself.

- [ ] **Step 8: Expand the implementation review checklist**

Convert the revised quality and reconciliation expectations into concrete `CHK-##` items covering at least:

```text
scope alignment
plan/module alignment
task-status accuracy
receipt currency
workflow-wrapper usage
scripting standards
testing standards
security standards
workflow-specific requirements
documentation standards / anti-drift expectations
other applicable standards
focused-check recording
artifact agreement
blockers/deferrals
approval-sensitive operations
placeholder-free receipt fields
ready-for-/verify state
```

Ensure check numbering is unique and stable.

- [ ] **Step 9: Tighten `Post-Step Checks`, `Receipt Updates`, and `Completion Report`**

Ensure `Post-Step Checks` contain only end-state assertions such as:

```md
- completed tasks correspond to real changes or explicit no-op findings
- `workflow-receipts.md` lists implementation evidence for required workflow sections
- `spec.md` and `plan.md` still match implemented decisions
- focused implementation checks passed or the exact blocker is recorded
```

Ensure `Receipt Updates` and `Completion Report` reflect implementation-time evidence and handoff, not verification closure.

- [ ] **Step 10: Align neighboring command wording only where the `/implement` contract changed**

Check `.agents/commands/tasks.md`, `.agents/commands/analyze.md`, and `.agents/commands/verify.md` for stale wording such as:

```text
old handoff assumptions
missing documentation-reconciliation owner
late-stage analysis wording that conflicts with the chosen flow
verification text that duplicates new `/implement` ownership
```

Update only the affected lines; do not broaden the slice into unrelated command redesign.

- [ ] **Step 11: Commit the command-contract slice**

```bash
git add .agents/commands/implement.md .agents/commands/tasks.md .agents/commands/analyze.md .agents/commands/verify.md
git commit -m "docs: densify /implement command contract"
```

## Task 3: Update The Plan Template To Support Implementation Readiness

**Files:**
- Modify: `templates/spec-workflow/plan.template.md`
- Review: `.agents/commands/plan.md`
- Review: `.agents/commands/implement.md`

**Interfaces:**
- Consumes:
  - Revised `/implement` contract from Task 2
  - Current `plan.template.md` sections and placeholders
  - Current `/plan` command behavior
- Produces:
  - Revised `plan.template.md` with implementation-facing fields that `/implement` can rely on
  - Confirmation about whether `/plan` wording must change to populate or review those fields correctly

- [ ] **Step 1: Identify which implementation-facing fields are currently missing or too weak**

Review whether the current plan template gives `/implement` enough information for:

```text
implementation sequencing constraints
workflow-specific implementation obligations
documentation ownership/drift constraints
standards-sensitive implementation constraints
focused implementation-readiness notes
```

Write the missing-field decision into the slice notes before editing the template.

- [ ] **Step 2: Strengthen the implementation-facing plan sections without turning plan.md into tasks.md**

Update `templates/spec-workflow/plan.template.md` so sections such as these carry enough implementation signal:

```md
## Architecture Decisions
## Project Structure And Ownership
## Module Impact
## Workflow Classification
## Verification Strategy
## Risks And Assumptions
## Complexity Tracking
```

Add or refine bullets for:

```text
implementation sequencing constraints
same-file / shared-surface coordination constraints
workflow-specific implementation obligations
documentation and anti-drift obligations
approval-sensitive operations and implementation blockers
```

Keep the plan decision-oriented; do not move task-level execution checklists into the template.

- [ ] **Step 3: Add explicit implementation-readiness and documentation-alignment prompts where needed**

If the current template lacks them, add prompts such as:

```md
- Implementation readiness: TODO: what must already be true before `/implement` starts.
- Workflow-specific implementation requirements: TODO: implementation-time requirements from required wrapper workflows.
- Documentation alignment constraints: TODO: governed docs or standards that must be reconciled during implementation to prevent drift.
```

Use the repo’s established section style rather than inventing a foreign template structure.

- [ ] **Step 4: Preserve validator-sensitive anchors unless the validator is updated in the same slice**

Do not remove required markers such as:

```text
Active spec:
Spec path:
Tasks path:
Workflow receipts path:
Workflow shape:
Verification Strategy
Rendered UI Verification
Implementation constraints
```

If any anchor changes, update validators and scaffold tests in Task 4.

- [ ] **Step 5: Review `/plan` for stale or missing guidance**

Inspect `.agents/commands/plan.md` for places where the command must now:

```text
populate new implementation-readiness fields
record workflow-specific implementation obligations
record documentation/anti-drift constraints
avoid leaving new required plan-template fields blank
```

Update only if the template change requires it.

- [ ] **Step 6: Commit the plan-template slice**

```bash
git add templates/spec-workflow/plan.template.md .agents/commands/plan.md
git commit -m "docs: strengthen plan template for implementation readiness"
```

## Task 4: Update Standards, Validators, Scaffolders, And Workflow Tests

**Files:**
- Modify: `standards/command-workflow-contract.md`
- Modify: `standards/spec-driven-workflow.md`
- Review or modify: `standards/workspace.md`
- Modify: `scripts/validate-codex-assets.ps1`
- Modify: `scripts/check-spec-artifacts.ps1`
- Review or modify: `scripts/validate-workflow-receipts.ps1`
- Modify: `scripts/create-app.ps1`
- Modify: `scripts/test-workflow-enforcement.ps1`
- Modify: `scripts/test-workspace.ps1`
- Review or modify: `.agents/skills/cross-platform-app-workflow/SKILL.md`
- Review or modify: `.agents/skills/ui-change-workflow/SKILL.md`
- Review or modify: `.agents/skills/data-change-workflow/SKILL.md`
- Review or modify: `.agents/skills/mobile-validation-workflow/SKILL.md`
- Review or modify: `.agents/skills/release-readiness-workflow/SKILL.md`

**Interfaces:**
- Consumes:
  - Revised command and template contracts from Tasks 2 and 3
  - Existing validator assertions in `scripts/validate-codex-assets.ps1`
  - Existing plan-artifact checks in `scripts/check-spec-artifacts.ps1`
  - Existing scaffold generation in `scripts/create-app.ps1`
  - Existing fixture/test expectations in `scripts/test-workflow-enforcement.ps1` and `scripts/test-workspace.ps1`
  - Existing workflow-wrapper guidance in local skills
- Produces:
  - Enforcement aligned to the new `/implement` and plan-template contracts
  - Generated apps and workflow tests that no longer drift from the command/template pair

- [ ] **Step 1: Align standards with the revised `/implement` ownership and sequencing**

Update standards text so it matches the new contract precisely:

```md
standards/command-workflow-contract.md
- `implement`: require current tasks plus initialized workflow receipts, execute implementation in dependency order, keep implementation evidence current, reconcile documentation and artifacts, and hand off to `/verify`.

standards/spec-driven-workflow.md
- Implement phase narrative reflects sequencing, implementation quality rules, documentation reconciliation, and focused checks before handoff.
- If `/analyze` is repositioned or clarified, phase-map and path prose must move with that decision.
```

Adjust surrounding prose only where it drifts from the new command/template behavior.

- [ ] **Step 2: Decide whether `standards/workspace.md` needs a stronger pointer for documentation reconciliation**

Review whether the current `Fact Ownership Map` and `Documentation Hygiene` sections already cover the command’s new documentation-alignment phase cleanly. If the command now depends on a sharper pointer, add it there once and keep the command pointing back to the canonical owner instead of duplicating prose.

- [ ] **Step 3: Update validator assertions for `/implement` command shape**

In `scripts/validate-codex-assets.ps1`, review and update the `/implement` command assertions. Relevant pattern:

```powershell
"implement" = @(...)
```

Update required needles to cover the revised dense guidance, for example:

```text
Prepare The Implementation Sequence
Apply Implementation Quality Rules
Reconcile Documentation And Artifacts
workflow-specific requirements
focused checks
initialized by `/tasks`
```

Keep assertions semantic and contract-based; do not add brittle prose matching beyond the repo’s current enforcement style.

- [ ] **Step 4: Update plan-template assertions only where the generated plan contract changed**

In `scripts/validate-codex-assets.ps1` and, if needed, `scripts/check-spec-artifacts.ps1`, update required plan-template and generated-plan checks to reflect any newly required implementation-readiness fields. Relevant patterns:

```powershell
foreach ($required in @("...")) { ... }
Assert-Contains -Path $planPath -Needles @(...)
```

Only change these checks where Task 3 intentionally changed the plan-artifact contract.

- [ ] **Step 5: Review receipt validation for implementation-evidence wording drift**

Inspect `scripts/validate-workflow-receipts.ps1` to confirm the revised `/implement` receipt guidance still matches the expected fields and states for:

```text
Implementation evidence
Verification commands
Verification result
Decision/closure
```

Edit only if the command rewrite changes field semantics or required implementation-time recording behavior.

- [ ] **Step 6: Update scaffold generation and workspace tests**

In `scripts/create-app.ps1`, make sure scaffolded `plan.md` content reflects the revised plan-template fields. Then align:

```text
scripts/test-workflow-enforcement.ps1
scripts/test-workspace.ps1
```

so current-template scaffolds and fixture-based checks assert the new contract rather than the old one.

- [ ] **Step 7: Review wrapper skills for stale implementation wording**

Inspect:

```text
.agents/skills/cross-platform-app-workflow/SKILL.md
.agents/skills/ui-change-workflow/SKILL.md
.agents/skills/data-change-workflow/SKILL.md
.agents/skills/mobile-validation-workflow/SKILL.md
.agents/skills/release-readiness-workflow/SKILL.md
```

Update only where the revised `/implement` contract changed implementation-time workflow behavior or evidence wording.

- [ ] **Step 8: Commit the enforcement slice**

```bash
git add standards/command-workflow-contract.md standards/spec-driven-workflow.md standards/workspace.md scripts/validate-codex-assets.ps1 scripts/check-spec-artifacts.ps1 scripts/validate-workflow-receipts.ps1 scripts/create-app.ps1 scripts/test-workflow-enforcement.ps1 scripts/test-workspace.ps1 .agents/skills/cross-platform-app-workflow/SKILL.md .agents/skills/ui-change-workflow/SKILL.md .agents/skills/data-change-workflow/SKILL.md .agents/skills/mobile-validation-workflow/SKILL.md .agents/skills/release-readiness-workflow/SKILL.md
git commit -m "chore: align /implement enforcement and scaffolding"
```

## Task 5: Run Verification And Drift Sweep

**Files:**
- Modify: `docs/plans/2026-07-11-implement-command-plan-template-update.md`
- Review: all files touched in Tasks 2-4

**Interfaces:**
- Consumes:
  - Revised command, template, standards, validators, scaffolders, skills, and tests
- Produces:
  - Verified no-drift workspace state
  - Final execution notes in this plan

- [ ] **Step 1: Run focused governance checks**

Run:

```powershell
./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true
./scripts/test-workflow-enforcement.ps1
./scripts/test-workspace.ps1
```

Expected:
- all pass
- failures, if any, identify the remaining drift surface directly

- [ ] **Step 2: Run focused project-artifact checks if the plan-artifact contract changed**

If Task 3 or Task 4 changed plan-artifact validation behavior, run:

```powershell
./scripts/check-spec-artifacts.ps1 -ProjectPath . -ValidationMode current-template
```

against the relevant generated or canary app fixture as used by the existing harness.

Expected:
- current-template plan validation passes with the revised implementation-readiness contract

- [ ] **Step 3: Run the broad closeout gate if focused checks pass**

Run:

```powershell
./scripts/check-all.ps1
```

Expected:
- full workspace governance suite passes

- [ ] **Step 4: Run a stale-reference sweep**

Run:

```powershell
rg -n "/implement|Prepare The Implementation Sequence|Apply Implementation Quality Rules|Reconcile Documentation And Artifacts|workflow-specific requirements|plan.template.md|implementation readiness|documentation hygiene|focused checks" .agents templates standards scripts projects docs
```

Review the hits and patch only real drift, not historical records that should remain as evidence.

- [ ] **Step 5: Record final notes in the plan and commit**

Update this plan with:

```text
- checks run and results
- any intentionally untouched historical artifacts
- any compatibility-mode exceptions
- whether `/analyze` remained in place or had surrounding wording adjusted
- any follow-up if a stricter current-template migration is deferred
```

Then commit:

```bash
git add docs/plans/2026-07-11-implement-command-plan-template-update.md
git commit -m "docs: record /implement densification verification results"
```

## Spec Coverage Check

- `/implement` command behavior and densification: covered by Task 2.
- execution sequencing, progress, failure handling, and focused-check behavior: covered by Task 2 steps 4-5 and 9.
- implementation quality rules, workflow-specific requirements, and documentation reconciliation: covered by Task 2 steps 6-8.
- plan-template implementation-readiness and anti-drift fields: covered by Task 3.
- standards and command/phase ownership: covered by Task 4 steps 1-2.
- validators and generated-artifact checks: covered by Task 4 steps 3-5.
- scaffolding, workflow wrappers, and workspace tests: covered by Task 4 steps 6-7.
- verification and stale-reference sweep: covered by Task 5.

## Placeholder Scan

- No `TODO`, `TBD`, or “similar to previous task” placeholders are allowed in implementation commits for the governed surfaces touched by this slice.
- Any unchanged historical docs under `docs/superpowers/` or `docs/audit/` should remain unchanged unless they are active governance owners rather than historical records.
- Spec-kit hook/runtime concepts must not appear in final local command or template text unless this slice explicitly adds that runtime, which it does not.

## Type And Contract Consistency

- `/plan` owns `plan.md` only, but the plan template must now capture the implementation-readiness data `/implement` depends on.
- `/tasks` owns `tasks.md`, `workflow-receipts.md`, and gated `checklist.md`.
- `/implement` consumes initialized artifacts, executes work, records implementation evidence, applies quality rules, and reconciles documentation before `/verify`.
- `/verify` remains the closure owner for verification evidence, convergence, and final completion claims.
- `/analyze` either remains a separate contradiction gate with clarified surrounding wording or is explicitly documented as a defensive pass inside `/verify`; do not leave ambiguous ownership.

## Closeout Evidence

- Status on 2026-07-11: implementation and verification work completed; commit steps intentionally not executed because no commit was requested in this run.
- Core contract outcome:
  - `/implement` now uses phased execution, explicit implementation quality rules, focused-check handling, and a required documentation-reconciliation phase before `/verify`.
  - `/plan` and `templates/spec-workflow/plan.template.md` now require implementation-readiness, workflow-specific implementation requirements, implementation sequencing constraints, documentation alignment constraints, and focused implementation checks.
  - `/analyze` now acts as the pre-implementation contradiction gate after `/tasks` and before `/implement`.
- Standards and enforcement aligned:
  - `standards/command-workflow-contract.md`
  - `standards/spec-driven-workflow.md`
  - `scripts/validate-codex-assets.ps1`
  - `scripts/check-spec-artifacts.ps1`
  - `scripts/create-app.ps1`
  - `.agents/skills/cross-platform-app-workflow/SKILL.md`
- Focused checks run:
  - `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`
  - `./scripts/test-workflow-enforcement.ps1`
  - `./scripts/test-workspace.ps1`
  - `./scripts/check-all.ps1`
- Verification result: all focused and broad governance checks passed after fixing the scaffold replacement bug in `scripts/create-app.ps1` for the new backtick-bearing plan-template prompts.
- Historical references intentionally left unchanged:
  - `docs/superpowers/specs/2026-07-10-command-template-density-design.md`
  - earlier plan/spec records under `docs/superpowers/`
  These remain historical evidence rather than active workflow owners.
- Compatibility notes:
  - existing apps remain on `compatibility` mode unless explicitly refreshed
  - generated-app verification passed under `current-template` for the canary scaffold projects created by `scripts/test-workspace.ps1`
- Remaining worktree note: the repository already contained many unrelated dirty changes before and during this slice; verification for this run focused on the governed surfaces touched by the `/implement` and plan-template contract update.

## Execution Handoff

Plan complete and saved to `docs/plans/2026-07-11-implement-command-plan-template-update.md`. Two execution options:

**1. Subagent-Driven (recommended)** - Dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
