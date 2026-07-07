# Next Web App Instructions

Follow the root `app-dev/AGENTS.md` standards. Use this template only when SSR, SEO, server routes, public content, or ecommerce-like flows justify Next.js.
Use this project's `PLAN.md` for architecture, module, risk, and verification decisions.

## Active Specification

- Start with `specs/001-initial/spec.md`.
- Create later feature specs under `specs/NNN-<slug>/`.
- Keep `PLAN.md` and `tasks.md` aligned to the active spec before implementation starts.

## App Identity

- Users: Replace with the target audience when establishing the initial app identity.
- Core jobs: Replace with the primary user jobs the overall app will support.
- Platforms: desktop web and mobile web unless revised.
- Native requirements: none.

## Capability Routing

- Use `cross-platform-app-workflow` as the required local app-dev skill.
- Treat frontend, React/Next, security, GitHub, and deployment skills/plugins as optional external capabilities.
- Continue with local standards and report the gap if optional capabilities are unavailable.

## Verification

After installing dependencies inside this project, run available scripts through `../../scripts/verify-app.ps1 -ProjectPath .`.

## Done When

- Active specification and task artifacts are current for the feature being built.
- `PLAN.md` is current for architecture, data model, auth, routing, deployment, migration, or multi-module work.
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` passes before completion.
- Available checks pass through `../../scripts/verify-app.ps1 -ProjectPath .`.
- Missing scripts are reported instead of invented.
- UI changes include rendered desktop and mobile checks.
- Handoff notes record deviations, skipped checks, and unresolved decisions.
