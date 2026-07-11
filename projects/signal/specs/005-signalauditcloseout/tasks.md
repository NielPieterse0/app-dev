# 005 Signal Audit Closeout Task Breakdown

- Status: complete
- Spec: `specs/005-signalauditcloseout/spec.md`

## Task List

- [x] Confirm the workflow classification in `workflow-receipts.md` and mark the required workflow sections.
- [x] Confirm `spec.md` is complete and reflects the intended scope.
- [x] Update the slice plan so architecture and verification choices match this spec.
- [x] Split dashboard concept promotion from concept listing so the dashboard avoids eager concept reads.
- [x] Reuse canonical source labels and remove duplicate fixture-label drift.
- [x] Add clearer GitHub rate-limit handling plus optional internal operator token support.
- [x] Add the broader-deployment release gate for anonymous browser-write RPC posture.
- [x] Reconcile root README and `.codex/README` with the current repo and permission-profile truth.
- [x] Fix template env/query-client/settings-link behavior and add a tracked Supabase scaffold.
- [x] Remove the duplicate skill reference file and harden validators against future duplicate copies.
- [x] Generalize CI app validation away from a hardcoded app working directory and align validator expectations.
- [x] Add or update tests for the primary behavior and failure states.
- [x] Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before implementation handoff.
- [x] Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` before claiming completion.
- [x] Run `../../scripts/verify-app.ps1 -ProjectPath .`, root governance checks, and `npm run release:check`, then record results.

## Notes

- Keep this file aligned to `workflow-receipts.md`, including the required UI, data, and release-readiness workflows.
