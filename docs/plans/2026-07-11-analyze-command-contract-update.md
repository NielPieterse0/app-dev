# /analyze Command Contract Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the `/analyze` command so it matches the attached dense command draft, stays in harmony with the current `/implement` contract, and keeps command, script, standards, registries, validators, scaffold expectations, and workflow tests aligned across the repo.

**Architecture:** Treat this as a workflow-governance slice, not a single markdown edit. `.agents/commands/analyze.md` owns the human-facing Analyze phase contract, `scripts/analyze-spec.ps1` remains the mechanical contradiction detector unless this slice explicitly broadens it, registry selection must be visible before `/implement` without stealing implementation-time Applicable Standards Checklist ownership, and all neighboring command, standards, validator, and test surfaces must move together so the Analyze phase does not drift from the live workflow.

**Tech Stack:** Markdown command docs and plans, PowerShell workflow scripts and validators, JSON standards registries, workflow receipts, workspace governance tests.

## Global Constraints

- Plan lives under `docs/plans/` per local user instruction, not under `docs/superpowers/plans/`.
- `/analyze` remains a pre-implementation gate between `/tasks` and `/implement`.
- `/analyze` must require the initialized active `spec.md`, `plan.md`, `tasks.md`, `workflow-receipts.md`, and gated `checklist.md` when required by risk level.
- `/analyze` is read-only by default. It may report owning artifacts that need correction, but it must not silently write `spec.md`, `plan.md`, `tasks.md`, or `workflow-receipts.md` unless the user explicitly requests remediation.
- `/analyze` may preflight likely applicable registry rules, but `/implement` remains the owner of generated Applicable Standards Checklist statuses and implementation evidence.
- `scripts/analyze-spec.ps1` is currently a contradiction detector, not a full spec-kit-style report generator. This slice must decide whether to keep that split or deliberately expand the script and its tests.
- Existing apps remain on validator `compatibility` mode unless a slice explicitly opts into `current-template`.
- Do not import spec-kit runtime hooks, `.specify/extensions.yml`, foreign prerequisite runners, or other upstream runtime assumptions that conflict with local `app-dev` ownership.
- Do not create broad churn across historical `projects/*/specs/*` artifacts unless a validator contract change makes a compatibility update unavoidable.

## Implementation Decisions

- Status: implemented on 2026-07-11.
- Script-boundary model chosen: Model A.
- Command/script split:
  - `.agents/commands/analyze.md` now owns the dense human-facing Analyze-phase contract, phased reporting guidance, severity model, receipt boundary, and `/implement` handoff.
  - `scripts/analyze-spec.ps1` remains the mechanical contradiction detector and was intentionally not broadened in this slice.
- Registry boundary:
  - `/analyze` may preflight likely applicable rules with `scripts/get-applicable-standard-rules.ps1` when relevant.
  - `/implement` remains the sole owner of generated Applicable Standards Checklist statuses and implementation evidence.
- Receipt boundary:
  - `/analyze` stays read-only by default and does not update workflow receipts unless the user explicitly requests remediation work.
- Drift policy:
  - Active-owner command, standards, registry, validator, and workflow-test surfaces moved together.
  - Historical plans, audits, and prior spec records were left intact unless they were current owners of the live contract.

## Affected Artifact Map

- Modify `.agents/commands/analyze.md`
  - Own the dense `/analyze` contract: purpose, user input, reads, writes, preflight, report shape, receipt boundary, stop conditions, and handoff to `/implement`.
- Review or modify `.agents/commands/tasks.md`
  - Keep `/tasks` handoff to `/analyze` aligned with the densified Analyze-phase contract.
- Review or modify `.agents/commands/implement.md`
  - Keep `/implement` start-gate wording aligned with `/analyze` as the contradiction and registry-readiness gate.
- Review or modify `.agents/commands/verify.md`
  - Keep `/verify` from re-owning pre-implementation analysis concerns unless it is intentionally doing a defensive rerun.
- Modify `standards/command-workflow-contract.md`
  - Keep Analyze-phase responsibility aligned with the revised command behavior.
- Modify `standards/spec-driven-workflow.md`
  - Keep phase-map, lean/gated path wording, and Analyze-phase semantics aligned with the revised contract.
- Modify `standards/registry/command-workflow-contract.rules.json`
  - Keep command-registry rules aligned with the revised Analyze-phase ownership.
- Modify `standards/registry/spec-driven-workflow.rules.json`
  - Keep workflow-registry rules aligned with the revised Analyze-phase semantics and any registry-preflight expectations.
- Review `standards/registry/constitution.rules.json`
  - Confirm constitution-alignment rules are sufficient if `/analyze` now explicitly reports constitution issues.
- Review `standards/registry/{workspace,stack,security,testing,scripting,module-contract,codex-capabilities,adaptive-layouts}.rules.json`
  - Confirm rule metadata is sufficient for Analyze-phase preflight when triggered by active artifact text and task paths.
- Review or modify `scripts/analyze-spec.ps1`
  - Decide whether it remains a contradiction gate only or grows to support richer report categories expected by the new command.
- Modify `scripts/test-analyze-spec.ps1`
  - Keep the analyzer’s tested behavior aligned with the chosen script scope.
- Review or modify `scripts/get-applicable-standard-rules.ps1`
  - Confirm Analyze-phase preflight can reuse it without incorrectly generating implementation evidence.
- Modify `scripts/validate-codex-assets.ps1`
  - Update command-density assertions for `/analyze` and any phase-owner wording that moved.
- Review or modify `scripts/check-spec-artifacts.ps1`
  - Update only if Analyze-phase artifact assumptions or current-template command checks materially change.
- Review or modify `scripts/validate-workflow-receipts.ps1`
  - Update only if read-only `/analyze` receipt guidance or pending-analysis blocker wording must be validated.
- Modify `scripts/test-workflow-enforcement.ps1`
  - Keep workflow command-contract and registry-preflight expectations aligned with the revised `/analyze` behavior.
- Review or modify `scripts/test-workspace.ps1`
  - Update only if generated canary apps or workflow enforcement tests need new Analyze-phase expectations.
- Review `.agents/skills/cross-platform-app-workflow/SKILL.md`
  - Confirm the wrapper still points to `/analyze` as the pre-implementation contradiction gate.
- Review `.agents/skills/{ui-change-workflow,data-change-workflow,mobile-validation-workflow,release-readiness-workflow}/SKILL.md`
  - Update only if wrapper skill wording needs to mention Analyze-phase blocker handling or preflight expectations.
- Modify `docs/plans/2026-07-11-analyze-command-contract-update.md`
  - Record decisions, scope boundaries, verification results, and drift findings for this governance slice.

## Task 1: Lock The Revised `/analyze` Contract Before Editing

**Files:**
- Modify: `docs/plans/2026-07-11-analyze-command-contract-update.md`
- Review: `.agents/commands/analyze.md`
- Review: `.agents/commands/tasks.md`
- Review: `.agents/commands/implement.md`
- Review: `.agents/commands/verify.md`
- Review: `standards/command-workflow-contract.md`
- Review: `standards/spec-driven-workflow.md`
- Review: `scripts/analyze-spec.ps1`
- Review: `scripts/get-applicable-standard-rules.ps1`

**Interfaces:**
- Consumes:
  - current `/analyze` command contract
  - attached dense `/analyze` draft
  - current `/implement` start-gate and registry-checklist ownership
  - current contradiction-detector behavior in `scripts/analyze-spec.ps1`
  - current registry-rule selector behavior in `scripts/get-applicable-standard-rules.ps1`
- Produces:
  - final contract decisions for:
    - read-only versus remediation behavior
    - script scope versus command-doc scope
    - registry preflight versus implementation-time checklist ownership
    - neighboring command handoff wording
    - repo-wide drift surfaces that must move in lockstep

- [ ] **Step 1: Capture the current Analyze-phase contract and drift surfaces**

Run:

```powershell
rg -n "/analyze|analyze-spec|get-applicable-standard-rules|workflow-receipts|Applicable Standards Checklist|contradictions|before material implementation" .agents standards scripts
```

Expected:
- hits for `.agents/commands/analyze.md`
- hits for neighboring command handoffs and workflow standards
- hits for `scripts/analyze-spec.ps1` and `scripts/get-applicable-standard-rules.ps1`

- [ ] **Step 2: Record the non-negotiable contract decisions in this plan**

Write these decisions into the slice notes before implementation:

```text
1. `/analyze` is a pre-implementation gate after `/tasks` and before `/implement`.
2. `/analyze` is read-only by default and does not silently write owning artifacts.
3. `/analyze` may identify `spec.md`, `plan.md`, `tasks.md`, `workflow-receipts.md`, or `checklist.md` as the artifact that needs repair, but follow-up edits happen only in explicit remediation work.
4. `/analyze` may preflight likely applicable registry rules, but `/implement` remains the owner of generated Applicable Standards Checklist statuses and implementation evidence.
5. `scripts/analyze-spec.ps1` must either remain a contradiction detector with a richer command-layer report built around it, or this slice must explicitly broaden the script and its tests; do not let the command promise behavior the script cannot support.
6. `/verify` remains the owner of completion closure and final verification evidence.
```

- [ ] **Step 3: Decide the script-boundary model before code changes**

Record one of these two models in the plan and implement only the chosen one:

```text
Model A: keep `scripts/analyze-spec.ps1` as the contradiction detector and make `.agents/commands/analyze.md` the owner of richer human analysis/report guidance.

Model B: expand `scripts/analyze-spec.ps1` so it emits more of the structured analysis categories that the command promises, then update `scripts/test-analyze-spec.ps1` accordingly.
```

Expected:
- the slice has one explicit script-boundary decision
- later tasks do not mix models

- [ ] **Step 4: Reject unnecessary scope expansion up front**

Record these non-goals in the slice notes:

```text
- Do not add spec-kit extension-hook runtime behavior.
- Do not move Applicable Standards Checklist ownership from `/implement` into `/analyze`.
- Do not turn `/analyze` into a verification or convergence command.
- Do not backfill historical project receipts unless a validator change makes a compatibility update unavoidable.
```

## Task 2: Rewrite The `/analyze` Command Contract

**Files:**
- Modify: `.agents/commands/analyze.md`
- Review or modify: `.agents/commands/tasks.md`
- Review or modify: `.agents/commands/implement.md`
- Review or modify: `.agents/commands/verify.md`

**Interfaces:**
- Consumes:
  - contract decisions from Task 1
  - current neighboring command handoff wording
  - current `/implement` ownership of Applicable Standards Checklist evidence
- Produces:
  - revised `/analyze` command guidance with stable headings:
    - `Purpose`
    - `User Input`
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

- [ ] **Step 1: Replace the thin command with the dense phase-based contract**

Update `.agents/commands/analyze.md` so it states, in substance:

```md
`/analyze` analyzes the active `spec.md`, `plan.md`, `tasks.md`, `workflow-receipts.md`, gated `checklist.md` when required, and relevant `standards/registry/*.rules.json` files before material implementation starts.

It does not create or initialize workflow artifacts.
It does not execute implementation tasks.
It does not claim verification closure.
```

Expected:
- `/analyze` matches the repo’s dense command layout
- the command no longer reads like a lightweight note

- [ ] **Step 2: Add explicit `User Input`, `Required Reads`, and `Required Writes` sections**

Ensure the command says, in substance:

```md
User arguments can narrow analysis focus, reporting depth, or finding categories, but cannot override the active spec, required artifacts, safety gates, contradiction handling, or approval requirements.

Required Reads:
- active `spec.md`
- active `plan.md`
- active `tasks.md`
- active `workflow-receipts.md`
- gated `checklist.md` when required
- relevant `standards/registry/*.rules.json`
- `scripts/analyze-spec.ps1`
- `scripts/get-applicable-standard-rules.ps1`

Required Writes:
- none by default
```

Expected:
- read-only ownership is explicit
- registry preflight inputs are explicit

- [ ] **Step 3: Add phased execution that matches the attached draft but stays local to app-dev**

Restructure `Execution Steps` around phases such as:

```md
### Phase 1: Read The Active Artifacts
### Phase 2: Run The Governed Analysis Script
### Phase 3: Build Analysis Models
### Phase 4: Preflight Applicable Standard Rules
### Phase 5: Run Detection Passes
### Phase 6: Assign Severity
### Phase 7: Produce Analysis Report
### Phase 8: Receipt Handling
### Phase 9: Run Analysis Review
```

Expected:
- spec-kit-inspired structure is adopted without importing upstream runtime assumptions
- local `/implement` ownership remains intact

- [ ] **Step 4: Keep registry preflight visible but non-invasive**

In the Analyze-phase contract, require wording in substance:

```md
- derive candidate touched surfaces from `tasks.md`, planned files, workflow classification, and artifact text
- run `scripts/get-applicable-standard-rules.ps1` for Analyze-phase preflight when relevant
- report likely critical or high rules that may affect `/implement`
- do not mark rules applied and do not populate implementation evidence
```

Expected:
- `/analyze` prepares `/implement` without duplicating its checklist ownership

- [ ] **Step 5: Keep receipt handling read-only by default**

Ensure `Receipt Updates` says, in substance:

```md
Default: none.

When remediation is explicitly requested:
- record `/analyze` in `Command path used:` only for sections whose blocker or classification state changed
- record contradiction findings as analysis blockers
- do not add Applicable Standards Checklist entries as applied from `/analyze`
```

Expected:
- the command boundary matches the answer already given to the user about the reference analyze behavior

- [ ] **Step 6: Align neighboring commands only where the owner split changed**

Update only the affected handoff lines:

- `/tasks` should hand off to `/analyze` after task and receipt initialization
- `/implement` should assume analysis contradictions are already resolved before material code changes
- `/verify` should not re-own pre-implementation analysis except for defensive reruns when drift is discovered

Expected:
- neighboring commands agree without being broadly rewritten

## Task 3: Decide And Implement The Script Boundary

**Files:**
- Review or modify: `scripts/analyze-spec.ps1`
- Modify: `scripts/test-analyze-spec.ps1`
- Review or modify: `scripts/get-applicable-standard-rules.ps1`

**Interfaces:**
- Consumes:
  - the Model A or Model B decision from Task 1
  - current contradiction checks in `scripts/analyze-spec.ps1`
  - current generator behavior in `scripts/get-applicable-standard-rules.ps1`
- Produces:
  - mechanical behavior that matches the promise made by the revised `/analyze` command

- [ ] **Step 1: Capture the current analyzer scope and test coverage**

Run:

```powershell
rg -n "Status|checklist|workflow-receipts|NEEDS CLARIFICATION|no-auth|verification" scripts/analyze-spec.ps1 scripts/test-analyze-spec.ps1
```

Expected:
- current contradiction checks are explicit
- the existing tests show what the script already guarantees

- [ ] **Step 2: If Model A was chosen, keep the script narrow and document the boundary**

Under Model A:

```text
- keep `scripts/analyze-spec.ps1` as the contradiction detector
- use `.agents/commands/analyze.md` to require richer human-layer coverage, mapping, severity, and report formatting
- update `scripts/test-analyze-spec.ps1` only for behavior that materially changed in the script itself
```

Expected:
- the command never implies that the script emits a full spec-kit-style report

- [ ] **Step 3: If Model B was chosen, expand the script deliberately**

Under Model B:

```text
- add structured checks that support the promised command categories
- keep the script output deterministic and testable
- update `scripts/test-analyze-spec.ps1` with fixtures for the new failure modes or report fields
```

Expected:
- script behavior, tests, and command promises remain aligned

- [ ] **Step 4: Validate Analyze-phase use of `get-applicable-standard-rules.ps1`**

Confirm whether the current generator already supports `-Phase analyze` well enough. If not, patch it so Analyze-phase preflight can:

```text
- inspect active spec artifacts
- select likely rules by `applies_to`, `trigger_kinds`, and `phases`
- report registry files reviewed and candidate rules
- avoid generating implementation evidence or applied statuses
```

Expected:
- registry preflight works for `/analyze` without stealing `/implement` ownership

## Task 4: Reconcile Standards And Matching Registries

**Files:**
- Modify: `standards/command-workflow-contract.md`
- Modify: `standards/spec-driven-workflow.md`
- Modify: `standards/registry/command-workflow-contract.rules.json`
- Modify: `standards/registry/spec-driven-workflow.rules.json`
- Review or modify: `standards/registry/constitution.rules.json`
- Review: other `standards/registry/*.rules.json` families when triggered

**Interfaces:**
- Consumes:
  - revised `/analyze` contract
  - chosen script boundary
  - current phase-map and command-responsibility wording
- Produces:
  - no drift between human workflow policy and registry-layer operational rules

- [ ] **Step 1: Align prose standards with the revised Analyze-phase contract**

Update standards text so it matches the new behavior in substance:

```md
standards/command-workflow-contract.md
- `analyze`: require the active spec, active `plan.md`, active `tasks.md`, initialized `workflow-receipts.md`, and gated `checklist.md` when required; resolve contradictions and surface implementation blockers before material implementation starts.

standards/spec-driven-workflow.md
- Analyze remains the pre-implementation contradiction gate in the lean and gated paths.
- Analyze may preflight registry rule visibility before `/implement`, but implementation-time checklist ownership remains in `/implement`.
```

Expected:
- prose standards and command doc say the same thing

- [ ] **Step 2: Reconcile matching registry rules in the same slice**

Update registry entries so command and workflow rule metadata reflects:

```text
- Analyze-phase prerequisites
- Analyze-phase contradiction resolution before implementation
- read-only default behavior
- registry preflight visibility before `/implement`
- no transfer of implementation evidence ownership
```

Expected:
- the matching registry rules move with the prose standards

- [ ] **Step 3: Review constitution-registry sufficiency**

Confirm `standards/registry/constitution.rules.json` already provides enough Analyze-phase alignment for constitution conflicts. If not, add or refine only the minimum rule metadata needed for Analyze-phase reporting.

Expected:
- constitution-alignment findings remain a first-class Analyze concern without unnecessary registry churn

- [ ] **Step 4: Build a standards-to-registry reconciliation table in this plan**

Add a reconciliation table in the plan during implementation:

```md
| Prose standard | Matching registry | Changed? | Reconciled? | Notes |
| --- | --- | --- | --- | --- |
| `standards/command-workflow-contract.md` | `standards/registry/command-workflow-contract.rules.json` | yes | yes | Analyze-phase command responsibility |
| `standards/spec-driven-workflow.md` | `standards/registry/spec-driven-workflow.rules.json` | yes | yes | Analyze-phase semantics and path wording |
| `standards/constitution.md` | `standards/registry/constitution.rules.json` | conditional | conditional | Analyze-phase constitution reporting sufficiency |
```

Expected:
- every prose change has a matching registry decision

## Task 5: Update Validators, Workflow Tests, And Scaffold Expectations

**Files:**
- Modify: `scripts/validate-codex-assets.ps1`
- Review or modify: `scripts/check-spec-artifacts.ps1`
- Review or modify: `scripts/validate-workflow-receipts.ps1`
- Modify: `scripts/test-workflow-enforcement.ps1`
- Review or modify: `scripts/test-workspace.ps1`
- Review: `scripts/create-app.ps1`

**Interfaces:**
- Consumes:
  - revised command and standard contracts
  - chosen script-boundary model
  - current receipt/template expectations
- Produces:
  - mechanical drift detection for Analyze-phase contract changes

- [ ] **Step 1: Update command-density assertions for `/analyze`**

In `scripts/validate-codex-assets.ps1`, replace the thin `/analyze` needles with contract-based assertions for the revised command, such as:

```text
User Input
Required Reads
Required Writes
Run The Governed Analysis Script
Preflight Applicable Standard Rules
Produce Analysis Report
read-only
get-applicable-standard-rules.ps1
```

Expected:
- validator enforcement matches the denser command shape
- avoid brittle exact-sentence checks beyond the repo’s established style

- [ ] **Step 2: Decide whether receipt validators need Analyze-phase wording support**

Review whether `scripts/validate-workflow-receipts.ps1` must explicitly accept or validate:

```text
- pending Analyze-phase blockers recorded in receipt sections
- Analyze-phase `Command path used:` entries when remediation is explicit
- no applied Applicable Standards Checklist entries coming from `/analyze`
```

Edit only if the revised command or test fixtures require it.

- [ ] **Step 3: Decide whether artifact checks need Analyze-phase contract updates**

Review `scripts/check-spec-artifacts.ps1` for assumptions about current-template command files or workflow-receipt initialization that would drift after the Analyze-phase rewrite. Change only what is necessary to keep artifact enforcement aligned.

- [ ] **Step 4: Update workflow tests for the revised Analyze-phase contract**

Update `scripts/test-workflow-enforcement.ps1` and, if needed, `scripts/test-workspace.ps1` to cover:

```text
- the denser `/analyze` command headings and required terms
- Analyze-phase preflight wording that references `get-applicable-standard-rules.ps1`
- no drift in `/tasks -> /analyze -> /implement -> /verify` handoff wording
- any chosen script-boundary behavior that became testable
```

Expected:
- workflow tests fail before the Analyze-phase contract is implemented and pass after it lands

- [ ] **Step 5: Confirm scaffold expectations do not drift**

Review `scripts/create-app.ps1` and `scripts/test-workspace.ps1` to confirm generated canary apps still satisfy the revised Analyze-phase assumptions without requiring unnecessary artifact changes.

Expected:
- generated projects remain compatible with the densified Analyze-phase contract

## Task 6: Review Wrapper Skills And Repo-Wide Drift Surfaces

**Files:**
- Review or modify: `.agents/skills/cross-platform-app-workflow/SKILL.md`
- Review or modify: `.agents/skills/ui-change-workflow/SKILL.md`
- Review or modify: `.agents/skills/data-change-workflow/SKILL.md`
- Review or modify: `.agents/skills/mobile-validation-workflow/SKILL.md`
- Review or modify: `.agents/skills/release-readiness-workflow/SKILL.md`
- Review: `README.md`
- Review: `AGENTS.md`

**Interfaces:**
- Consumes:
  - revised Analyze-phase command contract
  - updated standards/registry ownership
  - current wrapper skill references to workflow receipts and command flow
- Produces:
  - repo-wide wording that does not drift on active-owner surfaces

- [ ] **Step 1: Update wrapper skill wording only if active guidance drifted**

Search:

```powershell
rg -n "/analyze|analyze|contradiction|before material implementation|workflow-receipts.md|Applicable Standards Checklist" .agents/skills README.md AGENTS.md
```

Patch only lines on active-owner surfaces that now conflict with the new `/analyze` behavior.

Expected:
- wrapper skills keep the same owner split as the revised commands
- top-level historical or descriptive docs are changed only when they are active workflow owners

- [ ] **Step 2: Keep README and AGENTS changes narrow**

Only edit `README.md` or `AGENTS.md` if they contain active workflow-owner wording that is now false after the Analyze-phase change. Do not broaden this slice into unrelated governance cleanup.

Expected:
- repo-wide drift is prevented without unnecessary documentation churn

## Task 7: Run Verification And Record Repo-Wide Drift Results

**Files:**
- Modify: `docs/plans/2026-07-11-analyze-command-contract-update.md`
- Review: all files touched in Tasks 2-6

**Interfaces:**
- Consumes:
  - revised command, script, standards, registries, validators, skills, and tests
- Produces:
  - verified no-drift workspace state for the Analyze-phase contract slice
  - final implementation notes in this plan

- [ ] **Step 1: Run focused workflow-governance checks**

Run:

```powershell
./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true
./scripts/test-analyze-spec.ps1
./scripts/test-workflow-enforcement.ps1
```

Expected:
- all pass
- failures identify the remaining Analyze-phase drift surface directly

- [ ] **Step 2: Run workspace or receipt checks if the implementation changed their contract**

If Tasks 3-5 changed scaffold, artifact, or receipt enforcement behavior, run the narrowest relevant checks used by the repo, such as:

```powershell
./scripts/test-workspace.ps1
./scripts/validate-workflow-receipts.ps1 -ProjectPath projects/signal
```

Expected:
- the revised Analyze-phase contract does not break current-template or compatibility expectations

- [ ] **Step 3: Run the broad governance gate if focused checks pass**

Run:

```powershell
./scripts/check-all.ps1
```

Expected:
- the full governance suite passes

- [ ] **Step 4: Run a repo-wide stale-reference sweep**

Run:

```powershell
rg -n "/analyze|Run The Governed Analysis Script|Preflight Applicable Standard Rules|read-only|get-applicable-standard-rules.ps1|contradictions before material implementation" .agents standards scripts templates projects docs
```

Review the hits and patch only real drift, not historical records that should remain unchanged as evidence.

- [ ] **Step 5: Append closeout evidence to this plan**

Append a section like:

```md
## Closeout Evidence

- Implementation status:
- Script-boundary model chosen:
- Registry files reviewed:
- Analyze-phase standards and registries reconciled:
- Validators updated:
- Checks run:
- Drift sweep result:
- Compatibility notes:
- Remaining blockers:
```

Expected:
- the plan itself records the repo-wide drift and verification outcome for this governance slice

## Applicable Standards Selection For This Plan

This plan intentionally does not maintain a static rule-id checklist. During implementation, generate the relevant Analyze-phase and neighboring governance rules from `standards/registry/*.rules.json` using:

- active phase: `analyze`, plus adjacent `implement` and `verify` review where handoff wording changes
- changed surfaces: `.agents/commands/`, `scripts/`, `standards/`, `standards/registry/`, `.agents/skills/`, and any active-owner docs changed to prevent drift
- trigger kinds: command change, workflow change, validator change, registry change, governance change, contradiction handling, receipt change, and pre-implementation analysis

Expected generated rule families include command workflow, spec workflow, constitution alignment, workspace governance, and any triggered testing, security, scripting, module-contract, or capability-routing rules. Concrete rule IDs and references should come from generator output during implementation, not be hardcoded into this plan.

## Reporting Checklist

- [x] `/analyze` remains a pre-implementation gate after `/tasks` and before `/implement`.
- [x] Read-only default behavior is explicit.
- [x] Registry preflight is visible without transferring Applicable Standards Checklist ownership from `/implement`.
- [x] Script scope versus command-doc scope is explicitly decided and implemented.
- [x] Neighboring commands are reviewed for handoff drift.
- [x] Prose standards and matching registries move in the same slice.
- [x] Validators and workflow tests are updated so the new Analyze-phase contract is enforced mechanically.
- [x] Repo-wide drift surfaces are explicitly reviewed rather than assumed.
- [x] Final closeout evidence is appended to this plan after verification.

## Spec Coverage Check

- dense `/analyze` command structure from the attached draft: covered by Task 2
- harmony with the current `/implement` contract: covered by Tasks 2, 4, and 6
- registry preflight visibility before `/implement`: covered by Tasks 2, 3, and 4
- read-only default behavior and remediation boundary: covered by Tasks 1 and 2
- script-boundary decision for `analyze-spec.ps1`: covered by Task 3
- validator, workflow-test, and scaffold drift prevention: covered by Tasks 5 and 7
- repo-wide affected-artifact identification and reconciliation: covered by the Affected Artifact Map and Tasks 4-7

## Placeholder Scan

- No `TODO`, `TBD`, or “similar to previous task” placeholders are allowed in implementation commits for the governed surfaces touched by this slice.
- Historical docs under `docs/superpowers/` or prior plan records remain historical evidence unless they are active workflow owners.
- Upstream spec-kit hook/runtime concepts must not appear in final local command or validator text unless this slice explicitly adds that runtime, which it does not.

## Type And Contract Consistency

- `/tasks` owns task generation, receipt initialization, and gated checklist initialization.
- `/analyze` owns pre-implementation contradiction analysis and readiness reporting.
- `/implement` owns generated Applicable Standards Checklist statuses and implementation evidence.
- `/verify` owns final verification evidence and completion closure.
- Standards own phase semantics; command files own exact execution steps, working directory, and receipt obligations.

## Execution Handoff

Plan complete and saved to `docs/plans/2026-07-11-analyze-command-contract-update.md`. Two execution options:

**1. Subagent-Driven (recommended)** - Dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints.

Preferred execution path for this governance slice: Subagent-Driven for Tasks 2-6 with a main-agent review after each task, then inline verification for Task 7.

## Closeout Evidence

- Implementation status: complete.
- Script-boundary model chosen: Model A; `scripts/analyze-spec.ps1` remained narrow and `.agents/commands/analyze.md` absorbed the richer analysis/report contract.
- Files changed:
  - `.agents/commands/analyze.md`
  - `standards/command-workflow-contract.md`
  - `standards/spec-driven-workflow.md`
  - `standards/registry/command-workflow-contract.rules.json`
  - `standards/registry/spec-driven-workflow.rules.json`
  - `scripts/validate-codex-assets.ps1`
  - `scripts/test-workflow-enforcement.ps1`
- Registry files reviewed:
  - changed: `standards/registry/command-workflow-contract.rules.json`, `standards/registry/spec-driven-workflow.rules.json`
  - sweep-reviewed for alignment/no-change: `standards/registry/constitution.rules.json`, `standards/registry/codex-capabilities.rules.json`, `standards/registry/workspace.rules.json`
- Analyze-phase standards and registries reconciled:
  - `standards/command-workflow-contract.md` and `standards/spec-driven-workflow.md` now describe `/analyze` as the pre-implementation contradiction and blocker gate with registry preflight visibility but no implementation-evidence ownership.
  - Matching command-workflow and spec-driven-workflow registry rules now enforce the same ownership boundary.
- Validators and tests updated:
  - `scripts/validate-codex-assets.ps1` now enforces dense `/analyze` headings and required phrases.
  - `scripts/test-workflow-enforcement.ps1` now verifies Analyze-phase rule generation through `scripts/get-applicable-standard-rules.ps1`.
- Checks run:
  - `./scripts/test-analyze-spec.ps1`
  - `./scripts/test-workflow-enforcement.ps1`
  - `./scripts/validate-codex-assets.ps1`
  - `./scripts/check-all.ps1`
- Verification result:
  - all targeted checks passed
  - `./scripts/check-all.ps1` passed fully, including workspace checks, hook tests, workflow enforcement, spec analysis, template parity, secret scan, and generated-project workspace tests
- Drift sweep result:
  - repo-wide `rg` sweep over `.agents`, `standards`, `scripts`, `templates`, `projects`, and `docs` found no remaining active-owner surfaces that conflicted with the revised `/analyze` boundary
  - remaining hits were either updated owners, passive script references, scaffold references to `analyze-spec.ps1`, or historical evidence documents that should remain unchanged
- Compatibility notes:
  - validator compatibility remained intact
  - generated verify apps created during `check-all.ps1` passed spec artifact validation, spec analysis, and workflow receipt validation
- Remaining blockers: none in this slice
