# `/release-readiness`

Use this command when:

- the user asks to finish, complete, stage, commit, push, or prepare a PR
- the task touches auth, payments, public APIs, deploy, secrets, live migrations, or production-readiness surfaces
- the handoff claims a feature is complete or ready

Working directory: `projects/<app>/`.

Load the release-readiness-workflow skill `../../../../.agents/skills/release-readiness-workflow/SKILL.md`

## Required workflow

1. Confirm the `Release Readiness Workflow Receipt` is complete.
2. Confirm `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence` passes.
3. Confirm `../../scripts/verify-app.ps1 -ProjectPath .` passes or exact blockers are recorded.
4. Confirm `checklist.md` is complete when the spec is sensitive.
5. Report unresolved gaps explicitly instead of implying readiness.
