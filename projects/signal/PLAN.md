# Signal Task Plan

- Created: 2026-07-09
- Template: react-vite-capacitor
- Active spec: `specs/005-signalauditcloseout/spec.md`
- Status: complete

## Goal

Close the remaining 2026-07-09 audit findings across Signal and the app-dev workspace so the branch no longer carries avoidable runtime inefficiency, stale governance guidance, weak workflow enforcement drift, or template gaps.

## Non-Goals

- shipping public-launch auth and full multi-user authorization in this slice
- adding new live sources beyond GitHub and Hacker News
- replacing Supabase or the current internal-MVP persistence model
- broad bundle-size optimization or chart-library replacement
- native Android or iOS packaging work
- repo-splitting or monorepo restructuring

## Spec Link

- Spec id: `005-signalauditcloseout`
- Spec path: `specs/005-signalauditcloseout/spec.md`
- Tasks path: `specs/005-signalauditcloseout/tasks.md`
- Workflow receipts path: `specs/005-signalauditcloseout/workflow-receipts.md`
- Checklist path: `specs/005-signalauditcloseout/checklist.md`
- Audit source: `../../docs/audit/2026-07-09-app-dev-signal-review-findings.md`

## Architecture Decision

- Dashboard concept promotion must use a mutation-only path so the primary dashboard route does not eagerly query concept drafts on every visit.
- Concept listing remains a separate query-backed concern for `/concepts`.
- GitHub ingestion stays browser-based for the internal MVP, but it now needs explicit rate-limit messaging and optional operator-token support rather than opaque refresh failures.
- The internal no-auth RPC posture remains intentionally not public-launch safe, so this slice adds a dedicated `npm run release:check` gate that fails while anonymous write RPCs remain enabled.
- Root README, `.codex/README`, CI, template scaffolding, and workflow validators must agree with the current same-repo project model and Windows permission-profile reality.
- Template improvements must be enforced by workspace checks so generated apps inherit the fixed contract instead of relying on documentation alone.

## Module Plan

| Surface | Responsibility | Main files | Verification |
| --- | --- | --- | --- |
| `dashboard` | avoid unnecessary concept reads on the primary route while preserving promotion flow | `src/modules/dashboard/**`, `src/modules/concepts/hooks/useConcepts.ts` | route tests and app checks |
| `sources` | improve GitHub refresh resilience and clean source-label drift | `src/modules/sources/**`, `.env.example`, `README.md` | adapter tests and app checks |
| `settings` | reuse canonical source labels instead of route-local literals | `src/modules/settings/**`, `src/modules/sources/**` | route tests and lint/typecheck |
| `release-readiness` | make the anonymous-write deployment blocker explicit and machine-checkable | `scripts/check-public-launch-readiness.ps1`, `package.json`, docs/spec artifacts | direct gate execution plus artifact checks |
| `workspace/template` | reconcile README and `.codex` truth, add template Supabase scaffold, fix template runtime defaults, remove duplicate skill references, and harden CI/validators | `README.md`, `.codex/README.md`, `.github/workflows/**`, `templates/**`, `scripts/**`, `.agents/**` | root governance checks and project-generation checks |

## Implementation Steps

1. Move Signal onto a dedicated audit-closeout spec and keep plan/tasks/receipts/checklist current for the slice.
2. Split concept writes from concept reads so the dashboard can promote signals without loading concept drafts.
3. Reuse canonical source labels in Signal and remove the duplicate label/fixture drift surface.
4. Add clearer GitHub Search rate-limit handling and optional operator token support.
5. Add the explicit public-launch release gate for anonymous browser-write RPC posture.
6. Reconcile root README and `.codex/README` with the current repo and permission-profile truth.
7. Fix template env/query-client/settings-link behavior and add a tracked Supabase scaffold.
8. Harden workflow validators and CI so receipt evidence, duplicate skill references, template scaffolding, and project validation stay enforced.
9. Re-run Signal and root verification, then update the audit findings document with fresh dispositions.

## Risks And Assumptions

| Item | Type | Impact | Mitigation |
| --- | --- | --- | --- |
| Public launch still cannot proceed because auth/RLS hardening is not implemented in this slice | risk | high | make the blocker explicit with `npm run release:check` and keep docs/specs honest |
| CI and workspace validators can regress if docs-only and template-only expectations drift again | risk | medium | update the validators in the same change as the docs/template fixes |
| GitHub rate limits can still affect a browser-only MVP | risk | medium | improve error messaging and support an optional operator token while keeping the trust boundary explicit |
| Branch-topology findings depend on Git history as well as file content | assumption | medium | verify branch state explicitly before final disposition instead of assuming the older audit text is still current |

## Data Security Posture

- Browser code may use only publishable Supabase keys; service-role or backend-only secrets remain prohibited.
- The current Signal no-auth RPC paths are internal-MVP only and block any public-launch or production-readiness claim.
- The optional `VITE_GITHUB_TOKEN` path is internal operator convenience only and is still browser-exposed.
- The release gate must fail while anonymous write RPC grants remain active.

## Failure And Rollback

- If the concept-hook split regresses route behavior, restore the previous hook shape only after preserving the new dashboard/query separation requirement.
- If template or validator changes break generated-app verification, fix the generator contract before changing the checks back.
- If the release gate misidentifies the anonymous-write posture, tighten the detection logic rather than weakening the guardrail.

## Verification

Run available checks through:

```powershell
../../scripts/verify-app.ps1 -ProjectPath .
```

Expected project checks:

```text
npm run typecheck
npm run lint
npm run test
npm run build
npm run e2e
```

Pre-completion artifact checks:

- `../../scripts/analyze-spec.ps1 -ProjectPath .`
- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`
- `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`

Additional closeout checks:

- `npm run release:check`
- `./scripts/check-workspace.ps1`
- `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`
- `./scripts/test-hooks.ps1`
- `./scripts/test-workflow-enforcement.ps1`
- `./scripts/test-analyze-spec.ps1`
- `./scripts/test-workspace.ps1`
- `./scripts/scan-secrets.ps1`

Verification result:

- Completed on 2026-07-09.
- Signal checks passed: `npm run typecheck`, `npm run lint`, `npm run test`, `npm run build`, `npm run e2e`, and `../../scripts/verify-app.ps1 -ProjectPath .`.
- Signal artifact checks passed: `../../scripts/analyze-spec.ps1 -ProjectPath .`, `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`, and `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
- Root governance checks passed: `./scripts/check-workspace.ps1`, `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`, `./scripts/test-hooks.ps1`, `./scripts/test-workflow-enforcement.ps1`, `./scripts/test-analyze-spec.ps1`, `./scripts/test-workspace.ps1`, and `./scripts/scan-secrets.ps1`.
- Public-launch gate failed as designed: `npm run release:check` correctly reported the remaining anonymous browser-write RPC posture as a blocker for broader deployment.

## Handoff Notes

Record deviations from this plan, any expected failing gates, and any branch-state findings that are closed by refreshed Git evidence rather than by file edits alone.
