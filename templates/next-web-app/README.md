# Next Web App Template

Use this template only when SSR, SEO, server routes, content-heavy public pages, or ecommerce-like flows justify Next.js.

After creating a project, install dependencies inside the generated project:

```powershell
npm install
npm run typecheck
npm run lint
npm run test
npm run build
```

Keep shared app standards from `app-dev/AGENTS.md`. Prefer app-specific dependencies inside this project package.

This template includes a minimal App Router source tree, explicit ESLint config, TypeScript config, and a smoke test so verification scripts run against real files instead of an empty package.
