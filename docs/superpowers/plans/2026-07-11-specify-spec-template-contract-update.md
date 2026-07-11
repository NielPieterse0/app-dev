# Specify Command And Spec Template Contract Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rework `/specify` and `templates/spec-workflow/spec.template.md` so `/specify` is a true spec-only first step, then update every downstream command, validator, scaffold, skill pointer, and workspace test that still assumes `/specify` also creates later-phase artifacts.

**Architecture:** Treat this as a workflow-contract migration across five layers: command docs, canonical standards, spec template content, validation/enforcement scripts, and scaffold/test harnesses. The key boundary is phase ownership: `/specify` owns only `spec.md`; later commands own later artifacts; workflow receipts and gated checklists must no longer be backfilled during spec creation. Use one spec-only validator path for `/specify` and preserve broader artifact validation for later phases.

**Tech Stack:** Markdown workflow contracts, PowerShell validators and scaffold scripts, workspace governance tests, generated app template assets.

## Global Constraints

- `/specify` must create or update only `specs/NNN-<slug>/spec.md`; it must not write `plan.md`, `tasks.md`, `workflow-receipts.md`, `checklist.md`, or app `AGENTS.md`.
- `spec.template.md` must use the approved structure and wording, keep `Risk level`, and stay product-focused and implementation-agnostic.
- The command chain must remain internally consistent: no later command may require artifacts that an earlier phase no longer creates.
- Established app validation behavior must remain safe under `compatibility`; template/generated-app enforcement may use newer validation only where explicitly intended.
- Do not retroactively rewrite existing `projects/signal/specs/*` artifacts to satisfy the new template or command contract unless a file is being updated for another direct reason.
- Keep canonical ownership centralized: workflow sequencing in `standards/spec-driven-workflow.md`, command obligations in `.agents/commands/*.md`, capability routing in `standards/codex-capabilities.md`, and operational app-workflow behavior in `.agents/skills/cross-platform-app-workflow/SKILL.md`.
- Preserve unrelated pending edits in dirty files; merge only the hunks required for this contract migration.

---

## Verified Current State

- `.agents/commands/specify.md` still reads and writes `tasks.md`, `workflow-receipts.md`, and `checklist.md`, and still validates against those downstream artifacts.
- `templates/spec-workflow/spec.template.md` now matches the approved structure and retains `Risk level`; the remaining work is to align downstream commands, validators, and scaffolds around it.
- `.agents/commands/plan.md` still assumes `tasks.md` and `workflow-receipts.md` already exist before `/plan` runs, which is incompatible with a spec-only `/specify`.
- `standards/command-workflow-contract.md` still describes `specify` as initializing workflow classification instead of only creating/updating the numbered spec.
- `scripts/check-spec-artifacts.ps1` still treats `spec.md`, `tasks.md`, and `workflow-receipts.md` as a coupled minimum set and has no spec-only mode for `/specify`.
- `scripts/validate-codex-assets.ps1` still asserts dense `/specify` wording such as `Task List`, `Command path used:`, and `ValidationMode current-template` in `.agents/commands/specify.md`.
- `scripts/test-workspace.ps1` and `scripts/create-app.ps1` still scaffold and validate fully populated `specs/001-initial/` artifact sets, which may need narrowing or explicit bootstrap-mode wording if `/specify` becomes the first real authoring step.
- `.agents/skills/cross-platform-app-workflow/SKILL.md` and `standards/codex-capabilities.md` are current routing owners for app workflow behavior and must stay aligned with any command-phase ownership changes.

## File Structure

- `.agents/commands/specify.md`: primary command contract to rewrite as spec-only.
- `templates/spec-workflow/spec.template.md`: primary spec artifact template to refine for scope, quality, and review structure.
- `.agents/commands/plan.md`: must be reconciled so it no longer requires artifacts `/specify` no longer creates.
- `.agents/commands/tasks.md`: make later-phase artifact ownership explicit and ensure it no longer assumes `/specify` created downstream artifacts.
- `standards/command-workflow-contract.md`: update the command responsibility summary to match the new phase ownership.
- `standards/spec-driven-workflow.md`: update phase narrative, artifact roles, and validation wording so `/specify` is explicitly spec-only.
- `scripts/check-spec-artifacts.ps1`: split or parameterize validation so `/specify` can validate only `spec.md` while later phases still validate broader artifact sets.
- `scripts/validate-codex-assets.ps1`: update command-density assertions and spec-workflow checks to match the new `/specify` and `spec.template` contracts.
- `scripts/test-workspace.ps1`: update generated-app expectations and harness assertions where they incorrectly encode the old `/specify` contract.
- `scripts/create-app.ps1`: inspect whether seeded `spec.md` replacement content or generated guidance now conflicts with the tightened `spec.template` and `/specify` contract.
- `.agents/skills/cross-platform-app-workflow/SKILL.md`: confirm it owns any removed operational behavior that no longer belongs in app-level docs or `/specify`.
- `standards/codex-capabilities.md`: confirm it remains the authoritative routing owner if any capability wording is removed from command docs.
- `docs/superpowers/plans/2026-07-11-specify-spec-template-contract-update.md`: execution record for this migration.

---

### Task 1: Lock The New `/specify` And Spec Template Contract

**Files:**
- Modify: `docs/superpowers/plans/2026-07-11-specify-spec-template-contract-update.md`
- Review: `.agents/commands/specify.md`
- Review: `templates/spec-workflow/spec.template.md`
- Review: `standards/spec-driven-workflow.md`
- Review: `standards/command-workflow-contract.md`

**Interfaces:**
- Consumes: the attached `/specify` comments, the earlier review findings, and the current phase model in standards.
- Produces: the exact retained responsibilities and review checks that all later edits must follow.

- [ ] **Step 1: Re-read the governing command and standards files**

Run:

```powershell
Get-Content .agents/commands/specify.md
Get-Content templates/spec-workflow/spec.template.md
Get-Content standards/spec-driven-workflow.md
Get-Content standards/command-workflow-contract.md
```

Expected: confirms the live mismatches between the intended spec-only `/specify` phase and the current broader artifact assumptions.

- [ ] **Step 2: Record the exact new `/specify` boundary**

Capture this in the plan notes and use it as the non-negotiable contract:

```text
/specify reads workflow/app rules, creates or selects specs/NNN-<slug>/, writes spec.md, runs spec-only review/validation, and reports the next step.
/specify does not write plan.md, tasks.md, workflow-receipts.md, checklist.md, or app AGENTS.md.
```

- [ ] **Step 3: Record the exact spec-template additions**

Capture these required sections before touching the template:

```text
Summary
Problem
Scope -> In Scope / Out Of Scope
User Scenarios And Testing
Edge Cases
Requirements
Success Criteria
Data, Permissions, And Security
UX And Platform Notes
Assumptions
Risks And Open Questions
Verification Intent
```

- [ ] **Step 4: Record the review checklist categories `/specify` must enforce**

Use this as the command-review basis:

```text
CHK-01 one feature or one vertical slice only
CHK-02 bounded scope
CHK-03 explicit exclusions
CHK-04 clear actors and outcomes
CHK-05 independent test per main story
CHK-06 stable FR/SC IDs
CHK-07 risk level chosen appropriately
CHK-08 requirement completeness
CHK-09 requirement clarity/testability
CHK-10 requirement consistency
CHK-11 measurable success criteria
CHK-12 scenario coverage
CHK-13 edge-case coverage
CHK-14 relevant non-functional requirements
CHK-15 dependencies and assumptions documented
CHK-16 open questions/ambiguities surfaced
CHK-17 data/permission/sensitive-operation impact described
CHK-18 no placeholders remain
```

- [ ] **Step 5: Stop if the locked contract still implies later-phase artifacts**

Run:

```powershell
rg -n "tasks\.md|workflow-receipts\.md|checklist\.md|Command path used:|Task List" .agents/commands/specify.md standards/command-workflow-contract.md
```

Expected: every surviving mention is either being removed or explicitly justified as historical context to patch in later tasks.

- [ ] **Step 6: Commit the locked implementation scope**

```bash
git add docs/superpowers/plans/2026-07-11-specify-spec-template-contract-update.md
git commit -m "docs: define specify and spec template migration plan"
```

### Task 2: Rewrite `.agents/commands/specify.md` As A Spec-Only Command

**Files:**
- Modify: `.agents/commands/specify.md`

**Interfaces:**
- Consumes: Task 1 contract and quality checklist.
- Produces: a `/specify` command that creates or updates only `spec.md` and reviews it against the new quality bar.

- [ ] **Step 1: Replace the over-scoped read/write lists**

Remove command requirements for:

```text
tasks.template.md
workflow-receipts.template.md
checklist.template.md
tasks.md
workflow-receipts.md
checklist.md
App AGENTS.md active specification pointer updates
```

Retain only:

```text
Required Reads: root AGENTS, app AGENTS, governing standards, spec.template.md
Required Writes: specs/NNN-<slug>/spec.md
```

- [ ] **Step 2: Rewrite the execution phases**

Use the new structure:

```text
Phase 1 Parse The Request
Phase 2 Name The Spec
Phase 3 Create Or Select The Spec Folder
Phase 4 Write The Spec
Phase 5 Apply Spec Quality Rules
Phase 6 Run Spec Review
```

Move folder-numbering details into Phase 3 and remove them from `Start Gate`.

- [ ] **Step 3: Add the explicit requirement-writing quality rules**

Insert directive wording for:

```text
Requirement Completeness
Requirement Clarity
Requirement Consistency
Acceptance Criteria Quality
Scenario Coverage
Edge Case Coverage
Non-Functional Requirements
Dependencies And Assumptions
Ambiguities And Conflicts
```

- [ ] **Step 4: Add the numbered `CHK-##` review checklist**

Convert the free-form review bullets into `CHK-01` through `CHK-17` items so downstream reviews can reference exact failures.

- [ ] **Step 5: Minimize post-step checks**

Keep only:

```text
spec.md exists
no unresolved placeholders remain
```

Move stable IDs, independent tests, and one-slice scope into the numbered review checklist rather than duplicating them.

- [ ] **Step 6: Re-read the final command text for internal consistency**

Run:

```powershell
Get-Content .agents/commands/specify.md
```

Expected: no mention remains that implies `/specify` initializes later-phase artifacts.

- [ ] **Step 7: Commit the command rewrite**

```bash
git add .agents/commands/specify.md
git commit -m "docs: make specify a spec-only workflow command"
```

### Task 3: Refine `templates/spec-workflow/spec.template.md` To Match The New Command

**Files:**
- Modify: `templates/spec-workflow/spec.template.md`

**Interfaces:**
- Consumes: Task 1 structure and Task 2 quality/review rules.
- Produces: a stronger spec template that supports `/specify` without relying on later-phase artifacts.

- [ ] **Step 1: Add explicit scope structure**

Insert:

```md
## Scope

### In Scope

### Out Of Scope
```

This gives `/specify` a place to record exclusions instead of burying them in prose.

- [ ] **Step 2: Rename and strengthen the data/security section**

Use:

```md
## Data, Permissions, And Security
```

and keep explicit prompts for data impact, permissions/access, and sensitive operations.

- [ ] **Step 3: Keep the template product-focused**

Remove or avoid:

```text
framework names
API choices
implementation steps
artifact-ownership assumptions for plan/tasks/receipts/checklist
```

Keep verification intent at the “what should later be verified” level rather than instructing `/specify` to close later-phase evidence.

- [ ] **Step 4: Strengthen placeholders around story independence and measurable outcomes**

Ensure the template clearly prompts for:

```text
independently valuable story
why this priority
independent test
observable acceptance scenarios
measurable or objectively observable success criteria
```

- [ ] **Step 5: Re-read the template against the `/specify` checklist**

Run:

```powershell
Get-Content templates/spec-workflow/spec.template.md
```

Expected: every `CHK-##` item from Task 1 is supported by a clear section or prompt in the template.

- [ ] **Step 6: Commit the template refinement**

```bash
git add templates/spec-workflow/spec.template.md
git commit -m "docs: strengthen spec template for spec-only specify flow"
```

### Task 4: Reconcile Downstream Command Ownership To Prevent Workflow Drift

**Files:**
- Modify: `.agents/commands/plan.md`
- Modify: `.agents/commands/tasks.md`
- Modify if needed: `.agents/commands/implement.md`
- Modify if needed: `.agents/commands/verify.md`
- Modify: `standards/command-workflow-contract.md`
- Modify: `standards/spec-driven-workflow.md`

**Interfaces:**
- Consumes: spec-only `/specify`.
- Produces: a coherent phase chain in which each later command requires only artifacts that earlier phases actually create.

- [ ] **Step 1: Remove impossible prerequisites from `/plan`**

`/plan` must stop requiring `tasks.md` and `workflow-receipts.md` before it runs if those artifacts are no longer created by `/specify`.

Decide and implement one clear ownership model:

```text
Model A:
/plan creates/updates plan.md only
/tasks creates tasks.md and initializes workflow-receipts.md and checklist.md when needed
```

or

```text
Model B:
/plan creates plan.md and initializes workflow-receipts.md
/tasks creates tasks.md and checklist.md when needed
```

Use one model consistently everywhere else in this plan.

- [ ] **Step 2: Update `standards/command-workflow-contract.md`**

Rewrite command responsibilities so `specify` is spec-only and the later artifact owners are explicit.

- [ ] **Step 3: Update `standards/spec-driven-workflow.md`**

Patch:

```text
Phase To Command Map
Lean Path narrative
Gated Path narrative
artifact-role wording where phase ownership changed
```

so the standard matches the new command chain and no longer implies `/specify` seeds later artifacts.

- [ ] **Step 4: Review `tasks.md`, `implement.md`, and `verify.md` for stale assumptions**

Run:

```powershell
rg -n "specify|workflow-receipts|checklist|tasks\.md|plan\.md" .agents/commands
```

Expected: every prerequisite aligns with the newly chosen ownership model.

- [ ] **Step 5: Commit the command-chain reconciliation**

```bash
git add .agents/commands/plan.md .agents/commands/tasks.md .agents/commands/implement.md .agents/commands/verify.md standards/command-workflow-contract.md standards/spec-driven-workflow.md
git commit -m "docs: reconcile workflow phase ownership after specify split"
```

### Task 5: Split Validation So `/specify` Can Pass Without Later-Phase Artifacts

**Files:**
- Modify: `scripts/check-spec-artifacts.ps1`
- Modify if needed: `scripts/common.ps1`

**Interfaces:**
- Consumes: new command ownership model.
- Produces: one validation path that checks only `spec.md` for `/specify`, plus the existing broader artifact validation for later phases.

- [ ] **Step 1: Design the validation mode split**

Introduce a validation mode or explicit flag for spec-only checks, for example:

```text
spec-only
compatibility
current-template
```

or a similarly clear scheme that separates:

```text
spec artifact checks
full workflow artifact checks
```

- [ ] **Step 2: Make `tasks.md` and `workflow-receipts.md` conditional**

Only require them when the selected validation mode is a later-phase or full-artifact mode.

Preserve existing placeholder, numbering, and section checks for those files when they are in scope.

- [ ] **Step 3: Keep `spec.md` checks strong**

Retain checks for:

```text
required sections
FR/SC IDs
risk level
independent test wording
placeholder removal
scope-related sections added by the new template
```

- [ ] **Step 4: Update any helper functions only if shared logic is needed**

If `common.ps1` needs a shared “active spec path” or artifact-mode helper, add it there once instead of duplicating logic.

- [ ] **Step 5: Run focused validator inspection**

Run:

```powershell
Get-Content scripts/check-spec-artifacts.ps1
```

Expected: the validator can explain exactly how `/specify` succeeds without `tasks.md`, `workflow-receipts.md`, or `checklist.md`.

- [ ] **Step 6: Commit the validator split**

```bash
git add scripts/check-spec-artifacts.ps1 scripts/common.ps1
git commit -m "feat: add spec-only validation path for specify"
```

### Task 6: Update Workspace Validators And Harness Tests To The New Contract

**Files:**
- Modify: `scripts/validate-codex-assets.ps1`
- Modify: `scripts/test-workspace.ps1`
- Modify if needed: `scripts/test-workflow-enforcement.ps1`
- Modify if needed: `scripts/test-analyze-spec.ps1`

**Interfaces:**
- Consumes: new command wording, new template shape, and new validator modes.
- Produces: workspace enforcement that validates the updated contract instead of reintroducing the old one.

- [ ] **Step 1: Replace stale `/specify` command assertions**

In `scripts/validate-codex-assets.ps1`, remove required needles that no longer belong in `.agents/commands/specify.md`, especially:

```text
Task List
Command path used:
ValidationMode current-template
```

Replace them with the new spec-only markers, such as:

```text
specs/NNN-<slug>/spec.md
spec.template.md
one feature or one vertical slice
CHK-01
spec-only validation wording
```

- [ ] **Step 2: Update spec-workflow asset assertions**

If `validate-codex-assets.ps1` asserts old spec-template content, update the required section names to include:

```text
Scope
In Scope
Out Of Scope
Data, Permissions, And Security
```

- [ ] **Step 3: Update harness tests for generated apps and workflow enforcement**

Inspect `scripts/test-workspace.ps1`, `scripts/test-workflow-enforcement.ps1`, and `scripts/test-analyze-spec.ps1` for any assumption that `/specify` or the initial scaffold already implies tasks/receipts/checklists at the command-contract level.

Keep scaffold tests that are still intentionally true, but remove expectations that now belong only to later phases.

- [ ] **Step 4: Review command and validator drift together**

Run:

```powershell
git diff -- .agents/commands/specify.md templates/spec-workflow/spec.template.md scripts/check-spec-artifacts.ps1 scripts/validate-codex-assets.ps1 scripts/test-workspace.ps1 scripts/test-workflow-enforcement.ps1 scripts/test-analyze-spec.ps1
```

Expected: assertions and source documents describe the same phase contract.

- [ ] **Step 5: Commit the enforcement updates**

```bash
git add scripts/validate-codex-assets.ps1 scripts/test-workspace.ps1 scripts/test-workflow-enforcement.ps1 scripts/test-analyze-spec.ps1
git commit -m "test: align workspace enforcement to specify spec-only contract"
```

### Task 7: Reconcile Skill Pointers, Scaffold Output, And Live Artifacts

**Files:**
- Modify if needed: `.agents/skills/cross-platform-app-workflow/SKILL.md`
- Modify if needed: `.agents/skills/cross-platform-app-workflow/references/spec-driven-workflow.md`
- Modify if needed: `standards/codex-capabilities.md`
- Modify if needed: `scripts/create-app.ps1`
- Review only if needed: `projects/signal/specs/001-initial/spec.md`
- Review only if needed: other live sample artifacts under `projects/signal/specs/`

**Interfaces:**
- Consumes: the migrated command/standard/validator contracts.
- Produces: no remaining pointer or scaffold text that contradicts the new `/specify` model.

- [ ] **Step 1: Confirm the skill still owns the right operational behavior**

The skill should keep operational app-workflow guidance, but it must not restate the old assumption that `/specify` initializes workflow receipts or task artifacts.

- [ ] **Step 2: Inspect `scripts/create-app.ps1` for seeded spec wording drift**

The initial spec seeding logic may still inject phrases that assume aligned `tasks.md` and `workflow-receipts.md` exist from the start. Patch only the lines that now contradict the new ownership model.

- [ ] **Step 3: Review live example artifacts for misleading contract text**

Check whether `projects/signal/specs/001-initial/spec.md` or similar seeded examples are now acting as de facto documentation of the old model. Do not retroactively rewrite them to the new contract unless a direct fix is required; otherwise record them as historical compatibility artifacts.

- [ ] **Step 4: Keep routing ownership centralized**

If `standards/codex-capabilities.md` needs any wording change, keep it limited to skill-loading/routing ownership rather than command-sequencing detail.

- [ ] **Step 5: Commit pointer and scaffold reconciliation**

```bash
git add .agents/skills/cross-platform-app-workflow/SKILL.md .agents/skills/cross-platform-app-workflow/references/spec-driven-workflow.md standards/codex-capabilities.md scripts/create-app.ps1 projects/signal/specs
git commit -m "docs: remove specify drift from skills and scaffold examples"
```

### Task 8: Prove The Migration With Focused And Full Verification

**Files:**
- Modify: `docs/superpowers/plans/2026-07-11-specify-spec-template-contract-update.md`

**Interfaces:**
- Consumes: all prior tasks.
- Produces: closeout evidence that command docs, templates, validators, scaffolds, and tests are aligned.

- [ ] **Step 1: Run focused workflow-governance checks**

Run:

```powershell
scripts/validate-codex-assets.ps1 -RequirePythonToml:$true
scripts/test-workspace.ps1
scripts/test-workflow-enforcement.ps1
scripts/test-analyze-spec.ps1
git diff --check
```

Expected: command contracts, template assets, and workflow enforcement all pass with the new spec-only `/specify` model.

- [ ] **Step 2: Run the canonical full governance gate**

Run:

```powershell
scripts/check-all.ps1
```

Expected: the full workspace governance sequence passes after the contract migration.

- [ ] **Step 3: Inspect final repo scope**

Run:

```powershell
git status --short
git diff --stat
git diff -- .agents/commands templates/spec-workflow standards scripts .agents/skills projects/signal/specs docs/superpowers/plans
```

Expected: only the intended `/specify` / `spec.template` contract migration and its anti-drift follow-ons remain in the diff.

- [ ] **Step 4: Record closeout evidence in this plan**

Append notes for:

- final changed files
- validation modes introduced or changed
- commands run
- any live sample artifacts updated
- any skipped checks and exact blockers

- [ ] **Step 5: Commit the final closeout**

```bash
git add .agents/commands templates/spec-workflow standards scripts .agents/skills projects/signal/specs docs/superpowers/plans
git commit -m "docs: finalize specify and spec template workflow migration"
```

## Self-Review

- Spec coverage: the plan covers the primary command/template edits plus every directly affected drift surface discovered in the live repo: `/plan`, `/tasks`, standards, validators, test harnesses, scaffold generation, and workflow skill pointers.
- Placeholder scan: no `TODO`, `TBD`, “implement later”, or undefined follow-on owners remain.
- Interface consistency: the plan consistently treats `/specify` as spec-only and explicitly assigns later artifact ownership to later phases.
- Drift check: validator assertions, command docs, standards, and skill pointers are all included so the repo cannot silently enforce the old contract after the visible docs change.
- Dirty-worktree safety: the plan explicitly requires diff review before editing already-dirty standards and skill files.

## Closeout Evidence

- Status on 2026-07-11: implementation and verification work completed; commit steps intentionally not executed because no commit was requested in this run.
- Core contract outcome: `/specify` now creates or updates only `specs/NNN-<slug>/spec.md`; `plan.md` remains owned by `/plan`; `tasks.md`, `workflow-receipts.md`, and gated `checklist.md` are initialized later instead of during spec creation.
- Validation modes: `scripts/check-spec-artifacts.ps1` now supports `spec-only`, `compatibility`, and `current-template`.
- Focused checks run:
  - `scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`
  - `scripts/test-workflow-enforcement.ps1`
  - `scripts/test-analyze-spec.ps1`
  - `scripts/test-workspace.ps1`
  - `scripts/check-all.ps1`
  - `git diff --check`
- Verification result: all workflow and governance checks passed after final cleanup of the unrelated trailing-whitespace blocker in `.agents/skills/release-readiness-workflow/SKILL.md`.
- Final changed surfaces reviewed:
  - command contracts under `.agents/commands/`
  - workflow standards under `standards/`
  - spec workflow templates under `templates/spec-workflow/`
  - scaffold and validation scripts under `scripts/`
  - workflow-skill and routing pointers touched by the contract split
- Live historical artifacts: existing `projects/signal/specs/*` artifacts were not retrofitted wholesale; compatibility behavior was preserved.
- Remaining open items from the original checklist:
  - per-task commit steps were intentionally deferred because the user did not request a commit
  - the final commit step in Task 8 remains intentionally deferred for the same reason
- Updated finding status:
  - previous finding that `scripts/check-all.ps1` had not been run is resolved
  - previous finding that `git diff --check` failed is resolved
  - previous finding that the plan lacked closeout evidence is resolved
