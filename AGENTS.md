# Zomboid Workspace Instructions

This workspace contains Project Zomboid mods. Its Codex Zomboid skills are project-local in `skills/` so they only apply when Codex is working from this repo.

## Project-Local Codex Skills

Before Project Zomboid mod work in this workspace, read the relevant local skill completely:

- `skills/zomboid-modding/SKILL.md` for mod creation, maintenance, packaging, live linking, load-list updates, and general mod workflow.
- `skills/zomboid-bug-fixing/SKILL.md` for logs, Lua errors, broken behavior, missing assets, save-compatible fixes, and loot/spawn bugs.
- `skills/zomboid-review/SKILL.md` after any Project Zomboid mod code, packaging, live-install, mod-list, or asset-reference change.

Do not recreate symlinks from `~/.codex/skills` unless the user explicitly asks. Global symlinks make these skills active outside this workspace.

## B42.19 Migration

Before doing Project Zomboid B42.19 migration, compatibility, live-install, mod-list, translation, asset, native-patch, or log-error work in this workspace, read and apply:

`b42.19-codex-instructions.md`

That guide captures the concrete B42.12 -> B42.19 pitfalls learned in this workspace, including direct-Workshop rules, active load-list behavior, Linux path shims, B42.19 Lua/API migrations, native helper patches, translation compatibility, and per-mod lessons.

## Easy Distributions

Before adding new loot or fixing existing loot that uses Nep Easy Distributions, read and apply:

`instructions/easy-distributions.md`

That guide defines how EasyDistro multipliers work, what distribution tables EasyDistro actually scans, how to handle capsule/wrapper loot, and how to preserve sandbox compatibility.

## Workspace Tools

- `.tools/decompile-pz.sh` is a tracked helper for decompiling Project Zomboid Java classes into the ignored `.pz-reference/` tree. It requires a local Vineflower jar at `.tools/vineflower.jar` or `VINEFLOWER_JAR=/path/to/vineflower.jar`.
- `.tools/pz-continue-debug.sh` is a tracked local debug launcher that starts Project Zomboid, clicks through Continue, and captures diagnostics under ignored `.runtime/`.
- `.lua-scripts/` is scratch space for one-off in-game Lua repair snippets. Do not track it unless a script is deliberately promoted into reusable tooling.
