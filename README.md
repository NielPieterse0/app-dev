# app-dev

Control workspace for building modular cross-platform apps with Codex.

This folder is not intended to be one giant application. It holds shared development standards, Codex instructions, reusable skills, scripts, and starter templates. Real apps should live under `projects/`, normally as independent git repositories.

## Layout

```text
app-dev/
  AGENTS.md
  .codex/
  .agents/
  standards/
  templates/
  scripts/
  projects/
```

## Default Stack

React + Vite + React Router, TypeScript, Tailwind, shadcn/ui, Radix, Zod, React Hook Form, TanStack Query, TanStack Table, Supabase, Capacitor, Vitest, Testing Library, and Playwright.

Repo-specific Codex skills live in `.agents/skills/` so Codex can discover them as project skills.

## First Commands

From this folder:

```powershell
.\scripts\check-workspace.ps1
```

To create a project folder from the React/Vite/Capacitor template:

```powershell
.\scripts\create-app.ps1 -Name my-app -Template react-vite-capacitor
```

Then open `projects/my-app/AGENTS.md` and define the app-specific modules and verification commands. Install dependencies inside the generated project, not at the `app-dev` root:

```powershell
cd projects\my-app
npm install
..\..\scripts\verify-app.ps1 -ProjectPath .
```

To run control-workspace checks:

```powershell
.\scripts\test-workspace.ps1
```
