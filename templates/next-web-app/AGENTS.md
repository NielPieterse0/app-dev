# Next Web App Instructions

Follow the root `app-dev/AGENTS.md` standards. Use this template only when SSR, SEO, server routes, public content, or ecommerce-like flows justify Next.js.
Use this project's `PLAN.md` for architecture, module, risk, and verification decisions.

## Product Decision Record

- Users: Replace with the target audience before feature work.
- Core jobs: Replace with the primary user jobs before feature work.
- Modules: Replace with vertical modules before feature work.
- Data model: Replace with primary entities before feature work.
- Permissions: Replace with roles and access rules before feature work.
- Platforms: desktop web and mobile web unless revised.
- Native requirements: none.

## Capability Routing

- Use `cross-platform-app-workflow` as the required local app-dev skill.
- Treat frontend, React/Next, security, GitHub, and deployment skills/plugins as optional external capabilities.
- Continue with local standards and report the gap if optional capabilities are unavailable.

## Verification

After installing dependencies inside this project, run available scripts through `../../scripts/verify-app.ps1 -ProjectPath .`.
