---
name: mobile-validation-workflow
description: app-dev workflow receipt and validation contract for Capacitor, Expo, Android, iOS, and emulator or simulator checks.
metadata:
  owner: app-dev
  version: 1.0.0
  maturity: stable
---

# Mobile Validation Workflow

Use this local workflow whenever app-dev work affects mobile packaging, native bridges, or device-specific runtime behavior.

## Trigger Surface

This workflow is required when the task or changed files touch:

- `capacitor.config.*`
- `android/`
- `ios/`
- Expo-native behavior
- native plugins, permissions, or packaging flows

## Required Inputs

1. Active spec under `specs/NNN-<slug>/`.
2. Current `tasks.md`.
3. `workflow-receipts.md` in the active spec directory.
4. `checklist.md` when permissions, auth, deploy, payments, or live environment steps are involved.

## Required Receipt

Update the `## Mobile Validation Workflow Receipt` section in `workflow-receipts.md` with:

- trigger surface
- command path used
- local workflow used
- external skill used or unavailable
- files and surfaces reviewed
- verification performed
- outstanding gaps
- decision and closure

## Verification Contract

- Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before handoff.
- Run `../../scripts/verify-app.ps1 -ProjectPath .`.
- Record Android and iOS validation status separately.
- If emulator or simulator verification is unavailable, record the exact blocker.

## External Accelerators

This workflow must use:

- `C:/Users/piete/.codex/skills/android-emulator-qa/SKILL.md`when work touches Android or Android Capacitor surfaces
- `C:/Users/piete/.codex/skills/ios-debugger-agent/SKILL.md` when work touches iOS or iOS Capacitor surfaces

If none are available, continue with local app-dev standards and record the gap in the receipt.
