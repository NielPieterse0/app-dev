# /tasks

## Purpose

Create or update one numbered task breakdown from the active feature spec and active plan.

`/tasks` is step three of the workflow. It creates or updates:

- `specs/NNN-<slug>/tasks.md`
- `specs/NNN-<slug>/workflow-receipts.md`
- `specs/NNN-<slug>/checklist.md` when the active spec uses gated or sensitive risk

It does not create or update:

- `spec.md`
- `plan.md`
- app `AGENTS.md`

## Working Directory

Run inside `projects/<app>/`.

Do not run this command from the repository root.

## Start Gate

- Confirm the current directory contains app `AGENTS.md`.
- Confirm the active `spec.md` exists.
- Confirm the active `plan.md` exists.
- Confirm the active `plan.md` references the same active spec as app `AGENTS.md`.
- Confirm the active plan is concrete enough to sequence implementation work.

## Required Reads

- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/plan.md`
- `../../templates/spec-workflow/tasks.template.md`
- `../../templates/spec-workflow/workflow-receipts.template.md`
- `../../templates/spec-workflow/checklist.template.md` when gated or sensitive risk applies
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
  - `../../standards/testing.md` and `../../standards/scripting.md` only when they materially affect planning decisions, workflow obligations, or verification scope.


## Required Writes

- Active `specs/NNN-<slug>/tasks.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- Active `specs/NNN-<slug>/checklist.md` when the active spec uses gated or sensitive risk

## Pre-Step Checks

- Confirm the active plan resolves architecture, data, permission, platform, workflow, and verification decisions enough to create executable tasks.
- Confirm whether the app is staying on validator compatibility mode or is intentionally targeting a newer template-validation path.
- Confirm the work can be split into independently verifiable increments where practical.
- Do not require verification evidence completion at this step; `/tasks` initializes later artifacts and task sequencing, while `/verify` closes evidence.

## Execution Steps

### Phase 1: Review The Active Inputs

1. Review the active `spec.md` and `plan.md`.
2. Re-check app `AGENTS.md` only when needed to confirm the active spec pointer or app-specific constraints.
3. Extract:
   - user stories or vertical increments
   - functional requirements and success criteria that drive work ordering
   - affected modules, files, data, permissions, and platforms
   - workflow classification needs: UI, data, mobile, release readiness
   - required verification commands and rendered UI expectations
   - blockers, dependencies, and deferred decisions already recorded in the plan
4. If key sequencing details are missing, make reasonable defaults only when they do not change scope, security posture, workflow classification, or user-visible behavior.
5. Ask for clarification only when the missing point would materially change task order, workflow obligations, destructive-action approval needs, or implementation ownership.
6. Limit unresolved clarifications to at most three critical items.

### Phase 2: Choose The Task Model

1. Use the governed task shape from `../../templates/spec-workflow/tasks.template.md`.
2. Organize tasks in this order:
   - Setup
   - Foundation
   - one phase per independently testable user story or vertical increment
   - Polish and verification
3. Prefer vertical slices that can be implemented and verified independently.
4. Use story or increment titles taken from the active spec and plan rather than ad hoc engineering labels.
5. Assign sequential `T###` task IDs in execution order.
6. Use `[US1]`, `[US2]`, and later labels only for user-story or vertical-increment work.
7. Use `[P]` only for independent files or independent surfaces with no unfinished shared dependency.

### Phase 3: Create The Task Artifacts

1. Create or rewrite `specs/NNN-<slug>/tasks.md` from `../../templates/spec-workflow/tasks.template.md`.
2. Create or refresh `specs/NNN-<slug>/workflow-receipts.md` from `../../templates/spec-workflow/workflow-receipts.template.md`.
3. Create or refresh `specs/NNN-<slug>/checklist.md` from `../../templates/spec-workflow/checklist.template.md` when the active spec uses gated or sensitive risk.
4. Remove all template placeholders that no longer apply.

### Phase 4: Write The Task Sequence

Populate `tasks.md` with concrete content derived from the active spec and active plan.

The task breakdown must include:

- setup tasks that confirm the active artifact set and baseline checks
- foundation tasks for shared prerequisites that block story work
- one phase per independently testable user story or vertical increment
- explicit implementation tasks with exact repo-relative paths
- explicit test tasks with exact repo-relative paths when tests are practical in the repo's existing structure
- explicit receipt-update tasks for each relevant story or increment
- explicit artifact-reconciliation tasks for `spec.md`, `plan.md`, `tasks.md`, and `workflow-receipts.md`
- explicit analysis, artifact validation, receipt validation, and app verification tasks
- explicit rendered desktop and mobile verification tasks when UI work is in scope

### Phase 5: Initialize Workflow Receipts And Gated Checklist

1. Initialize `workflow-receipts.md` from the governed receipt template for the active spec.
2. Set workflow classification in `workflow-receipts.md` based on the active spec and active plan.
3. Mark only the required workflow sections:
   - UI
   - Data
   - Mobile
   - Release readiness
4. Record `/tasks` in `Command path used:` for workflow sections whose classification or outstanding gaps changed during task generation.
5. Record the files, templates, and standards reviewed during task generation.
6. Keep implementation and verification evidence in planned or `not-run` state until later owning phases execute them.
7. Initialize the Applicable Standards Checklist section as draft scaffold evidence only; `/implement` owns dynamic rule selection and status updates.
8. Initialize `checklist.md` from the governed checklist template when the active spec uses gated or sensitive risk.
9. Update checklist readiness items when gated or sensitive work applies so security, approval, and readiness obligations reflect the current spec and plan.

### Phase 6: Run Task Review

Before finishing, review the generated artifacts against this checklist:

- `CHK-01` Does app `AGENTS.md`, active `spec.md`, and active `plan.md` all point to the same active spec?
- `CHK-02` Does `tasks.md` describe one active spec only?
- `CHK-03` Does `tasks.md` contain `## Task List`?
- `CHK-04` Are task IDs strict, sequential, and stable as `T###`?
- `CHK-05` Are setup, foundation, story or increment, and polish or verification phases present where applicable?
- `CHK-06` Does each story or increment have an independent test where practical?
- `CHK-07` Does every material implementation, test, or artifact task name an exact repo-relative path?
- `CHK-08` Is `[P]` used only for truly independent work?
- `CHK-09` Are workflow classification and receipt update tasks present where required?
- `CHK-10` Is `workflow-receipts.md` initialized from the governed template and aligned to the current spec?
- `CHK-11` Is `checklist.md` present and current for gated or sensitive work?
- `CHK-12` Are verification tasks present for `analyze-spec`, `check-spec-artifacts`, `validate-workflow-receipts`, and `verify-app`?
- `CHK-13` Are rendered desktop and mobile verification tasks present when UI work is in scope?
- `CHK-14` Are destructive, credentialed, deployment, migration, or live-environment actions explicit and approval-sensitive?
- `CHK-15` Are all placeholder tokens removed from generated artifacts?

### Phase 7: Run Task Checks

1. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`.
2. Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath .` without `-RequireVerificationEvidence` to validate receipt shape before implementation.
3. If a check fails, update the task artifact set before treating the step as complete.

## Post-Step Checks

- `tasks.md` exists at `specs/NNN-<slug>/tasks.md`.
- `workflow-receipts.md` exists and is initialized from the governed template.
- `checklist.md` exists when gated or sensitive risk applies.
- No unresolved template placeholders remain.

## Receipt Updates

- Record `/tasks` in `Command path used:` for workflow sections whose classification or gaps changed.
- Record the files and standards reviewed during task generation.
- Record implementation and verification evidence as planned or `not-run` only.

## Stop Conditions

- The active plan has unresolved blockers that prevent safe task sequencing.
- App `AGENTS.md` and the active `plan.md` do not reference the same active spec.
- A task would require destructive or live-environment action without explicit approval.
- More than three material clarifications remain unresolved.
- A critical workflow-classification, security, approval, or live-operation decision cannot be safely defaulted.
- Receipt validation fails and cannot be resolved in the artifact set.
- The work cannot be split into executable, independently verifiable increments.

## Completion Report

Report:

- active spec folder
- task file path
- receipt file path
- checklist file path when applicable
- total task count
- phase breakdown
- workflow classification
- whether `workflow-receipts.md` and `checklist.md` were created or refreshed
- checks run and results
- blockers, skipped checks, open questions, or assumptions
- recommended next command

## Next Command

Run `/analyze` after `tasks.md`, `workflow-receipts.md`, and any required `checklist.md` are complete and accepted. Run `/implement` after analysis contradictions are resolved.
