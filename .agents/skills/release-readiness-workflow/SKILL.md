---
name: release-readiness-workflow
description: app-dev workflow receipt and verification closure contract for completion claims, risky changes, PR readiness, and deploy-adjacent work.
metadata:
  owner: app-dev
  version: 1.0.0
  maturity: stable
---

# Release Readiness Workflow

Use this local workflow whenever app-dev work reaches a completion claim or touches high-risk release surfaces.

## Trigger Surface

This workflow is required when:

- the user asks to finish, complete, stage, commit, push, or prepare a PR
- the task touches auth, payments, public APIs, deploy, secrets, live migrations, or production-readiness surfaces
- the handoff claims a feature is complete or ready

## Required Inputs

1. Active spec under `specs/NNN-<slug>/`.
2. Current `tasks.md`.
3. `workflow-receipts.md` in the active spec directory.
4. `checklist.md` when risk-domain work exists.

## Required Receipt

Update the `## Release Readiness Workflow Receipt` section in `workflow-receipts.md` with:

- trigger surface
- command path used
- local workflow used
- external skill used or unavailable
- files and surfaces reviewed
- implementation evidence
- verification commands
- verification result
- outstanding gaps
- decision and closure

## Verification Contract

- Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before handoff.
- Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
- Run `../../scripts/verify-app.ps1 -ProjectPath .` when the completion claim depends on the current app verification state.
- Record exact commands run and exact blockers.
- Do not mark the receipt complete if required verification evidence is missing.

## External Accelerators

This workflow must use:

- `C:/Users/piete/.codex/skills/verification-before-completion/SKILL.md` when work touches PR, deploy, or production-readiness surfaces
- `C:/Users/piete/.codex/skills/security-scan/SKILL.md`when work touches auth, payments, or public API surfaces
- `C:/Users/piete/.codex/skills/github/SKILL.md` when PR or GitHub work is involved
- `C:/Users/piete/.codex/skills/gh-fix-ci/SKILL.md` when GitHub CI work is involved
- `C:/Users/piete/.codex/skills/gh-address-comments/SKILL.md` when PR comments are involved
- `C:/Users/piete/.codex/skills/yeet/SKILL.md` when work touches deploy, secrets, live migrations, or production-readiness surfaces
- `C:/Users/piete/.codex/skills/stripe-best-practices/SKILL.md` when work touches payments or Stripe surfaces

If none are available, continue with local app-dev standards and record the gap in the receipt.
