# 003 Signal Live Ingestion Tasks

- Status: complete
- Spec: `specs/003-live-ingestion/spec.md`

## Task List

- [x] Update Signal spec, plan, checklist, tasks, and workflow receipts for the Slice 3 hardening-plus-ingestion scope.
- [x] Add base-ref aware workflow-obligation detection and root tests for committed-tree enforcement.
- [x] Make CI analyze the real Signal spec artifacts and narrow secret-scan exclusions so `projects/signal` is covered.
- [x] Replace the settings two-step save path with a transactional Supabase RPC and tighten the internal-MVP write guardrail.
- [x] Stop settings hydration from overwriting dirty drafts and degrade failed configured saves into the local fallback store.
- [x] Remove the eager env export, scope settings refetch behavior, and close the query-route correctness gaps.
- [x] Fix dashboard source-filter affordance and the activity-chart color token mismatch.
- [x] Add live GitHub and Hacker News adapters plus mocked contract tests.
- [x] Add persisted source-item storage, a manual refresh flow, and dashboard reads from persisted source items.
- [x] Update dashboard empty, live, degraded, and refresh states plus rendered verification expectations.
- [x] Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before implementation handoff.
- [x] Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` before completion.
- [x] Run `../../scripts/verify-app.ps1 -ProjectPath .` and record the results.
