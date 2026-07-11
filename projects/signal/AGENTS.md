# Signal App Instructions

This file defines the durable app contract for this project.

Keep feature-specific requirements, scenarios, risks, tasks, workflow receipts, and completion criteria in `specs/NNN-<slug>/`.

Follow the root `app-dev/AGENTS.md` standards.

## Active Specification

- Active spec: `specs/007-code-script-closeout/spec.md`.
- The active plan for this slice lives at `specs/007-code-script-closeout/plan.md`.
- Create later feature specs under `specs/NNN-<slug>/`.

## App Type

Default cross-platform app: React + Vite + React Router + Capacitor.

## App Identity

- Product: Signal, a personal tech and AI trend-scouting dashboard.
- Primary users: a single operator evaluating public-source trend signals and shaping future product concepts.
- Core jobs: ingest public source items, normalize them, rank them, review the feed, tune source settings, and export promising concepts into future scoped product work.
- Current v1 scope: GitHub + Hacker News source ingestion, persisted ranked dashboard, manual refresh, source filters, source settings, and concept promotion/export workflow.
- Platforms: desktop web and mobile web first; Capacitor stays available for later Android and iOS packaging if product validation justifies it.
- Repository model: Signal stays tracked in the root `app-dev` repository unless a later recorded decision changes that ownership model.

## Durable Constraints

- Cross-module imports use the target module public surface only: `@/modules/<module>`.
- Keep Signal on free-tier services until product proof or a documented production need justifies an upgrade.
- Treat public-source ingestion, Supabase schema work, and source/API terms as gated-path concerns even while the app remains internal and no-auth.
- Treat any no-auth browser write path as internal-MVP only and record that it is not production-ready or public-launch safe in the active checklist, receipts, and handoff.
- Do not store secrets, private keys, service-role keys, or `.env` files in the repository.
- Document required public environment variables in `.env.example`.

## Platform Constraints

- Native requirements: none for the first slice beyond the existing Capacitor-ready shell.
- Add native platform folders and native APIs only after an active spec explicitly requires them.

## Verification Baseline

- Run the app's available verification commands through `../../scripts/verify-app.ps1 -ProjectPath .`.
- If a required script is missing, report the missing script instead of inventing commands.
- UI changes require rendered verification on the relevant supported surfaces.
- `npm run release:check` is the broader deployment gate and must pass before any public-launch or production-readiness claim.
