# Planning Standard

Use this file as the workspace planning protocol. Each generated app should have its own `PLAN.md` created from `templates/PLAN.template.md`.

## When a Plan Is Required

Create or update a project `PLAN.md` before work that changes architecture, data model, authentication, permissions, routing, core UI shell, deployment, migrations, or more than one module.

A plan is optional for small fixes, documentation edits, formatting changes, or one-file corrections where the next action is obvious.

## Minimum Plan Content

A useful plan must state:

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
2. Keep the plan concise; avoid replacing issue tracking or product specs.
3. Mark decisions as accepted, deferred, or rejected.
4. Update the verification section when commands change.
5. Archive or replace stale plans instead of letting outdated guidance accumulate.

## Standard Files

- Root planning protocol: `PLANS.md`
- Reusable template: `templates/PLAN.template.md`
- Per-app plan: `projects/<app>/PLAN.md`

## Completion Rule

Before claiming a planned task is complete, compare final changes against the plan and call out any deviation, skipped verification, or unresolved decision.
