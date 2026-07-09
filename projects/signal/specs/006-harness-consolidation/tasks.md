# 006 Harness Consolidation Tasks

## Task List

- [ ] T1 Add phase-to-command table to `standards/spec-driven-workflow.md` (R1)
- [ ] T2 Slim root `AGENTS.md` Development Workflow to pointers plus Lean/Gated one-liners (R1)
- [ ] T3 Slim `SKILL.md` Workflow section to pointer plus skill-specific content (R1)
- [ ] T4 Update `validate-codex-assets.ps1` workflow assertions from steps to pointers (R1)
- [ ] T5 Add working-directory line to every `.agents/commands/*.md`; document clarify inside `/specify` and convergence inside `/verify` (R2)
- [ ] T6 Register `analyze.md` in `validate-codex-assets.ps1` required paths (R2)
- [ ] T7 Create `standards/workspace-manifest.psd1`; refactor `check-workspace.ps1` and `validate-codex-assets.ps1` to consume it; downgrade `docs/audit/` to path-exists; single-source the 32768 AGENTS.md limit and align `.codex/config.toml` (R3)
- [ ] T8 Create `scripts/check-all.ps1`; point README and root `AGENTS.md` governance-check sections at it (R4)
- [ ] T9 Decide and execute wire-or-delete for `.codex/hooks/verify-before-finish.ps1`; update Test-HookReferences and test-hooks accordingly (R5)
- [ ] T10 Exclude `.github/` in `create-app.ps1` template copy; relocate template workflow files to `templates/common/ci/verify.reference.yml`; update validator required paths (R6)
- [ ] T11 Verify hook/rules coverage superset and close any escalation-capable gaps in `default.rules` (R7)
- [ ] T12 Scrub absolute paths from `.codex/config.toml` comments; convert README examples to cross-platform forms (R8)
- [ ] T13 Remove pending markers from `standards/workspace.md` as each item lands (R9)
- [ ] T14 Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` and full governance sequence; then `../../scripts/verify-app.ps1 -ProjectPath .` for Signal regression; push and confirm hosted CI green

## Notes

Ordering: T7 (manifest) before T4 and T6 where practical so assertion changes land as manifest data, not new hardcoded checks (scripting standard 9.3). T9 and T10 are independent and may land first. Hosted CI green on the head commit is the completion referee for every task.
