# Standard App Stack

## Default

Use React + Vite + React Router for most applications. Add Capacitor when Android/iOS packaging or native APIs are needed.

## Libraries

- TypeScript: application language
- Vite: default app scaffold/build tool
- React Router: SPA routing
- Tailwind CSS: styling utility layer
- CSS variables: design tokens
- shadcn/ui: editable component source
- Radix primitives: accessible component behavior
- lucide-react: icons
- Zod: runtime validation and schema inference
- React Hook Form: forms
- TanStack Query: server/cache state
- Zustand: small local state stores
- TanStack Table: data tables
- Recharts or ECharts: charts
- Supabase: default backend/auth/storage/Postgres
- Capacitor: Android/iOS wrapper for web-first apps
- Vitest: unit tests
- Testing Library: component tests
- Playwright: end-to-end and responsive UI checks

## Use Next.js When

- SEO or public content matters.
- SSR/server rendering is needed.
- Route-level server functions reduce backend complexity.
- The app is content-heavy or ecommerce-like.

## Use Expo When

- Native mobile UX is central.
- Camera, Bluetooth, background tasks, gestures, native maps, or offline mobile behavior dominate.
- Web is secondary.

## Use Tauri When

- Desktop packaging is required.
- Native desktop capabilities such as filesystem, tray, updater, or OS shortcuts are necessary.

## Dependency Policy

Install dependencies in the package where they are used. Keep root dependencies limited to workspace tooling. Commit lockfiles for reproducibility.
