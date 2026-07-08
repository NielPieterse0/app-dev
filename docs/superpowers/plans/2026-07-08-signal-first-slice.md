# Signal First Slice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `projects/signal` as the first real app in `app-dev`, replace the placeholder scaffold artifacts with a Signal-specific foundation slice, and deliver a working GitHub/Hacker News trend dashboard backed by Supabase-ready schemas and local mock data.

**Architecture:** Scaffold from the existing `react-vite-capacitor` template, preserve the module boundary contract, add a new `sources` module for normalized source items and settings, repurpose the dashboard for ranked trend display, and keep Supabase integration browser-safe with publishable-key-only client code and migration-first schema files. The first slice remains internal, no-auth, and fixture-backed for ingestion while still wiring the persistence boundary and workflow receipts.

**Tech Stack:** TypeScript, React, Vite, React Router, Tailwind CSS, shadcn/Radix primitives already in template, Zod, Zustand, TanStack Query, Supabase JS, Vitest, Testing Library, Playwright, local app-dev workflow scripts.

## Global Constraints

- Use `projects/signal` from the `react-vite-capacitor` template.
- Keep work on a non-`main` branch.
- No secrets or service-role keys in repo or browser code.
- Free-tier-first and no-auth v1 must be documented in project artifacts.
- Use numbered spec artifacts and keep `AGENTS.md`, `PLAN.md`, `spec.md`, `tasks.md`, `workflow-receipts.md`, and `checklist.md` aligned.
- Treat `ui-change-workflow`, `data-change-workflow`, and `release-readiness-workflow` as required for this slice.
- Reuse template patterns before adding abstractions.

---

### Task 1: Scaffold Signal And Create Execution Branch

**Files:**
- Create: `projects/signal/**`
- Create: `docs/superpowers/plans/2026-07-08-signal-first-slice.md`
- Modify: `projects/signal/AGENTS.md`

**Interfaces:**
- Consumes: `scripts/create-app.ps1 -Name signal -Template react-vite-capacitor`
- Produces: `projects/signal` scaffold with baseline app shell and spec artifacts

- [ ] Create branch `codex/signal-first-slice`.
- [ ] Run the scaffold script to create `projects/signal` from `react-vite-capacitor`.
- [ ] Review generated `projects/signal/AGENTS.md`, confirm active spec path, and change app identity text from generic scaffold wording to Signal-specific wording.
- [ ] Verify `projects/signal` contains `PLAN.md` and `specs/001-initial/{spec,tasks,workflow-receipts,checklist}.md`.

### Task 2: Replace Placeholder Planning Artifacts With Signal Foundation

**Files:**
- Modify: `projects/signal/PLAN.md`
- Modify: `projects/signal/specs/001-initial/spec.md`
- Modify: `projects/signal/specs/001-initial/tasks.md`
- Modify: `projects/signal/specs/001-initial/workflow-receipts.md`
- Modify: `projects/signal/specs/001-initial/checklist.md`

**Interfaces:**
- Consumes: Signal hardening design spec, root workflow rules
- Produces: active Signal foundation spec and project plan that downstream implementation can follow

- [ ] Rename the spec title and internal references to `001-signal-foundation` while keeping the folder `001-initial` unless script or validator constraints make that unsafe.
- [ ] Put the first implementation-slice work as the first task item in `tasks.md`.
- [ ] Update `PLAN.md` with concrete decisions for no-auth v1, free-tier-first, Supabase persistence, mock ingestion first, and GitHub routine.
- [ ] Mark `workflow-receipts.md` for required UI, data, and release-readiness workflows and seed the trigger surfaces.
- [ ] Update `checklist.md` for data access, RLS posture, secrets, source/API terms, and launch-not-now boundaries.

### Task 3: Add Signal Data Model And Sources Module

**Files:**
- Create: `projects/signal/supabase/migrations/001_signal_foundation.sql`
- Create: `projects/signal/src/modules/sources/index.ts`
- Create: `projects/signal/src/modules/sources/schemas/source-item.schema.ts`
- Create: `projects/signal/src/modules/sources/services/source-fixtures.ts`
- Create: `projects/signal/src/modules/sources/services/source-normalizer.ts`
- Create: `projects/signal/src/modules/sources/services/source-repository.ts`
- Create: `projects/signal/src/modules/sources/hooks/useSourceItems.ts`
- Create: `projects/signal/src/modules/sources/tests/source-normalizer.test.ts`
- Create: `projects/signal/src/modules/sources/tests/source-repository.test.ts`
- Modify: `projects/signal/src/lib/env.ts`
- Modify: `projects/signal/.env.example`

**Interfaces:**
- Consumes: `getSupabaseClient()`, existing env validation pattern
- Produces: `NormalizedSourceItem`, `SourceKind`, `getSeedSourceItems()`, `normalizeGithubItem()`, `normalizeHackerNewsItem()`, `listSourceItems()`

- [ ] Define normalized item and source-settings schemas with Zod.
- [ ] Create a first migration for `source_items` and `source_settings`, plus indexes needed for source, external id, published time, and score.
- [ ] Build mock GitHub and Hacker News fixture inputs and normalization helpers.
- [ ] Build a repository layer that can return seeded items now and later switch to Supabase-backed reads without changing route components.
- [ ] Add tests for normalization, duplicate handling, ordering, and malformed payload rejection.

### Task 4: Rework Dashboard And Settings Into Signal V1

**Files:**
- Modify: `projects/signal/src/app/NavigationShell.tsx`
- Modify: `projects/signal/src/app/routes.tsx`
- Modify: `projects/signal/src/modules/dashboard/routes/DashboardRoute.tsx`
- Modify: `projects/signal/src/modules/dashboard/components/*`
- Modify: `projects/signal/src/modules/dashboard/hooks/useDashboardModules.ts`
- Modify: `projects/signal/src/modules/dashboard/services/dashboard-service.ts`
- Modify: `projects/signal/src/modules/dashboard/state/dashboard-view-store.ts`
- Modify: `projects/signal/src/modules/dashboard/tests/*`
- Modify: `projects/signal/src/modules/settings/routes/SettingsRoute.tsx`
- Modify: `projects/signal/src/modules/settings/index.ts`

**Interfaces:**
- Consumes: `listSourceItems()`, source schemas, settings model
- Produces: working Signal trend dashboard, source filters, and source settings surface

- [ ] Replace generic dashboard copy and tables with Signal-specific ranked feed, summary metrics, and trend chart.
- [ ] Wire dashboard data flow through the new sources repository and a query hook.
- [ ] Replace generic settings content with source toggles, keyword controls, and free-tier boundary notes.
- [ ] Keep the UI dense and operational, not a marketing page.
- [ ] Update tests to cover first meaningful screen, filtered state, and empty/error cases.

### Task 5: Verify, Record Gaps, And Close The Slice

**Files:**
- Modify: `projects/signal/specs/001-initial/workflow-receipts.md`
- Modify: `projects/signal/specs/001-initial/tasks.md`
- Modify: `projects/signal/PLAN.md`
- Create: `projects/signal/specs/001-initial/converge.md` when useful for handoff

**Interfaces:**
- Consumes: app-dev verification scripts and app test scripts
- Produces: verified first slice with explicit blockers and harness-gap notes

- [ ] Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`.
- [ ] Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
- [ ] Run `../../scripts/verify-app.ps1 -ProjectPath .`.
- [ ] If dependencies are missing, install them inside `projects/signal` and rerun the checks.
- [ ] Run rendered desktop and mobile verification for the first meaningful Signal screen.
- [ ] Record harness gaps as fixed, deferred, or rejected in receipts and handoff notes.
