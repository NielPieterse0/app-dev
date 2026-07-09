# app-dev And Signal Review Findings Closeout

- Original review date: `2026-07-09`
- Closeout update date: `2026-07-09`
- Scope: root `app-dev` workspace, templates, scripts, CI, `projects/signal`, and the hosted Supabase/GitHub follow-up for PR `#2`
- Branch under closeout: `codex/signal-first-slice`

## Final Position

All six template and harness findings called out in the review are now closed in repository code:

1. Template Supabase env parsing is lazy and import-safe in [templates/react-vite-capacitor/src/lib/env.ts](../../templates/react-vite-capacitor/src/lib/env.ts).
2. Template settings navigation uses router-aware links in [templates/react-vite-capacitor/src/components/layout/SettingsLayout.tsx](../../templates/react-vite-capacitor/src/components/layout/SettingsLayout.tsx).
3. Template React Query defaults are conservative in [templates/react-vite-capacitor/src/lib/query-client.ts](../../templates/react-vite-capacitor/src/lib/query-client.ts).
4. The template now ships a tracked Supabase scaffold plus an RPC-bound write example in [templates/react-vite-capacitor/supabase/README.md](../../templates/react-vite-capacitor/supabase/README.md), [001_template_foundation.sql](../../templates/react-vite-capacitor/supabase/migrations/001_template_foundation.sql), and [002_template_profile_rpc.sql](../../templates/react-vite-capacitor/supabase/migrations/002_template_profile_rpc.sql).
5. CI now discovers app projects dynamically in [app-dev-validation.yml](../../.github/workflows/app-dev-validation.yml) through [get-app-validation-matrix.mjs](../../scripts/get-app-validation-matrix.mjs) instead of naming Signal by hand.
6. Template auth/settings scaffolding is now explicitly disposable example code in [templates/react-vite-capacitor/README.md](../../templates/react-vite-capacitor/README.md), [src/app/README.md](../../templates/react-vite-capacitor/src/app/README.md), [src/modules/auth/index.ts](../../templates/react-vite-capacitor/src/modules/auth/index.ts), and the renamed example settings route exports in [src/modules/settings/routes/SettingsRoute.tsx](../../templates/react-vite-capacitor/src/modules/settings/routes/SettingsRoute.tsx).

## Attached Review Follow-Up

The later PR review findings are also closed in repository code:

- Cross-platform script defects were removed from [common.ps1](../../scripts/common.ps1), [get-workflow-obligations.ps1](../../scripts/get-workflow-obligations.ps1), [analyze-spec.ps1](../../scripts/analyze-spec.ps1), [validate-workflow-receipts.ps1](../../scripts/validate-workflow-receipts.ps1), [test-workflow-enforcement.ps1](../../scripts/test-workflow-enforcement.ps1), [test-analyze-spec.ps1](../../scripts/test-analyze-spec.ps1), [test-hooks.ps1](../../scripts/test-hooks.ps1), and [projects/signal/package.json](../../projects/signal/package.json).
- The release-readiness gate is now state-based across the migration chain, not a fixed-text grep, in [projects/signal/scripts/check-public-launch-readiness.ps1](../../projects/signal/scripts/check-public-launch-readiness.ps1).
- The release gate now calls out the exact risk of `replace_signal_source_items(...)`: anonymous full-feed reset access.
- Secret scanning now detects modern Supabase key formats and no longer depends on a line-pinned suppression in [scripts/scan-secrets.ps1](../../scripts/scan-secrets.ps1).
- Settings navigation no longer carries two active-state sources of truth in both the template and Signal copies of `SettingsLayout.tsx`.
- Template-to-app parity for the patched shared files is now enforced by [check-template-parity.ps1](../../scripts/check-template-parity.ps1) and [template-parity.manifest.json](../../templates/react-vite-capacitor/template-parity.manifest.json).
- Repository-side dependency monitoring is now present through [dependabot.yml](../../.github/dependabot.yml).
- This closeout record no longer embeds machine-local absolute paths.

## Signal-Specific Status

The Signal app-side audit work remains closed:

- Schema drift is closed by [005_signal_audit_closeout.sql](../../projects/signal/supabase/migrations/005_signal_audit_closeout.sql), which was also applied to the live Supabase project `qwtfvuwkxtucgcteisfa`.
- Dashboard concept promotion no longer pulls the concepts query eagerly; the dashboard now uses a mutation-only concept save path in [DashboardRoute.tsx](../../projects/signal/src/modules/dashboard/routes/DashboardRoute.tsx).
- Settings route source labels are canonicalized through the shared source module in [SettingsRoute.tsx](../../projects/signal/src/modules/settings/routes/SettingsRoute.tsx).
- GitHub ingestion now has explicit token/rate-limit handling in [github-source-adapter.ts](../../projects/signal/src/modules/sources/services/github-source-adapter.ts).

## Remaining Intentional Blocker

One intentional broader-deployment blocker still remains, and it is enforced rather than hidden:

- Signal still uses anonymous browser-write RPCs for the internal MVP. That is intentionally unchanged in this slice.
- The blocker is now enforced by `npm run release:check`, wired to [check-public-launch-readiness.ps1](../../projects/signal/scripts/check-public-launch-readiness.ps1).
- Public launch remains blocked until a later auth/RLS hardening slice removes anonymous write access.

## Verification Standard

Fresh local verification is required before claiming this slice complete. The relevant command set for this closeout is:

- `scripts/check-workspace.ps1`
- `scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`
- `scripts/test-hooks.ps1`
- `scripts/test-workflow-enforcement.ps1`
- `scripts/test-analyze-spec.ps1`
- `scripts/scan-secrets.ps1`
- `scripts/check-template-parity.ps1`
- `projects/signal`: `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
- `projects/signal`: `../../scripts/analyze-spec.ps1 -ProjectPath .`
- `projects/signal`: `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`
- `projects/signal`: `npm run typecheck`
- `projects/signal`: `npm run lint`
- `projects/signal`: `npm run test`
- `projects/signal`: `npm run build`
- `projects/signal`: `npm run e2e`
