# /tasks

## Purpose

Convert the active spec and app plan into an executable, dependency-ordered task sequence.

## Working Directory

Run inside `projects/<app>/`.

## Start Gate

- Confirm app `AGENTS.md`, `PLAN.md`, active `spec.md`, active `tasks.md`, and active `workflow-receipts.md` exist.
- Confirm `PLAN.md` references the same active spec as app `AGENTS.md`.
- Stop if the plan has unresolved blockers that prevent task sequencing.

## Required Reads

- App `AGENTS.md`
- `PLAN.md`
- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- `../../templates/spec-workflow/tasks.template.md`
- `../../standards/spec-driven-workflow.md`
- `../../standards/command-workflow-contract.md`

## Required Writes

- Active `specs/NNN-<slug>/tasks.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- Active `specs/NNN-<slug>/checklist.md` when gated risk readiness changes

## Pre-Step Checks

- Confirm task IDs will use strict `T001` sequencing.
- Confirm `[P]` is reserved for independent files or independent surfaces.
- Confirm material implementation tasks include exact repo-relative paths.
- Confirm each user story or vertical increment is independently testable where practical.
- Confirm whether the app is staying on validator compatibility mode or is intentionally targeting `../../scripts/check-spec-artifacts.ps1 -ValidationMode current-template`.

## Execution Steps

1. Load spec scenarios, functional requirements, success criteria, plan decisions, workflow classifications, and current receipt gaps.
2. Rewrite `tasks.md` from the task template using setup, foundation, user story or vertical-increment phases, polish, and verification.
3. Assign sequential task IDs in execution order.
4. Label story tasks with `[US1]`, `[US2]`, or equivalent vertical-increment labels.
5. Add `[P]` only when tasks touch independent files or can proceed without shared unfinished dependencies.
6. Include explicit tasks for artifact updates, receipt updates, tests, rendered UI checks when required, and final verification.
7. Update workflow classification and outstanding gaps in receipts.
8. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`. Use `-ValidationMode current-template` only for newly generated or template-refresh work.
9. Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath .` without `-RequireVerificationEvidence` to validate receipt shape before implementation.

## Post-Step Checks

- `tasks.md` contains `## Task List`.
- Every material task follows `- [ ] T### ...`.
- Tasks are executable without unstated context.
- Verification and receipt-update tasks are present.
- Required checklist readiness items are current for gated work.

## Receipt Updates

- Record `/tasks` in `Command path used:` for workflow sections whose classification or gaps changed.
- Record the task-generation files reviewed.
- Keep verification evidence as planned or not-run until `/verify`.

## Stop Conditions

- Task sequence depends on unresolved plan decisions.
- A task would require destructive or live-environment action without explicit approval.
- Receipt validation fails and cannot be resolved in the artifact set.
- The work cannot be split into independently verifiable increments.

## Completion Report

Report total task count, phase breakdown, parallel opportunities, workflow classification, checks run, blockers or skipped checks, and whether the next step is `/implement`.

## Next Command

Run `/implement` after tasks, plan, and receipts are aligned.
