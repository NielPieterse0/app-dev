# {{SPEC_NUMBER}} {{SPEC_TITLE}} Task Breakdown

- Status: draft
- Spec: `specs/{{SPEC_DIR}}/spec.md`

## Task List

- [ ] Confirm the workflow classification in `workflow-receipts.md` and mark the required workflow sections.
- [ ] Confirm `spec.md` is complete and reflects the intended scope.
- [ ] Update `PLAN.md` so architecture and verification choices match this spec.
- [ ] Implement the minimum shell, routing, data, and UI changes required by this spec.
- [ ] Add or update tests for the primary behavior and failure states.
- [ ] Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before implementation handoff.
- [ ] Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` before claiming completion.
- [ ] Run `../../scripts/verify-app.ps1 -ProjectPath .` and record results.

## Notes

- Keep this file aligned to `workflow-receipts.md`, including whether UI, data, mobile, or release-readiness workflows are required for this spec.
