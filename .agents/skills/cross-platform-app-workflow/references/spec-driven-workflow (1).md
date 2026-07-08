# Spec-Driven Workflow Reference

Use this reference when creating or updating app specs, plans, and task artifacts inside `projects/<app>`.

## Required Order

1. Read root `AGENTS.md`.
2. Read app `AGENTS.md`.
3. Confirm the active spec path from `AGENTS.md`.
4. Read `specs/NNN-<slug>/spec.md`.
5. Read or update `PLAN.md`.
6. Read or update `specs/NNN-<slug>/tasks.md`.
7. Read or update `specs/NNN-<slug>/workflow-receipts.md`.
8. For sensitive work, read or update `specs/NNN-<slug>/checklist.md`.

## Lean Path

Use the lean path for ordinary module work:

`spec -> plan -> tasks -> implement -> verify -> handoff`

## Gated Path

Use the gated path for auth, payments, secrets, public APIs, data access, file uploads, RLS, AI tool actions, deployment, or live migrations:

`clarify -> spec -> checklist -> plan -> tasks -> implement -> converge -> verify -> handoff`

## Required Checks

- Before implementation handoff: `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
- Before completion: `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`
- Before completion: `../../scripts/verify-app.ps1 -ProjectPath .`
- For UI work: rendered desktop and mobile verification
