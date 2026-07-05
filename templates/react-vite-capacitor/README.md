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

Initialize Tailwind, shadcn/ui, and Capacitor when the app is ready for styled UI components and native wrappers. Keep dependencies inside the generated project package.

Required app layout primitives:

- `src/app/AppShell.tsx`
- `src/app/NavigationShell.tsx`
- `src/app/PageHeader.tsx`
- `src/components/layout/ListDetailLayout.tsx`
- `src/components/layout/FormLayout.tsx`
- `src/components/layout/DataTableLayout.tsx`
