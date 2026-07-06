# Expo Native App Instructions

Follow the root `app-dev/AGENTS.md` standards. Use this template only when native mobile behavior is central enough that a web-first Capacitor app would fight the product.
Use this project's `PLAN.md` for architecture, module, risk, and verification decisions.

## Product Decision Record

- Users: Replace with the target audience before feature work.
- Core jobs: Replace with the primary mobile jobs before feature work.
- Modules: Replace with vertical modules before feature work.
- Data model: Replace with primary entities before feature work.
- Permissions: Replace with roles and device permission needs before feature work.
- Platforms: iOS and Android unless revised.
- Native requirements: replace with the native APIs that justify Expo.

## Capability Routing

- Use `cross-platform-app-workflow` as the required local app-dev skill.
- Treat native emulator/debugger, frontend, security, GitHub, and deployment skills/plugins as optional external capabilities.
- Continue with local standards and report the gap if optional capabilities are unavailable.

## Verification

After installing dependencies inside this project, run available scripts through `../../scripts/verify-app.ps1 -ProjectPath .`.
