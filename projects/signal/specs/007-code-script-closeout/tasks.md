# 007 Code And Script Closeout Tasks

## Task List

- [ ] T1 Fix `scripts/common.ps1` path return and add vocabulary registry constants (R1, R5)
- [ ] T2 Fix `scripts/test-hooks.ps1` path literals and binary invocation (R1)
- [ ] T3 Fix `scripts/test-workflow-enforcement.ps1` dot-source and fixture paths (R1)
- [ ] T4 Fix `scripts/get-workflow-obligations.ps1` git invocation (R1)
- [ ] T5 Fix `scripts/validate-workflow-receipts.ps1` script path literal; consume shared section/field helpers (R1, R5)
- [ ] T6 Fix `scripts/analyze-spec.ps1` and `scripts/check-spec-artifacts.ps1` separator handling; consolidate active-spec regex onto the common helper (R1, R5)
- [ ] T7 Fix `scripts/create-app.ps1` generated paths and remove dead `-NoInstall` logic (R1, R4)
- [ ] T8 Fix Signal `package.json` release:check to invoke pwsh (R1)
- [ ] T9 Add `scripts/lint-portability.ps1` plus test fixture and PSScriptAnalyzer settings; wire as first CI steps; register required paths (R2)
- [ ] T10 CI hygiene: concurrency, timeouts, npm and Playwright caching, failure artifact upload (R3)
- [ ] T11 Diagnose app-validation failure from uploaded artifacts; regenerate lockfile on Linux if implicated (R3)
- [ ] T12 Normalize `verify-app.ps1` switch semantics; source `new-spec.ps1` ValidateSet from the registry (R4)
- [ ] T13 Secret scanner: add sb_secret_ family patterns; replace or remove the line-pinned allowlist entry (R6)
- [ ] T14 Rework `projects/signal/scripts/check-public-launch-readiness.ps1` to net-grant-state evaluation across all migrations with explicit full-feed-replace messaging (R7)
- [ ] T15 Template parity pass for Signal env.ts and SettingsLayout active-state; record reconciliations or accepted divergences (R8)
- [ ] T16 Fix `scripts/export-workspace.ps1` staging-relative exclusion (R9)
- [ ] T17 Append repo-relative link correction note to the 2026-07-09 findings ledger; refresh PR 2 description after CI green (R10)
- [ ] T18 Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` and `../../scripts/verify-app.ps1 -ProjectPath .`; run full governance sequence; push and confirm both CI jobs green on the head commit

## Notes

T1 lands first: every other portability fix depends on the common helper returning forward-slash paths. T9 lands in the same commit as T1-T8 so the gate ships with the fix (scripting standard 9). T11 depends on T10's artifact upload if the failure cause is not already evident from logs. Hosted CI green on the head commit closes this spec; local verification is supporting evidence only.
