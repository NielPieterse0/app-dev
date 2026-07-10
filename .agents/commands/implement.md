# /implement

## Purpose

Execute the active task sequence while keeping spec artifacts and workflow receipts current.

## Working Directory

Run inside `projects/<app>/`.

## Start Gate

- Confirm app `AGENTS.md`, `PLAN.md`, active `spec.md`, active `tasks.md`, and active `workflow-receipts.md` exist.
- Confirm `tasks.md` uses executable `T###` task IDs.
- Confirm gated checklist items required before implementation are complete or explicitly approved to proceed.
- Stop if workflow obligations are unclassified.

## Required Reads

- App `AGENTS.md`
- `PLAN.md`
- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/tasks.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- Active `specs/NNN-<slug>/checklist.md` when present
- Local workflow skills for required UI, data, mobile, or release-readiness obligations

## Required Writes

- Application source, tests, configuration, and docs named by `tasks.md`
- Active `tasks.md` task status updates
- Active `workflow-receipts.md` implementation evidence and outstanding-gap updates
- Active `checklist.md` gated readiness updates when applicable
- `PLAN.md` or `spec.md` only when implementation exposes a real artifact drift that must be reconciled before verification

## Pre-Step Checks

- Run or confirm `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`.
- Classify UI, data, mobile, and release-readiness obligations.
- Confirm required local workflow wrappers are followed and receipt sections are ready.
- Confirm no task requires unapproved destructive, credentialed, or live-environment action.
- Confirm validator mode remains compatibility for established apps unless this implementation slice explicitly includes a template-refresh migration.

## Execution Steps

1. Execute tasks in dependency order, completing setup and foundation tasks before story or vertical-increment tasks.
2. For each completed task, update `tasks.md` from `[ ]` to `[x]`.
3. For deferred tasks, leave them unchecked and record the reason in the task or handoff notes.
4. Keep implementation evidence in `workflow-receipts.md` current as files and surfaces change.
5. Add or update tests with behavior changes when the project test structure supports them.
6. Run focused checks as each slice becomes testable.
7. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before handoff. Use `-ValidationMode current-template` only when the app opted into the current scaffold contract.

## Post-Step Checks

- Completed tasks correspond to real changes or explicit no-op findings.
- `workflow-receipts.md` lists implementation evidence for required workflow sections.
- `PLAN.md` and `spec.md` still match implementation decisions.
- `check-spec-artifacts.ps1` passes before handoff or the exact blocker is recorded.

## Receipt Updates

- Record `/implement` in `Command path used:` for required workflow sections.
- Record implementation evidence as concrete files, modules, migrations, UI surfaces, or scripts.
- Record focused checks already run and gaps left for `/verify`.

## Stop Conditions

- Required artifacts are missing or stale.
- A gated checklist has incomplete blocking items and no explicit approval to proceed.
- A task requires network, credentialed, destructive, or live-environment action without approval.
- Focused checks reveal a defect that changes the spec or plan.

## Completion Report

Report tasks completed, tasks deferred, files changed, focused checks run, receipt sections updated, blockers, and that completion is not claimed until `/verify`.

## Next Command

Run `/verify` after implementation tasks are complete or intentionally deferred and artifacts are reconciled.
