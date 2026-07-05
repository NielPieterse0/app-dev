# React Vite Capacitor App Instructions

Follow the root `app-dev/AGENTS.md` standards.
Use `standards/codex-capabilities.md` for Codex skill and plugin routing.

## App Type

Default cross-platform app: React + Vite + React Router + Capacitor.

## Required Before Feature Work

- Define product decision record in this file.
- Review the starter `AppShell`, `NavigationShell`, and base route structure.
- Initialize Tailwind and shadcn/ui when the first real UI surface needs component styling; use `shadcn-best-practices` for setup.
- Add `.env.example` for required public environment variables.

## Capability Routing

- Use `frontend-app-builder` for new usable screens and visually driven app surfaces.
- Use `frontend-testing-debugging` for rendered UI verification, responsive layout checks, console errors, and interaction bugs.
- Use `supabase-best-practices` for database, auth, RLS, SQL, and Postgres performance work.
- Use `verification-before-completion` before claiming implementation work is complete.
- Prefer Browser/IAB for rendered UI checks when available; use Playwright as fallback and record why.

## Verification

After installing dependencies inside this project, run available scripts through `../../scripts/verify-app.ps1 -ProjectPath .`.
