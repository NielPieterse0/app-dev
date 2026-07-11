# /verify

## Purpose

Verify the active numbered feature specification package after convergence is already closed.

`/verify` is the post-convergence verification gate. It confirms the converged implementation state still matches the active specification package, runs governed verification commands, records rendered and non-rendered verification evidence, updates workflow receipts, and closes completion honestly.

It verifies the active:

- `spec.md`
- `plan.md`
- `tasks.md`
- `workflow-receipts.md`
- `checklist.md` when required by risk level
- implemented files and verification configuration needed to confirm verified behavior

It does not create or initialize:

- `spec.md`
- `plan.md`
- `tasks.md`
- `workflow-receipts.md`
- `checklist.md`
- app `AGENTS.md`

It does not re-own remaining-work discovery from `/converge`, reopen implementation scope silently, or claim release-readiness closure unless the active workflow classification explicitly requires `/release-readiness`.

## User Input

Treat non-empty user arguments as verification constraints for this run.

User arguments can narrow verification focus, reporting depth, or rendered-check emphasis, but they cannot override the active spec, required evidence, rendered UI obligations, safety gates, or approval requirements.

## Working Directory

Run inside `projects/<app>/`.

Do not run this command from the repository root.

## Start Gate

- Confirm the current directory contains app `AGENTS.md`.
- Confirm app `AGENTS.md` points to the intended active spec.
- Confirm app `AGENTS.md`, active `plan.md`, active `spec.md`, active `tasks.md`, and active `workflow-receipts.md` exist.
- Confirm gated `checklist.md` exists when required by the active spec risk level.
- Confirm `/converge` already closed remaining implementation work for the current task set.
- Confirm implementation has stopped changing source files except for verification evidence updates or explicitly approved final blocker fixes.
- Confirm required workflow sections contain implementation evidence or explicit outstanding gaps.
- Confirm the Applicable Standards Checklist already reflects the implementation-time rule selection or explicitly records any remaining drift blocker.

## Required Reads

- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/plan.md`
- Active `specs/NNN-<slug>/tasks.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- Active `specs/NNN-<slug>/checklist.md` when required by the active spec risk level
- Relevant implemented files needed to confirm requirement, behavior, and closure state
- Project package scripts and verification configuration
- `../../scripts/analyze-spec.ps1`
- `../../scripts/check-spec-artifacts.ps1`
- `../../scripts/validate-workflow-receipts.ps1`
- `../../scripts/verify-app.ps1`
- Revalidate only when the current session context is no longer reliable:
  - Root `../../AGENTS.md`
  - App `AGENTS.md`
  - `../../standards/spec-driven-workflow.md`
  - `../../standards/command-workflow-contract.md`
  - `../../standards/constitution.md`
  - `../../standards/workspace.md`
  - `../../standards/codex-capabilities.md`
- Read prose standards only when a selected registry rule is unclear, verification drift changes a governed owner surface, or a registry is missing or malformed

## Required Writes

- Active `specs/NNN-<slug>/workflow-receipts.md` verification evidence and closure state
- Active `specs/NNN-<slug>/tasks.md` task status or deferred items only when verification reveals a real follow-up that must be documented
- Active `specs/NNN-<slug>/plan.md` or `spec.md` only to reconcile documented state with the verified implemented reality
- Active `specs/NNN-<slug>/checklist.md` only when gated verification state or approval state is wrong

Do not create new implementation scope under the guise of verification.

## Pre-Step Checks

- Confirm active `spec.md`, active `plan.md`, and app `AGENTS.md` reference the same active spec.
- Confirm implemented behavior has already been reconciled against `spec.md`, `plan.md`, and `tasks.md` through `/converge`.
- Confirm required rendered UI evidence is planned for UI work.
- Confirm skipped checks have a concrete blocker and next action.
- Confirm whether verification is using the established app compatibility contract or the explicit `current-template` contract for a new or refreshed scaffold.
- Confirm `workflow-receipts.md` and any required `checklist.md` were created in earlier phases and are now being closed rather than initialized here.
- Confirm no completion claim will be made without fresh verification evidence from this run.

## Execution Steps

### Phase 1: Read The Converged State

1. Read the active `spec.md`, `plan.md`, `tasks.md`, and `workflow-receipts.md`.
2. Read active `checklist.md` when required by risk level.
3. Read the implemented files and verification configuration needed to confirm behavior.
4. Extract:
   - active spec path
   - feature goal
   - functional requirements and success criteria
   - architecture, data, auth, permission, storage, and platform decisions
   - task IDs, completion state, and deferred items
   - workflow classification
   - Applicable Standards Checklist state
   - required workflow receipt sections
   - planned verification commands
   - rendered UI obligations
   - blockers, gaps, and follow-ups already recorded
5. Identify any final artifact drift that would make verification results misleading.

### Phase 2: Close Final Artifact Drift Before Running Gates

1. Confirm the converged implementation state still matches the active `spec.md`, `plan.md`, `tasks.md`, and the selected Applicable Standards Checklist entries.
2. Update artifacts only where verification results, deferred items, approval state, or final deviations need to be documented accurately.
3. If verification reveals actual remaining feature work rather than evidence-only drift, treat that as a blocker and route it back through the owning artifact or command path instead of silently absorbing it here.

### Phase 3: Run Governed Verification Commands

1. Run `../../scripts/analyze-spec.ps1 -ProjectPath .`.
2. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`. Use `-ValidationMode current-template` only for newly generated or explicitly refreshed apps.
3. Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
4. Run `../../scripts/verify-app.ps1 -ProjectPath .`.
5. Treat command failures as blocking findings unless the failure is clearly environmental.
6. Report every failure with the owning command, artifact, and recommended next action.

### Phase 4: Run Rendered Verification

1. Determine whether UI, layout, interaction, or platform-visible behavior changed enough to require rendered checks.
2. For UI work, perform:
   - first meaningful screen check
   - core interaction check
   - desktop viewport check
   - mobile viewport check
3. Record the exact surface, interaction, viewport, and outcome.
4. Treat missing rendered evidence for required UI work as a blocking verification gap.

### Phase 5: Review Evidence And Closure State

1. Confirm required workflow receipt sections contain concrete verification evidence rather than placeholders.
2. Confirm required workflow sections have a closure state other than `not-applicable` or `not-started`.
3. Confirm `tasks.md` accurately separates completed work, deferred work, and verification follow-ups.
4. Do not regenerate the Applicable Standards Checklist during `/verify` unless implementation drift or a newly discovered touched surface makes the current checklist inaccurate.
5. If checklist drift is discovered, reconcile it before completion claims.

### Phase 6: Assign Severity

Use deterministic severity.

- `CRITICAL`: governed verification command fails on a real defect; required verification evidence missing; required rendered UI evidence missing; gated verification state missing; spec and implementation materially disagree on shipped behavior or risk.
- `HIGH`: major verification command skipped without an accepted blocker; receipt, task, or plan drift obscures what was actually shipped; unresolved deviation affects correctness, security, data, auth, or platform behavior.
- `MEDIUM`: incomplete non-blocking receipt detail; deferred work not clearly owned; important verification context missing but not invalidating the result.
- `LOW`: wording cleanup, note clarity, redundancy, or style-only receipt improvement.

### Phase 7: Produce Verification Report

Output a Markdown report.

Use this format:

```md
## Specification Verification Report

Active spec: `specs/NNN-<slug>/`
Analysis script: `../../scripts/analyze-spec.ps1 -ProjectPath .`
Artifact validation: `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
Receipt validation: `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`
App verification: `../../scripts/verify-app.ps1 -ProjectPath .`
Result: PASS | FAIL | PASS_WITH_WARNINGS

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|

## Verification Commands

| Command | Result | Evidence | Notes |
|---------|--------|----------|-------|

## Rendered Checks

State `Not applicable.` when no rendered verification is required.

| Surface | Viewport Or Device | Interaction | Result | Notes |
|---------|--------------------|-------------|--------|-------|

## Receipt Closure

| Receipt Area | Required? | Closure State | Verification Evidence Present? | Notes |
|--------------|-----------|---------------|--------------------------------|-------|

## Deferred Items

State `None.` when clean.

## Metrics

- Total verification commands run:
- Commands passed:
- Commands failed:
- Commands skipped:
- Rendered checks required:
- Rendered checks completed:
- Receipt sections closed:
- Receipt gaps remaining:
- Critical issue count:
- High issue count:

## Next Actions

- Resolve CRITICAL and HIGH findings before handoff.
- Record exact blockers and owners for any deferred MEDIUM findings.
- LOW findings may be deferred when they do not affect verification integrity.
```

### Phase 8: Receipt Handling

1. Record `/verify` in `Command path used:` for receipt sections closed by verification.
2. Record exact commands run, exit outcomes, rendered checks, blockers, skipped checks, deviations, and follow-ups in `workflow-receipts.md`.
3. Mark closure complete only when required checks pass or documented gaps are explicitly accepted and owned.
4. Do not record unverifiable assumptions as evidence.

### Phase 9: Run Verification Review

Before finishing, review the verification against this checklist:

- `CHK-01` Does the verification stay within the active spec scope?
- `CHK-02` Do app `AGENTS.md`, active `spec.md`, and active `plan.md` point to the same active spec?
- `CHK-03` Are required artifacts present and already initialized by the correct earlier phases?
- `CHK-04` Did `/converge` already close remaining implementation work for the current task set?
- `CHK-05` Did `analyze-spec.ps1`, `check-spec-artifacts.ps1`, `validate-workflow-receipts.ps1`, and `verify-app.ps1` run or fail with exact blockers?
- `CHK-06` Are rendered UI checks present when UI work requires them?
- `CHK-07` Do receipt sections contain concrete verification evidence rather than placeholders?
- `CHK-08` Does `tasks.md` accurately separate completed work, deferred work, and follow-ups?
- `CHK-09` Is Applicable Standards Checklist drift either absent or explicitly reconciled?
- `CHK-10` Are failures, skipped checks, and environmental blockers reported with exact ownership?
- `CHK-11` Does the report avoid claiming release-readiness unless that closure is explicitly required?
- `CHK-12` Does the report avoid claiming success without fresh evidence from this run?

## Post-Step Checks

- Convergence remains closed; `/verify` did not silently absorb remaining implementation work.
- Governed verification command results are reported.
- Rendered verification status is reported when applicable.
- Required workflow receipt sections have non-placeholder verification evidence.
- Required workflow sections have a closure state other than `not-applicable` or `not-started`.
- `tasks.md` accurately marks completed and deferred work.
- Final handoff can separate implemented changes from unrelated dirty worktree changes.

## Receipt Updates

- Record `/verify` in `Command path used:` for sections closed by verification.
- Record exact commands and rendered checks performed.
- Record failures, skipped checks, and outstanding gaps before completion claims.
- Mark closure complete only when required checks pass or documented gaps are intentionally deferred.

## Stop Conditions

- Any required gate fails without a documented, accepted deferral.
- Required verification evidence is missing.
- UI work lacks rendered verification evidence.
- Spec, `plan.md`, tasks, and implementation disagree in a way that affects behavior or risk.
- Verification reveals actual remaining feature work that belongs back in `/converge` or `/implement`.

## Completion Report

Report:

- active spec folder
- verification result
- commands run
- rendered checks run when applicable
- receipt sections closed
- Applicable Standards Checklist drift status
- finding counts by severity
- blockers, assumptions, deferred items, and follow-ups
- changed files caused by verification reconciliation
- recommended next command

## Next Command

Use `/release-readiness` only when the active spec or receipt classification requires release-readiness closure. Otherwise hand off after verification is complete.
