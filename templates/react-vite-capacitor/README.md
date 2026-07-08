# React Vite Capacitor Template

Use this template for default cross-platform business apps. It is a minimal runnable Vite app scaffold with verification scripts and app-dev layout primitives.

## Template includes

- Tailwind config and Tailwind CSS entry wiring.
- shadcn/ui config with React-friendly path aliases.
- `@/*` import alias in Vite and TypeScript.
- Enforced module boundaries for cross-module imports via `@/modules/<module>` public barrels.
- Capacitor config for web-first native packaging.
- State primitives for empty, loading, and error surfaces.
- Verification scripts for `typecheck`, `lint`, `test`, `build`, and `e2e`.

After creating a project, install dependencies inside the generated project:

```powershell
npm install
npm run typecheck
npm run lint
npm run test
npm run build
```

Tailwind, shadcn/ui configuration, and a minimal Capacitor config are included so the first real UI surface can add shadcn components without reworking project structure. Keep dependencies inside the generated project package.

To add shadcn components after install:

```powershell
npx shadcn@latest add button
```

Required app layout primitives:

- `src/app/AppShell.tsx`
- `src/app/NavigationShell.tsx`
- `src/app/PageHeader.tsx`
- `src/components/layout/ListDetailLayout.tsx`
- `src/components/layout/FormLayout.tsx`
- `src/components/layout/DataTableLayout.tsx`
- `src/components/state/EmptyState.tsx`
- `src/components/state/LoadingState.tsx`
- `src/components/state/ErrorState.tsx`

Reference surfaces included in the template:

- `FormLayoutExample` shows the supported React Hook Form + Zod + shadcn `Form` pattern.
- `DataTableLayout` shows the supported TanStack Table + shadcn `Table` pattern.
- `SettingsLayout` is wired into nested settings routes for general, notifications, and a protected example section.

## Module boundaries

- Treat `src/modules/<module>/index.ts` as the only public cross-module API surface.
- Import another module through `@/modules/<module>`.
- Do not import another module's `routes/`, `hooks/`, `services/`, `schemas/`, `state/`, or `components/` files directly; the template ESLint config rejects those deep imports.

## Reference template complete when

- [x] `Supabase` env handling is present with a documented public key contract.
- [x] shadcn/ui source lives in `src/components/ui/` instead of relying on registry install steps.
- [x] The module contract is demonstrated by a full `src/modules/<module>/` structure.
- [x] Form, table, and chart examples show the supported library patterns.
- [x] `SettingsLayout` exists and is used by a route.
- [x] Playwright covers the required responsive projects and widths.
- [x] A CI workflow template runs install, typecheck, lint, test, build, and e2e.
- [x] A disposable generated app passes the workspace verification flow.

## Supabase reference notes

- Browser-facing Vite apps use `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY`.
- Do not expose `service_role`, secret, or backend-only Supabase keys in browser env.
- Use `/settings/protected` as the loader-guarded route example after wiring a real auth flow.
- Enable Row Level Security on exposed schemas such as `public` before shipping app data access.
- Keep product-specific auth flows, roles, and RLS policies in generated app migrations after the data model is defined.

## CI workflow

Generated apps inherit `.github/workflows/verify.yml`, which runs install, dependency review on pull requests, secret scanning, Playwright browser setup, and the full `typecheck`, `lint`, `test`, `build`, and `e2e` script set.

## Native platforms

This template does not store `android/` or `ios/` projects in source control. Add native platform folders per generated app after the product decision record confirms native delivery requirements.

Typical per-app native setup:

```powershell
npm install
npm install @capacitor/android @capacitor/ios
npm run build
npx cap add android
npx cap add ios
npx cap sync
```

Android builds require Android Studio and a working JDK. iOS native projects require macOS and Xcode. The generated helper script `scripts/add-native-platforms.ps1` automates the same flow from inside a generated app.
