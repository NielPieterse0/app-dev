# app-dev Scripting And Coding Standard

- Document: standards/scripting.md
- Version: 1.0.0
- Date: 2026-07-09
- Status: Adopted. Remediation of existing violations is tracked in `projects/signal/specs/007-code-script-closeout/`.
- Owner: app-dev
- Applies to: `scripts/`, `.codex/hooks/`, `projects/<app>/scripts/`, template-embedded scripts, and (Part B) template and application source code
- Enforcement: CI portability lint (section 9), PSScriptAnalyzer (section 9), manifest-driven validators (section 5)
- Change control: amendments follow the numbered-spec workflow; enforcement scripts in section 9 are updated in the same commit as any rule change they enforce

---

## Part A - Harness Scripting (PowerShell)

### 1. Prime Directive

Every script runs identically on ubuntu-latest and on a Windows workstation, invoked as `pwsh -File <script>`.

Linux CI is the canonical execution environment and the contract. Windows-local execution is a developer convenience. A script that passes locally but cannot run on the Linux runner is defective, not untested. The 2026-07-09 CI failure traced to seven files carrying Windows-only idioms that no local run could expose.

### 2. Cross-Platform Rules (Hard Requirements)

| # | Rule | Incident reference |
|---|---|---|
| 2.1 | Path literals use forward slashes only: `Join-Path $root ".codex/hooks/pre-command.ps1"`. pwsh normalizes `/` on Windows; `\` is a literal filename character on Linux. | test-hooks.ps1, test-workflow-enforcement.ps1, validate-workflow-receipts.ps1 |
| 2.2 | Never call `cmd.exe`, `powershell`, `bash -c`, or any shell wrapper to run a tool. Invoke natives directly: `& git diff --name-only $range`. | get-workflow-obligations.ps1 |
| 2.3 | Suppress native stderr with `2>$null`, never `2>nul`. | same file |
| 2.4 | The cross-platform binary is `pwsh`. The name `powershell` must not appear as an invoked binary in any script, package.json script, workflow, hook config, or generated artifact. | test-hooks.ps1; Signal release:check |
| 2.5 | Never post-process paths with `Replace("/", "\")` or the inverse. Produce forward-slash relative paths at the source and keep them that way. | common.ps1 Get-ActiveSpecRelativePath; check-spec-artifacts.ps1 round-trip |
| 2.6 | File references in scripts and manifests match on-disk casing exactly. Windows will not catch a mismatch; Linux will. | preventive |
| 2.7 | Write files with `Set-Content -Encoding UTF8`; regexes match `\r?\n`, never bare `\r\n` or `\n` assumptions. | codified existing practice |
| 2.8 | Temp locations via `[System.IO.Path]::GetTempPath()` plus GUID suffix, cleaned in try/finally. | codified existing practice |
| 2.9 | No absolute local paths in any committed artifact - scripts, docs, ledgers, links, comments, or generated files. Repo-relative only. | 2026-07-09 findings ledger |

### 3. Parameter Contract

```powershell
param(
  [Parameter(Mandatory = $true)][string]$ProjectPath,
  [string]$BaseRef,
  [switch]$RequireVerificationEvidence,
  [switch]$SkipE2E,
  [switch]$JsonSummary
)
$ErrorActionPreference = "Stop"
```

- 3.1 Boolean intent is always `[switch]`. Never `[bool]` and never `[object]` coercion except per 3.4.
- 3.2 A `[switch]` never defaults to `$true`. If default behavior is on, name the switch for the opt-out: `-IncludeE2E = $true` becomes `-SkipE2E`.
- 3.3 CI and docs invoke switches bare (`-RequireVerificationEvidence`) or with colon syntax (`-Flag:$false`) - never space-separated `$true`/`$false`.
- 3.4 Where a GitHub Actions expression must pass a value, accept it as `[string]` with explicit documented coercion at the top of the script. This is the only sanctioned coercion site.
- 3.5 `[ValidateSet(...)]` values come from the vocabulary registry (section 6), never a second hand-typed list. Incident: new-spec.ps1 accepts standard|sensitive while the harness vocabulary added gated.
- 3.6 Every script begins with `param()` then `$ErrorActionPreference = "Stop"`, before any other statement.

### 4. Execution And Exit Contract

- 4.1 Aggregate, then fail: collect problems into a failures list, report all, emit one `Write-Error`, exit non-zero. Never fail on the first finding of a multi-check script.
- 4.2 Success prints exactly one final summary line.
- 4.3 `-JsonSummary` is supported by every check script and emits one JSON object with at minimum root/projectPath, failures, warnings, failureCount, warningCount. Machine consumers parse this; they never scrape prose output.
- 4.4 After every native tool invocation, check `$LASTEXITCODE` explicitly.
- 4.5 Optional external tools are probed with `Get-Command`; absence degrades to a recorded warning when optional and a failure when a Require switch is set.
- 4.6 Fail closed: malformed input errors; hooks emit the block-decision JSON rather than crashing.

### 5. Data Over Code - The Manifest Rule

- 5.1 Required paths, required-content rules, and CI-content rules live in one declarative manifest consumed by both `check-workspace.ps1` and `validate-codex-assets.ps1`.
- 5.2 Content rules assert structure and patterns, not prose. Permitted rule types: path-exists, heading-exists, field-matches, token-present, max-bytes, frontmatter-schema. Exact-wording assertions require a recorded reason in the manifest entry.
- 5.3 Template substitution uses `{{TOKEN}}` placeholders exclusively. Prose-matching replacement chains are forbidden; generation fails if any token remains unresolved in output.
- 5.4 Vocabularies are defined once in the registry (section 6) and referenced everywhere.
- 5.5 Suppressions and allowlists are keyed by path plus pattern with a mandatory inline justification, never by line number.

### 6. Shared Code And The Single-Truth Rule

- 6.1 `scripts/common.ps1` is the only shared-helper location for root scripts. Anything used by two or more scripts moves there in the commit that creates the second use.
- 6.2 Reimplementing a helper inline is a defect even before drift occurs. Standing instances: the active-spec regex inline in check-spec-artifacts.ps1; Get-SectionBody and Get-FieldValue duplicated across analyze-spec.ps1 and validate-workflow-receipts.ps1.
- 6.3 `common.ps1` hosts the vocabulary registry: risk levels, gated levels, completed states, invalid verification states. `Test-GatedRiskLevel` and all ValidateSet mirrors read from it.
- 6.4 Helpers return forward-slash repo-relative paths. Path-shape conversion is not a helper responsibility.

### 7. Script Size, Shape, Naming

- 7.1 Verb-noun kebab-case filenames. `test-<x>.ps1` tests exactly `<x>` or the subsystem it names.
- 7.2 A script exceeding roughly 300 lines signals that checks belong in manifest data or the script has multiple responsibilities.
- 7.3 One responsibility per script; composition happens in CI steps and hooks.
- 7.4 Every enforcement script has a test script exercising at least one pass fixture and one fail fixture per rule family, using GUID temp dirs and try/finally cleanup.
- 7.5 Test scripts invoke targets exactly as CI invokes them - same binary, same parameter syntax.

### 8. Git Interaction

- 8.1 Direct invocation with explicit `$LASTEXITCODE` checks; never via a shell wrapper.
- 8.2 Diff-based logic supports three labeled modes: working-tree, committed-range (merge-base against `-BaseRef`), and explicit file list. CI and post-hoc audits use committed-range; a working-tree-only enforcement script is inert in CI.
- 8.3 Parse git plumbing output only (`--name-only`, `--porcelain`).

### 9. Enforcement

The gate for a defect class ships with the fix for its first instance.

- 9.1 `scripts/lint-portability.ps1` runs as the first CI script step and fails on: `cmd\.exe`; `2>\s*nul\b`; `powershell` as an invoked binary; `Replace("/","\")` and inverse; backslashes inside path-like string literals; `[bool]$` in param blocks; `[switch]$x = $true`.
- 9.2 PSScriptAnalyzer runs in CI over `scripts/` and `.codex/hooks/` with a committed settings file; suppressions inline with justification per 5.5.
- 9.3 Until the manifest refactor lands, no new exact-phrase assertions may be added to `validate-codex-assets.ps1`.
- 9.4 CI script steps run on ubuntu-latest. A Windows matrix leg may be added; it never replaces the Linux leg.

### 10. Adoption Sequence

Tracked as `projects/signal/specs/007-code-script-closeout/`: (1) fix the confirmed Linux-fatal files and generated-content paths; (2) land lint-portability plus PSScriptAnalyzer in the same commit; (3) normalize parameter semantics; (4) consolidate duplicated helpers and add the vocabulary registry; (5) manifest refactor as its own follow-on gated spec; (6) replace create-app.ps1 prose surgery with token-only substitution.

---

## Part B - Template And Application Code (TypeScript / React)

- B.1 Environment access is lazy and validated: no module-scope env parsing; exported parse/require/isConfigured functions; backend-only key names and `sb_secret_` shapes rejected at parse time. The template `env.ts` is the reference implementation.
- B.2 Router-aware navigation only (`NavLink`/`Link`); active-state derives from the router, not a parallel prop.
- B.3 Explicit QueryClient defaults: `retry` and `refetchOnWindowFocus` deliberate for queries and mutations; `staleTime` chosen consciously per app.
- B.4 Module boundaries are lint-enforced: cross-module imports only through `@/modules/<module>`; every new module ships its `index.ts` public surface.
- B.5 Every data surface renders empty, loading, and error states; e2e specs pass in the unconfigured-env state, asserting the degraded UI.
- B.6 Migrations: append-only numbered chain; idempotent where re-runnable; security posture recorded via `comment on`; `security definer` functions set `search_path`. Anonymous-write grants require the comment, release-gate coverage, and gated risk classification.
- B.7 Release gates check state, not prose: net grant state across all migrations or live verification. Text-pinned patterns against specific files are an accepted interim only, recorded as such.
- B.8 Lockfiles are CI-proven on Linux. package.json scripts contain no OS-specific binaries (`pwsh`, never `powershell`).
- B.9 Template parity is auditable: a manifest of template-owned files is diffed against each app; unrecorded drift is a CI warning. Fixing a template defect without propagating or recording divergence is incomplete work.
- B.10 No absolute or machine-local paths in any committed app artifact.

## Appendix - Forbidden Idiom Quick Reference

| Forbidden | Use instead |
|---|---|
| `Join-Path $root "a\b\c.ps1"` | `Join-Path $root "a/b/c.ps1"` |
| `& cmd.exe /d /c "git diff ... 2>nul"` | `& git diff --name-only $range 2>$null` |
| `powershell -NoProfile -File x.ps1` | `pwsh -NoProfile -File x.ps1` |
| `$path.Replace("/", "\")` | keep forward slashes end-to-end |
| `[bool]$Flag` | `[switch]$Flag` |
| `[switch]$IncludeE2E = $true` | `[switch]$SkipE2E` |
| `-SomeSwitch $true` in CI or docs | `-SomeSwitch` or `-SomeSwitch:$false` |
| Prose-matching template replacement | `{{TOKEN}}` substitution plus fail on unresolved tokens |
| Exact-sentence validator assertions | manifest rules: heading, field, token, pattern |
| Allowlist pinned to a line number | path plus pattern plus justification |
| Duplicate path lists or regexes across scripts | single manifest or common.ps1 |
| Absolute local paths in committed docs | repo-relative links |
