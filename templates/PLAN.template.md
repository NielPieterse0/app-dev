# {{APP_NAME}} Task Plan

- Created: {{DATE}}
- Template: {{TEMPLATE}}
- Status: draft

## Goal

Define the outcome this app or task must deliver.

## Non-Goals

List explicit exclusions to prevent scope drift.

## Product Decision Record

- Users:
- Core jobs:
- Modules:
- Data model:
- Permissions:
- Target platforms:
- Native requirements:

## Architecture Decision

- App type:
- Routing model:
- State/data strategy:
- Backend/auth/storage:
- UI system:

## Module Plan

| Module | Responsibility | Main files | Verification |
| --- | --- | --- | --- |
| TBD | TBD | TBD | TBD |

## Implementation Steps

1. Confirm product decision record and app type.
2. Build or update the app shell, providers, routing, and theme tokens.
3. Implement vertical modules with schema, services/hooks, UI, routes, and tests.
4. Add empty, loading, and error states for every primary workflow.
5. Run verification and rendered desktop/mobile checks.

## Risks and Assumptions

| Item | Type | Impact | Mitigation |
| --- | --- | --- | --- |
| TBD | assumption | TBD | TBD |

## Verification

Run available checks through:

```powershell
../../scripts/verify-app.ps1 -ProjectPath .
```

Expected project checks:

```text
npm run typecheck
npm run lint
npm run test
npm run build
npm run e2e
```

Rendered UI checks:

- first meaningful screen
- primary user flow
- desktop viewport
- mobile viewport
- no clipped, overlapping, or overflowing text

## Open Decisions

| Decision | Options | Owner | Status |
| --- | --- | --- | --- |
| TBD | TBD | TBD | open |

## Handoff Notes

Record deviations from this plan, skipped checks, and next actions.
