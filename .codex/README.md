# Codex Setup

This folder contains active project-level Codex configuration for the `app-dev` control workspace.

## Active Assets

- `config.toml` selects the project permission profile and wires lifecycle hooks.
- `rules/default.rules` defines command approval/deny policy for commands Codex requests outside the sandbox.
- `hooks/pre-command.ps1` blocks destructive shell and edit operations through `PreToolUse` and `PermissionRequest`.
- `hooks/post-edit.ps1` adds verification reminders after edits and verification commands.
- `hooks/verify-before-finish.ps1` is a manual final verification helper for generated app projects.

Keep durable behavioral rules in the root `AGENTS.md`; keep repeatable task workflows in `.agents/skills/`.

## Trust Requirement

Project-local `.codex/` configuration loads only after this repository is trusted in Codex. After changing hook definitions, restart Codex and review/trust the changed hooks through `/hooks` before relying on them.

## Hook Representation

This project uses inline hook tables in `.codex/config.toml`. Do not add `.codex/hooks.json` unless the inline hook tables are removed first. Codex merges both forms in the same layer and may warn at startup.

## Permission Model

The active profile is `app-dev-workspace`.

Default behavior:

- Workspace files are writable for normal app/template/script work.
- `.codex/` and `.git/` are read-only under the default profile.
- Common secret-bearing files and key material are denied.
- Outbound network access is disabled by default.

For deliberate governance edits under `.codex/`, temporarily use a profile that permits those edits, then restore this profile.

## Validation

Run this after changes to Codex configuration, hooks, skills, or workspace structure:

```powershell
.\scripts\validate-codex-assets.ps1
```

Recommended full workspace check:

```powershell
.\scripts\check-workspace.ps1
.\scripts\validate-codex-assets.ps1
.\scripts\test-hooks.ps1
.\scripts\test-workspace.ps1
```
