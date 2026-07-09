# 004 Signal Concept Workbench Checklist

- Status: complete
- Spec: `specs/004-concept-workbench/spec.md`

## Clarify

- [x] Keep the slice internal-only and no-auth.
- [x] Keep live ingestion manual-refresh only.
- [x] Keep source scope limited to public GitHub and Hacker News reads.

## Security And Data Review

- [x] Browser env stays publishable-key only; service-role and backend secrets remain prohibited.
- [x] Connected Supabase verification uses a bounded internal project and is recorded distinctly from mocked or unit validation.
- [x] Concept persistence remains internal-MVP only and does not create a public-launch claim.
- [x] Export avoids direct repo mutation from inside the browser app.
- [x] Spec and receipts state that the no-auth browser-write path is not production-ready or public-launch safe.

## Implementation Readiness

- [x] Drift-reconciliation changes update stale docs and receipts where live repo wording no longer matches reality.
- [x] App changes include repository, route, and export coverage.
- [x] UI changes include rendered dashboard, concept workspace, and responsive checks.
