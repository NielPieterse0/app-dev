# 006 Harness Consolidation

- Status: in progress
- Risk level: gated
- Date: 2026-07-09
- App: signal (workspace-scoped slice hosted in the Signal spec chain per the 005 precedent; see Out Of Scope)

## Summary

Wire Workspace Standard v2 (`standards/workspace.md` 2.0.0) fully into the harness: establish single-owner facts, collapse the four parallel workflow statements into one canonical source with executable commands, build the workspace manifest and canonical governance check, and remove the template CI contradiction. This spec implements the drift findings D1-D5, D8-D10, D12-D14 from the 2026-07-09 harness audit.

## Requirements

- R1 Workflow spine (D9): `standards/spec-driven-workflow.md` gains a phase-to-command table; root `AGENTS.md` Development Workflow section shrinks to the Lean/Gated one-liners plus pointers; `cross-platform-app-workflow/SKILL.md` Workflow section shrinks to the same pointer plus skill-specific content only; `validate-codex-assets.ps1` assertions updated to check pointers, not steps.
- R2 Command layer completion: every command file states its working directory (D13); `/analyze` is registered in required-path validation (this slice added the file and check-workspace entry; validate-codex-assets alignment lands here); clarify is documented as the gated branch of `/specify`; convergence closure is documented inside `/verify`.
- R3 Workspace manifest (D8, D12): `standards/workspace-manifest.psd1` created; `check-workspace.ps1` and `validate-codex-assets.ps1` consume it; `docs/audit/` entries downgraded to path-exists; the AGENTS.md size limit exists once (adopted value 32768) and `.codex/config.toml` `project_doc_max_bytes` agrees (D1).
- R4 Canonical governance check (D8): `scripts/check-all.ps1` sequences the full governance run; README and root `AGENTS.md` reference it instead of maintaining their own lists.
- R5 Dormant hook resolution (D2): delete `verify-before-finish.ps1` and remove its required-path, test, and documentation references rather than keeping an unwired helper.
- R6 Template CI contradiction (D5): `create-app.ps1` excludes `.github/` from template copies; template workflow files move to `templates/common/ci/verify.reference.yml` (and per-template reference variants as needed); both validators' required paths updated; `standards/workspace.md` 5.3 pending marker removed.
- R7 Policy layering documentation (D10): coverage relationship between the pre-command hook rules and `.codex/rules/default.rules` verified against current contents and the superset direction confirmed; any rules-file gap for escalation-capable blocked commands closed.
- R8 Hygiene (D3, D11, D14): `.codex/config.toml` comment paths made generic; README command examples converted to cross-platform pwsh forms; `.codex/README.md` alignment check.
- R9 Pending markers in `standards/workspace.md` (sections 4.2, 4.3, 5.3 and the layout note for templates/common) removed in the same commit that lands each item.

## Out Of Scope

- Script portability remediation, CI job hygiene, and code-level closeouts: `specs/007-code-script-closeout/`.
- Matrix directory discovery: deferred by recorded decision until a second app exists under `projects/` (workspace.md 5.2).
- Wrapper-skill consolidation beyond the thin-pointer rule: no change unless a real slice demands it.
- Workspace-level spec hosting convention: this slice and 007 ride the Signal spec chain per 005 precedent; if workspace-scoped specs recur, a dedicated location decision belongs in a future spec.

## Verification Intent

- `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` passes with specs 001-007 present.
- `scripts/check-all.ps1` exists and reproduces the CI workspace-validation sequence.
- `scripts/validate-codex-assets.ps1` passes against the slimmed AGENTS.md and SKILL.md with pointer assertions.
- Generated app from `scripts/create-app.ps1` contains no `.github/` directory.
- Hosted CI green on the pushed head is the closure evidence; local runs are supporting only.
