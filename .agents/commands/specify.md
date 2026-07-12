# /specify

## Purpose

Create or update one numbered feature specification from a product feature description or user request.

`/specify` is step one of the workflow. It only creates or updates `specs/NNN-<slug>/spec.md`.

It does not create or update:

- `plan.md`
- `tasks.md`
- `workflow-receipts.md`
- `checklist.md`
- app `AGENTS.md`

## Working Directory

Run inside `projects/<app>/`.

Do not run this command from the repository root.

## Start Gate

- Confirm the current directory contains app `AGENTS.md`.
- Confirm a concrete product feature description or user request exists.
- Confirm the requested work is one feature or one vertical slice.
- Split broad or unrelated requests into separate specs before creating artifacts.

## Required Reads

- Root `../../AGENTS.md`
- App `AGENTS.md`
- `../../standards/spec-driven-workflow.md`
- `../../standards/constitution.md`
- `../../standards/command-workflow-contract.md`
- `../../standards/workspace.md`
- `../../standards/stack.md`
- `../../standards/security.md`
- `../../standards/codex-capabilities.md`
- `../../templates/spec-workflow/spec.template.md`

## Required Writes

- `specs/NNN-<slug>/spec.md`

## Pre-Step Checks

- Confirm the feature description is concrete enough to describe users, outcomes, scope boundaries, and verification intent.
- Confirm risk level will be classified with one allowed local value: `standard`, `gated`, or `sensitive`.
- Confirm no generated spec keeps unresolved template tokens after writing.
- Use the spec-only validation path for `/specify`.
- Do not require `plan.md`, `tasks.md`, `workflow-receipts.md`, or `checklist.md` at this step.

## Execution Steps

### Phase 1: Parse The Request

1. Read the product feature description or user request.
2. Identify:
   - actors
   - user outcomes
   - data touched
   - target platforms or surfaces
   - constraints
   - explicit exclusions
3. Choose a risk level:
   - `standard` for ordinary feature work with no sensitive or gated concerns
   - `gated` for work involving elevated security, auth, data, permission, or live-environment review needs
   - `sensitive` for the highest-risk work that requires the strongest gated treatment
4. If key details are missing, make reasonable defaults.
5. Ask for clarification only when the missing point would materially change scope, security, permissions, or user-visible behavior.
6. Limit unresolved clarifications to at most three critical items.

### Phase 2: Name The Spec

1. Choose a short, durable slug from the feature terms.
2. Prefer business or product language over implementation language.
3. Avoid temporary wording such as `fix`, `misc`, `v2`, or ticket-only names unless the request is truly defect-specific.

### Phase 3: Create Or Select The Spec Folder

1. Create or select `specs/NNN-<slug>/`.
2. `NNN` is the next monotonically increasing three-digit number.
3. `<slug>` is the durable feature or workflow-slice name.
4. Write or update `specs/NNN-<slug>/spec.md` from `../../templates/spec-workflow/spec.template.md`.

### Phase 4: Write The Spec

Populate `spec.md` with concrete content derived from the request.

The spec must include:

- status
- risk level
- summary
- problem
- scope
- scoped user scenarios
- independently testable stories or vertical increments
- functional requirements
- key entities when relevant
- measurable success criteria
- data, permissions, and sensitive-operation notes
- UX and platform notes
- assumptions
- risks and open questions
- verification intent

### Phase 5: Apply Spec Quality Rules

When writing the spec:

- Ensure requirement completeness: all necessary requirements are documented.
- Ensure requirement clarity: requirements are specific and unambiguous.
- Ensure requirement consistency: requirements do not conflict with each other.
- Ensure acceptance criteria quality: success criteria are measurable or objectively observable.
- Ensure scenario coverage: primary, alternate, and relevant exception flows are addressed.
- Ensure edge-case coverage: boundary conditions and failure cases are described.
- Ensure non-functional requirements are included when relevant, such as performance, security, accessibility, privacy, or reliability.
- Ensure dependencies and assumptions are documented and separated from requirements.
- Surface ambiguities and conflicts explicitly instead of hiding them in vague wording.

Also:

- Prefer product behavior over implementation detail.
- State what the system must do, not how it will be built.
- Keep scope bounded.
- Make each requirement testable and observable.
- Use stable IDs such as `FR-001` and `SC-001`.
- Use plain language that a product owner, reviewer, or implementer can all read.

### Phase 6: Run Spec Review

Before finishing, review the spec against this checklist:

- `CHK-01` Does the spec describe one feature or one vertical slice only?
- `CHK-02` Is the feature scope clearly bounded?
- `CHK-03` Are exclusions explicit?
- `CHK-04` Are the primary actors and outcomes clear?
- `CHK-05` Does each main story have an independent test?
- `CHK-06` Are stable IDs such as `FR-001` and `SC-001` used?
- `CHK-07` Is the chosen risk level appropriate to the feature's data, permission, and operational impact?
- `CHK-08` Are requirements complete for the intended slice?
- `CHK-09` Are requirements specific, testable, and unambiguous?
- `CHK-10` Are requirements internally consistent and free of obvious conflicts?
- `CHK-11` Are success criteria measurable or objectively observable?
- `CHK-12` Are primary, alternate, and relevant exception scenarios covered?
- `CHK-13` Are important edge cases addressed?
- `CHK-14` Are relevant non-functional requirements stated when needed?
- `CHK-15` Are dependencies and assumptions documented clearly?
- `CHK-16` Are open questions and unresolved ambiguities clearly separated?
- `CHK-17` Are data, permission, and sensitive-operation impacts described?
- `CHK-18` Are all placeholder tokens removed?

## Post-Step Checks

- `spec.md` exists at `specs/NNN-<slug>/spec.md`.
- No unresolved template placeholders remain.

## Receipt Updates

- Do not update `workflow-receipts.md` from `/specify`.
- Leave workflow classification, implementation evidence, and verification evidence for later owning phases.

## Stop Conditions

- No concrete feature description was provided.
- The request spans unrelated features that need separate specs.
- More than three material clarifications are required.
- A critical scope, security, or permission decision cannot be safely defaulted.
- Spec-only validation fails and the failure cannot be resolved inside `spec.md`.

## Completion Report

Report:

- selected spec folder
- spec file path
- chosen risk level
- feature scope summary
- open questions or assumptions
- spec-only validation result
- recommended next command

## Next Command

Run `/plan` after `spec.md` is complete and accepted.
