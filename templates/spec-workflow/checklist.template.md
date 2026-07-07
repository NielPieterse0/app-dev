# {{SPEC_NUMBER}} {{SPEC_TITLE}} Gated Review Checklist

- Status: draft
- Spec: `specs/{{SPEC_DIR}}/spec.md`
- Risk level: {{RISK_LEVEL}}

Use this checklist for auth, payments, secrets, public APIs, data access, file uploads, RLS, AI tool actions, deployment, or live migration work.

## Clarify

- [ ] Ambiguous requirements were resolved before implementation.
- [ ] Sensitive operations are described concretely in `spec.md`.
- [ ] Failure and rollback behavior is documented in `PLAN.md`.

## Security And Data Review

- [ ] Authentication and authorization behavior is explicit.
- [ ] Data access paths and storage locations are identified.
- [ ] Secret handling follows `standards/security.md`.
- [ ] Public API, file upload, or AI action exposure is reviewed.

## Implementation Readiness

- [ ] `tasks.md` reflects the final work sequence.
- [ ] Verification commands are current.
- [ ] Any live migration or deployment step requires explicit user approval.
