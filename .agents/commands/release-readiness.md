# /release-readiness

## Purpose

Close release-readiness obligations for the active numbered feature specification package before any completion, delivery, commit, push, PR, deployment-adjacent, or production-readiness claim.

`/release-readiness` is the final workflow closure gate after `/verify` when the active workflow classification, risk surface, or user request requires explicit release-readiness handling. It confirms the active verification state is real, checks that risky completion surfaces are documented honestly, records release-readiness evidence in `workflow-receipts.md`, and reports unresolved gaps before any final completion claim.

It closes the active:

- `spec.md`
- `plan.md`
- `tasks.md`
- `workflow-receipts.md`
- `checklist.md` when required by risk level
- release-adjacent implementation, verification, approval, deployment, security, or handoff notes required to support the completion claim

It does not create or initialize:

- `spec.md`
- `plan.md`
- `tasks.md`
- `workflow-receipts.md`
- `checklist.md`
- app `AGENTS.md`

It does not silently absorb unfinished implementation from `/implement`, unfinished remaining-work discovery from `/converge`, or missing verification evidence from `/verify`.

## User Input

Treat non-empty user arguments as release-readiness constraints for this run.

User arguments can narrow the target handoff, delivery surface, or reporting depth, but they cannot override the active spec, required workflow closure, required verification evidence, unresolved-gap reporting, safety gates, or approval requirements.

## Working Directory

Run inside `projects/<app>/`.

Do not run this command from the repository root.

## Start Gate

- Confirm the current directory contains app `AGENTS.md`.
- Confirm app `AGENTS.md` points to the intended active spec.
- Confirm active `specs/NNN-<slug>/spec.md`, `plan.md`, `tasks.md`, and `workflow-receipts.md` exist.
- Confirm gated `checklist.md` exists when required by the active spec risk level.
- Confirm `/verify` already ran for the current converged state, or explicitly treat missing verification closure as a blocker.
- Confirm the active workflow classification or current request actually requires release-readiness closure.
- Confirm the run is closing the present implementation state, not speculating about future release work.

## Required Reads

- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/plan.md`
- Active `specs/NNN-<slug>/tasks.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- Active `specs/NNN-<slug>/checklist.md` when required by the active spec risk level
- Relevant implemented files, deployment files, auth files, migration files, environment contracts, CI files, and delivery notes needed to judge the completion claim honestly
- Project package scripts and verification configuration
- `../../scripts/get-workflow-obligations.ps1`
- `../../scripts/get-applicable-standard-rules.ps1`
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
- Read the local wrapper workflow:
  - `../../.agents/skills/release-readiness-workflow/SKILL.md`
- Read prose standards only when a selected registry rule is unclear, release-readiness drift changes a governed owner surface, or a registry is missing or malformed

## Required Writes

- Active `specs/NNN-<slug>/workflow-receipts.md` release-readiness evidence, blockers, and closure state
- Active `specs/NNN-<slug>/tasks.md` only when release-readiness reveals a real remaining-work item that must be owned explicitly
- Active `specs/NNN-<slug>/plan.md`, `spec.md`, or `checklist.md` only when the recorded state is materially wrong for the completion claim
- Touched docs, standards, registries, command docs, skills, or scripts only when release-readiness work exposes governed-surface drift that must be reconciled before handoff

Do not create new product scope under the guise of release-readiness.

## Pre-Step Checks

- Confirm active `spec.md`, active `plan.md`, and app `AGENTS.md` reference the same active spec.
- Confirm `workflow-receipts.md` and any required `checklist.md` were initialized in earlier phases and are now being closed rather than created here.
- Confirm required workflow receipt sections already contain implementation and verification evidence, or record the exact missing owner command.
- Confirm no completion claim will be made without exact unresolved-gap reporting.
- Confirm any requested commit, push, PR, deploy, or production-readiness claim is supported by the active verification state rather than implied by intent alone.
- Confirm external skills or plugins remain optional accelerators routed through the local wrapper, not hard runtime dependencies.

## Execution Steps

### Phase 1: Read The Release Context

1. Read the active `spec.md`, `plan.md`, `tasks.md`, and `workflow-receipts.md`.
2. Read active `checklist.md` when required by risk level.
3. Read the implemented and delivery-adjacent files needed to judge the claimed readiness surface.
4. Extract:
   - active spec path
   - feature goal
   - workflow classification
   - completion claim surface
   - risky touched surfaces such as auth, payments, public APIs, deploy, secrets, live migrations, or production-readiness notes
   - required workflow receipt sections
   - final verification commands and results
   - rendered verification status when applicable
   - checklist approval state when applicable
   - outstanding gaps, deferrals, blockers, and assumptions
5. Identify any artifact drift that would make the completion claim misleading.

### Phase 2: Confirm Release-Readiness Obligation

1. Run `../../scripts/get-workflow-obligations.ps1 -ProjectPath .`.
2. Confirm the active spec classification, touched surfaces, or user request require release-readiness closure.
3. If release-readiness is not actually required, report that explicitly and route back to `/verify` handoff instead of fabricating a release gate.
4. If release-readiness is required only because the user requested final completion, keep the closure scoped to honest handoff evidence.

### Phase 3: Review Applicable Rules And Wrapper Expectations

1. Derive candidate touched surfaces from the active artifacts, implemented risky surfaces, requested handoff actions, and final changed files when available.
2. Read relevant `../../standards/registry/*.rules.json` files before reading long prose standards.
3. Run `../../scripts/get-applicable-standard-rules.ps1` with the active spec path, changed files when available, and phase `release-readiness`.
4. Match candidate rules by `applies_to`, `trigger_kinds`, and `phases`.
5. Review the local `release-readiness-workflow` wrapper and any optional external capability routes it points to.
6. Report candidate critical or high rules that still pressure the completion claim.
7. Do not invent deployment evidence, approval evidence, or GitHub evidence that this run did not actually produce.
8. If an applicable registry is missing, malformed, or inconsistent with its prose standard, report a `CRITICAL` governance finding.

Registry review must include these families when triggered:

- `../../standards/registry/constitution.rules.json`
- `../../standards/registry/spec-driven-workflow.rules.json`
- `../../standards/registry/command-workflow-contract.rules.json`
- `../../standards/registry/workspace.rules.json`
- `../../standards/registry/stack.rules.json`
- `../../standards/registry/security.rules.json`
- `../../standards/registry/testing.rules.json`
- `../../standards/registry/scripting.rules.json`
- `../../standards/registry/codex-capabilities.rules.json`

### Phase 4: Re-Run Governed Closure Checks

1. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`. Use `-ValidationMode current-template` only for newly generated or explicitly refreshed apps.
2. Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
3. Run `../../scripts/verify-app.ps1 -ProjectPath .` when the completion claim depends on the current app verification state remaining valid.
4. Treat command failures as blocking findings unless the failure is clearly environmental.
5. Report every failure with the owning artifact, command, and recommended next action.

### Phase 5: Assess Completion Claim Integrity

1. Confirm required workflow receipt sections have concrete implementation evidence, verification commands, verification results, outstanding gaps, and decision state.
2. Confirm the `Release Readiness Workflow Receipt` reflects the real trigger surface and handoff intent for this slice.
3. Confirm required gated or sensitive approvals are either complete, explicitly blocked, or explicitly deferred.
4. Confirm unresolved gaps are reported before any claim of completion, readiness, or delivery.
5. If commit, push, PR, deploy, or production-readiness work was requested but not executed, record that exact limitation rather than implying closure.
6. If release-readiness reveals actual remaining feature work, route it back to `tasks.md` or the owning command instead of silently absorbing it here.

### Phase 6: Assign Severity

Use deterministic severity.

- `CRITICAL`: missing required verification evidence; missing required gated approval state; malformed required registry; completion claim contradicts current artifact or verification reality; risky release surface is represented as ready without evidence.
- `HIGH`: major governed check skipped without accepted blocker; unresolved auth, payments, public API, deploy, migration, or security gap affects the completion claim; required workflow receipt closure is incomplete or misleading.
- `MEDIUM`: non-blocking delivery or handoff drift; incomplete receipt detail that does not invalidate the result; important unresolved ownership on a deferred next step.
- `LOW`: wording cleanup, note clarity, redundancy, or style-only receipt improvement.

### Phase 7: Produce Release-Readiness Report

Output a Markdown report.

Use this format:

```md
## Specification Release-Readiness Report

Active spec: `specs/NNN-<slug>/`
Workflow obligations: `../../scripts/get-workflow-obligations.ps1 -ProjectPath .`
Registry review: `../../scripts/get-applicable-standard-rules.ps1 -ProjectPath . -SpecDir specs/NNN-<slug> -Phase release-readiness`
Artifact validation: `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
Receipt validation: `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`
App verification: `../../scripts/verify-app.ps1 -ProjectPath .`
Result: READY | BLOCKED | READY_WITH_GAPS

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|

## Closure Checks

| Check | Result | Evidence | Notes |
|-------|--------|----------|-------|

## Workflow Receipt Closure

| Receipt Area | Required? | Closure State | Verification State | Outstanding Gaps | Notes |
|--------------|-----------|---------------|--------------------|------------------|-------|

## Registry Review

| Registry | Candidate Rule IDs | Highest Severity | Reason Selected | Release Impact |
|----------|--------------------|------------------|-----------------|----------------|

## Handoff And Delivery Notes

State `Not requested.` when no commit, push, PR, deploy, or delivery claim is part of this run.

## Metrics

- Total closure checks run:
- Closure checks passed:
- Closure checks failed:
- Closure checks skipped:
- Required workflow receipts closed:
- Receipt gaps remaining:
- Candidate critical or high registry rules:
- Critical issue count:
- High issue count:

## Next Actions

- Resolve CRITICAL and HIGH findings before any completion, push, PR, deploy, or release claim.
- Record exact owners and blockers for deferred MEDIUM findings.
- LOW findings may be deferred when they do not affect completion integrity.
```

### Phase 8: Update Release-Readiness Evidence

1. Record `/release-readiness` in `Command path used:` for receipt sections updated by this closure pass.
2. Update the `Release Readiness Workflow Receipt` with:
   - trigger surface
   - command path used
   - local workflow used
   - external skill used or unavailable
   - files and surfaces reviewed
   - implementation evidence
   - verification commands
   - verification result
   - outstanding gaps
   - decision and closure
3. Record exact commands run, blockers, skipped checks, and unresolved gaps.
4. Mark closure complete only when the supporting evidence is real and the remaining risk is honestly represented.
5. Do not record aspirational future work as completed release evidence.

### Phase 9: Run Release-Readiness Review

Before finishing, review the release-readiness pass against this checklist:

- `CHK-01` Does the closure stay within the active spec scope and real completion claim?
- `CHK-02` Do app `AGENTS.md`, active `spec.md`, and active `plan.md` point to the same active spec?
- `CHK-03` Did `/verify` already run, or is the missing verification state reported as a blocker?
- `CHK-04` Did `get-workflow-obligations.ps1`, `check-spec-artifacts.ps1`, `validate-workflow-receipts.ps1`, and any required `verify-app.ps1` run or fail with exact blockers?
- `CHK-05` Were relevant registry files reviewed or explicitly reported as not selected?
- `CHK-06` Are required release-readiness receipt fields concrete and current?
- `CHK-07` Are unresolved gaps reported before any completion, push, PR, deploy, or release claim?
- `CHK-08` Does the report avoid implying deploy, GitHub, approval, or production closure that did not actually happen?
- `CHK-09` Does the result distinguish ready, blocked, and ready-with-gaps honestly?
- `CHK-10` Are next actions assigned to the correct owning artifact, command, or delivery surface?

## Post-Step Checks

- Completion claims are supported by current evidence or explicitly blocked.
- The `Release Readiness Workflow Receipt` contains concrete current closure evidence.
- Required workflow receipt sections do not hide unresolved gaps.
- Required governed checks are reported with exact results or exact blockers.
- Final handoff can separate actual ready surfaces from deferred or blocked surfaces.

## Receipt Updates

- Record `/release-readiness` in `Command path used:` for sections updated during closure.
- Record exact closure checks and current blockers.
- Record unresolved gaps before any completion claim.
- Mark release-readiness complete only when the evidence supports the claim honestly.

## Stop Conditions

- Required artifacts are missing or stale.
- App `AGENTS.md`, active `spec.md`, and active `plan.md` reference different active specs.
- `/verify` has not run and the requested completion claim depends on verification closure.
- A required workflow receipt section is missing or materially incomplete.
- A gated checklist is required but missing.
- A required registry file for a touched governed surface is missing or malformed.
- A completion claim would rely on unrun checks, unknown approval state, or undocumented risky gaps.
- Release-readiness reveals actual remaining implementation or convergence work that must return to an earlier command.

## Completion Report

Report:

- active spec folder
- release-readiness result
- closure checks run
- registry files reviewed
- receipt sections updated
- finding counts by severity
- unresolved gaps, blockers, assumptions, and deferred items
- changed files caused by release-readiness reconciliation
- recommended next command or delivery action

## Next Command

- Hand off when release-readiness reports `READY` or an explicitly accepted `READY_WITH_GAPS`.
- Return to `/verify`, `/converge`, or `/implement` when the blocking owner is evidence, remaining work, or implementation state rather than release closure.
