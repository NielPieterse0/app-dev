# {{APP_NAME}} Task Plan

- Created: {{DATE}}
- Template: {{TEMPLATE}}
- Status: draft

## Goal

Replace this line with the outcome this app or task must deliver.

## Non-Goals

Replace this line with explicit exclusions that prevent scope drift.

## Product Decision Record

- Users: Replace with the target audience and primary operators.
- Core jobs: Replace with the main jobs the app must support.
- Modules: Replace with the vertical modules that own routes, UI, data, and tests.
- Data model: Replace with the primary entities, relationships, and persistence needs.
- Permissions: Replace with roles, access rules, and sensitive operations.
- Target platforms: Replace with desktop web, mobile web, Android, iOS, or another explicit set.
- Native requirements: Replace with the native APIs or device capabilities required, or state none.

## Architecture Decision

- App type: Replace with React/Vite/Capacitor, Next.js, Expo, or the documented project-specific choice.
- Routing model: Replace with the route structure and navigation model.
- State/data strategy: Replace with client state, server state, validation, and cache decisions.
- Backend/auth/storage: Replace with backend, auth, storage, and migration choices.
- UI system: Replace with design system, component library, and token decisions.

## Module Plan

| Module | Responsibility | Main files | Verification |
| --- | --- | --- | --- |
| Replace with module name | Replace with owned user workflow and data boundary | Replace with main route/component/service files | Replace with focused checks |

## Implementation Steps

1. Confirm product decision record and app type.
2. Build or update the app shell, providers, routing, and theme tokens.
3. Implement vertical modules with schema, services/hooks, UI, routes, and tests.
4. Add empty, loading, and error states for every primary workflow.
5. Run verification and rendered desktop/mobile checks.

## Risks and Assumptions

| Item | Type | Impact | Mitigation |
| --- | --- | --- | --- |
| Replace with risk or assumption | assumption | Replace with impact | Replace with mitigation or owner |

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
| Replace with decision | Replace with concrete options | Replace with owner | open |

## Handoff Notes

Record deviations from this plan, skipped checks, and next actions.
