# Next Web App Instructions

This file defines the durable app contract for this project.

Keep feature-specific requirements, scenarios, risks, tasks, workflow receipts, and completion criteria in `specs/NNN-<slug>/`.

Follow the root `app-dev/AGENTS.md` standards.

## Active Specification

- Active spec: `specs/001-initial/spec.md` until a later spec becomes active.
- Start new work by creating or updating a numbered spec with `/specify`.
- The first feature spec should live under `specs/001-initial/`.
- Later feature specs live under `specs/NNN-<slug>/`.

## App Type

Use this template only when SSR, SEO, server routes, public content, or ecommerce-like flows justify Next.js.

## App Identity

- Users: replace with the target audience when establishing the initial app identity.
- Core jobs: replace with the primary user jobs the overall app will support.
- Platforms: desktop web and mobile web unless revised.
- Repository model: generated apps remain tracked in the root `app-dev` repository unless a later recorded decision splits them out.

## Durable Constraints

- Cross-module imports use the target module public surface only when the app adopts the module contract.
- Do not place app dependencies at the workspace root; keep them inside this project.
- Do not store secrets, private keys, service-role keys, or `.env` files in the repository.
- Document required public environment variables in `.env.example`.

## Platform Constraints

- Native requirements: none unless a later recorded decision changes the app type.
- Add deployment-specific or server-side integrations only after an active spec explicitly requires them.

## Verification Baseline

- Run the app's available verification commands through `../../scripts/verify-app.ps1 -ProjectPath .`.
- If a required script is missing, report the missing script instead of inventing commands.
- UI changes require rendered verification on the relevant supported surfaces.
