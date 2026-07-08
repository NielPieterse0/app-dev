# Planning Standard

Use this file as the workspace planning protocol. Each generated app should have its own `PLAN.md` created from `templates/PLAN.template.md` and derived from an active numbered spec in `projects/<app>/specs/`.

## When a Plan Is Required

Create or update a project `PLAN.md` before work that changes architecture, data model, authentication, permissions, routing, core UI shell, deployment, migrations, or more than one module.

Create or update a numbered feature spec before any material app work, then update `PLAN.md` from that active spec before implementation starts.

A plan is optional for small fixes, documentation edits, formatting changes, or one-file corrections where the next action is obvious.

## Minimum Plan Content

A useful plan must state:

- active spec id and path
- goal and non-goals
- target app type and platforms
- affected modules/files
- user-visible behavior
- data/auth/permission impact
- risks and assumptions
- verification commands and rendered UI checks
- open decisions

## Plan Lifecycle

1. Draft the plan before implementation.
2. Confirm the active spec path in `AGENTS.md` before changing `PLAN.md`.
3. Keep the plan concise; avoid replacing issue tracking or product specs.
4. Mark decisions as accepted, deferred, or rejected.
5. Update the verification section when commands change.
6. Archive or replace stale plans instead of letting outdated guidance accumulate.

## Standard Files

- Root planning protocol: `PLANS.md`
- Reusable template: `templates/PLAN.template.md`
- Reusable spec templates: `templates/spec-workflow/`
- Per-app plan: `projects/<app>/PLAN.md`
- Per-app feature specs: `projects/<app>/specs/NNN-<slug>/`

## Completion Rule

Before claiming a planned task is complete, compare final changes against the plan and call out any deviation, skipped verification, or unresolved decision.
