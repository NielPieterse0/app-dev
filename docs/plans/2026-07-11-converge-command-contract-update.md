# /converge Command Contract Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Introduce a dense standalone `/converge` command, derived from `/analyze` and the legacy convergence intent, then reconcile commands, standards, registries, validators, templates, and workflow pointers across the repo so convergence is no longer implicitly owned by `/verify`.

**Architecture:** Treat this as a workflow-governance slice, not a single markdown-file addition. `.agents/commands/converge.md` will become the human-facing post-implementation convergence gate, `/analyze` remains the pre-implementation model builder and registry-preflight gate, `/implement` remains the owner of Applicable Standards Checklist generation and implementation evidence, and `/verify` narrows to verification evidence plus rendered checks after convergence is already closed. The implementation must move the phase model, machine-readable registry metadata, validator assumptions, command density checks, and workflow pointers together so there is one clear owner split instead of overlapping partial truths.

**Tech Stack:** Markdown command contracts and plans, PowerShell workflow validators and tests, JSON standards registries, spec-workflow templates, workflow receipts, workspace governance scripts.

## Global Constraints

- Plan lives under `docs/plans/` per local user instruction, not under `docs/superpowers/plans/`.
- `/converge` must be written in the same dense command style as `.agents/commands/analyze.md`.
- `/converge` must explicitly refer back to `/analyze` instead of duplicating its full modeling purpose without attribution.
- Most of `/converge` Phase 3 must reuse or review the analysis models already developed by `/analyze`, then refresh them against live implementation and post-implement task state.
- `/converge` must support dynamic standard-registry selection in the same spirit as `/analyze`, using `scripts/get-applicable-standard-rules.ps1` and applicable `standards/registry/*.rules.json` families.
- `/converge` must remain append-only with respect to convergence tasks in `tasks.md`; it must not rewrite prior phases, renumber tasks, or edit application code.
- `/implement` remains the owner of Applicable Standards Checklist generation, statuses, and implementation evidence in `workflow-receipts.md`.
- `/verify` remains the owner of required verification evidence, rendered checks, and final completion closure after convergence has passed.
- Historical evidence under `docs/superpowers/`, prior plans, audits, and older spec artifacts is not an active workflow owner. Review those surfaces for reference only; patch them only if they are still presented as active guidance.
- Existing app validators stay on `compatibility` mode unless this slice intentionally changes current-template command expectations.
- Do not import upstream spec-kit runtime hooks, `.specify/extensions.yml`, or other foreign workflow runtime assumptions into local app-dev governance.

## Decision Gates To Resolve First

- **Owner split:** introducing `/converge` means the current statement that convergence is closed inside `/verify` must be removed or narrowed on every active-owner surface.
- **Phase order:** choose one canonical post-implementation path and use it everywhere:
  - lean: `spec -> plan -> tasks -> analyze -> implement -> converge -> verify -> handoff`
  - gated: `clarify -> spec -> checklist -> plan -> tasks -> analyze -> implement -> converge -> verify -> handoff`
- **Registry support:** decide whether `converge` becomes a first-class `phase` value in applicable registry rules and in `get-applicable-standard-rules.ps1` output. Default assumption for this slice: yes.
- **Script boundary:** default assumption is command-only convergence with no new `scripts/converge-spec.ps1`. Create or broaden a script only if validator/test coverage becomes too weak to enforce the promised contract.

## Affected Artifact Map

- Create `.agents/commands/converge.md`
  - New dense command contract for post-implementation convergence, including the `/analyze` reference, append-only task behavior, dynamic registry review, severity model, report shape, and handoff to `/implement` or `/verify`.
- Modify `.agents/commands/implement.md`
  - Handoff must point to `/converge` rather than straight to `/verify`.
- Modify `.agents/commands/verify.md`
  - Remove ownership language that says `/verify` closes convergence; keep `/verify` focused on verification evidence and final closure after convergence.
- Review or modify `.agents/commands/analyze.md`
  - Ensure `/analyze` and `/converge` use compatible language about shared analysis models, registry preflight, and artifact boundaries.
- Review or modify `.agents/commands/tasks.md`
  - Keep downstream handoff wording and task-phase assumptions aligned with the new workflow sequence.
- Modify `standards/spec-driven-workflow.md`
  - Update phase-to-command map, lean path, gated path, and convergence semantics to make `/converge` explicit.
- Modify `standards/command-workflow-contract.md`
  - Add `/converge` command responsibility and adjust `/implement` and `/verify` owner boundaries.
- Modify `standards/workspace.md`
  - Update the command list and fact-ownership map where it currently says `verify` includes convergence closure.
- Review or modify `AGENTS.md`
  - Update top-level Lean/Gated path pointers only if they still present `/verify` as the convergence owner after the standards move.
- Modify `standards/workspace-manifest.psd1`
  - Add `.agents/commands/converge.md` to governed required-path lists and any command-surface manifests consumed by validators.
- Modify `standards/registry/command-workflow-contract.rules.json`
  - Add converge-phase command rules and revise implement/verify rule boundaries.
- Modify `standards/registry/spec-driven-workflow.rules.json`
  - Add converge-phase semantics, lean/gated path changes, and the new phase order.
- Modify `standards/registry/workspace.rules.json`
  - Update workspace-level rules that describe the executable command spine and convergence ownership.
- Review or modify `standards/registry/codex-capabilities.rules.json`
  - Patch only if capability-routing or wrapper-skill references assume the old command set or old convergence owner split.
- Review or modify `standards/registry/testing.rules.json`
  - Patch only if verify/converge handoff changes which phase owns rendered or verification gate language.
- Review `standards/registry/{constitution,stack,security,scripting,module-contract,adaptive-layouts}.rules.json`
  - Confirm phase metadata, trigger kinds, and owner surfaces remain sufficient when `converge` becomes a selectable phase.
- Review or modify `scripts/get-applicable-standard-rules.ps1`
  - Ensure `-Phase converge` and changed-file sets including `.agents/commands/converge.md` produce sensible rule output without creating implementation evidence.
- Modify `scripts/validate-codex-assets.ps1`
  - Add dense-command assertions for `/converge`, update the commanded file inventory, and adjust existing `/verify` expectations if they currently enforce convergence ownership.
- Modify `scripts/test-workflow-enforcement.ps1`
  - Add convergence-phase rule-generation and command-handoff coverage.
- Review or modify `scripts/check-spec-artifacts.ps1`
  - Patch only if command-phase expectations or current-template command checks need the new `/converge` surface.
- Review or modify `scripts/validate-workflow-receipts.ps1`
  - Patch only if receipt validation needs to understand convergence-phase blockers or command-path entries before `/verify`.
- Review `scripts/test-workspace.ps1`
  - Patch only if workspace canary expectations or command inventories need to include `/converge`.
- Review `scripts/check-all.ps1`
  - Confirm the canonical governance gate naturally exercises the updated surfaces; patch only if it hardcodes command counts or workflow expectations.
- Review or modify `.agents/skills/cross-platform-app-workflow/SKILL.md`
  - Keep the workflow spine pointer aligned with the new command list and phase order.
- Review or modify `.agents/skills/{ui-change-workflow,data-change-workflow,mobile-validation-workflow,release-readiness-workflow}/SKILL.md`
  - Update only if any wrapper mentions `/verify` as the first post-implement stop or otherwise conflicts with the new owner split.
- Review or modify `templates/spec-workflow/converge.template.md`
  - Keep the template aligned with the new command’s report and handoff expectations if the command now requires fields the template does not support.
- Review or modify `templates/spec-workflow/tasks.template.md`
  - Update only if the generated workflow path or downstream command references need to show `/converge`.
- Review or modify `templates/spec-workflow/plan.template.md`
  - Update only if implementation-readiness or verification strategy prose explicitly assumes `/implement -> /verify`.
- Modify `docs/plans/2026-07-11-converge-command-contract-update.md`
  - Record decisions, scope boundaries, rule families reviewed, verification results, and repo-wide drift findings for this slice.

## Task 1: Lock The New Convergence Owner Split Before Editing

**Files:**
- Modify: `docs/plans/2026-07-11-converge-command-contract-update.md`
- Review: `.agents/commands/analyze.md`
- Review: `.agents/commands/implement.md`
- Review: `.agents/commands/verify.md`
- Review: `standards/spec-driven-workflow.md`
- Review: `standards/command-workflow-contract.md`
- Review: `standards/workspace.md`
- Review: `AGENTS.md`

**Interfaces:**
- Consumes:
  - current `/analyze` contract
  - missing `.agents/commands/converge.md`
  - current standards stating convergence is closed inside `/verify`
  - current command, standards, and workspace-owner wording
- Produces:
  - one explicit owner split for `/analyze`, `/implement`, `/converge`, and `/verify`
  - one canonical lean/gated path with `/converge` inserted
  - one bounded list of active-owner surfaces that must move together

- [ ] **Step 1: Capture every active-owner surface that currently defines convergence**

Run:

```powershell
rg -n "converge|convergence|/verify|/implement|/analyze" AGENTS.md .agents standards scripts templates
```

Expected:
- hits in `standards/spec-driven-workflow.md`
- hits in `standards/command-workflow-contract.md`
- hits in `standards/workspace.md`
- hits in `.agents/commands/verify.md`
- confirmation that `.agents/commands/converge.md` does not exist yet

- [ ] **Step 2: Write the non-negotiable command-owner split into this plan**

Record these decisions in the plan before code changes:

```text
1. `/analyze` remains the pre-implementation artifact, contradiction, and registry-preflight gate.
2. `/implement` remains the owner of Applicable Standards Checklist generation and implementation evidence.
3. `/converge` becomes the post-implementation done/not-done command that compares live implementation to the active spec package and appends remaining work to `tasks.md` when necessary.
4. `/verify` no longer owns convergence discovery. It assumes convergence is already closed, then records verification evidence, rendered checks, blockers, and final closure.
5. `workflow-receipts.md` remains the workflow evidence ledger; `/converge` must not steal verification-evidence ownership from `/verify`.
```

- [ ] **Step 3: Lock the canonical phase order before patching standards or validators**

Record this as the default target sequence for implementation:

```text
Lean path: spec -> plan -> tasks -> analyze -> implement -> converge -> verify -> handoff
Gated path: clarify -> spec -> checklist -> plan -> tasks -> analyze -> implement -> converge -> verify -> handoff
```

Expected:
- later tasks do not invent competing phase orders

- [ ] **Step 4: Reject scope creep up front**

Record these non-goals:

```text
- Do not create app-level runtime hooks or spec-kit extension-hook behavior.
- Do not move Applicable Standards Checklist ownership out of `/implement`.
- Do not let `/converge` become a verification-evidence command.
- Do not rewrite historical plans, audits, or prior spec records unless they are still active workflow owners.
- Do not add a new convergence script unless command-only governance proves mechanically insufficient.
```

## Task 2: Draft The Dense `/converge` Command From `/analyze`

**Files:**
- Create: `.agents/commands/converge.md`
- Review: `.agents/commands/analyze.md`
- Review or modify: `.agents/commands/implement.md`
- Review or modify: `.agents/commands/verify.md`
- Review: `templates/spec-workflow/converge.template.md`

**Interfaces:**
- Consumes:
  - dense `/analyze` structure and headings
  - legacy converge intent
  - chosen owner split from Task 1
  - current convergence template
- Produces:
  - new dense `/converge` contract with stable sections matching command style:
    - `Purpose`
    - `User Input`
    - `Working Directory`
    - `Start Gate`
    - `Required Reads`
    - `Required Writes`
    - `Pre-Step Checks`
    - `Execution Steps`
    - `Post-Step Checks`
    - `Task Updates`
    - `Stop Conditions`
    - `Completion Report`
    - `Next Command`

- [ ] **Step 1: Start from `/analyze` structure rather than a thin legacy note**

Use `.agents/commands/analyze.md` as the structural reference and ensure `.agents/commands/converge.md` includes the same density of sections, phase headings, and explicit boundaries.

Expected:
- `/converge` looks like a peer command, not an ad hoc appendix

- [ ] **Step 2: Make the Purpose section explicitly reference `/analyze`**

The command should say, in substance:

```md
`/converge` reviews and updates the analysis models already developed by `/analyze`, then refreshes them against the live post-implementation codebase, task state, and plan decisions to determine whether the feature is converged or must return to `/implement`.
```

Expected:
- the user’s direction about Phase 3 reuse is reflected in the contract
- `/converge` does not pretend to be the first place that models requirements

- [ ] **Step 3: Keep the write contract append-only and narrow**

The command should state, in substance:

```md
Required Writes:
- append one new `## Phase N: Convergence` block to active `tasks.md` when actionable findings remain
- leave `tasks.md` byte-for-byte unchanged when convergence is clean
```

And explicitly forbid:

```text
- rewriting or renumbering prior tasks
- editing `spec.md` or `plan.md` in this command
- updating application code
- claiming verification closure
```

- [ ] **Step 4: Reframe Phase 3 as model refresh, not full model creation**

In `Execution Steps`, replace fresh-model wording with convergence-specific wording such as:

```md
### Phase 3: Review And Refresh Analysis Models

- reuse the requirements, success-criteria, story, task, and workflow models already expected from `/analyze`
- refresh them against implemented code, post-implement task state, and any changed plan decisions
- extend them only when implementation exposed a real gap the earlier analysis could not have seen
```

Expected:
- convergence builds on analyze rather than duplicating it

- [ ] **Step 5: Add dynamic standard-registry review in the same spirit as `/analyze`**

The command should include a phase such as:

```md
### Phase 4: Review Applicable Standard Rules

- derive candidate touched surfaces from implemented files, plan paths, task paths, workflow classification, and artifact text
- read relevant `../../standards/registry/*.rules.json` files before long prose standards
- run `../../scripts/get-applicable-standard-rules.ps1` with the active spec and phase `converge` when registry metadata includes converge coverage
- also inspect adjacent `implement` and `verify` rule families when needed for handoff correctness
- report candidate critical or high rules whose unresolved state means the implementation is not actually converged
- do not mark rules applied and do not populate verification evidence
```

Expected:
- registry selection is dynamic and methodical
- `/converge` still respects implementation and verification ownership boundaries

- [ ] **Step 6: Make the next-command behavior binary and explicit**

The command must end with:

```text
- next command is `/implement` when tasks were appended
- next command is `/verify` when convergence is clean
```

Expected:
- no ambiguous overlap between convergence and verification

## Task 3: Introduce Converge-Phase Registry Support And Rule Metadata

**Files:**
- Review or modify: `scripts/get-applicable-standard-rules.ps1`
- Modify: `standards/registry/command-workflow-contract.rules.json`
- Modify: `standards/registry/spec-driven-workflow.rules.json`
- Modify: `standards/registry/workspace.rules.json`
- Review or modify: `standards/registry/codex-capabilities.rules.json`
- Review or modify: `standards/registry/testing.rules.json`
- Review: `standards/registry/{constitution,stack,security,scripting,module-contract,adaptive-layouts}.rules.json`

**Interfaces:**
- Consumes:
  - new `/converge` command contract
  - current registry rule metadata and phase tagging
  - generator behavior in `scripts/get-applicable-standard-rules.ps1`
- Produces:
  - first-class `converge` phase support where applicable
  - dynamic rule selection that mirrors `/analyze` style but serves convergence decisions

- [ ] **Step 1: Verify whether the generator already accepts `-Phase converge`**

Run:

```powershell
./scripts/get-applicable-standard-rules.ps1 -ProjectPath . -ChangedFiles @(".agents/commands/converge.md") -Phase converge -JsonSummary
```

Expected:
- either usable output or a concrete limitation to patch

- [ ] **Step 2: Add `converge` as a recognized phase where it is a real workflow owner**

Update registry metadata only where convergence is materially owned, including:

```text
- command workflow rules
- spec-driven workflow rules
- workspace ownership rules
- any capability-routing or testing rules whose phase metadata depends on the command sequence
```

Do not bulk-edit unrelated registry families just to mention the new phase.

- [ ] **Step 3: Keep `/converge` registry behavior observational, not evidentiary**

Ensure converge-phase rule text and evidence requirements say, in substance:

```text
- convergence may review unresolved rule obligations against implemented reality
- convergence may report blockers and remaining work
- convergence does not mark Applicable Standards Checklist rows applied
- convergence does not create verification evidence
```

- [ ] **Step 4: Build a registry reconciliation table in this plan during implementation**

Append a table like:

```md
| Registry file | Why reviewed | Changed? | Converge phase added? | Notes |
| --- | --- | --- | --- | --- |
| `standards/registry/command-workflow-contract.rules.json` | new command owner split | yes | yes | add `/converge` responsibility |
| `standards/registry/spec-driven-workflow.rules.json` | phase map and lean/gated path | yes | yes | add converge sequence |
| `standards/registry/workspace.rules.json` | workspace command spine and ownership text | yes | yes | remove verify-as-convergence-owner |
```

Expected:
- every normative prose change has a matching machine-readable decision

## Task 4: Reconcile Neighboring Commands, Standards, And Workspace Owners

**Files:**
- Modify: `.agents/commands/implement.md`
- Modify: `.agents/commands/verify.md`
- Review or modify: `.agents/commands/analyze.md`
- Review or modify: `.agents/commands/tasks.md`
- Modify: `standards/spec-driven-workflow.md`
- Modify: `standards/command-workflow-contract.md`
- Modify: `standards/workspace.md`
- Review or modify: `AGENTS.md`

**Interfaces:**
- Consumes:
  - converge command draft
  - converge-capable registries
  - current owner-split wording
- Produces:
  - one consistent repo-wide workflow narrative on all active-owner prose surfaces

- [ ] **Step 1: Update `/implement` handoff to point to `/converge`**

Ensure `.agents/commands/implement.md` says, in substance:

```md
- implement resolves applicable rules and records implementation evidence
- after implementation converges locally, hand off to `/converge`
```

- [ ] **Step 2: Narrow `/verify` to verification evidence and closure**

Ensure `.agents/commands/verify.md` removes language that says it closes convergence. Replace it with wording in substance:

```md
`/verify` requires a converged implementation state, then records verification commands, rendered checks, workflow receipt closure evidence, and final completion status.
```

- [ ] **Step 3: Update standards phase map and workflow paths**

Patch `standards/spec-driven-workflow.md` so:

```text
- the phase-to-command table includes Converge between Implement and Verify
- lean and gated paths insert `/converge`
- the Convergence section no longer says convergence is closed inside `/verify`
- it instead states `/converge` closes the implementation gap decision and `/verify` closes verification evidence
```

- [ ] **Step 4: Update command-workflow and workspace owner prose in the same slice**

Patch:

```text
standards/command-workflow-contract.md
- add a `/converge` responsibility line
- change `/implement` handoff from `/verify` to `/converge`
- state `/verify` requires converged state plus verification evidence

standards/workspace.md
- update the executable command list
- remove or narrow the claim that `verify` includes convergence closure
```

- [ ] **Step 5: Keep AGENTS changes pointer-only**

Only edit `AGENTS.md` if the lean/gated path summary or workflow pointer becomes false after the standards move. Do not duplicate the full new procedure into root AGENTS.

Expected:
- the anti-drift ownership model remains intact

## Task 5: Update Manifest, Validators, And Workflow Tests

**Files:**
- Modify: `standards/workspace-manifest.psd1`
- Modify: `scripts/validate-codex-assets.ps1`
- Modify: `scripts/test-workflow-enforcement.ps1`
- Review or modify: `scripts/check-spec-artifacts.ps1`
- Review or modify: `scripts/validate-workflow-receipts.ps1`
- Review or modify: `scripts/test-workspace.ps1`
- Review or modify: `scripts/check-all.ps1`

**Interfaces:**
- Consumes:
  - new converge command file
  - updated command/standards/registry owner split
  - current validator command inventories and density checks
- Produces:
  - mechanical enforcement for the new workflow shape

- [ ] **Step 1: Add `/converge` to governed required-path inventories**

Update `standards/workspace-manifest.psd1` so any command-path lists consumed by validators include:

```text
.agents/commands/converge.md
```

Expected:
- repo asset validation fails if the command is missing

- [ ] **Step 2: Add dense-command assertions for `/converge`**

In `scripts/validate-codex-assets.ps1`, add a `converge` command-needle set with required phrases such as:

```text
## User Input
## Required Reads
## Required Writes
Review And Refresh Analysis Models
get-applicable-standard-rules.ps1
append-only
Phase N: Convergence
```

Also update existing `verify` needles if they still enforce convergence ownership.

- [ ] **Step 3: Extend workflow enforcement tests for the new phase**

Patch `scripts/test-workflow-enforcement.ps1` to cover:

```text
- phase order including converge
- applicable-rule generation for phase `converge`
- implement handoff to converge
- verify requiring already-converged state
```

Expected:
- tests fail before the slice lands and pass after it lands

- [ ] **Step 4: Review artifact and receipt validators for phase assumptions**

Check whether:

```text
scripts/check-spec-artifacts.ps1
scripts/validate-workflow-receipts.ps1
scripts/test-workspace.ps1
scripts/check-all.ps1
```

contain hardcoded assumptions that there are only six governed commands or that `/verify` owns convergence. Patch only the minimum necessary lines.

Expected:
- validators enforce the new workflow without broad churn

## Task 6: Reconcile Skills, Templates, And Other Active Pointer Surfaces

**Files:**
- Review or modify: `.agents/skills/cross-platform-app-workflow/SKILL.md`
- Review or modify: `.agents/skills/ui-change-workflow/SKILL.md`
- Review or modify: `.agents/skills/data-change-workflow/SKILL.md`
- Review or modify: `.agents/skills/mobile-validation-workflow/SKILL.md`
- Review or modify: `.agents/skills/release-readiness-workflow/SKILL.md`
- Review or modify: `templates/spec-workflow/converge.template.md`
- Review or modify: `templates/spec-workflow/tasks.template.md`
- Review or modify: `templates/spec-workflow/plan.template.md`

**Interfaces:**
- Consumes:
  - new command sequence
  - updated owner split
  - current thin wrapper-skill and template pointers
- Produces:
  - no active pointer surface that still points from `/implement` straight to `/verify`

- [ ] **Step 1: Sweep wrapper skills for command-sequence drift**

Run:

```powershell
rg -n "/implement|/verify|converge|workflow-receipts|Applicable Standards Checklist" .agents/skills
```

Patch only lines that now conflict with the new owner split.

- [ ] **Step 2: Review the convergence template against the new command report shape**

If `.agents/commands/converge.md` now expects explicit sections not supported by `templates/spec-workflow/converge.template.md`, update the template minimally so it can support the new handoff and decision record.

- [ ] **Step 3: Review workflow templates for downstream path references**

Check `tasks.template.md` and `plan.template.md` for phrases that explicitly assume:

```text
/implement -> /verify
verify owns convergence
```

Patch only if those assumptions are active and user-facing.

- [ ] **Step 4: Leave historical evidence docs untouched unless they are active owners**

Do not sweep-update `docs/superpowers/` or older plan/spec records solely to make wording uniform. If a repo-wide search finds only historical evidence there, document it as intentionally unchanged.

## Task 7: Verify The Slice And Record Repo-Wide Drift Results

**Files:**
- Modify: `docs/plans/2026-07-11-converge-command-contract-update.md`
- Review: all files touched in Tasks 2-6

**Interfaces:**
- Consumes:
  - revised commands
  - revised standards and registries
  - updated validators, manifest, tests, skills, and templates
- Produces:
  - verified no-drift workspace state for the converge-command slice
  - closeout evidence appended to this plan

- [ ] **Step 1: Run focused workflow-governance checks first**

Run:

```powershell
./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true
./scripts/test-workflow-enforcement.ps1
```

Expected:
- both pass
- failures identify command, registry, or workflow drift directly

- [ ] **Step 2: Run narrower validators only if their contracts changed**

If Tasks 5-6 touched artifact, receipt, or template expectations, run the narrowest relevant checks, such as:

```powershell
./scripts/check-spec-artifacts.ps1 -ProjectPath projects/signal
./scripts/validate-workflow-receipts.ps1 -ProjectPath projects/signal
./scripts/test-workspace.ps1
```

Expected:
- compatibility mode still passes for established projects

- [ ] **Step 3: Run the broad governance gate after focused checks pass**

Run:

```powershell
./scripts/check-all.ps1
```

Expected:
- the full governance suite passes with the new command inventory and owner split

- [ ] **Step 4: Run a repo-wide stale-reference sweep**

Run:

```powershell
rg -n "verify.*convergen|includes convergence|closed inside `/verify`|/implement -> /verify|converge|/converge" AGENTS.md .agents standards scripts templates docs
```

Review each hit and patch only:

```text
- active workflow owners
- validators enforcing active owners
- active wrapper skills or templates
```

Do not change historical evidence records unless they are still presented as live workflow guidance.

- [ ] **Step 5: Append closeout evidence to this plan**

Append a section like:

```md
## Closeout Evidence

- Implementation status:
- Phase order chosen:
- Script-boundary decision:
- Registry files reviewed:
- Registry files changed:
- Active-owner prose files changed:
- Validators/tests changed:
- Checks run:
- Drift sweep result:
- Compatibility notes:
- Remaining blockers:
```

Expected:
- the plan becomes the slice receipt for repo-wide convergence-command rollout

## Applicable Standards Selection For This Plan

This plan intentionally does not hardcode a static rule-id checklist. During implementation, generate the applicable rules using `standards/registry/*.rules.json` and `scripts/get-applicable-standard-rules.ps1` with:

- changed surfaces: `.agents/commands/`, `standards/`, `standards/registry/`, `scripts/`, `.agents/skills/`, `templates/spec-workflow/`, `AGENTS.md`, and `standards/workspace-manifest.psd1` when changed
- target phase: `converge`, plus adjacent `implement`, `analyze`, and `verify` review where owner boundaries or handoff wording change
- trigger kinds: command change, workflow change, registry change, validator change, governance change, receipt change, template change, and standards change

Expected rule families to review first:

- `standards/registry/command-workflow-contract.rules.json`
- `standards/registry/spec-driven-workflow.rules.json`
- `standards/registry/workspace.rules.json`

Conditionally review and patch:

- `standards/registry/codex-capabilities.rules.json`
- `standards/registry/testing.rules.json`
- other registry families only when generator output or changed surfaces make them applicable

Concrete rule IDs and references should come from generator output during implementation, not from hand-maintained guesses in this plan.

## Reporting Checklist

- [x] The plan explicitly treats `/converge` as a new governed command, not just a draft text file.
- [x] The plan makes `/analyze` the structural reference for `/converge`.
- [x] The plan explicitly states that most of converge Phase 3 reuses and refreshes analyze-built models.
- [x] Dynamic registry selection is included as an implementation requirement, mirroring `/analyze`.
- [x] `/implement`, `/converge`, and `/verify` ownership boundaries are explicitly separated.
- [x] Active-owner prose, registry, validator, manifest, template, and skill surfaces are all enumerated for drift review.
- [x] Historical evidence docs are intentionally excluded from routine churn unless they still act as owners.
- [x] Verification ends with focused checks, broad governance checks, and a repo-wide stale-reference sweep.

## Spec Coverage Check

- standalone dense `/converge` command in `/analyze` style: covered by Task 2
- explicit reference back to `/analyze` and reuse of its Phase 3 modeling work: covered by Task 2
- dynamic standard registries as applicable: covered by Task 3 and Task 5
- repo-wide owner-split correction so `/verify` no longer closes convergence: covered by Tasks 1, 4, and 5
- manifest, validators, and tests for the new command surface: covered by Task 5
- active skills/templates/docs drift prevention: covered by Task 6
- final verification and drift sweep: covered by Task 7

## Placeholder Scan

- No `TODO`, `TBD`, or “similar to Task N” placeholders are allowed in implementation commits for the governed surfaces touched by this slice.
- Historical docs under `docs/superpowers/` and prior plans remain evidence by default, not active owners.
- No new upstream spec-kit runtime assumptions should appear in the final local command or validator text.

## Type And Contract Consistency

- `/tasks` owns task generation and workflow-receipt initialization.
- `/analyze` owns pre-implementation artifact analysis, contradiction detection, and preflight rule visibility.
- `/implement` owns Applicable Standards Checklist generation and implementation evidence.
- `/converge` owns the post-implementation done/not-done decision and append-only remaining-work task creation.
- `/verify` owns verification evidence, rendered checks, and final completion closure after convergence passes.
- Standards own phase semantics; command files own exact step-by-step behavior; registries own machine-readable rule metadata; validators and tests enforce those owners.

## Execution Handoff

Plan complete and saved to `docs/plans/2026-07-11-converge-command-contract-update.md`. Two execution options:

**1. Subagent-Driven (recommended)** - Dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints.

Preferred execution path for this governance slice: Subagent-Driven for Tasks 2-6 with main-agent review between tasks, then inline verification for Task 7.

## Implementation Decisions

- Status: implemented on 2026-07-11.
- Phase order chosen:
  - lean: `spec -> plan -> tasks -> analyze -> implement -> converge -> verify -> handoff`
  - gated: `clarify -> spec -> checklist -> plan -> tasks -> analyze -> implement -> converge -> verify -> handoff`
- Script-boundary decision:
  - command-only convergence was retained
  - no new `scripts/converge-spec.ps1` was introduced
  - `scripts/get-applicable-standard-rules.ps1` was extended with converge-command path signals so dynamic rule selection can score converge-specific rules accurately
- Owner split implemented:
  - `/analyze` remains the pre-implementation model and contradiction gate
  - `/implement` remains the owner of Applicable Standards Checklist generation and implementation evidence
  - `/converge` now owns the post-implementation done or not-done decision and append-only remaining-work task creation
  - `/verify` now assumes converged state and owns verification evidence plus final closure

## Registry Reconciliation

| Registry file | Why reviewed | Changed? | Converge phase added? | Notes |
| --- | --- | --- | --- | --- |
| `standards/registry/command-workflow-contract.rules.json` | command-owner split | yes | yes | implement now hands off to `/converge`, new converge responsibility rule added, verify now requires converged state |
| `standards/registry/spec-driven-workflow.rules.json` | phase map, lean/gated path, convergence semantics | yes | yes | phase map, path rules, and convergence ownership moved from verify-only to converge-then-verify |
| `standards/registry/workspace.rules.json` | workspace evidence phases and command-surface linkage | yes | yes | receipt-evidence rule now includes converge phase and command automation |
| `standards/registry/codex-capabilities.rules.json` | capability-routing drift check | no | no | no active capability rule depended on the old converge owner split |
| `standards/registry/testing.rules.json` | verification-owner drift check | no | no | verify-app and rendered-check ownership stayed in `/verify` |

## Closeout Evidence

- Implementation status: complete.
- Files created:
  - `.agents/commands/converge.md`
  - `docs/plans/2026-07-11-converge-command-contract-update.md`
- Files changed:
  - `AGENTS.md`
  - `.agents/commands/implement.md`
  - `.agents/commands/verify.md`
  - `.agents/skills/cross-platform-app-workflow/SKILL.md`
  - `standards/command-workflow-contract.md`
  - `standards/spec-driven-workflow.md`
  - `standards/workspace.md`
  - `standards/workspace-manifest.psd1`
  - `standards/registry/command-workflow-contract.rules.json`
  - `standards/registry/spec-driven-workflow.rules.json`
  - `standards/registry/workspace.rules.json`
  - `scripts/create-app.ps1`
  - `scripts/get-applicable-standard-rules.ps1`
  - `scripts/test-workflow-enforcement.ps1`
  - `scripts/validate-codex-assets.ps1`
  - `templates/spec-workflow/tasks.template.md`
  - `templates/spec-workflow/plan.template.md`
- Active-owner prose files changed:
  - `AGENTS.md`
  - `.agents/commands/converge.md`
  - `.agents/commands/implement.md`
  - `.agents/commands/verify.md`
  - `.agents/skills/cross-platform-app-workflow/SKILL.md`
  - `standards/command-workflow-contract.md`
  - `standards/spec-driven-workflow.md`
  - `standards/workspace.md`
- Validators and tests changed:
  - `scripts/get-applicable-standard-rules.ps1`
  - `scripts/test-workflow-enforcement.ps1`
  - `scripts/validate-codex-assets.ps1`
  - `scripts/create-app.ps1`
- Checks run:
  - `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`
  - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\test-workflow-enforcement.ps1`
  - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\test-workspace.ps1`
  - `powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-all.ps1`
- Verification result:
  - all targeted checks passed
  - `check-all.ps1` passed fully, including hook policy, workflow enforcement, spec analysis, template parity, secret scan, and generated-project workspace tests
- Compatibility notes:
  - current-template generated apps passed after `create-app.ps1` was updated to replace the new plan-template `/converge` placeholder wording
  - no compatibility-mode validator contract changes were required for existing apps
- Drift sweep result:
  - active-owner surfaces under `AGENTS.md`, `.agents/`, `standards/`, `scripts/`, and `templates/` now agree on the new `/analyze -> /implement -> /converge -> /verify` split
  - remaining `docs/superpowers/` and earlier `docs/plans/` hits were left unchanged as historical evidence, not active workflow owners
- Notable verification note:
  - one failed `check-all` run was caused by running `test-workspace.ps1` in parallel with `check-all.ps1`, which exposed temporary `projects/__verify-*` folders to nested asset validation
  - rerunning `check-all.ps1` serially after cleanup passed fully
- Remaining blockers: none in this slice
