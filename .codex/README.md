# Codex Setup

This folder contains project-level Codex scaffolding for the `app-dev` control workspace.

- `config.toml` documents conservative project settings and where hook wiring belongs.
- `hooks/` contains standalone PowerShell scripts that can be wired into Codex hook support when the installed Codex version supports the desired schema.

Keep durable behavioral rules in the root `AGENTS.md`; keep repeatable task knowledge in `.agents/skills/`.

## Hook Enablement

Hook wiring is intentionally explicit. The scripts in `.codex/hooks/` are tested standalone, but they are not enforced unless they are connected through the current Codex hook schema for the installed version.

Use this supported pre-command invocation when enabling shell command checks:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .codex/hooks/pre-command.ps1
```

Keep the hook command scoped to the app project path, for example:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .codex/hooks/verify-before-finish.ps1 -ProjectPath projects/<app>
```
