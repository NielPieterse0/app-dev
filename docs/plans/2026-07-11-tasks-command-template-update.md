# /tasks Command And Template Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the `/tasks` command and `templates/spec-workflow/tasks.template.md` so task generation, receipt initialization, and gated checklist ownership are explicit, consistent, and enforced across standards, validators, scaffold generation, and workflow checks.

**Architecture:** Treat this as a workflow-governance slice, not a pair of markdown edits. The command doc defines `/tasks` behavior, the task template defines the generated artifact shape, and the enforcement layer must move with them so generated apps, validators, tests, and downstream commands do not drift. Keep the contract narrow: `/tasks` consumes the active `spec.md` and `plan.md`, creates or updates `tasks.md`, initializes `workflow-receipts.md`, initializes gated `checklist.md` when required, and hands off to `/implement`.

**Tech Stack:** Markdown command docs and templates, PowerShell validators and scaffolders, workspace governance tests.

## Global Constraints

- `/tasks` requires the active `spec.md` and `plan.md`, then creates or updates `tasks.md`, `workflow-receipts.md`, and gated `checklist.md`.
- `/tasks` must not assume `workflow-receipts.md` or `checklist.md` already exist before the command runs.
- `plan.md` remains owned by `/plan`; `/tasks` may reference it and require it, but must not redefine plan ownership.
- Existing apps remain on validator `compatibility` mode unless a slice explicitly opts into `current-template`.
- `check-spec-artifacts.ps1` and `validate-workflow-receipts.ps1` remain the enforcement gates for `/tasks`.
- Do not create broad churn across historical spec artifacts unless a validator contract change makes it unavoidable.

## File Structure

- Modify `.agents/commands/tasks.md`
  - Own the executable `/tasks` contract: reads, writes, start gate, execution phases, stop conditions, and completion report.
- Modify `templates/spec-workflow/tasks.template.md`
  - Own the generated `tasks.md` shape and task-format rules.
- Review `templates/spec-workflow/workflow-receipts.template.md`
  - Confirm the receipt template still matches the revised `/tasks` initialization behavior; edit only if command/template changes require it.
- Review `templates/spec-workflow/checklist.template.md`
  - Confirm gated checklist initialization wording still matches revised `/tasks` ownership; edit only if needed.
- Modify `standards/command-workflow-contract.md`
  - Keep the `/tasks` ownership statement aligned with the revised command behavior.
- Modify `standards/spec-driven-workflow.md`
  - Keep phase sequencing, artifact ownership, and `/tasks` evidence expectations aligned with the revised contract.
- Review `.agents/commands/plan.md`
  - Ensure `/plan` hands off to `/tasks` without stale assumptions about later artifacts.
- Review `.agents/commands/implement.md`
  - Ensure `/implement` describes `/tasks` outputs using the revised ownership language.
- Review `.agents/commands/verify.md`
  - Ensure `/verify` still consumes `/tasks` outputs without stale wording.
- Modify `scripts/validate-codex-assets.ps1`
  - Update command-pointer assertions and dense task-template assertions.
- Modify `scripts/check-spec-artifacts.ps1`
  - Update task-artifact contract checks only if the generated `tasks.md` shape changes.
- Modify `scripts/create-app.ps1`
  - Keep scaffolded `tasks.md`, `workflow-receipts.md`, and `checklist.md` generation aligned with the revised command/template contract.
- Modify `scripts/test-workflow-enforcement.ps1`
  - Update task or receipt fixture expectations if contract-sensitive wording changes.
- Modify `scripts/test-workspace.ps1`
  - Update scaffold or validator expectations only if the revised template contract requires it.
- Review `.agents/skills/cross-platform-app-workflow/SKILL.md`
  - Confirm the wrapper workflow still points at the right artifact ownership for `/tasks`.
- Create `docs/plans/2026-07-11-tasks-command-template-update.md`
  - Execution record for this governance slice.

## Task 1: Lock The Revised `/tasks` Contract Before Editing

**Files:**
- Modify: `docs/plans/2026-07-11-tasks-command-template-update.md`
- Review: `.agents/commands/tasks.md`
- Review: `templates/spec-workflow/tasks.template.md`
- Review: `standards/command-workflow-contract.md`
- Review: `standards/spec-driven-workflow.md`

**Interfaces:**
- Consumes:
  - Current `/tasks` command sections in `.agents/commands/tasks.md`
  - Current task template sections in `templates/spec-workflow/tasks.template.md`
  - Ownership rules in `standards/command-workflow-contract.md`
  - Phase rules in `standards/spec-driven-workflow.md`
- Produces:
  - Finalized contract decisions for:
    - unconditional reads vs conditional rereads
    - when receipts and checklists are created
    - which rules belong in `Pre-Step Checks`, execution phases, or post-step checks
    - exact wording drift surfaces that later tasks must update

- [ ] **Step 1: Capture the current contract and the known defects**

Run:

```powershell
rg -n "/tasks|tasks.template.md|workflow-receipts.md|checklist.md|## Task List|validate-workflow-receipts" .agents templates standards scripts
```

Expected:
- hits for `.agents/commands/tasks.md`
- hits for `templates/spec-workflow/tasks.template.md`
- hits for validator and standards files that reference task artifact ownership

- [ ] **Step 2: Write the contract decisions into this plan before implementation**

Record these decisions verbatim in the working notes for the slice:

```text
1. `/tasks` reads the active `spec.md` and `plan.md`, plus the task/receipt/checklist templates and only the standards needed to shape task generation.
2. `/tasks` creates or refreshes `tasks.md`, initializes `workflow-receipts.md`, and initializes `checklist.md` only when gated risk applies.
3. `/tasks` must not list `workflow-receipts.md` or `checklist.md` as normal prerequisites in a way that implies they already exist.
4. Task-format rules such as `T###`, `[P]`, `[US#]`, exact repo-relative paths, and TODO removal belong in task-format or quality sections, not as faux start-gate checks.
5. Abort logic should live in `Stop Conditions` instead of being duplicated inside execution phases.
```

- [ ] **Step 3: Reject unnecessary scope expansion up front**

Record this non-goal in the slice notes:

```text
Do not backfill historical `projects/*/specs/*/tasks.md` artifacts unless compatibility-mode validator changes make a sample update unavoidable.
```

- [ ] **Step 4: Commit the contract-audit checkpoint**

```bash
git add docs/plans/2026-07-11-tasks-command-template-update.md
git commit -m "docs: lock /tasks contract update plan"
```

## Task 2: Rewrite The `/tasks` Command Contract

**Files:**
- Modify: `.agents/commands/tasks.md`
- Review: `.agents/commands/plan.md`
- Review: `.agents/commands/implement.md`
- Review: `.agents/commands/verify.md`

**Interfaces:**
- Consumes:
  - Contract decisions from Task 1
  - Existing command section headings enforced by workspace validators
- Produces:
  - Revised `/tasks` command guidance with stable headings:
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

- [ ] **Step 1: Rewrite `Purpose`, `Start Gate`, and `Required Reads` to remove stale assumptions**

Update `.agents/commands/tasks.md` so it states, in substance:

```md
`/tasks` creates or updates `tasks.md`, `workflow-receipts.md`, and `checklist.md` when gated risk applies.

Start Gate:
- Confirm app `AGENTS.md`, active `spec.md`, and active `plan.md` exist.
- Confirm app `AGENTS.md` and active `plan.md` reference the same active spec.
- Stop if the plan still has unresolved blockers that prevent task sequencing.

Required Reads:
- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/plan.md`
- `../../templates/spec-workflow/tasks.template.md`
- `../../templates/spec-workflow/workflow-receipts.template.md`
- `../../templates/spec-workflow/checklist.template.md` when gated risk applies
```

Reject wording that implies `workflow-receipts.md` and `checklist.md` already exist before `/tasks`.

- [ ] **Step 2: Move format rules out of `Pre-Step Checks` and into execution or quality guidance**

Replace faux checks like these:

```md
- Confirm task IDs will use strict `T001` sequencing.
- Confirm `[P]` is reserved for independent files or independent surfaces.
```

with execution-quality language such as:

```md
- Assign sequential `T###` task IDs in execution order.
- Use `[P]` only for independent files or independent surfaces with no unfinished shared dependency.
- Use `[US#]` labels only for user-story or vertical-increment work.
```

- [ ] **Step 3: Expand `Execution Steps` into clear phases without duplicating stop logic**

Restructure the command around phases such as:

```md
### Phase 1: Review The Active Inputs
### Phase 2: Choose The Task Model
### Phase 3: Create The Task Artifacts
### Phase 4: Write The Task Sequence
### Phase 5: Initialize Workflow Receipts And Gated Checklist
### Phase 6: Run Task Review
### Phase 7: Run Task Checks
```

Keep mismatch and unresolved-blocker failure paths centralized in `Stop Conditions` unless a phase truly cannot continue safely.

- [ ] **Step 4: Tighten `Post-Step Checks`, `Receipt Updates`, and `Completion Report`**

Ensure `Post-Step Checks` contain only end-state assertions such as:

```md
- `tasks.md` exists at `specs/NNN-<slug>/tasks.md`.
- `workflow-receipts.md` exists at `specs/NNN-<slug>/workflow-receipts.md`.
- `checklist.md` exists when gated risk applies.
- No unresolved template placeholders remain.
```

Ensure `Receipt Updates` only describes what `/tasks` records now, not what later commands will close.

- [ ] **Step 5: Align downstream command wording only where ownership language changed**

Check `.agents/commands/plan.md`, `.agents/commands/implement.md`, and `.agents/commands/verify.md` for stale wording like:

```text
assumed from `/specify` or `/plan`
workflow-receipts already exist
later-phase artifact ownership that no longer matches `/tasks`
```

Update only the affected lines; do not broaden the slice into unrelated command rewrites.

- [ ] **Step 6: Commit the command-contract slice**

```bash
git add .agents/commands/tasks.md .agents/commands/plan.md .agents/commands/implement.md .agents/commands/verify.md
git commit -m "docs: refine /tasks command contract"
```

## Task 3: Update The Task Template And Any Direct Template Neighbors

**Files:**
- Modify: `templates/spec-workflow/tasks.template.md`
- Review: `templates/spec-workflow/workflow-receipts.template.md`
- Review: `templates/spec-workflow/checklist.template.md`

**Interfaces:**
- Consumes:
  - Revised `/tasks` command contract from Task 2
  - Current dense task-template requirements enforced by validators
- Produces:
  - Revised `tasks.template.md` that matches the command contract
  - Confirmation about whether receipt/checklist templates also require edits

- [ ] **Step 1: Update the task template so its setup and foundation phases match revised ownership**

Keep the generated shape dense, but correct any lines that encode the wrong ownership model. Target examples:

```md
### Phase 1: Setup
- [ ] T001 Confirm app `AGENTS.md`, `specs/{{SPEC_DIR}}/plan.md`, and `specs/{{SPEC_DIR}}/spec.md` point to the same active spec.
- [ ] T002 Confirm workflow classification in `specs/{{SPEC_DIR}}/workflow-receipts.md`.
- [ ] T003 Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before implementation planning closes.
```

and:

```md
### Phase 2: Foundation
- [ ] T004 Update `specs/{{SPEC_DIR}}/plan.md` ...
- [ ] T005 Update `specs/{{SPEC_DIR}}/workflow-receipts.md` with `/plan` and `/tasks` command evidence ...
```

Keep what still matches the contract; rewrite what encodes stale assumptions.

- [ ] **Step 2: Preserve validator-sensitive dense-template markers**

Do not remove these required anchors unless you update validators in the same slice:

```text
T001
[P]
[US1]
## Dependencies And Order
## Parallel Opportunities
Additional User Stories Or Vertical Increments
Repeat the user story phase
## Task List
```

- [ ] **Step 3: Decide whether receipt and checklist templates need matching edits**

Review whether the revised command wording requires changes in:

```text
templates/spec-workflow/workflow-receipts.template.md
templates/spec-workflow/checklist.template.md
```

Only edit them if the `/tasks` command or task template now expects different initialization text, headings, or pre-implementation state markers.

- [ ] **Step 4: Commit the template slice**

```bash
git add templates/spec-workflow/tasks.template.md templates/spec-workflow/workflow-receipts.template.md templates/spec-workflow/checklist.template.md
git commit -m "docs: align tasks template with /tasks contract"
```

## Task 4: Update Standards, Validators, Scaffolders, And Tests

**Files:**
- Modify: `standards/command-workflow-contract.md`
- Modify: `standards/spec-driven-workflow.md`
- Modify: `scripts/validate-codex-assets.ps1`
- Modify: `scripts/check-spec-artifacts.ps1`
- Modify: `scripts/create-app.ps1`
- Modify: `scripts/test-workflow-enforcement.ps1`
- Modify: `scripts/test-workspace.ps1`
- Review: `.agents/skills/cross-platform-app-workflow/SKILL.md`

**Interfaces:**
- Consumes:
  - Revised command and template contracts from Tasks 2 and 3
  - Existing validator assertions in `scripts/validate-codex-assets.ps1`
  - Existing task artifact checks in `scripts/check-spec-artifacts.ps1`
  - Existing scaffold generation in `scripts/create-app.ps1`
  - Existing fixture/test expectations in `scripts/test-workflow-enforcement.ps1` and `scripts/test-workspace.ps1`
- Produces:
  - Enforcement aligned to the new `/tasks` contract
  - Generated apps and workspace tests that no longer drift from the command/template pair

- [ ] **Step 1: Align standards with the revised ownership language**

Update standards text so it matches the new contract precisely:

```md
standards/command-workflow-contract.md
- `tasks`: require the active spec and `plan.md`, then create or update `tasks.md`, `workflow-receipts.md`, and `checklist.md` when gated risk applies.

standards/spec-driven-workflow.md
- `tasks.md` is created during `/tasks`
- `workflow-receipts.md` is created during `/tasks`
- `checklist.md` is created during `/tasks` for gated work
```

Adjust surrounding prose only where it drifts from the new command/template behavior.

- [ ] **Step 2: Update validator assertions for command and template shape**

In `scripts/validate-codex-assets.ps1`, review and update the `/tasks` command assertions and task-template assertions. Relevant pattern:

```powershell
"tasks" = @(...)
$taskTemplate = Get-Content ...
foreach ($required in @(...)) { ... }
```

Keep assertions semantic and contract-based; do not add brittle prose matching beyond what the repo already enforces.

- [ ] **Step 3: Update artifact validation only if the generated `tasks.md` contract changed**

Review `scripts/check-spec-artifacts.ps1` for task checks such as:

```powershell
Assert-Contains -Path $tasksPath -Needles @("## Task List", "check-spec-artifacts.ps1", "verify-app.ps1")
foreach ($needle in @("## Task Format", "## Dependencies And Order", "## Parallel Opportunities", "[US1]", "[P]", "Repeat the user story phase")) { ... }
```

Only change these checks if Task 3 intentionally changed the generated task artifact shape.

- [ ] **Step 4: Update scaffold generation and test fixtures**

In `scripts/create-app.ps1`, make sure the seeded `tasks.md`, `workflow-receipts.md`, and gated checklist content still reflects the revised `/tasks` contract. Then align:

```text
scripts/test-workflow-enforcement.ps1
scripts/test-workspace.ps1
```

so generated-app and fixture-based checks assert the new contract rather than the old one.

- [ ] **Step 5: Review the wrapper skill for stale ownership wording**

Inspect `.agents/skills/cross-platform-app-workflow/SKILL.md` for references to task/receipt/checklist sequencing. Update only if the revised `/tasks` contract changed the skill-facing guidance.

- [ ] **Step 6: Commit the enforcement slice**

```bash
git add standards/command-workflow-contract.md standards/spec-driven-workflow.md scripts/validate-codex-assets.ps1 scripts/check-spec-artifacts.ps1 scripts/create-app.ps1 scripts/test-workflow-enforcement.ps1 scripts/test-workspace.ps1 .agents/skills/cross-platform-app-workflow/SKILL.md
git commit -m "chore: align /tasks enforcement and scaffolding"
```

## Task 5: Run Verification And Drift Sweep

**Files:**
- Modify: `docs/plans/2026-07-11-tasks-command-template-update.md`
- Review: all files touched in Tasks 2-4

**Interfaces:**
- Consumes:
  - Revised command, template, standards, validators, scaffolder, and tests
- Produces:
  - Verified no-drift workspace state
  - Final execution notes in this plan

- [ ] **Step 1: Run focused governance checks**

Run:

```powershell
./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true
./scripts/test-workspace.ps1
./scripts/test-workflow-enforcement.ps1
```

Expected:
- all pass
- failures, if any, identify the remaining drift surface directly

- [ ] **Step 2: Run the broad closeout gate if focused checks pass**

Run:

```powershell
./scripts/check-all.ps1
```

Expected:
- full workspace governance suite passes

- [ ] **Step 3: Run a stale-reference sweep**

Run:

```powershell
rg -n "/tasks|tasks.template.md|workflow-receipts.md|checklist.md|initialized by `/tasks`|assumed from `/specify` or `/plan`" .agents templates standards scripts projects docs
```

Review the hits and patch only real drift, not historical records that should remain as evidence.

- [ ] **Step 4: Record final notes in the plan and commit**

Update this plan with:

```text
- checks run and results
- any intentionally untouched historical artifacts
- any compatibility-mode exceptions
- any follow-up if a stricter current-template migration is deferred
```

Then commit:

```bash
git add docs/plans/2026-07-11-tasks-command-template-update.md
git commit -m "docs: record /tasks contract verification results"
```

## Spec Coverage Check

- `/tasks` command behavior: covered by Task 2.
- `tasks.template.md` generated artifact shape: covered by Task 3.
- Standards and command/phase ownership: covered by Task 4 step 1.
- Validators and artifact checks: covered by Task 4 steps 2-3.
- Scaffolding and test harness drift prevention: covered by Task 4 steps 4-5.
- Verification and stale-reference sweep: covered by Task 5.

## Placeholder Scan

- No `TODO`, `TBD`, or “similar to previous task” placeholders are allowed in implementation commits for the governed surfaces touched by this slice.
- Any unchanged historical docs under `docs/superpowers/` or `docs/audit/` should remain unchanged unless they are active governance owners rather than historical records.

## Type And Contract Consistency

- `/tasks` owns `tasks.md`, `workflow-receipts.md`, and gated `checklist.md`.
- `/plan` owns `plan.md` only.
- `/implement` consumes initialized `tasks.md`, `workflow-receipts.md`, and gated `checklist.md`.
- `/verify` closes verification evidence rather than initializing `/tasks` artifacts.

## Execution Handoff

Plan complete and saved to `docs/plans/2026-07-11-tasks-command-template-update.md`. Two execution options:

**1. Subagent-Driven (recommended)** - Dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?
