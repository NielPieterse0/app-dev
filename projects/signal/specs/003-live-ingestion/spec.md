# 003 Signal Live Ingestion Specification

- Status: complete
- Risk level: gated
- App: signal
- Created: 2026-07-08

## Summary

Complete Signal Slice 3 in two ordered lanes on one active spec: first harden the Slice 2 settings and workflow base, then replace the fixture-backed dashboard with a manual-refresh live ingestion flow backed by persisted source items.

## Requirements

1. Root workflow scripts must detect workflow obligations for committed trees through a base-ref aware path and remain testable through injected changed-file JSON.
2. Root CI must run contradiction analysis against the real Signal project artifacts, not only fixture tests.
3. Root secret scanning must cover `projects/signal` while still excluding disposable verification folders and known noisy build outputs.
4. Signal settings writes must move behind one transactional persistence boundary and stop depending on two independent browser upserts.
5. Signal settings hydration must not overwrite unsaved draft edits during query refresh or route re-entry.
6. Signal settings save failures after a configured load must degrade to an explicit local fallback path instead of dropping the user's draft.
7. Signal must remove the eager browser env export that can crash boot on malformed optional Supabase values and must scope settings refetch behavior away from window-focus clobbering.
8. Dashboard source filters must expose active-state affordance and accessible pressed semantics, and the activity chart must use the intended color tokens.
9. Signal must ingest real GitHub and Hacker News items through explicit source adapters and a manual refresh path before any scheduler or background job is introduced.
10. Signal must persist normalized source items and read the ranked dashboard from persisted source-item data rather than fixture-backed runtime truth.
11. No service-role key, auth system, public launch posture, background scheduler, or broad performance refactor may be added in this slice.

## Acceptance Criteria

1. `scripts/get-workflow-obligations.ps1` supports committed-tree comparison through a base ref or merge base, and root workflow tests cover that detector path.
2. `.github/workflows/app-dev-validation.yml` runs `scripts/analyze-spec.ps1 -ProjectPath projects/signal` in CI.
3. `scripts/scan-secrets.ps1` scans Signal project files and still ignores disposable verification folders under `projects/`.
4. Settings repository tests cover RPC-backed save behavior, local fallback save symmetry, and factory-local fallback state.
5. Settings route tests cover draft-preserving hydration, degraded save behavior, and route-layer rejection handling.
6. Dashboard tests cover active filter semantics, refresh affordance, and the empty/live states driven by persisted items.
7. Live-source adapter tests cover GitHub and Hacker News contract parsing with mocked network responses.
8. Source-item persistence uses Supabase-backed storage when configured, local fallback when unavailable, and records the degraded state honestly.
9. Typecheck, lint, test, build, e2e, artifact checks, receipt validation, and root governance checks are recorded against this active spec.

## Data And Permissions

- Personal data: none.
- Stored data: public-source metadata, ranked source items, and single-operator source and keyword preferences.
- Client credentials: Supabase URL and publishable key only.
- Authorization: no-auth internal MVP. Browser writes remain explicitly not production-ready and block any public-launch claim.
- External APIs: public GitHub and Hacker News read paths only.
- Retention: source items reflect the latest manual refresh batch; settings persist until replaced or explicitly reset.

## Clarifications

- Manual refresh is the only live ingestion trigger in this slice.
- Live integration verification may use a disposable or local Supabase environment only; do not target a production project.
- If live Supabase credentials or tooling are unavailable in the current environment, the gap must be recorded explicitly rather than described as verified.

## Verification Intent

- Root: `./scripts/check-workspace.ps1`, `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`, `./scripts/test-hooks.ps1`, `./scripts/test-workflow-enforcement.ps1`, `./scripts/test-analyze-spec.ps1`, `./scripts/test-workspace.ps1`, and `./scripts/scan-secrets.ps1`.
- Spec: `../../scripts/analyze-spec.ps1 -ProjectPath .`, `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, and `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
- App: `../../scripts/verify-app.ps1 -ProjectPath .` plus rendered dashboard/settings checks at desktop and mobile widths.
