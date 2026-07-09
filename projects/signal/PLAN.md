# Signal Task Plan

- Created: 2026-07-09
- Template: react-vite-capacitor
- Active spec: `specs/004-concept-workbench/spec.md`
- Status: complete

## Goal

Complete Signal Slice 4 in two linked parts: first close the remaining Slice 3 verification and drift gaps, then add a concept workbench that promotes persisted live signals into durable product briefs with backend-neutral storage messaging.

## Non-Goals

- scheduled or background ingestion
- auth, sharing, or multi-user access
- public-launch readiness
- native platform packaging
- additional sources beyond GitHub and Hacker News
- broad bundle optimization or chart-library replacement
- service-role or backend secrets in the client
- direct repo mutation from inside the browser app

## Spec Link

- Spec id: `004-concept-workbench`
- Spec path: `specs/004-concept-workbench/spec.md`
- Tasks path: `specs/004-concept-workbench/tasks.md`
- Workflow receipts path: `specs/004-concept-workbench/workflow-receipts.md`
- Checklist path: `specs/004-concept-workbench/checklist.md`
- Detailed design reference: `../../docs/superpowers/specs/2026-07-09-signal-slice-4a-4b-design.md`

## Architecture Decision

- App type: React + Vite + React Router with the existing Capacitor-ready shell retained but unused for native packaging in this slice.
- Routing model: keep `/` as the ranked dashboard, `/settings` for source and keyword controls, and add `/concepts` as the concept workspace surface for promoted signals and export actions.
- State/data strategy: Zod remains the normalization contract; TanStack Query owns persisted settings, source-feed reads, and concept reads/writes; Zustand stays limited to transient dashboard view state and settings drafts.
- Backend/auth/storage: Supabase remains the default remote persistence backend with publishable browser keys only, but product-facing copy should describe generic remote storage versus local fallback unless the vendor is the actual point. The no-auth posture remains explicitly internal-MVP only.
- Feed architecture: live GitHub and Hacker News adapters remain manual-refresh only; concept promotion must derive from persisted source items rather than direct live API responses.
- Concept architecture: promoted signals persist as separate concept drafts with captured evidence snapshots, editable product-brief fields, and export helpers for Markdown and JSON handoff.
- UI system: preserve the existing Signal shell and operational layout patterns. Slice 4 adds inspect-first promotion, concept review/edit flows, and export actions without turning the app into a marketing or public-launch surface.
- Implementation constraints: free-tier-first, no service-role secrets, module-boundary lint rules preserved, UI/data/release-readiness workflows required, source/API terms tracked in the active checklist, and live integration verification recorded with exact proof level rather than implied by unit coverage alone.

## Module Plan

| Module | Responsibility | Main files | Verification |
| --- | --- | --- | --- |
| `sources` | own settings persistence, live adapters, persisted source-item repositories, and shared source metadata such as labels | `src/modules/sources/**`, `supabase/migrations/001-004*.sql` | repository, adapter, hook, and migration contract tests |
| `dashboard` | display persisted ranked items, inspect-first promotion affordances, refresh state, source filters, and trend activity | `src/modules/dashboard/**` | route/component tests and rendered checks |
| `concepts` | own concept schemas, persistence, promotion helpers, concept editing, and export payload generation | `src/modules/concepts/**`, `supabase/migrations/004_signal_concepts.sql` | repository, route, export, and persistence tests |
| `settings` | preserve draft edits, save through the transactional path, and disclose storage mode honestly without over-branding the vendor | `src/modules/settings/**` | route tests and rendered checks |
| `root/app docs` | reconcile stale slice wording, record live verification truthfully, and keep repo guidance aligned to the current Signal baseline | `README.md`, `projects/signal/**`, relevant `standards/**` | root script checks and artifact validation |

## Implementation Steps

1. Activate spec 004 and align Signal planning artifacts with the Slice 4 core-closeout plus concept-workbench scope.
2. Close the deferred Slice 3 live-backend blocker by applying the Signal migrations to the connected internal Supabase project and recording bounded smoke evidence.
3. Reconcile stale docs and receipts so the live repo no longer describes Slice 2-era or pre-ingestion behavior as current.
4. Add a new migration for concept persistence and evidence snapshots on top of the existing Signal schema.
5. Add remote and local-fallback concept repositories, query orchestration, and export helpers.
6. Add an inspect-first dashboard promotion flow that creates concept drafts from persisted source items.
7. Add a concept workspace route for review, editing, and export.
8. Replace unnecessary vendor-heavy product copy with backend-neutral storage messaging where the concern is generic remote persistence versus local fallback.
9. Standardize the small drift items touched during the slice, including shared source labels and mixed import patterns.
10. Run artifact gates, app verification, root governance checks, and live backend smoke verification; record exact proof levels and any remaining bounded limitations honestly.

## Risks and Assumptions

| Item | Type | Impact | Mitigation |
| --- | --- | --- | --- |
| Public API shape drift can break adapters and concept evidence quality | risk | medium | keep adapter normalization strict and preserve evidence snapshots at promotion time |
| The connected internal Supabase project may lag the repo schema | risk | medium | apply migrations deliberately, verify objects before app-level smoke claims, and record the exact environment used |
| No-auth browser writes remain unsafe for public launch | risk | high | keep RPC-backed boundaries, retain internal-only wording, and avoid any public-launch claim |
| Concept promotion can produce weak drafts if the signal is reviewed too quickly | risk | medium | keep inspect-first workflow, expose evidence details, and make drafts editable before export |
| Bundle size remains elevated with Recharts and the growing concepts UI | risk | low | keep scope narrow and defer broad visualization or bundle work unless a correctness fix requires it |

## Data Security Posture

- `public.source_settings` and `public.signal_preferences` stay browser-readable for the internal MVP, but writes remain behind a transactional RPC boundary.
- `public.source_items` stores normalized public-source data for the latest manual refresh batch and is browser-readable for the internal MVP.
- `public.signal_concepts` stores internal concept drafts and captured evidence snapshots for promoted signals, and browser writes remain internal-MVP only.
- Browser code may use only publishable Supabase keys. Service-role credentials remain prohibited from client code, repo files, and checked-in artifacts.
- The no-auth policy remains an internal-MVP compromise that blocks any public-launch or production-readiness claim.

## Failure And Rollback

- If the connected remote persistence path regresses, keep the explicit local fallback repository path and disable the failing configured repository behavior rather than restoring obsolete runtime assumptions.
- If migration review raises issues, do not apply the migration to any shared or public-facing environment. Adjust the SQL locally and re-run project verification first.
- If public API rate limits or adapter parsing fail, surface the failure in the dashboard refresh state and preserve the last persisted batch.
- If concept persistence fails remotely after promotion, degrade explicitly to the local fallback concept store rather than dropping the concept draft.

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
- inspect and concept-promotion affordance
- concept workspace list/detail flow
- concept export action
- desktop viewport
- mobile viewport
- no clipped, overlapping, or overflowing text

Pre-completion artifact checks:

- `../../scripts/analyze-spec.ps1 -ProjectPath .`
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`

Verification result:

- Completed on 2026-07-09. Local checks passed: `npm run typecheck`, `npm run lint`, `npm run test`, `npm run build`, `npm run e2e`, and `../../scripts/verify-app.ps1 -ProjectPath .`.
- Signal artifact checks passed: `../../scripts/analyze-spec.ps1 -ProjectPath .`, `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, and `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
- Root governance checks passed: `./scripts/check-workspace.ps1`, `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`, `./scripts/test-hooks.ps1`, `./scripts/test-workflow-enforcement.ps1`, `./scripts/test-analyze-spec.ps1`, `./scripts/test-workspace.ps1`, and `./scripts/scan-secrets.ps1`.
- Live Supabase verification passed against internal project `qwtfvuwkxtucgcteisfa` after applying migrations `001` through `004`. Smoke checks confirmed the settings, feed, and concept RPC paths with bounded test data.

## Open Decisions

| Decision | Options | Owner | Status |
| --- | --- | --- | --- |
| Concept evidence persistence shape | join table vs captured snapshot payload | Codex | resolved: captured snapshot payload |
| Concept review surface | dedicated route vs inline dashboard-only editor | Codex | resolved: dedicated `/concepts` route |
| Export handoff format | markdown only vs markdown plus JSON | Codex | resolved: markdown plus JSON |
| Storage-mode messaging | vendor-specific copy vs backend-neutral copy with targeted infra notes | Codex | resolved: backend-neutral copy with targeted infra notes |

## Handoff Notes

Record deviations from this plan, skipped checks, source/API constraints, and app-dev backport candidates discovered during the slice.

## Audit Disposition

| Item | Disposition | Notes |
| --- | --- | --- |
| Prior CI, repo-topology, and gated-validator findings | fixed | treat older attached findings as regression targets, not fresh defects |
| Signal README stale Slice 2 wording | fixed | reconciled during Slice 4A repo-surface drift pass |
| Backend-neutral product messaging | fixed | route-level and plan/spec copy now distinguishes generic remote storage from Supabase-specific setup notes |
| Disposable Supabase migration/smoke execution | fixed | completed against internal project `qwtfvuwkxtucgcteisfa` with recorded RPC smoke evidence |
