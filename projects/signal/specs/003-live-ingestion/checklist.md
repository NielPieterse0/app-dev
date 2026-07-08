# 003 Signal Live Ingestion Checklist

- Status: complete
- Spec: `specs/003-live-ingestion/spec.md`

## Clarify

- [x] Keep the slice internal-only and no-auth.
- [x] Keep live ingestion manual-refresh only.
- [x] Keep source scope limited to public GitHub and Hacker News reads.

## Security And Data Review

- [x] Browser env stays publishable-key only; service-role and backend secrets remain prohibited.
- [x] Settings writes now run through a transactional RPC rather than split browser upserts.
- [x] Source-item replacement runs through a bounded RPC and remains internal-MVP only.
- [x] Root secret scanning covers `projects/signal`.
- [x] Spec and receipts state that the no-auth browser-write path is not production-ready or public-launch safe.

## Implementation Readiness

- [x] Root workflow changes include tests and CI wiring.
- [x] App changes include repository, adapter, and route coverage.
- [x] Live integration verification remains explicitly bounded to disposable or local Supabase infrastructure only.
