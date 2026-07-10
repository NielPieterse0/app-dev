# /verify

## Purpose

Close convergence and verification evidence for the active spec.

## Working Directory

Run inside `projects/<app>/`.

## Start Gate

- Confirm app `AGENTS.md`, `PLAN.md`, active `spec.md`, active `tasks.md`, and active `workflow-receipts.md` exist.
- Confirm implementation has stopped changing source files except for convergence and evidence updates.
- Confirm required workflow sections contain implementation evidence or explicit outstanding gaps.

## Required Reads

- App `AGENTS.md`
- `PLAN.md`
- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/tasks.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- Active `specs/NNN-<slug>/checklist.md` when present
- `../../templates/spec-workflow/converge.template.md`
- Project package scripts and verification configuration

## Required Writes

- Active `workflow-receipts.md` verification evidence and closure state
- Active `tasks.md` task status, deferred items, or convergence tasks
- `PLAN.md` or `spec.md` only to reconcile documented state with implemented reality
- A convergence note from `converge.template.md` when the feature needs explicit handoff detail

## Pre-Step Checks

- Reconcile implemented behavior against `spec.md`, `PLAN.md`, `tasks.md`, and receipts before running final gates.
- Confirm required rendered UI evidence is planned for UI work.
- Confirm skipped checks have a concrete blocker and next action.
- Confirm whether verification is using the established app compatibility contract or the explicit `current-template` contract for a new or refreshed scaffold.

## Execution Steps

1. Compare implementation against spec requirements, success criteria, plan decisions, and task status.
2. Update artifacts so they describe the implemented state, deferred items, and deviations.
3. Add a convergence note when reconciliation is non-trivial.
4. Run `../../scripts/analyze-spec.ps1 -ProjectPath .`.
5. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`. Use `-ValidationMode current-template` only for newly generated or explicitly refreshed apps.
6. Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
7. Run `../../scripts/verify-app.ps1 -ProjectPath .`.
8. For UI work, perform rendered first-screen, core-interaction, desktop viewport, and mobile viewport checks.
9. Record verification commands, results, skipped checks, blockers, deviations, and follow-ups in `workflow-receipts.md`.

## Post-Step Checks

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
- Spec, plan, tasks, and implementation disagree in a way that affects behavior or risk.

## Completion Report

Report convergence result, commands run, rendered checks, receipt closure state, skipped checks, blockers, deviations, follow-ups, and final changed-file summary.

## Next Command

Use `/release-readiness` only when the active spec or receipt classification requires release-readiness closure. Otherwise hand off after verification is complete.
