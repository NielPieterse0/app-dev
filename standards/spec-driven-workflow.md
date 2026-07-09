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

## Numbered Specs

- Start every generated app with `specs/001-initial/`.
- Later feature work uses `specs/00N-<feature-slug>/`.
- Numbers are zero-padded to three digits and increase monotonically.
- `AGENTS.md` and `PLAN.md` must both point to the active spec path before material implementation begins.

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
