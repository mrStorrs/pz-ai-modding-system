# Project Zomboid Map-Mod Instructions

Read this file before evaluating, installing, updating, patching, enabling,
disabling, or debugging a map mod. Also follow `AGENTS.md`, the applicable
Zomboid skills, and `b42.20-codex-instructions.md`.

Current loadout state and decisions belong in `MAP_MOD_ROLLOUT.md`. Active
physical cell ownership belongs in `MAP_MOD_CELLS.tsv`.

## Rules

- Process one candidate at a time. Record its result before moving to the next.
- Do not change live mods, load lists, or saves while Project Zomboid is running.
- A physical cell overlap makes the candidate incompatible. Record every
  conflicting cell and owner, do not install it, and continue to the next map.
  Load order does not make overlapping cells compatible.
- Derive cells from the selected B42 payload's `.lotheader` files. Steam page
  cell lists and compatibility claims are not authoritative.
- Never create a partial same-token `media/maps/<MapToken>/` override.
- Do not edit map/save binaries or delete generated chunks without explicit user
  approval and a backup.
- Do not call a map working until it passes a new-save visual test. The map
  selector, world map, `MapGroup`, and `map_ver.bin` do not prove that compiled
  lots loaded.

## Required State Files And Tools

| Path | Use |
|---|---|
| `MAP_MOD_ROLLOUT.md` | Queue, checkpoint, dependencies, reports, decisions, conflicts, and remaining tests |
| `MAP_MOD_CELLS.tsv` | Active `.lotheader` ownership and collision status |
| `.tools/pz-map-cell-ledger.sh` | Regenerate the active cell ledger |
| `.tools/pz-map-shadow-audit.sh` | Detect incomplete same-token CJS map overrides |

After context compaction, read this file and `MAP_MOD_ROLLOUT.md` before
continuing. Verify conclusions against the current payloads, load lists, and
logs.

## Candidate Checklist

### 1. Identify The Active Payload

Record:

- Workshop item ID, page title, update timestamp, and local Workshop path.
- Selected B42 version directory and active `mod.info` `id=`.
- Every `media/maps/<MapToken>` directory and `lots=` relationship.
- Optional submaps, connectors, and mutually exclusive variants.
- Differences between Workshop and any existing live copy.

Do not mix B41 and B42 cells or similarly named Workshop items. When the active
B42 version directory or `common/` contains cells, ignore dormant legacy-root
cells.

### 2. Resolve Dependencies

Check the current Steam required-items list, active `mod.info` `require=` lines,
and actual asset use. Resolve dependencies recursively. Record each dependency's
Workshop ID, mod ID, selected payload, required order, and whether it is already
active and current.

Check for bundled copies of tile packs or other mods. Classify compatibility
problems accurately:

- **Cell conflict:** two active physical maps contain the same `.lotheader`
  basename.
- **Tile/content conflict:** duplicate tiledef IDs, sprites, scripts, or asset
  files. This does not require a cell overlap.
- **Map-token shadow:** two mods provide the same `media/maps/<MapToken>` and the
  later mod wins directory resolution, hiding the earlier directory's contents.
- **Load-order/map-group error:** IDs, dependencies, or `lots=` are missing or
  ordered incorrectly.

Do not call tile packs “different versions” without identifying their exact
Workshop IDs and proving the relevant file or registration differences.

### 3. Check Physical Cells

For the candidate and every map-bearing dependency:

1. Select the same B42 and lowercase `common/` roots that the game will load.
2. Extract every `X_Y.lotheader` basename with its map token and source path.
3. Compare the cells with the `cell` column in `MAP_MOD_CELLS.tsv`.
4. Compare optional components with the core map and with one another.

A shipped `.lotheader` claims the cell even when it looks empty. If any cell has
another active owner, mark the candidate `INCOMPATIBLE`, record the complete
conflict set in `MAP_MOD_ROLLOUT.md`, make no install or load-list changes, and
continue. If an optional component overlaps the candidate's core, exclude that
component; if it is required, reject the candidate.

When a Steam cell list disagrees with the selected payload, record the mismatch
and use the payload result.

After installing a compatible map, regenerate the ledger:

```bash
.tools/pz-map-cell-ledger.sh > MAP_MOD_CELLS.tsv
```

Verify the new rows, totals, and conflicts. Incompatible and deferred candidates
stay out of the active ledger; their cells and conflicts stay in the rollout
file. Same-token tweak mirrors stay attributed to the target map, not counted as
a second owner.

### 4. Review Reports And Map Data

Steam data changes. Browse the current page during the evaluation. Review every
comment from the last six months and never fewer than the newest three comment
pages, or all available comments when fewer pages exist. Also review current
pinned bug discussions. Record the date range and number of comments/discussion
posts reviewed.

Classify each relevant report as:

- Confirmed in the current payload.
- Fixed upstream.
- Stale or for another build/variant.
- Caused by a dependency, load order, or compatibility conflict.
- Needs a specific in-game reproduction.
- Unsupported by the available evidence.

If current reports indicate unresolved problems, review the affected code,
metadata, and compiled map data. At minimum check:

- Spawn coordinates, room/building membership, and solid interior spawn tiles.
- Exact lotheader/lotpack/chunkdata cell triads.
- `objects.lua` zones and world-map metadata.
- Rooms/buildings, metadata IDs, stairs/landings, floors, walls, and doors.
- Room labels, fixture container types, and the exact vanilla loot definitions
  selected by each room/container pair.
- Sprites, tiledefs, textures, biome data, and undeclared dependencies.
- `map.info`, `lots=`, token/path casing, thumbnails, and Linux `common/` layout.
- Whether the report applies to single-player, multiplayer, or an optional map
  component.

Do not invent replacements for missing assets or fixes for reports without
enough coordinates, logs, or file evidence. Record the required reproduction.

### 5. Audit Room Labels And Container Loot

Map authors can place the correct military crate or locker sprite inside a room
with the wrong `RoomDef` name. Project Zomboid selects container loot from both
the room name and the tile's `container=` type; the sprite's appearance and the
building's location are not enough to determine the resulting loot.

When a map has suspiciously uniform loot, inspect the complete selected map
payload, not only the reported building:

1. Enumerate relevant compiled rooms from every active `.lotheader`, including
   their name, z-level, rectangles, global bounds, and a valid probe square.
2. Read the room's `.lotpack` squares and resolve each fixture through the
   active base and dependency `.tiles` files. Count actual `container=` values
   such as `militarycrate`, `militarylocker`, `locker`, and `metal_shelves`.
3. Inspect the selected vanilla `media/lua/server/Items/Distributions.lua` and
   `ProceduralDistributions.lua` for the exact room/container pair. If that pair
   is absent, verify `ItemPickerJava` fallback behavior instead of assuming the
   generic result is suitable.
4. Inspect the room and adjoining building context. A non-military storefront,
   basement, house, prison, or remote safe spot may deliberately hide a bunker
   or treasure cache and can still warrant full military guns and ammunition.
5. Classify every suspicious room and record both the rooms to correct and the
   intentionally ammunition-focused exceptions.

For the current B42.20 vanilla payload, these distinctions are important and
must be rechecked after a game update:

- `gunstorestorage.militarycrate` and `.militarylocker` select
  `GunStoreAmmunition`, so broad use of that room label makes every such fixture
  ammunition-only.
- `armystorage.militarycrate` provides the mixed army gun, ammunition, medical,
  outfit, and electronics pools. Use it for true armories, bunkers, and hidden
  military caches even when the surrounding location is not overtly military.
- `security.militarycrate` and `.militarylocker` provide police firearms and are
  suitable for police, prison, and security armories.
- `policestorage` has no `militarycrate` entry. Its fallback is the generic
  `all.militarycrate` humanitarian pool, not a police armory pool.
- `gunstore.militarycrate` selects `ArmySurplusCases`, not the full army pool,
  and `armysurplus.militarycrate` remains ammunition-box focused. A plain
  `gunstore` or `armysurplus` relabel therefore does not fix a full-loot crate.
- Generic fallbacks are asymmetric: `all.militarycrate` is humanitarian while
  `all.militarylocker` includes army guns, outfits, and ammunition. Never infer
  one from the other.

Preserve a small number of ammunition-only rooms when the geometry and nearby
fixtures show that they are genuine gun-store ammunition stockrooms or other
intentional ammo caches. Do not preserve a room merely because it is outside a
military base, and do not convert every matching label without reviewing its
context. Report the exact converted and retained fixture counts.

Prefer a coordinate-bounded runtime room relabel over editing compiled map
binaries when the fix can layer safely. Each rule must include:

- A probe x/y/z inside the room.
- The expected source room name.
- Exact global min/max x/y bounds and z-level.
- The intended replacement name.
- Idempotent handling plus a targeted warning when the room is missing or its
  name or bounds drift from the verified Workshop payload.

`Events.OnLoadedMapZones` is the appropriate B42.20 point for changing verified
`RoomDef` names: map metadata is loaded, and the relabel occurs before
`ItemConfigurator.Preprocess` registers room strings. Do not use a global room
relabel that can affect vanilla or another map.

When one room mixes genuine gun-store fixtures with military crates, no single
vanilla room label may preserve both behaviors. Create a unique namespaced room
distribution that copies the vanilla `gunstore` entries and overrides only the
container entries proven wrong, such as directing `militarycrate` to
`armystorage.militarycrate`. Relabel only the verified room to that custom name.
Do not mutate the global vanilla `gunstore` or `armystorage` tables.

Validation must prove:

- Every rule still resolves to the expected compiled room and exact bounds in
  the current Workshop payload.
- Fixture counts come from tiledefinition `container=` properties, not sprite
  names or screenshots.
- Intended ammunition rooms are absent from the target rules.
- Relabel application is idempotent and fails closed on source-name or bounds
  drift.
- A custom mixed distribution retains the intended vanilla retail entries,
  replaces only the selected military entries, and leaves vanilla tables
  unchanged.
- The audit covered all active map mods when one map exposes a recurring room-
  label mistake; do not stop after repairing the first reported map.

Room relabels do not reroll contents that a save already generated. Do not add a
one-time save repair unless the user asks for one; validate ordinary fixes with
a new save or previously unfilled containers.

### 6. Create A Tweaks Mod Only When Needed

Use a separate private tweaks project for confirmed, layerable fixes. Each map
gets its own project:

- Repository: `pz-<map-name>-cjs-tweaks`.
- Project folder and `mod.info` ID: `<mapName>CjsTweaks`.
- Name: `CJS <Map Name> Tweaks`.
- Dependency: `require=\<TargetModId>`.
- Load order: target immediately followed by its tweaks mod.

Keep runtime Lua and saved data namespaced. Use runtime Lua outside the map token
when it can implement the fix without overriding `media/maps/` files or changing
save-facing IDs.

Do not create or enable a tweaks project for an incompatible candidate unless
the user asks. Preserve confirmed findings in `MAP_MOD_ROLLOUT.md` for later.

## Same-Token Map Override

B42.20 resolves `media/maps/<MapToken>` as one winning directory. A tweaks
directory containing only `objects.lua`, `spawnpoints.lua`, or `map.info` hides
the target directory's compiled geometry. The game may then show the expected
world map and spawn location over procedural forest.

If a fix must override any file under the target's map token, mirror the target's
complete current map-token directory. Include every shipped file, including:

- `map.info`, thumbnails, and metadata.
- All `.lotheader`, `world_*.lotpack`, and `chunkdata_*.bin` files.
- `objects.lua` and `spawnpoints.lua`.
- World-map XML/binaries, biome/forest data, streets data, and images.

Only the intended patched text files may differ. Verify:

- The exact relative filename set matches the target.
- Every cell has the matching lotheader, lotpack, and chunkdata files.
- Every unpatched file is byte-for-byte identical to the target.

Matching file counts are insufficient; the filenames must match. Add these
checks to the tweaks repo's tests and run `.tools/pz-map-shadow-audit.sh`.

A Workshop update makes the mirror stale. Refresh every mirrored file, reapply
the text patch to the new source, update expected hashes/file lists, and rerun
all tests before enabling the tweak again.

Use a distinct map token only when B42.20 runtime evidence proves that it layers
correctly. Do not assume separate tokens merge.

## Install And Save Safety

Before changing live state:

1. Confirm Project Zomboid is not running.
2. Back up the active save and load-list files.
3. Check whether the candidate cells already contain generated or visited save
   data. Do not delete it.
4. Use the verified Workshop payload directly for an unmodified third-party map
   and a project symlink for its CJS tweaks mod.
5. Add dependencies before the target and the tweak immediately after it.
6. Update the intended B42.20 save, the B42.20 `mods/default.txt`, and `b42-4`
   unless the user limited the scope. Verify each exact mod ID occurs once.

For a B42 POT cell `X_Y`, check the save for:

- `metagrid/metacell_X_Y.bin`, `chunkdata/chunkdata_X_Y.bin`,
  `zpop/zpop_X_Y.bin`, and `apop/apop_X_Y.bin`.
- Map chunks under `map/<chunkX>/<chunkY>.bin` where `chunkX` is
  `X*32..X*32+31` and `chunkY` is `Y*32..Y*32+31`.
- Matching `isoregiondata/datachunk_<chunkX>_<chunkY>.bin` files.

Map or isoregion chunks in that range prove generated state. A small sentinel
file by itself requires inspection; do not classify the cell as visited from a
filename alone.

Preserve map tokens and other save-facing IDs.

A world that already generated procedural terrain in a broken map cell cannot
validate the repair. Leave it untouched and use a new save unless the user
separately approves a backed-up chunk repair.

## Validation

Static checks:

- Workshop/live files match except documented normalization and patches.
- Same-token tweaks contain the exact complete map directory and cell triads.
- `map.info`, `lots=`, token casing, and dependencies are valid; declared asset
  paths exist.
- Tweaks projects are live symlinks with the correct casing.
- Save/default/preset IDs and order are correct and unique.
- Suspicious room/container pairs were audited against vanilla distributions,
  and intentional ammunition-only exceptions are documented by coordinates and
  fixture counts.
- Repo tests, Lua parsing, XML/JSON parsing, and `git diff --check` pass.
- The shadow audit passes and the regenerated ledger adds no new conflict.

Runtime checks:

- The launch log shows the intended dependency/target/tweak order.
- For a same-token mirror, the log shows the compiled map files coming from the
  winning tweaks directory.
- A new save contains the expected buildings and supports the intended spawn or
  travel test.
- The new log has no matching `SpawnPoints.initSpawnBuildings` “no room or
  building” warning or relevant map-loading error.

Do not launch Project Zomboid unless the user asks. Report any runtime check the
user still needs to perform.

Diagnostic facts:

- The map selector and world map can work while compiled lots are missing.
- `map_ver.bin` and `MapGroup` prove selection, not correct file resolution.
- Nodebug logs may omit map-folder paths from the “Looking in these map folders”
  section.
- A custom-spawn selector choosing a named map can be normal.
- Correct-cell spawn coordinates plus a “no room or building” warning indicate
  that compiled geometry may not have loaded.
- A clean cell ledger rules out cell overlap only, not shadowing, dependency,
  file-version, or load-order failures.

## Closeout

Before moving to the next map, update `MAP_MOD_ROLLOUT.md` with:

- Candidate identity, payload, dependencies, and cells.
- Compatibility result and exact conflicts.
- Comment/discussion coverage and report classifications.
- Room/container loot findings, converted fixture totals, and intentional
  ammunition-focused exceptions when applicable.
- Audit findings, fixes, repo/commit/push state, and live/load-list result.
- Ledger totals, backups, save-safety result, and remaining runtime checks.
- The next candidate and exact continuation action.

Run the Zomboid review gate after implementation or live changes. Report the
current map's result, then continue.
