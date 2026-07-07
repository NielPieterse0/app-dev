# Local Skills

This directory contains project-local skills for the app-dev workspace.

## Inventory

| Skill | Required | Purpose |
| --- | --- | --- |
| `cross-platform-app-workflow` | Yes | Planning, scaffolding, reviewing, and verifying modular cross-platform apps. |

External/global skills and plugins are optional. Do not reference them as local dependencies unless they are added to this directory with their own valid `SKILL.md`.

The required local workflow is now spec-driven:

- keep durable app rules in `projects/<app>/AGENTS.md`
- keep feature intent in `projects/<app>/specs/NNN-<slug>/spec.md`
- keep implementation sequencing in `projects/<app>/specs/NNN-<slug>/tasks.md`
- keep architecture and verification decisions in `projects/<app>/PLAN.md`
