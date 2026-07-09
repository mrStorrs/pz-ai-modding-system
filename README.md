# AI Workspace Guide

This repository is configured for AI-assisted maintenance through top-level
instructions, project-local Codex skills, and supporting workflow references.
The documentation here describes that AI system only; it intentionally does not
catalog or describe the contained workspace items.

## Entry Points

- `AGENTS.md` is the first instruction file for Codex in this workspace. It
  defines home-directory hygiene, privileged-command expectations, skill routing,
  and project-specific guardrails.
- `.codex/skills/` contains project-local Codex skills. These skills are scoped
  to this repository and should not be symlinked into global Codex skill
  directories unless explicitly requested.
- `.codex/instructions/` contains focused supplemental instructions that a skill
  may require for a narrower task.
- `b42.19-codex-instructions.md` is a compatibility and migration reference that
  Codex reads before matching migration, compatibility, install, translation,
  asset, native-patch, or log-error work.
- `.tools/` contains local helper scripts used by the AI workflow for inspection,
  diagnostics, and reference generation.

## Local Skills

The project-local skills define when Codex should switch from general coding
behavior to a domain-specific workflow:

- `zomboid-modding`: creation, maintenance, packaging, linking, load-list, and
  general workflow tasks.
- `zomboid-bug-fixing`: log-driven debugging, broken behavior, load failures,
  compatibility fixes, and save-compatible repairs.
- `zomboid-review`: post-change review for code, packaging, live-install,
  asset-reference, script, sandbox, and related changes.

When a task matches one of these skills, Codex should read the full skill file
before acting. If a task touches an area with supplemental instructions, Codex
should read those instructions before editing.

## Workflow Rules

Codex should preserve existing user edits, inspect the actual working copy before
changing files, and prefer local patterns over generic assumptions. For changes
that affect runtime behavior or packaging, the relevant review skill is part of
the closeout process, not an optional extra.

Validation depends on the task. Local syntax, structure, diff, and log checks
should be run when they apply. If a behavior cannot be proven outside the target
runtime, Codex should state the remaining manual validation clearly in the final
response.

## Boundaries

- Keep AI-generated files inside this repository or another approved workspace.
- Do not create new top-level files in the home directory without approval.
- Do not install dependencies or persistent assets into the home directory
  without explaining the location and getting approval.
- Do not make project-local skills global unless explicitly requested.
- Do not use broad defensive fixes to hide root causes; prefer targeted,
  evidence-backed changes.
