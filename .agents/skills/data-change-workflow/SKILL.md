---
name: data-change-workflow
description: app-dev workflow receipt and review contract for Supabase, SQL, RLS, migrations, schemas, and data access changes.
metadata:
  owner: app-dev
  version: 1.0.0
  maturity: stable
---

# Data Change Workflow

Use this local workflow whenever app-dev work changes data access, schema, or database security surfaces.

## Trigger Surface

This workflow is required when the task or changed files touch:

- `supabase/`
- `*.sql`
- RLS policies, migrations, or schema files
- `src/lib/supabase*`
- `src/modules/*/schemas/`
- `src/modules/*/services/`

## Required Inputs

1. Active spec under `specs/NNN-<slug>/`.
2. Current `tasks.md`.
3. `workflow-receipts.md` in the active spec directory.
4. `checklist.md` for sensitive data, auth, API, or migration work.

## Required Receipt

Update the `## Data Change Workflow Receipt` section in `workflow-receipts.md` with:

- trigger surface
- command path used
- local workflow used
- external skill used or unavailable
- files and surfaces reviewed
- verification performed
- outstanding gaps
- decision and closure

## Verification Contract

- Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before handoff.
- Run `../../scripts/verify-app.ps1 -ProjectPath .`.
- Record any RLS, migration, or schema review done through `checklist.md`.
- Record unresolved live-environment or secret-dependent gaps explicitly.

## Optional External Accelerators

When installed and trusted, this workflow may use:

- `supabase-best-practices`
- `security-scan`

If none are available, continue with local app-dev standards and record the gap in the receipt.
