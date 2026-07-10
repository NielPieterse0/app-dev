# {{APP_NAME}} Task Plan

- Created: {{DATE}}
- Template: {{TEMPLATE}}
- Active spec: `specs/001-initial/spec.md`
- Status: draft

## Goal

TODO: state the outcome this app, feature, or workflow slice must deliver.

## Non-Goals

TODO: list explicit exclusions that prevent scope drift.

## Spec Link

- Spec id: `001-initial`
- Spec path: `specs/001-initial/spec.md`
- Tasks path: `specs/001-initial/tasks.md`
- Workflow receipts path: `specs/001-initial/workflow-receipts.md`
- Checklist path: `specs/001-initial/checklist.md` when the feature follows the gated path.

## Constitution Check

- Constitution path: `../../standards/constitution.md`
- Free-tier-first impact: TODO: state cost impact or why an exception is needed.
- Same-repo impact: TODO: state whether work stays inside the root-tracked `projects/<app>` model.
- Evidence requirement: TODO: artifacts and checks required before completion.

## App Type And Platform Targets

- App type: TODO: React/Vite/Capacitor, Next.js, Expo, or documented project-specific choice.
- Primary platforms: TODO: desktop web, mobile web, Android, iOS, CLI, or docs.
- Native needs: TODO: Capacitor/Expo/native APIs or state none.
- Browser/rendered surfaces: TODO: pages, routes, or states that require rendered verification.

## Technical Context

- Runtime and package manager: TODO: node/runtime expectations and package manager in use.
- External services: TODO: Supabase, APIs, storage, queues, or state none.
- Environment contract: TODO: required env groups, local fallbacks, and secret handling boundaries.
- Migration/runtime constraints: TODO: CI, device, browser, or deployment constraints that shape implementation.

## Architecture Decisions

- Routing model: TODO: route structure and navigation model.
- State/data strategy: TODO: client state, server state, validation, and cache decisions.
- Backend/auth/storage: TODO: backend, auth, storage, and migration choices.
- UI system: TODO: design system, component library, and token decisions.
- Implementation constraints: TODO: approvals, workflow constraints, and local standards that affect implementation.

## Project Structure And Ownership

| Surface | Owner | Paths | Notes |
| --- | --- | --- | --- |
| TODO: surface | TODO: module or layer | TODO: repo-relative paths | TODO: ownership boundary or coupling note |

## Module Impact

| Module | Responsibility | Main files | Verification |
| --- | --- | --- | --- |
| TODO: module name | TODO: owned user workflow and data boundary | TODO: repo-relative files | TODO: focused checks |

## Data Auth Permission And Storage Impact

- Data model impact: TODO: entities, migrations, storage, or state none.
- Auth impact: TODO: session, roles, RLS, or state none.
- Permission impact: TODO: user, admin, file, device, or live-service permission impact.
- Storage impact: TODO: database, local storage, files, object storage, or state none.
- Sensitive operations: TODO: destructive, credentialed, live-environment, or state none.

## Workflow Classification

- UI workflow: TODO: required or not required, with reason.
- Data workflow: TODO: required or not required, with reason.
- Mobile workflow: TODO: required or not required, with reason.
- Release-readiness workflow: TODO: required or not required, with reason.
- Receipt owner: `specs/001-initial/workflow-receipts.md`

## Verification Strategy

- Artifact validation: `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
- Spec analysis: `../../scripts/analyze-spec.ps1 -ProjectPath .`
- Receipt validation: `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`
- App verification: `../../scripts/verify-app.ps1 -ProjectPath .`
- Focused tests: TODO: exact package scripts or test files.
- Missing scripts policy: Report missing commands instead of inventing them.

## Rendered UI Verification

- Required: TODO: yes/no.
- First meaningful screen: TODO: route or state.
- Core interaction: TODO: interaction or state transition.
- Desktop viewport: TODO: viewport and expected result.
- Mobile viewport: TODO: viewport and expected result.
- Text/layout risk: TODO: overflow, clipping, overlap, or state none.

## Risks And Assumptions

| Item | Type | Impact | Mitigation |
| --- | --- | --- | --- |
| TODO: risk or assumption | assumption | TODO: impact | TODO: mitigation or owner |

## Complexity Tracking

- Complexity level: TODO: low, medium, or high.
- Main unknowns: TODO: list the unknowns that could change sequencing or scope.
- Fallback path: TODO: smallest acceptable fallback if the preferred implementation stalls.
- Rollback or recovery path: TODO: how to recover from migration, deployment, or behavioral regression risk.

## Decisions

### Accepted

- TODO: accepted decision, reason, and date.

### Rejected

- TODO: rejected option and reason, or state none.

### Deferred

- TODO: deferred decision, owner, and trigger to revisit, or state none.

## Deviations And Follow-Ups

- Deviations from spec or standards: TODO: state none or document accepted deviation.
- Follow-ups: TODO: state none or list next slice items.

## Handoff Notes

Record deviations from this plan, skipped checks, unresolved decisions, and next actions before completion.
