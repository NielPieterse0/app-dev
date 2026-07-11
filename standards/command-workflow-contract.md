# Command Workflow Contract

This workspace uses local command templates as workflow gates, not as lightweight prompt shortcuts.

## Required Behavior

- Commands must route through numbered specs and then create later artifacts in phase order rather than assuming they already exist.
- Commands must use the same workflow taxonomy as local workflow skills:
  - UI
  - Data
  - Mobile
  - Release readiness
- Commands must not treat external/global skills as required runtime dependencies.
- Commands may reference optional external capabilities only through the local workflow wrappers and must record the fallback when unavailable.

## Command Responsibilities

- `specify`: create or update the active numbered `spec.md` only.
- `plan`: require the active spec and create or update `plan.md` only.
- `tasks`: require the active spec and `plan.md`, then create or update `tasks.md`, `workflow-receipts.md`, and `checklist.md` when gated or sensitive risk applies.
- `analyze`: require the active spec, active `plan.md`, active `tasks.md`, initialized `workflow-receipts.md`, and gated `checklist.md` when required; resolve contradictions, surface implementation blockers, and preflight rule visibility before implementation starts.
- `implement`: require current tasks plus initialized workflow receipts, resolve applicable registry rules, record the Applicable Standards Checklist, execute implementation in dependency order, keep implementation evidence current, stop on blocked critical rules or missing validator evidence, reconcile documentation and artifacts, and hand off to `/converge`.
- `converge`: require the active spec package plus implemented surfaces, refresh the analysis models established by `/analyze`, review dynamic rule pressure for the converged state, append remaining work to `tasks.md` when needed, and hand off either back to `/implement` or forward to `/verify`.
- `verify`: require a converged state plus current workflow receipts and verification evidence.
- `release-readiness`: require workflow closure and unresolved-gap reporting before completion claims.

## Evidence Model

The workflow evidence artifact is `specs/NNN-<slug>/workflow-receipts.md`.
`workflow-receipts.md` also owns the Applicable Standards Checklist produced from the registry layer during implementation.

Commands, local workflow skills, hooks, validators, and CI must all agree on this file as the source of workflow closure evidence.

This contract is local to `app-dev`; it does not require vendored upstream `spec-kit` runtime files.
