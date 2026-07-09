# Signal Codex Instructions

Follow the root `app-dev/AGENTS.md` standards.
Use `standards/codex-capabilities.md` for Codex skill and plugin routing.
Use this project's `PLAN.md` for architecture, module, risk, and verification decisions.

## Active Specification

- Active spec: `specs/005-signalauditcloseout/spec.md`.
- Create later feature specs under `specs/NNN-<slug>/`.
- Keep `PLAN.md`, `tasks.md`, and `workflow-receipts.md` aligned to the active spec before implementation starts.

## App Type

Default cross-platform app: React + Vite + React Router + Capacitor.

## App Identity

- Product: Signal, a personal tech and AI trend-scouting dashboard.
- Primary users: a single operator evaluating public-source trend signals and shaping future product concepts.
- Core jobs: ingest public source items, normalize them, rank them, review the feed, tune source settings, and export promising concepts into future scoped product work.
- Current v1 scope: GitHub + Hacker News source ingestion, persisted ranked dashboard, manual refresh, source filters, source settings, and concept promotion/export workflow.
- Platforms: desktop web and mobile web first; Capacitor stays available for later Android and iOS packaging if product validation justifies it.
- Native requirements: none for the first slice beyond the existing Capacitor-ready shell.
- Repository model: Signal stays tracked in the root `app-dev` repository unless a later recorded decision changes that ownership model.

## Required Before Feature Work

- Complete `specs/005-signalauditcloseout/spec.md` before feature work.
- Update `PLAN.md` for architecture-sensitive or multi-module work.
- Update `specs/005-signalauditcloseout/tasks.md` before material implementation.
- Review the starter `AppShell`, `NavigationShell`, and base route structure.
- Keep module boundaries explicit: import other modules only through `@/modules/<module>`, and treat deep imports into another module's internals as lint failures.
- Add `.env.example` for required public environment variables.
- Use publishable Supabase browser keys only; never add service-role or secret keys to Vite env.
- Add native platform folders only inside a generated app after the active spec confirms the need.
- Treat the template README checklist as the completion baseline for later tasks in this plan.
- Keep Signal on free-tier services until product proof or a documented production need justifies an upgrade.
- Treat public-source ingestion, Supabase schema work, and source/API terms as gated-path concerns even while the app remains internal and no-auth.
- Treat any no-auth browser write path as internal-MVP only and record that it is not production-ready or public-launch safe in the active checklist, receipts, and handoff.

## Capability Routing

- Use `cross-platform-app-workflow` as the required local app-dev skill.
- Use the local wrapper workflows when triggered: `ui-change-workflow`, `data-change-workflow`, `mobile-validation-workflow`, and `release-readiness-workflow`.
- Optional external capabilities may help with frontend UI, rendered QA, Supabase, security, data analysis, concept shaping, mobile emulator checks, and deployment.
- Do not assume optional global skills/plugins are installed. Continue with local standards when they are unavailable.
- Prefer Browser/IAB for rendered UI checks when available; use Playwright as fallback and record why.
- Product-specific auth policies and RLS rules belong in migrations after the app data model is defined.
- Record any plugin accelerator used or unavailable in `workflow-receipts.md`.

## Verification

After installing dependencies inside this project, run available scripts through `../../scripts/verify-app.ps1 -ProjectPath .`.

## Done When

- Active specification and task artifacts are current for the feature being built.
- `workflow-receipts.md` is current for any UI, data, mobile, or release-readiness work.
- `PLAN.md` is current for architecture, data model, auth, routing, deployment, migration, or multi-module work.
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` passes before completion.
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` passes before completion.
- Available checks pass through `../../scripts/verify-app.ps1 -ProjectPath .`.
- `npm run release:check` is the explicit broader-deployment gate and must pass before any public-launch or production-readiness claim.
- The React template lint config still enforces `@/modules/<module>` as the only public cross-module import surface.
- Missing scripts are reported instead of invented.
- UI changes include rendered desktop and mobile checks.
- Handoff notes record deviations, skipped checks, and unresolved decisions.
- Supabase migrations, RLS posture, free-tier assumptions, and source/API constraints are documented when data surfaces change.
