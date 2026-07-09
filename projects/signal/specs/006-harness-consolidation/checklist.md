# 006 Harness Consolidation Checklist

## Clarify

- [x] Confirm verify-before-finish decision: delete the dormant helper and remove all required-path/test/doc references (R5)
- [x] Confirm 32768 as the adopted AGENTS.md byte limit before aligning config.toml and the manifest (R3)
- [x] Confirm the template CI reference filename convention (`verify.reference.yml`) before relocation (R6)

## Security And Data Review

- [ ] Hook and rules coverage superset re-verified after any policy edits (R7)
- [ ] Manifest refactor does not weaken any existing enforced check; removed exact-phrase assertions map to pattern-level replacements or a recorded acceptance
- [ ] No secrets, tokens, or absolute local paths introduced by generated or relocated files

## Implementation Readiness

- [x] Spec, tasks, and receipts reviewed and consistent
- [x] Execution ordering per tasks Notes accepted
- [x] Hosted CI green criterion acknowledged as the completion referee
