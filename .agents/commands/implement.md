# `/implement`

Use this command only when the active spec, current tasks, and workflow receipts are ready.

Working directory: `projects/<app>/`.

## Required workflow

1. Confirm `spec.md`, `tasks.md`, and `workflow-receipts.md` exist.
2. Classify the task into any matching local workflow wrappers:
   - `ui-change-workflow`
   - `data-change-workflow`
   - `mobile-validation-workflow`
   - `release-readiness-workflow`
3. Update the relevant workflow receipt sections during implementation.
4. Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before handoff.

Do not claim completion from this command. Use `/verify` or `/release-readiness` for closure.
