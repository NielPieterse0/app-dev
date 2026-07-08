# `/verify`

Use this command when the implementation is ready for verification.

## Required workflow

1. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`.
2. Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
3. Run `../../scripts/verify-app.ps1 -ProjectPath .`.
4. Record verification evidence in `workflow-receipts.md`.
5. Record any skipped or blocked checks explicitly.

Do not mark the work complete if receipt validation or app verification fails.
