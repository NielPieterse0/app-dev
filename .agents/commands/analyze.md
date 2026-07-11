# /analyze

## Purpose

Analyze the active numbered feature specification package before material implementation starts.

`/analyze` is step four of the workflow. It validates cross-artifact consistency, requirement-to-task coverage, workflow classification, gated-readiness state, and implementation-rule readiness before `/implement`.

It analyzes the active:

- `spec.md`
- `plan.md`
- `tasks.md`
- `workflow-receipts.md`
- `checklist.md` when required by risk level
- relevant `../../standards/registry/*.rules.json` files

It does not create or initialize:

- `spec.md`
- `plan.md`
- `tasks.md`
- `workflow-receipts.md`
- `checklist.md`
- app `AGENTS.md`

It does not execute implementation tasks, mark implementation evidence complete, or claim verification closure.

## User Input

Treat non-empty user arguments as analysis constraints for this run.

User arguments can narrow focus, reporting depth, or finding categories, but they cannot override the active spec, required artifacts, safety gates, registry-rule visibility, contradiction handling, or approval requirements.

## Working Directory

Run inside `projects/<app>/`.

Do not run this command from the repository root.

## Start Gate

- Confirm the current directory contains app `AGENTS.md`.
- Confirm app `AGENTS.md` points to the intended active spec.
- Confirm active `specs/NNN-<slug>/spec.md`, `plan.md`, `tasks.md`, and `workflow-receipts.md` exist.
- Confirm gated `checklist.md` exists when required by the active spec risk level.
- Confirm `/tasks` initialized the active task and receipt artifacts.
- Confirm the active task list is concrete enough to analyze without inventing missing scope.

## Required Reads

- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/plan.md`
- Active `specs/NNN-<slug>/tasks.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- Active `specs/NNN-<slug>/checklist.md` when required by the active spec risk level
- Relevant `../../standards/registry/*.rules.json` files selected by active spec content, plan decisions, task paths, workflow classification, and analysis phase
- `../../scripts/analyze-spec.ps1`
- `../../scripts/get-applicable-standard-rules.ps1`
- Revalidate only when the current session context is no longer reliable:
  - Root `../../AGENTS.md`
  - App `AGENTS.md`
  - `../../standards/spec-driven-workflow.md`
  - `../../standards/command-workflow-contract.md`
  - `../../standards/constitution.md`
  - `../../standards/workspace.md`
  - `../../standards/codex-capabilities.md`
- Read prose standards only when a selected registry rule is unclear, a rule references a section that needs interpretation, analysis changes the standard or registry itself, or a registry is missing or malformed

## Required Writes

None by default.

`/analyze` is read-only unless the user explicitly asks to remediate findings.

When remediation is explicitly requested, update only the owning artifact:

- active `spec.md` when feature intent, requirement, success criteria, risk, or scope is wrong
- active `plan.md` when architecture, verification, workflow, or decision state is wrong
- active `tasks.md` when implementation coverage, sequencing, task state, or path references are wrong
- active `workflow-receipts.md` when workflow classification, outstanding gaps, analysis outcome, or implementation blockers are wrong
- active `checklist.md` when gated readiness state is wrong

Do not record implementation evidence from `/analyze`.

## Pre-Step Checks

- Confirm `tasks.md`, `workflow-receipts.md`, and any required `checklist.md` were initialized by `/tasks`, not backfilled here.
- Confirm app `AGENTS.md`, active `spec.md`, and active `plan.md` reference the same active spec.
- Confirm executable tasks use clear `T###` task IDs and remain aligned to the active spec and active plan.
- Confirm workflow classification is already set in `workflow-receipts.md`.
- Confirm validator mode remains `compatibility` for established apps unless this slice explicitly includes a template-refresh migration.
- Confirm no analysis finding will be silently resolved without user approval when the run is read-only.

## Execution Steps

### Phase 1: Read The Active Artifacts

1. Read the active `spec.md`, `plan.md`, `tasks.md`, and `workflow-receipts.md`.
2. Read active `checklist.md` when required by risk level.
3. Extract:
   - active spec path
   - artifact status values
   - risk level
   - user stories or vertical increments
   - functional requirements
   - success criteria
   - architecture decisions
   - data, auth, permission, storage, and platform decisions
   - workflow classifications
   - task IDs, phases, `[P]` markers, and referenced paths
   - outstanding gaps
   - deferred decisions
   - planned verification commands
   - required local workflow wrappers
4. Identify any artifact drift that blocks implementation.

### Phase 2: Run The Governed Analysis Script

1. Run `../../scripts/analyze-spec.ps1 -ProjectPath .`.
2. Treat script failures as blocking findings unless the failure is clearly environmental.
3. Report every failure with the owning artifact and recommended owner command.
4. Resolve no contradiction automatically in read-only mode.

The script result must cover at least:

- active spec pointer mismatch
- status mismatch between spec and plan
- missing required artifacts
- gated spec missing `checklist.md`
- completed removal tasks whose targets still exist
- completed receipt sections with missing verification evidence
- unresolved `NEEDS CLARIFICATION` markers in completed artifacts
- no-auth or anonymous-access wording without the required guardrail

### Phase 3: Build Analysis Models

Build internal models. Do not dump raw artifact content into the report.

1. Build a requirements inventory from `FR-###` entries and any unnumbered functional requirements.
2. Build a success-criteria inventory from `SC-###` entries.
3. Mark success criteria as buildable only when they require implementation, infrastructure, test harness, migration, verification, or measurable product behavior.
4. Build a story or vertical-increment inventory from the spec and plan.
5. Build a task inventory from `T###`, phase, story label, path references, and `[P]` markers.
6. Build a workflow-obligation inventory from `workflow-receipts.md`.
7. Build a gated-readiness inventory from `checklist.md` when present.
8. Build a registry-signal inventory from task paths, planned files, active workflow classification, and artifact text.

### Phase 4: Preflight Applicable Standard Rules

1. Derive candidate touched surfaces from `tasks.md`, planned files in `plan.md`, workflow classification, and artifact text.
2. Read relevant `../../standards/registry/*.rules.json` files before reading long prose standards.
3. Run `../../scripts/get-applicable-standard-rules.ps1` with the active spec path and phase `analyze` when registry rules include analysis-phase coverage.
4. Also inspect likely implementation-phase rules that `/implement` will later enforce, without marking them applied.
5. Match candidate rules by `applies_to`, `trigger_kinds`, and `phases`.
6. Report registry files reviewed and candidate critical or high rules likely to affect `/implement`.
7. Do not populate implementation evidence.
8. If an applicable registry is missing, malformed, or inconsistent with its prose standard, report a `CRITICAL` governance finding.

Registry preflight must include these families when triggered:

- `../../standards/registry/constitution.rules.json`
- `../../standards/registry/spec-driven-workflow.rules.json`
- `../../standards/registry/command-workflow-contract.rules.json`
- `../../standards/registry/workspace.rules.json`
- `../../standards/registry/stack.rules.json`
- `../../standards/registry/security.rules.json`
- `../../standards/registry/testing.rules.json`
- `../../standards/registry/scripting.rules.json`
- `../../standards/registry/module-contract.rules.json`
- `../../standards/registry/codex-capabilities.rules.json`
- `../../standards/registry/adaptive-layouts.rules.json`

### Phase 5: Run Detection Passes

Limit the output to the highest-signal findings. Summarize overflow by category.

Run these passes:

- Requirements coverage: every functional requirement has at least one implementation, test, or artifact task when buildable.
- Success-criteria coverage: every buildable success criterion has an implementation or verification route.
- Story coverage: every user story or vertical increment maps to executable tasks.
- Task mapping: every task maps to a requirement, story, plan decision, workflow obligation, or verification need.
- Ordering: setup and foundation tasks precede dependent story work.
- Parallel safety: `[P]` appears only on truly independent tasks.
- Path validity: task path references are concrete enough for implementation.
- Workflow alignment: plan, tasks, and receipts agree on UI, data, mobile, and release-readiness obligations.
- Registry readiness: likely critical or high registry rules are visible before `/implement`.
- Gated readiness: gated or sensitive work has checklist, security, data, rollback, and approval notes.
- Constitution alignment: active artifacts do not conflict with `../../standards/constitution.md` or its registry rules.
- Ambiguity: vague quality claims have measurable criteria or planned verification.
- Duplication: duplicate requirements, success criteria, or tasks are identified for consolidation.
- Contradiction: spec, plan, tasks, receipts, and checklist do not disagree on scope, status, stack, data, risk, or verification.
- Placeholder drift: active artifacts contain no unresolved template markers, `TODO`, `TBD`, `???`, or `NEEDS CLARIFICATION` in completed sections.
- Evidence drift: receipts do not claim completed implementation or verification evidence before the owning phase has produced it.

### Phase 6: Assign Severity

Use deterministic severity.

- `CRITICAL`: missing required artifact; active spec mismatch; constitution MUST violation; malformed required registry; gated spec missing checklist; zero coverage for baseline functionality; receipt closure claims absent verification evidence.
- `HIGH`: conflicting requirements; conflicting stack, architecture, data, auth, or permission decisions; ambiguous security or performance requirement; critical or high registry rule likely to block `/implement` and not visible in receipts.
- `MEDIUM`: missing non-functional task coverage; workflow classification drift; task ordering defect; stale task state; important terminology drift.
- `LOW`: wording cleanup, minor redundancy, non-blocking clarity issue, or style-only artifact improvement.

### Phase 7: Produce Analysis Report

Output a Markdown report.

Use this format:

```md
## Specification Analysis Report

Active spec: `specs/NNN-<slug>/`
Analysis script: `../../scripts/analyze-spec.ps1 -ProjectPath .`
Registry preflight: `../../scripts/get-applicable-standard-rules.ps1 -ProjectPath . -SpecDir specs/NNN-<slug> -Phase analyze`
Result: PASS | FAIL | PASS_WITH_WARNINGS

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|

## Coverage Summary

| Requirement Key | Has Task? | Task IDs | Notes |
|-----------------|-----------|----------|-------|

## Buildable Success Criteria

| Success Criterion | Has Implementation Or Verification Route? | Task IDs | Notes |
|-------------------|--------------------------------------------|----------|-------|

## Workflow Alignment

| Workflow Area | Required? | Source | Receipt State | Task Coverage | Notes |
|---------------|-----------|--------|---------------|---------------|-------|

## Registry Preflight

| Registry | Candidate Rule IDs | Highest Severity | Reason Selected | Implementation Impact |
|----------|--------------------|------------------|-----------------|-----------------------|

## Gated Readiness

State `Not applicable.` for standard risk work.

## Unmapped Tasks

State `None.` when clean.

## Metrics

- Total requirements:
- Total buildable success criteria:
- Total tasks:
- Requirement coverage:
- Buildable success-criteria coverage:
- Unmapped tasks:
- Candidate critical or high registry rules:
- Ambiguity count:
- Duplication count:
- Critical issue count:

## Next Actions

- Resolve CRITICAL and HIGH findings before `/implement`.
- Resolve or explicitly defer MEDIUM findings before `/verify`.
- LOW findings may be deferred when they do not affect implementation safety.
```

### Phase 8: Receipt Handling

1. Do not write receipts during read-only analysis.
2. If the user explicitly asks for remediation, record `/analyze` in `Command path used:` only for receipt sections whose classification, gap state, blocker state, or analysis outcome changed.
3. Record analysis blockers as blockers, not implementation evidence.
4. Do not add Applicable Standards Checklist entries as applied from `/analyze`.
5. If registry preflight identifies likely critical or high implementation rules, record them as pending only when remediation is explicitly requested.

### Phase 9: Run Analysis Review

Before finishing, review the analysis against this checklist:

- `CHK-01` Does the analysis stay within the active spec scope?
- `CHK-02` Do app `AGENTS.md`, active `spec.md`, and active `plan.md` point to the same active spec?
- `CHK-03` Are required artifacts present and initialized by the correct earlier phase?
- `CHK-04` Did `analyze-spec.ps1` run or fail with an exact blocker?
- `CHK-05` Were relevant registry files reviewed or explicitly reported as not selected?
- `CHK-06` Are candidate critical and high registry rules visible before `/implement`?
- `CHK-07` Are requirements and buildable success criteria mapped to tasks?
- `CHK-08` Are unmapped tasks identified?
- `CHK-09` Are workflow obligations aligned across plan, tasks, and receipts?
- `CHK-10` Is gated readiness checked when gated or sensitive risk applies?
- `CHK-11` Are contradictions, ambiguity, duplication, and underspecification reported with concrete locations?
- `CHK-12` Does the report avoid claiming implementation or verification completion?
- `CHK-13` Are next actions assigned to the correct owning artifact or command?

## Post-Step Checks

- `analyze-spec.ps1` result is reported.
- Registry files reviewed are reported.
- Candidate critical or high registry rules are visible before `/implement`.
- Requirement and success-criteria coverage is reported.
- Workflow alignment is reported.
- Gated readiness is reported when applicable.
- No implementation evidence or verification closure is claimed.

## Receipt Updates

Default: none.

When remediation is explicitly requested:

- Record `/analyze` in `Command path used:` for receipt sections whose blocker or classification state changed.
- Record contradiction findings as analysis blockers.
- Record registry preflight results as pending implementation-rule visibility, not as applied implementation evidence.
- Leave final Applicable Standards Checklist status ownership to `/implement`.

## Stop Conditions

- Required artifacts are missing or stale.
- App `AGENTS.md`, active `spec.md`, and active `plan.md` reference different active specs.
- A gated checklist is required but missing.
- `analyze-spec.ps1` reports contradictions that block implementation.
- A required registry file for a touched governed surface is missing or malformed.
- Candidate critical registry rules indicate implementation cannot proceed without a plan or task update.
- More than three material analysis blockers remain unresolved.
- The user requests implementation before analysis blockers are resolved or explicitly accepted.

## Completion Report

Report:

- active spec folder
- artifacts analyzed
- analysis script result
- registry files reviewed
- candidate critical or high registry rules
- finding counts by severity
- requirement coverage
- buildable success-criteria coverage
- workflow alignment status
- gated readiness status when applicable
- blockers, assumptions, or deferred analysis issues
- recommended next command

## Next Command

Run `/implement` after CRITICAL and HIGH findings are resolved or explicitly accepted as implementation blockers.
