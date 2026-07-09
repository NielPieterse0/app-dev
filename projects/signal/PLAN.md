# Signal Task Plan

- Created: 2026-07-09
- Template: react-vite-capacitor
- Active spec: `specs/006-harness-consolidation/spec.md`
- Status: in progress

## Goal

Implement the harness-consolidation slice so Workspace Standard v2 is fully wired into the executable governance layer, validators, generator, and template references that Signal currently depends on.

## Non-Goals

- script portability remediation, CI job hygiene, or code-level cleanup deferred to `specs/007-code-script-closeout/`
- new Signal product features, source ingestion changes, or dashboard UX work
- repo splitting, matrix auto-discovery before a second tracked app exists, or broader wrapper-skill consolidation beyond thin workflow pointers
- public-launch auth/RLS hardening

## Spec Link

- Spec id: `006-harness-consolidation`
- Spec path: `specs/006-harness-consolidation/spec.md`
- Tasks path: `specs/006-harness-consolidation/tasks.md`
- Workflow receipts path: `specs/006-harness-consolidation/workflow-receipts.md`
- Checklist path: `specs/006-harness-consolidation/checklist.md`
- Audit source: `../../docs/audit/2026-07-09-app-dev-signal-review-findings.md`
- Background source: `../../standards/workspace.md` and the 2026-07-09 harness audit attached to slice creation

## Architecture Decision

- `standards/spec-driven-workflow.md` owns workflow narrative; `.agents/commands/` own executable phase steps.
- Required-path lists and governed numbers are sourced from `standards/workspace-manifest.psd1` instead of being duplicated across validators.
- The canonical governance run is `scripts/check-all.ps1`, and docs/CI point to that sequencer instead of maintaining their own script lists.
- Dormant hook assets are deleted rather than retained as unwired placeholders.
- Template CI workflow files remain reference-only under `templates/common/ci/`; generated apps must not receive nested executable `.github/` workflows.

## Module Plan

| Surface | Responsibility | Main files | Verification |
| --- | --- | --- | --- |
| `workflow-owner-docs` | collapse duplicate workflow prose into owner pointers plus command map | `AGENTS.md`, `standards/spec-driven-workflow.md`, `.agents/skills/cross-platform-app-workflow/SKILL.md`, `.agents/commands/*.md` | validator + artifact checks |
| `manifest-and-validators` | source governed paths/numbers once and enforce pointer-style governance checks | `standards/workspace-manifest.psd1`, `scripts/check-workspace.ps1`, `scripts/validate-codex-assets.ps1` | governance checks |
| `generator-and-template-ci` | keep generated apps free of nested workflows while preserving CI reference material | `scripts/create-app.ps1`, `scripts/test-workspace.ps1`, `templates/common/ci/verify.reference.yml`, template docs | governance checks + generation test |
| `codex-policy-layer` | remove dormant hook references and keep hook/rules coverage aligned | `.codex/config.toml`, `.codex/README.md`, `.codex/rules/default.rules`, `scripts/test-hooks.ps1` | governance checks |
| `workspace-docs` | align README/workspace guidance to the canonical governance entry point and cross-platform command forms | `README.md`, `standards/workspace.md` | governance checks |

## Implementation Steps

1. Make slice `006` the active Signal spec and keep AGENTS/PLAN/spec artifacts aligned.
2. Add the workflow phase-to-command map, slim duplicate workflow prose to pointers, and document clarify/convergence at the command layer.
3. Create the workspace manifest and refactor the workspace validators to consume it for required paths and governed numbers.
4. Add `scripts/check-all.ps1` and repoint docs plus CI to the canonical governance sequence.
5. Delete the dormant `verify-before-finish` hook surface and remove every validator/test/doc reference to it.
6. Move template CI workflow content to `templates/common/ci/verify.reference.yml`, exclude `.github/` from template copies, and assert generated apps stay free of nested workflow folders.
7. Reconcile workspace-doc drift, hook/rules layering notes, and remaining pending markers in `standards/workspace.md`.
8. Re-run workspace governance checks, Signal spec artifact checks, and Signal regression checks, then update the slice receipts/tasks/checklist to match the implemented state.

## Risks And Assumptions

| Item | Type | Impact | Mitigation |
| --- | --- | --- | --- |
| Validator refactors can accidentally weaken enforcement while reducing duplication | risk | high | keep existing content checks where they still enforce real contracts, and add explicit workflow-pointer assertions |
| Generated-app verification can silently regress if the template copy/filter and workspace tests diverge | risk | high | update `create-app.ps1` and `test-workspace.ps1` in the same change |
| Rules/hook layering may still have uncovered escalated-command gaps | risk | medium | re-read `default.rules` against `pre-command.ps1` and keep hook superset direction documented |
| Hosted CI remains the final referee, but local checks are still useful for fast feedback | assumption | medium | reproduce the workspace-validation sequence locally through `scripts/check-all.ps1` before handoff |

## Data Security Posture

- No secrets, tokens, or private-key reads are introduced by this slice.
- Hook/rules coverage must continue to block `.env` and private-key reads plus escalation-capable destructive/deploy/database commands.
- Generated apps must continue to use only documented public env contracts.

## Failure And Rollback

- If validator refactors introduce false positives, fix the manifest or pointer assertions rather than restoring duplicated truth.
- If generated-app checks fail because template references moved, fix the generator/test contract before weakening the expectation.
- If a deleted dormant hook turns out to have a real consumer, restore it only with an actual config event registration and test coverage.

## Verification

Run available checks through:

```powershell
../../scripts/verify-app.ps1 -ProjectPath .
```

Pre-completion artifact checks:

- `../../scripts/analyze-spec.ps1 -ProjectPath .`
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`

Additional closeout checks:

- `./scripts/check-all.ps1`
- `../../scripts/verify-app.ps1 -ProjectPath .`

Verification result:

- `../../scripts/analyze-spec.ps1 -ProjectPath .` passed on 2026-07-09.
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` passed on 2026-07-09.
- `./scripts/check-all.ps1` passed on 2026-07-09.
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` passed on 2026-07-09.
- `../../scripts/verify-app.ps1 -ProjectPath .` passed on 2026-07-09: `typecheck`, `lint`, `test`, `build`, and `e2e` all passed. The earlier transient `mobile-390` WebKit launch failure did not reproduce on rerun.

## Handoff Notes

Record the verify-before-finish deletion decision, manifest adoption, template CI relocation, and any remaining policy-layer follow-up that moves to slice `007`.
