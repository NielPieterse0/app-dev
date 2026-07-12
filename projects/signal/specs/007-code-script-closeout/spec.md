# 007 Code And Script Closeout

- Status: draft
- Risk level: gated
- Date: 2026-07-09
- App: signal (workspace-scoped slice hosted in the Signal spec chain per the 005 precedent)

## Summary

Close out the remaining open code and script findings from the 2026-07-09 review cycle: the Linux portability defect class that turned CI red on PR 2, CI job hygiene and diagnosability, release-gate design, helper duplication, parameter-semantics normalization, and residual hygiene items. This slice starts from the current branch state, so already-landed fixes such as `pwsh`-based `release:check`, modern Supabase secret-key detection, and Signal/template `env.ts` parity are treated as verified baseline, not new implementation targets. `standards/scripting.md` 1.0.0 is already present; this spec implements the remaining repo changes needed to satisfy its active portability and enforcement rules.

## Requirements

- R1 Portability class (scripting standard 2.1-2.5): fix `scripts/common.ps1` (Get-ActiveSpecRelativePath returns forward-slash paths and exposes shared vocabularies/helpers), `scripts/test-hooks.ps1` (path literals; invoke `pwsh`, never the Windows-only binary name), `scripts/test-workflow-enforcement.ps1` (dot-source and fixture path literals), `scripts/get-workflow-obligations.ps1` (direct git invocation, `2>$null`), `scripts/validate-workflow-receipts.ps1` (script path literal), `scripts/analyze-spec.ps1` and `scripts/check-spec-artifacts.ps1` (separator round-trips; consolidate the active-spec regex onto the common helper), and `scripts/create-app.ps1` (generated AGENTS.md uses forward-slash `../../scripts/` paths).
- R2 Enforcement gate ships with the fix (scripting standard 9): add `scripts/lint-portability.ps1` and a PSScriptAnalyzer settings file; wire both as the first workspace-validation CI steps; add both to required-path validation.
- R3 CI hygiene: concurrency group with cancel-in-progress, timeout-minutes on both jobs, setup-node npm caching keyed to the app lockfile, Playwright browser caching, and failure-artifact upload of playwright-report and test-results. Diagnose and fix the app-validation failure on the current head using the uploaded evidence; if the lockfile is the cause, regenerate it via Linux `npm ci`/`npm i --package-lock-only` per scripting standard B.8.
- R4 Parameter semantics (scripting standard 3): `verify-app.ps1` default-true switches renamed to opt-out form (`-SkipE2E`, and RequireAnyCheck made default behavior with an opt-out switch); `create-app.ps1` dead `-NoInstall` logic removed; `new-spec.ps1` ValidateSet sourced from the common.ps1 vocabulary registry including gated.
- R5 Shared-code consolidation (scripting standard 6): Get-SectionBody and Get-FieldValue moved to `common.ps1`; vocabulary registry constants added and consumed by Test-GatedRiskLevel, analyze-spec status sets, and receipt validators.
- R6 Secret scanner baseline: keep modern Supabase key-shape detection active and confirm there is no line-pinned suppression drift left in `scripts/scan-secrets.ps1`; if any stale suppression remains, replace it with a path-plus-pattern justification or remove it.
- R7 Release gate design (scripting standard B.7): `projects/signal/scripts/check-public-launch-readiness.ps1` computes net grant state across all migrations instead of pattern-matching two fixed files, so a future revoke migration flips the gate without editing it. The failure message names the full-feed replace capability explicitly. The anonymous browser-write posture itself remains intentionally unchanged and internal-MVP only; it is not production-ready and public launch remains blocked until an auth/RLS hardening slice.
- R8 Template parity evidence (scripting standard B.9): verify `projects/signal/src/lib/env.ts` parity with the template `env.ts` and confirm SettingsLayout active-state handling is router-derived in both template and app; record the no-drift result or any accepted divergence in the receipts/handoff.
- R9 Export staging fix: `scripts/export-workspace.ps1` second-pass exclusion computes relative paths against the staging root so prefix exclusions apply correctly to staged items.
- R10 Hygiene: convert absolute local paths in `docs/audit/2026-07-09-app-dev-signal-review-findings.md` links to repo-relative form via an appended correction note (audit records append, never rewrite); refresh the PR 2 description to reflect actual CI state once green.

## Out Of Scope

- Manifest refactor and workflow-spine changes: `specs/006-harness-consolidation/`.
- npm advisory audit: remains blocked by tenant policy; Dependabot server-side alerts recommended as the substitute, decision recorded here.
- Removal of the anonymous browser-write RPCs: future auth/RLS hardening slice; guarded by the release gate.

## Verification Intent

- `scripts/lint-portability.ps1` passes over the fixed tree and demonstrably fails on a seeded violation fixture in its test.
- Full governance sequence passes locally on Windows and, decisively, in hosted CI on ubuntu-latest.
- `projects/signal`: `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`, and `../../scripts/verify-app.ps1 -ProjectPath .` pass; typecheck, lint, test, build, e2e pass in CI.
- Both CI jobs green on the pushed head of PR 2. Hosted CI is the closure referee.
