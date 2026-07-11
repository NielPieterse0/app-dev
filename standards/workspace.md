# Workspace Standard

- Document: standards/workspace.md
- Version: 2.0.0
- Date: 2026-07-09
- Status: Adopted and implemented.
- Owner: app-dev
- Related: standards/spec-driven-workflow.md, standards/scripting.md, standards/constitution.md, standards/codex-capabilities.md

`app-dev` is a single control workspace: governance, standards, templates, scripts, and all application projects live in one repository with one git history, one `.codex/` governance layer, one branch-protection policy, and one CI pipeline.

## 1. Repository Model

- `app-dev` is the only repository. `projects/<app>/` directories are tracked directly in it and are never initialized as nested or standalone git repositories.
- Each app keeps its own `AGENTS.md`, `specs/`, and `package.json` scoped to its directory. Each implementation spec owns its own `plan.md` inside `specs/NNN-<slug>/`. Gated checklists live inside the active spec folder (`specs/NNN-<slug>/checklist.md`), not at the app root.
- Each app's `.gitignore` excludes its own `node_modules/`, build output, and test artifacts.
- Shared code across apps, when it ever exists, goes under `packages/` in this same repo. Promote to a pnpm/Turborepo workspace only after at least two apps share real code such as `ui`, `auth`, `api-client`, or `config`.
- Exception path: an app may split into its own repository only for a hard external requirement - a different legal entity, a different access-control boundary, or a release process that genuinely cannot share this repo's branch protection. Any such split must update this document and the active spec's `plan.md` in the same change, so the exception is traceable rather than silent.

## 2. Authoritative Layout

```text
app-dev/
  AGENTS.md                 # durable workspace rules (pointers, not procedures)
  README.md                 # orientation and first commands (cross-platform forms)
  .codex/                   # Codex runtime governance: config.toml, rules/, hooks/
  .agents/
    commands/               # executable workflow entry points (the workflow's "how")
    skills/                 # one required local skill plus thin wrapper workflows
  .github/workflows/        # the ONLY location where CI workflows execute
  docs/
    audit/                  # immutable audit records and closeout ledgers
  standards/                # canonical human-readable standards (single truth)
  templates/
    spec-workflow/          # plan/spec/tasks/checklist/receipts/converge templates
    common/ci/              # non-executable CI reference snippets
    react-vite-capacitor/
    next-web-app/
    expo-native-app/
  scripts/                  # workspace validation, generation, enforcement
  projects/
    <app>/
      AGENTS.md
      specs/NNN-<slug>/     # spec.md, plan.md, tasks.md, workflow-receipts.md, checklist.md
      src/  supabase/  scripts/  package.json
```

Anything present in the repo but absent from this tree is either app-internal or a drift candidate; anything in this tree but absent from the repo is a defect. The workspace manifest (4.2) is the machine-readable form of this section.

## 3. Fact Ownership Map (Anti-Drift)

Every governed fact has exactly one owning file. Other files may point to the owner; they may not restate its content. Validators enforce the pointer, not a copy.

| Fact | Owner | Pointers allowed in |
|---|---|---|
| Workflow phases, Lean/Gated paths, convergence, and planning rules | `standards/spec-driven-workflow.md` | AGENTS.md, SKILL.md, README |
| Executable workflow steps per phase | `.agents/commands/<phase>.md` | spec-driven-workflow.md phase table |
| Machine-readable implementation rules per standard | `standards/registry/*.rules.json` | commands, validators, workflow receipts, handoff notes |
| Default stack | `standards/stack.md` | AGENTS.md, README, SKILL.md |
| Module contract | skill `references/module-contract.md` | AGENTS.md, template AGENTS.md |
| Scripting and coding rules | `standards/scripting.md` | everywhere |
| Repository model and layout | this document | README, AGENTS.md |
| Required paths and content rules | workspace manifest (4.2) | consumed by validators |
| Vocabularies (risk levels, closure states, check classifications) | `scripts/common.ps1` registry | ValidateSet declarations, templates, validators, docs |
| Command-execution policy | `.codex/hooks/pre-command.ps1` rule table plus `.codex/rules/default.rules` (layering per 6.2) | README, AGENTS.md |
| AGENTS.md size limit | one number in the manifest; `.codex/config.toml` `project_doc_max_bytes` and the validator must agree. Adopted value: 32768 | - |
| Numbered-spec format and lifecycle | `standards/spec-driven-workflow.md` | new-spec.ps1 help text |

A change that duplicates an owned fact into a second file is a review-blocking defect even if the copies currently agree. When a normative standard changes and it has a matching registry file under `standards/registry/`, reconcile both in the same slice unless the change is purely editorial.

## 4. Governance Surfaces

### 4.1 Layer Roles

- Root `AGENTS.md` - durable workspace rules Codex must always hold: stack default pointer, surface rules, dependency rules, quality gates, design rules. Its workflow section is a pointer to the workflow owner plus the Lean/Gated one-liners; it does not enumerate steps.
- `projects/<app>/AGENTS.md` - app identity, active-spec pointer, app-specific constraints, and verification baseline. Generated by `create-app.ps1`; paths inside it are forward-slash and repo-relative.
- `.agents/skills/` - one required local skill (`cross-platform-app-workflow`) that delegates to canonical standards, plus four thin wrapper workflows (`ui-change-workflow`, `data-change-workflow`, `mobile-validation-workflow`, `release-readiness-workflow`) whose job is to be classifiable and receipt-referenced. Wrapper skills never accumulate their own procedure text.
- `.agents/commands/` - the executable workflow: `specify` (includes the gated clarify branch), `plan`, `tasks`, `analyze`, `implement`, `converge`, `verify`, `release-readiness`. Each command states its working directory, exact script invocations, receipt obligations, and closure rule.
- `.codex/` - runtime enforcement: `config.toml` (inline hooks only; never alongside `hooks.json`), `rules/default.rules`, `hooks/`. Every hook file that exists is wired to an event in `config.toml`; a hook file with no event registration is deleted, not kept for later.
- `standards/` - canonical prose. `scripts/` - mechanical enforcement of the standards. A standard without an enforcing script is a preference; label it as such or build the script.

### 4.2 Workspace Manifest

Required paths, content rules, CI-content rules, and governed numbers live in one declarative manifest (`standards/workspace-manifest.psd1`) consumed by `check-workspace.ps1` and `validate-codex-assets.ps1`. Content rules assert structure and patterns (headings, fields, tokens), never exact prose, per `standards/scripting.md` section 5. Historical records under `docs/audit/` are validated as path-exists only.

### 4.3 Canonical Governance Check

`scripts/check-all.ps1` is the single entry point that runs the full governance sequence (workspace structure, codex assets, hooks, workflow enforcement, spec analysis, secret scan, generation test) in CI order. Humans, README, AGENTS.md, and CI all invoke the same sequence; none maintains its own list.

### 4.4 Core vs Project Validator Scope

- Root governance validators such as `check-workspace.ps1` and `validate-codex-assets.ps1` enforce the current `app-dev` source surfaces immediately: standards, commands, templates, skills, hooks, CI, and root scripts. These are the workspace source of truth and must not drift.
- Project artifact validators such as `check-spec-artifacts.ps1`, `analyze-spec.ps1`, `validate-workflow-receipts.ps1`, and `verify-app.ps1` operate against app state under `projects/<app>/`.
- Existing apps are not made retroactively noncompliant merely because the root workspace later tightens template density or command wording. Their default contract is validator compatibility mode.
- Newly generated apps, disposable scaffold verification projects, and explicitly refreshed apps are validated against the current template contract. That forward-only contract belongs in the root templates and source validators, not as an unannounced breaking change against old app artifacts.
- When a governance slice changes a template or validator rule, document whether it is a core-source change only or whether a specific app also opted into the new contract.

## 5. CI Model

- 5.1 CI workflows execute only from `.github/workflows/` at the repository root. GitHub Actions does not discover nested workflow files; `projects/<app>/.github/workflows/` must not exist.
- 5.2 One validation workflow with two job families: workspace-validation (governance scripts, portability lint first) and app-validation via a project matrix with `working-directory: ${{ matrix.project.path }}`. Matrix entries are hand-listed while one app exists; when the second app lands under `projects/`, the list is replaced by a discovery job that emits the matrix from `projects/*/package.json`. That trigger condition is the recorded decision - do not build discovery speculatively.
- 5.3 Templates do not ship executable workflow files. CI reference snippets live in `templates/common/ci/` with non-executable names such as `verify.reference.yml`, and `create-app.ps1` excludes `.github/` from template copies. This supersedes the previous state where templates carried `.github/workflows/verify.yml` into generated apps as inert files.
- 5.4 Workflow hygiene requirements: `concurrency` group with cancel-in-progress per ref, `timeout-minutes` on every job, `setup-node` npm caching keyed to each app's lockfile, Playwright browser caching, and upload of `playwright-report/` and `test-results/` as artifacts on failure.
- 5.5 CI runs on `ubuntu-latest`; Linux execution is the portability contract (`standards/scripting.md` section 1). App e2e in CI runs in the unconfigured-env state by default: no backend secrets in CI, and e2e specs must pass against the app's degraded and empty states.
- 5.6 Lockfiles are proven by `npm ci` on Linux in CI; a lockfile that installs locally but not in CI is defective.

## 6. Command Policy Layering

- 6.1 Two enforcement layers exist by design: the `PreToolUse`/`PermissionRequest` hook (`pre-command.ps1`) evaluates every matched tool call inside Codex; `.codex/rules/default.rules` governs commands escalated outside the sandbox. The hook's coverage is a superset: it additionally blocks `.env` and private-key reads and global installs.
- 6.2 Both layers derive from the same policy intent. When adding a policy: add the hook rule, add the execpolicy rule if the command can be escalated, and add a blocked-case to `test-hooks.ps1` - in one commit. Divergence between layers is acceptable only in the superset direction (hook stricter than rules) and is documented here.
- 6.3 Hooks fail closed: malformed input produces a block decision, never a crash or a silent allow.

## 7. Planning And Spec Workflow (Pointers)

- Workflow definition: `standards/spec-driven-workflow.md` (Lean Path for ordinary work; Gated Path for auth, payments, secrets, public APIs, data access, uploads, RLS, AI tool actions, deployment, live migrations).
- Execution: `.agents/commands/`. Enforcement: `check-spec-artifacts.ps1` (compatibility by default, `current-template` for new or refreshed apps), `analyze-spec.ps1`, `validate-workflow-receipts.ps1 -ProjectPath . -RequireVerificationEvidence`, `verify-app.ps1`.
- Evidence: `workflow-receipts.md` in the active spec folder is the required evidence trail; agent narratives are not evidence. Hosted CI on the pushed head is the final referee - local verification, however complete, does not substitute for a green run.

## 8. Documentation Hygiene

- All committed docs, ledgers, configs, and generated artifacts use repo-relative forward-slash paths. Absolute local paths are defects, including inside comments.
- README command examples use cross-platform pwsh forms (`./scripts/check-all.ps1`, `cd projects/my-app`).
- Audit records under `docs/audit/` are immutable once their slice closes; corrections append, never rewrite.
- When reality and a standard diverge, the same commit updates whichever one is wrong - never neither, never later.

## 9. Change Control

Changes to `.codex/`, `.agents/`, root `AGENTS.md`, `standards/`, the manifest, templates, CI, or `scripts/` are governance changes: run the canonical governance check sequence before commit, and keep governance-layer changes in slices separate from app feature slices except where a defect discovered by app work is fixed at its template or harness source in the same slice, with the pairing recorded in the receipt.
