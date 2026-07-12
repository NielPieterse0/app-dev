# app-dev Constitution

- Version: 1.0.0
- Ratified: 2026-07-08
- Last amended: 2026-07-08

## Principles

1. Free-tier first: prefer no-cost or free-tier infrastructure until product proof or a recorded production need justifies expansion.
2. Modular assembly first: build applications as explicit vertical modules with clear public boundaries before adding framework-level abstraction.
3. Evidence before completion: do not mark work complete until the required spec artifacts, workflow receipts, and verification evidence exist.
4. Security and compliance by risk: gated work requires explicit checklist, migration, permission, and rollback review matched to the actual surface touched.
5. Same-repo project model by default: generated apps under `projects/` remain tracked by the root repository unless a later recorded decision splits them.
6. Recorded deviations: when the simpler default is not used, document the deviation, why it is needed, and what simpler option was rejected.

## Delegation

- Workflow mechanics: `standards/spec-driven-workflow.md`
- Workspace and repository model: `standards/workspace.md`
- Stack and dependency defaults: `standards/stack.md`
- Testing and rendered verification: `standards/testing.md`
- Codex routing and optional accelerators: `standards/codex-capabilities.md`
