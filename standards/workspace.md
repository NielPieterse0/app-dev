# Workspace Standard

Use `app-dev` as a single control workspace. All app projects live in-tree under `projects/` and are committed directly into the `app-dev` git history. Apps are not split into separate repositories.

## Default Shape

```text
app-dev/
  AGENTS.md
  .agents/
  docs/
    audit/
    superpowers/
  PLANS.md
  standards/
  templates/
    PLAN.template.md
  scripts/
  projects/
    app-name/
      AGENTS.md
      package.json
```

The root workspace owns governance, planning, audit, and template assets in addition to project generators. Keep workspace-level audit notes under `docs/audit/`, implementation plans and execution records under `docs/superpowers/`, the shared planning protocol in `PLANS.md`, and the reusable per-app plan scaffold in `templates/PLAN.template.md`.

## Repository Model

- `app-dev` is the only repository. `projects/<app-name>/` directories are tracked directly in it — they are not initialized as nested or standalone git repositories.
- Each app keeps its own `AGENTS.md`, `PLAN.md`, `specs/`, `checklist.md`, and `package.json` scoped to its directory, but shares the control repo's git history, `.codex/` governance layer, branch protection, and CI.
- Each app's `.gitignore` excludes its own `node_modules/`, build output, and test artifacts so they never enter the control repo's tracked tree.
- Per-app CI (typecheck/lint/test/build/e2e) must live in a workflow file at the repository root (`.github/workflows/`), scoped to the app's path via `on.push.paths` / `on.pull_request.paths`. GitHub Actions does not discover workflow files nested inside `projects/<app-name>/.github/workflows/` — those are inert and must not be used.
- If a shared package is ever needed across apps (e.g. a common UI kit or API client), add it under a `packages/` directory in this same repo. Do not create a separate repository or a second workspace for it.
- Exception: an app may be split into its own repository only for a hard external requirement — a different legal entity, a different access-control boundary, or a release process that genuinely cannot share this repo's branch protection. Any such split must update this document and the app's `PLAN.md` in the same change, so the exception is traceable rather than silent.
