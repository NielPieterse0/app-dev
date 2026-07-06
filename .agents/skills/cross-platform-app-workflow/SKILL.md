---
name: cross-platform-app-workflow
description: Scaffold, build, review, and verify cross-platform app-dev apps: React/Vite/Capacitor, Next.js, Expo, adaptive desktop/mobile layouts, vertical modules, templates, and Codex app workflow.
---

# Cross-Platform App Workflow

Use this skill for modular app planning, scaffolding, implementation review, and verification inside the `app-dev` workspace.

## Required Local Context

1. Read root `AGENTS.md`.
2. Read the app `AGENTS.md` when working inside `projects/<app>`.
3. Read the app `PLAN.md` when present. Create one from `templates/PLAN.template.md` for architectural or multi-module work.
4. Load only the reference file needed for the task:
   - `references/stack.md` for app-type or library decisions.
   - `references/module-contract.md` for module structure.
   - `references/adaptive-layouts.md` for responsive UI work.
   - `references/qa-gates.md` for verification and handoff.
5. Reuse `templates/` before inventing structure.

## Workflow

1. Capture the product decision record: users, core jobs, modules, data model, permissions, platforms, and native requirements.
2. Select the simplest app type:
   - React + Vite + React Router + Capacitor for default cross-platform apps.
   - Next.js only for SSR, SEO, server routes, or content-heavy public pages.
   - Expo only for native-first mobile behavior.
3. Update app `AGENTS.md` and `PLAN.md` before material implementation.
4. Build the base shell before feature modules: providers, routing, navigation, theme tokens, empty/loading/error states.
5. Implement vertical modules with schemas, services/hooks, UI, routes, tests, and exports.
6. Prefer standard libraries and local templates over custom framework code.
7. Verify with available scripts and rendered desktop/mobile checks before handoff.

## Optional External Capabilities

The only required local skill in this repo is `cross-platform-app-workflow`. Other skills or plugins are optional external/global capabilities. Use them only when installed, trusted, and relevant; if unavailable, continue with local standards and report the gap.

Consult `standards/codex-capabilities.md` for routing guidance before using optional capabilities for frontend UI, rendered QA, shadcn/ui, React/Next, Supabase, Playwright, security, GitHub, mobile emulators, dashboards, OpenAI API work, payments, or deployment.

## Guardrails

- Do not add a second UI kit, form library, state library, router, or table library without documenting the reason.
- Do not create a monorepo until shared packages justify it.
- Do not install app dependencies at the `app-dev` root unless they are workspace tooling.
- Do not claim UI work is complete without rendered desktop and mobile checks.
- Do not commit secrets or production environment files.
