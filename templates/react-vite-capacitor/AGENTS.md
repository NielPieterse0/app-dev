# React Vite Capacitor App Instructions

Follow the root `app-dev/AGENTS.md` standards.
Use `standards/codex-capabilities.md` for Codex skill and plugin routing.
Use this project's `PLAN.md` for architecture, module, risk, and verification decisions.

## App Type

Default cross-platform app: React + Vite + React Router + Capacitor.

## Product Decision Record

- Users: Developers creating generated cross-platform business apps from this template.
- Core jobs: Start a runnable React/Vite/Capacitor app, add vertical modules, and verify the app with local scripts.
- Modules: App shell, navigation shell, page header, list/detail layouts, form layout, data table layout, state primitives, and template reference surfaces.
- Data model: None in the template itself; generated apps define their own entities and schemas.
- Permissions: None in the template itself; generated apps define their own roles and access rules.
- Platforms: desktop web, mobile web, Android, and iOS unless a generated app narrows the target set.
- Native requirements: Capacitor shell only; generated apps add platform folders and native APIs when the product requires them.

## Required Before Feature Work

- Define product decision record in this file.
- Update `PLAN.md` for architecture-sensitive or multi-module work.
- Review the starter `AppShell`, `NavigationShell`, and base route structure.
- Initialize Tailwind and shadcn/ui when the first real UI surface needs component styling; use optional shadcn capability only if available.
- Add `.env.example` for required public environment variables.
- Use publishable Supabase browser keys only; never add service-role or secret keys to Vite env.
- Treat the template README checklist as the completion baseline for later tasks in this plan.

## Capability Routing

- Use `cross-platform-app-workflow` as the required local app-dev skill.
- Optional external capabilities may help with frontend UI, rendered QA, Supabase, shadcn/ui, security, mobile emulator checks, and deployment.
- Do not assume optional global skills/plugins are installed. Continue with local standards when they are unavailable.
- Prefer Browser/IAB for rendered UI checks when available; use Playwright as fallback and record why.
- Product-specific auth policies and RLS rules belong in generated app migrations after the app data model is defined.

## Verification

After installing dependencies inside this project, run available scripts through `../../scripts/verify-app.ps1 -ProjectPath .`.

## Done When

- Product decision record is complete for the current app.
- `PLAN.md` is current for architecture, data model, auth, routing, deployment, migration, or multi-module work.
- Available checks pass through `../../scripts/verify-app.ps1 -ProjectPath .`.
- Missing scripts are reported instead of invented.
- UI changes include rendered desktop and mobile checks.
- Handoff notes record deviations, skipped checks, and unresolved decisions.
