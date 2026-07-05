---
name: cross-platform-app-workflow
description: Use when planning, scaffolding, building, reviewing, or verifying modular cross-platform applications in the app-dev workspace. Applies to React/Vite/Capacitor apps, Next.js apps when SSR is justified, Expo native apps when native mobile behavior is central, adaptive desktop/Android/iOS layouts, app module decisions, reusable app templates, and Codex-driven app development workflows.
---

# Cross-Platform App Workflow

Use this skill to build modular applications from the `app-dev` workspace with minimal custom code and a single adaptive design system.

## Source Order

1. Read root `AGENTS.md`.
2. Read the project `AGENTS.md` if working inside `projects/<app>`.
3. Read only the relevant reference files in this skill:
   - `references/stack.md` for stack selection.
   - `references/module-contract.md` for module structure.
   - `references/adaptive-layouts.md` for responsive design.
   - `references/qa-gates.md` for verification.
4. Read `standards/codex-capabilities.md` when the task may need a specialist Codex skill or plugin.
5. Reuse templates under `templates/` before inventing new structure.

## Workflow

1. Capture the product decision record: users, core jobs, modules, data model, permissions, platforms, native requirements.
2. Select the app type:
   - React + Vite + React Router + Capacitor by default.
   - Next.js only for SSR/SEO/server-rendered requirements.
   - Expo only for native-first mobile requirements.
3. Create or update app-specific `AGENTS.md`.
4. Build the base shell before feature modules: providers, routing, navigation, theme tokens, empty/loading/error states.
5. Implement vertical modules. Each module owns schema, services/hooks, UI, routes, tests, and exports.
6. Use standard libraries before custom code.
7. Verify with available scripts and rendered desktop/mobile checks before handoff.

## Stack Defaults

Default to TypeScript, React, Vite, React Router, Tailwind, shadcn/ui, Radix, lucide-react, Zod, React Hook Form, TanStack Query, Zustand, TanStack Table, Supabase, Capacitor, Vitest, Testing Library, and Playwright.

## Companion Skills

Use specialist skills/plugins by task type:

- `frontend-app-builder` for new visual app surfaces, dashboards, redesigns, and first usable screens.
- `frontend-testing-debugging` for rendered UI QA, responsive bugs, console errors, and interaction issues.
- `shadcn-best-practices` for shadcn/ui setup, component composition, registries, and `components.json`.
- `react-best-practices` for React/Next.js component, data-flow, and performance work.
- `supabase-best-practices` for schema, SQL, RLS, query, and Postgres performance decisions.
- `playwright` when Browser/IAB is unavailable or insufficient for browser automation.
- `verification-before-completion` before claiming work is complete.
- `security-scan` and `security-best-practices` before production readiness or when touching auth, payments, secrets, APIs, or data access.
- `github`, `gh-fix-ci`, `gh-address-comments`, and `yeet` for GitHub repo, PR, CI, review, and publishing workflows.
- `android-emulator-qa` for Capacitor Android emulator validation.
- `ios-debugger-agent` for Capacitor iOS simulator validation.
- `data-visualization`, `build-dashboard`, and Data Analytics widgets for metrics dashboards, KPI views, reports, and chart-heavy apps.
- `openai-platform-api-key` and the OpenAI Platform plugin only when an app needs AI features or `OPENAI_API_KEY`.
- `stripe-best-practices` only for payments, subscriptions, or marketplace flows.
- `cloudflare`, `workers-best-practices`, and `vercel-deploy` only after a hosting or deployment target is chosen.

## Guardrails

- Do not add a second UI kit, form library, state library, router, or table library without documenting the reason.
- Do not create a monorepo until shared packages justify it.
- Do not install app dependencies at the app-dev root unless they are workspace tooling.
- Do not claim UI work is complete without rendered desktop and mobile checks.
- Do not commit secrets or production environment files.
