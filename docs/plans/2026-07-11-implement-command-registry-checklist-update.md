# /implement Registry Checklist Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `/implement` so compact JSON standards registries are the normal operating surface, with an auditable Applicable Standards Checklist recorded in workflow receipts.

**Architecture:** Keep prose standards as policy references and make `standards/registry/*.rules.json` the implementation-time rule selection layer. `/implement` will derive touched surfaces, select matching registry rules, maintain a checklist in `workflow-receipts.md`, apply high-risk rules during execution, and reconcile standards, registries, validators, commands, templates, and receipt artifacts before handoff to `/verify`.

**Tech Stack:** Markdown command docs and templates, JSON rule registries, PowerShell validators and scaffolders, app-dev workflow receipts, workspace governance checks.

## Global Constraints

- Plan lives under `docs/plans/` per local user instruction, not under `docs/superpowers/plans/`.
- `/implement` consumes initialized `spec.md`, `plan.md`, `tasks.md`, `workflow-receipts.md`, and gated `checklist.md` when required; it must not create the active workflow artifact set.
- JSON registries under `standards/registry/*.rules.json` become the primary standards input for `/implement`.
- Prose standards are fallback/reference inputs only when a selected registry rule is unclear, a rule references a section needing interpretation, the implementation changes a standard or registry, or a registry is missing or malformed.
- The Applicable Standards Checklist must record rule id, standard reference, status, evidence, and blocker/defer reason for each applicable critical or high rule.
- Applicable requirements and checks must be dynamic: derive them from the active `spec.md`, `plan.md`, `tasks.md`, current changed files, and registry metadata rather than maintaining hardcoded rule-id lists in `/implement` prose.
- Concrete rule IDs should be generated from registry JSON at execution time and written to receipts as evidence; `/implement` should reference registry files and the generator contract, not quote fixed rule IDs except when documenting an observed generated result.
- Checklist statuses are limited to `applied`, `not-applicable`, `deferred`, and `blocked`.
- `/implement` must stop when a critical applicable rule is blocked and safe progress is impossible, when a touched governed surface has a missing or malformed registry, when a prose standard changes without matching registry reconciliation, or when an applicable `validator-required` rule lacks validation evidence or an explicit blocker.
- Do not adopt spec-kit extension hooks, spec-kit prerequisite scripts, generic ignore-file generation, `FEATURE_DIR/checklists/`, optional spec-kit docs as named assumptions, or a hard "all tasks completed" done rule.

## Affected Artifact Map

- Modify `.agents/commands/implement.md`
  - Own the registry-driven `/implement` flow, user-argument handling, checklist resolution phase, progress reporting, stop conditions, and final completion validation.
- Modify `templates/spec-workflow/workflow-receipts.template.md`
  - Own the reusable Applicable Standards Checklist evidence shape.
- Create `scripts/get-applicable-standard-rules.ps1`
  - Generate the applicable standards checklist from active spec artifacts, touched files, changed files, and `standards/registry/*.rules.json`.
- Modify `scripts/validate-workflow-receipts.ps1`
  - Validate the new receipt checklist shape and required critical/high statuses when present or required.
- Modify `scripts/validate-codex-assets.ps1`
  - Assert the `/implement` command includes registry-driven phases, receipt obligation wording, and stop conditions without adding brittle exact-sentence checks.
- Modify `scripts/check-spec-artifacts.ps1`
  - Validate receipt-template or active-receipt checklist anchors where the spec artifact contract requires them.
- Modify `scripts/create-app.ps1`
  - Ensure generated first-spec receipts include the new Applicable Standards Checklist section from the template.
- Modify `scripts/test-workflow-enforcement.ps1`
  - Cover command and receipt-validator expectations for registry checklist behavior.
- Modify `scripts/test-workspace.ps1`
  - Confirm generated canary apps include the new receipt checklist shape.
- Modify `standards/command-workflow-contract.md`
  - Align `/implement` responsibility with registry selection, checklist evidence, and receipt updates.
- Modify `standards/spec-driven-workflow.md`
  - Align Implement phase semantics with registry-first standards application and final implementation validation.
- Modify `standards/workspace.md`
  - Only if the implementation needs a clearer owner rule for prose-standard and registry drift.
- Modify `standards/registry/command-workflow-contract.rules.json`
  - Update the generated applicable command/receipt rules for registry-driven checklist behavior.
- Modify `standards/registry/spec-driven-workflow.rules.json`
  - Add or adjust SDW rules for Applicable Standards Checklist ownership and Implement phase rule resolution.
- Modify `standards/registry/workspace.rules.json`
  - Add or adjust WSP drift rules so standards and matching registries move together.
- Review all other `standards/registry/*.rules.json`
  - Confirm existing rule ids, `applies_to`, `trigger_kinds`, `phases`, and `enforcement_mode` are enough for `/implement` selection.
- Review `standards/registry/*.rules.json` schema consistency
  - Confirm all registries expose a usable `rules[]` array with `id`, `standard_reference`, `severity`, `applies_to`, `trigger_kinds`, `phases`, `enforcement_mode`, and `evidence_required`.
- Review `.agents/commands/plan.md`, `.agents/commands/tasks.md`, `.agents/commands/analyze.md`, and `.agents/commands/verify.md`
  - Update only if neighboring command handoff wording conflicts with the new `/implement` contract.
- Review `.agents/skills/*-workflow/SKILL.md`
  - Update only if local wrapper evidence wording must mention the standards checklist.

## Task 1: Confirm The Live Contract And Baseline Drift

**Files:**
- Modify: `docs/plans/2026-07-11-implement-command-registry-checklist-update.md`
- Review: `.agents/commands/implement.md`
- Review: `templates/spec-workflow/workflow-receipts.template.md`
- Review: `standards/registry/*.rules.json`
- Review: `scripts/validate-codex-assets.ps1`
- Review: `scripts/validate-workflow-receipts.ps1`
- Review: existing registry-selector or workflow-obligation script patterns, especially `scripts/get-workflow-obligations.ps1`

**Interfaces:**
- Consumes: current command flow, current receipt shape, registry rule schema, current validator assertions.
- Produces: a baseline note identifying which current surfaces already support registry-driven work and which need edits.

- [ ] **Step 1: Capture current `/implement` command phases and validator needles**

Run:

```powershell
rg -n "Resolve Applicable|Apply Implementation Quality Rules|workflow-receipts.md|focused checks|Stop Conditions|Completion Report" .agents/commands/implement.md scripts/validate-codex-assets.ps1
```

Expected:
- `.agents/commands/implement.md` still uses the older `Apply Implementation Quality Rules` phase.
- `scripts/validate-codex-assets.ps1` has `/implement` needles that must move to registry-aware wording.

- [ ] **Step 2: Capture current receipt evidence anchors**

Run:

```powershell
rg -n "Implementation evidence|Verification commands|Final Verification Evidence|Applicable Standards" templates/spec-workflow/workflow-receipts.template.md scripts/validate-workflow-receipts.ps1 scripts/check-spec-artifacts.ps1
```

Expected:
- receipt evidence fields exist
- no current Applicable Standards Checklist anchor exists unless a prior edit already added it

- [ ] **Step 3: Confirm the registry files parse as JSON**

Run:

```powershell
Get-ChildItem standards/registry/*.rules.json | ForEach-Object {
  Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json | Out-Null
}
```

Expected: no JSON parse errors.

- [ ] **Step 4: Confirm registry files expose operational rule metadata**

Run:

```powershell
Get-ChildItem standards/registry/*.rules.json | ForEach-Object {
  $json = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json
  if (-not $json.rules) { throw "$($_.Name) has no rules array" }
  foreach ($rule in $json.rules) {
    foreach ($field in @("id", "standard_reference", "severity", "applies_to", "trigger_kinds", "phases", "enforcement_mode", "evidence_required")) {
      if (-not $rule.PSObject.Properties.Name.Contains($field)) { throw "$($_.Name) $($rule.id) missing $field" }
    }
  }
}
```

Expected: either all registries pass, or the failing registry and field become explicit Task 5 work.

- [ ] **Step 5: Confirm there is no existing applicable-rule generator**

Run:

```powershell
rg -n "applicable.*standard|standard.*checklist|rules.json|trigger_kinds|applies_to" scripts .agents standards
```

Expected:
- if no generator exists, Task 5 creates `scripts/get-applicable-standard-rules.ps1`
- if a suitable generator exists, Task 5 extends it instead of creating a duplicate

- [ ] **Step 6: Record baseline dirty-worktree boundaries**

Run:

```powershell
git status --short
```

Expected:
- existing unrelated dirty files are noted and left untouched unless required by this plan
- final summary separates plan-created changes from pre-existing worktree state

## Task 2: Redesign `/implement` Around Registry Rule Resolution

**Files:**
- Modify: `.agents/commands/implement.md`
- Review: `.agents/commands/plan.md`
- Review: `.agents/commands/tasks.md`
- Review: `.agents/commands/analyze.md`
- Review: `.agents/commands/verify.md`

**Interfaces:**
- Consumes: active artifact reads, registry metadata fields, local command phase contract.
- Produces: revised `/implement` phases and command obligations.

- [ ] **Step 1: Add user input handling**

Update `.agents/commands/implement.md` with a short `## User Input` section after `## Purpose`:

```markdown
## User Input

Treat non-empty user arguments as execution constraints for this run.

User arguments can narrow order, scope, or reporting detail, but they cannot override the active spec, safety gates, initialized artifact requirements, applicable registry rules, required receipt updates, or approval requirements.
```

Expected:
- user arguments become part of the command contract
- no wording allows bypassing active spec, registry, or receipt obligations

- [ ] **Step 2: Replace broad standards-reading language with registry-first reads**

Revise `## Required Reads` so it includes:

```markdown
- Relevant `../../standards/registry/*.rules.json` files selected by touched surfaces, `tasks.md`, planned files, changed files, workflow classification, and active phase.
- Prose standards only when a selected registry rule is unclear, a rule references a section that needs interpretation, the implementation changes the standard or registry itself, or a registry is missing or malformed.
```

Expected:
- registry files are the normal standards input
- prose standards remain authoritative policy references without being the default operating surface

- [ ] **Step 3: Insert a new Phase 3**

Add this phase between preparation and execution:

```markdown
### Phase 3: Resolve Applicable Standard Rules

1. Derive touched surfaces from `tasks.md`, planned files in `plan.md`, active workflow classification, existing changed files, and files changed during implementation.
2. Read the relevant `../../standards/registry/*.rules.json` files before reading long prose standards.
3. Match candidate rules by `applies_to`, `trigger_kinds`, and `phases`.
4. Build an Applicable Standards Checklist in `workflow-receipts.md`.
5. Include rule id, standard reference, severity, enforcement mode, selected status, evidence, and reason or next action.
6. Mark each applicable rule as `applied`, `not-applicable`, `deferred`, or `blocked`.
7. Require every critical or high applicable rule to have a status before execution continues beyond the task that triggered it.
```

Expected:
- current execution phase numbers are shifted
- all later references use the new phase numbers

- [ ] **Step 4: Rename and rewrite the old quality phase**

Rename:

```markdown
### Phase 5: Apply Implementation Quality Rules
```

to:

```markdown
### Phase 6: Apply Applicable Standards Checklist
```

Replace prose-category-only guidance with registry-id guidance:

```markdown
#### Registry-Selected Rules
- Use the generated Applicable Standards Checklist as the source of required implementation checks.
- Generate the checklist from `../../standards/registry/*.rules.json` using the active `spec.md`, `plan.md`, `tasks.md`, changed files, and current implementation phase.
- Do not maintain fixed rule-id lists in this command. Concrete rule ids belong in generated receipt evidence.
- Record every generated critical or high applicable rule as `applied`, `not-applicable`, `deferred`, or `blocked`.
- For `deferred` or `blocked`, record the reason and the next command, task, validation, or user approval needed.
```

Expected:
- `/implement` avoids hardcoded rule-number drift
- concrete rule ids appear only as generated checklist output in `workflow-receipts.md`

Expected:
- `/implement` references registry ids by family
- prose categories remain explanatory only

- [ ] **Step 5: Add progress reporting after each task**

Add an execution requirement under the work/evidence phases:

```markdown
After each completed, deferred, or blocked `T###`, report:
- task id and status
- files or surfaces touched
- selected registry rule ids updated
- checks run and result
- receipt sections updated
- next task or blocker
```

Expected:
- progress reporting is explicit and tied to task ids and receipt evidence

- [ ] **Step 6: Add checklist summary for active `checklist.md`**

Add a gated-checklist reporting rule:

```markdown
When active `checklist.md` exists, summarize total items, completed items, incomplete items, blocking status, and whether explicit approval is required before material implementation continues.
```

Expected:
- local `checklist.md` is summarized
- no `FEATURE_DIR/checklists/` scan is introduced

- [ ] **Step 7: Add implementation-context extraction fields**

Extend Phase 1 extraction to include:

```markdown
- tech stack
- architecture decisions
- file structure
- test requirements
- workflow classifications
- registry rules
- focused checks
```

Expected:
- context extraction is concrete enough for later rule resolution

- [ ] **Step 8: Add final completion validation**

Rename or extend the final review phase so it explicitly validates implementation against:

```markdown
- active `spec.md`
- active `plan.md`
- selected registry rules
- focused checks and tests
- current `workflow-receipts.md`
- active `checklist.md` when present
```

Expected:
- completion validation is specific and evidence-backed
- `/verify` remains the final closure command

## Task 3: Add The Applicable Standards Checklist Receipt Shape

**Files:**
- Modify: `templates/spec-workflow/workflow-receipts.template.md`
- Review: existing `projects/*/specs/*/workflow-receipts.md` compatibility expectations

**Interfaces:**
- Consumes: selected registry rules from `/implement`.
- Produces: stable receipt evidence area used by `/implement` and validated later.

- [ ] **Step 1: Add a new receipt section after Workflow Classification**

Insert:

```markdown
## Applicable Standards Checklist

- Status: not-started
- Selection basis: none
- Registry files reviewed: none
- Prose standards consulted: none
- Critical/high rule summary: none

| Rule | Reference | Severity | Status | Evidence | Reason or next action |
| --- | --- | --- | --- | --- | --- |
| none | none | none | not-applicable | none | no applicable rules selected yet |
```

Expected:
- generated receipts have a stable checklist area
- the initial row is valid for draft generated specs

- [ ] **Step 2: Document valid statuses in the template**

Add one short line under the table:

```markdown
Allowed statuses: `applied`, `not-applicable`, `deferred`, `blocked`.
```

Expected:
- agents and validators share the same status vocabulary

- [ ] **Step 3: Add a generated-output example to `/implement`, not a maintained rule list**

In `.agents/commands/implement.md`, include only a shape example under `## Receipt Updates`:

```markdown
Applicable standards checklist:
- [x] `<generated-rule-id> / <registry-reference>` - `<registry title>` - applied: `<evidence>`
- [ ] `<generated-rule-id> / <registry-reference>` - `<registry title>` - not-applicable: `<reason>`
- [ ] `<generated-rule-id> / <registry-reference>` - `<registry title>` - deferred: `<next action>`
```

Expected:
- examples guide humans without baking fixed rule numbers into the command

## Task 4: Tighten Stop Conditions And Failure Handling

**Files:**
- Modify: `.agents/commands/implement.md`
- Modify: `standards/command-workflow-contract.md`
- Modify: `standards/spec-driven-workflow.md`
- Modify: `standards/registry/command-workflow-contract.rules.json`
- Modify: `standards/registry/spec-driven-workflow.rules.json`

**Interfaces:**
- Consumes: registry statuses and validator-required rules.
- Produces: stop behavior that prevents unsafe or unaudited implementation.

- [ ] **Step 1: Add registry-specific stop conditions**

Add these stop conditions to `.agents/commands/implement.md`:

```markdown
- Any applicable `critical` rule is `blocked` and the task cannot proceed safely.
- A registry file is missing or malformed for a touched governed surface.
- Implementation changes a prose standard but does not update or explicitly reconcile the matching registry.
- Implementation changes a registry but does not reconcile the matching prose standard when the normative requirement changes.
- A registry rule marked `validator-required` is applicable but no validation result or explicit blocker is recorded.
```

Expected:
- stop conditions match the recommendation exactly in local terms

- [ ] **Step 2: Align standards with the stop behavior**

Update standards so:

```markdown
standards/command-workflow-contract.md
- `/implement` resolves applicable registry rules, records the Applicable Standards Checklist, and stops on blocked critical rules or missing validator evidence.

standards/spec-driven-workflow.md
- Implement phase uses registry-first standards application and keeps workflow-receipts.md current as the evidence ledger.
```

Expected:
- standards define phase semantics
- `.agents/commands/implement.md` owns exact execution steps

- [ ] **Step 3: Reconcile command and workflow registries**

Update registry rules so critical/high command and workflow behavior is selectable:

Use `scripts/get-applicable-standard-rules.ps1` or the selected registry metadata to identify which command-workflow and spec-workflow rules govern this change, then update those registry entries so they mention registry-first rule resolution, applicable checklist evidence, and implementation receipt evidence.

Expected:
- command and workflow registries are not stale after prose changes

## Task 5: Add Dynamic Rule Generation And Validator Support

**Files:**
- Modify: `scripts/validate-workflow-receipts.ps1`
- Create: `scripts/get-applicable-standard-rules.ps1`
- Modify: `scripts/validate-codex-assets.ps1`
- Modify: `scripts/check-spec-artifacts.ps1`
- Modify: `scripts/test-workflow-enforcement.ps1`
- Modify: `scripts/test-workspace.ps1`

**Interfaces:**
- Consumes: active spec artifacts, touched files, changed files, receipt checklist shape, status vocabulary, registry metadata.
- Produces: generated applicable standards checklist output and mechanical drift detection for command, receipt, and registry behavior.

- [ ] **Step 1: Create the applicable-rule generator**

Create `scripts/get-applicable-standard-rules.ps1` unless Task 1 found an existing reusable generator. The script must accept:

```powershell
param(
  [Parameter(Mandatory=$true)][string]$ProjectPath,
  [Parameter(Mandatory=$true)][string]$SpecDir,
  [string[]]$ChangedFiles = @(),
  [string]$Phase = "implement",
  [switch]$Markdown
)
```

Generator behavior:
- read `specs/<SpecDir>/spec.md`, `plan.md`, `tasks.md`, `workflow-receipts.md`, and `checklist.md` when present
- infer touched surfaces from artifact text and `ChangedFiles`
- load every valid `../../standards/registry/*.rules.json`
- select rules by `applies_to`, `trigger_kinds`, and `phases`
- emit deterministic JSON by default
- emit the receipt table body when `-Markdown` is passed
- sort output by severity and rule id

Expected:
- `/implement` can generate concrete rule ids instead of maintaining them in prose
- future registry changes flow into requirements/checks without command-doc edits

- [ ] **Step 2: Validate receipt checklist anchors**

In `scripts/validate-workflow-receipts.ps1`, require these anchors when validating current-template receipts or when the section exists:

```text
## Applicable Standards Checklist
Status:
Selection basis:
Registry files reviewed:
Prose standards consulted:
Critical/high rule summary:
| Rule | Reference | Severity | Status | Evidence | Reason or next action |
Allowed statuses:
```

Expected:
- old compatibility receipts are not retroactively failed unless the script already applies current-template strictness
- current-template receipts must include the new section

- [ ] **Step 3: Validate status vocabulary**

Add a parser check that any checklist table status is one of:

```text
applied
not-applicable
deferred
blocked
```

Expected:
- malformed status text fails validation with the offending rule id

- [ ] **Step 4: Validate critical/high rows are complete**

When an Applicable Standards Checklist row has severity `critical` or `high`, require non-empty values for:

```text
Rule
Reference
Status
Evidence
Reason or next action
```

Expected:
- critical/high applicable rules cannot be left as empty evidence rows

- [ ] **Step 5: Validate registry JSON schema in governance checks**

In `scripts/validate-codex-assets.ps1`, add a registry validation helper that confirms every `standards/registry/*.rules.json` parses and each rule has:

```text
id
standard_reference
severity
applies_to
trigger_kinds
phases
enforcement_mode
evidence_required
```

Expected:
- malformed registries are caught before `/implement` relies on them
- the validator reports all registry failures together

- [ ] **Step 6: Update command validator needles**

Replace old `/implement` needles with contract-based terms such as:

```text
Apply Applicable Standards Checklist
Applicable Standards Checklist
standards/registry/*.rules.json
get-applicable-standard-rules.ps1
validator-required
critical
blocked
Progress reporting
```

Expected:
- validator enforces the new command contract
- avoid adding exact full-sentence assertions

- [ ] **Step 7: Update workflow tests**

Update `scripts/test-workflow-enforcement.ps1` and `scripts/test-workspace.ps1` to cover:

```text
generated receipts include Applicable Standards Checklist
applicable standards checklist can be generated from active spec artifacts and ChangedFiles
receipt validation accepts the initial not-started checklist row
receipt validation rejects an invalid checklist status
receipt validation rejects an incomplete critical/high row
registry validation rejects a malformed registry fixture if the existing test harness supports fixtures
```

Expected:
- tests fail before implementation and pass after validator support lands

## Task 6: Reconcile Scaffold, Templates, Neighbor Commands, And Wrapper Skills

**Files:**
- Modify: `scripts/create-app.ps1`
- Review or modify: `.agents/commands/plan.md`
- Review or modify: `.agents/commands/tasks.md`
- Review or modify: `.agents/commands/analyze.md`
- Review or modify: `.agents/commands/verify.md`
- Review or modify: `.agents/skills/cross-platform-app-workflow/SKILL.md`
- Review or modify: `.agents/skills/ui-change-workflow/SKILL.md`
- Review or modify: `.agents/skills/data-change-workflow/SKILL.md`
- Review or modify: `.agents/skills/mobile-validation-workflow/SKILL.md`
- Review or modify: `.agents/skills/release-readiness-workflow/SKILL.md`

**Interfaces:**
- Consumes: new receipt template and `/implement` command behavior.
- Produces: generated and adjacent workflow surfaces that do not drift.

- [ ] **Step 1: Confirm scaffold generation copies the updated receipt template**

Run:

```powershell
rg -n "workflow-receipts.template.md|Workflow Receipts|Applicable Standards" scripts/create-app.ps1 templates/spec-workflow/workflow-receipts.template.md
```

Expected:
- `create-app.ps1` either copies the template directly or substitutes from the updated template
- generated first-spec receipts include the new checklist section

- [ ] **Step 2: Update neighboring commands only for handoff drift**

Search:

```powershell
rg -n "Apply Implementation Quality Rules|Applicable Standards|standards/registry|workflow-receipts.md|/implement|/verify" .agents/commands
```

Patch only lines that conflict with the new owner split:
- `/plan` may mention implementation context fields but does not write receipts.
- `/tasks` initializes `workflow-receipts.md` with the checklist section.
- `/analyze` resolves contradictions before implementation.
- `/verify` validates final evidence and does not redo rule selection unless drift is discovered.

Expected:
- command docs agree without copying the whole `/implement` procedure

- [ ] **Step 3: Update wrapper skills only where evidence wording changed**

Search:

```powershell
rg -n "workflow-receipts.md|Implementation evidence|/implement|standards" .agents/skills
```

Patch only wrapper skill lines that now need to mention:
- applicable standards checklist updates
- registry rule ids in implementation evidence
- wrapper-specific rules feeding the receipt checklist

Expected:
- local skills point to the receipt checklist without becoming alternate command owners

## Task 7: Reconcile All Prose Standards And Matching Registries

**Files:**
- Modify: `standards/command-workflow-contract.md`
- Modify: `standards/spec-driven-workflow.md`
- Modify if needed: `standards/workspace.md`
- Modify: `standards/registry/command-workflow-contract.rules.json`
- Modify: `standards/registry/spec-driven-workflow.rules.json`
- Modify if needed: `standards/registry/workspace.rules.json`
- Review: `standards/registry/{adaptive-layouts,codex-capabilities,constitution,module-contract,scripting,security,stack,testing}.rules.json`

**Interfaces:**
- Consumes: exact prose standard changes from Tasks 4-6.
- Produces: no drift between human policy and operational registry rules.

- [ ] **Step 1: Build a standards-to-registry reconciliation table**

Record in this plan before implementation closeout:

```markdown
| Prose standard | Matching registry | Changed? | Reconciled? | Notes |
| --- | --- | --- | --- | --- |
| `standards/command-workflow-contract.md` | `standards/registry/command-workflow-contract.rules.json` | yes | yes | `/implement` registry checklist behavior |
| `standards/spec-driven-workflow.md` | `standards/registry/spec-driven-workflow.rules.json` | yes | yes | Implement phase semantics |
| `standards/workspace.md` | `standards/registry/workspace.rules.json` | conditional | conditional | standards/registry drift owner if edited |
```

Expected:
- every prose edit has a matching registry decision

- [ ] **Step 2: Validate all registries after edits**

Run:

```powershell
Get-ChildItem standards/registry/*.rules.json | ForEach-Object {
  Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json | Out-Null
}
```

Expected: all registry files parse.

- [ ] **Step 3: Search for stale prose-first wording**

Run:

```powershell
rg -n "read/apply standards|Apply Implementation Quality Rules|standards become|prose standards|registry-driven|Applicable Standards Checklist" .agents standards scripts templates docs/plans
```

Expected:
- active command and standards surfaces use registry-first wording
- historical plans remain unchanged unless they are active owners

## Task 8: Run Verification And Record Checklist Evidence

**Files:**
- Modify: `docs/plans/2026-07-11-implement-command-registry-checklist-update.md`
- Review: all touched files from Tasks 2-7

**Interfaces:**
- Consumes: changed command docs, receipt template, validators, standards, registries, scaffolders, tests.
- Produces: final implementation evidence, drift notes, and handoff.

- [ ] **Step 1: Run focused validator and workflow tests**

Run:

```powershell
./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true
./scripts/test-workflow-enforcement.ps1
./scripts/test-workspace.ps1
```

Expected: all pass.

- [ ] **Step 2: Run receipt validator tests if added separately**

If new receipt-validator unit coverage is added, run the narrow test command used by the repo, for example:

```powershell
./scripts/validate-workflow-receipts.ps1 -ProjectPath projects/signal -SpecDir specs/007-code-script-closeout
```

Expected:
- active receipts with the new checklist shape pass
- compatibility receipts are not retroactively failed unless explicitly migrated

- [ ] **Step 3: Run the full governance gate**

Run:

```powershell
./scripts/check-all.ps1
```

Expected: full governance suite passes.

- [ ] **Step 4: Run a drift sweep**

Run:

```powershell
rg -n "Apply Implementation Quality Rules|Resolve Applicable Standard Rules|Apply Applicable Standards Checklist|Applicable Standards Checklist|standards/registry|validator-required|workflow-receipts.md" .agents standards scripts templates projects docs
```

Expected:
- no stale active-owner wording remains
- historical docs are identified as historical and left unchanged

- [ ] **Step 5: Update this plan with closeout evidence**

Append a `## Closeout Evidence` section containing:

```markdown
## Closeout Evidence

- Implementation status:
- Registry files reviewed:
- Applicable command/governance rules selected:
- Receipt checklist shape:
- Validators updated:
- Checks run:
- Drift sweep result:
- Compatibility notes:
- Remaining blockers:
```

Expected:
- the plan itself records the reporting/checklist outcome requested for this governance slice

## Applicable Standards Selection For This Plan

This plan intentionally does not maintain a static rule-id checklist. During implementation, generate the Applicable Standards Checklist from `standards/registry/*.rules.json` using:

- active phase: `implement`
- changed surfaces: `.agents/commands/`, `templates/spec-workflow/`, `scripts/`, `standards/`, `standards/registry/`
- trigger kinds: command change, receipt change, validator change, standard change, registry change, workflow change, governance change

Expected generated rule families include command workflow, spec workflow, workspace governance, scripting portability, security governance, and testing/verification rules. The concrete rule IDs and standard references must come from the generator output and be written to `workflow-receipts.md` or the closeout evidence, not maintained manually in this plan or `/implement`.

## Reporting Checklist

- [x] Active command flow updated with registry-first standards input.
- [x] Applicable Standards Checklist added to `workflow-receipts.template.md`.
- [x] `/implement` requires progress reporting after each completed, deferred, or blocked `T###`.
- [x] `/implement` summarizes active `checklist.md` when present.
- [x] `/implement` validates completion against spec, plan, selected registry rules, focused checks, and receipts.
- [x] Prose standards and matching registries reconciled in the same implementation slice.
- [x] Validators and scaffold tests updated so generated receipts do not drift.
- [x] Final closeout evidence appended to this plan after verification.

## Spec Coverage Check

- Registry files as primary standards input: covered by Tasks 2, 5, and 7.
- New `Resolve Applicable Standard Rules` phase: covered by Task 2.
- Rename quality phase to `Apply Applicable Standards Checklist`: covered by Task 2.
- Receipt obligation with auditable checklist rows: covered by Task 3.
- Stop conditions for critical blockers, malformed registries, standard/registry drift, and validator-required rules: covered by Task 4.
- User input handling: covered by Task 2.
- Local checklist status reporting: covered by Task 2.
- Implementation-context extraction: covered by Task 2.
- Progress reporting after each `T###`: covered by Task 2.
- Final completion validation wording: covered by Task 2.
- Affected artifact drift prevention: covered by Tasks 5, 6, 7, and 8.

## Execution Handoff

Plan complete and saved to `docs/plans/2026-07-11-implement-command-registry-checklist-update.md`. Two execution options:

**1. Subagent-Driven (recommended)** - Dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints.

Preferred execution path for this governance slice: Subagent-Driven for Tasks 2-7 with a main-agent review after each task, then inline verification for Task 8.

## Closeout Evidence

- Implementation status: complete
- Registry files reviewed: `standards/registry/command-workflow-contract.rules.json`, `standards/registry/spec-driven-workflow.rules.json`, `standards/registry/workspace.rules.json`, `standards/registry/security.rules.json`, plus schema validation across `standards/registry/*.rules.json`
- Applicable command/governance rules selected: registry-first `/implement` command workflow, spec-workflow receipt ownership, workspace prose/registry reconciliation, and registry-schema enforcement for validators
- Receipt checklist shape: `templates/spec-workflow/workflow-receipts.template.md` now seeds `## Applicable Standards Checklist` with status metadata, reviewed-registry fields, and a governed table/status vocabulary
- Validators updated: `scripts/validate-workflow-receipts.ps1`, `scripts/validate-codex-assets.ps1`, and `scripts/check-spec-artifacts.ps1`
- Scaffold and workflow tests updated: `scripts/test-workflow-enforcement.ps1`, `scripts/test-workspace.ps1`, and generated-app receipt assertions
- Checks run:
  - `./scripts/validate-codex-assets.ps1 -RequirePythonToml:$true`
  - `./scripts/test-workflow-enforcement.ps1`
  - `./scripts/test-workspace.ps1`
  - `./scripts/check-all.ps1`
- Drift sweep result: active owner surfaces now reference `Resolve Applicable Standard Rules`, `Apply Applicable Standards Checklist`, registry-first selection, and validator-required stop handling; remaining hits are historical plans or existing app receipts outside this slice
- Compatibility notes: receipt validation remains compatible with legacy workflow sections that still use `Verification performed:` while current-template scaffolds require the new checklist anchors
- Remaining blockers: none
