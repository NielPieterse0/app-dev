# QA Gates

Run available package scripts:

- typecheck
- lint
- test
- build
- e2e

Run workflow receipt validation before claiming completion:

- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`

For UI work, also verify rendered behavior:

- meaningful first screen
- no framework overlay
- no relevant console errors
- one core interaction
- desktop viewport
- mobile viewport
- no clipping, overlap, or horizontal overflow

Use Browser plugin first when available, otherwise Playwright.
