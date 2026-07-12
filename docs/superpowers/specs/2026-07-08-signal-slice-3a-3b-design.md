# Signal Slice 3A and 3B Design

Date: 2026-07-08
Status: Proposed

## Purpose

Signal Slice 3 must be split into two implementation slices:

- **Slice 3A** closes the verified correctness, security, and harness weaknesses surfaced after Slice 2.
- **Slice 3B** converts Signal from a fixture-backed dashboard into a real ingestion-backed trend-scouting product.

This split prevents live data work from landing on top of a persistence path and governance layer with known integrity and coverage gaps.

## Why A 3A and 3B Split

Slice 2 proved that Signal can persist settings and that the root harness can enforce more of the app-dev workflow. The attached reviews also showed that several of the strongest claims from Slice 2 are still conditional:

- Supabase writes are not transaction-safe.
- The live Supabase path has no real integration verification.
- Secret scanning and workflow-obligation detection have coverage gaps in the harness.
- Several app-level correctness issues remain in dashboard rendering and settings-state behavior.

If Slice 3 goes directly to live ingestion, those weaknesses become the base pattern for the first real data slice and are likely to be copied into future projects. Slice 3A exists to close that risk before Slice 3B widens product scope.

## Scope Strategy

### Slice 3A: Hardening and Finding Closeout

Slice 3A is a **stabilization slice**. It should not change Signal's product promise beyond making the current dashboard/settings workflow safer, more accurate, and more honestly verified.

Primary outcomes:

1. Close applicable attached findings and recommendations.
2. Add real verification for the configured Supabase settings path.
3. Make the harness enforce the documented gates on committed trees and project files, not only in the authoring window.
4. Fix app-level correctness issues already identified in dashboard, env, and query behavior.
5. Record every remaining out-of-scope item explicitly as deferred rather than leaving it ambiguous.

### Slice 3B: Live Ingestion and Persisted Feed

Slice 3B is the first **product-widening slice** after the hardening pass. It should add a narrow, real ingestion workflow while keeping larger platform concerns deferred.

Primary outcomes:

1. Add real GitHub and Hacker News source adapters.
2. Persist normalized source items into Supabase-backed `source_items`.
3. Switch the dashboard from fixture-backed reads to persisted source-item reads.
4. Add a manual refresh/update path first.
5. Preserve the existing no-auth, internal-only, free-tier-first boundary.

## Capability Routing

The local app-dev workflows remain the enforceable base contract. External plugins are accelerators and reviewers that must be recorded in workflow receipts when used or unavailable.

### Slice 3A

- `cross-platform-app-workflow`: required umbrella workflow.
- `data-change-workflow`: required for Supabase RPC, migration, RLS, verification, and repository changes.
- `ui-change-workflow`: required for dashboard fixes and settings-state behavior updates.
- `release-readiness-workflow`: required because this slice is primarily about verification truthfulness, security posture, and gate coverage.
- Supabase plugin: review RPC/migration/RLS design and test strategy.
- Codex Security plugin: review transaction safety, anon-write posture, secret-scan coverage, and CI enforcement.
- Build Web Apps plugin: review app-shell/query/UI fixes when they touch reusable frontend patterns.

### Slice 3B

- `cross-platform-app-workflow`: required umbrella workflow.
- `data-change-workflow`: required for adapters, persistence, source schemas, and ingestion updates.
- `ui-change-workflow`: required for dashboard state, refresh UX, loading/error surfaces, and rendered verification.
- `release-readiness-workflow`: required because live source ingestion affects source/API terms, persistence, and product truthfulness.
- Supabase plugin: review source-item persistence shape and operational implications.
- Build Web Data Visualization plugin: review dashboard presentation against real data volume and chart/table decisions.
- Build Web Apps plugin: review module boundaries, route behavior, and rendered UX under live data conditions.

## Attached Findings To Slice Mapping

### Included In Slice 3A

The following findings are directly related to hardening the current slice and must be closed or explicitly dispositioned in Slice 3A:

1. **Transaction safety for settings writes**
   - Current two-step upsert can partially commit.
   - Fix by moving the write path into a single Postgres RPC or equivalent transactional boundary.

2. **Real Supabase-path verification**
   - Add at least one real migration-apply plus configured read/write smoke path.
   - This may use a throwaway Supabase project, a local Supabase stack, or another bounded non-production environment.

3. **Secret scan coverage for `projects/signal`**
   - Narrow the current blanket `projects/` exclusion.
   - Ensure root and/or project-local secret scanning actually scans Signal files.

4. **Workflow-obligation detection on committed trees**
   - Move `get-workflow-obligations.ps1` from uncommitted-only diff logic to a base-ref/merge-base-aware model.
   - Add real tests for the obligations detector itself.

5. **CI enforcement of contradiction analysis**
   - Run `analyze-spec.ps1` against real project content in CI, not only fixture tests.

6. **Receipt-verification contradiction regex drift**
   - Consolidate placeholder/verification contradiction detection through shared helpers.

7. **Settings hydration overwriting unsaved edits**
   - Prevent background query refresh or route hydration from stomping local unsaved draft state.

8. **Local fallback symmetry on failed save**
   - If Supabase save fails after a configured load, preserve the current draft and save locally with explicit degraded state.

9. **Unreachable/no-op query error effect**
   - Remove or rewire the dead `query.error` effect.

10. **Unhandled save rejection in the settings route**
   - Catch rejected save promises at the route layer so console behavior matches UI behavior.

11. **Local repository instance leakage**
   - Move module-level in-memory fallback state into factory-local state.

12. **Dashboard chart CSS variable mismatch**
   - Fix the Hacker News color token mismatch and add test coverage for the intended line color.

13. **Dashboard source-filter UX**
   - Add active-state affordance and accessible pressed-state semantics to source filter controls.

14. **Unsafe eager `env` export**
   - Remove or guard the eager export so malformed environment values cannot crash app boot unnecessarily.

15. **QueryClient default refetch policy**
   - Scope or disable `refetchOnWindowFocus` for settings-sensitive flows to avoid clobbering draft state.

16. **Signal CI/verification truthfulness wording**
   - Update artifacts/receipts so "verified" language differentiates mocked validation from real integration validation when relevant.

17. **No-auth anon-write posture guardrail**
   - Keep the internal-MVP RLS model for now, but add a governance rule/checklist/CI rule that prevents this pattern from being treated as production-ready or silently cloned into a public-ready slice.

18. **Bundle/perf item only where clearly coupled**
   - Include only the correctness-adjacent bundle warning work needed to keep Slice 3A honest and bounded.
   - This means measuring and documenting the current bundle issue, not a broad charting/perf refactor.

### Deferred Explicitly Beyond Slice 3A

These items are related, but not tightly enough coupled to justify inclusion in the hardening slice:

1. **Recharts replacement or major chart-library migration**
   - Keep as a later targeted perf/visualization decision unless a 3A fix proves Recharts is the blocker.

2. **Atomic migration from `checklist.md` to a renamed contract**
   - Still too broad for this slice.

3. **Auth, public launch, multi-user RLS, sharing**
   - Remain out of scope until after live ingestion exists.

4. **Large-scale bundle optimization or route-level code splitting**
   - Document now; perform later unless a 3A correctness fix requires a specific small change.

5. **Scheduled/background ingestion**
   - Belongs to a later slice after manual refresh and persisted live feed are working.

## Slice 3A Architecture

### Root Harness Lane

Files likely affected:

- `scripts/get-workflow-obligations.ps1`
- `scripts/test-workflow-enforcement.ps1`
- `scripts/validate-workflow-receipts.ps1`
- `scripts/analyze-spec.ps1`
- `scripts/common.ps1`
- `scripts/scan-secrets.ps1`
- `.github/workflows/app-dev-validation.yml`
- `projects/signal/specs/**` and receipts where verification wording changes

Key design decisions:

1. **Base-ref aware obligations**
   - Introduce a deterministic changed-file mode that can compare against a base ref or merge-base for committed work.
   - Preserve explicit `-ChangedFilesJson` injection for tests and controlled workflows.

2. **Shared contradiction helpers**
   - Move repeated placeholder/verification classification logic into `common.ps1`.
   - Keep one canonical definition of "placeholder verification evidence" and "gated risk."

3. **Project-tree secret scan**
   - Replace blanket `projects/` exclusion with targeted noisy-path exclusion.
   - Ensure generated disposable verification folders remain excluded.

4. **Real CI gate use**
   - CI must execute contradiction analysis against `projects/signal`, not only fixture tests.

### Signal Settings/Supabase Lane

Files likely affected:

- `projects/signal/supabase/migrations/002_live_source_settings.sql`
- `projects/signal/src/modules/sources/services/supabase-source-settings-repository.ts`
- `projects/signal/src/modules/sources/services/local-source-settings-repository.ts`
- `projects/signal/src/modules/sources/hooks/useSourceSettings.ts`
- `projects/signal/src/modules/sources/state/source-preferences-store.ts`
- `projects/signal/src/modules/settings/routes/SettingsRoute.tsx`
- `projects/signal/src/lib/env.ts`
- `projects/signal/src/lib/query-client.ts`
- associated tests and e2e

Key design decisions:

1. **Transaction-safe settings persistence**
   - Prefer a single RPC such as `save_signal_settings(...)` that updates both `source_settings` and `signal_preferences` inside one transaction.
   - Keep row validation on the client boundary even when RPC is used.

2. **Configured-path smoke verification**
   - Add a real migration-apply and configured settings read/write smoke path.
   - Keep it bounded to test or disposable infrastructure only.

3. **Degraded save semantics**
   - Save failure after a previously healthy configured load must degrade to local fallback, not only error.

4. **Draft hydration discipline**
   - Hydrate draft state on initial load and after successful save or explicit reset, not on every refetch.

### Signal Dashboard/App Lane

Files likely affected:

- `projects/signal/src/modules/dashboard/routes/DashboardRoute.tsx`
- `projects/signal/src/modules/dashboard/components/SourceActivityChart.tsx`
- `projects/signal/src/modules/dashboard/tests/**`
- `projects/signal/src/lib/env.ts`
- `projects/signal/src/lib/query-client.ts`

Key design decisions:

1. **Fix current correctness defects first**
   - color token mismatch
   - filter active state/accessibility
   - env boot-risk cleanup

2. **Do not redesign the dashboard**
   - Slice 3A is a correctness pass, not a visual redesign.

## Slice 3A Verification Model

Slice 3A is complete only when all of the following are true:

1. Root harness tests pass, including the real obligations path.
2. Secret scanning actually covers `projects/signal`.
3. CI runs contradiction analysis against real Signal artifacts.
4. Real Supabase-path verification has been executed and recorded.
5. Settings write behavior is transaction-safe or the remaining limitation is explicitly recorded and tested.
6. Dashboard/env/query correctness issues have regression tests where practical.
7. Workflow receipts distinguish mocked verification from real integration verification clearly and accurately.

## Slice 3B Architecture

Slice 3B should start only after 3A closes or explicitly re-dispositions the hardening issues above.

### Source Ingestion Lane

Files likely affected:

- `projects/signal/src/modules/sources/services/source-repository.ts`
- new GitHub and Hacker News adapter/service files
- source normalization/schema files
- `supabase/migrations` for `source_items` evolution only if needed

Key design decisions:

1. **Manual refresh first**
   - Add explicit user-triggered ingestion/update before any scheduler or background job.

2. **Adapter isolation**
   - GitHub and Hacker News fetch logic should live in source-specific adapters.
   - Normalization remains shared and strictly validated.

3. **Persist then read**
   - Dashboard reads from persisted normalized data, not directly from live APIs.

### Dashboard/Product Lane

Files likely affected:

- `projects/signal/src/modules/dashboard/**`
- `projects/signal/src/modules/settings/**` only where live-source preferences affect ingestion

Key design decisions:

1. **Replace fixture-backed truth**
   - Remove or narrow the "fixture-backed feed" contract once live data is present.

2. **Keep scoring local unless scale forces otherwise**
   - Preserve client-side scoring unless real data proves that SQL-side aggregation is needed.

3. **Add operational states**
   - stale data
   - refresh in progress
   - refresh failed
   - partial-source failure

## Slice 3B Verification Model

Slice 3B is complete only when:

1. GitHub and Hacker News adapters both have contract tests.
2. A manual refresh path persists normalized items to Supabase successfully.
3. Dashboard reads persisted source items rather than fixtures.
4. Rendered checks cover refresh, mixed-source display, empty/error states, and mobile/desktop behavior.
5. Source/API terms obligations are documented in the active spec/checklist/receipts.

## Findings Disposition Table

| Review area | 3A | 3B | Deferred beyond 3B |
| --- | --- | --- | --- |
| Settings write transaction safety | yes | no | no |
| Real Supabase verification for current settings path | yes | no | no |
| Secret scan coverage gap | yes | no | no |
| Obligations detection on committed trees | yes | no | no |
| CI contradiction gate against real content | yes | no | no |
| Verification regex/helper drift | yes | no | no |
| Settings draft overwrite on refetch | yes | no | no |
| Save fallback symmetry | yes | no | no |
| Dead query error logic | yes | no | no |
| Unhandled save rejection | yes | no | no |
| Local fallback state leakage | yes | no | no |
| Chart color mismatch | yes | no | no |
| Dashboard active filter affordance | yes | no | no |
| Eager env boot-crash risk | yes | no | no |
| QueryClient refetch default for settings flow | yes | no | no |
| Broad bundle/perf refactor | no | no | yes |
| Recharts replacement/migration | no | no | yes |
| Live ingestion adapters | no | yes | no |
| Persisted `source_items` feed | no | yes | no |
| Manual refresh flow | no | yes | no |
| Scheduled/background ingestion | no | no | yes |
| Auth/public launch/multi-user model | no | no | yes |
| `checklist.md` contract migration | no | no | yes |

## Recommended Implementation Order

1. Write a `3A` spec and implementation plan first.
2. Execute and verify `3A` to closure.
3. Re-run attached-finding confirmation against the live tree after `3A`.
4. Only then write the `3B` implementation plan against the hardened base.

## Deferred Beyond Slice 3

- Scheduled/background ingestion
- Auth and public-launch readiness
- Multi-user RLS and sharing
- Recharts migration or major visualization library replacement
- Broad bundle/performance refactor not directly required by a 3A fix
- Atomic migration away from `checklist.md`

## Recommendation

Proceed with **Slice 3A first** using the balanced hardening scope above, then use the closed 3A base to implement **Slice 3B** as the first real ingestion/product slice.
