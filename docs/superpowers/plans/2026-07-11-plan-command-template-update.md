# /plan Command And Template Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the `/plan` command and `templates/spec-workflow/plan.template.md` so planning is stateful, per-spec, and enforced consistently across docs, generators, validators, and workflow checks.

**Architecture:** Treat this as a workflow-governance slice, not a single markdown edit. The command doc defines behavior, the plan template defines the generated artifact shape, and the validators plus scaffold generator must move with them so new and existing per-spec `plan.md` files under `specs/NNN-<slug>/` do not drift.

**Tech Stack:** Markdown command docs and templates, PowerShell validators and scaffolders, repo governance checks.

## Global Constraints

- `plan.md` remains under `projects/<app>/specs/NNN-<slug>/plan.md`.
- `/plan` creates or updates `plan.md` only; it does not create `tasks.md`, `workflow-receipts.md`, or `checklist.md`.
- Context reuse is preferred when still reliable; rereads are for direct inputs, drift checks, or decision-shaping standards.
- `standards/testing.md` and `standards/scripting.md` are conditional planning inputs, not mandatory rereads for every plan step.
- Existing validator compatibility mode remains the default unless the slice explicitly migrates an app to `current-template`.

## Summary

Update the `/plan` command so its required reads and checks reflect the actual workflow: plan from the active `spec.md`, revalidate broader standards only when context is no longer reliable, move abort logic into `Stop Conditions`, and keep duplicate checks out of `Post-Step Checks`. Update the plan template to record workflow shape explicitly, then align standards, validators, and scaffolding so the contract is generated and enforced without stale wording.

## Key Changes

- **Command contract**
  - Rewrite `.agents/commands/plan.md` to use a stateful workflow model with:
    - direct reads: active `spec.md` and `plan.template.md`
    - conditional rereads for `AGENTS.md` and broader standards
    - conditional reads for `standards/testing.md` and `standards/scripting.md`
    - workflow-shape selection recorded during planning
    - stop logic centralized in `Stop Conditions`
  - Keep section headings compatible with the command wrapper validator.

- **Plan artifact shape**
  - Add `Workflow shape: TODO: lean or gated.` to `templates/spec-workflow/plan.template.md`.
  - Preserve per-spec plan ownership and existing section names so current apps remain compatible unless intentionally refreshed.

- **Governance and enforcement**
  - Update `standards/spec-driven-workflow.md` so plan lifecycle guidance matches the new context-reuse model and clarifies when testing/scripting standards should be read.
  - Update `scripts/validate-codex-assets.ps1` to assert the new `/plan` command guidance and the new template field.
  - Update `scripts/check-spec-artifacts.ps1` to require `Workflow shape:` in per-spec plans.
  - Update `scripts/create-app.ps1` so generated apps fill the new workflow-shape field and remain placeholder-free.

## Test Plan

- Run `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`.
- Run `./scripts/test-workspace.ps1`.
- Run `./scripts/test-workflow-enforcement.ps1`.
- If the focused gates pass, run `./scripts/check-all.ps1`.
- Spot-check that generated or existing per-spec plans still point at `specs/NNN-<slug>/spec.md` and include `Workflow shape:`.

## Assumptions

- The intended behavior change is governance-level, not just editorial.
- Existing apps should stay on compatibility mode unless explicitly refreshed.
- `projects/signal` remains a useful canary, but the change is owned at the workspace level.
