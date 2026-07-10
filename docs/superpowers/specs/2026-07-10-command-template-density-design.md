# Command And Template Density Design

Date: 2026-07-10
Status: Draft for user review

## Purpose

This slice strengthens the app-dev harness by making the core workflow path more command-driven, template-driven, and verification-driven. The first implementation slice focuses on the vertical path:

`/specify -> /plan -> /tasks -> /implement -> /verify`

The goal is not to vendor upstream `spec-kit` or copy its runtime model. The goal is to adapt the useful command-density and template-density ideas from `spec-kit` to the current app-dev standards, ownership model, scripts, and generated-app workflow.

## Current Problem

The current app-dev harness already has the right surfaces:

- `.agents/commands/` owns executable workflow steps.
- `templates/spec-workflow/` owns generated spec artifacts.
- `templates/PLAN.template.md` owns generated app plans.
- `standards/spec-driven-workflow.md` owns phase semantics.
- `standards/command-workflow-contract.md` owns command responsibilities.
- scripts enforce artifact, receipt, and verification contracts.

The weak point is density and repeatability. The current command files are directionally correct but too thin to consistently force preconditions, per-step outputs, receipt evidence, stop conditions, and completion reports. The current templates also leave too much room for vague output, incomplete workflow evidence, weak task sequencing, or stale plan content.

## Design Principles

1. **Commands force the workflow**
   - Commands define what must be read, written, checked, recorded, and reported for each phase.
   - Commands must not become templates or standards documents.

2. **Templates force repeatable outputs**
   - Templates define stable artifact shapes, required fields, allowed status values, and machine-checkable headings.
   - Templates must not duplicate command procedures or standards prose.

3. **Standards own durable policy**
   - Workflow semantics stay in `standards/spec-driven-workflow.md`.
   - Command responsibilities stay in `standards/command-workflow-contract.md`.
   - Scripting and validator behavior stay aligned with `standards/scripting.md`.

4. **Receipts are evidence**
   - `workflow-receipts.md` remains the source of workflow closure evidence.
   - Agent chat, final summaries, and unstored command narratives do not count as completion evidence.

5. **Local harness first**
   - External plugins and upstream spec-kit patterns can inspire shape and sequencing.
   - app-dev must not depend on upstream `.specify/` runtime files, hook runners, or command names.

## Scope

### Included In This Slice

1. Densify the core vertical command path:
   - `.agents/commands/specify.md`
   - `.agents/commands/plan.md`
   - `.agents/commands/tasks.md`
   - `.agents/commands/implement.md`
   - `.agents/commands/verify.md`

2. Densify the core templates:
   - `templates/spec-workflow/spec.template.md`
   - `templates/spec-workflow/tasks.template.md`
   - `templates/spec-workflow/workflow-receipts.template.md`
   - `templates/PLAN.template.md`

3. Touch supporting templates only where the vertical path requires it:
   - `templates/spec-workflow/checklist.template.md`
   - `templates/spec-workflow/converge.template.md`

4. Consolidate root planning protocol:
   - Fold the unique useful content from root `PLANS.md` into `standards/spec-driven-workflow.md`.
   - Stop treating `PLANS.md` as a standalone governance owner.
   - Update references and validators that require or point to `PLANS.md`.

5. Add targeted validator hardening only where needed to keep the new contracts honest.

### Excluded From This Slice

1. Full densification of `.agents/commands/analyze.md`.
2. Full densification of `.agents/commands/release-readiness.md`.
3. A generalized upstream spec-kit extension hook runtime.
4. A broad manifest or validator architecture rewrite.
5. A new workflow runner that replaces the existing command and script model.
6. Any app feature work under `projects/<app>/` except generated artifact compatibility if required by tests.

## Command Contract

Each command in the vertical path should follow the same stable structure:

1. `# /command`
2. `## Purpose`
3. `## Working Directory`
4. `## Start Gate`
5. `## Required Reads`
6. `## Required Writes`
7. `## Pre-Step Checks`
8. `## Execution Steps`
9. `## Post-Step Checks`
10. `## Receipt Updates`
11. `## Stop Conditions`
12. `## Completion Report`
13. `## Next Command`

The sections create a consistent grammar for Codex sessions and provide headings that validators can check without asserting exact prose.

### `/specify`

`/specify` creates or updates the active numbered spec surface. It should:

- confirm the command is running inside `projects/<app>/`
- create or select `specs/NNN-<slug>/`
- write or update `spec.md`
- initialize `tasks.md`
- initialize `workflow-receipts.md`
- initialize `checklist.md` when gated risk applies
- update the active spec pointer when appropriate
- run the pre-implementation artifact check before handing off to `/plan`
- stop before implementation

### `/plan`

`/plan` turns the active spec into an app-level plan. It should:

- confirm `AGENTS.md` points to the active spec
- read `spec.md`, `tasks.md`, `workflow-receipts.md`, and `templates/PLAN.template.md`
- update `PLAN.md`
- record architecture, module, data, permission, platform, workflow, verification, and deviation decisions
- run artifact and analysis checks that are safe before implementation
- stop if required plan fields remain unresolved
- hand off to `/tasks`

### `/tasks`

`/tasks` turns the spec and plan into an executable task sequence. It should:

- read `spec.md`, `PLAN.md`, `workflow-receipts.md`, and the task template
- organize tasks by setup, foundation, user story or vertical increment, polish, and verification
- require strict task IDs such as `T001`
- use `[P]` only for tasks that are truly parallelizable
- require exact repo-relative paths in task descriptions
- include explicit artifact, receipt, and verification tasks
- update workflow classification in receipts
- hand off to `/implement`

### `/implement`

`/implement` executes only after the active spec, plan, tasks, and receipts are ready. It should:

- confirm required artifacts exist and are current
- classify UI, data, mobile, and release-readiness workflow obligations
- execute tasks in dependency order
- update `tasks.md` as tasks are completed or deferred
- update receipt sections while implementation proceeds
- run `check-spec-artifacts.ps1` before handoff
- stop before completion claims
- hand off to `/verify`

### `/verify`

`/verify` closes convergence and verification. It should:

- reconcile `spec.md`, `PLAN.md`, `tasks.md`, and `workflow-receipts.md` to the implemented state
- use `converge.template.md` when an explicit convergence note is needed
- run `analyze-spec.ps1`
- run `check-spec-artifacts.ps1`
- run `validate-workflow-receipts.ps1 -RequireVerificationEvidence`
- run `verify-app.ps1`
- require rendered verification for UI work
- update verification evidence and closure state in receipts
- report skipped checks, blockers, deviations, and follow-ups

## Template Contract

### `spec.template.md`

The spec template should become closer to the upstream spec-kit shape while preserving app-dev fields. It should require:

- feature title and status
- risk level
- active app
- created date
- input or source request
- prioritized user scenarios or vertical increments
- independent test for each main scenario
- acceptance scenarios using concrete given/when/then wording when useful
- edge cases
- functional requirements with stable IDs such as `FR-001`
- success criteria with stable IDs such as `SC-001`
- data and permissions impact
- UX and platform notes
- assumptions
- risks and open questions
- verification intent

Placeholders should be explicit and easy for validators to detect. Generated specs must not retain unresolved placeholder text.

### `PLAN.template.md`

The app plan template should become the authoritative shape for `projects/<app>/PLAN.md`. It should require:

- active spec id and path
- status
- goal and non-goals
- app type and platform targets
- architecture decisions
- module impact table
- data, auth, permission, and storage impact
- workflow classification
- verification strategy
- rendered UI verification expectations when applicable
- risks and assumptions
- accepted, rejected, and deferred decisions
- deviations and follow-ups

Root `PLANS.md` should not remain the owner for these rules. The planning protocol belongs in `standards/spec-driven-workflow.md`; the app plan shape belongs in `templates/PLAN.template.md`.

### `tasks.template.md`

The tasks template should adopt the strongest useful spec-kit task ideas:

- strict checklist format
- `T001` task IDs
- `[P]` marker only for independent files or independent surfaces
- optional story or vertical-increment labels
- setup phase
- foundation phase
- independently testable user-story or vertical-increment phases
- polish and verification phase
- dependency and execution-order notes
- per-slice validation tasks
- explicit receipt-update tasks

The generated task list must remain immediately executable by a Codex session without requiring unstated context.

### `workflow-receipts.template.md`

The receipt template should make closure evidence harder to fake or omit. Each workflow receipt should require:

- trigger surface
- command path used
- local workflow used
- external skill used, unavailable, or not needed
- files and surfaces reviewed
- implementation evidence
- verification commands
- verification result
- outstanding gaps
- decision and closure state

The classification section should remain the first place commands record whether UI, data, mobile, or release-readiness workflows are required.

### `checklist.template.md`

The checklist template should stay gated-risk focused. It should not duplicate every command step. It should require:

- clarification closure
- security and data review
- implementation readiness
- rollback or failure behavior where relevant
- explicit user approval for destructive or live-environment operations

### `converge.template.md`

The convergence template should support `/verify` by requiring:

- spec match
- plan match
- task status match
- receipt closure match
- documentation drift check
- verification evidence
- deviations
- deferred items
- handoff notes

## Planning Protocol Consolidation

Root `PLANS.md` currently duplicates planning protocol that now belongs to the workflow standard and command contract. The implementation slice should:

1. Move unique planning requirements into `standards/spec-driven-workflow.md`.
2. Keep `templates/PLAN.template.md` as the app plan artifact template.
3. Keep `.agents/commands/plan.md` as the executable `/plan` command contract.
4. Update `standards/workspace.md`, root `AGENTS.md`, README, manifest rules, and validators so `PLANS.md` is no longer a primary governance surface.
5. Remove `PLANS.md` if no compatibility reason remains; otherwise replace it with a short pointer file and record why the pointer remains.

The preferred end state is no standalone root `PLANS.md`.

## Validator Boundary

Validator work in this slice should stay targeted:

- command files contain the required contract headings
- templates contain required stable headings
- generated spec artifacts do not retain unresolved placeholders
- `tasks.md` keeps `## Task List`
- task items follow the required task ID format when material implementation tasks exist
- receipts keep `Command path used:`
- verification evidence is required before completion closure
- root `PLANS.md` is not required once planning protocol consolidation lands

Do not use this slice to perform a broad validator rewrite or a full manifest redesign.

## Verification Model

The implementation slice is complete only when:

1. The five vertical path command files share the command contract structure.
2. The four core templates generate denser, more repeatable artifacts.
3. Supporting checklist and convergence templates are updated only where needed.
4. Root `PLANS.md` is consolidated into the workflow standard or reduced to a justified pointer.
5. Standards and root docs point to canonical owners instead of duplicating workflow procedure.
6. Targeted validators enforce the new structure without exact-prose assertions.
7. `scripts/check-all.ps1` passes, or any blocker is recorded with exact command output and next action.
8. The final handoff separates this slice's changes from unrelated dirty worktree changes.

## Risks

1. **Over-densifying commands**
   - Mitigation: use stable headings and concise bullets; keep standards prose in standards files.

2. **Duplicating owner facts**
   - Mitigation: point commands and templates at `standards/spec-driven-workflow.md`, `standards/command-workflow-contract.md`, and `standards/scripting.md` instead of restating all rules.

3. **Breaking existing generated app validation**
   - Mitigation: update tests and generated template expectations in the same slice as template changes.

4. **Letting `PLANS.md` removal become a broad docs churn task**
   - Mitigation: only update references directly tied to planning ownership and validator expectations.

5. **Importing upstream spec-kit assumptions that do not fit app-dev**
   - Mitigation: borrow structure, not runtime paths, hook mechanics, branch assumptions, or command names.

## Follow-Up Slice

After this vertical path is implemented and verified, the next harness slice should densify:

- `.agents/commands/analyze.md`
- `.agents/commands/release-readiness.md`
- any release-readiness template or receipt closure gaps found during the first slice
- broader manifest-driven validator improvements if the vertical slice exposes repeated structural checks

## Recommendation

Proceed with the vertical command and template density slice. Include `/plan`, `templates/PLAN.template.md`, and root `PLANS.md` consolidation in the same slice because planning is central to the path and the current root protocol file is now an ownership drift candidate.
