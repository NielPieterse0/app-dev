# app-dev

Control workspace for building modular cross-platform apps with Codex.

This folder is not intended to be one giant application. It holds shared development standards, Codex instructions, reusable skills, scripts, starter templates, planning templates, and validation workflow files. Real apps should live under `projects/`, normally as independent git repositories.

## Layout

```text
app-dev/
  AGENTS.md
  PLANS.md
  .codex/
  .agents/
  .github/workflows/
  standards/
  templates/
  scripts/
  projects/
```

## Prerequisites

Required for local workspace validation:

- Git
- PowerShell 7+ (`pwsh`)
- Node.js LTS and npm. Node 22 LTS is recommended for new generated apps; Node 20.19.4+ is the minimum practical floor for current Expo/React Native tooling.
- Python 3.11+ for TOML validation via `tomllib`
- Codex CLI/app when using `.codex/` project config, hooks, rules, and skills

Recommended per project:

- pnpm or yarn only when the app template/project uses that lockfile
- Playwright browsers after dependency install when the app uses `npm run e2e`
- Android Studio for Capacitor/Expo Android emulator validation
- Xcode on macOS for iOS simulator validation
- Supabase CLI only for projects that actually use Supabase local development

Do not install app dependencies at the `app-dev` root. Install dependencies inside the generated project folder.

## Default Stack

React + Vite + React Router, TypeScript, Tailwind, shadcn/ui, Radix, Zod, React Hook Form, TanStack Query, TanStack Table, Supabase, Capacitor, Vitest, Testing Library, and Playwright.

Repo-specific Codex skills live in `.agents/skills/` so Codex can discover them as project skills. Optional external/global skills and plugins are documented in `standards/codex-capabilities.md`; they are not required local dependencies.

## Planning

Root planning protocol lives in `PLANS.md`. New project plans are created from `templates/PLAN.template.md`.

A generated app should have:

```text
projects/<app>/AGENTS.md
projects/<app>/PLAN.md
```

Use the plan for architectural, data model, auth, routing, deployment, migration, or multi-module work.

## Codex Governance Checks

The `.codex/config.toml` file is active. It enables project hooks, selects the least-privilege `app-dev-workspace` permission profile, and relies on `.codex/rules/default.rules` for command policy outside the sandbox. Project-local Codex assets load only after the repository is trusted in Codex.

Run Codex asset validation after changing `.codex/`, `.agents/skills/`, `AGENTS.md`, planning templates, CI, or workspace scripts:

```powershell
.\scripts\validate-codex-assets.ps1
```

Run hook policy tests separately:

```powershell
.\scripts\test-hooks.ps1
```

Run the local secret scan before distributing or pushing workspace changes:

```powershell
.\scripts\scan-secrets.ps1
```

Create a distributable workspace archive without `.git/`, generated projects, dependencies, logs, or reports:

```powershell
.\scripts\export-workspace.ps1
```

## First Commands

From this folder:

```powershell
.\scripts\check-workspace.ps1
.\scripts\validate-codex-assets.ps1
.\scripts\test-hooks.ps1
.\scripts\scan-secrets.ps1
```

To create a project folder from the React/Vite/Capacitor template:

```powershell
.\scripts\create-app.ps1 -Name my-app -Template react-vite-capacitor
```

Then open `projects/my-app/AGENTS.md` and `projects/my-app/PLAN.md` and define the app-specific modules, decisions, and verification commands. Install dependencies inside the generated project, not at the `app-dev` root:

```powershell
cd projects\my-app
npm install
..\..\scripts\verify-app.ps1 -ProjectPath .
```

To run control-workspace checks:

```powershell
.\scripts\test-workspace.ps1
```

## CI

`.github/workflows/app-dev-validation.yml` runs the control-workspace validation scripts on push, pull request, and manual dispatch. The workflow validates Codex assets, hooks, project generation, and the React template structure without installing template dependencies.
