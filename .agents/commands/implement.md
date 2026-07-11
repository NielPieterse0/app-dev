# /implement

## Purpose

Execute the active implementation tasks for one numbered feature specification while keeping execution evidence current.

`/implement` is the implementation phase of the workflow. It executes the active `tasks.md`, updates application files, resolves applicable standard rules from the registry layer, records implementation evidence in `specs/NNN-<slug>/workflow-receipts.md`, and reconciles code, docs, standards, registries, and workflow artifacts before `/converge`.

It does not create or initialize:

- `spec.md`
- `plan.md`
- `tasks.md`
- `workflow-receipts.md`
- `checklist.md`
- app `AGENTS.md`

## User Input

Treat non-empty user arguments as execution constraints for this run.

User arguments can narrow order, scope, or reporting detail, but they cannot override the active spec, safety gates, initialized artifact requirements, applicable registry rules, required receipt updates, or approval requirements.

## Working Directory

Run inside `projects/<app>/`.

Do not run this command from the repository root.

## Start Gate

- Confirm the current directory contains app `AGENTS.md`.
- Confirm app `AGENTS.md` points to the intended active spec.
- Confirm active `specs/NNN-<slug>/spec.md`, `plan.md`, `tasks.md`, and `workflow-receipts.md` exist.
- Confirm gated `checklist.md` exists when required by the active spec risk level.
- Confirm the active task list is concrete enough to execute without inventing missing scope.

## Required Reads

- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/plan.md`
- Active `specs/NNN-<slug>/tasks.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- Active `specs/NNN-<slug>/checklist.md` when required by the active spec risk level
- Relevant `../../standards/registry/*.rules.json` files selected by touched surfaces, `tasks.md`, planned files, changed files, workflow classification, and active phase
- `../../scripts/get-applicable-standard-rules.ps1`
- Revalidate only when the current session context is no longer reliable:
  - Root `../../AGENTS.md`
  - App `AGENTS.md`
  - `../../standards/spec-driven-workflow.md`
  - `../../standards/command-workflow-contract.md`
  - `../../standards/constitution.md`
  - `../../standards/workspace.md`
  - `../../standards/codex-capabilities.md`
- Read prose standards only when a selected registry rule is unclear, a rule references a section that needs interpretation, implementation changes the standard or registry itself, or a registry is missing or malformed
- Read the required local workflow skill instructions only when the active receipt classification requires them:
  - UI workflow
  - data workflow
  - mobile workflow
  - release-readiness workflow

## Required Writes

- Application source, tests, configuration, and docs named by the active `tasks.md`
- Active `specs/NNN-<slug>/tasks.md` task status updates
- Active `specs/NNN-<slug>/workflow-receipts.md` implementation evidence, Applicable Standards Checklist updates, and outstanding-gap updates
- Active `specs/NNN-<slug>/checklist.md` gated readiness updates when applicable
- Active `specs/NNN-<slug>/plan.md` or `spec.md` only when implementation exposes real artifact drift that must be reconciled before verification
- Touched standards, matching registries, validators, templates, skills, or command docs when the implementation changes those governed surfaces

## Pre-Step Checks

- Confirm `tasks.md`, `workflow-receipts.md`, and any required `checklist.md` were initialized by `/tasks`, not backfilled here.
- Confirm executable tasks use clear `T###` task IDs and remain aligned to the active spec and active plan.
- Confirm workflow classification is already set in `workflow-receipts.md`.
- Confirm any required pre-implementation analysis contradictions were resolved before starting material code changes.
- Confirm required local workflow wrappers are identified before touching the affected surfaces.
- Confirm no task requires unapproved destructive, credentialed, or live-environment action.
- Confirm validator mode remains `compatibility` for established apps unless this slice explicitly includes a template-refresh migration.

## Execution Steps

### Phase 1: Read The Active Artifacts

1. Read the active `spec.md`, `plan.md`, `tasks.md`, and `workflow-receipts.md`.
2. Extract:
   - task dependency order
   - user stories or vertical increments
   - touched modules and files
   - workflow obligations
   - focused verification needs
   - blockers or deferred items
   - tech stack
   - architecture decisions
   - file structure
   - test requirements
   - workflow classifications
   - focused checks
3. Identify any implementation decisions the active plan already fixed.
4. Identify any artifact drift that must be reconciled before code changes continue.

### Phase 2: Prepare The Implementation Sequence

1. Order tasks by dependency.
2. Complete setup and foundation work before story or vertical-increment work.
3. Complete each phase before proceeding to the next.
4. Keep same-file or shared-surface work sequential.
5. Use `[P]` only for truly independent work with no unfinished shared dependency.
6. Keep the sequence scoped to the active spec only.
7. Stop to reconcile blocking artifact drift before continuing implementation.

### Phase 3: Resolve Applicable Standard Rules

1. Derive touched surfaces from `tasks.md`, planned files in `plan.md`, active workflow classification, existing changed files, and files changed during implementation.
2. Read the relevant `../../standards/registry/*.rules.json` files before reading long prose standards.
3. Run `../../scripts/get-applicable-standard-rules.ps1` with the active spec path, changed files, and phase `implement`.
4. Match candidate rules by `applies_to`, `trigger_kinds`, and `phases`.
5. Build or refresh the Applicable Standards Checklist in `workflow-receipts.md`.
6. Include generated rule id, standard reference, severity, enforcement mode, status, evidence, and reason or next action.
7. Mark each applicable rule as `applied`, `not-applicable`, `deferred`, or `blocked`.
8. Require every critical or high applicable rule to have a status before execution continues beyond the task that triggered it.

### Phase 4: Execute The Work

1. Implement tasks in dependency order.
2. Update the concrete source, tests, configuration, and docs required by the task list.
3. Mark completed tasks in `tasks.md` from `[ ]` to `[x]`.
4. Leave deferred tasks unchecked and record the exact reason in the task or handoff notes.
5. If a non-deferred blocking task fails, stop and record the blocker before continuing.
6. For independent parallel tasks, keep successful work, record failed work, and reconcile the remaining task sequence before continuing.
7. Keep behavior, ownership boundaries, and touched surfaces aligned to the active spec and active plan.

### Phase 5: Keep Execution Evidence Current

1. Update `workflow-receipts.md` as implementation changes files, modules, scripts, UI surfaces, or platform behavior.
2. Record the required local workflow wrappers actually used for this slice.
3. Update gated `checklist.md` only when gated readiness state materially changes.
4. Update `plan.md` or `spec.md` only when documented intent and implemented reality would otherwise diverge.
5. When active `checklist.md` exists, summarize total items, completed items, incomplete items, blocking status, and whether explicit approval is required before material implementation continues.
6. After each completed, deferred, or blocked `T###`, report:
   - task id and status
   - files or surfaces touched
   - selected generated rule ids updated
   - checks run and results
   - receipt sections updated
   - next task or blocker

### Phase 6: Apply Applicable Standards Checklist

#### Registry-Selected Rules

- Use the generated Applicable Standards Checklist as the source of required implementation checks.
- Generate or refresh the checklist from `../../standards/registry/*.rules.json` using the active `spec.md`, `plan.md`, `tasks.md`, changed files, and current implementation phase.
- Do not maintain fixed rule-id lists in this command. Concrete rule ids belong in generated receipt evidence.
- Record every generated critical or high applicable rule as `applied`, `not-applicable`, `deferred`, or `blocked`.
- For `deferred` or `blocked`, record the reason and the next command, task, validation, or user approval needed.

#### Workflow-Specific Requirements

- Apply the required local workflow wrappers and receipt obligations for the active slice classification.
- Satisfy all implementation-time requirements for any required UI, data, mobile, or release-readiness workflow.
- Keep `workflow-receipts.md` current for each required workflow section as implementation progresses.
- Record workflow-specific evidence, constraints, gaps, and deferred items before handoff to `/converge`.

### Phase 7: Run Focused Implementation Checks

1. Run focused checks as each slice becomes testable.
2. Add or update tests for behavior changes when the project test structure supports them.
3. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before handoff.
4. Use `-ValidationMode current-template` only for newly generated or explicitly refreshed apps.
5. If a check is skipped, record the exact reason in `workflow-receipts.md`.
6. If a focused check fails, fix the implementation or reconcile the affected artifacts before treating the step as complete.
7. If an applicable rule uses `validator-required` enforcement, record the validation result or the explicit blocker before continuing.

### Phase 8: Reconcile Documentation, Registries, And Artifacts

1. Update task-owned documentation as implementation completes.
2. Reconcile `spec.md`, `plan.md`, `tasks.md`, `workflow-receipts.md`, and any touched operational or user-facing docs to the implemented state.
3. Reconcile affected repo-wide docs when the slice touches governed surfaces such as `AGENTS.md`, `README.md`, `.agents/commands/`, `.agents/skills/`, `standards/`, `standards/registry/`, `templates/`, or `scripts/`.
4. If implementation changes a prose standard, update or explicitly reconcile the matching registry in the same slice.
5. If implementation changes a registry requirement, reconcile the matching prose standard when the normative requirement changed.
6. Record deviations, deferred documentation work, and exact blockers when reconciliation cannot be completed.
7. Finish `/implement` only after code and documentation describe the same implemented reality.

### Phase 9: Run Implementation Review

Before finishing, validate the implementation against:

- active `spec.md`
- active `plan.md`
- selected registry rules
- focused checks and tests
- current `workflow-receipts.md`
- active `checklist.md` when present

Review the implementation against this checklist:

- `CHK-01` Does the work stay within the active spec scope?
- `CHK-02` Do touched files and modules match the active plan decisions?
- `CHK-03` Are completed tasks marked complete and deferred tasks left explicit?
- `CHK-04` Is `workflow-receipts.md` current for the required workflow sections?
- `CHK-05` Is the Applicable Standards Checklist current for the generated applicable rules?
- `CHK-06` Were required local workflow wrappers followed for the touched surfaces?
- `CHK-07` Were applicable registry-selected scripting, testing, security, workflow, and governance rules applied or explicitly deferred?
- `CHK-08` Are behavior changes covered by tests where the project structure supports them?
- `CHK-09` Are focused checks and their results recorded clearly?
- `CHK-10` Do `spec.md`, `plan.md`, `tasks.md`, and implementation still agree?
- `CHK-11` Are blockers, assumptions, and deferred items explicit?
- `CHK-12` Does the work avoid unapproved destructive, credentialed, or live-environment actions?
- `CHK-13` Are no missing or placeholder implementation-evidence fields left in touched receipt sections?
- `CHK-14` Does the slice remain ready for `/converge` without needing missing artifact initialization?

## Post-Step Checks

- Completed tasks correspond to real changes or explicit no-op findings.
- `workflow-receipts.md` lists implementation evidence for required workflow sections.
- `workflow-receipts.md` includes an Applicable Standards Checklist with current generated rule coverage.
- `spec.md` and `plan.md` still match implemented decisions.
- Focused implementation checks passed before handoff or the exact blocker is recorded.

## Receipt Updates

- Record `/implement` in `Command path used:` for sections updated during implementation.
- Record implementation evidence as concrete files, modules, migrations, UI surfaces, scripts, or platform changes.
- Record the registry files reviewed and the selection basis used for the Applicable Standards Checklist.
- Record focused checks already run and any gaps intentionally left for `/converge` or `/verify`.

Applicable standards checklist:
- [x] `<generated-rule-id> / <registry-reference>` - `<registry title>` - applied: `<evidence>`
- [ ] `<generated-rule-id> / <registry-reference>` - `<registry title>` - not-applicable: `<reason>`
- [ ] `<generated-rule-id> / <registry-reference>` - `<registry title>` - deferred: `<next action>`

## Stop Conditions

- Required artifacts are missing or stale.
- A gated checklist has incomplete blocking items and no explicit approval to proceed.
- A task requires network, credentialed, destructive, or live-environment action without approval.
- Any applicable `critical` rule is `blocked` and the task cannot proceed safely.
- A registry file is missing or malformed for a touched governed surface.
- Implementation changes a prose standard but does not update or explicitly reconcile the matching registry.
- Implementation changes a registry but does not reconcile the matching prose standard when the normative requirement changes.
- A registry rule marked `validator-required` is applicable but no validation result or explicit blocker is recorded.
- Focused checks reveal a defect that changes the active spec or active plan.
- More than three material implementation blockers remain unresolved.

## Completion Report

Report:

- active spec folder
- tasks completed
- tasks deferred
- files or surfaces changed
- workflow sections updated
- Applicable Standards Checklist status
- focused checks run and results
- blockers, assumptions, or deviations
- recommended next command

## Next Command

Run `/converge` after implementation tasks are complete or intentionally deferred and execution artifacts are reconciled.
