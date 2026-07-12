# Signal Slice 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct the app-dev harness defects exposed by Slice 1 and prove the corrected workflow by persisting Signal source and keyword settings through a browser-safe Supabase boundary.

**Architecture:** Slice 2A changes the root harness first and is independently reviewable. Slice 2B then uses the corrected gates to add one narrow Signal persistence path: a repository contract with Supabase and local implementations, TanStack Query orchestration, and explicit degraded-mode UI. Source-item ingestion, auth, and public deployment remain outside this slice.

**Tech Stack:** PowerShell 7, GitHub Actions, TypeScript, React 19, Vite, TanStack Query, Zustand, Zod, Supabase Postgres/RLS, Vitest, Testing Library, Playwright.

## Global Constraints

- Keep Signal and all app-dev projects tracked in the root repository.
- Stay on free or no-cost tiers until product proof or production need is recorded.
- Signal remains single-operator, no-auth, public-source-only, and internal.
- Browser code may contain only the Supabase URL and publishable key; never use a service-role key.
- Enable and review RLS before browser reads or writes.
- Do not add sources, scheduled ingestion, auth, sharing, native packaging, or public deployment.
- Use existing modules and approved libraries before adding custom framework code.
- Keep `checklist.md` as the gated-artifact filename during this slice.
- Treat `sensitive` and `gated` as equivalent gated-path terms until one vocabulary is migrated atomically.

---

## File Map

### Slice 2A

- Create `scripts/common.ps1`: shared failure collection, normalized path resolution, gated-risk vocabulary, and corrective-message helpers.
- Create `scripts/analyze-spec.ps1`: read-only cross-artifact and live-tree consistency analysis.
- Create `scripts/test-analyze-spec.ps1`: disposable-project regression suite for contradiction detection.
- Modify PowerShell entry scripts in `scripts/`: convert CLI toggles to `[switch]`; retain `[bool]` only for internal helper parameters.
- Modify `scripts/check-spec-artifacts.ps1`: consume common risk/path/failure logic and recognize both gated terms.
- Modify `scripts/validate-workflow-receipts.ps1`: consume shared helpers and support bare switch invocation.
- Modify `scripts/test-workflow-enforcement.ps1` and `scripts/test-workspace.ps1`: assert CLI behavior and run analysis.
- Create `standards/constitution.md`: versioned principles and delegation map.
- Modify `templates/spec-workflow/plan.template.md`: clarification, constitution check, and deviation tracking.
- Modify root and template `AGENTS.md`, `standards/*.md`, and generated command text: correct switch syntax and same-repo guidance.
- Modify `.github/workflows/app-dev-validation.yml`: validate Signal from the root workflow.
- Delete `projects/signal/.github/workflows/verify.yml`: remove inert nested workflow.

### Slice 2B

- Delete `projects/signal/src/modules/auth/`: remove unused template module.
- Modify `projects/signal/package.json`: set Signal identity and add no dependency unless tests prove one is required.
- Create `projects/signal/supabase/migrations/002_live_source_settings.sql`: keyword preferences, timestamps, RLS, and internal-MVP policies.
- Create `projects/signal/src/modules/sources/services/source-settings-repository.ts`: repository interface and Zod-validated row mapping.
- Create `projects/signal/src/modules/sources/services/supabase-source-settings-repository.ts`: Supabase implementation.
- Create `projects/signal/src/modules/sources/services/local-source-settings-repository.ts`: deterministic fallback.
- Create `projects/signal/src/modules/sources/hooks/useSourceSettings.ts`: query and mutation orchestration.
- Modify `projects/signal/src/modules/sources/state/source-preferences-store.ts`: retain transient draft state only.
- Modify `projects/signal/src/modules/settings/routes/SettingsRoute.tsx`: async state, persistence feedback, and degraded mode.
- Add focused service, hook, route, and Playwright tests.

---

### Task 1: Correct PowerShell CLI Contracts

**Files:**

- Modify: `scripts/create-app.ps1`
- Modify: `scripts/verify-app.ps1`
- Modify: `scripts/validate-workflow-receipts.ps1`
- Modify: `scripts/validate-codex-assets.ps1`
- Modify: `scripts/scan-secrets.ps1`
- Modify: `scripts/get-workflow-obligations.ps1`
- Test: `scripts/test-workflow-enforcement.ps1`

**Interfaces:**

- Produces: bare switches such as `-RequireVerificationEvidence`, `-JsonSummary`, `-NoInstall`, and `-InitializeGit`.
- Preserves: internal helper parameters typed as `[bool]` when callers pass explicit Boolean expressions.

- [ ] **Step 1: Add a failing bare-switch regression**

Add a test invocation equivalent to:

```powershell
& $validator -ProjectPath $ProjectPath -ChangedFilesJson $ChangedFilesJson -RequireVerificationEvidence *> $null
if ($LASTEXITCODE -ne 0) {
  throw "Bare -RequireVerificationEvidence must be accepted."
}
```

- [ ] **Step 2: Run the focused harness test**

Run:

```powershell
./scripts/test-workflow-enforcement.ps1
```

Expected: failure caused by the current `[bool]` parameter requiring an argument.

- [ ] **Step 3: Convert entry-point toggles**

Use `[switch]` for command-line flags and convert to Boolean only at internal call boundaries:

```powershell
param(
  [string]$ProjectPath = ".",
  [string]$ChangedFilesJson = "",
  [switch]$RequireVerificationEvidence,
  [switch]$JsonSummary
)
```

- [ ] **Step 4: Run focused and static checks**

Run:

```powershell
./scripts/test-workflow-enforcement.ps1
rg -n '^\s*\[bool\]\$(RequireVerificationEvidence|JsonSummary|NoInstall|InitializeGit|RequireAnyCheck|IncludeE2E)' scripts
```

Expected: harness test passes; the search returns no CLI declarations.

- [ ] **Step 5: Commit**

```powershell
git add scripts
git commit -m "fix: use PowerShell switches for harness CLI flags"
```

### Task 2: Centralize Harness Primitives

**Files:**

- Create: `scripts/common.ps1`
- Modify: `scripts/check-spec-artifacts.ps1`
- Modify: `scripts/validate-workflow-receipts.ps1`
- Modify: `scripts/get-workflow-obligations.ps1`
- Test: `scripts/test-workflow-enforcement.ps1`

**Interfaces:**

- Produces: `Add-HarnessFailure`, `Resolve-ProjectPath`, `Test-GatedRiskLevel`, and `Write-CorrectiveFailure`.
- `Test-GatedRiskLevel([string]$RiskLevel) -> [bool]` returns true for `gated` and `sensitive`, case-insensitively.

- [ ] **Step 1: Add failing gated-risk cases**

Add assertions for both accepted terms:

```powershell
foreach ($risk in @("gated", "sensitive")) {
  if (-not (Test-GatedRiskLevel -RiskLevel $risk)) {
    throw "Expected '$risk' to require gated artifacts."
  }
}
```

- [ ] **Step 2: Run the focused harness test**

Run `./scripts/test-workflow-enforcement.ps1`.

Expected: failure because the shared function does not exist or `gated` is not recognized.

- [ ] **Step 3: Implement and consume `common.ps1`**

Implement the canonical predicate:

```powershell
function Test-GatedRiskLevel {
  param([Parameter(Mandatory=$true)][string]$RiskLevel)
  return $RiskLevel.Trim().ToLowerInvariant() -in @("gated", "sensitive")
}
```

Dot-source the file from each consumer using `$PSScriptRoot`.

- [ ] **Step 4: Improve corrective failures**

Messages must identify the repair, for example:

```text
Missing active spec. Run ./scripts/new-spec.ps1 -ProjectPath <path> -Slug <slug> first.
Gated spec requires checklist.md. Create it from templates/spec-workflow/checklist.template.md.
```

- [ ] **Step 5: Verify**

Run:

```powershell
./scripts/test-workflow-enforcement.ps1
./scripts/check-workspace.ps1
```

Expected: both pass.

- [ ] **Step 6: Commit**

```powershell
git add scripts
git commit -m "refactor: share workflow harness primitives"
```

### Task 3: Add the Cross-Artifact Analysis Gate

**Files:**

- Create: `scripts/analyze-spec.ps1`
- Create: `scripts/test-analyze-spec.ps1`
- Modify: `scripts/test-workspace.ps1`
- Modify: `.github/workflows/app-dev-validation.yml`

**Interfaces:**

- Consumes: active spec resolved from the active spec `plan.md`.
- Produces: exit code `0` with `Spec analysis passed.` or nonzero with one line per contradiction.
- Checks: status agreement, gated artifact presence, completed-task artifact claims, verification-evidence closure, and unresolved clarification markers at completion.

- [ ] **Step 1: Create disposable failing fixtures**

The test script must generate isolated projects under `projects/__verify-analyze-*` for:

```text
spec planned + PLAN completed
completed "remove src/modules/auth" task while path exists
completed receipts with "Verification performed: pending"
completed spec containing NEEDS CLARIFICATION
```

- [ ] **Step 2: Run the new test**

Run `./scripts/test-analyze-spec.ps1`.

Expected: failure because `analyze-spec.ps1` does not exist.

- [ ] **Step 3: Implement deterministic analysis**

Parse Markdown status fields and task lines without modifying files. For removal tasks, support quoted/backticked relative paths and report a contradiction only when the task is checked and the path still exists.

- [ ] **Step 4: Add a passing fixture and Signal invocation**

Run:

```powershell
./scripts/test-analyze-spec.ps1
./scripts/analyze-spec.ps1 -ProjectPath ./projects/signal
```

Expected: fixtures pass; Signal reports no contradiction while spec 002 remains planned.

- [ ] **Step 5: Wire the gate**

Run the test in root CI and `test-workspace.ps1`; do not make generated draft specs fail merely because they contain open fields.

- [ ] **Step 6: Commit**

```powershell
git add scripts .github/workflows/app-dev-validation.yml
git commit -m "feat: add cross-artifact spec analysis gate"
```

### Task 4: Formalize Constitution and Planning Decisions

**Files:**

- Create: `standards/constitution.md`
- Modify: `templates/spec-workflow/plan.template.md`
- Modify: `standards/spec-driven-workflow.md`
- Modify: `AGENTS.md`
- Test: `scripts/validate-codex-assets.ps1`

**Interfaces:**

- Constitution metadata: `Version`, `Ratified`, and `Last amended`.
- Planning sections: `Constitution Check`, `Clarifications`, and `Complexity And Deviations`.

- [ ] **Step 1: Add validator expectations**

Require the constitution metadata and the three plan-template sections.

- [ ] **Step 2: Run validation and observe failure**

Run `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`.

Expected: missing constitution/template markers.

- [ ] **Step 3: Create the delegating constitution**

State stable principles only: free-tier first, modular assembly first, evidence before completion, security/compliance by risk, same-repo project model, and recorded deviations. Link detailed mechanics to existing standards instead of copying them.

- [ ] **Step 4: Add explicit planning fields**

Use:

```markdown
## Clarifications

| Question | Resolution | Status |
| --- | --- | --- |
| Replace with a concrete unknown | `NEEDS CLARIFICATION` | open |

## Complexity And Deviations

| Deviation | Why Needed | Simpler Alternative Rejected | Review Status |
| --- | --- | --- | --- |
| None | Not applicable | Not applicable | accepted |
```

- [ ] **Step 5: Verify and commit**

Run the validator and `./scripts/check-workspace.ps1`, then:

```powershell
git add AGENTS.md standards templates/spec-workflow/plan.template.md scripts/validate-codex-assets.ps1
git commit -m "docs: establish app-dev constitution and deviation tracking"
```

### Task 5: Reconcile Repository Guidance and CI Ownership

**Files:**

- Modify: `standards/workspace.md`
- Modify: root/template/project `AGENTS.md`
- Modify: `projects/signal/specs/NNN-<slug>/plan.md`
- Modify: `.gitignore`
- Modify: `.github/workflows/app-dev-validation.yml`
- Delete: `projects/signal/.github/workflows/verify.yml`
- Test: `scripts/test-workspace.ps1`

**Interfaces:**

- Produces: one repository model: projects are tracked by root Git unless a recorded future decision splits them.
- Produces: one CI owner: root GitHub Actions.

- [ ] **Step 1: Add consistency assertions**

Fail if tracked docs claim `projects/*` is ignored or Signal is a nested repository.

- [ ] **Step 2: Remove stale guidance and dead negations**

Preserve generated disposable-project cleanup without restoring broad project ignores.

- [ ] **Step 3: Add a root Signal verification job**

The job must use `working-directory: projects/signal`, run `npm ci`, then typecheck, lint, test, build, and e2e with the required Playwright browser setup.

- [ ] **Step 4: Remove the inert nested workflow**

Delete the project-local workflow only after root CI contains equivalent checks.

- [ ] **Step 5: Verify and commit**

Run root checks and `git diff --check`, then:

```powershell
git add .github .gitignore AGENTS.md standards templates projects/signal
git commit -m "ci: validate tracked Signal project from root workflow"
```

### Task 6: Reconcile Signal Identity and Remove Auth Residue

**Files:**

- Delete: `projects/signal/src/modules/auth/**`
- Modify: `projects/signal/package.json`
- Modify: `projects/signal/README.md`
- Modify: `projects/signal/src/modules/README.md`
- Test: `projects/signal/src/test/eslint-module-boundaries.test.js`

**Interfaces:**

- Produces: package name `signal`.
- Preserves: no-auth routes and module public boundaries.

- [ ] **Step 1: Add an absence assertion**

Add a harness or project test that fails when `src/modules/auth` exists in the no-auth Signal app.

- [ ] **Step 2: Run the test and observe failure**

Run `npm test -- --run` from `projects/signal`.

- [ ] **Step 3: Delete auth residue and update identity**

Set:

```json
"name": "signal"
```

Remove auth documentation and imports, without changing the reusable template’s auth example in this task.

- [ ] **Step 4: Verify and commit**

Run typecheck, lint, and tests, then:

```powershell
git add projects/signal
git commit -m "refactor(signal): remove unused auth scaffold"
```

### Task 7: Define and Secure the Settings Persistence Model

**Files:**

- Create: `projects/signal/supabase/migrations/002_live_source_settings.sql`
- Modify: `projects/signal/specs/002-live-settings/checklist.md`
- Test: migration review assertions in `projects/signal/src/modules/sources/tests/source-settings-repository.test.ts`

**Interfaces:**

- `source_settings`: one row per source with `enabled` and `updated_at`.
- `signal_preferences`: singleton row with `include_keywords text[]` and `updated_at`.
- RLS: enabled before grants/policies; policies explicitly labelled internal MVP and no-auth.

- [ ] **Step 1: Write migration contract tests**

Assert SQL contains RLS enablement, both tables, timestamp updates, and no service-role credential.

- [ ] **Step 2: Run the focused test and observe failure**

Run:

```powershell
npm test -- src/modules/sources/tests/source-settings-repository.test.ts
```

- [ ] **Step 3: Write the migration**

Use idempotent DDL, constrained source values, a singleton preference key, and explicit policies. Add SQL comments stating that anonymous writes are unsuitable for public launch.

- [ ] **Step 4: Review with Supabase guidance**

Check indexes, RLS, grants, upsert behavior, and free-tier implications. Do not apply to a shared project without explicit authorization.

- [ ] **Step 5: Commit**

```powershell
git add projects/signal/supabase projects/signal/specs/002-live-settings/checklist.md projects/signal/src/modules/sources/tests
git commit -m "feat(signal): define secured settings persistence schema"
```

### Task 8: Implement the Settings Repository Contract

**Files:**

- Create: `projects/signal/src/modules/sources/services/source-settings-repository.ts`
- Create: `projects/signal/src/modules/sources/services/local-source-settings-repository.ts`
- Create: `projects/signal/src/modules/sources/services/supabase-source-settings-repository.ts`
- Modify: `projects/signal/src/modules/sources/index.ts`
- Test: `projects/signal/src/modules/sources/tests/source-settings-repository.test.ts`

**Interfaces:**

```typescript
export type SourceSettingsRepository = {
  get(): Promise<SourceSettings>;
  save(settings: SourceSettings): Promise<SourceSettings>;
};

export type SettingsBackend = "supabase" | "local-fallback";
```

- [ ] **Step 1: Write contract tests**

Cover defaults, configured read, configured save, malformed row rejection, request failure, and unconfigured local fallback.

- [ ] **Step 2: Run tests and observe failure**

Run the focused Vitest file.

- [ ] **Step 3: Implement local and Supabase adapters**

Inject `SupabaseClient` into the Supabase adapter. Validate all returned rows with Zod. Keep fallback selection outside the adapter so a real backend failure is observable rather than silently swallowed.

- [ ] **Step 4: Run focused tests**

Expected: all repository cases pass without network access.

- [ ] **Step 5: Commit**

```powershell
git add projects/signal/src/modules/sources
git commit -m "feat(signal): add source settings repositories"
```

### Task 9: Add Query and Mutation Orchestration

**Files:**

- Create: `projects/signal/src/modules/sources/hooks/useSourceSettings.ts`
- Modify: `projects/signal/src/modules/sources/state/source-preferences-store.ts`
- Modify: `projects/signal/src/modules/sources/index.ts`
- Test: `projects/signal/src/modules/sources/tests/useSourceSettings.test.tsx`

**Interfaces:**

- Query key: `["source-settings"]`.
- `useSourceSettings()` returns settings, backend, loading/error state, and `saveSettings`.
- Zustand stores only transient input/draft values; persisted server state belongs to TanStack Query.

- [ ] **Step 1: Write hook tests**

Verify hydration, optimistic-disabled save, successful cache replacement, failure preservation, and backend label.

- [ ] **Step 2: Run tests and observe failure**

Run the focused hook test.

- [ ] **Step 3: Implement minimal hooks**

Use one query and one mutation. On success, replace the exact query cache value. On error, retain the last confirmed settings and expose the error.

- [ ] **Step 4: Verify**

Run hook, repository, typecheck, and lint checks.

- [ ] **Step 5: Commit**

```powershell
git add projects/signal/src/modules/sources
git commit -m "feat(signal): orchestrate persisted settings state"
```

### Task 10: Build the Persisted Settings UX

**Files:**

- Modify: `projects/signal/src/modules/settings/routes/SettingsRoute.tsx`
- Create: `projects/signal/src/modules/settings/tests/SettingsRoute.test.tsx`
- Modify: `projects/signal/tests/e2e/app.spec.ts`

**Interfaces:**

- Shows: loading, saved, saving, save-failed, and local-fallback states.
- Prevents: concurrent saves and disabling every source.

- [ ] **Step 1: Write route tests**

Test keyboard-accessible controls, hydrated values, disabled state during save, save confirmation, recoverable error, and local fallback disclosure.

- [ ] **Step 2: Run tests and observe failure**

Run the focused route test.

- [ ] **Step 3: Implement the UI**

Use existing Button/Input/Badge primitives. Keep status copy adjacent to the controls and use `aria-live="polite"` for save feedback.

- [ ] **Step 4: Add browser flow coverage**

Verify settings navigation, source toggle, keyword edit, save feedback, desktop viewport, and mobile viewport without requiring live Supabase.

- [ ] **Step 5: Verify and commit**

Run tests and e2e, then:

```powershell
git add projects/signal/src/modules/settings projects/signal/tests/e2e
git commit -m "feat(signal): persist source settings from the UI"
```

### Task 11: Close Evidence, Security, and Audit Findings

**Files:**

- Modify: `projects/signal/specs/002-live-settings/spec.md`
- Modify: `projects/signal/specs/002-live-settings/tasks.md`
- Modify: `projects/signal/specs/002-live-settings/checklist.md`
- Modify: `projects/signal/specs/002-live-settings/workflow-receipts.md`
- Modify: `projects/signal/specs/NNN-<slug>/plan.md`

**Interfaces:**

- Produces: matching completed statuses only after all required evidence exists.
- Produces: audit disposition table with `fixed`, `deferred`, `rejected`, or `project-local`.

- [ ] **Step 1: Run root verification**

```powershell
./scripts/check-workspace.ps1
./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true
./scripts/test-hooks.ps1
./scripts/test-workflow-enforcement.ps1
./scripts/test-analyze-spec.ps1
./scripts/test-workspace.ps1
./scripts/scan-secrets.ps1
```

Expected: all pass.

- [ ] **Step 2: Run Signal verification**

From `projects/signal`:

```powershell
../../scripts/analyze-spec.ps1 -ProjectPath .
../../scripts/check-spec-artifacts.ps1 -ProjectPath .
../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence
../../scripts/verify-app.ps1 -ProjectPath .
```

Expected: analysis, artifact, receipt, typecheck, lint, test, build, and e2e checks pass.

- [ ] **Step 3: Perform rendered and security review**

Capture desktop and mobile evidence for the settings flow. Run a scoped security review over the migration, RLS, browser credentials, repository fallback, and public-launch prohibition.

- [ ] **Step 4: Update artifacts**

Replace planned statuses only after evidence is recorded. Resolve or retain each `NEEDS CLARIFICATION` marker with an owner and reason; completed artifacts may not contain unresolved markers.

- [ ] **Step 5: Run final consistency checks**

```powershell
./scripts/analyze-spec.ps1 -ProjectPath ./projects/signal
git diff --check
git status --short
```

Expected: analysis and diff checks pass; status shows only intentional Slice 2 files.

- [ ] **Step 6: Commit**

```powershell
git add docs standards scripts templates .github projects/signal AGENTS.md
git commit -m "docs: close Signal slice 2 evidence"
```

## Deferred Beyond Slice 2

- Rename `checklist.md` only through a dedicated atomic migration across validators, templates, tests, generated apps, and docs.
- Upgrade or replace Recharts after measuring bundle and migration impact.
- Persist source items and add live GitHub/Hacker News ingestion.
- Add scheduled functions, auth, sharing, multi-user RLS, or public deployment.
- Promote the Signal settings repository into a reusable template module only after a second project proves reuse.

## Self-Review Record

- Spec coverage: every Slice 2A and 2B requirement maps to Tasks 1-11.
- Placeholder scan: no implementation step relies on unspecified error handling, tests, or unnamed files.
- Interface consistency: repository, backend label, query key, and hook ownership are defined once and reused by later tasks.
- Scope boundary: source-item persistence, new adapters, auth, public launch, and checklist renaming remain explicitly deferred.
