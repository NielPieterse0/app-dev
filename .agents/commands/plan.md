# /plan

## Purpose

Create or update one implementation plan for the active numbered feature specification.

`/plan` is step two of the workflow. It only creates or updates `specs/NNN-<slug>/plan.md`.

It does not create or update:

- `spec.md`
- `tasks.md`
- `workflow-receipts.md`
- `checklist.md`
- app `AGENTS.md`

## Working Directory

Run inside `projects/<app>/`.

Do not run this command from the repository root.

## Start Gate

- Confirm the current directory contains app `AGENTS.md`.
- Confirm app `AGENTS.md` points to the intended active spec.
- Confirm `specs/NNN-<slug>/spec.md` exists.
- Confirm the active spec is concrete enough to plan from.

## Required Reads

- Active `specs/NNN-<slug>/spec.md`
- `../../templates/spec-workflow/plan.template.md`
- Revalidate only when the current session context is no longer reliable:
  - Root `../../AGENTS.md`
  - App `AGENTS.md`
  - `../../standards/spec-driven-workflow.md`
  - `../../standards/command-workflow-contract.md`
  - `../../standards/constitution.md`
  - `../../standards/workspace.md`
  - `../../standards/stack.md`
  - `../../standards/security.md`
  - `../../standards/codex-capabilities.md`
- Read `../../standards/testing.md` and `../../standards/scripting.md` only when they materially affect planning decisions, workflow obligations, or verification scope.

## Required Writes

- Active `specs/NNN-<slug>/plan.md`

## Pre-Step Checks

- Confirm the active `plan.md` will reference the same active spec path as app `AGENTS.md`.
- Confirm the work follows one allowed workflow shape: `lean` or `gated`.
- Confirm architecture, data, auth, permission, storage, platform, and verification questions are decided, explicitly deferred, or recorded as blockers.
- Confirm whether validation remains on the default compatibility contract or whether this app explicitly opted into a newer template-validation path.

## Execution Steps

### Phase 1: Read The Active Spec

1. Read the active `specs/NNN-<slug>/spec.md`.
2. Extract:
   - goal
   - non-goals
   - user scenarios
   - functional requirements
   - data touched
   - permissions or sensitive operations
   - target platforms or surfaces
   - risk level
   - verification intent
3. Identify the implementation decisions the spec already implies.
4. Identify any unresolved planning blockers.

### Phase 2: Classify The Work

1. Decide whether the slice follows the `lean` or `gated` path.
2. Determine whether the slice requires:
   - UI workflow coverage
   - data workflow coverage
   - mobile workflow coverage
   - release-readiness workflow coverage
3. Record only the workflows actually required by the slice.
4. Keep later-phase artifact expectations explicit without creating those artifacts yet.

### Phase 3: Create Or Update The Plan File

1. Create or update `specs/NNN-<slug>/plan.md`.
2. Use `../../templates/spec-workflow/plan.template.md`.
3. Keep the plan tied to the active spec folder only.
4. Do not create a second plan for the same active spec.

### Phase 4: Write The Plan

Populate `plan.md` with concrete content derived from the active spec.

The plan must include:

- plan status
- active spec id and path
- goal
- non-goals
- constitution check
- app type and platform targets
- technical context
- architecture decisions
- project structure and ownership
- module impact
- data, auth, permission, and storage impact
- workflow classification
- implementation readiness
- verification strategy
- rendered UI verification expectations when relevant
- risks and assumptions
- complexity tracking
- accepted decisions
- rejected decisions
- deferred decisions
- deviations and follow-ups
- handoff notes

### Phase 5: Apply Planning Quality Rules

When writing the plan:

- Ensure plan-to-spec alignment: the plan must implement the active spec without adding out-of-scope work.
- Ensure decision clarity: major implementation decisions are explicit rather than implied.
- Ensure boundary clarity: ownership, modules, and touched surfaces are concrete.
- Ensure implementation-readiness clarity: implementation constraints, workflow-specific requirements, and documentation-alignment obligations are explicit.
- Ensure verification clarity: checks, scripts, and rendered verification expectations are named precisely.
- Ensure workflow clarity: required later-phase artifacts and workflow owners are stated clearly.
- Ensure risk visibility: assumptions, blockers, and deferred decisions are separated from accepted decisions.
- Surface ambiguities and conflicts explicitly instead of hiding them in vague wording.

Also:

- Prefer implementation approach over product restatement.
- State how the slice should be built and verified, not just what it should do.
- Keep scope bounded to the active spec.
- Keep accepted, rejected, and deferred decisions separate.
- Use exact local paths and command names.
- Record planning gaps inside `plan.md` instead of leaving required fields blank.
- Record later-phase artifact expectations without creating or updating `tasks.md`, `workflow-receipts.md`, or `checklist.md`.

### Phase 6: Run Plan Review

Before finishing, review the plan against this checklist:

- `CHK-01` Does the plan reference the same active spec path as app `AGENTS.md`?
- `CHK-02` Does the plan stay within the active spec scope?
- `CHK-03` Are non-goals explicit?
- `CHK-04` Are app type and platform targets clear?
- `CHK-05` Are architecture decisions concrete enough to guide implementation?
- `CHK-06` Are ownership boundaries and touched modules identified?
- `CHK-07` Are data, auth, permission, storage, and sensitive-operation impacts described?
- `CHK-08` Is the workflow classified correctly as `lean` or `gated`?
- `CHK-09` Are required downstream workflows identified correctly?
- `CHK-10` Are verification commands and rendered UI expectations specific?
- `CHK-11` Are implementation constraints, workflow-specific implementation requirements, and documentation-alignment constraints explicit?
- `CHK-12` Are accepted, rejected, and deferred decisions separated clearly?
- `CHK-13` Are risks, assumptions, and blockers explicit?
- `CHK-14` Does the plan avoid assuming `tasks.md`, `workflow-receipts.md`, or `checklist.md` already exist?
- `CHK-15` Are all placeholder tokens removed?
- `CHK-16` Does the plan avoid introducing out-of-scope implementation detail that contradicts the spec?

### Phase 7: Run Planning Checks

1. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`.
2. Run `../../scripts/analyze-spec.ps1 -ProjectPath .` when enough detail exists for pre-implementation analysis.
3. If a check is skipped, record the exact reason in `plan.md`.
4. If a check fails, update the plan before treating the step as complete.

## Post-Step Checks

- `plan.md` exists at `specs/NNN-<slug>/plan.md`.
- Any skipped analysis check is recorded with the exact blocker.

## Receipt Updates

- Do not update `workflow-receipts.md` from `/plan`.

## Stop Conditions

- No active spec is selected in app `AGENTS.md`.
- The active spec is too incomplete to support implementation planning.
- App `AGENTS.md` and the active `plan.md` would point to different active specs.
- Required architecture, data, permission, or platform decisions are unresolved.
- More than three material planning blockers remain unresolved.
- Artifact or analysis checks fail and the failure changes the plan.

## Completion Report

Report:

- active spec folder
- plan file path
- workflow classification
- key architecture and verification decisions
- blockers, deferred decisions, or assumptions
- checks run and results
- recommended next command

## Next Command

Run `/tasks` after `plan.md` is complete and planning blockers are closed or explicitly deferred.
