# Spec-Driven Workflow Standard

This workspace uses a translated local spec-driven workflow inspired by `spec-kit`. The workflow is local to `app-dev`; it does not require `specify-cli`, a vendored `.specify/` tree, or upstream workflow runtime support.

## Constitution

`standards/constitution.md` is the stable principle set for this workspace. Keep operational mechanics in this workflow standard and other delegated standards instead of duplicating them in the constitution.

## Artifact Roles

- `projects/<app>/AGENTS.md`: durable app identity, stack constraints, verification rules, and active spec pointer
- `projects/<app>/specs/NNN-<slug>/spec.md`: feature intent, requirements, acceptance criteria, data impact, and risk
- `projects/<app>/specs/NNN-<slug>/plan.md`: architecture, rollout, verification, and implementation constraints derived from that spec
- `projects/<app>/specs/NNN-<slug>/tasks.md`: ordered implementation checklist for that feature
- `projects/<app>/specs/NNN-<slug>/workflow-receipts.md`: workflow classification, Applicable Standards Checklist evidence, and closure evidence for UI, data, mobile, and release-readiness obligations
- `projects/<app>/specs/NNN-<slug>/checklist.md`: gated review checklist for sensitive work
- `templates/spec-workflow/plan.template.md`: reusable per-spec plan shape for generated and updated plans

## Numbered Specs

- Start every generated app with `specs/001-initial/`.
- Later feature work uses `specs/00N-<feature-slug>/`.
- Numbers are zero-padded to three digits and increase monotonically.
- `AGENTS.md` and the active spec's `plan.md` must both point to the active spec path before material implementation begins.

## Validation Modes

Project artifact validation has two deliberate modes:

- `compatibility`: the default for existing apps already living under `projects/<app>/`. This enforces the durable minimum contract needed for active work and does not retroactively fail an older app just because `app-dev` later densified a template, command, or source validator.
- `current-template`: the source-of-truth contract for newly generated apps, disposable scaffold verification, and any app that is explicitly refreshed to the current template shape. This mode enforces the latest dense template sections and command expectations.

Use `current-template` only when validating newly generated artifacts or an app that intentionally opted into the newer scaffold. Use `compatibility` for ordinary work on established apps unless the spec or plan explicitly includes a migration to the current template contract.

## Phase To Command Map

| Phase | Command owner | Main enforcement |
|---|---|---|
| Clarify (gated only) | `.agents/commands/specify.md` gated branch | `check-spec-artifacts.ps1` plus later checklist completion |
| Spec | `.agents/commands/specify.md` | `check-spec-artifacts.ps1` |
| Plan | `.agents/commands/plan.md` | `check-spec-artifacts.ps1`, `analyze-spec.ps1` |
| Tasks | `.agents/commands/tasks.md` | `check-spec-artifacts.ps1`, `validate-workflow-receipts.ps1` |
| Analyze | `.agents/commands/analyze.md` | `analyze-spec.ps1`, `get-applicable-standard-rules.ps1` preflight when relevant |
| Implement | `.agents/commands/implement.md` | `get-applicable-standard-rules.ps1`, `check-spec-artifacts.ps1` before handoff |
| Converge | `.agents/commands/converge.md` | `get-applicable-standard-rules.ps1` convergence review when relevant, append-only `tasks.md` updates |
| Verify | `.agents/commands/verify.md` | `check-spec-artifacts.ps1`, `validate-workflow-receipts.ps1 -RequireVerificationEvidence`, `verify-app.ps1` |
| Release readiness | `.agents/commands/release-readiness.md` | `validate-workflow-receipts.ps1`, `verify-app.ps1`, any slice-specific release gate |

The standards document owns the phase narrative. Command files own the exact execution steps, working directory, and receipt obligations.

## Lean Path

Use the lean path for ordinary app and module work:

`spec -> plan -> tasks -> analyze -> implement -> converge -> verify -> handoff`

Lean-path work still requires:

- a complete `spec.md`
- a current `plan.md`
- a tracked `tasks.md` created during `/tasks`
- a current `workflow-receipts.md` created during `/tasks`
- `../../scripts/analyze-spec.ps1 -ProjectPath .` before material implementation starts
- Analyze-phase registry-rule visibility is reviewed before `/implement` when the active artifacts or task paths trigger relevant `../../standards/registry/*.rules.json` families.
- applicable implementation rules resolved from `../../standards/registry/*.rules.json` and recorded in `workflow-receipts.md`
- `/converge` determines whether implementation is actually done or must return to `/implement`
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before implementation handoff
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` before completion
- `../../scripts/verify-app.ps1 -ProjectPath .` plus rendered UI checks before completion

## Gated Path

Use the gated path for work involving auth, payments, secrets, public APIs, data access, file uploads, RLS, AI tool actions, deployment, or live migrations:

`clarify -> spec -> checklist -> plan -> tasks -> analyze -> implement -> converge -> verify -> handoff`

Gated-path work requires:

- a populated `checklist.md` created no earlier than `/tasks` for gated or sensitive work
- contradictions found by `../../scripts/analyze-spec.ps1 -ProjectPath .` are resolved before material implementation starts
- Analyze may preflight registry-rule visibility before `/implement`, but implementation-time Applicable Standards Checklist ownership remains in `/implement`
- `/converge` closes the post-implementation done or not-done decision before `/verify`
- a populated `workflow-receipts.md` with the Applicable Standards Checklist and relevant workflow sections kept current
- explicit security, data, and rollback notes
- explicit user approval before destructive or live-environment operations

## Convergence

Convergence is artifact-based in this workspace. Before claiming a feature is complete, confirm:

- implemented scope still matches the active `spec.md`
- `plan.md` reflects the real architecture and verification decisions
- `tasks.md` accurately marks completed and deferred work
- `workflow-receipts.md` accurately captures which local wrapper workflows were required and what verification evidence exists
- the Applicable Standards Checklist records how the selected registry rules were applied, deferred, or blocked
- implementation-time documentation reconciliation already aligned touched governed docs to the implemented state
- handoff notes capture deviations, skipped checks, and follow-up items

Use `templates/spec-workflow/converge.template.md` as the default handoff structure when a feature needs an explicit convergence note.

In command terms, `/converge` closes the post-implementation done or not-done decision: it refreshes `/analyze` models against implemented reality, appends remaining work to `tasks.md` when needed, and sends the slice back to `/implement` or forward to `/verify`.

`/verify` assumes convergence is already closed, then records verification evidence, rendered checks, blockers, and final completion closure against the converged state.
