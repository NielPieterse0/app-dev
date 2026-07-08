# Codex Agent Assets

Repo-specific Codex skills live under `.agents/skills/`.
Repo-specific workflow entry commands live under `.agents/commands/`.

## Required Local Skills

- `cross-platform-app-workflow` - primary app-dev workflow for planning, scaffolding, module structure, adaptive layout, and verification.
- `ui-change-workflow` - required when work changes user-facing UI surfaces.
- `data-change-workflow` - required when work changes schema, SQL, RLS, Supabase, or data-access surfaces.
- `mobile-validation-workflow` - required when work changes Capacitor, Expo, Android, iOS, or native runtime surfaces.
- `release-readiness-workflow` - required for completion claims and risky release-adjacent work.

## Optional External Capabilities

Do not assume global skills or plugins are available. If a task would benefit from an external capability, first use `standards/codex-capabilities.md` to decide whether it is relevant. If the capability is unavailable, continue with local standards and report the limitation.

This keeps reusable workflows discoverable without putting long instructions directly in `AGENTS.md`.

## Local Command Templates

The local command templates mirror the same spec-driven workflow contract:

- `/specify`
- `/plan`
- `/tasks`
- `/implement`
- `/verify`
- `/release-readiness`

Commands are workflow gates, not bypasses around the local skills.
