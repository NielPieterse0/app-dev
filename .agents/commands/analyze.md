# `/analyze`

Run cross-artifact consistency analysis on the active spec before verification or closure claims.

Working directory: `projects/<app>/`.

## Required workflow

1. Confirm the active spec pointer in `AGENTS.md` and `PLAN.md` agree.
2. Run `../../scripts/analyze-spec.ps1 -ProjectPath .`
3. Resolve every reported contradiction before proceeding: status mismatches between spec and plan, completed receipts with pending verification, completed removal tasks whose targets still exist, unresolved NEEDS CLARIFICATION markers in completed artifacts, and no-auth wording without its guardrail.
4. Record the analysis outcome in the active spec's `workflow-receipts.md` when it changes a decision or surfaces a gap.

Do not claim completion from this command. Use `/verify` or `/release-readiness` for closure.
