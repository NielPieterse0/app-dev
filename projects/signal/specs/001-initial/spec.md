# 001 Signal Foundation Specification

- Status: completed
- Risk level: gated
- App: signal
- Created: 2026-07-08

## Summary

Deliver the first real Signal slice: a no-auth internal trend-scouting dashboard with GitHub and Hacker News source fixtures, a Supabase-ready persistence boundary, source settings, and workflow evidence that tests the app-dev harness on a real project.

## Problem

app-dev currently has templates and governance, but no real application proving that the modular assembly workflow holds up under product pressure. Signal must become that proof case while also producing a useful ranked feed of public-source trend items.

## Users And Scenarios

- Primary users: a single operator reviewing public-source trend signals and converting promising items into future product ideas.
- Core scenario: open the dashboard, review ranked items, filter by source or keywords, inspect why an item ranks highly, and tune which sources or topics stay in scope.
- Out of scope: multi-user auth, public launch, live scheduled ingestion, private data collection, and sources beyond GitHub and Hacker News.

## Requirements

### Functional Requirements

1. Signal must provide a working dashboard that lists normalized GitHub and Hacker News items ranked by recency and engagement.
2. Signal must define a stable data boundary that starts with local fixtures but is shaped for Supabase persistence from day one.
3. Signal must expose settings for source toggles and keyword filters without requiring authentication.
4. Signal must replace generic template copy, routes, and demo auth surfaces with product-specific behavior.
5. Signal must keep project workflow artifacts, receipts, and gated-checklist notes current throughout the slice.

### Acceptance Criteria

1. `projects/signal` contains Signal-specific `AGENTS.md`, `PLAN.md`, `spec.md`, `tasks.md`, `workflow-receipts.md`, and `checklist.md`.
2. The dashboard loads a ranked feed from the repository layer and supports at least one meaningful filter interaction.
3. The first Supabase migration exists for `source_items` and `source_settings`, with documented free-tier and browser-key constraints.
4. The settings route reflects source controls and operating-boundary notes rather than template placeholders.
5. The slice can run the strongest available checks, or records exact blockers when a check cannot run.

## Data And Permissions

- Data model impact: add normalized source items, source settings, score fields, timestamps, and source metadata shaped for later idea scoring.
- Permissions: no user accounts in this slice; browser reads remain limited to publishable-key-safe surfaces and local fixtures.
- Sensitive operations: schema design, future RLS posture, public-source API terms tracking, and environment key handling.

## UX And Platform Notes

- Target surfaces: desktop web and mobile web now; keep the Capacitor-ready shell but do not add native packaging work.
- States: dashboard must include loading, error, empty, and populated ranked-feed states; settings must include explanatory empty/help states.
- Native needs: none for this slice.

## Risks And Open Questions

- Risks: fixture-backed ingestion may drift from live API payloads; template auth examples may leak into the product surface; dependency install or Playwright execution may be blocked by the local environment.
- Open questions: whether the first slice should read through optional Supabase-backed queries immediately or stay fixture-only behind the repository interface if local backend setup blocks it.

## Verification Intent

- Pre-implementation gate: run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` after updating this spec set.
- Workflow evidence gate: keep `workflow-receipts.md` current and run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` before completion.
- Completion checks: run `../../scripts/verify-app.ps1 -ProjectPath .` plus rendered desktop and mobile checks before handoff.
