# Signal Slice 4A and 4B Design

Date: 2026-07-09
Status: Implemented on 2026-07-09

## Completion Note

Slice 4A and 4B were implemented and verified on 2026-07-09.

- The previously deferred live Supabase migration and smoke-verification gap was closed against bounded internal project `qwtfvuwkxtucgcteisfa`.
- Signal now includes concept promotion, concept editing, and Markdown/JSON export.
- Repo-surface drift called out in this design was reconciled in the live Signal README, plan, spec, checklist, and workflow receipts.
- Remaining deferred items below are product-scope deferrals by design, not unfinished Slice 4 implementation work.

The sections below capture the pre-implementation design and finding classification that drove the slice.

## Purpose

Signal Slice 4 should be split into two ordered parts:

- **Slice 4A** closes the remaining app-dev core findings, reconciles stale or superseded attached findings against the live tree, and performs a thorough repo-surface drift verification pass.
- **Slice 4B** turns Signal from a live-ingestion scouting dashboard into a product-shaping tool by adding concept capture, evidence review, export workflow, and a less Supabase-branded app boundary.

This split keeps the next product slice from landing on top of partially reconciled governance findings, stale docs, or backend-coupled product language.

## Why A 4A and 4B Split

Signal Slice 3 materially improved the repo and the app, but the attached review set spans multiple moments in time. Some findings are already fixed in the live tree, some are still open, and some have turned into drift rather than defects.

The current repo state shows three realities at once:

1. The root harness is in much better shape than several attached findings imply.
2. A few live gaps remain, especially verification truthfulness, README/doc drift, and backend-coupled product wording.
3. Signal now ingests and persists live source items, but it still stops short of its documented job of turning promising signals into future scoped product work.

If Slice 4 goes directly into the next Signal feature without reconciling the live core baseline first, the repo will keep carrying stale review baggage and product-facing copy drift. Slice 4A exists to finish that close-out cleanly. Slice 4B then widens Signal on top of a re-verified base.

## Reality Check Against The Attached Findings

The attached findings should not be treated as equally current. Slice 4A must begin by classifying them against the live tree.

### Already Closed In The Live Tree

These items appear fixed already and should become regression targets, not new work:

1. Signal package identity is now `signal`.
2. `specs/001-initial/spec.md` now reports `Status: completed`.
3. The dead nested Signal workflow is gone.
4. Root GitHub Actions already contains a `signal-validation` job in `.github/workflows/app-dev-validation.yml`.
5. Root `.gitignore` no longer carries the dead negation block.
6. `validate-workflow-receipts.ps1` and `verify-app.ps1` now use `[switch]` parameters instead of the broken bare `[bool]` flag pattern.
7. `check-spec-artifacts.ps1` now recognizes the repo's gated-risk vocabulary through `Test-GatedRiskLevel`.
8. The unused auth module has been removed from `projects/signal`.
9. The Slice 3 plan already records Signal as tracked in the root repository, not as a nested repository.

### Still Open Or Only Partially Closed

These should be active Slice 4A work items:

1. **Disposable Supabase smoke verification is still deferred**
   - the active Signal `plan.md` still records disposable migration and read/write smoke verification as deferred.
   - Slice 4A must close this with a bounded non-production verification path, not carry it forward again.

2. **Signal README drift**
   - `projects/signal/README.md` still says "Auth, sharing, source-item persistence, and scheduled ingestion stay out of scope for Slice 2."
   - That text is no longer true after Slice 3 and is the clearest live documentation drift item.

3. **Repo-surface drift needs a full pass**
   - Root docs, template docs, Signal docs, standards, scripts, and receipts should be rechecked against the live baseline rather than against older review snapshots.

4. **Verification truthfulness still depends too much on prose discipline**
   - The repo distinguishes mocked/unit coverage from live integration coverage in several places, but the rule is not yet hardened enough that future slices will reliably stay honest without a deliberate pass.

5. **Backend branding is too visible in product-facing UI**
   - Signal exposes Supabase-specific wording directly in app copy for flows that are really about "remote configured storage" versus "local fallback."
   - Supabase remains the default backend, but the app should not treat the vendor name as the product feature unless the screen is explicitly about infrastructure.

### Findings That Are Outdated Or Need Re-Scoping

These should be dispositioned explicitly so they do not create fake work:

1. The older "fixture-backed dashboard truth" finding is obsolete because Slice 3 replaced runtime fixture truth with persisted live source items.
2. The older chart token and refetch/draft-clobber findings should now be treated as regression checks, not fresh defects.
3. The older dead-code claim around `source-fixtures.ts` needs re-checking before deletion because that file still provides types and fixture helpers used by `source-normalizer.ts`.
4. Some prior CI and repo-topology findings now describe historical bugs, not live defects. Slice 4A should mark them as closed with evidence rather than re-open them.

## Scope Strategy

### Slice 4A: App-Dev Core Closeout And Drift Reconciliation

Slice 4A is a **closeout and drift-hardening slice**. It should finish the still-relevant core recommendations, codify which older findings are now stale, and leave both app-dev and Signal in one internally consistent verified state.

Primary outcomes:

1. Reconcile every attached core finding against the live tree as `fixed`, `still-open`, `superseded`, or `deferred with explicit blocker`.
2. Close the remaining live core gaps, including the deferred disposable Supabase smoke path.
3. Run a thorough drift verification sweep across root governance assets, templates, workflow scripts, CI, and Signal artifacts.
4. Reduce vendor-coupled default wording in core guidance where the concern is generic persistence, not Supabase-specific behavior.
5. Leave behind stronger regression checks so old findings do not silently reappear in Slice 5 or future apps.

### Slice 4B: Signal Slice 4 Product Development

Slice 4B is the next **product-widening slice** for Signal after live ingestion. It should implement the next product job already implied by Signal's app identity: promote strong signals into structured concept briefs for future app work.

Primary outcomes:

1. Add a concept-capture workflow from persisted live signals.
2. Add a concept review/export surface so promising signals can become durable, structured product briefs.
3. Reduce hardwired Supabase branding in app behavior by moving storage selection behind backend-neutral repository or provider boundaries.
4. Close small live app-drift items while the concept workflow is added.
5. Keep scheduled/background ingestion, auth, sharing, public launch, and native packaging deferred.

## Capability Routing

The local app-dev workflows remain the enforceable contract. External plugins are accelerators and reviewers that must be recorded in workflow receipts when used or unavailable.

### Slice 4A

- `release-readiness-workflow`: required because this slice is about completion truthfulness, CI/gate integrity, drift closure, and verification claims.
- `data-change-workflow`: required if disposable Supabase verification requires local stack setup, migration changes, or backend-factory cleanup.
- `ui-change-workflow`: required for README/app-copy drift and any app-facing backend-language corrections that land as part of closeout.
- Superpowers plugin: review sequencing, drift closeout, and implementation planning.
- Supabase plugin: review the disposable verification path and any backend abstraction guidance that still relies on Supabase assumptions.
- Codex Security plugin: review whether the no-auth internal-MVP posture and verification wording remain appropriately bounded after the closeout pass.

### Slice 4B

- `cross-platform-app-workflow`: required umbrella workflow.
- `ui-change-workflow`: required for the concept workflow, route additions, state transitions, and rendered checks.
- `data-change-workflow`: required for concept schemas, persistence, export payloads, and repository abstraction updates.
- `release-readiness-workflow`: required because the slice adds a new durable product surface and export behavior.
- Superpowers plugin: planning and execution workflow.
- Product Design plugin: optional review of the concept workspace and detail flow before implementation locks in.
- Data Analytics plugin: optional review of evidence scoring, concept metrics, and concept-quality fields.
- Supabase plugin: review concept persistence shape while keeping backend coupling bounded.

## Slice 4A Included Findings

The following items belong in Slice 4A and must be closed or explicitly dispositioned:

1. **Disposable Supabase verification gap**
   - Execute migration apply plus bounded read/write smoke verification against a disposable or local Supabase environment.
   - If local infrastructure is used, record the exact setup path and evidence.

2. **Signal README drift**
   - Update Signal's README and any matching app docs so the documented app surface matches the live Slice 3 baseline.

3. **Repo-wide drift sweep**
   - Re-check root `AGENTS.md`, `PLANS.md`, `README.md`, `standards/**`, templates, CI, scripts, and Signal artifacts for stale slice numbers, outdated scope notes, wrong repo-model wording, or obsolete commands.

4. **Verification-evidence truthfulness**
   - Harden the rule that mocked/unit validation and real integration validation must be separated in receipts, plans, and handoff notes.

5. **External-skill/accountability drift**
   - Make sure workflow receipts and standards are aligned on how optional accelerators such as Superpowers, Supabase, and other plugins are recorded when they materially shape the work.

6. **Backend-neutral default guidance**
   - Where the repo is teaching a generic persistence pattern, talk about configured remote storage versus local fallback unless the document is specifically about Supabase setup or security boundaries.

7. **Regression protection for formerly open core findings**
   - Add or improve the narrowest useful checks so the already-fixed CI, risk-gating, flag, and artifact consistency bugs are less likely to regress.

## Explicitly Deferred Beyond Slice 4A

These do not belong in the core closeout slice:

1. Scheduled or background ingestion.
2. Auth, sharing, public launch, multi-user access, or production RLS hardening.
3. Broad charting or bundle refactors.
4. Native packaging.
5. Additional source adapters beyond GitHub and Hacker News.
6. Direct workspace-file creation from the browser app.

## Slice 4A Architecture

### Findings Reconciliation Lane

Files likely affected:

- `docs/superpowers/specs/2026-07-09-signal-slice-4a-4b-design.md`
- `projects/signal/specs/NNN-<slug>/plan.md`
- `projects/signal/specs/**`
- `projects/signal/README.md`
- root `README.md` and relevant `standards/**` files if drift is found

Key design decisions:

1. **Treat findings as evidence, not truth**
   - Every attached finding should be checked against the live tree before it becomes a task.
   - Older closed findings should be retained as regression targets or historical notes, not reopened blindly.

2. **Create one live disposition table**
   - The closeout artifact should say whether each finding is `fixed`, `open`, `superseded`, or `deferred with blocker`.
   - This removes ambiguity about which findings Slice 4A is actually carrying.

### Verification Closure Lane

Files likely affected:

- `projects/signal/specs/NNN-<slug>/plan.md`
- `projects/signal/specs/003-live-ingestion/workflow-receipts.md`
- root or project verification notes if a durable evidence file is needed
- possibly `scripts/**` only if the current gates still leave ambiguity

Key design decisions:

1. **No second deferral of the same smoke path**
   - Slice 4A should close the disposable Supabase verification gap, not just restate it.
   - If cloud credentials are unavailable, a local Supabase stack or equivalent bounded non-production path should be used.

2. **Verification claims must name the proof level**
   - Unit and mocked adapter coverage should stay recorded.
   - Real migration apply and read/write smoke verification should be recorded separately with exact environment notes.

### Drift Guard Lane

Files likely affected:

- `scripts/analyze-spec.ps1`
- `scripts/check-spec-artifacts.ps1`
- `scripts/validate-workflow-receipts.ps1`
- template docs under `templates/**`
- app docs under `projects/signal/**`

Key design decisions:

1. **Automate only the repeated drift**
   - Add deterministic checks only for drift classes that are likely to recur, such as stale workflow commands, outdated active-slice wording, or repo-model contradictions.
   - Do not overbuild a generalized prose-linter.

2. **Use standards as the source of truth**
   - Drift checks should delegate to the canonical standards files rather than copying rules into several validators.

### Backend-Neutral Guidance Lane

Files likely affected:

- `standards/stack.md`
- `standards/workspace.md`
- template `README.md` and `AGENTS.md` files where generic persistence guidance appears
- `projects/signal/README.md`

Key design decisions:

1. **Supabase stays the default backend**
   - Slice 4A does not demote Supabase as the default stack choice.

2. **Generic behavior should use generic language**
   - Product docs and generic template guidance should distinguish "configured remote persistence" from "local fallback" unless the text is specifically about Supabase setup, env vars, or security posture.

## Slice 4A Verification Model

Slice 4A is complete only when all of the following are true:

1. Every still-relevant attached core finding has a live disposition and none remain silently ambiguous.
2. Root governance checks pass.
3. Signal artifact gates pass.
4. The deferred disposable Supabase migration and read/write smoke path has been executed successfully in a bounded non-production environment and recorded explicitly.
5. The repo-surface drift sweep has updated any stale docs, workflow text, or template guidance found during the pass.
6. Any remaining deferred items are outside Slice 4A by design and are recorded with exact reasons.

## Slice 4B Included Product Work

The following belongs in the next Signal product slice:

1. **Concept capture from live signals**
   - A persisted signal should be promotable into a structured concept draft.

2. **Concept workspace**
   - Signal needs a dedicated surface to review promoted ideas, edit concept fields, and manage concept status.

3. **Evidence summary derived from source items**
   - A concept should carry enough source-derived metadata to justify why it exists: linked signals, source mix, engagement, recency, keywords, and confidence inputs.

4. **Export workflow**
   - A concept should be exportable as a durable structured brief, preferably both human-readable and machine-readable.

5. **Backend decoupling at the app boundary**
   - The product should stop treating Supabase as the user-facing feature name for persistence flows that are really about configured remote storage plus local fallback.

6. **Small live app-drift corrections**
   - Standardize the remaining inconsistent imports and duplicate label mappings while the related routes and components are already being touched.

## Explicitly Deferred Beyond Slice 4B

These remain out of scope for the next product slice:

1. Scheduled or background ingestion.
2. Auth, sharing, comments, multi-user roles, or public launch.
3. More source adapters.
4. Native mobile packaging.
5. Broad chart-library replacement or major bundle work.
6. Direct creation of new `projects/<app>` folders from inside the browser app.

## Slice 4B Architecture

### Concept Domain Lane

Files likely affected:

- `projects/signal/src/modules/concepts/**`
- `projects/signal/supabase/migrations/004_signal_concepts.sql`
- `projects/signal/src/app/routes.tsx`
- `projects/signal/src/app/NavigationShell.tsx`

Key design decisions:

1. **Add a first-class `concepts` module**
   - Concept capture should not be bolted into `dashboard` or `settings`.
   - The new module should own schemas, repositories, routes, state, tests, and export helpers.

2. **Persist concepts separately from source items**
   - A concept is not just another source item.
   - It should have its own schema and lifecycle with linked evidence back to source items.

3. **Keep one-operator scope**
   - Concepts stay internal and single-operator in this slice.
   - No sharing, assignment, or collaboration model should be introduced.

### Source Review And Promotion Lane

Files likely affected:

- `projects/signal/src/modules/dashboard/**`
- `projects/signal/src/modules/concepts/**`
- `projects/signal/src/modules/sources/**`

Key design decisions:

1. **Promote from persisted live items**
   - The concept workflow should start from already-persisted source items, not from direct live fetch responses.

2. **Capture evidence at promotion time**
   - When a signal becomes a concept, the app should preserve the source item ids and a snapshot of the evidence fields needed for later review.

3. **Prefer detail-first UX**
   - A signal should be inspectable before it is promoted.
   - This can be a detail panel, detail route, or list-detail workflow, but the product should support "review, then promote" rather than only "promote blind from the table."

### Export And Intake Lane

Files likely affected:

- `projects/signal/src/modules/concepts/services/**`
- `projects/signal/src/modules/concepts/routes/**`
- `projects/signal/src/modules/concepts/tests/**`
- possibly `projects/signal/specs/004-*/checklist.md` for intake/export obligations

Key design decisions:

1. **Export structured briefs, not only labels**
   - The export surface should produce a concept brief with title, problem, target user, opportunity, evidence summary, risks, and confidence.

2. **Support a human-readable and machine-readable path**
   - Markdown or rich text is the operator-facing handoff format.
   - JSON or a stable typed object supports later automation without forcing direct repo writes from the browser.

3. **Do not directly mutate the workspace from the browser app**
   - Slice 4B stops at generating durable concept artifacts for handoff, copy, or download.
   - Actual `projects/<app>` creation remains an app-dev repo workflow, not an in-app side effect.

### Backend Abstraction Lane

Files likely affected:

- `projects/signal/src/lib/**`
- `projects/signal/src/modules/sources/services/**`
- `projects/signal/src/modules/concepts/services/**`
- app-facing copy in dashboard/settings/concepts routes

Key design decisions:

1. **Keep Supabase as the default adapter**
   - Slice 4B does not replace Supabase.

2. **Hide vendor choice behind repository factories**
   - App routes and components should consume a backend-neutral repository shape wherever possible.

3. **Use vendor-specific wording only in infrastructure contexts**
   - UI that describes storage mode to the user should prefer "remote workspace" or "configured remote backend" when the specific vendor is not the actual point.

### App Drift Cleanup Lane

Files likely affected:

- `projects/signal/src/modules/settings/routes/SettingsRoute.tsx`
- `projects/signal/src/app/NavigationShell.tsx`
- `projects/signal/src/modules/dashboard/routes/DashboardRoute.tsx`
- `projects/signal/src/modules/dashboard/components/RankedItemsTable.tsx`
- `projects/signal/src/modules/sources/schemas/source-item.schema.ts`

Key design decisions:

1. **Standardize imports while touched**
   - Move the remaining mixed relative-plus-alias patterns toward the app's public alias style when the file is already being edited.

2. **Create one source-label constant**
   - Keep the GitHub/Hacker News label mapping in a single reusable source-domain location rather than duplicating it in route and table code.

3. **Use shared UI primitives for stateful controls**
   - The dashboard source filter should align with the app's button primitives and active-state behavior rather than staying as plain ad hoc buttons.

## Slice 4B Verification Model

Slice 4B is complete only when all of the following are true:

1. Signal can promote a persisted live source item into a concept draft.
2. The concept workspace supports review and edit of the concept brief fields.
3. Export produces a stable human-readable artifact and a stable machine-readable representation.
4. Concept persistence works through the configured remote backend when available and the local fallback path when not.
5. App-facing storage language is no longer unnecessarily hardwired to Supabase for generic persistence behavior.
6. UI checks cover dashboard promotion, concept review/edit, export action, desktop viewport, and mobile viewport.
7. Signal app verification, spec artifact checks, receipt validation, and any new migration contract tests all pass.

## Recommended Implementation Order

1. Execute **Slice 4A** first and do not widen Signal until the live drift and remaining core closeout items are settled.
2. Re-run the attached-findings disposition after 4A to prove which items are truly closed.
3. Only then write the implementation plan for **Slice 4B** against the cleaned baseline.
4. Keep scheduled/background ingestion deferred until the concept workflow exists and the live-refresh model has been validated in real use.

## Deferred Beyond Slice 4

- scheduled/background ingestion
- auth, sharing, multi-user roles, and public launch
- additional source adapters
- direct repo mutation from inside the browser app
- native packaging
- broad chart/performance refactors

## Recommendation

Proceed with **Slice 4A first** as a live-tree closeout and drift-reconciliation pass. After that, use **Slice 4B** to implement Signal's next real product job: convert live signals into durable concept briefs without coupling the product surface too tightly to Supabase-specific wording or infrastructure assumptions.
