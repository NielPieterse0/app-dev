# React Vite Capacitor Template

Use this template for default cross-platform business apps. It is a minimal runnable Vite app scaffold with verification scripts and app-dev layout primitives.

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
