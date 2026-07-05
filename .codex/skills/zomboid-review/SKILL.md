---
name: zomboid-review
description: Review gate for Project Zomboid mod code changes, bug fixes, live installs, and post-change audits. Use after any code changes made while using zomboid-modding or zomboid-bug-fixing; use when asked to review or audit Project Zomboid mod changes; use for B42 packaging, Lua/Kahlua API, Java bridge calls, loot/EasyDistro, save data, scripts, sandbox options, UI, world entities, economy, or live-install risk checks.
---

# Zomboid Review

Use this skill as a focused review gate for Project Zomboid mods. The goal is to catch failures that local syntax checks miss: active load roots, B42 packaging, live-install drift, Kahlua/Java API mismatches, save-state shape, loot paths, and end-to-end gameplay contracts.

When invoked from `zomboid-modding` or `zomboid-bug-fixing` after implementation, review the current code changes before final closeout. If the user asked for implementation rather than review-only work, apply focused fixes for confirmed findings, then rerun the relevant review checks.

## Baseline Gate

Run these checks before domain-specific review:

- Identify the changed files: `git status --short`, `git diff --stat`, and targeted `git diff` in the mod repo. Preserve unrelated user changes.
- Identify the mod root, mod ID, active version folder, and live install path. Inspect versioned `mod.info` such as `42/mod.info` or `42.12/mod.info`; do not rely only on root metadata.
- For third-party or Workshop-backed mods, verify that the local Workshop source was checked before local patching or closeout. Inspect `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600`, match by `mod.info` `id=`, active version folder, and relevant files, and flag the change if Workshop already contains the compatible fix/update.
- For project-backed live installs, verify the live entry is a direct child symlink under `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods`, its name matches the project folder casing, `readlink -f` resolves to the project mod folder, and the symlink resolves to the expected versioned `mod.info` and assets. If a project-backed live entry must be repaired, use `~/projects/game-mods/zomboid/link-project-mod.sh <modFolder>`.
- Inspect the latest relevant logs before declaring success. Prefer `~/Zomboid/console.txt`; also check `/media/cjstorrs/windows/Users/cjsto/Zomboid/console.txt` if that is the active log location.
- Search logs for families of errors, not one line only: `ERROR`, `Exception`, `stack traceback`, `attempted index`, `No implementation found`, `Recipe.Load`, `ItemPickInfo`, `unknown SandboxOption`, `Could not assign`, `cannot get ID`.
- Run Lua syntax checks for changed Lua files when possible, but treat `lua5.1 loadfile` as syntax-only. It does not validate PZ globals, Kahlua userdata, Java method signatures, event payloads, or live render behavior.
- Check line endings in touched hunks for Windows-origin mods. Mixed CRLF/LF or broad newline churn is a review finding unless intentionally normalized.

## B42 Packaging And Load State

Check packaging and enablement when files, installs, or mod lists changed:

- Confirm required version folders and companion folders: `42/`, `42.12/`, `Common/`, or `common/` as appropriate for the mod.
- Confirm poster/icon paths exist relative to the `mod.info` that PZ will actually load.
- Verify dependency IDs and B42 `require=\ModID` syntax against installed mod IDs.
- Check every active load point touched by the task: save `mods.txt`, `mods/default.txt`, and `Lua/pz_modlist_settings.cfg`. Do not use `saved_builds.txt` as a mod list.
- Distinguish installed from enabled. Evidence from an installed folder is not active-cause proof unless the mod is enabled in the relevant save/loadout.
- For live-only Workshop/direct mods that are not project-backed, do not assume project symlink behavior applies. Use targeted copy/dry-run logic and verify the live folder shape.

## Causality Review

Use this before accepting a root cause:

- Rank explicit Lua errors, stack traces, missing assets, and parser errors above noisy debug spam.
- Check log category/config problems before patching mod code for spam or lag.
- Match the suspected code to the user action, timing, enabled state, load order, and exact entity/item/container ownership.
- For cleanup/despawn bugs, prove whether the code touches ordinary game entities or only mod-tagged entities.
- Classify the failure phase: app boot, new-game/world-dictionary load, in-world runtime, context menu, timed action, or save/load.
- Flag defensive fixes that hide symptoms instead of proving the cause: broad nil guards, catch-all `pcall`, silent skips, fallback ladders, deleting bad items/entities/save data, or swallowing impossible states. Allow defensive handling only when it is narrowly tied to an absolute-must boundary such as persisted save/modData, sandbox values, client/server command payloads, optional dependencies, real Workshop/API drift, or proven nullable PZ API returns.
- If a stack trace remains for the same user action, closeout is not clean.

## Domain Probes

Run only the probes relevant to the changed files and user request.

### Loot, EasyDistro, Capsules, Wrappers

- If the task touches loot distribution, EasyDistro, spawn rates, zombie/container loot, capsules, packs, boxes, wrappers, or contained item definitions, read and apply `/home/cjstorrs/projects/game-mods/zomboid/.codex/instructions/easy-distributions.md`.
- Audit all active spawn paths in repo and live install: versioned folders, root `media`, `ProceduralDistributions`, `SuburbsDistributions`, `VehicleDistributions`, `OnFillContainer`, zombie inventory, EasyDistro calls, and custom roll code.
- For wrapper/capsule loot, prove raw contents cannot spawn directly. Check item tags, display categories, memento tags, fuel/tinder tags, old root loot files, and upstream compatibility patches.
- Treat EasyDistro injection logs as necessary but insufficient. Review effective probability after sandbox/category multipliers.
- Sandbox option changes require compatibility review for existing saves, startup logs, UI labels, translations, and active presets.

### Lua, Kahlua, Java Bridge, Vanilla Overrides

- Verify Java-exposed method names and signatures from active local vanilla usage, decompiled/bytecode evidence, or known working mods before approving new calls.
- Flag dynamic Java userdata probes such as `object[methodName]`, `if object.someMethod then`, or dot-style method guards. Known PZ userdata may not support them reliably.
- Prefer direct colon calls only after verifying the method owner and signature. Be cautious with `pcall` ladders; Kahlua may still log Java binding errors.
- Treat global monkey-patches of vanilla UI, build, context-menu, timed-action, render, and inventory methods as high-risk. Trace an unrelated vanilla object through the fallback path.
- For event hooks, verify event timing and payloads before keying logic to strings or nullable values.

### Save Data, modData, Persistence

- Treat persisted `modData` and sandbox values as hostile input. Guard nil, sparse arrays, legacy strings/numbers, and truthy non-table containers before indexing, but do not silently delete or rewrite user state unless the migration path is explicit and justified.
- Review every reader and writer of the same save key, not just the stack-trace line.
- For save-compatible fixes, preserve item IDs, mod IDs, perk IDs, sandbox option IDs, and existing serialized field meanings unless the user approved a break.
- Setter availability is not persistence proof. Consider save/load, item transfer, floor drops, nested bags, world containers, and rehydration.

### Inventory, Containers, Timed Actions, Economy

- Trace context-menu offer, selected object, queued `isValid`, action completion, item removal, reward, and UI refresh as one path.
- For world inventory items with storage, resolve the actual storage path, such as `IsoWorldInventoryObject -> InventoryItem -> item inventory`, instead of the wrapper container.
- For sale, payout, contract, mailbox, XP, and reward flows, prove the resource still exists and is removed before granting rewards.
- Preserve existing bonuses and compatibility behavior unless the user explicitly asked to remove them.
- Disable or refresh stale UI rows after successful one-shot actions.

### Body Parts, Wounds, Combat, Movement

- Require bytecode/API or active-source verification for damage events, wound setters, infection fields, movement speed, and combat trigger logic.
- Distinguish lethal zombification infection from normal wound infection. Review setter overloads before copying, clearing, or rerouting wounds.
- For new limb/body-part support, check data, UI, perks/XP, movement, equipment/prosthetics, translations, save reset/rehydration, and tests.
- Do not infer combat behavior from one script flag. Compare vanilla fields and actual engine gates.

### World Objects, Rendering, Entities, Spawns

- For visual/tile changes, trace the B42 render path for base sprites, attached sprites, overlays, alpha, target alpha, and chunk invalidation.
- For scanners, verify object classification and identifiers against the dependency or vanilla path that already recognizes the target.
- For spawn/restore helpers, compare preview output to actual spawn output. Defaults must not defeat the requested workflow.
- When building or room metadata is suspect, require coordinate or volume targeting fallback.
- Entity cleanup predicates need session/provenance/owner discriminators; do not delete all entities with a broad tag.

### Scripts, Recipes, Assets, Text

- For `media/scripts/*.txt`, validate the exact item, recipe, or block changed. Broad greps can false-pass when helper items share values.
- Check B42 script compatibility for recipe syntax, result references, categories, tags, display names, and item inheritance.
- Verify icon/model/texturepack references against actual files or pack contents.
- After broadening a feature, grep stale nouns in tooltips, context labels, debug labels, translations, and docs.

## Findings Format

Report findings first, ordered by severity:

- `Critical` or `High`: blocks closeout until fixed or explicitly accepted by the user.
- `Medium`: likely user-facing bug, compatibility risk, or incomplete requested behavior.
- `Low`: polish, validation weakness, line-ending churn, stale text, or maintainability issue.

For each finding, include:

- Severity
- File/path and line when available
- Concrete risk
- Evidence from diff, log, live install, or known PZ behavior
- Required fix or validation

If no findings are found, say so clearly and list the checks actually performed. Always state remaining in-game validation that cannot be proven outside Project Zomboid.

## Instruction Maintenance

- If the work reveals a new recurring Project Zomboid problem, compatibility pitfall, validation pattern, or durable fix that future sessions should remember, update the relevant workspace or skill instructions while the context is fresh.
- Keep durable generic guidance in `b42.19-codex-instructions.md`; do not recreate one-off current-state notes unless the user explicitly asks.
- Keep instruction updates concise, evidence-backed, and separate from unrelated refactors or historical cleanup.
