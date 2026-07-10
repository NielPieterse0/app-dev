# /plan

## Purpose

Turn the active numbered spec into the app-level implementation plan.

## Working Directory

Run inside `projects/<app>/`.

## Start Gate

- Confirm app `AGENTS.md` points to the intended active spec.
- Confirm `specs/NNN-<slug>/spec.md`, `tasks.md`, and `workflow-receipts.md` exist.
- Stop if `spec.md` still contains unresolved placeholders or material `NEEDS CLARIFICATION` items.

## Required Reads

- App `AGENTS.md`
- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/tasks.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- `../../templates/spec-workflow/PLAN.template.md`
- `../../standards/spec-driven-workflow.md`
- `../../standards/command-workflow-contract.md`
- `../../standards/constitution.md`

## Required Writes

- `PLAN.md`
- Active `workflow-receipts.md`, when planning changes workflow classification or outstanding gaps
- Active `tasks.md`, when planning exposes required planning or verification tasks

## Pre-Step Checks

- Confirm `PLAN.md` will reference the same active spec path as app `AGENTS.md`.
- Confirm the work is lean or gated according to the workflow standard.
- Confirm architecture, data, auth, permission, storage, platform, and verification questions are either decided, rejected, deferred, or marked as blockers.
- Confirm whether validation remains on the default compatibility contract or whether this app explicitly opted into `../../scripts/check-spec-artifacts.ps1 -ValidationMode current-template`.

## Execution Steps

1. Read the active spec and extract goal, non-goals, scenarios, requirements, data impact, permissions, platforms, and verification intent.
2. Fill `PLAN.md` from `templates/spec-workflow/PLAN.template.md`.
3. Record active spec id/path, status, app type, platform targets, architecture decisions, module impact, data/auth/permission/storage impact, workflow classification, verification strategy, rendered UI expectations, risks, assumptions, decisions, deviations, and follow-ups.
4. Keep accepted, rejected, and deferred decisions separate.
5. Update receipts if planning changes workflow obligations or external skill usage.
6. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`. Use `-ValidationMode current-template` only for newly generated or template-refresh work.
7. Run `../../scripts/analyze-spec.ps1 -ProjectPath .` when enough detail exists for pre-implementation analysis.

## Post-Step Checks

- `PLAN.md` contains active spec, tasks, receipts, and checklist paths.
- No required plan field remains unresolved.
- Plan decisions match the current spec and do not introduce out-of-scope implementation.
- Any skipped analysis check is recorded with the exact blocker.

## Receipt Updates

- Record `/plan` in `Command path used:` for workflow sections classified or changed during planning.
- Record files and surfaces reviewed.
- Record planning gaps as outstanding gaps instead of leaving fields blank.

## Stop Conditions

- App `AGENTS.md` and `PLAN.md` would point to different active specs.
- Required architecture, data, permission, or platform decisions are unresolved.
- Gated work lacks a current checklist.
- Artifact or analysis checks fail and the failure changes the plan.

## Completion Report

Report the active spec path, `PLAN.md` status, key decisions, workflow classification, checks run, blockers or skipped checks, and whether the next step is `/tasks`.

## Next Command

Run `/tasks` after `PLAN.md` is current and any planning blockers are closed or explicitly deferred.
