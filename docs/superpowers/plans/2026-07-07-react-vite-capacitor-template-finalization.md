# React Vite Capacitor Template Finalization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Finalize `templates/react-vite-capacitor` from a runnable scaffold into a complete, reusable, verified reference template for cross-platform React/Vite/Capacitor apps in `app-dev`.

**Architecture:** Keep `app-dev` as a control workspace and improve only the template, template tests, template documentation, and workspace validation scripts. Reuse official shadcn/ui, Supabase, Capacitor, TanStack, and Playwright patterns where they already solve the gap; hand-author only the app-dev-specific module contract, local adapter layer, and verification rules.

**Tech Stack:** TypeScript, React, Vite, React Router, Capacitor, Tailwind CSS v4, shadcn/ui with Radix-compatible configuration, lucide-react, Zod, React Hook Form, TanStack Query, TanStack Table, Zustand, Recharts, Supabase, Vitest, Testing Library, Playwright.

## Global Constraints

- Keep app dependencies inside `templates/react-vite-capacitor/package.json` and generated apps under `projects/<app>`; do not install app dependencies at the workspace root.
- Copy or generate reusable artifacts from official tools before hand-authoring: shadcn CLI/components, Supabase React quickstart, Capacitor CLI shape, Playwright config conventions, and current local template files.
- Treat `C:\Projects\supervox\.agents\skills` as an execution-time skill reference source, not as a folder to vendor into `app-dev`.
- Use `cross-platform-app-workflow` for app-dev module/template rules.
- Use `superpowers:test-driven-development` for behavior changes, `superpowers:verification-before-completion` before success claims, and `superpowers:subagent-driven-development` or `superpowers:executing-plans` to execute this plan.
- Use Supabase plugin guidance for Supabase client/auth/RLS work; use publishable client keys in browser-facing Vite code and never service-role or secret keys.
- Use shadcn guidance for UI source generation; run CLI commands from `templates/react-vite-capacitor` or a generated project, never from the workspace root.
- Preserve Radix-compatible shadcn behavior unless `standards/stack.md` is changed; if running shadcn init or scratch comparisons, pass/confirm `--base radix`.
- Rendered UI verification must cover desktop/laptop/tablet/mobile widths: 1440, 1280, 768, and 390 px.
- No production secrets, `.env` files, Supabase secret keys, or service-role keys may be committed.

---

## Verified Current State

The attached recommendations are partly stale against the current checkout.

Already present:
- `components.json`, `tailwind.config.ts`, `postcss.config.js`, Tailwind import in `src/styles.css`.
- `@/*` alias in `tsconfig.json` and `vite.config.ts`.
- `capacitor.config.ts`.
- `src/components/state/{EmptyState,LoadingState,ErrorState}.tsx` and tests.
- A seeded `settings` route.

Still open:
- No `@supabase/supabase-js`, no Supabase client, and `.env.example` still uses legacy `VITE_SUPABASE_ANON_KEY` naming.
- `QueryClient` is inline in `src/main.tsx`, not in `src/lib/query-client.ts`.
- No `src/lib/env.ts` or runtime env validation.
- No `src/lib/utils.ts` `cn()` helper despite shadcn aliases pointing to it.
- No `src/components/ui/` shadcn component source files.
- `FormLayout` and `DataTableLayout` are plain wrappers, not RHF/Zod or TanStack Table teaching examples.
- `dashboard` module does not demonstrate the full module contract: missing `components/`, `hooks/`, `schemas/`, `services/`, `state/`, `tests/`.
- `SettingsLayout` is missing from code and template README checklist.
- `playwright.config.ts` has only desktop/mobile projects and desktop is not pinned to the app-dev required widths.
- No CI workflow template.
- No Recharts/shadcn chart reference surface.
- No scripted disposable generated-app verification proving the finalized template works after copy.

## Source-Backed Decisions

- shadcn CLI `init` installs dependencies, adds the `cn` util, and configures CSS variables; it supports `--template vite` and `--base base|radix`. Use this only in scratch or with diffs because the template is already partially initialized.
- shadcn Data Table documentation builds with TanStack Table plus the shadcn `Table` component; use that as the reference for the template's table teaching example.
- shadcn Chart is built on Recharts and installed with `shadcn add chart`; use its generated component source instead of a custom chart wrapper.
- Supabase React docs now prefer `VITE_SUPABASE_PUBLISHABLE_KEY`; legacy `anon` keys are deprecated by the end of 2026. Update the template env contract to accept publishable key naming while optionally supporting legacy anon naming only as a migration fallback if explicitly documented.
- Supabase API-key docs state publishable keys are safe for browser/mobile apps, while secret keys are backend-only and bypass RLS. Template code must never mention `service_role` as a frontend env var.
- Supabase RLS docs require RLS on tables in exposed schemas such as `public`; include a migration example that enables RLS and uses ownership predicates, but keep it example-only until a real app defines its data model.
- Capacitor docs add native projects with `@capacitor/android`, `@capacitor/ios`, `npx cap add android`, `npx cap add ios`, and `npx cap sync`. Keep native platforms out of the root template unless the repo chooses to store generated native project files; document and optionally script this as a per-generated-app follow-up.

## Dependency Plan

Add or verify these template package dependencies:
- Runtime: `@supabase/supabase-js`, `@hookform/resolvers`, `recharts`.
- shadcn-generated dependencies: whatever `npx shadcn@latest add button card table field input label select badge dropdown-menu skeleton empty separator chart` adds, reviewed file-by-file.
- Native optional runtime for generated apps only: `@capacitor/android`, `@capacitor/ios` when a project opts into native platform folders.

Do not install anything at `C:\Users\piete\Documents\app-dev`.

## Candidate Reuse Sources

- Current template files under `templates/react-vite-capacitor`.
- shadcn CLI generated source for `button`, `card`, `table`, `field`, `input`, `label`, `select`, `badge`, `dropdown-menu`, `skeleton`, `empty`, `separator`, and `chart`.
- Supabase official React quickstart for `createClient` and auth event shape, adapted to Vite TypeScript and app-dev env validation.
- Capacitor official docs for per-app native platform commands.
- `C:\Projects\supervox\.agents\skills\shadcn-best-practices`, `react-best-practices`, `frontend-testing-debugging`, `test-driven-development`, `verification-before-completion`, and `supabase-best-practices` as execution-time workflow references.

---

### Task 1: Establish The Template Completion Baseline

**Files:**
- Modify: `docs/superpowers/plans/2026-07-07-react-vite-capacitor-template-finalization.md`
- Modify: `templates/react-vite-capacitor/README.md`
- Modify: `templates/react-vite-capacitor/AGENTS.md`

**Interfaces:**
- Consumes: Root `AGENTS.md`, `standards/stack.md`, `standards/adaptive-layouts.md`, `standards/codex-capabilities.md`, attached gap analyses.
- Produces: A current checklist used by later tasks and final verification.

- [x] **Step 1: Re-read current governance files**

Run:

```powershell
Get-Content AGENTS.md
Get-Content standards/stack.md
Get-Content standards/adaptive-layouts.md
Get-Content standards/codex-capabilities.md
Get-Content templates/react-vite-capacitor/README.md
Get-Content templates/react-vite-capacitor/AGENTS.md
```

Expected: confirms React/Vite/Capacitor default stack, module contract, adaptive widths, and capability routing.

- [x] **Step 2: Record stale attachment corrections**

Update `templates/react-vite-capacitor/README.md` with a short "Template includes" section that lists Tailwind config, shadcn config, path alias, Capacitor config, state primitives, and verification scripts.

- [x] **Step 3: Record remaining completion criteria**

Update `templates/react-vite-capacitor/README.md` with a "Reference template complete when" checklist covering Supabase/env, shadcn UI source, module contract, form/table/chart examples, SettingsLayout, responsive Playwright projects, CI template, and generated-app verification.

- [x] **Step 4: Run documentation checks**

Run:

```powershell
scripts/validate-codex-assets.ps1
git diff --check
```

Expected: both exit 0.

- [x] **Step 5: Commit**

```bash
git add docs/superpowers/plans/2026-07-07-react-vite-capacitor-template-finalization.md templates/react-vite-capacitor/README.md templates/react-vite-capacitor/AGENTS.md
git commit -m "docs: define react vite capacitor template completion baseline"
```

### Task 2: Generate And Review shadcn UI Source

**Files:**
- Create: `templates/react-vite-capacitor/src/lib/utils.ts`
- Create: `templates/react-vite-capacitor/src/components/ui/*.tsx`
- Modify: `templates/react-vite-capacitor/src/styles.css`
- Modify: `templates/react-vite-capacitor/package.json`
- Modify: `templates/react-vite-capacitor/package-lock.json` if dependency installation is performed in the template directory

**Interfaces:**
- Consumes: `components.json` aliases and Radix-compatible shadcn guidance.
- Produces: shadcn source components and `cn(...inputs: ClassValue[]): string`.

- [x] **Step 1: Inspect shadcn context**

Run from `templates/react-vite-capacitor`:

```powershell
npx shadcn@latest info --json
```

Expected: project is detected, `aliases.utils` points to `@/lib/utils`, Tailwind CSS file is `src/styles.css`, and primitive base is confirmed. If the output indicates Base UI while the workspace still requires Radix, stop and use a scratch diff with `--base radix` before applying changes.

- [x] **Step 2: Preview generated files**

Run from `templates/react-vite-capacitor`:

```powershell
npx shadcn@latest add button card table field input label select badge dropdown-menu skeleton empty separator chart --dry-run
```

Expected: dry run lists generated UI files and dependency changes without writing.

- [x] **Step 3: Generate components**

Run from `templates/react-vite-capacitor`:

```powershell
npx shadcn@latest add button card table field input label select badge dropdown-menu skeleton empty separator chart
```

Expected: `src/components/ui/` is populated and `src/lib/utils.ts` exists or is generated.

- [x] **Step 4: Review generated source**

Read every generated `src/components/ui/*.tsx` file. Confirm imports use `@/lib/utils`, icons use `lucide-react`, components use semantic tokens, and no component imports a missing file.

- [x] **Step 5: Run focused checks**

```powershell
npm run typecheck
npm run lint
npm run test
```

Expected: all exit 0 from `templates/react-vite-capacitor`.

- [x] **Step 6: Commit**

```bash
git add templates/react-vite-capacitor
git commit -m "feat: add shadcn ui source to react vite template"
```

### Task 3: Add Env Validation, Supabase Client, And Query Client Modules

**Files:**
- Create: `templates/react-vite-capacitor/src/lib/env.ts`
- Create: `templates/react-vite-capacitor/src/lib/supabase.ts`
- Create: `templates/react-vite-capacitor/src/lib/query-client.ts`
- Modify: `templates/react-vite-capacitor/src/main.tsx`
- Modify: `templates/react-vite-capacitor/.env.example`
- Modify: `templates/react-vite-capacitor/src/lib/README.md`
- Modify: `templates/react-vite-capacitor/package.json`

**Interfaces:**
- Produces: `env`, `supabase`, and `queryClient`.
- Consumes: `VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY`, optional documented legacy `VITE_SUPABASE_ANON_KEY`.

- [ ] **Step 1: Write failing env tests**

Create `templates/react-vite-capacitor/src/lib/env.test.ts` with tests that verify:
- valid URL + publishable key returns parsed env
- missing URL returns a readable error
- missing key returns a readable error
- secret/service-role-like key names are not accepted as browser env variables

Run:

```powershell
npm run test -- src/lib/env.test.ts
```

Expected: fails because `src/lib/env.ts` does not exist.

- [ ] **Step 2: Implement `src/lib/env.ts`**

Use Zod to parse `import.meta.env` and export:
- `env.VITE_SUPABASE_URL`
- `env.VITE_SUPABASE_PUBLISHABLE_KEY`
- `isSupabaseConfigured(): boolean`

Do not throw during import for placeholder `.env.example` values. Throw only when code asks for a configured Supabase client without valid values.

- [ ] **Step 3: Implement `src/lib/supabase.ts`**

Use Supabase's Vite React quickstart pattern:

```ts
import { createClient } from "@supabase/supabase-js";
import { env } from "./env";

export const supabase = createClient(
  env.VITE_SUPABASE_URL,
  env.VITE_SUPABASE_PUBLISHABLE_KEY,
);
```

Adapt this with the lazy validation behavior from Step 2 so tests and static template rendering work without real credentials.

- [ ] **Step 4: Extract `src/lib/query-client.ts`**

Move the inline `new QueryClient()` from `src/main.tsx` to a shared module:

```ts
import { QueryClient } from "@tanstack/react-query";

export const queryClient = new QueryClient();
```

Update `src/main.tsx` to import it.

- [ ] **Step 5: Update `.env.example`**

Use:

```text
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_your_publishable_key
```

Add comments in README, not `.env.example`, explaining legacy anon key migration if retained.

- [ ] **Step 6: Run checks**

```powershell
npm run typecheck
npm run lint
npm run test
```

Expected: all exit 0.

- [ ] **Step 7: Commit**

```bash
git add templates/react-vite-capacitor
git commit -m "feat: add env and supabase clients to react vite template"
```

### Task 4: Add Auth Boundary And Supabase Security Notes Without Forcing Product Auth

**Files:**
- Create: `templates/react-vite-capacitor/src/modules/auth/index.ts`
- Create: `templates/react-vite-capacitor/src/modules/auth/hooks/useAuthSession.ts`
- Create: `templates/react-vite-capacitor/src/modules/auth/services/auth-service.ts`
- Create: `templates/react-vite-capacitor/src/modules/auth/tests/auth-service.test.ts`
- Modify: `templates/react-vite-capacitor/README.md`
- Modify: `templates/react-vite-capacitor/AGENTS.md`

**Interfaces:**
- Produces: `useAuthSession`, `signInWithEmailOtp(email: string)`, `signOut()`.
- Consumes: `supabase` from `src/lib/supabase.ts`.

- [ ] **Step 1: Write failing auth service tests**

Test that `signInWithEmailOtp` calls `supabase.auth.signInWithOtp` with `emailRedirectTo: window.location.origin`, and `signOut` calls `supabase.auth.signOut`.

- [ ] **Step 2: Implement service wrapper**

Create a thin wrapper around the Supabase auth calls. Keep it product-neutral: no roles, no routes, no hardcoded permissions.

- [ ] **Step 3: Implement session hook**

Create `useAuthSession` using `supabase.auth.getSession()` and `supabase.auth.onAuthStateChange()`. Return `{ session, isLoading, error }`.

- [ ] **Step 4: Add security documentation**

Document:
- browser apps use publishable keys only
- secret/service-role keys are backend-only
- RLS must be enabled for exposed schemas
- product-specific policies belong in app migrations after the data model is defined

- [ ] **Step 5: Run checks**

```powershell
npm run typecheck
npm run lint
npm run test
```

- [ ] **Step 6: Commit**

```bash
git add templates/react-vite-capacitor
git commit -m "feat: add supabase auth boundary to react vite template"
```

### Task 5: Convert Layout Teaching Examples To Real Library Patterns

**Files:**
- Modify: `templates/react-vite-capacitor/src/components/layout/FormLayout.tsx`
- Modify: `templates/react-vite-capacitor/src/components/layout/DataTableLayout.tsx`
- Create: `templates/react-vite-capacitor/src/components/layout/SettingsLayout.tsx`
- Create: `templates/react-vite-capacitor/src/components/layout/FormLayout.test.tsx`
- Create: `templates/react-vite-capacitor/src/components/layout/DataTableLayout.test.tsx`
- Create: `templates/react-vite-capacitor/src/components/layout/SettingsLayout.test.tsx`
- Modify: `templates/react-vite-capacitor/src/components/layout/layouts.css`
- Modify: `templates/react-vite-capacitor/README.md`

**Interfaces:**
- Produces: `FormLayout`, `DataTableLayout<TData, TValue>`, `SettingsLayout`.
- Consumes: shadcn UI components, React Hook Form/Zod, TanStack Table.

- [ ] **Step 1: Write failing layout tests**

Tests must verify:
- `FormLayout` disables fields when pending and surfaces validation content.
- `DataTableLayout` renders columns and rows from TanStack Table definitions and shows empty state for no rows.
- `SettingsLayout` renders a side navigation and active settings panel.

- [ ] **Step 2: Update `DataTableLayout`**

Adapt the shadcn Data Table pattern to this template:
- accept `columns: ColumnDef<TData, TValue>[]`
- accept `data: TData[]`
- use `useReactTable`, `getCoreRowModel`, `getPaginationRowModel`, and `flexRender`
- render shadcn `Table` components
- render `EmptyState` when no rows exist
- keep horizontal overflow strategy for mobile

- [ ] **Step 3: Update `FormLayout`**

Keep `FormLayout` as a layout primitive, but add a companion example pattern that uses:
- React Hook Form
- Zod resolver from `@hookform/resolvers/zod`
- shadcn `Field`, `Input`, and `Button`

Avoid making `FormLayout` own business validation; modules own schemas.

- [ ] **Step 4: Create `SettingsLayout`**

Implement a reusable settings shell using a side navigation on desktop and stacked/tabs-like navigation on mobile. Keep prop surface minimal:

```ts
type SettingsLayoutProps = {
  items: Array<{ label: string; href: string; isActive?: boolean }>;
  children: React.ReactNode;
};
```

- [ ] **Step 5: Run checks**

```powershell
npm run typecheck
npm run lint
npm run test
```

- [ ] **Step 6: Commit**

```bash
git add templates/react-vite-capacitor
git commit -m "feat: complete layout primitives with form table settings patterns"
```

### Task 6: Complete The Dashboard Module Contract

**Files:**
- Create: `templates/react-vite-capacitor/src/modules/dashboard/components/DashboardSummary.tsx`
- Create: `templates/react-vite-capacitor/src/modules/dashboard/components/DashboardModulesTable.tsx`
- Create: `templates/react-vite-capacitor/src/modules/dashboard/hooks/useDashboardModules.ts`
- Create: `templates/react-vite-capacitor/src/modules/dashboard/schemas/dashboard-module.schema.ts`
- Create: `templates/react-vite-capacitor/src/modules/dashboard/services/dashboard-service.ts`
- Create: `templates/react-vite-capacitor/src/modules/dashboard/state/dashboard-view-store.ts`
- Create: `templates/react-vite-capacitor/src/modules/dashboard/tests/dashboard-module.schema.test.ts`
- Create: `templates/react-vite-capacitor/src/modules/dashboard/tests/DashboardRoute.test.tsx`
- Modify: `templates/react-vite-capacitor/src/modules/dashboard/routes/DashboardRoute.tsx`
- Modify: `templates/react-vite-capacitor/src/modules/dashboard/index.ts`

**Interfaces:**
- Produces: `dashboardModuleSchema`, `getDashboardModules`, `useDashboardModules`, `useDashboardViewStore`.
- Consumes: TanStack Query, Zustand, Zod, `DataTableLayout`, state primitives.

- [ ] **Step 1: Write failing schema tests**

Verify valid module rows parse, invalid status fails, and inferred TypeScript type supports `"ready" | "draft" | "blocked"`.

- [ ] **Step 2: Implement schema**

Create a Zod schema close to the module:

```ts
export const dashboardModuleSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  status: z.enum(["ready", "draft", "blocked"]),
});
```

- [ ] **Step 3: Write failing service/hook tests**

Verify service returns parsed rows and hook exposes loading/error/empty/success states.

- [ ] **Step 4: Implement service and hook**

Use static seed data for the template, parsed through Zod, and expose it through TanStack Query. This teaches the pattern without requiring a real Supabase project.

- [ ] **Step 5: Write failing route test**

Verify the route renders:
- page header
- loading state when query is loading
- empty state when data is empty
- table rows when data exists

- [ ] **Step 6: Refactor route into components**

Move table rendering into `DashboardModulesTable` and summary content into `DashboardSummary`. Keep `DashboardRoute.tsx` as orchestration.

- [ ] **Step 7: Export public module API**

Update `index.ts` to export only public route/component/schema/service/hook APIs needed outside the module.

- [ ] **Step 8: Run checks**

```powershell
npm run typecheck
npm run lint
npm run test
```

- [ ] **Step 9: Commit**

```bash
git add templates/react-vite-capacitor
git commit -m "feat: complete dashboard module contract in react vite template"
```

### Task 7: Add A Chart Reference Surface

**Files:**
- Create: `templates/react-vite-capacitor/src/modules/dashboard/components/DashboardActivityChart.tsx`
- Create: `templates/react-vite-capacitor/src/modules/dashboard/tests/DashboardActivityChart.test.tsx`
- Modify: `templates/react-vite-capacitor/src/modules/dashboard/routes/DashboardRoute.tsx`
- Modify: `templates/react-vite-capacitor/package.json`

**Interfaces:**
- Produces: a shadcn/Recharts example component.
- Consumes: `ChartContainer`, `ChartTooltip`, `ChartTooltipContent`, Recharts.

- [ ] **Step 1: Confirm chart dependency**

Run:

```powershell
npm ls recharts
```

Expected: installed after shadcn `chart`; if missing, run `npm install recharts` inside `templates/react-vite-capacitor`.

- [ ] **Step 2: Write failing chart render test**

Test that the chart component renders its accessible title/label and does not crash in jsdom.

- [ ] **Step 3: Implement chart component**

Use shadcn Chart docs pattern:
- stable height class, e.g. `h-[220px]`
- `accessibilityLayer`
- semantic chart config
- no custom chart abstraction beyond the reference component

- [ ] **Step 4: Add chart to dashboard**

Place it in the dashboard route as a reference chart surface without overwhelming the first screen.

- [ ] **Step 5: Run checks**

```powershell
npm run typecheck
npm run lint
npm run test
```

- [ ] **Step 6: Commit**

```bash
git add templates/react-vite-capacitor
git commit -m "feat: add chart reference to react vite template"
```

### Task 8: Expand Responsive And Rendered Verification

**Files:**
- Modify: `templates/react-vite-capacitor/playwright.config.ts`
- Modify: `templates/react-vite-capacitor/tests/e2e/app.spec.ts`
- Modify: `standards/adaptive-layouts.md` only if the standard needs clarification, not to weaken it

**Interfaces:**
- Produces: Playwright projects `desktop-1440`, `laptop-1280`, `tablet-768`, `mobile-390`.

- [ ] **Step 1: Update Playwright projects**

Define explicit viewport projects:
- `{ width: 1440, height: 900 }`
- `{ width: 1280, height: 800 }`
- `{ width: 768, height: 1024 }`
- `{ width: 390, height: 844 }`

- [ ] **Step 2: Expand e2e assertions**

Test:
- first meaningful screen renders
- navigation reaches Settings
- dashboard table is visible
- primary action is reachable
- no horizontal overflow at each project width

- [ ] **Step 3: Run e2e**

```powershell
npm run e2e
```

Expected: all configured projects pass.

- [ ] **Step 4: Commit**

```bash
git add templates/react-vite-capacitor/playwright.config.ts templates/react-vite-capacitor/tests/e2e/app.spec.ts
git commit -m "test: add responsive playwright coverage to react vite template"
```

### Task 9: Add CI Workflow Template Without Turning The Root Into An App

**Files:**
- Create: `templates/react-vite-capacitor/.github/workflows/verify.yml`
- Modify: `templates/react-vite-capacitor/README.md`
- Modify: `scripts/validate-codex-assets.ps1`

**Interfaces:**
- Produces: generated apps inherit CI that runs install, typecheck, lint, test, build, and e2e.

- [ ] **Step 1: Add workflow**

Create a GitHub Actions workflow with:
- `actions/checkout`
- `actions/setup-node`
- `npm ci`
- `npx playwright install --with-deps chromium`
- `npm run typecheck`
- `npm run lint`
- `npm run test`
- `npm run build`
- `npm run e2e`

- [ ] **Step 2: Update validation script**

Add checks that the React/Vite/Capacitor template contains `.github/workflows/verify.yml` and required package scripts.

- [ ] **Step 3: Run root governance checks**

```powershell
scripts/check-workspace.ps1
scripts/validate-codex-assets.ps1
scripts/test-hooks.ps1
```

Expected: all exit 0.

- [ ] **Step 4: Commit**

```bash
git add templates/react-vite-capacitor/.github/workflows/verify.yml templates/react-vite-capacitor/README.md scripts/validate-codex-assets.ps1
git commit -m "ci: add generated app verification workflow template"
```

### Task 10: Document And Optionally Script Capacitor Native Platform Finalization

**Files:**
- Modify: `templates/react-vite-capacitor/README.md`
- Modify: `templates/react-vite-capacitor/AGENTS.md`
- Optionally create: `templates/react-vite-capacitor/scripts/add-native-platforms.ps1`
- Optionally modify: `scripts/create-app.ps1`

**Interfaces:**
- Produces: documented per-generated-app native setup path.
- Consumes: Capacitor `webDir: "dist"` in `capacitor.config.ts`.

- [ ] **Step 1: Decide native platform storage policy**

Choose one:
- Recommended: do not store `android/` and `ios/` folders in the template; generate them per app after product/native requirements are known.
- Alternative: store platform folders in template only if the repo accepts much larger generated artifacts and platform-specific churn.

- [ ] **Step 2: Document native commands**

In template README:

```powershell
npm install
npm install @capacitor/android @capacitor/ios
npm run build
npx cap add android
npx cap add ios
npx cap sync
```

State that iOS requires macOS/Xcode and Android requires Android Studio/JDK setup.

- [ ] **Step 3: Optional script**

If scripting is chosen, create `scripts/add-native-platforms.ps1` inside the template that refuses to run unless `package.json` and `capacitor.config.ts` are present in the current generated app.

- [ ] **Step 4: Run checks**

```powershell
npm run typecheck
npm run lint
npm run test
npm run build
```

- [ ] **Step 5: Commit**

```bash
git add templates/react-vite-capacitor scripts/create-app.ps1
git commit -m "docs: define capacitor native finalization workflow"
```

### Task 11: Prove The Template Works Through A Disposable Generated App

**Files:**
- Modify: `scripts/test-workspace.ps1`
- Modify: `scripts/verify-app.ps1` only if the current verifier cannot run the finalized template correctly

**Interfaces:**
- Produces: root-level workspace test coverage that creates and verifies a disposable React/Vite/Capacitor app.

- [ ] **Step 1: Update workspace test expectations**

Ensure `scripts/test-workspace.ps1` creates a disposable generated app under `projects/__verify-react-vite-capacitor`, then checks for:
- `AGENTS.md`
- `PLAN.md`
- `package.json`
- `.env.example`
- `src/lib/env.ts`
- `src/lib/supabase.ts`
- `src/components/ui`
- `src/components/layout/SettingsLayout.tsx`
- `src/modules/dashboard/{components,hooks,routes,schemas,services,state,tests,index.ts}`
- `playwright.config.ts`
- `.github/workflows/verify.yml`

- [ ] **Step 2: Run generated app install and verification**

From the disposable generated app:

```powershell
npm install
..\..\scripts\verify-app.ps1 -ProjectPath .
```

Expected: typecheck, lint, test, build, and e2e pass.

- [ ] **Step 3: Confirm root ignore boundary**

Run:

```powershell
git check-ignore -v projects/__verify-react-vite-capacitor/package.json
```

Expected: ignored by `.gitignore` `projects/*` rule.

- [ ] **Step 4: Clean disposable app**

Remove only `projects/__verify-react-vite-capacitor` after confirming the resolved path is under `C:\Users\piete\Documents\app-dev\projects`.

- [ ] **Step 5: Run full root governance gate**

```powershell
scripts/check-workspace.ps1
scripts/validate-codex-assets.ps1 -RequirePythonToml true
scripts/test-hooks.ps1
scripts/test-workspace.ps1
git diff --check
```

Expected: all exit 0.

- [ ] **Step 6: Commit**

```bash
git add scripts/test-workspace.ps1 scripts/verify-app.ps1
git commit -m "test: verify finalized react vite capacitor template"
```

### Task 12: Final Review And Handoff

**Files:**
- Modify: `docs/audit/app-dev-audit-closeout.md` or create a new audit note if needed

**Interfaces:**
- Produces: final template readiness note with verified commands and known limits.

- [ ] **Step 1: Inspect git diff**

```powershell
git status --short
git diff --stat
git diff -- templates/react-vite-capacitor scripts standards docs
```

Expected: only intended files changed.

- [ ] **Step 2: Run final verification**

```powershell
scripts/check-workspace.ps1
scripts/validate-codex-assets.ps1 -RequirePythonToml true
scripts/test-hooks.ps1
scripts/test-workspace.ps1
git diff --check
```

Expected: all exit 0.

- [ ] **Step 3: Write handoff note**

Record:
- dependencies added
- commands run
- generated app verification outcome
- whether native platform folders remain per-app generation only
- any skipped checks and exact blockers

- [ ] **Step 4: Commit**

```bash
git add docs/audit templates scripts standards
git commit -m "docs: close react vite capacitor template finalization"
```

## Self-Review

- Spec coverage: Covers the current template gaps from the attachments after correcting stale items already present in the checkout.
- Placeholder scan: No unresolved placeholder markers are intentionally left in this plan.
- Type consistency: Shared names are consistent across tasks: `env`, `supabase`, `queryClient`, `SettingsLayout`, `DataTableLayout`, `dashboardModuleSchema`, `useDashboardModules`, and `useDashboardViewStore`.
- Reuse check: The plan explicitly uses shadcn CLI/component source, Supabase React docs, Capacitor CLI flow, current template files, and execution-time SuperVOX skills before custom code.
- Dependency boundary: All app dependencies are scoped to the template/generated app, not the `app-dev` root.
