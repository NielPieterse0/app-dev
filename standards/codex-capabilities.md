# Codex Capability Routing Standard

Use local app-dev assets first. Treat all global skills and plugins as optional unless they are actually installed, trusted, and visible in the active Codex session.

## Required Local Capability

| Task | Local capability |
| --- | --- |
| App planning, scaffolding, module contracts, adaptive layout, and verification | `.agents/skills/cross-platform-app-workflow` |
| Numbered feature specs, tasks, gated-path reviews, and spec-to-plan handoff | `templates/spec-workflow/`, `scripts/new-spec.ps1`, `scripts/check-spec-artifacts.ps1`, `standards/spec-driven-workflow.md` |

## Optional External Capabilities

These names are routing hints, not repository dependencies. Use them only when present in the active Codex environment. If they are missing, proceed with the local skill and standards, then state the gap in the handoff.

| Task | Optional external capability |
| --- | --- |
| Multi-feature app iteration, ambiguous requirements, or spec-heavy decomposition | `spec-kit` methodology translated into local app-dev assets; use lean path by default and gated path for work flagged by `standards/security.md` |
| New app screens, dashboards, redesigns, visually driven UI | `frontend-app-builder` |
| Rendered UI QA, dev server issues, responsive bugs, console errors | `frontend-testing-debugging` |
| shadcn/ui setup, components, registry, `components.json` | `shadcn-best-practices` |
| React or Next.js component/data-flow/performance review | `react-best-practices` |
| Supabase schema, SQL, RLS, query, or Postgres performance work | `supabase-best-practices` |
| Browser automation when Browser/IAB is unavailable or insufficient | `playwright` |
| Completion claims, handoff, or PR readiness | `verification-before-completion` |
| Production readiness, auth, payments, secrets, APIs, or data access | `security-scan`, dependency audit, secret scan, rendered verification |
| GitHub repo, PR, CI, or review workflows | `github`, `gh-fix-ci`, `gh-address-comments`, `yeet` |
| Capacitor Android emulator validation | `android-emulator-qa` |
| Capacitor iOS simulator validation | `ios-debugger-agent` |
| Metrics dashboards, KPI views, chart-heavy reports | `data-visualization`, `build-dashboard`, Data Analytics widgets |
| AI features or `OPENAI_API_KEY` setup | `openai-platform-api-key` and OpenAI Platform plugin |
| Payments, subscriptions, marketplaces | `stripe-best-practices` |
| Hosting, Workers, Pages, deployment | `cloudflare`, `workers-best-practices`, `vercel-deploy` |

## Routing Rules

- Load `cross-platform-app-workflow` first for app-dev work.
- Prefer local translated spec-driven assets over vendoring or depending on upstream `spec-kit` runtime files.
- Prefer Browser/IAB for rendered UI checks when available. Use Playwright as the fallback and record why.
- Keep deployment capabilities conditional until the app chooses a hosting target.
- Keep MCP servers user-level by default. Add project-level MCP only for repo-specific tooling, never for personal credentials or secret-bearing env blocks.
- Do not copy global plugin skills into this repository unless the workflow must be project-specific.
- Do not let plugin routing replace app-specific `AGENTS.md` or `PLAN.md` decisions. Product requirements still decide stack, modules, data model, permissions, and target platforms.

## Future App Review Checklist

Use this dry-run checklist before feature work begins in a generated app:

- Product decision record is present in `projects/<app>/AGENTS.md`.
- `projects/<app>/PLAN.md` exists for architectural or multi-module work.
- App type is selected: React/Vite/Capacitor, Next.js, or Expo.
- Capability routing is visible in the app instructions without treating optional global skills as required.
- Verification command is documented.
- No secrets, production environment files, or root app dependencies were added.
- Production-readiness reviews include dependency audit, secret scan, rendered UI verification, and security review of auth, authorization, RLS, public APIs, deploys, and live migrations.
