# Claude Instruction: Easy Distributions Loot

Apply this instruction when adding loot to Project Zomboid mods in this workspace or fixing loot in existing mods.

## Core Rule

Use Nep Easy Distributions only when the desired behavior is:

> Spawn this new item wherever this existing reference item can spawn.

EasyDistro is a reference-item copier. It is not a general replacement for every Project Zomboid loot system.

## Setup

- Require the dependency in the mod's `mod.info` with `require=\NepEasyDistro`.
- Put gameplay loot Lua under the mod's B42 server Lua path, usually `42/media/lua/server/Items/`.
- Load the API with:

```lua
local easyDistroLibrary = require("EasyDistro")
```

- Register loot with:

```lua
easyDistroLibrary.AddItem("MyMod.NewItem", "Base.ReferenceItem", multiplier)
```

## Multiplier Semantics

The EasyDistro multiplier is relative to the reference item's existing table weight.

- `2.0` means double the reference item's weight.
- `1.0` means the same weight as the reference item.
- `0.25` means one quarter of the reference item's weight.

Do not pre-compensate for vanilla sandbox loot category settings such as `LiteratureLootNew`, `OtherLootNew`, or similar. EasyDistro already copies the reference item's actual distribution entries, so the multiplier should stay relative to the chosen reference item.

If a mod has its own sandbox loot multiplier, apply that only to the final EasyDistro multiplier:

```lua
easyDistroLibrary.AddItem(newItem, referenceItem, modLootMultiplier * referenceRelativeMultiplier)
```

## What EasyDistro Scans

Nep Easy Distributions scans:

- `ProceduralDistributions.list`
- `VehicleDistributions`

It does not scan:

- `SuburbsDistributions`
- `Distributions.lua` generic zombie inventories such as `inventorymale` or `inventoryfemale`
- direct outfit inventory tables such as `Outfit_Student`, unless the same item also appears in `ProceduralDistributions.list`
- custom roll tables from other mods

Before choosing a reference item, verify that it appears in a table EasyDistro scans:

```bash
rg -n '"ReferenceItem"' "/home/cjstorrs/games/Project Zomboid/media/lua/server/Items/ProceduralDistributions.lua" "/home/cjstorrs/games/Project Zomboid/media/lua/server/Vehicles/VehicleDistributions.lua"
```

## Capsule Or Wrapper Loot

If a mod should spawn a capsule, pack, box, envelope, tube, or other wrapper item:

- Register only the wrapper item with EasyDistro.
- Register secondary loot items such as binders or albums with EasyDistro too if they are meant to be found directly.
- Do not also add the contained item to loot tables.
- The contained item should be produced by the wrapper's open action, recipe, or context action.
- Keep contained item definitions passive: script item definitions, models, textures, translations, and optional open-action pools only.
- Do not give contained-only items tag-driven spawn hooks such as `base:ismemento`, `base:morewhennozombies`, `base:bagsfillexception`, or similar tags unless the item is intentionally allowed to spawn outside the wrapper.
- If replacing existing direct spawns, remove the old direct inserts too.

This prevents players from finding both the wrapper and the final contained item in world/container loot.

Use Poster Tube/Gooner-style structure as the reference pattern:

- The tube is the EasyDistro loot item.
- The poster items are plain content definitions and assets.
- Opening the tube discovers or rolls a poster and creates it in the player's inventory.
- The poster content items are not added to EasyDistro, `ProceduralDistributions`, `VehicleDistributions`, zombie inventory tables, or memento/tag-based spawn systems.

## Fixing Another Mod's Loot

First identify the mod's current loot path before editing:

- EasyDistro `AddItem`
- direct `ProceduralDistributions` inserts
- `VehicleDistributions`
- `SuburbsDistributions`
- `Distributions.lua` zombie inventory or outfit tables
- custom Lua roll code

Do not assume EasyDistro covers all of those systems. If the target reference item only exists in `Distributions.lua` or a custom mod table, either choose a different EasyDistro reference item or edit that specific non-EasyDistro loot path deliberately.

## Save And Sandbox Compatibility

Avoid renaming sandbox option IDs in existing mods unless you also keep compatibility definitions for the old IDs. Saved worlds and presets can keep old sandbox keys and will log startup errors like `ERROR unknown SandboxOption` if the option definition disappears.

If a sandbox option is obsolete, leave a compatibility option definition in `sandbox-options.txt` and ignore it in code, or migrate code to read both the old and new IDs.

## Validation

After loot edits:

- Run `lua5.1 -e "assert(loadfile('path/to/file.lua'))"` for changed Lua files.
- Run `jq empty` for changed JSON translation files.
- Use `rg` to confirm removed direct loot paths are actually gone.
- Check `~/Zomboid/console.txt` after an in-game startup for EasyDistro output and `unknown SandboxOption` errors.
- If a project mod was copied into the live Zomboid mods folder, verify the live copy too.
