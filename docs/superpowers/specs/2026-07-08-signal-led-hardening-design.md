# Signal-Led App-Dev Hardening Design

Date: 2026-07-08
Status: Draft for user review

## Purpose

The next app-dev phase will use `projects/signal` as the first real reference app while hardening the app-dev repository around actual assembly pressure. The goal is to prove that app-dev can turn ideas into modular, governed, cross-platform product apps without continuing meta-work in isolation.

Signal is a personal tech and AI trend-scouting dashboard. It will ingest public source data, normalize items, score them, and present a useful ranked feed. It will also become the first producer of future product concepts that can be shaped into scoped app-dev projects.

## Scope

This phase has four coupled lanes:

1. Signal app development.
2. app-dev core hardening.
3. projects core hardening.
4. Idea-to-product intake.

The lanes must move together. A Signal feature should validate or improve a concrete part of the harness, and a harness change should be justified by a real Signal or project-assembly need.

## App-Dev Core Constitution

The app-dev core constitution is the standing rule set for the root workspace: standards, templates, workflow scripts, skills, hooks, command routines, source adoption, and update policy.

### Free-Tier First

All generated apps must start on free or no-cost tiers until product proof or production need justifies a paid service. Product proof may be user validation, revenue path, customer-facing uptime need, hard quota exhaustion, or a compliance/security requirement that cannot be met on a free plan.

Paid-service adoption requires a recorded decision in the app `PLAN.md`, the active spec when relevant, and any launch-readiness checklist that applies.

This rule applies to Supabase, GitHub, hosting, analytics, email, AI APIs, monitoring, storage, and future services added to the standard stack.

### Modular Assembly First

Build by assembling governed parts before writing new product code from scratch:

1. Reuse existing app-dev modules, templates, routines, and standards.
2. Use approved libraries and official patterns when the repo lacks a reusable part.
3. Write a new custom module only when neither the repo nor a reliable library solves the product need cleanly.
4. Promote reusable patterns discovered in Signal back into app-dev as standards, templates, scripts, skills, examples, or checklists.

### Proven Source Adoption

New libraries, UI components, workflow patterns, and backend services must be adopted through a source hierarchy:

1. Official docs for the default stack: React, Vite, React Router, Tailwind CSS, Supabase, GitHub, Playwright.
2. Accessibility and security authorities: WAI-ARIA APG, OWASP ASVS, OWASP cheat sheets, European Commission GDPR guidance.
3. Proven stack libraries: shadcn/ui, Radix primitives, TanStack Query, TanStack Table, Zod, React Hook Form, Recharts or ECharts.
4. Community examples only when current, reputable, source reviewed, and converted into local repo standards before repeated use.

Each adoption that changes app-dev defaults must document why the source is trusted, what problem it solves, and whether it belongs in the core template, an optional module, or project-local code only.

## Compliance And Security Baseline

Compliance is part of product design, not launch cleanup. This baseline is engineering governance, not legal advice.

Every app must classify its data and risk before implementation work:

- personal data or no personal data
- public, internal, or sensitive source data
- authentication and authorization requirements
- payments, uploads, user-generated content, AI tool actions, public APIs, or live migrations
- source/API terms obligations
- retention, export, and deletion expectations
- production uptime and incident-response expectations

Baseline checks for all apps:

- secret scanning and `.env` discipline
- dependency vulnerability checks
- license review for new libraries
- GitHub Actions verification gates
- Dependabot or equivalent dependency update routine where GitHub supports it
- OWASP-oriented checklist for access control, injection, secrets, misconfiguration, vulnerable dependencies, logging, and API exposure
- Supabase checks for publishable keys only, no service-role leakage, migrations, backup/export posture, RLS posture when user data or multi-user access exists
- GDPR-oriented checks for purpose limitation, minimization, retention, access/export/delete readiness, security controls, and accountability
- launch checklist for privacy notice, cookies/tracking, production monitoring, rollback, domains, and support/contact path

Sensitive features require an expanded checklist before implementation. Sensitive features include auth, payments, public APIs, user content, uploads, personal data, live migrations, AI tool actions, and production deployment.

## GitHub Requirements

GitHub routines exist at two levels.

### app-dev Core GitHub Routine

The root repo should maintain:

- protected `main` expectations where available
- `codex/` branch prefix for Codex implementation branches unless a task says otherwise
- PR-based review for material governance, template, hook, workflow, or security changes
- Actions checks for workspace validation
- secret scanning where available
- dependency review and Dependabot where available
- clear release notes or audit entries for governance changes
- no forced pushes unless explicitly requested and the branch is confirmed

GitHub tier limits must be treated like any other free-tier boundary. Use free capabilities until a product or governance need justifies an upgrade.

### Project GitHub Routine

Each real app under `projects/<app>` should normally become its own repository once it is more than a local scaffold. Before that split, app-dev owns its assembly evidence.

Project repos should preserve:

- project `AGENTS.md`
- `PLAN.md`
- numbered specs under `specs/`
- workflow receipts
- app-local CI checks
- dependency update configuration
- secrets kept out of git
- release-readiness evidence before public launch

## Projects Core Assembly Methodology

The projects core is the method for turning a scoped product into a built app under `projects/`.

1. Skeleton: define app identity, platform targets, user roles, routes, data model, module map, Supabase boundary, GitHub routine, and compliance class.
2. Module selection: reuse app-dev modules first, approved libraries second, and custom modules last.
3. UI/UX assembly: start from shadcn/ui, Radix, Tailwind, and existing app-dev layout patterns; check complex interactions against WAI-ARIA APG.
4. Data assembly: define Supabase schema, migrations, RLS posture, TanStack Query hooks, Zod schemas, retention, and source terms.
5. Verification assembly: run typecheck, lint, tests, build, e2e when available, rendered desktop/mobile checks, workflow receipt validation, and launch-readiness checks.
6. Backport loop: record reusable discoveries and promote them into app-dev core only when Signal proves they are generally useful.

## Idea-To-Product Intake

Signal will eventually generate candidate ideas. app-dev needs a disciplined import path so those ideas become buildable projects instead of vague prompts.

The intake pipeline is:

1. Idea capture: raw Signal finding, source evidence, trend cluster, target user, problem, opportunity, and confidence.
2. Concept brief: who it is for, what problem it solves, why now, what already exists, smallest useful version, and kill risks.
3. Product shaping: user workflows, platform target, data model, modules, compliance/security class, free-tier services, monetization assumption, and proof target.
4. App-dev import: create `projects/<app>` from the selected template, import the product spec into `projects/<app>/specs/001-<slug>/spec.md`, update `PLAN.md`, initialize `tasks.md`, `workflow-receipts.md`, and add required compliance checklist items.
5. Assembly plan: choose existing modules first, approved libraries second, and new custom modules last.
6. Development loop: build vertical slices, verify them, and backport reusable improvements.

No idea should become a project until it has passed concept brief, product spec, app-dev import, and assembly plan.

## Signal V1 Reference App

Signal will be created as `projects/signal` from `react-vite-capacitor`.

V1 product scope:

- GitHub and Hacker News source ingestion
- Supabase persistence from day one
- normalized source items
- simple scoring based on recency and engagement
- ranked feed
- source and keyword filters
- source settings
- no auth in v1 unless a real sharing or multi-user requirement appears

V1 technical scope:

- `sources` module for adapters, schemas, ingestion services, and source settings
- `dashboard` module for ranked feed and trend surface
- `settings` module for source toggles and filters
- Supabase migrations for persisted source items, source settings, and scored view or query layer
- TanStack Query for async state
- Zod for source payload validation and normalized item schemas
- tests for adapters, scoring, schemas, and key UI flows
- rendered desktop and mobile checks before handoff

Supabase Free tier is allowed for Signal because this is a personal/internal MVP. The app must document free-tier operating boundaries, including the risk that a free project can pause after inactivity and that free quotas can change. Before production or public use, the live Supabase pricing page must be checked and the app `PLAN.md` must record whether Free remains acceptable or Pro is required.

## First Implementation Slice

The first implementation slice should produce both product value and harness evidence:

1. Create `projects/signal` from the React/Vite/Capacitor template.
2. Update the initial scaffold spec into a Signal-specific `001-signal-foundation` spec.
3. Define the Signal `PLAN.md` decisions for Supabase, free-tier boundaries, no-auth v1, source adapters, and GitHub routine.
4. Add the first Supabase schema/migration artifacts for persisted source items and settings.
5. Add local mock ingestion for GitHub and Hacker News payloads before depending on scheduled production ingestion.
6. Build the initial ranked feed from persisted or fixture-backed items.
7. Run app-dev project artifact checks and app verification.
8. Record every harness gap as either fixed immediately, deferred, or rejected as not general enough.

## Non-Goals

- Do not build a generic multi-tenant SaaS shell for Signal v1.
- Do not implement overlay or manifest-based app assembly before Signal proves the need.
- Do not add all source adapters before the GitHub and Hacker News adapter pattern is proven.
- Do not adopt paid tiers before product proof or production need is recorded.
- Do not add new custom framework code when existing app-dev patterns or proven libraries are sufficient.

## Source Anchors

- Supabase pricing and plan boundaries: https://supabase.com/pricing
- GitHub pricing and plan boundaries: https://github.com/pricing
- GitHub security features: https://docs.github.com/en/code-security/getting-started/github-security-features
- GitHub Actions usage and administration: https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/usage-limits-billing-and-administration
- OWASP ASVS: https://owasp.org/www-project-application-security-verification-standard/
- European Commission data protection: https://commission.europa.eu/law/law-topic/data-protection_en
- GDPR Article 5 principles: https://gdpr.eu/article-5-how-to-process-personal-data/
- WAI-ARIA APG: https://www.w3.org/WAI/ARIA/apg/
- React docs: https://react.dev/
- Vite guide: https://vite.dev/guide/
- React Router docs: https://reactrouter.com/home
- Tailwind CSS with Vite: https://tailwindcss.com/docs/installation/using-vite
- shadcn/ui docs: https://ui.shadcn.com/docs
- Radix primitives: https://www.radix-ui.com/primitives/docs/overview/introduction
- TanStack Query: https://tanstack.com/query/latest
- TanStack Table: https://tanstack.com/table/latest
- Playwright docs: https://playwright.dev/docs/intro

## Approval Gate

This design should be reviewed before implementation planning starts. After approval, create an implementation plan that sequences Signal app work with the app-dev core and projects core hardening loop.
