# `/release-readiness`

Use this command for completion claims, PR readiness, or risky deploy-adjacent work.

## Required workflow

1. Confirm the `Release Readiness Workflow Receipt` is complete.
2. Confirm `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` passes.
3. Confirm `../../scripts/verify-app.ps1 -ProjectPath .` passes or exact blockers are recorded.
4. Confirm `checklist.md` is complete when the spec is sensitive.
5. Report unresolved gaps explicitly instead of implying readiness.
