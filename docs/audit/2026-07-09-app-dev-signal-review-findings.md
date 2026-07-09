# app-dev And Signal Review Findings Closeout

- Original review date: 2026-07-09
- Closeout date: 2026-07-09
- Scope: root `app-dev` control workspace, `.codex/`, `.agents/`, `standards/`, `scripts/`, templates, CI, `projects/signal`, live Supabase project `qwtfvuwkxtucgcteisfa`, and GitHub PR state for `NielPieterse0/app-dev`
- Branch under closeout: `codex/signal-first-slice`
- Remote: `origin https://github.com/NielPieterse0/app-dev.git`

## Executive Summary

All actionable repository and app findings from the 2026-07-09 review were closed in this slice.

The only remaining high-severity item is not an unaddressed implementation gap. It is the intentional internal-MVP security posture: Signal still uses anonymous browser-write RPCs, but the branch now carries an explicit release-readiness gate that fails while that posture remains. That blocker is documented, verified, and enforced rather than being left implicit.

## Verification Performed

Executed successfully in the live checkout on 2026-07-09:

- `git fetch origin`
- `git status --short --branch`
- `scripts/check-workspace.ps1`
- `scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`
- `scripts/test-hooks.ps1`
- `scripts/test-workflow-enforcement.ps1`
- `scripts/test-analyze-spec.ps1`
- `scripts/test-workspace.ps1`
- `scripts/scan-secrets.ps1`
- `projects/signal`: `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
- `projects/signal`: `../../scripts/analyze-spec.ps1 -ProjectPath .`
- `projects/signal`: `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`
- `projects/signal`: `../../scripts/verify-app.ps1 -ProjectPath .`
- `projects/signal`: `npm run typecheck`
- `projects/signal`: `npm run lint`
- `projects/signal`: `npm run test`
- `projects/signal`: `npm run build`
- `projects/signal`: `npm run e2e`
- `projects/signal`: `npm run release:check`

Observed verification notes:

- Signal tests: 50 passed across 18 files.
- Playwright: 4 passed across desktop, laptop, tablet, and mobile projects.
- Build: passed. Vite still emits a chunk-size warning for the main bundle.
- Test warnings: Recharts still emits zero-dimension warnings in chart tests even though the tests pass.
- Secret scan: passed. `gitleaks` could not execute in this environment, so the local regex fallback scanner was used.
- Release gate: failed for the expected reason, reporting the remaining anonymous browser-write RPC posture as a broader-deployment blocker.

Live Supabase verification performed on 2026-07-09:

- Project discovered and verified: `qwtfvuwkxtucgcteisfa`
- Remote migration list inspected
- Remote `public.source_items` schema inspected
- Remote write RPC presence inspected
- Migration `005_signal_audit_closeout` applied successfully
- Remote `public.source_items` schema re-checked after migration
- Remote trigger `set_source_items_updated_at` re-checked after migration

GitHub-hosted verification performed on 2026-07-09:

- PR `#1` metadata inspected
- PR `#2` metadata inspected
- Combined commit status for head commit `4b2b2be8138d2dc87fef82537e0f785e7bd1db53` inspected
- Pull-request-triggered workflow runs for that same commit inspected

Not completed:

- Advisory-based dependency audit via `npm audit`.
  The earlier sandboxed run failed on network/cache access, and the escalated audit path remains blocked by tenant policy because it would send private dependency metadata to the npm audit service.

## Final Disposition Of Original Findings

### Closed: Dashboard eager concept load

- Original finding: `P1: Dashboard route eagerly loads concepts even before concept functionality is used`
- Closeout:
  - [projects/signal/src/modules/dashboard/routes/DashboardRoute.tsx](C:/Users/piete/Documents/app-dev/projects/signal/src/modules/dashboard/routes/DashboardRoute.tsx) now uses `useSaveConcept()` instead of `useConcepts()`.
  - [projects/signal/src/modules/concepts/hooks/useConcepts.ts](C:/Users/piete/Documents/app-dev/projects/signal/src/modules/concepts/hooks/useConcepts.ts) now separates concept listing from concept mutation.
  - `/concepts` still uses query-backed concept reads, while dashboard promotion uses the mutation-only hook.
- Verification:
  - `npm run test`
  - `../../scripts/verify-app.ps1 -ProjectPath .`

### Closed As Enforced Blocker: Anonymous browser-write RPC posture

- Original finding: `P1: Signal still relies on anonymous browser-write RPCs for internal-MVP operations`
- Closeout:
  - The internal-MVP posture remains intentionally unchanged in this slice.
  - [projects/signal/scripts/check-public-launch-readiness.ps1](C:/Users/piete/Documents/app-dev/projects/signal/scripts/check-public-launch-readiness.ps1) now fails while anonymous write RPC grants remain present.
  - [projects/signal/package.json](C:/Users/piete/Documents/app-dev/projects/signal/package.json) exposes this through `npm run release:check`.
  - Signal planning/spec/receipt artifacts now record this as a hard broader-deployment blocker rather than a soft caveat.
- Verification:
  - `npm run release:check` failed for the expected anonymous-write reasons.
- Remaining reality:
  - Public launch is still blocked until a future auth/RLS hardening slice removes anonymous browser-write access.

### Closed: Root README same-repo drift

- Original finding: `P2: Root documentation contradicts the current same-repo project model`
- Closeout:
  - [README.md](C:/Users/piete/Documents/app-dev/README.md) now states that apps stay tracked in the root repository by default.
  - [standards/workspace.md](C:/Users/piete/Documents/app-dev/standards/workspace.md) now explicitly codifies the single-repo in-tree project model.
- Verification:
  - `scripts/check-workspace.ps1`
  - `scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`

### Closed: Codex permission-profile documentation drift

- Original finding: `P2: Codex permission-profile documentation is stale relative to the active config`
- Closeout:
  - [README.md](C:/Users/piete/Documents/app-dev/README.md) now says project hooks and rules are active while project-level `default_permissions` are disabled on Windows.
  - [.codex/README.md](C:/Users/piete/Documents/app-dev/.codex/README.md) now reflects the same truth.
- Verification:
  - `scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`

### Closed: GitHub refresh resilience gap

- Original finding: `P3: GitHub ingestion has no token/backoff strategy and is likely to rate-limit in normal use`
- Closeout:
  - [projects/signal/src/modules/sources/services/github-source-adapter.ts](C:/Users/piete/Documents/app-dev/projects/signal/src/modules/sources/services/github-source-adapter.ts) now emits explicit rate-limit guidance and supports an optional `VITE_GITHUB_TOKEN` path for internal operator use.
  - [projects/signal/.env.example](C:/Users/piete/Documents/app-dev/projects/signal/.env.example) and [projects/signal/README.md](C:/Users/piete/Documents/app-dev/projects/signal/README.md) document the trust boundary clearly.
  - [projects/signal/src/modules/sources/tests/github-source-adapter.test.ts](C:/Users/piete/Documents/app-dev/projects/signal/src/modules/sources/tests/github-source-adapter.test.ts) covers the new rate-limit path.
- Verification:
  - `npm run test`

### Closed: Duplicate skill reference drift

- Original finding: `P3: A duplicate skill reference file creates unnecessary drift surface`
- Closeout:
  - [.agents/skills/cross-platform-app-workflow/references/spec-driven-workflow (1).md](C:/Users/piete/Documents/app-dev/.agents/skills/cross-platform-app-workflow/references/spec-driven-workflow%20(1).md) was removed.
  - [scripts/validate-codex-assets.ps1](C:/Users/piete/Documents/app-dev/scripts/validate-codex-assets.ps1) now fails on unexpected duplicate `* (1).md` skill-reference artifacts.
- Verification:
  - `scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`

## Attached Action List Reconciliation

Reference used: `C:\Users\piete\Downloads\signal-consolidated-action-list.md`

### Closed In This Closeout

- `A1` schema drift in `source_items`
  - Closed by [projects/signal/supabase/migrations/005_signal_audit_closeout.sql](C:/Users/piete/Documents/app-dev/projects/signal/supabase/migrations/005_signal_audit_closeout.sql).
  - Closed live on Supabase after applying migration `005_signal_audit_closeout` to project `qwtfvuwkxtucgcteisfa`.
- `A3` live Supabase evidence gap
  - Closed by direct inspection of the live project migration list, live schema, live RPC presence, and live migration application result.
- `B2` duplicated source labels in Settings
  - Closed by [projects/signal/src/modules/settings/routes/SettingsRoute.tsx](C:/Users/piete/Documents/app-dev/projects/signal/src/modules/settings/routes/SettingsRoute.tsx) now reusing canonical `sourceLabels`.
- `C1` template eager env parse
  - Closed by [templates/react-vite-capacitor/src/lib/env.ts](C:/Users/piete/Documents/app-dev/templates/react-vite-capacitor/src/lib/env.ts) no longer exporting an eager module-scope parsed env object.
- `C2` template raw settings anchors
  - Closed by [templates/react-vite-capacitor/src/components/layout/SettingsLayout.tsx](C:/Users/piete/Documents/app-dev/templates/react-vite-capacitor/src/components/layout/SettingsLayout.tsx) now using router-aware links.
- `C3` template Query Client defaults
  - Closed by [templates/react-vite-capacitor/src/lib/query-client.ts](C:/Users/piete/Documents/app-dev/templates/react-vite-capacitor/src/lib/query-client.ts) now setting conservative default query/mutation behavior.
- `C4` missing template Supabase scaffold
  - Closed by [templates/react-vite-capacitor/supabase/README.md](C:/Users/piete/Documents/app-dev/templates/react-vite-capacitor/supabase/README.md) and [templates/react-vite-capacitor/supabase/migrations/001_template_foundation.sql](C:/Users/piete/Documents/app-dev/templates/react-vite-capacitor/supabase/migrations/001_template_foundation.sql).
- `C5` Signal-hardcoded CI working directory
  - Closed by [.github/workflows/app-dev-validation.yml](C:/Users/piete/Documents/app-dev/.github/workflows/app-dev-validation.yml) now using an app matrix and `${{ matrix.project.path }}`.
- `B1` fixture/runtime source drift
  - Closed to the degree supported by the original narrower finding: unused runtime fixture exports and the duplicate `sourceLabels` export were removed from [projects/signal/src/modules/sources/services/source-fixtures.ts](C:/Users/piete/Documents/app-dev/projects/signal/src/modules/sources/services/source-fixtures.ts), while fixture types remain for normalizer/test use.

### Closed Or Reframed By Fresh Evidence

- `D2` PR `#1` merge-metadata oddity
  - Not a live defect. Fresh GitHub inspection shows PR `#1` is a normal merged PR with merge commit `8a8d8949af30ba4cbb118d3580cf549fff9d9075` on 2026-07-07.
- `D3` governance/app scope-mixing concern
  - The branch still contains both Signal and root-harness/template changes, but that is now explicit, justified, and validator-backed in the current slice. This is not a hidden drift condition anymore; it is a scoped control-workspace change set.

### Still Open As Hosted-State Follow-Up

- `A2` zero CI signal on PR `#2`
  - Fresh GitHub inspection still shows no combined commit statuses and no PR-triggered workflow runs for commit `4b2b2be8138d2dc87fef82537e0f785e7bd1db53`.
  - This is no longer a local implementation defect. It is a hosted-state follow-up that requires pushing the refreshed branch state and letting GitHub Actions run on the new head commit.
- `D1` stale PR `#2` description
  - Fresh GitHub inspection confirms PR `#2` still contains stale “known open items” text from the earlier slice state.
  - This is a hosted metadata follow-up, not a repo-content bug.
- `A4` branch behind `origin/main`
  - After `git fetch origin`, `git rev-list --left-right --count origin/main...HEAD` still reports `1 7`.
  - The missing `origin/main` commit is `688462f` (`docs: codify single-repo model, no per-app repositories`).
  - The same-repo model content is already reflected in the working tree, but ancestry remains behind until the branch is updated and pushed.

## Slice 2 Audit Reconciliation

Reference used: `C:\Users\piete\.codex\attachments\ba9bea0c-00e6-4418-b878-922e54f838e9\pasted-text.txt`

### Closed Since The Original Slice 2 Audit

- Real Supabase verification evidence gap
  - Closed by direct live inspection and migration application on project `qwtfvuwkxtucgcteisfa`.
- Workflow-receipt contradiction detection mismatch
  - Closed by [scripts/validate-workflow-receipts.ps1](C:/Users/piete/Documents/app-dev/scripts/validate-workflow-receipts.ps1) now rejecting `pending` in the same completed-receipt situations that [scripts/analyze-spec.ps1](C:/Users/piete/Documents/app-dev/scripts/analyze-spec.ps1) rejects.
  - [scripts/test-workflow-enforcement.ps1](C:/Users/piete/Documents/app-dev/scripts/test-workflow-enforcement.ps1) now covers the stricter release-readiness case.
- Signal-hardcoded CI
  - Closed by the app matrix change in [.github/workflows/app-dev-validation.yml](C:/Users/piete/Documents/app-dev/.github/workflows/app-dev-validation.yml).

### Still Intentionally Open

- Anonymous browser-write RPC posture
  - Still intentionally open as a broader-deployment blocker, now guarded by `npm run release:check` instead of being only a documentation caveat.

## spec-kit Cross-Reference Reconciliation

Reference used: `C:\Users\piete\.codex\attachments\0580bc2d-26a8-441f-9a74-0853ce60e313\pasted-text.txt`

### Closed Recommendations

- Receipt-validator regex mismatch
  - Closed by the `pending` alignment between `analyze-spec.ps1` and `validate-workflow-receipts.ps1`.
- Signal-specific CI scaling concern
  - Closed by the root app matrix workflow.
- Shared-helper duplication for `Get-ActiveSpecRelativePath`
  - Closed by moving `Get-ActiveSpecRelativePath` into [scripts/common.ps1](C:/Users/piete/Documents/app-dev/scripts/common.ps1) and reusing it from both analyzers.

### Still Low-Priority Recommendations

- `checklist.md` naming collision versus `spec-kit`
  - Still a documentation/UX recommendation, not a correctness defect.
- Generic module README explicit disposable marker
  - Still a low-priority workflow-design recommendation, not a defect blocking this slice closeout.
- Chunk-size and Recharts test warnings
  - Still deferred. They are visible during verification but did not block successful app checks.

## Final Status

This closeout slice fixed the actionable repository, template, Signal, and live Supabase findings from the 2026-07-09 review.

What remains after this closeout is limited to:

1. the intentional anonymous browser-write internal-MVP posture, which is now an explicit enforced blocker rather than an implicit risk,
2. GitHub-hosted PR/CI state that depends on pushing the refreshed branch head and updating PR metadata,
3. low-priority warnings and workflow recommendations that were already classified as non-blocking.
