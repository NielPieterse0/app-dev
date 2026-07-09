# `/specify`

Use this command only inside a generated app project.

Working directory: `projects/<app>/`.

## Required workflow

1. Confirm or create the active numbered spec under `specs/NNN-<slug>/`.
2. Update `spec.md`.
3. Update `tasks.md`.
4. Initialize `workflow-receipts.md`.
5. If the work is sensitive, use the gated clarify branch now: resolve open questions, populate `checklist.md`, and record the decisions before implementation starts.

Do not proceed with implementation from this command. This command prepares the spec surface only.
