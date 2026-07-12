# Expo Native App Instructions

This file defines the durable app contract for this project.

Keep feature-specific requirements, scenarios, risks, tasks, workflow receipts, and completion criteria in `specs/NNN-<slug>/`.

Follow the root `app-dev/AGENTS.md` standards.

## Active Specification

- Active spec: `specs/001-initial/spec.md` until a later spec becomes active.
- Start new work by creating or updating a numbered spec with `/specify`.
- The first feature spec should live under `specs/001-initial/`.
- Later feature specs live under `specs/NNN-<slug>/`.

## App Type

Use this template only when native mobile behavior is central enough that a web-first Capacitor app would fight the product.

## App Identity

- Users: replace with the target audience when establishing the initial app identity.
- Core jobs: replace with the primary mobile jobs the overall app will support.
- Platforms: iOS and Android unless revised.
- Repository model: generated apps remain tracked in the root `app-dev` repository unless a later recorded decision splits them out.

## Durable Constraints

- Cross-module imports use the target module public surface only when the app adopts the module contract.
- Do not place app dependencies at the workspace root; keep them inside this project.
- Do not store secrets, private keys, service-role keys, or `.env` files in the repository.
- Document required public environment variables in `.env.example`.

## Platform Constraints

- Native requirements: replace with the native APIs that justify Expo.
- Add new device APIs, permissions, or platform-specific integrations only after an active spec explicitly requires them.

## Verification Baseline

- Run the app's available verification commands through `../../scripts/verify-app.ps1 -ProjectPath .`.
- If a required script is missing, report the missing script instead of inventing commands.
- UI and native behavior changes require rendered verification on the relevant supported surfaces.
