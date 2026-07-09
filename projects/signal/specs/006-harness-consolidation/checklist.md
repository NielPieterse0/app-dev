# 006 Harness Consolidation Checklist

## Clarify

- [ ] Confirm verify-before-finish decision: wire to a finish-stage hook event or delete (R5)
- [ ] Confirm 32768 as the adopted AGENTS.md byte limit before aligning config.toml (R3)
- [ ] Confirm the template CI reference filename convention (verify.reference.yml) before relocation (R6)

## Security And Data Review

- [ ] Hook and rules coverage superset re-verified after any policy edits (R7)
- [ ] Manifest refactor does not weaken any existing enforced check; removed exact-phrase assertions map to pattern-level replacements or a recorded acceptance
- [ ] No secrets, tokens, or absolute local paths introduced by generated or relocated files

## Implementation Readiness

- [ ] Spec, tasks, and receipts reviewed and consistent
- [ ] Execution ordering per tasks Notes accepted
- [ ] Hosted CI green criterion acknowledged as the completion referee
