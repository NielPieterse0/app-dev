# 002 Signal Live Settings Specification

- Status: complete
- Risk level: gated
- App: signal
- Created: 2026-07-08

## Summary

Use Signal's first live Supabase settings path to prove the corrected app-dev harness. Persist source toggles and keyword filters while preserving an explicit local fallback when the free-tier backend is missing, paused, or unavailable.

## Requirements

1. Root workflow scripts must support documented switch-style invocation and share canonical risk/path/failure helpers.
2. A required analysis gate must detect stale status, missing gated artifacts, false-complete removal tasks, and missing verification evidence.
3. Root CI must validate app-dev and the tracked Signal project.
4. Signal must remove orphaned auth code and template package identity.
5. Signal must persist source toggles and keyword filters through a browser-safe Supabase repository when configured.
6. Signal must remain usable with a clearly disclosed local fallback when Supabase is unavailable.
7. RLS must be enabled and reviewed before browser reads or writes are active.
8. No service-role key, auth system, new source adapter, or scheduled ingestion may be added.

## Acceptance Criteria

1. Root governance checks and harness regression tests pass.
2. `scripts/analyze-spec.ps1 -ProjectPath projects/signal` passes this artifact set and fails contradiction fixtures.
3. Root GitHub Actions installs and verifies Signal from `projects/signal`.
4. Settings hydrate from Supabase, save through mutations, and show pending, saved, fallback, and error states.
5. Repository tests cover configured success, malformed rows, query failure, and unconfigured fallback.
6. The migration enables RLS and contains no permissive policy described as production-safe.
7. `src/modules/auth/` is absent and `package.json` identifies Signal.
8. Typecheck, lint, test, build, e2e, desktop/mobile rendered checks, receipt validation, and secret scan are recorded.

## Data And Permissions

- Personal data: none.
- Stored data: public source identifiers plus single-operator source and keyword preferences.
- Client credentials: Supabase URL and publishable key only.
- Authorization: no-auth internal MVP; policies must be reassessed before public deployment, sharing, or multi-user use.
- Retention: settings persist until replaced or explicitly reset; source-item retention remains out of scope.

## Clarifications

- Live Supabase project identity and publishable key: not bound in this repo verification run; configured Supabase reads and writes are covered by repository tests while rendered verification exercised the local fallback path.
- Public deployment: excluded.
- Production-grade anonymous write protection: excluded because auth is excluded; this blocks public launch.

## Verification Intent

- Root: `./scripts/check-workspace.ps1`, `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`, `./scripts/test-hooks.ps1`, `./scripts/test-workflow-enforcement.ps1`, `./scripts/test-workspace.ps1`, and `./scripts/scan-secrets.ps1`.
- Spec: `../../scripts/analyze-spec.ps1 -ProjectPath .`, `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, and `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
- App: `../../scripts/verify-app.ps1 -ProjectPath .` plus desktop and mobile rendered settings-flow checks.
