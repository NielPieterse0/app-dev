# Signal Task Plan

- Created: 2026-07-09
- Template: react-vite-capacitor
- Active spec: `specs/007-code-script-closeout/spec.md`
- Status: in progress

## Goal

Close the remaining script, CI, and release-gate defects surfaced by the 2026-07-09 review cycle so Signal and the control-workspace harness are portable, diagnosable, and aligned with the adopted scripting standard.

## Non-Goals

- manifest refactor and workflow-spine changes deferred to `specs/006-harness-consolidation/`
- new Signal product features, source ingestion changes, auth/RLS hardening, or dashboard UX work
- repo splitting, matrix auto-discovery before a second tracked app exists, or broader wrapper-skill consolidation beyond the helpers directly required for this slice
- public-launch auth/RLS hardening

## Spec Link

- Spec id: `007-code-script-closeout`
- Spec path: `specs/007-code-script-closeout/spec.md`
- Tasks path: `specs/007-code-script-closeout/tasks.md`
- Workflow receipts path: `specs/007-code-script-closeout/workflow-receipts.md`
- Checklist path: `specs/007-code-script-closeout/checklist.md`
- Audit source: `../../docs/audit/2026-07-09-app-dev-signal-review-findings.md`
- Background source: `../../standards/workspace.md` and the 2026-07-09 harness audit attached to slice creation

## Architecture Decision

- Hosted CI on `ubuntu-latest` is the portability referee; local Windows verification is supporting evidence only.
- Shared script helpers belong in `scripts/common.ps1` and are consumed by validators instead of being copied across files.
- Portability gates ship with the fixes: regex-based lint plus PSScriptAnalyzer run before the broader workspace validation steps.
- Signal's release-readiness gate remains intentionally fail-closed for anonymous browser-write access until a later auth/RLS slice removes that posture.
- Existing template and Signal app parity stays explicit and recorded when this slice confirms it rather than changing behavior.

## Module Plan

| Surface | Responsibility | Main files | Verification |
| --- | --- | --- | --- |
| `shared-script-helpers` | remove separator and helper drift across common validator surfaces | `scripts/common.ps1`, `scripts/analyze-spec.ps1`, `scripts/validate-workflow-receipts.ps1`, `scripts/check-spec-artifacts.ps1` | harness tests + spec checks |
| `portability-and-ci` | eliminate Windows-only script behavior and harden CI diagnosis | `scripts/test-hooks.ps1`, `scripts/test-workflow-enforcement.ps1`, `scripts/get-workflow-obligations.ps1`, `.github/workflows/app-dev-validation.yml`, `scripts/lint-portability.ps1` | workspace validation + CI |
| `generator-and-verifier` | normalize script parameters and generated path conventions | `scripts/create-app.ps1`, `scripts/new-spec.ps1`, `scripts/verify-app.ps1` | targeted script runs + workspace tests |
| `release-and-security` | keep scanner and release gate behavior state-based and explicit | `scripts/scan-secrets.ps1`, `projects/signal/scripts/check-public-launch-readiness.ps1`, `docs/audit/2026-07-09-app-dev-signal-review-findings.md` | secret scan + release gate |
| `export-and-parity` | fix export staging semantics and record any template/app reconciliation | `scripts/export-workspace.ps1`, `projects/signal/src/lib/env.ts`, `projects/signal/src/components/layout/SettingsLayout.tsx` | export check + app verification |

## Implementation Steps

1. Make slice `007` the active Signal spec and keep AGENTS/PLAN/spec artifacts aligned to the actual remaining work.
2. Remove Windows-only path and shell assumptions from the shared harness scripts and consolidate duplicated helpers into `common.ps1`.
3. Add the portability lint and analyzer gate, wire it into workspace CI, and tighten CI hygiene plus artifacts for diagnosis.
4. Normalize generator/verifier parameter semantics and generated script-path output.
5. Rework the release gate and export logic, then append the audit-ledger correction note and record parity verification.
6. Re-run Signal spec checks, workspace checks, and the strongest available app verification, then confirm hosted CI status on the pushed head.

## Risks And Assumptions

| Item | Type | Impact | Mitigation |
| --- | --- | --- | --- |
| Helper consolidation can change validator behavior in subtle ways | risk | high | keep the existing receipt/spec contracts intact and back changes with the existing harness tests |
| CI hygiene changes can mask the underlying app failure if artifact paths are wrong | risk | high | wire artifact upload before relying on it for diagnosis and inspect the produced paths locally |
| Switch-semantic cleanup can break existing call sites if names drift | risk | medium | preserve backward-compatible defaults where practical and update docs/callers in the same slice |
| Hosted CI remains the final referee, but local Windows verification cannot prove Linux portability | assumption | high | run local checks for fast feedback, then treat hosted CI as the closure gate |

## Data Security Posture

- No secrets, tokens, or private-key reads are introduced by this slice.
- Hook/rules coverage must continue to block `.env` and private-key reads plus escalation-capable destructive, deploy, and database commands.
- Generated apps must continue to use only documented public env contracts.

## Failure And Rollback

- If helper consolidation introduces false positives, fix the helper or its tests rather than copying logic back into multiple scripts.
- If CI still fails after the portability sweep, use the uploaded artifacts and logs to isolate the remaining failure before broadening scope.
- If the release gate rewrite misclassifies grant state, prefer a stricter fail-closed interpretation until the logic is corrected.

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

- `../../scripts/analyze-spec.ps1 -ProjectPath .` passed on 2026-07-10.
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` passed on 2026-07-10.
- `./scripts/check-all.ps1` passed on 2026-07-10.
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` passed on 2026-07-10.
- `../../scripts/verify-app.ps1 -ProjectPath .` passed on 2026-07-10: `typecheck`, `lint`, `test`, `build`, and `e2e` all passed.
- Hosted CI on the pushed head commit remains the final closure gate for this slice.

## Handoff Notes

Record the portability fixes, CI hygiene deltas, helper consolidations, release-gate behavior, and any hosted-CI-only gaps that remain after local verification.
