# Zomboid Workspace Instructions

This workspace contains Project Zomboid mods. Its Codex Zomboid skills are project-local in `.codex/skills/` so they only apply when Codex is working from this repo.

## Project-Local Codex Skills

Before Project Zomboid mod or save work in this workspace, read the relevant local skill completely:

- `.codex/skills/zomboid-modding/SKILL.md` for mod creation, maintenance, packaging, live linking, load-list updates, and general mod workflow.
- `.codex/skills/zomboid-bug-fixing/SKILL.md` for logs, Lua errors, broken behavior, missing assets, save-compatible fixes, and loot/spawn bugs.
- `.codex/skills/zomboid-revive/SKILL.md` for safely reviving and fully healing a dead local B42.20 character in a backed-up save.
- `.codex/skills/zomboid-review/SKILL.md` after any Project Zomboid mod code, packaging, live-install, mod-list, or asset-reference change.

Do not recreate symlinks from `~/.codex/skills` unless the user explicitly asks. Global symlinks make these skills active outside this workspace.

## B42.20 Migration

Before doing Project Zomboid B42.20 migration, compatibility, live-install,
mod-list, tile-definition, Java-agent, native-patch, or log-error work in this
workspace, read and apply:

`b42.20-codex-instructions.md`

Treat B42.20 as the only active and supported build. Use the game and user-data
roots defined in `b42.20-codex-instructions.md`; do not target retired Project
Zomboid installations or user-data trees.

## Map Mods

Before discovering, evaluating, installing, updating, patching, enabling,
disabling, or debugging a map mod, read and apply:

`.codex/instructions/maps.md`

For multi-map work, also read `MAP_MOD_ROLLOUT.md` and `MAP_MOD_CELLS.tsv`
after every context compaction or new session. The map guide defines the
one-at-a-time workflow, dependency and Steam-comment review, physical-cell
ledger, incompatibility handling, same-token whole-directory override rule,
per-map tweaks convention, save safety, and fresh-world validation.

## Patch Mods For Existing Mods

When adding CJS-only behavior to a third-party or Workshop-backed mod, prefer a separate patch/tweaks mod over overwriting the target mod. Overwrite only when a patch cannot safely layer the change, when refreshing from a verified current Workshop payload, or when the user explicitly asks.

Patch/tweaks repos must be named `pz-<mod-name>-cjs-tweaks`, with `<mod-name>` in kebab-case, e.g. CleanUI -> `pz-clean-ui-cjs-tweaks`. Use the same words without `pz-` for the project folder and `mod.info` `id=`, converted to lower camelCase, e.g. CleanUI -> `cleanUiCjsTweaks`.

## Easy Distributions

Only when a task modifies an item's loot distribution, including adding or removing that item from loot tables or changing how often it appears there, read and apply:

`.codex/instructions/easy-distributions.md`

That guide defines how EasyDistro multipliers work, what distribution tables EasyDistro actually scans, how to handle capsule/wrapper loot, and how to preserve sandbox compatibility.

Do not invoke this guide merely because a mod contains loot-related items, capsules, packs, boxes, wrappers, recipes, or other spawning code. Installing, packaging, enabling, reviewing, or changing non-loot behavior does not trigger the guide.

## Workspace Tools

- `.tools/decompile-pz.sh` is a tracked helper for decompiling Project Zomboid Java classes into the ignored `.pz-reference/` tree. It requires a local Vineflower jar at `.tools/vineflower.jar` or `VINEFLOWER_JAR=/path/to/vineflower.jar`.
- `.tools/pz-continue-debug.sh` is a tracked local debug launcher that starts Project Zomboid, clicks through Continue, and captures diagnostics under ignored `.runtime/`.
- `.lua-scripts/` is scratch space for one-off in-game Lua repair snippets. Do not track it unless a script is deliberately promoted into reusable tooling.
