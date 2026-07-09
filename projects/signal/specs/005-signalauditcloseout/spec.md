# 005 Signal Audit Closeout Specification

- Status: complete
- Risk level: sensitive
- App: signal
- Created: 2026-07-09

## Summary

Close the remaining 2026-07-09 audit findings across Signal and the app-dev workspace so the dashboard, template, docs, and workflow harness all match the intended internal-MVP contract.

## Problem

The audit found a mix of live runtime inefficiency, internal-MVP security-readiness ambiguity, documentation drift, template drift, validator mismatch, CI scaling drift, and stale skill-reference artifacts. Leaving them open weakens both Signal and the control workspace that future apps inherit.

## Users And Scenarios

- Primary users: the Signal operator, future app-dev contributors, and the workspace verification harness.
- Core scenario: a contributor refreshes the audit closeout slice, verifies Signal and workspace checks, and can see that the open findings are either fixed in code/docs/templates or explicitly blocked by a machine-checkable release gate.
- Out of scope: full auth/RLS remediation for public launch, new live sources, bundle-size optimization, chart-library replacement, native packaging work, and repo-topology redesign.

## Requirements

### Functional Requirements

1. The dashboard route must be able to promote a selected signal into a concept draft without eagerly loading concept drafts on every dashboard visit.
2. Signal must reuse canonical source-label metadata instead of route-local literals or duplicate label exports.
3. GitHub refresh failures must surface rate-limit/backoff guidance, and the app may support an optional internal operator token path that stays out of committed files.
4. Signal must expose a dedicated broader-deployment gate that fails while anonymous browser-write RPCs remain enabled.
5. Root README and `.codex/README` must match the current same-repo project model and the fact that project-level `default_permissions` are disabled on Windows.
6. The React/Vite/Capacitor template must stop eagerly parsing env at module scope, use router-aware settings links, set conservative Query Client defaults, and include a tracked Supabase scaffold.
7. Workspace validators and CI must reject stale duplicate skill-reference copies, enforce the receipt-verification mismatch fix, and validate tracked apps through a matrix rather than a hardcoded app working directory.

### Acceptance Criteria

1. Signal app checks pass with the dashboard concept-promotion flow still working and concept listing still functional.
2. Root governance checks pass with the updated docs, template scaffold, CI workflow, and workflow validators.
3. `npm run release:check` fails for the expected anonymous-write reason until a later auth-hardening slice removes that posture.
4. The audit findings document can be updated from fresh evidence instead of preserving stale open items that no longer match the checkout.

## Data And Permissions

- Data model impact: no new app-domain entities; this slice changes concept-query orchestration, template Supabase scaffold assets, and a release-readiness inspection script.
- Permissions: no public-launch permission expansion is allowed. Anonymous browser-write RPCs remain internal-MVP only and must be treated as a blocker for broader deployment.
- Sensitive operations: release gating around live-write RPC posture, template Supabase/RLS scaffolding, and CI/workflow enforcement updates.

## UX And Platform Notes

- Target surfaces: desktop web and mobile web verification for Signal; template/runtime and workspace governance files at the repo level.
- States: dashboard refresh errors must communicate GitHub rate-limit/backoff expectations clearly; settings and concepts workflows must keep their current loading/error behavior.
- Native needs: none for this slice.

## Risks And Open Questions

- Risks: CI/validator edits can create false positives; template scaffolding can drift again if checks are weaker than the docs; the public-launch gate is expected to fail until a later auth slice.
- Open questions: none for the approved closeout direction. The only deferred strategic decision is when to replace anonymous browser-write RPCs with authenticated user/session checks.

## Verification Intent

- Pre-implementation gate: Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` after updating this spec set.
- Workflow evidence gate: Keep `workflow-receipts.md` current and run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` before completion.
- Completion checks: Run `../../scripts/verify-app.ps1 -ProjectPath .`, rendered desktop/mobile checks, root governance checks, and `npm run release:check` before handoff.
