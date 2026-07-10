# Spec-Driven Workflow Standard

This workspace uses a translated local spec-driven workflow inspired by `spec-kit`. The workflow is local to `app-dev`; it does not require `specify-cli`, a vendored `.specify/` tree, or upstream workflow runtime support.

## Constitution

`standards/constitution.md` is the stable principle set for this workspace. Keep operational mechanics in this workflow standard and other delegated standards instead of duplicating them in the constitution.

## Artifact Roles

- `projects/<app>/AGENTS.md`: durable app identity, stack constraints, verification rules, and active spec pointer
- `projects/<app>/specs/NNN-<slug>/spec.md`: feature intent, requirements, acceptance criteria, data impact, and risk
- `projects/<app>/specs/NNN-<slug>/tasks.md`: ordered implementation checklist for that feature
- `projects/<app>/specs/NNN-<slug>/workflow-receipts.md`: workflow classification and closure evidence for UI, data, mobile, and release-readiness obligations
- `projects/<app>/specs/NNN-<slug>/checklist.md`: gated review checklist for sensitive work
- `projects/<app>/PLAN.md`: architecture, rollout, verification, and implementation constraints derived from the active spec
- `templates/spec-workflow/PLAN.template.md`: reusable app plan shape for generated and updated app plans

## Numbered Specs

- Start every generated app with `specs/001-initial/`.
- Later feature work uses `specs/00N-<feature-slug>/`.
- Numbers are zero-padded to three digits and increase monotonically.
- `AGENTS.md` and `PLAN.md` must both point to the active spec path before material implementation begins.

## Validation Modes

Project artifact validation has two deliberate modes:

- `compatibility`: the default for existing apps already living under `projects/<app>/`. This enforces the durable minimum contract needed for active work and does not retroactively fail an older app just because `app-dev` later densified a template, command, or source validator.
- `current-template`: the source-of-truth contract for newly generated apps, disposable scaffold verification, and any app that is explicitly refreshed to the current template shape. This mode enforces the latest dense template sections and command expectations.

Use `current-template` only when validating newly generated artifacts or an app that intentionally opted into the newer scaffold. Use `compatibility` for ordinary work on established apps unless the spec or plan explicitly includes a migration to the current template contract.

## Phase To Command Map

| Phase | Command owner | Main enforcement |
|---|---|---|
| Clarify (gated only) | `.agents/commands/specify.md` gated branch | `check-spec-artifacts.ps1` plus checklist completion |
| Spec | `.agents/commands/specify.md` | `check-spec-artifacts.ps1` |
| Plan | `.agents/commands/plan.md` | `check-spec-artifacts.ps1`, `analyze-spec.ps1` |
| Tasks | `.agents/commands/tasks.md` | `check-spec-artifacts.ps1`, `validate-workflow-receipts.ps1` |
| Implement | `.agents/commands/implement.md` | `check-spec-artifacts.ps1` before handoff |
| Analyze | `.agents/commands/analyze.md` | `analyze-spec.ps1` |
| Verify | `.agents/commands/verify.md` | `check-spec-artifacts.ps1`, `validate-workflow-receipts.ps1 -RequireVerificationEvidence`, `verify-app.ps1` |
| Release readiness | `.agents/commands/release-readiness.md` | `validate-workflow-receipts.ps1`, `verify-app.ps1`, any slice-specific release gate |

The standards document owns the phase narrative. Command files own the exact execution steps, working directory, and receipt obligations.

## Lean Path

Use the lean path for ordinary app and module work:

`spec -> plan -> tasks -> implement -> analyze -> verify -> handoff`

Lean-path work still requires:

- a complete `spec.md`
- a current `PLAN.md`
- a tracked `tasks.md`
- a current `workflow-receipts.md`
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before implementation handoff
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` before completion
- `../../scripts/verify-app.ps1 -ProjectPath .` plus rendered UI checks before completion

## Gated Path

Use the gated path for work involving auth, payments, secrets, public APIs, data access, file uploads, RLS, AI tool actions, deployment, or live migrations:

`clarify -> spec -> checklist -> plan -> tasks -> implement -> converge -> analyze -> verify -> handoff`

Gated-path work requires:

- a populated `checklist.md`
- a populated `workflow-receipts.md` with the relevant sections closed
- explicit security, data, and rollback notes
- explicit user approval before destructive or live-environment operations

## Convergence

Convergence is artifact-based in this workspace. Before claiming a feature is complete, confirm:

- implemented scope still matches the active `spec.md`
- `PLAN.md` reflects the real architecture and verification decisions
- `tasks.md` accurately marks completed and deferred work
- `workflow-receipts.md` accurately captures which local wrapper workflows were required and what verification evidence exists
- handoff notes capture deviations, skipped checks, and follow-up items

Use `templates/spec-workflow/converge.template.md` as the default handoff structure when a feature needs an explicit convergence note.

In command terms, convergence is closed inside `/verify`: artifacts are reconciled first, then verification evidence is recorded against the converged state.

## Planning Protocol

Planning protocol is owned here. App plan shape is owned by `templates/spec-workflow/PLAN.template.md`. Root `PLANS.md` is not a standalone governance surface.

### When A Plan Is Required

Create or update `projects/<app>/PLAN.md` before work that changes architecture, data model, authentication, permissions, routing, core UI shell, deployment, migrations, or more than one module.

Create or update a numbered feature spec before material app work, then update `PLAN.md` from that active spec before implementation starts.

A plan is optional for small fixes, documentation edits, formatting changes, or one-file corrections where the next action is obvious.

### Minimum Plan Content

A useful app plan states:

- active spec id and path
- goal and non-goals
- target app type and platforms
- affected modules/files
- user-visible behavior
- data/auth/permission/storage impact
- workflow classification
- risks and assumptions
- verification commands and rendered UI checks
- accepted, rejected, and deferred decisions
- open decisions, deviations, and follow-ups

### Plan Lifecycle

1. Draft the plan before implementation when the work meets the plan-required threshold.
2. Confirm the active spec path in app `AGENTS.md` before changing `PLAN.md`.
3. Keep the plan concise; avoid replacing specs, tasks, or issue tracking.
4. Mark decisions as accepted, deferred, or rejected.
5. Update the verification section when commands change.
6. Replace stale plan content with current active-spec decisions instead of letting outdated guidance accumulate.

### Standard Files

- Planning protocol: `standards/spec-driven-workflow.md`
- Reusable app plan template: `templates/spec-workflow/PLAN.template.md`
- Reusable spec templates: `templates/spec-workflow/`
- Per-app plan: `projects/<app>/PLAN.md`
- Per-app feature specs: `projects/<app>/specs/NNN-<slug>/`

### Completion Rule

Before claiming a planned task is complete, compare final changes against the plan and call out any deviation, skipped verification, unresolved decision, or deferred item.
