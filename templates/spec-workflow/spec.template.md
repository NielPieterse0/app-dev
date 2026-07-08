# {{SPEC_NUMBER}} {{SPEC_TITLE}} Specification

- Status: draft
- Risk level: {{RISK_LEVEL}}
- App: {{APP_NAME}}
- Created: {{DATE}}

## Summary

Replace this line with the user-visible outcome this feature must deliver.

## Problem

Replace this line with the user problem or workflow gap this feature addresses.

## Users And Scenarios

- Primary users: Replace with the operators or audiences for this feature.
- Core scenario: Replace with the main workflow this feature unlocks.
- Out of scope: Replace with explicit exclusions that keep this feature narrow.

## Requirements

### Functional Requirements

1. Replace with the first concrete requirement.
2. Replace with the second concrete requirement.

### Acceptance Criteria

1. Replace with the first observable success condition.
2. Replace with the second observable success condition.

## Data And Permissions

- Data model impact: Replace with affected entities, fields, or state changes.
- Permissions: Replace with roles, access rules, or state none.
- Sensitive operations: Replace with risky actions or state none.

## UX And Platform Notes

- Target surfaces: Replace with desktop web, mobile web, Android, iOS, or another explicit set.
- States: Replace with empty, loading, error, and success expectations.
- Native needs: Replace with required device APIs or state none.

## Risks And Open Questions

- Risks: Replace with the main delivery or correctness risks.
- Open questions: Replace with unresolved decisions or state none.

## Verification Intent

- Pre-implementation gate: Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` after updating this spec set.
- Workflow evidence gate: Keep `workflow-receipts.md` current and run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` before completion.
- Completion checks: Run `../../scripts/verify-app.ps1 -ProjectPath .` plus rendered desktop and mobile checks before handoff.
