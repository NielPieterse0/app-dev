# React Vite Capacitor App Instructions

This file defines the durable app contract for this project.

Keep feature-specific requirements, scenarios, risks, tasks, workflow receipts, and completion criteria in `specs/NNN-<slug>/`.

Follow the root `app-dev/AGENTS.md` standards.

## Active Specification

- Active spec: `specs/001-initial/spec.md` until a later spec becomes active.
- Start new work by creating or updating a numbered spec with `/specify`.
- The first feature spec should live under `specs/001-initial/`.
- Later feature specs live under `specs/NNN-<slug>/`.

## App Type

Default cross-platform app: React + Vite + React Router + Capacitor.

## App Identity

- Users: developers creating generated cross-platform business apps from this template.
- Core jobs: start a runnable React/Vite/Capacitor app and extend it with product-specific modules.
- Platforms: desktop web, mobile web, Android, and iOS unless a later spec narrows the target set.
- Repository model: generated apps remain tracked in the root `app-dev` repository unless a later recorded decision splits them out.

## Durable Constraints

- Cross-module imports use the target module public surface only: `@/modules/<module>`.
- Do not place app dependencies at the workspace root; keep them inside this project.
- Do not store secrets, private keys, service-role keys, or `.env` files in the repository.
- Document required public environment variables in `.env.example`.
- Use publishable browser keys only in frontend-exposed configuration.

## Platform Constraints

- Native requirements: Capacitor shell only until a later spec requires native folders or device APIs.
- Add native platform folders and native APIs only after an active spec explicitly requires them.

## Verification Baseline

- Run the app's available verification commands through `../../scripts/verify-app.ps1 -ProjectPath .`.
- If a required script is missing, report the missing script instead of inventing commands.
- UI changes require rendered verification on the relevant supported surfaces.
