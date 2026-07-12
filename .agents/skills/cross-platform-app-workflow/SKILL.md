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
3. Read the active spec's `plan.md` when present. Create one from `templates/spec-workflow/plan.template.md` for architectural or multi-module work.
4. Load only the reference file needed for the task:
   - `../../../standards/stack.md` for app-type or library decisions.
   - `references/module-contract.md` for module structure.
   - `../../../standards/adaptive-layouts.md` for responsive UI work.
   - `../../../standards/testing.md` for verification and rendered QA.
   - `../../../standards/spec-driven-workflow.md` for numbered specs, tasks, and gated-path rules.
   - `../../../standards/command-workflow-contract.md` for local command and receipt obligations when relevant.
5. Reuse `templates/` before inventing structure.

## Workflow

The canonical workflow lives in `../../../standards/spec-driven-workflow.md` and is executed through `.agents/commands/`.

App-specific responsibilities in this skill:

1. Capture or confirm durable app identity in app `AGENTS.md` and keep the active spec pointer current.
2. Select the simplest app type for the requirement set.
3. Keep the active `plan.md`, `tasks.md`, `workflow-receipts.md`, and `checklist.md` aligned before material implementation, and resolve `/analyze` contradictions before starting code changes.
4. Build the base shell before feature modules, then implement vertical modules with public `@/modules/<module>` boundaries only.
5. Classify the work into any required local wrapper workflows and keep the matching receipt sections current.
   - `ui-change-workflow` and use `.agents/skills/ui-change-workflow/SKILL.md`
   - `data-change-workflow` and use `.agents/skills/data-change-workflow/SKILL.md`
   - `mobile-validation-workflow` and use `.agents/skills/mobile-validation-workflow/SKILL.md`
   - `release-readiness-workflow` and use `.agents/skills/release-readiness-workflow/SKILL.md`
6. Reuse standard libraries and local templates, close implementation through `/converge`, then finish with the workflow-required verification and rendered checks.

## External Capabilities

Other skills or plugins are external/global capabilities. Use them when relevant; if unavailable, continue with local standards and report the gap.

Consult `standards/codex-capabilities.md` for routing guidance before using external/global  capabilities for frontend UI, rendered QA, shadcn/ui, React/Next, Supabase, Playwright, security, GitHub, mobile emulators, dashboards, OpenAI API work, payments, or deployment. External skills are accelerators; the local wrapper workflows are the enforceable contract.

## Guardrails

- Do not add a second UI kit, form library, state library, router, or table library without documenting the reason.
- Do not create a monorepo until shared packages justify it.
- Do not install app dependencies at the `app-dev` root unless they are workspace tooling.
- Do not start material implementation without an active numbered spec and current tasks file.
- Do not skip `workflow-receipts.md`; it is required workflow evidence for app-dev work.
- Do not claim UI work is complete without rendered desktop and mobile checks.
- Do not commit secrets or production environment files.
