# Workspace Standard

Use `app-dev` as a control workspace. Keep applications under `projects/`.

Start with independent app repositories. Move to a pnpm/Turborepo monorepo only when shared packages are real and stable enough to justify coordination overhead.

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

## When To Use A Monorepo

Use a monorepo when two or more apps need versioned shared source packages such as:

- `packages/ui`
- `packages/auth`
- `packages/api-client`
- `packages/config`
- `packages/test-utils`

Use `apps/*` for applications and `packages/*` for shared packages.

## When To Keep Separate Repos

Keep separate repos when apps have independent release schedules, independent client ownership, different access-control needs, or little shared source code.
