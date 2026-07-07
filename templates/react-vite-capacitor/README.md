# React Vite Capacitor Template

Use this template for default cross-platform business apps. It is a minimal runnable Vite app scaffold with verification scripts and app-dev layout primitives.

## Template includes

- Tailwind config and Tailwind CSS entry wiring.
- shadcn/ui config with React-friendly path aliases.
- `@/*` import alias in Vite and TypeScript.
- Capacitor config for web-first native packaging.
- State primitives for empty, loading, and error surfaces.
- Verification scripts for `typecheck`, `lint`, `test`, and `build`.

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

## Reference template complete when

- [ ] `Supabase` env handling is present with a documented public key contract.
- [ ] shadcn/ui source lives in `src/components/ui/` instead of relying on registry install steps.
- [ ] The module contract is demonstrated by a full `src/modules/<module>/` structure.
- [ ] Form, table, and chart examples show the supported library patterns.
- [ ] `SettingsLayout` exists and is used by a route.
- [ ] Playwright covers the required responsive projects and widths.
- [ ] A CI workflow template runs install, typecheck, lint, test, build, and e2e.
- [ ] A disposable generated app passes the workspace verification flow.
