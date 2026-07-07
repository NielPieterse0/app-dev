---
name: cross-platform-app-workflow
description: app-dev scaffold, verify, and review React/Vite/Capacitor, Next.js, and Expo apps with vertical modules and adaptive desktop/mobile layouts.
metadata:
  owner: app-dev
  version: 1.0.0
  maturity: stable
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
   - `references/spec-driven-workflow.md` for numbered specs, tasks, and gated-path rules.
   - `../../standards/command-workflow-contract.md` for local command and receipt obligations when relevant.
5. Reuse `templates/` before inventing structure.

## Workflow

1. Capture or confirm durable app identity in app `AGENTS.md`.
2. Select or create the active numbered spec under `specs/NNN-<slug>/`.
3. Select the simplest app type:
   - React + Vite + React Router + Capacitor for default cross-platform apps.
   - Next.js only for SSR, SEO, server routes, or content-heavy public pages.
   - Expo only for native-first mobile behavior.
4. Update app `AGENTS.md`, the active `spec.md`, and `PLAN.md` before material implementation.
5. Generate or update `tasks.md` and `workflow-receipts.md` before implementation. Add `checklist.md` for auth, payments, secrets, public APIs, data access, file uploads, RLS, AI tool actions, deployment, or live migrations.
6. Build the base shell before feature modules: providers, routing, navigation, theme tokens, empty/loading/error states.
7. Implement vertical modules with schemas, services/hooks, UI, routes, tests, and exports.
8. Prefer standard libraries and local templates over custom framework code.
9. Classify the work into any required local wrapper workflows before implementation:
   - `ui-change-workflow`
   - `data-change-workflow`
   - `mobile-validation-workflow`
   - `release-readiness-workflow`
10. Update the matching workflow receipt sections during implementation.
11. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before implementation handoff, then run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` and verify with available scripts and rendered desktop/mobile checks before completion.

## Optional External Capabilities

The only required local skill in this repo is `cross-platform-app-workflow`. Other skills or plugins are optional external/global capabilities. Use them only when installed, trusted, and relevant; if unavailable, continue with local standards and report the gap.

Consult `standards/codex-capabilities.md` for routing guidance before using optional capabilities for frontend UI, rendered QA, shadcn/ui, React/Next, Supabase, Playwright, security, GitHub, mobile emulators, dashboards, OpenAI API work, payments, or deployment. External skills are accelerators; the local wrapper workflows are the enforceable contract.

## Guardrails

- Do not add a second UI kit, form library, state library, router, or table library without documenting the reason.
- Do not create a monorepo until shared packages justify it.
- Do not install app dependencies at the `app-dev` root unless they are workspace tooling.
- Do not start material implementation without an active numbered spec and current tasks file.
- Do not skip `workflow-receipts.md`; it is required workflow evidence for app-dev work.
- Do not claim UI work is complete without rendered desktop and mobile checks.
- Do not commit secrets or production environment files.
