# /specify

## Purpose

Create or update the active numbered spec surface for one feature or workflow slice.

## Working Directory

Run inside `projects/<app>/`. Do not run this command from the repository root.

## Start Gate

- Confirm the current directory contains app `AGENTS.md` and, when present, `PLAN.md`.
- Confirm the requested work is one feature or one vertical slice. Split broad requests before creating artifacts.
- Generate or select a `specs/NNN-<slug>/` folder using monotonically increasing three-digit numbering.
- Stop if the feature description is empty or if more than three material clarifications are needed.

## Required Reads

- Root `../../AGENTS.md`
- App `AGENTS.md`
- `../../standards/spec-driven-workflow.md`
- `../../standards/command-workflow-contract.md`
- `../../templates/spec-workflow/spec.template.md`
- `../../templates/spec-workflow/tasks.template.md`
- `../../templates/spec-workflow/workflow-receipts.template.md`
- `../../templates/spec-workflow/checklist.template.md` when gated risk applies

## Required Writes

- `specs/NNN-<slug>/spec.md`
- `specs/NNN-<slug>/tasks.md`
- `specs/NNN-<slug>/workflow-receipts.md`
- `specs/NNN-<slug>/checklist.md` when gated risk applies
- App `AGENTS.md` active specification pointer, when the selected spec becomes active

## Pre-Step Checks

- Confirm no generated artifact keeps unresolved template tokens after the feature description is applied.
- Confirm risk level is one of the allowed local risk values.
- Confirm gated work has a checklist initialized before implementation starts.
- Confirm `tasks.md` contains `## Task List`.
- Confirm `workflow-receipts.md` contains `Command path used:` fields.
- Use `../../scripts/check-spec-artifacts.ps1 -ValidationMode current-template` only for newly generated or explicitly refreshed apps; existing apps stay on the default compatibility contract unless this slice includes a template migration.

## Execution Steps

1. Parse the user request into actors, outcomes, data touched, target platforms, constraints, and explicit exclusions.
2. Choose a concise slug from durable feature terms.
3. Create or select `specs/NNN-<slug>/`.
4. Populate `spec.md` with prioritized scenarios or vertical increments, independent tests, functional requirements, success criteria, data and permission impact, UX/platform notes, assumptions, risks, and verification intent.
5. Populate `tasks.md` from the task template with initial setup, planning, receipt, and verification tasks. Leave implementation-specific tasks for `/tasks` when details are not yet known.
6. Populate `workflow-receipts.md`; classify UI, data, mobile, and release-readiness obligations as required or not required.
7. Populate `checklist.md` for gated work and resolve required clarification, security, data, rollback, and approval items before implementation.
8. Update app `AGENTS.md` if this is the active spec.
9. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`. Use `-ValidationMode current-template` only when this spec is validating a newly generated or intentionally refreshed app scaffold.

## Post-Step Checks

- `spec.md` has stable `FR-###` and `SC-###` IDs.
- Each main scenario or vertical increment has an independent test.
- `workflow-receipts.md` records the workflow classification.
- Gated risk has a populated `checklist.md`.
- Artifact validation passes or the blocker is recorded exactly.

## Receipt Updates

- Record `/specify` in `Command path used:` for any workflow section initialized by this command.
- Record files reviewed and current outstanding gaps.
- Leave verification evidence as planned or not-run; do not mark closure complete from `/specify`.

## Stop Conditions

- No concrete feature description was provided.
- The request spans unrelated features that need separate specs.
- A gated decision requires user approval before it can be documented.
- `check-spec-artifacts.ps1` fails and the failure cannot be resolved inside the spec artifacts.

## Completion Report

Report the selected spec folder, risk level, workflow classification, files written, artifact check result, unresolved questions, and whether the next step is `/plan`.

## Next Command

Run `/plan` after the spec, initial tasks, receipts, and any gated checklist are ready.
