# `/verify`

Use this command when the implementation is ready for verification.

Working directory: `projects/<app>/`.

## Required workflow

1. Close convergence first: reconcile `spec.md`, `PLAN.md`, `tasks.md`, and `workflow-receipts.md` to the implemented state.
2. Record any deviations, skipped checks, or deferred items before running the gates.
3. Run `../../scripts/analyze-spec.ps1 -ProjectPath .`.
4. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`.
5. Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
6. Run `../../scripts/verify-app.ps1 -ProjectPath .`.
7. Record verification evidence in `workflow-receipts.md`.
8. Record any skipped or blocked checks explicitly.

Do not mark the work complete if analysis, receipt validation, or app verification fails.
