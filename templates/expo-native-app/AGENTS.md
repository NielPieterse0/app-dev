# Expo Native App Instructions

Follow the root `app-dev/AGENTS.md` standards. Use this template only when native mobile behavior is central enough that a web-first Capacitor app would fight the product.
Use this project's `PLAN.md` for architecture, module, risk, and verification decisions.

## Active Specification

- Start with `specs/001-initial/spec.md`.
- Create later feature specs under `specs/NNN-<slug>/`.
- Keep `PLAN.md`, `tasks.md`, and `workflow-receipts.md` aligned to the active spec before implementation starts.

## App Identity

- Users: Replace with the target audience when establishing the initial app identity.
- Core jobs: Replace with the primary mobile jobs the overall app will support.
- Platforms: iOS and Android unless revised.
- Native requirements: replace with the native APIs that justify Expo.

## Capability Routing

- Use `cross-platform-app-workflow` as the required local app-dev skill.
- Use the local wrapper workflows when triggered: `ui-change-workflow`, `data-change-workflow`, `mobile-validation-workflow`, and `release-readiness-workflow`.
- Treat native emulator/debugger, frontend, security, GitHub, and deployment skills/plugins as optional external capabilities.
- Continue with local standards and report the gap if optional capabilities are unavailable.

## Verification

After installing dependencies inside this project, run available scripts through `../../scripts/verify-app.ps1 -ProjectPath .`.

## Done When

- Active specification and task artifacts are current for the feature being built.
- `workflow-receipts.md` is current for any UI, data, mobile, or release-readiness work.
- `PLAN.md` is current for architecture, data model, auth, routing, deployment, migration, or multi-module work.
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` passes before completion.
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` passes before completion.
- Available checks pass through `../../scripts/verify-app.ps1 -ProjectPath .`.
- Missing scripts are reported instead of invented.
- Native permission needs are documented before adding device APIs.
- Handoff notes record deviations, skipped checks, and unresolved decisions.
