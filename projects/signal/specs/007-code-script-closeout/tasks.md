# 007 Code And Script Closeout Tasks

## Task List

- [x] T1 Fix `scripts/common.ps1` path return and add vocabulary registry constants (R1, R5)
- [x] T2 Fix `scripts/test-hooks.ps1` path literals and binary invocation (R1)
- [x] T3 Fix `scripts/test-workflow-enforcement.ps1` dot-source and fixture paths (R1)
- [x] T4 Fix `scripts/get-workflow-obligations.ps1` git invocation (R1)
- [x] T5 Fix `scripts/validate-workflow-receipts.ps1` script path literal; consume shared section/field helpers (R1, R5)
- [x] T6 Fix `scripts/analyze-spec.ps1` and `scripts/check-spec-artifacts.ps1` separator handling; consolidate active-spec regex onto the common helper (R1, R5)
- [x] T7 Fix `scripts/create-app.ps1` generated paths and remove dead `-NoInstall` logic (R1, R4)
- [x] T8 Add `scripts/lint-portability.ps1` plus test fixture and PSScriptAnalyzer settings; wire as first CI steps; register required paths (R2)
- [x] T9 CI hygiene: concurrency, timeouts, npm and Playwright caching, failure artifact upload (R3)
- [x] T10 Diagnose app-validation failure from current evidence; regenerate the lockfile only if the evidence implicates it (R3)
- [x] T11 Normalize `verify-app.ps1` switch semantics; source `new-spec.ps1` ValidateSet from the registry (R4)
- [x] T12 Verify the secret-scanner baseline remains correct and remove any stale suppression drift if present (R6)
- [x] T13 Rework `projects/signal/scripts/check-public-launch-readiness.ps1` to net-grant-state evaluation across all migrations with explicit full-feed-replace messaging (R7)
- [x] T14 Record template parity for Signal `env.ts` and `SettingsLayout`, reconciling only if drift is found (R8)
- [x] T15 Fix `scripts/export-workspace.ps1` staging-relative exclusion (R9)
- [x] T16 Append the repo-relative link correction note to the 2026-07-09 findings ledger; refresh PR 2 description after CI green (R10)
- [ ] T17 Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` and `../../scripts/verify-app.ps1 -ProjectPath .`; run full governance/workspace checks; push and confirm both CI jobs green on the head commit

## Notes

T1 lands first: every other portability fix depends on the common helper returning forward-slash paths and shared helper definitions. T8 lands in the same commit range as T1-T7 so the gate ships with the fix (scripting standard 9). T10 must use the current evidence first and only broaden to lockfile regeneration if the app-validation failure specifically points there. Hosted CI green on the head commit closes this spec; local verification is supporting evidence only.
