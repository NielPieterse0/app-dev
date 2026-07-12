# /converge

## Purpose

Analyze the implemented codebase against the active numbered feature specification package after material implementation work has run, then determine whether any specified work remains incomplete.

`/converge` is the post-implementation completion gate between `/implement` and `/verify`. It reviews and updates the analysis models already developed by `/analyze`, refreshes them against the live post-implementation codebase, task state, and plan decisions, and decides whether the feature is converged or must return to `/implement`.

It assesses the active:

- `spec.md`
- `plan.md`
- `tasks.md`
- `workflow-receipts.md`
- implemented files referenced by the active plan and active tasks
- relevant `../../standards/registry/*.rules.json` files selected by the implemented surfaces, active artifacts, and convergence phase

It appends new remaining-work tasks to `tasks.md` only when real implementation gaps still exist.

It does not create or initialize:

- `spec.md`
- `plan.md`
- `tasks.md`
- `workflow-receipts.md`
- `checklist.md`
- app `AGENTS.md`

It does not update application code, generate implementation evidence, or claim verification closure.

## User Input

Treat non-empty user arguments as convergence constraints for this run.

User arguments can narrow assessment focus, reporting depth, or finding categories, but they cannot override the active spec, required artifacts, append-only task handling, dynamic registry review, contradiction handling, or approval requirements.

## Working Directory

Run inside `projects/<app>/`.

Do not run this command from the repository root.

## Start Gate

- Confirm the current directory contains app `AGENTS.md`.
- Confirm app `AGENTS.md` points to the intended active spec.
- Confirm active `specs/NNN-<slug>/spec.md`, `plan.md`, `tasks.md`, and `workflow-receipts.md` exist.
- Confirm `/implement` has already run on the current `tasks.md`.
- Confirm the implementation surface is developed enough for a real convergence pass, or explicitly treat missing implementation as remaining work.
- Confirm this run is assessing present implementation state rather than git history or branch comparisons.

## Required Reads

- Active `specs/NNN-<slug>/spec.md`
- Active `specs/NNN-<slug>/plan.md`
- Active `specs/NNN-<slug>/tasks.md`
- Active `specs/NNN-<slug>/workflow-receipts.md`
- Active `specs/NNN-<slug>/checklist.md` when required by the active spec risk level
- Relevant implementation files selected by the active plan, active tasks, and refreshed analysis models
- Relevant `../../standards/registry/*.rules.json` files selected by implemented files, plan paths, task paths, workflow classification, and convergence phase
- `../../scripts/get-applicable-standard-rules.ps1`
- Revalidate only when the current session context is no longer reliable:
  - Root `../../AGENTS.md`
  - App `AGENTS.md`
  - `../../standards/spec-driven-workflow.md`
  - `../../standards/command-workflow-contract.md`
  - `../../standards/constitution.md`
  - `../../standards/workspace.md`
  - `../../standards/codex-capabilities.md`
- Read prose standards only when a selected registry rule is unclear, a rule references a section that needs interpretation, convergence changes the standard or registry itself, or a registry is missing or malformed

## Required Writes

Append-only to active `specs/NNN-<slug>/tasks.md` when actionable findings exist.

`/converge` may:

- append one new `## Phase N: Convergence` section to active `tasks.md`
- append one new checklist row per actionable finding
- add a convergence note from `../../templates/spec-workflow/converge.template.md` only when a separate handoff record is explicitly needed

`/converge` must not:

- rewrite or renumber prior tasks
- reorder existing tasks
- edit `spec.md`
- edit `plan.md`
- update application code
- record implementation evidence as new receipt evidence
- record verification closure
- create an empty convergence phase when no remaining work exists

When convergence is clean, `tasks.md` must remain byte-for-byte unchanged.

## Pre-Step Checks

- Confirm active `spec.md`, active `plan.md`, and app `AGENTS.md` reference the same active spec.
- Confirm `tasks.md` was created by `/tasks` and materially exercised by `/implement`, rather than improvised here.
- Confirm `/analyze` already established the baseline requirements, success-criteria, story, task, and workflow models used for convergence.
- Confirm workflow classification already exists in `workflow-receipts.md`.
- Confirm no finding will be silently resolved here; unresolved gaps must produce appended tasks or an explicit clean convergence result.
- Confirm dynamic registry review will stay observational and will not mark Applicable Standards Checklist rows applied.

## Execution Steps

### Phase 1: Read The Active Convergence Context

1. Read the active `spec.md`, `plan.md`, `tasks.md`, and `workflow-receipts.md`.
2. Read active `checklist.md` when required by risk level.
3. Extract:
   - active spec path
   - feature goal
   - user stories or vertical increments
   - functional requirements
   - success criteria
   - acceptance scenarios
   - architecture, data, auth, permission, storage, and platform decisions
   - task IDs, phases, status values, and path references
   - workflow classification
   - Applicable Standards Checklist state
   - outstanding gaps, blockers, and deferred items
4. Identify artifact drift that would make convergence results misleading.

### Phase 2: Refresh The Implemented Scope

1. Resolve the implemented files named by the active plan and active tasks.
2. Expand that scope only when the implementation clearly introduced adjacent files or modules needed to judge requirement completion.
3. Bound the convergence pass to the active spec package and the real implementation surfaces it governs.
4. Do not infer unrelated product scope or use git history as a substitute for present-state inspection.

### Phase 3: Review And Refresh Analysis Models

Build internal models. Do not dump raw artifact content into the report.

1. Reuse the requirements inventory already expected from `/analyze`.
2. Reuse the buildable success-criteria inventory already expected from `/analyze`.
3. Reuse the story or vertical-increment inventory already expected from `/analyze`.
4. Reuse the task inventory already expected from `/analyze`.
5. Reuse the workflow-obligation inventory already expected from `/analyze`.
6. Refresh those models against:
   - implemented code
   - post-implement task state
   - plan decisions that materially affected implementation
   - receipt blockers or outstanding gaps discovered during implementation
7. Extend the models only when implementation exposed a real gap that the earlier analysis could not have seen.
8. Build a convergence-gap inventory from missing, partial, contradicting, or unrequested implementation findings.

### Phase 4: Review Applicable Standard Rules

1. Derive candidate touched surfaces from implemented files, plan paths, task paths, workflow classification, and active artifact text.
2. Read relevant `../../standards/registry/*.rules.json` files before reading long prose standards.
3. Run `../../scripts/get-applicable-standard-rules.ps1` with the active spec path, changed files when available, and phase `converge`.
4. Also inspect adjacent `implement` and `verify` rule families only when they materially affect convergence handoff or blocker interpretation.
5. Match candidate rules by `applies_to`, `trigger_kinds`, and `phases`.
6. Report registry files reviewed and candidate critical or high rules whose unresolved state means the implementation is not actually converged.
7. Do not mark rules applied and do not populate verification evidence.
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
- `../../standards/registry/module-contract.rules.json`
- `../../standards/registry/codex-capabilities.rules.json`
- `../../standards/registry/adaptive-layouts.rules.json`

### Phase 5: Run Detection Passes

Limit the output to the highest-signal findings. Summarize overflow by category.

Run these passes:

- Requirements satisfaction: every functional requirement is fully implemented or has a concrete remaining gap.
- Success-criteria satisfaction: every buildable success criterion is satisfied by the implemented state or has a concrete remaining gap.
- Story and acceptance coverage: every user story or acceptance path is satisfied or has a concrete remaining gap.
- Plan-decision alignment: implementation matches architecture, module, data, auth, permission, storage, and platform decisions.
- Task truthfulness: tasks marked complete correspond to implemented reality.
- Workflow alignment: implementation, tasks, and receipts still agree on UI, data, mobile, and release-readiness obligations.
- Registry alignment: unresolved critical or high rule pressure is visible before `/verify`.
- Contradiction detection: implemented behavior does not conflict with the active spec, plan, tasks, or governed standards.
- Unrequested work detection: extra work not called for by the active artifacts is surfaced when it materially changes scope, behavior, or maintenance burden.
- Placeholder drift: completion-facing artifacts contain no unresolved `TODO`, `TBD`, `???`, or `NEEDS CLARIFICATION` markers in completed sections.

### Phase 6: Assign Severity

Use deterministic severity.

- `CRITICAL`: constitution MUST violation; malformed required registry; implemented behavior contradicts a baseline requirement; zero support for baseline functionality of a core story; task state or receipts claim completion where implementation clearly does not exist.
- `HIGH`: missing or partial implementation on a core functional requirement, acceptance scenario, or plan decision; unresolved critical or high registry blocker that prevents true convergence.
- `MEDIUM`: partial implementation on secondary behavior; stale task state; workflow-obligation drift; important unrequested work with unclear justification.
- `LOW`: wording cleanup, minor non-blocking drift, low-risk unrequested work, or style-only artifact improvement.

### Phase 7: Produce Convergence Report

Output a Markdown report.

Use this format:

```md
## Specification Convergence Report

Active spec: `specs/NNN-<slug>/`
Registry review: `../../scripts/get-applicable-standard-rules.ps1 -ProjectPath . -SpecDir specs/NNN-<slug> -Phase converge`
Result: CONVERGED | TASKS_APPENDED | BLOCKED

| ID | Gap Type | Severity | Source | Evidence | Remaining Work |
|----|----------|----------|--------|----------|----------------|

## Scope Reviewed

| Area | Source | In Scope? | Notes |
|------|--------|-----------|-------|

## Requirement Satisfaction

| Requirement Key | Satisfied? | Evidence | Remaining Work |
|-----------------|------------|----------|----------------|

## Buildable Success Criteria

| Success Criterion | Satisfied? | Evidence | Remaining Work |
|-------------------|------------|----------|----------------|

## Workflow Alignment

| Workflow Area | Required? | Receipt State | Converged? | Notes |
|---------------|-----------|---------------|------------|-------|

## Registry Review

| Registry | Candidate Rule IDs | Highest Severity | Reason Selected | Convergence Impact |
|----------|--------------------|------------------|-----------------|--------------------|

## Unrequested Work

State `None.` when clean.

## Metrics

- Total requirements checked:
- Total buildable success criteria checked:
- Total stories or acceptance paths checked:
- Total tasks reviewed:
- Actionable findings:
- Findings by gap type:
- Findings by severity:
- Candidate critical or high registry rules:
- Critical issue count:

## Next Actions

- Append remaining work to `tasks.md` when actionable findings exist.
- Return to `/implement` after convergence tasks are appended.
- Proceed to `/verify` only when no actionable findings remain.
```

### Phase 8: Append Convergence Tasks

Append only when there are actionable findings.

1. Scan all existing task IDs and find the maximum numeric task ID.
2. Find the highest existing phase number and increment it by one.
3. Append exactly one new section header:
   - `## Phase N: Convergence`
4. Append one checklist row per actionable finding, ordered by severity:
   - `CRITICAL`
   - `HIGH`
   - `MEDIUM`
   - `LOW`
5. Assign new zero-padded task IDs without reusing existing IDs.
6. Use this format:

```md
- [ ] T042 <imperative description> per <source-ref> (<gap-type>)
```

Rules for appended tasks:

- Constitution-violation tasks appear first and are described as `CRITICAL`.
- Each appended task traces clearly to its origin, such as `FR-003`, `SC-002`, `US1/AC2`, `plan: storage decision`, or `standard: SDW-021`.
- Do not modify prior phases.
- Do not merge the new convergence tasks into earlier convergence phases.
- If no actionable findings exist, do not write anything.

### Phase 9: Run Convergence Review

Before finishing, review the convergence pass against this checklist:

- `CHK-01` Do app `AGENTS.md`, active `spec.md`, and active `plan.md` point to the same active spec?
- `CHK-02` Are required artifacts present and owned by the correct earlier workflow phases?
- `CHK-03` Does the convergence pass explicitly build on `/analyze` models instead of recreating intent from scratch?
- `CHK-04` Were requirements, buildable success criteria, stories, task state, and plan decisions all refreshed against implemented reality?
- `CHK-05` Were relevant registry files reviewed or explicitly reported as not selected?
- `CHK-06` Were findings limited to real remaining work, contradictions, or materially unrequested scope?
- `CHK-07` Were appended tasks added only as one new convergence phase?
- `CHK-08` Was `tasks.md` left unchanged when no actionable findings remained?
- `CHK-09` Does the report avoid claiming verification or release closure?
- `CHK-10` Is the next command assigned correctly based on the result?

## Post-Step Checks

- `tasks.md` is unchanged when convergence is clean.
- Any appended work appears only in one new convergence phase at the bottom of `tasks.md`.
- Existing tasks, ordering, and IDs remain untouched.
- No application code was changed.
- No implementation evidence or verification closure was claimed.

## Task Updates

Default: append-only when actionable findings exist.

When findings exist:

- append one new convergence phase to `tasks.md`
- append one new task per actionable finding
- preserve all prior task text and numbering

When convergence is clean:

- do not modify `tasks.md`
- report a converged result only

## Receipt Updates

Default: none.

`/converge` does not own implementation evidence or verification evidence.

When the user explicitly asks for a standalone convergence note:

- use `../../templates/spec-workflow/converge.template.md`
- keep the note as a handoff record, not as substitute workflow evidence
- do not mark verification complete from `/converge`

## Stop Conditions

- Required artifacts are missing or stale.
- App `AGENTS.md`, active `spec.md`, and active `plan.md` reference different active specs.
- The active scope cannot be determined reliably from the active artifacts and implemented files.
- A required registry file for a touched governed surface is missing or malformed.
- The command would need to rewrite existing tasks instead of appending one new convergence phase.
- More than three material convergence blockers prevent a trustworthy present-state assessment.
- The user requests `/verify` completion even though `/converge` still found actionable remaining work.

## Completion Report

Report:

- active spec folder
- artifacts assessed
- registry files reviewed
- convergence result
- whether `tasks.md` changed
- appended phase number when applicable
- appended task count when applicable
- findings by gap type
- findings by severity
- blockers, assumptions, or deferred interpretation issues
- recommended next command

## Next Command

- Run `/implement` when convergence appends remaining-work tasks.
- Run `/verify` only when convergence reports no actionable findings.
