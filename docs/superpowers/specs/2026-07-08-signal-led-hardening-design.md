# Signal-Led App-Dev Hardening Design

Date: 2026-07-08
Status: Revised after plugin and local workflow review

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

## Capability Routing

The app-dev local workflows remain the enforceable contract. External plugin skills are accelerators that must be recorded in workflow receipts when used or unavailable.

Use this routing for the phase:

- `cross-platform-app-workflow`: required local workflow for Signal scaffolding, modular app work, and verification.
- `ui-change-workflow`: required for routes, components, layouts, styles, rendered UI behavior, and responsive checks.
- `data-change-workflow`: required for Supabase, SQL, RLS, migrations, schemas, and data access changes.
- `release-readiness-workflow`: required for completion claims, PR readiness, deploy-adjacent work, secrets, public APIs, auth, live migrations, or production-readiness surfaces.
- GitHub plugin: repository orientation, PR/issue context, PR creation, review follow-up, and GitHub workflow triage.
- Codex Security plugin: threat-model creation, scoped security scans, finding validation, and attack-path analysis for high-risk changes or release gates.
- Supabase plugin: Postgres schema, query, RLS, connection, and performance review.
- Product Design plugin: product UI brief confirmation, UX direction, and interface exploration before major UI buildout.
- Data Analytics plugin: product proof metrics, opportunity sizing, source authority, and Signal scoring/idea-quality evaluation.
- Creative Production plugin: brand, positioning, mood board, scene, ad, or asset exploration when Signal or future products need market-facing creative direction.
- CircleCI plugin: only when a project intentionally uses CircleCI or when GitHub Actions is insufficient for CI needs; otherwise GitHub Actions remains the default CI baseline.

## App-Dev Core Constitution

The app-dev core constitution is the standing rule set for the root workspace: standards, templates, workflow scripts, skills, hooks, command routines, source adoption, and update policy.

### Free-Tier First

All generated apps must start on free or no-cost tiers until product proof or production need justifies a paid service. Product proof may be user validation, revenue path, customer-facing uptime need, hard quota exhaustion, or a compliance/security requirement that cannot be met on a free plan.

Paid-service adoption requires a recorded decision in the active spec `plan.md`, the active spec when relevant, and any launch-readiness checklist that applies.

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

### Library And Module Adoption Routine

Every new reusable module, library, or service must pass an adoption routine before it becomes an app-dev default:

1. Define the product or harness problem it solves.
2. Check whether an existing repo module, template, script, or standard already covers the need.
3. Check the approved source hierarchy and prefer official docs or mature stack libraries.
4. Record free-tier, license, security, maintenance, and portability implications.
5. Decide the placement: core template, optional app module, project-local dependency, or rejected.
6. Add or update tests, examples, standards, and workflow receipts that make the adoption repeatable.

Project-local experimentation is allowed, but promotion into app-dev core requires evidence from at least one real project slice and a recorded backport decision.

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
- repository threat model for apps that introduce auth, personal data, public APIs, payments, uploads, AI tool actions, production deployment, or multi-user access
- scoped security scan before public launch and after material changes to auth, RLS, secrets, public APIs, payments, uploads, or AI tool actions

Sensitive features require an expanded checklist before implementation. Sensitive features include auth, payments, public APIs, user content, uploads, personal data, live migrations, AI tool actions, and production deployment.

### Security Review Routine

Security review is risk-triggered:

1. Low-risk personal/internal slices use the baseline checklist, secret scan, dependency checks, and workflow receipts.
2. Data, auth, public API, RLS, or deployment changes require a threat-model note in the active spec or a repo-scoped threat model when the app is becoming productized.
3. Public launch, customer data, payments, file uploads, AI tool actions, or production auth require Codex Security review or an equivalent documented security review before release.
4. Findings must be recorded as fixed, accepted risk, deferred with reason, or not applicable.

Signal v1 is low-risk if it remains single-user, no-auth, public-source-only, and internal. It becomes higher risk when it adds accounts, sharing, private notes, user profiles, public APIs, or production deployment.

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

### CI Provider Rule

GitHub Actions is the default CI provider because it is already aligned with GitHub repository governance. CircleCI is an approved optional provider only when a project documents a reason such as workflow portability, better parallelism, runner needs, queue/runtime constraints, or a customer/team requirement.

When CircleCI is used, its config must follow the CircleCI config workflow: establish baseline job duration and flake data, remove duplicate pipeline work, use deterministic lockfile-based cache keys, separate caches from workspaces and artifacts, and validate runtime or reliability impact. CircleCI free-tier limits must be recorded before adoption.

### Project GitHub Routine

Each real app under `projects/<app>` remains tracked in the app-dev root repository by default. A project may move to a separate repository only through a recorded decision justified by ownership, release, access-control, scale, or lifecycle needs.

Each tracked project should preserve:

- project `AGENTS.md`
- `plan.md`
- numbered specs under `specs/`
- workflow receipts
- app-local CI checks
- dependency update configuration
- secrets kept out of git
- release-readiness evidence before public launch

Project GitHub setup should also define:

- repository visibility and ownership
- branch protection expectations available on the current plan
- required checks for merge
- secret locations and environment names
- dependency update cadence
- issue labels or project tracking fields for product, security, compliance, and harness-backport work
- release tag and changelog routine once the app is public

## Projects Core Assembly Methodology

The projects core is the method for turning a scoped product into a built app under `projects/`.

1. Skeleton: define app identity, platform targets, user roles, routes, data model, module map, Supabase boundary, GitHub routine, and compliance class.
2. Module selection: reuse app-dev modules first, approved libraries second, and custom modules last.
3. UI/UX assembly: start from shadcn/ui, Radix, Tailwind, and existing app-dev layout patterns; check complex interactions against WAI-ARIA APG.
4. Data assembly: define Supabase schema, migrations, RLS posture, TanStack Query hooks, Zod schemas, retention, and source terms.
5. Verification assembly: run typecheck, lint, tests, build, e2e when available, rendered desktop/mobile checks, workflow receipt validation, and launch-readiness checks.
6. Backport loop: record reusable discoveries and promote them into app-dev core only when Signal proves they are generally useful.

### Assembly Evidence

Each project should maintain assembly evidence in its active spec, `plan.md`, or workflow receipts:

- which template was used and why
- which modules were reused unchanged
- which modules were adapted
- which libraries were selected from approved sources
- which new custom code was necessary and why
- which decisions should be backported to app-dev core
- which decisions should remain project-local

## Idea-To-Product Intake

Signal will eventually generate candidate ideas. app-dev needs a disciplined import path so those ideas become buildable projects instead of vague prompts.

The intake pipeline is:

1. Idea capture: raw Signal finding, source evidence, trend cluster, target user, problem, opportunity, and confidence.
2. Concept brief: who it is for, what problem it solves, why now, what already exists, smallest useful version, and kill risks.
3. Product shaping: user workflows, platform target, data model, modules, compliance/security class, free-tier services, monetization assumption, and proof target.
4. App-dev import: create `projects/<app>` from the selected template, import the product spec into `projects/<app>/specs/001-<slug>/spec.md`, update `plan.md`, initialize `tasks.md`, `workflow-receipts.md`, and add required compliance checklist items.
5. Assembly plan: choose existing modules first, approved libraries second, and new custom modules last.
6. Development loop: build vertical slices, verify them, and backport reusable improvements.

No idea should become a project until it has passed concept brief, product spec, app-dev import, and assembly plan.

The concept brief should include an evidence score, not just a narrative. Signal should track enough source metadata to support product-business analysis: source count, source authority, recency, engagement, repeated mentions, category, target user, comparable products, and confidence. Future dashboards can use those fields to evaluate whether Signal is producing useful product ideas.

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
- data-quality checks for duplicate source items, malformed payloads, stale sources, and scoring edge cases
- product-proof metrics for idea volume, source coverage, ranking usefulness, and concept conversion rate

Supabase Free tier is allowed for Signal because this is a personal/internal MVP. The app must document free-tier operating boundaries, including the risk that a free project can pause after inactivity and that free quotas can change. Before production or public use, the live Supabase pricing page must be checked and the active spec `plan.md` must record whether Free remains acceptable or Pro is required.

Signal database work must follow Supabase/Postgres guardrails:

- migrations are source controlled
- exposed-schema tables have RLS deliberately enabled or a documented reason why they are not exposed to untrusted clients
- service-role keys are never used in browser code or committed
- source-item queries have indexes for source, external id, published time, score, and status as needed
- scoring logic is testable outside the database before it is promoted into views or functions
- retention rules are recorded before source volume grows beyond MVP scale

## First Implementation Slice

The first implementation slice should produce both product value and harness evidence:

1. Create `projects/signal` from the React/Vite/Capacitor template.
2. Update the initial scaffold spec into a Signal-specific `001-signal-foundation` spec.
3. Define the Signal `plan.md` decisions for Supabase, free-tier boundaries, no-auth v1, source adapters, and GitHub routine.
4. Add the first Supabase schema/migration artifacts for persisted source items and settings.
5. Add local mock ingestion for GitHub and Hacker News payloads before depending on scheduled production ingestion.
6. Build the initial ranked feed from persisted or fixture-backed items.
7. Add workflow receipts for UI, data, and release-readiness obligations.
8. Run app-dev project artifact checks and app verification.
9. Record every harness gap as either fixed immediately, deferred, or rejected as not general enough.
10. Record plugin accelerators used or unavailable in the relevant receipts.

## Second Implementation Slice

Slice 2 is a convergence slice. It must remove defects and contradictions exposed by Slice 1 before widening Signal to more sources, scheduled ingestion, auth, or public launch.

### Slice 2A: Harness Convergence

Slice 2A hardens the app-dev control surface:

1. Replace command-line Boolean toggles in `scripts/*.ps1` with PowerShell switches while retaining ordinary Boolean parameters inside helper functions.
2. Extract shared failure collection, path resolution, and risk vocabulary into `scripts/common.ps1`.
3. Add `scripts/analyze-spec.ps1` to detect contradictions among `spec.md`, `plan.md`, `tasks.md`, gated review artifacts, and the live file tree.
4. Treat `sensitive` and `gated` as equivalent gated-path risk terms until the repository adopts one canonical term.
5. Add focused harness regression tests for switch invocation, risk classification, stale status, false-complete removal tasks, and missing verification evidence.
6. Make script failures identify the exact corrective command or artifact.
7. Add explicit `NEEDS CLARIFICATION` and complexity/deviation fields to the planning template.
8. Add a versioned `standards/constitution.md` that delegates detailed rules to existing standards rather than duplicating them.
9. Move Signal CI responsibility to the root GitHub Actions workflow and validate the tracked `projects/signal` app from the root repository.
10. Reconcile stale same-repo versus nested-repo guidance, obsolete ignore assumptions, and broken command examples across root and Signal documentation.

Renaming gated `checklist.md` files is deferred unless it can be completed atomically across scripts, templates, tests, generated apps, and documentation. The existing filename remains a contract during Slice 2A.

### Slice 2B: Signal Live Settings Persistence

Slice 2B proves the hardened harness through one narrow product path:

1. Remove orphaned auth module files and remaining template identity.
2. Add a browser-safe Supabase repository for source settings and keyword filters.
3. Keep a deterministic fixture/local fallback for missing, paused, or unavailable free-tier Supabase.
4. Add deliberate RLS policies before browser reads or writes are enabled.
5. Hydrate settings through TanStack Query and persist mutations with explicit pending, success, and error states.
6. Verify persistence behavior, fallback behavior, no-auth security assumptions, and desktop/mobile settings flows.
7. Record whether the settings repository is reusable enough to backport; do not promote it based on one use without evidence.

### Slice 2 Exit Criteria

- Root governance and workflow gates pass.
- `analyze-spec.ps1` passes for Signal spec 002 and fails its contradiction fixtures.
- Root GitHub Actions validates both app-dev and Signal.
- Signal source settings persist through Supabase when configured and degrade explicitly when unavailable.
- No auth module or template package identity remains in Signal.
- Signal typecheck, lint, tests, build, e2e, rendered desktop/mobile checks, workflow receipts, secret scan, and migration/RLS review are complete.
- Every audit finding in scope is closed, deferred with a reason, or rejected with evidence.

## Non-Goals

- Do not build a generic multi-tenant SaaS shell for Signal v1.
- Do not implement overlay or manifest-based app assembly before Signal proves the need.
- Do not add all source adapters before the GitHub and Hacker News adapter pattern is proven.
- Do not adopt paid tiers before product proof or production need is recorded.
- Do not add new custom framework code when existing app-dev patterns or proven libraries are sufficient.
- Do not introduce CircleCI as a second CI system unless a documented project or governance need outweighs the added maintenance surface.
- Do not run a full repository-wide security scan for every small internal slice; escalate security review by risk trigger.

## Source Anchors

- Supabase pricing and plan boundaries: https://supabase.com/pricing
- GitHub pricing and plan boundaries: https://github.com/pricing
- GitHub security features: https://docs.github.com/en/code-security/getting-started/github-security-features
- GitHub Actions usage and administration: https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/usage-limits-billing-and-administration
- CircleCI pricing and plan boundaries: https://circleci.com/pricing/
- CircleCI config optimization: local CircleCI config skill
- OWASP ASVS: https://owasp.org/www-project-application-security-verification-standard/
- Supabase RLS: https://supabase.com/docs/guides/database/postgres/row-level-security
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
