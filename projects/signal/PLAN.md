# Signal Task Plan

- Created: 2026-07-08
- Template: react-vite-capacitor
- Active spec: `specs/003-live-ingestion/spec.md`
- Status: complete

## Goal

Deliver Signal Slice 3 completely: harden the settings and workflow base from Slice 2, then replace the fixture-backed dashboard with a manual-refresh live-ingestion product backed by persisted source items.

## Non-Goals

- scheduled or background ingestion
- auth, sharing, or multi-user access
- public-launch readiness
- native platform packaging
- additional sources beyond GitHub and Hacker News
- broad bundle optimization or chart-library replacement
- service-role or backend secrets in the client

## Spec Link

- Spec id: `003-live-ingestion`
- Spec path: `specs/003-live-ingestion/spec.md`
- Tasks path: `specs/003-live-ingestion/tasks.md`
- Workflow receipts path: `specs/003-live-ingestion/workflow-receipts.md`
- Checklist path: `specs/003-live-ingestion/checklist.md`
- Detailed design reference: `../../docs/superpowers/specs/2026-07-08-signal-slice-3a-3b-design.md`

## Architecture Decision

- App type: React + Vite + React Router with the existing Capacitor-ready shell retained but unused for native packaging in this slice.
- Routing model: keep `/` as the ranked dashboard and `/settings` for source and keyword controls; widen the dashboard with a manual refresh workflow instead of adding new routes.
- State/data strategy: Zod schemas remain the normalization contract; TanStack Query owns persisted settings and persisted source-feed reads; Zustand owns transient dashboard filter state and settings drafts without allowing background hydration to overwrite dirty edits.
- Backend/auth/storage: Supabase remains the target persistence backend with publishable browser keys only. Transactional browser-write paths move behind bounded RPCs, and the no-auth posture stays explicitly internal-MVP only.
- Feed architecture: live GitHub and Hacker News adapters fetch public data, normalize it client-side, and persist the latest batch through repository abstractions that support configured Supabase storage plus explicit local fallback persistence.
- UI system: preserve the existing Signal shell and operational layout patterns. Slice 3 fixes correctness and adds refresh/live-state UX rather than redesigning the product surface.
- Implementation constraints: free-tier-first, no service-role secrets, module-boundary lint rules preserved, UI/data/release-readiness workflows required, source/API terms tracked in the active checklist, and live-integration verification recorded honestly when tooling or credentials are unavailable.

## Module Plan

| Module | Responsibility | Main files | Verification |
| --- | --- | --- | --- |
| `sources` | own settings RPC persistence, live adapters, persisted source-item repositories, and refresh orchestration | `src/modules/sources/**`, `supabase/migrations/003_signal_live_ingestion.sql` | repository, adapter, hook, and migration contract tests |
| `dashboard` | display persisted ranked items, refresh state, source filters, and trend activity with corrected semantics | `src/modules/dashboard/**` | route/component tests and rendered checks |
| `settings` | preserve draft edits, save through the transactional path, and disclose degraded fallback honestly | `src/modules/settings/**` | route tests and rendered checks |
| `root harness` | enforce base-ref workflow obligations, project-tree secret scanning, and real-project contradiction analysis in CI | `scripts/**`, `.github/workflows/app-dev-validation.yml` | root script tests and governance checks |

## Implementation Steps

1. Activate spec 003 and align Signal planning artifacts with the combined Slice 3 scope.
2. Harden root workflow enforcement with base-ref aware obligation detection, committed-tree tests, and real Signal contradiction analysis in CI.
3. Narrow secret-scan exclusions so `projects/signal` is scanned while disposable verification folders remain ignored.
4. Add a new Supabase migration that introduces transactional settings RPC writes plus persisted source-item storage and replacement RPCs.
5. Refactor Signal settings repositories, query behavior, and draft state so unsaved edits are not clobbered and configured save failures degrade to local fallback.
6. Remove eager env parsing at import time and scope query refetch behavior to avoid settings regressions.
7. Fix dashboard filter semantics and chart token correctness without redesigning the app shell.
8. Add live GitHub and Hacker News adapters, manual refresh orchestration, and persisted source-item repositories.
9. Switch the dashboard read path from fixtures to persisted source items with explicit empty, degraded, and refresh states.
10. Run artifact gates, app verification, and root governance checks; record live-integration blockers honestly if disposable Supabase infrastructure is unavailable.

## Risks and Assumptions

| Item | Type | Impact | Mitigation |
| --- | --- | --- | --- |
| Public API shape drift can break adapters | risk | medium | keep adapter normalization strict and cover parsing with mocked contract tests |
| Disposable Supabase infrastructure may be unavailable in-session | risk | medium | keep repository logic testable without live backend and record the exact integration blocker |
| No-auth browser writes remain unsafe for public launch | risk | high | route all writes through bounded RPCs, keep the policy internal-only, and enforce explicit non-production wording in artifacts |
| Manual refresh can return zero items for some public-source windows | assumption | low | treat empty feed as a valid state with a clear refresh message |
| Bundle size remains elevated with Recharts and live adapters | risk | low | keep scope narrow and defer broader optimization unless a correctness fix requires it |

## Data Security Posture

- `public.source_settings` and `public.signal_preferences` stay browser-readable for the internal MVP, but writes move behind a transactional RPC boundary.
- `public.source_items` stores normalized public-source data for the latest manual refresh batch and is browser-readable for the internal MVP.
- Browser code may use only publishable Supabase keys. Service-role credentials remain prohibited from client code, repo files, and checked-in artifacts.
- The no-auth policy remains an internal-MVP compromise that blocks any public-launch or production-readiness claim.

## Failure And Rollback

- If the live-ingestion path regresses, keep the persisted local fallback repository path and disable the failing configured repository behavior rather than restoring fixture-backed runtime truth.
- If migration review raises issues, do not apply the migration to any shared environment. Adjust the SQL locally and re-run project verification first.
- If public API rate limits or adapter parsing fail, surface the failure in the dashboard refresh state and preserve the last persisted batch.

## Verification

Run available checks through:

```powershell
../../scripts/verify-app.ps1 -ProjectPath .
```

Expected project checks:

```text
npm run typecheck
npm run lint
npm run test
npm run build
npm run e2e
```

Rendered UI checks:

- first meaningful dashboard state
- manual refresh affordance and source-filter interaction
- desktop viewport
- mobile viewport
- no clipped, overlapping, or overflowing text

Pre-completion artifact checks:

- `../../scripts/analyze-spec.ps1 -ProjectPath .`
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`

Verification result:

- 2026-07-08: `../../scripts/analyze-spec.ps1 -ProjectPath .`, `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`, and `../../scripts/verify-app.ps1 -ProjectPath .` passed after the Slice 3 implementation changes.
- 2026-07-08: root `check-workspace.ps1`, `validate-codex-assets.ps1 -RequirePythonToml:$true`, `test-hooks.ps1`, `test-workflow-enforcement.ps1`, `test-analyze-spec.ps1`, `test-workspace.ps1`, and `scan-secrets.ps1` passed after the root harness changes.
- 2026-07-08: disposable-environment Supabase migration application and read/write smoke verification were not executable in-session because no disposable project credentials or local Supabase stack were available; repository and RPC behavior were instead covered by unit and integration-style tests.

## Open Decisions

| Decision | Options | Owner | Status |
| --- | --- | --- | --- |
| Persisted feed replacement boundary | table writes vs transactional RPC | Codex | resolved: transactional RPC replaces the full source-item batch |
| Dashboard default state without stored items | fixtures vs empty state with manual refresh | Codex | resolved: empty state with manual refresh |
| Adapter execution mode | automatic on load vs manual refresh | Codex | resolved: manual refresh only |
| Settings draft hydration policy | hydrate on every query vs preserve dirty drafts | Codex | resolved: preserve dirty drafts until explicit save or reset |

## Handoff Notes

Record deviations from this plan, skipped checks, source/API constraints, and app-dev backport candidates discovered during the slice.

- Live-source verification remains honest about the difference between mocked/unit coverage and disposable-environment integration coverage.
- The dashboard is no longer fixture-backed at runtime; empty-state onboarding is now the first-run path until a refresh persists live items.
- The app still carries the existing Recharts dependency and build-size warning; broader visualization or bundle work remains deferred.
- Signal remains tracked in the root `app-dev` repository unless a later recorded decision changes the repository model.

## Audit Disposition

| Item | Disposition | Notes |
| --- | --- | --- |
| Transaction safety for settings writes | fixed | settings writes now run through an RPC boundary |
| Real-project contradiction analysis in CI | fixed | CI now analyzes `projects/signal` directly |
| Secret scan coverage gap for `projects/signal` | fixed | root scan covers the project while still excluding disposable verification folders |
| Settings draft overwrite on refetch | fixed | draft hydration preserves dirty local edits |
| Degraded save fallback symmetry | fixed | configured save failures fall back locally with explicit degraded state |
| Dashboard chart token mismatch and filter semantics | fixed | chart uses intended token names and filters expose active semantics |
| Fixture-backed dashboard truth | fixed | manual refresh persists live source items and dashboard reads the persisted batch |
| Disposable Supabase migration/smoke execution | deferred | bounded live integration remains blocked by unavailable disposable credentials or local stack in this session |
