# Command Workflow Contract

This workspace uses local command templates as workflow gates, not as lightweight prompt shortcuts.

## Required Behavior

- Commands must route through numbered specs, current plans, current tasks, and workflow receipts.
- Commands must use the same workflow taxonomy as local workflow skills:
  - UI
  - Data
  - Mobile
  - Release readiness
- Commands must not treat external/global skills as required runtime dependencies.
- Commands may reference optional external capabilities only through the local workflow wrappers and must record the fallback when unavailable.

## Command Responsibilities

- `specify`: create or update the active numbered spec and initialize workflow classification.
- `plan`: require the active spec and require `PLAN.md` for architecture-sensitive work.
- `tasks`: require current tasks and initialize risk-domain checklist use when needed.
- `implement`: require current tasks plus initialized workflow receipts.
- `verify`: require current workflow receipts plus verification evidence.
- `release-readiness`: require workflow closure and unresolved-gap reporting before completion claims.

## Evidence Model

The workflow evidence artifact is `specs/NNN-<slug>/workflow-receipts.md`.

Commands, local workflow skills, hooks, validators, and CI must all agree on this file as the source of workflow closure evidence.

This contract is local to `app-dev`; it does not require vendored upstream `spec-kit` runtime files.
