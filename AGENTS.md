# app-dev Codex Instructions

This workspace is the control base for modular cross-platform application development.

## Default Goal

Build applications as modular, maintainable products with one adaptive design system that works on desktop, Android, and iOS. Prefer proven libraries, existing templates, and standard modules over new custom framework code.

## Default Stack

Use this stack unless a project-level `AGENTS.md` documents a different decision:

- TypeScript
- React + Vite + React Router for default web/PWA apps
- Capacitor for Android/iOS wrappers when app-store packaging or native APIs are required
- Next.js only when SSR, SEO, server routes, or content-heavy public pages justify it
- Expo React Native only when native mobile UX/device APIs are central
- Tailwind CSS + CSS variables for styling and design tokens
- shadcn/ui + Radix primitives for UI components
- lucide-react for icons when the project icon system is not otherwise specified
- Zod for validation and shared schemas
- React Hook Form for forms
- TanStack Query for server state
- Zustand for small client state stores
- TanStack Table for complex data tables
- Recharts or ECharts for charts
- Supabase for default backend, auth, storage, and Postgres
- Vitest, Testing Library, and Playwright for verification

## Repository Shape

This root workspace contains standards, templates, skills, scripts, and project folders. Each real application under `projects/` should normally be its own git repository unless shared packages prove that a monorepo is needed.

Promote to a pnpm/Turborepo monorepo only after at least two apps share real code such as `ui`, `auth`, `api-client`, or `config`.

## Codex Surface Rules

- Put durable workspace rules in this file.
- Put app-specific rules in `projects/<app>/AGENTS.md`.
- Put feature specifications in `projects/<app>/specs/NNN-<slug>/`.
- Put task planning protocol in `PLANS.md` and per-app plans in `projects/<app>/PLAN.md`.
- Put repeatable task workflows in `.agents/skills/`.
- Put project settings, rules, and hooks in `.codex/`.
- Put human-readable standards in `standards/`.
- Put starter app files and reusable plan templates in `templates/`.
- Put Codex skill and plugin routing guidance in `standards/codex-capabilities.md`.
- Do not put secrets, API keys, tokens, private keys, `.env` files, or Supabase service role keys in this workspace.

## Development Workflow

1. Start every material app task by selecting or creating a numbered feature spec under `projects/<app>/specs/NNN-<slug>/`.
2. Keep app identity and durable rules in `projects/<app>/AGENTS.md`, and keep feature intent, acceptance criteria, and risk in the active `spec.md`.
3. Create or update `projects/<app>/PLAN.md` for architectural, data model, auth, routing, deployment, migration, or multi-module work. Use `templates/PLAN.template.md` when creating a new app plan.
4. Choose the simplest app type that satisfies requirements:
   - React + Vite + Capacitor for most cross-platform business apps.
   - Next.js for SSR/SEO/server-rendered public apps.
   - Expo for native-first mobile apps.
5. Create or update `specs/NNN-<slug>/tasks.md` before material implementation, and add `checklist.md` for auth, payments, secrets, public APIs, data access, file uploads, RLS, AI tool actions, deployment, or live migrations.
6. Build vertical modules, not page dumps. Each module owns schema, API/data hooks, UI components, routes, tests, and empty/loading/error states.
7. Reuse existing components and templates before creating new abstractions.
8. Install dependencies where they are used. Keep root dependencies minimal.
9. Keep adaptive layout explicit: desktop, tablet, and mobile view states must be designed and checked.
10. Before completion, run the app's verification commands and check rendered UI at desktop and mobile sizes.

## Module Contract

Each app module should contain, when applicable:

```text
src/modules/<module>/
  components/
  hooks/
  routes/
  schemas/
  services/
  state/
  tests/
  index.ts
```

Avoid cross-module deep relative imports. Use public `index.ts` exports or shared `src/lib` utilities.

## Planning Rules

- Keep plans short, decision-oriented, and current.
- Keep specs numbered, current, and tied to one feature or workflow slice.
- A plan is required before multi-module or architecture-sensitive work.
- Do not let stale plans override current user instructions or app `AGENTS.md`.
- In the final handoff, report deviations from the plan and skipped verification.

## Quality Gates

Before claiming work is complete, run the strongest available checks:

```text
npm run typecheck
npm run lint
npm run test
npm run build
npm run e2e
```

Use the package manager already present in the project. If a command is missing, report that instead of inventing it.

`npm run e2e` is mandatory when the project defines it or when UI/browser behavior changed enough to require rendered flow coverage. If an app template or project does not define `e2e`, report the missing script and run the strongest available checks instead.

For UI work, rendered verification is required: first meaningful screen, core interaction, desktop viewport, and mobile viewport.

## Design Rules

- Build the actual usable app surface first, not a marketing landing page, unless explicitly requested.
- Use dense but readable operational layouts for SaaS, CRM, dashboards, admin, booking, and workflow tools.
- Use cards for repeated items and modals, not for every page section.
- Use icons for icon-worthy controls and tooltips for ambiguous icons.
- Text must not overlap, clip, or overflow on mobile or desktop.
- Use stable dimensions for boards, grids, tables, toolbars, and counters to prevent layout shift.
- Use accessible controls from shadcn/Radix before custom control markup.

## Dependency Rules

- Prefer the standard stack in `standards/stack.md`.
- Prefer the capability routing in `standards/codex-capabilities.md` when a task may benefit from an optional specialist Codex skill or plugin.
- Do not assume optional global skills/plugins are installed. Continue with local standards if they are unavailable and report the gap.
- Do not add libraries for solved problems already covered by the stack.
- Do not add a new state manager, router, form library, table library, or UI kit without documenting the reason in the project `AGENTS.md`.
- Avoid global root installs for app dependencies. App dependencies belong in the app package.

## Codex Governance Checks

When changing `.codex/`, `.agents/skills/`, root `AGENTS.md`, planning templates, CI, or workspace scripts, run:

```text
scripts/check-workspace.ps1
scripts/validate-codex-assets.ps1
scripts/test-hooks.ps1
```

Project-local Codex hooks and rules are active only after the repository `.codex/` layer is trusted in Codex. Do not add `.codex/hooks.json` while inline hooks remain configured in `.codex/config.toml`.

## Verification Notes

When a check cannot be run because dependencies are not installed, scripts are absent, or external services are unavailable, state the exact blocker and the next command the user should run.
