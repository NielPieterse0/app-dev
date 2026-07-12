---
name: ui-change-workflow
description: app-dev workflow receipt and rendered verification contract for UI routes, components, layouts, styles, and user-facing interaction changes.
metadata:
  owner: app-dev
  version: 1.0.0
  maturity: stable
---

# UI Change Workflow

Use this local workflow whenever app-dev work changes a user-facing UI surface.

## Trigger Surface

This workflow is required when the task or changed files touch:

- `src/components/`
- `src/routes/`
- `src/app/`
- `src/modules/*/components/`
- `src/modules/*/routes/`
- app CSS, Tailwind, or layout styling
- rendered UI behavior, responsive fixes, or design refresh work

## Required Inputs

1. Active spec under `specs/NNN-<slug>/`.
2. Current `tasks.md`.
3. `workflow-receipts.md` in the active spec directory.

## Required Receipt

Update the `## UI Change Workflow Receipt` section in `workflow-receipts.md` with:

- trigger surface
- command path used
- local workflow used
- external skill used or unavailable
- files and surfaces reviewed
- verification performed
- outstanding gaps
- decision and closure

## Verification Contract

- Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before handoff.
- Run `../../scripts/verify-app.ps1 -ProjectPath .`.
- Record rendered desktop and mobile checks.
- Record the first meaningful screen and one core interaction path.

## External Accelerators

This workflow must use:

- `C:/Users/piete/.codex/skills/frontend-app-builder/SKILL.md` when work touches React, Next.js, Expo, or Capacitor app scaffolding, routing, or module boundaries
- `C:/Users/piete/.codex/skills/rontend-testing-debugging/SKILL.md` when work touches rendered UI, Playwright, or testing/debugging surfaces
- `C:/Users/piete/.codex/skills/react-best-practices/SKILL.md` when work touches React app scaffolding, routing, or module boundaries
- `C:/Users/piete/.codex/skills/shadcn-best-practices/SKILL.md` when work touches shadcn/ui, Radix, or Tailwind surfaces
- `C:/Users/piete/.codex/skills/playwright/SKILL.md` when work touches rendered UI, Playwright, or testing/debugging surfaces

If none are available, continue with local app-dev standards and record the gap in the receipt.
