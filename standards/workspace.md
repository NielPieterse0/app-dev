# Workspace Standard

Use `app-dev` as a control workspace. Keep applications under `projects/`.

Generated apps stay tracked in the root repository by default. Move an app into its own repository only after a recorded decision explains why release, ownership, or access-control needs justify the split.

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

## When To Use Shared Packages

Use a monorepo when two or more apps need versioned shared source packages such as:

- `packages/ui`
- `packages/auth`
- `packages/api-client`
- `packages/config`
- `packages/test-utils`

If shared packages become real, adopt a monorepo shape intentionally and record the migration decision in the affected app plans.

## When To Split A Project Out

Keep separate repos when apps have independent release schedules, independent client ownership, different access-control needs, or little shared source code.
