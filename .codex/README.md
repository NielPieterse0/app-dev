# Codex Setup

This folder contains active project-level Codex configuration for the `app-dev` control workspace.

## Active Assets

- `config.toml` wires lifecycle hooks, selects the `app-dev-workspace` permission profile, and keeps project-level policy in the repo.
- `rules/default.rules` defines command approval/deny policy for commands Codex requests outside the sandbox.
- `hooks/pre-command.ps1` blocks destructive shell and edit operations through `PreToolUse` and `PermissionRequest`.
- `hooks/post-edit.ps1` adds verification reminders after edits and verification commands.

Keep durable behavioral rules in the root `AGENTS.md`; keep repeatable task workflows in `.agents/skills/`.

## Trust Requirement

Project-local `.codex/` configuration loads only after this repository is trusted in Codex. After changing hook definitions, restart Codex and review/trust the changed hooks through `/hooks` before relying on them.

## Hook Representation

This project uses inline hook tables in `.codex/config.toml`. Do not add `.codex/hooks.json` unless the inline hook tables are removed first. Codex merges both forms in the same layer and may warn at startup.

## Permission Model

Project-level `default_permissions` are selected in `.codex/config.toml`.

Default behavior:

- Hooks and rules remain active from project config.
- The documented `app-dev-workspace` profile is the intended least-privilege default for this repository.
- Effective file/network permissions still depend on the active Codex runner and trusted workspace session.

For deliberate governance edits under `.codex/`, use an approval flow or a session profile that permits those edits, then return to the normal profile.

## MCP Policy

No project-level MCP server is configured by default. Keep personal documentation, browser, GitHub, Supabase, Figma, or hosting MCP servers in user-level Codex configuration unless a generated app needs repo-specific tooling that can be documented without secrets. If a project-level MCP server is added later, use environment variable forwarding for secrets and document the safety boundary in this file.

## Validation

Run this after changes to Codex configuration, hooks, skills, or workspace structure:

```powershell
./scripts/validate-codex-assets.ps1
```

Recommended full workspace check:

```powershell
./scripts/check-all.ps1
```
