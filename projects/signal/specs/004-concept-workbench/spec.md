# 004 Signal Concept Workbench Specification

- Status: complete
- Risk level: gated
- App: signal
- Created: 2026-07-09

## Summary

Complete Signal Slice 4 in two linked parts: first close the remaining Slice 3 verification and drift gaps, then add a concept workbench that promotes persisted live signals into durable product briefs with backend-neutral product copy.

## Requirements

1. Signal must close the previously deferred live Supabase migration and smoke-verification gap against a bounded non-production project.
2. Signal and app-dev docs must reconcile stale Slice 2 and Slice 3 wording so the live repo describes the current product and governance baseline accurately.
3. Signal must keep Supabase as the default persistence adapter while reducing user-facing vendor branding for generic remote-versus-local storage behavior.
4. Signal must add a concept domain that can persist concept drafts separately from source items.
5. Signal must let an operator inspect a persisted live signal and promote it into a concept draft.
6. Signal concepts must capture durable evidence from linked source items, including source, score, engagement, recency, keywords, and referenced signal ids.
7. Signal must provide a concept workspace where the operator can review and edit title, target user, problem, opportunity, evidence summary, risks, status, and confidence.
8. Signal must export a concept as both a human-readable brief and a machine-readable JSON representation without mutating the local workspace from inside the app.
9. Signal concept persistence must use the configured remote backend when available and the explicit local fallback repository when not.
10. No scheduled/background ingestion, auth, sharing, multi-user access, additional source adapters, native packaging, or public-launch claims may be added in this slice.

## Acceptance Criteria

1. The connected Supabase project has the Signal schema and RPCs applied through the repository migrations, and Slice 3's live verification blocker is closed with recorded evidence.
2. `projects/signal/README.md`, `PLAN.md`, and related slice artifacts no longer contain stale Slice 2 wording or outdated scope statements.
3. Dashboard/product copy uses backend-neutral wording for generic storage-mode disclosures while still keeping Supabase-specific setup and security notes where they matter.
4. A new `concepts` module exists with schemas, repositories, route logic, and tests.
5. The dashboard supports inspect-first promotion from a persisted signal into a concept draft.
6. The concept workspace supports list/detail review and editing for persisted concepts.
7. Concept export generates a stable Markdown brief and a stable JSON payload.
8. Typecheck, lint, test, build, e2e, artifact checks, receipt validation, and the root governance checks are recorded against this active spec.

## Data And Permissions

- Personal data: none.
- Stored data: public-source metadata, ranked source items, source and keyword preferences, concept drafts, and concept evidence snapshots derived from public source items.
- Client credentials: Supabase URL and publishable key only.
- Authorization: no-auth internal MVP. Browser writes remain explicitly not production-ready and block any public-launch claim.
- External APIs: public GitHub and Hacker News read paths only.
- Retention: source items reflect the latest manual refresh batch; concept drafts persist until replaced, archived, or explicitly removed through future product work.

## Clarifications

- Supabase remains the default remote adapter, but product-facing storage copy should not treat the vendor name as the feature when generic wording is clearer.
- Live migration and smoke verification must target only a bounded internal or disposable Supabase project.
- Concept export may generate downloadable artifacts or copyable payloads, but it must not create `projects/<app>` folders or write repo files from the browser app.

## Verification Intent

- Root: `./scripts/check-workspace.ps1`, `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`, `./scripts/test-hooks.ps1`, `./scripts/test-workflow-enforcement.ps1`, `./scripts/test-analyze-spec.ps1`, `./scripts/test-workspace.ps1`, and `./scripts/scan-secrets.ps1`.
- Spec: `../../scripts/analyze-spec.ps1 -ProjectPath .`, `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, and `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
- App: `../../scripts/verify-app.ps1 -ProjectPath .` plus rendered dashboard/concepts/settings checks at desktop and mobile widths.
- Live backend: apply the Signal migrations to the connected internal Supabase project and run bounded read/write smoke checks against the settings, feed, and concepts persistence paths.
