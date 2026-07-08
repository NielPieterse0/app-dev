# Signal Task Plan

- Created: 2026-07-08
- Template: react-vite-capacitor
- Active spec: `specs/002-live-settings/spec.md`
- Status: complete

## Goal

Deliver Slice 2: converge the app-dev harness around the defects exposed by Signal, then enable Signal's first browser-safe Supabase persistence path for source and keyword settings.

## Non-Goals

- Live scheduled ingestion
- multi-user auth or sharing
- public launch readiness
- native platform packaging
- additional sources beyond GitHub and Hacker News
- live source ingestion or scheduled jobs
- persisted source items
- speculative overlay or manifest-based assembly work
- auth, sharing, or multi-user settings

## Spec Link

- Spec id: `002-live-settings`
- Spec path: `specs/002-live-settings/spec.md`
- Tasks path: `specs/002-live-settings/tasks.md`
- Workflow receipts path: `specs/002-live-settings/workflow-receipts.md`
- Checklist path: `specs/002-live-settings/checklist.md`
- Detailed implementation plan: `../../docs/superpowers/plans/2026-07-08-signal-slice-2.md`

## Architecture Decision

- App type: React + Vite + React Router with the existing Capacitor-ready shell retained but unused for native packaging in this slice.
- Routing model: two primary routes, `/` for the ranked dashboard and `/settings` for source and keyword controls; remove auth-protected demo routes from the template.
- State/data strategy: Zod schemas for source normalization, TanStack Query for persisted source-settings state, Zustand for transient dashboard/settings draft inputs, and a repository layer that supports configured Supabase reads/writes plus an explicit local fallback.
- Backend/auth/storage: Supabase persistence is the target backend from day one; browser code may use only publishable keys. This slice adds migrations and browser-safe env handling, but stays no-auth and internal.
- UI system: keep the template’s operational layout patterns, state primitives, and Tailwind utility approach; adapt the dashboard into a dense trend-review surface rather than redesigning the app shell.
- Implementation constraints: free-tier-first, no service-role secrets, module-boundary lint rules preserved, UI/data/release-readiness workflows required, and source/API terms must be tracked in checklist and handoff notes.

## Module Plan

| Module | Responsibility | Main files | Verification |
| --- | --- | --- | --- |
| `sources` | Preserve source normalization and add a Supabase-backed settings repository with explicit local fallback | `src/modules/sources/**`, `supabase/migrations/002_live_source_settings.sql` | repository contract, query, fallback, and schema tests |
| `dashboard` | Display ranked items, summary metrics, filters, and trend activity surface | `src/modules/dashboard/**` | route/component tests, rendered checks |
| `settings` | Hydrate and persist source toggles and keyword filters with visible async/error state | `src/modules/settings/**` | route tests, mutation tests, rendered checks |

## Implementation Steps

1. Complete Slice 2A harness convergence and make all root governance checks pass.
2. Reconcile Signal identity, remove orphaned auth code, and activate spec 002.
3. Add the settings migration and deliberate RLS policy for the no-auth internal client boundary.
4. Implement the settings repository, query hooks, mutations, and deterministic unavailable-backend fallback.
5. Update the settings UI with pending, saved, fallback, and failure states.
6. Run `analyze-spec.ps1`, artifact checks, receipt validation, app verification, and rendered desktop/mobile checks.
7. Record each audit finding and backport candidate as fixed, deferred, rejected, or project-local.

## Risks and Assumptions

| Item | Type | Impact | Mitigation |
| --- | --- | --- | --- |
| Fixture-backed ingestion may hide live API shape issues | risk | medium | keep normalization strict with Zod and seed malformed-payload tests |
| Supabase env or dependency setup may be blocked locally | risk | medium | keep repository layer testable without live backend and record exact setup blockers |
| Template auth examples may leak into Signal UX | risk | low | remove protected demo routes and auth copy from the first slice |
| `001-initial` folder naming may diverge from the spec title | assumption | low | keep folder stable for validators and make the spec title explicit about Signal foundation |
| No-auth browser writes can be abused if the Supabase endpoint becomes public | risk | high | constrain the v2 policy to the documented internal MVP boundary; do not call it public-launch safe |
| Free-tier Supabase may pause after inactivity | risk | medium | expose unavailable state, retain local fallback, and avoid claiming always-on persistence |

## Data Security Posture

- `public.source_items` remains fixture-backed and is not exposed to browser writes in Slice 2.
- `public.source_settings` becomes browser-accessible only through the migration and policies reviewed in Slice 2B.
- Browser code may use only publishable Supabase keys. Service-role credentials are prohibited from client code, repo files, and local checked-in artifacts.
- RLS is mandatory before the Slice 2 settings client is enabled. A no-auth policy is an internal-MVP compromise, not a production authorization model.

## Failure And Rollback

- If the dashboard or settings slice regresses, revert to fixture-backed repository behavior and disable any incomplete Supabase wiring rather than attempting partial live reads.
- If migration review raises issues, do not apply the migration to a shared environment. Adjust the SQL locally and re-run project verification first.
- If bundle size or chart behavior degrades materially after additional sources are added, remove the new source adapter or chart surface before widening the slice.

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

- first meaningful dashboard screen
- source filter interaction
- desktop viewport
- mobile viewport
- no clipped, overlapping, or overflowing text

Pre-implementation artifact check:

- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
- `../../scripts/analyze-spec.ps1 -ProjectPath .`
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`

Verification result:

- 2026-07-08: `../../scripts/analyze-spec.ps1 -ProjectPath .`, `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`, and `../../scripts/verify-app.ps1 -ProjectPath .` all passed.
- 2026-07-08: root `check-workspace.ps1`, `validate-codex-assets.ps1 -RequirePythonToml:$true`, `test-hooks.ps1`, `test-workflow-enforcement.ps1`, `test-analyze-spec.ps1`, `test-workspace.ps1`, and `scan-secrets.ps1` all passed.

## Open Decisions

| Decision | Options | Owner | Status |
| --- | --- | --- | --- |
| Persistence read path for slice one | fixtures only vs hybrid repository with optional Supabase reads | Codex | resolved: hybrid-ready repository with fixture-backed reads in slice one |
| Keyword filtering shape | simple include keywords vs include/exclude sets | Codex | resolved: simple include-keyword filters for slice one |
| Scoring location | client-side scoring vs SQL view/function later | Codex | resolved: client-side scoring now, SQL view/function later if ingestion grows |
| Slice 2 persistence boundary | settings only vs settings and source items | Codex | resolved: settings only |
| Gated checklist rename | rename now vs preserve contract | Codex | resolved: preserve `checklist.md` during Slice 2A |

## Handoff Notes

Record deviations from this plan, skipped checks, source/API constraints, and app-dev backport candidates discovered during the slice.

- The first slice stayed fixture-backed for reads while adding the Supabase migration boundary; live persistence wiring is deferred.
- `verify-app.ps1` was more reliable than direct raw-shell Vite/Vitest commands in this Windows sandbox. The harness should standardize on wrapper verification or fix direct shell execution.
- The template currently pulls deprecated `recharts@2.15.4`; that is a control-repo hardening item.
- The initial dashboard bundle is already large enough to trigger a build warning, so additional sources and richer charts should be added only with bundle control in mind.
- Signal and future app-dev projects remain tracked in the same root repository unless a later recorded decision changes the repository model.
- Slice 2 is split into 2A harness convergence and 2B live settings persistence so each part can be reviewed and reverted independently.

## Audit Disposition

| Item | Disposition | Notes |
| --- | --- | --- |
| PowerShell CLI flags and workflow harness drift | fixed | Shared helpers, switch-style CLI flags, and contradiction analysis were added in Slice 2A |
| Signal auth scaffold residue | fixed | `src/modules/auth/` and the nested workflow were removed; package identity now matches Signal |
| Live Supabase project binding for rendered verification | deferred | The configured repository path is covered by unit tests; rendered verification stayed on the local fallback branch without checked-in secrets |
| Bundle-size warning from the dashboard build | deferred | Build passes, but the existing large client bundle should be reduced before adding more sources or richer charts |
