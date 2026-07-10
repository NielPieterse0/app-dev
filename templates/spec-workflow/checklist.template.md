# {{SPEC_NUMBER}} {{SPEC_TITLE}} Gated Review Checklist

- Status: draft
- Spec: `specs/{{SPEC_DIR}}/spec.md`
- Risk level: {{RISK_LEVEL}}

Use this checklist for auth, payments, secrets, public APIs, data access, file uploads, RLS, AI tool actions, deployment, or live migration work.

## Clarify

- [ ] CHK001 Ambiguous requirements were resolved before implementation.
- [ ] CHK002 Sensitive operations are described concretely in `spec.md`.
- [ ] CHK003 Failure and rollback behavior is documented in `PLAN.md`.
- [ ] CHK004 Open questions in `spec.md` are closed or explicitly deferred.

## Security And Data Review

- [ ] CHK005 Authentication and authorization behavior is explicit.
- [ ] CHK006 Data access paths and storage locations are identified.
- [ ] CHK007 Secret handling follows `standards/security.md`.
- [ ] CHK008 Public API, file upload, or AI action exposure is reviewed.
- [ ] CHK009 Rollback or failure behavior is documented for data or live-environment changes.

## Implementation Readiness

- [ ] CHK010 `tasks.md` reflects the final work sequence.
- [ ] CHK011 `workflow-receipts.md` identifies the required workflow sections for this spec.
- [ ] CHK012 Relevant receipt sections include current implementation, verification, and outstanding-gap notes.
- [ ] CHK013 Verification commands are current.
- [ ] CHK014 Any destructive, live migration, deployment, or credentialed operation has explicit user approval before execution.
