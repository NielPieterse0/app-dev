# {{APP_NAME}} Task Plan

- Created: {{DATE}}
- Template: {{TEMPLATE}}
- Active spec: `specs/001-initial/spec.md`
- Status: draft

## Goal

Replace this line with the outcome this app or task must deliver.

## Non-Goals

Replace this line with explicit exclusions that prevent scope drift.

## Spec Link

- Spec id: `001-initial`
- Spec path: `specs/001-initial/spec.md`
- Tasks path: `specs/001-initial/tasks.md`
- Checklist path: `specs/001-initial/checklist.md` when the feature follows the gated path.

## Architecture Decision

- App type: Replace with React/Vite/Capacitor, Next.js, Expo, or the documented project-specific choice.
- Routing model: Replace with the route structure and navigation model.
- State/data strategy: Replace with client state, server state, validation, and cache decisions.
- Backend/auth/storage: Replace with backend, auth, storage, and migration choices.
- UI system: Replace with design system, component library, and token decisions.
- Implementation constraints: Replace with spec-driven constraints, approvals, and workflow notes.

## Module Plan

| Module | Responsibility | Main files | Verification |
| --- | --- | --- | --- |
| Replace with module name | Replace with owned user workflow and data boundary | Replace with main route/component/service files | Replace with focused checks |

## Implementation Steps

1. Confirm product decision record and app type.
2. Confirm the active spec path and whether the feature follows the lean or gated path.
3. Build or update the app shell, providers, routing, and theme tokens.
4. Implement vertical modules with schema, services/hooks, UI, routes, and tests.
5. Add empty, loading, and error states for every primary workflow.
6. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, then run verification and rendered desktop/mobile checks.

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

Pre-implementation artifact check:

- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`

## Open Decisions

| Decision | Options | Owner | Status |
| --- | --- | --- | --- |
| Replace with decision | Replace with concrete options | Replace with owner | open |

## Handoff Notes

Record deviations from this plan, skipped checks, and next actions.
