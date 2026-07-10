# {{SPEC_NUMBER}} {{SPEC_TITLE}} Task Breakdown

- Status: draft
- Spec: `specs/{{SPEC_DIR}}/spec.md`
- Plan: `PLAN.md`
- Receipts: `specs/{{SPEC_DIR}}/workflow-receipts.md`

## Task Format

Use strict checklist rows:

```text
- [ ] T001 [P] [US1] Action with exact repo-relative path
```

- `T###` IDs are required and sequential.
- `[P]` means the task touches independent files or independent surfaces and can run without unfinished dependencies.
- `[US#]` labels are used only for user-story or vertical-increment work.
- Every material implementation task names an exact repo-relative path.

## Task List

### Phase 1: Setup

- [ ] T001 Confirm app `AGENTS.md`, `PLAN.md`, and `specs/{{SPEC_DIR}}/spec.md` point to the same active spec.
- [ ] T002 Confirm workflow classification in `specs/{{SPEC_DIR}}/workflow-receipts.md`.
- [ ] T003 Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .` before implementation planning closes.

### Phase 2: Foundation

- [ ] T004 Update `PLAN.md` from `templates/spec-workflow/PLAN.template.md` so architecture, module, data, permission, platform, workflow, and verification decisions match this spec.
- [ ] T005 Update `specs/{{SPEC_DIR}}/workflow-receipts.md` with `/plan` and `/tasks` command evidence, reviewed files, outstanding gaps, and required local workflows.
- [ ] T006 Add or update shared foundations named by the plan before user-story work begins.

### Phase 3: User Story 1 - TODO: short title (Priority: P1)

**Goal**: TODO: summarize independently valuable outcome.

**Independent Test**: TODO: describe focused verification for this story.

- [ ] T007 [US1] Implement TODO: action in TODO: exact repo-relative path.
- [ ] T008 [US1] Add or update tests for TODO: behavior in TODO: exact repo-relative path.
- [ ] T009 [US1] Update `specs/{{SPEC_DIR}}/workflow-receipts.md` with implementation evidence for this story.

### Phase 4: Additional User Stories Or Vertical Increments

- Repeat the user story phase for each additional independently testable slice.
- Continue the `T###` sequence without renumbering earlier tasks.
- Continue the `[US#]` sequence with `[US2]`, `[US3]`, and so on.
- Each repeated phase includes a goal, an independent test, implementation tasks, test tasks, and a receipt update task.

### Phase 5: Polish And Verification

- [ ] T010 Reconcile `specs/{{SPEC_DIR}}/spec.md`, `PLAN.md`, `specs/{{SPEC_DIR}}/tasks.md`, and `specs/{{SPEC_DIR}}/workflow-receipts.md` to the implemented state.
- [ ] T011 Run `../../scripts/analyze-spec.ps1 -ProjectPath .`.
- [ ] T012 Run `../../scripts/check-spec-artifacts.ps1 -ProjectPath .`.
- [ ] T013 Run `../../scripts/validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`.
- [ ] T014 Run `../../scripts/verify-app.ps1 -ProjectPath .`.
- [ ] T015 Record rendered desktop and mobile verification in `specs/{{SPEC_DIR}}/workflow-receipts.md` when UI work is in scope.

## Dependencies And Order

- Setup tasks block foundation tasks.
- Foundation tasks block user-story or vertical-increment tasks.
- User stories should be implemented in priority order unless `[P]` tasks are explicitly independent.
- Verification tasks run after implementation evidence and task status are current.

## Parallel Opportunities

- Mark `[P]` only after confirming tasks touch different files or independent surfaces.
- Do not mark receipt, plan, spec, or shared foundation updates as parallel when later tasks depend on them.

## Notes

- Replace all TODO markers before `/implement`.
- Keep this file aligned to `workflow-receipts.md`, including whether UI, data, mobile, or release-readiness workflows are required for this spec.
