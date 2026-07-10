# {{SPEC_NUMBER}} {{SPEC_TITLE}} Specification

- Status: draft
- Risk level: {{RISK_LEVEL}}
- App: {{APP_NAME}}
- Created: {{DATE}}
- Input/source request: TODO: quote or summarize the user request, ticket, audit item, or decision that created this spec.

## Summary

TODO: state the user-visible outcome this feature or workflow slice must deliver.

## Problem

TODO: state the user problem, workflow gap, or governance defect this slice addresses.

## User Scenarios And Testing

### User Story 1 - TODO: short title (Priority: P1)

TODO: describe the independently valuable journey or vertical increment in plain language.

**Why this priority**: TODO: explain why this is the first slice.

**Independent Test**: TODO: describe how this story can be verified by itself.

**Acceptance Scenarios**:

1. **Given** TODO: initial state, **When** TODO: user or agent action, **Then** TODO: observable result.
2. **Given** TODO: alternate state, **When** TODO: action, **Then** TODO: observable result.

### User Story 2 - TODO: short title (Priority: P2)

TODO: remove this section when the feature has only one independently testable slice.

**Why this priority**: TODO: explain priority or remove.

**Independent Test**: TODO: describe standalone verification or remove.

**Acceptance Scenarios**:

1. **Given** TODO: initial state, **When** TODO: action, **Then** TODO: observable result.

## Edge Cases

- TODO: boundary condition or state none.
- TODO: failure, empty, permission, offline, or conflict scenario or state none.

## Requirements

### Functional Requirements

- **FR-001**: TODO: system or workflow MUST provide a concrete, testable capability.
- **FR-002**: TODO: system or workflow MUST provide a second concrete, testable capability.

### Key Entities

- **TODO: Entity or artifact name**: TODO: describe the entity, durable artifact, or state affected by this feature. Use "None" when not applicable.

## Success Criteria

### Measurable Outcomes

- **SC-001**: TODO: measurable or observable success condition independent of implementation details.
- **SC-002**: TODO: second measurable or observable success condition.

## Data And Permissions

- Data model impact: TODO: affected entities, fields, migrations, or state none.
- Permissions: TODO: roles, access rules, RLS, local file access, or state none.
- Sensitive operations: TODO: destructive actions, credentials, live services, or state none.

## UX And Platform Notes

- Target surfaces: TODO: desktop web, mobile web, Android, iOS, CLI, docs, or another explicit set.
- States: TODO: empty, loading, error, success, offline, or state none.
- Native needs: TODO: device APIs, app-store packaging, or state none.
- Rendered verification: TODO: desktop/mobile viewport expectations or state not applicable.

## Assumptions

- TODO: reasonable default chosen because the request did not specify it.

## Risks And Open Questions

- Risks: TODO: delivery, correctness, security, data, platform, or workflow risk.
- Open questions: TODO: unresolved decision or state none.

## Verification Intent

- Pre-implementation gate: Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` after updating this spec set.
- Workflow evidence gate: Keep `workflow-receipts.md` current and run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` before completion.
- Completion checks: Run `../../scripts/analyze-spec.ps1 -ProjectPath .`, `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`, and `../../scripts/verify-app.ps1 -ProjectPath .`.
- Rendered checks: TODO: first meaningful screen, core interaction, desktop viewport, and mobile viewport when UI work is in scope, or state not applicable.
