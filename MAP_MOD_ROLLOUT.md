# Project Zomboid Map-Mod Rollout Anchor

This is the persistent recovery point for the large map-mod rollout. Read this
file, `.codex/instructions/maps.md`, `MAP_MOD_CELLS.tsv`, `AGENTS.md`, the
complete `zomboid-modding` skill, and `b42.20-codex-instructions.md` after every
harness/context compaction before continuing.

## Objective And Invariants

Process the user's requested map mods exactly one at a time.

For every map and every dependency:

1. Resolve the exact Steam Workshop item, current B42.20 payload, active `id=`,
   map folder token, dependency set, and required load order.
2. Extract occupied cells from the version folder selected by B42.20 plus
   lowercase `common/`. Prefer `42.20/`; accept a verified generic `42/`
   fallback from a compatible upstream payload. Compare the result with the
   full cumulative ledger before install.
3. Do not install a map that introduces a cross-mod cell overlap. Mark that map
   `INCOMPATIBLE`, record every conflicting owner/cell and the reason, then
   continue immediately to the next queued map. Never hide a collision by relying
   on load order.
4. Review recent Steam comments and current Workshop metadata. If users report
   problems, audit the current payload and determine whether each report is
   current, reproducible from code/assets/metadata, stale, dependency-related, or
   unsupported.
5. Fix confirmed layerable issues in a narrow, separate CJS tweaks mod. Each
   affected map gets its own project/repo using the workspace convention:
   `pz-<map-name>-cjs-tweaks` for the private GitHub repo and lower-camel-case
   `<mapName>CjsTweaks` for the project folder and `mod.info` ID. Require the
   target map and load the tweaks mod immediately after it.
6. Prefer the verified current Workshop payload as the live source for
   third-party maps. Preserve save-facing IDs and never hand-edit binary map data.
7. Update the newest save, `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/mods/default.txt`, and the
   `b42-4` preset together unless the user explicitly narrows scope.
8. Run the complete `zomboid-review` gate after live/load-list or tweaks changes,
   update this checkpoint and the ledger, then report the result before starting
   the next map.
9. Before the first map mutation, archive the active save and load-list files.
   For each candidate, check whether any claimed cells already have generated
   chunks in the active save. Never delete/reset visited chunks or binary map data
   without a separate evidence-backed decision and user approval.
10. A separate tweaks mod must never ship a partial `media/maps/<token>/`
    directory. B42.20 resolves the entire virtual map directory to the last
    override, so a partial `objects.lua` or `spawnpoints.lua` override masks the
    target's `.lotheader`, `.lotpack`, and `chunkdata` files and produces
    procedural forest. A map-file tweaks mod must mirror the target's complete
    current map directory while preserving only the intended patched text files.

## Persistent Files

| File | Purpose |
|---|---|
| `MAP_MOD_ROLLOUT.md` | Queue, per-map decisions, blockers, and exact continuation point |
| `.codex/instructions/maps.md` | Durable map-mod workflow, packaging rules, safety gates, and validation standard |
| `MAP_MOD_CELLS.tsv` | One row per active physical `.lotheader`, including collision status |
| `.tools/pz-map-cell-ledger.sh` | Rebuilds the ledger from the newest active B42.20 save and B42.20-selected version/common payloads |
| `.tools/pz-map-shadow-audit.sh` | Rejects incomplete same-token CJS map-directory overrides |

Regenerate the ledger after each successful map/dependency activation:

```bash
.tools/pz-map-cell-ledger.sh > MAP_MOD_CELLS.tsv
```

Before installation, extract the candidate and dependency `.lotheader` basenames
from their B42.20-selected version/common payloads and compare every `X_Y` value against the
`cell` column in `MAP_MOD_CELLS.tsv`.

## Current Checkpoint

The detailed per-map records below predate the dedicated B42.20 cutover unless
an entry explicitly says it was revalidated afterward. Treat them as leads and
historical implementation context, not current compatibility proof. Before any
new install, repair, or enablement decision, rerun the full workflow against the
B42.20 game, user-data tree, Workshop payloads, logs, and fresh saves.

| Field | Value |
|---|---|
| Rollout state | `B42.20_REVALIDATION_REQUIRED`: prior static repairs and compatibility results are not current until rechecked against B42.20 |
| Active save used for baseline | Resolve the newest B42.20 save at execution time; the prior `2026-07-18_18-52-21` baseline is historical only |
| Requested queue | 15 maps supplied on 2026-07-19; preserved below in user order |
| Current map | B42.20 baseline and active-map revalidation |
| Last processed map | Raccoon City (`PACKAGING_REPAIR_STATIC_PASS`) |
| Exact next action | When Project Zomboid is stopped, rebuild the ledger from the newest B42.20 save and live mods root, revalidate active map/dependency/tweaks payloads against current Workshop sources, then create fresh B42.20 test saves for Wildsteel and Little Town. Keep Greenport, Greenleaf, Dirkerdam, and Green River disabled until separately revalidated. |

## One-Map Execution Checklist

| Gate | Required evidence before advancing |
|---|---|
| Identity | Workshop ID/URL, display name, B42 mod ID, map token, current payload location and update date |
| Dependencies | Full recursive dependency list, exact IDs, payloads present, required order documented |
| Cells | Candidate and map-dependency cells extracted; zero cross-mod overlaps against the cumulative ledger |
| Comments | Every comment from the last six months and the newest three pages reviewed (or all comments if fewer exist), plus current pinned bug discussions; dates/counts recorded and claims checked against current files |
| Audit/tweaks | Full relevant review for reported issues; per-map tweaks repo created only for confirmed fixes that should layer over Workshop |
| Existing-save safety | Target cells checked for generated/visited save chunks; save and load-list backup exists before mutation |
| Install | Direct live child folders/symlinks correct; exact map/dependency/tweaks IDs ordered correctly |
| Load points | Newest save, default list, and `b42-4` each contain every intended ID exactly once |
| Review | B42 layout, `mod.info`, map metadata, assets, scripts/Lua, logs, diffs, live source, and remaining in-game checks reviewed |
| Closeout | Ledger regenerated, conflicts rechecked, this checkpoint updated, and one-map result reported |

## Baseline Map Registry

Populate cell counts and conflicts from the generated ledger. Mods with map
metadata but no `.lotheader` (for example spawn selectors or DWAP overlays) are
tracked separately because they do not claim physical cells by themselves.

| Mod ID | Live folder | Role | Dependencies | Cells | Cross-mod conflict cells | Notes |
|---|---|---|---|---:|---:|---|
| `42Grapeseed` | `Grapeseed` | Physical map | — | 24 | 3 | Existing `grapeseedCjsTweaks` follows the target |
| `Constown42` | `Constown` | Physical map | — | 18 | 3 | Conflicts with Grapeseed at the shared western/eastern edge |
| `RavenCreekB42` | `Raven Creek B42` | Physical map | — | 116 | 0 | — |
| `Estate 39` | `Estate 39` | Physical map | — | 4 | 2 | Conflicts with Willowbrook Bastion |
| `Fort_Boonesborough` | `Fort Boonesborough` | Physical map | — | 3 | 0 | — |
| `HazelnutManor` | `Hazelnut Manor` | Physical map | — | 4 | 0 | — |
| `Louisville_Quarantine_Zone` | `Louisville Quarantine Zone` | Physical map | — | 6 | 0 | — |
| `Louisville_River_Marina` | `Louisville River Marina` | Physical map | — | 6 | 3 | Conflicts with PIE42 |
| `Louisville_Riverboat` | `Louisville_Riverboat` | Physical map | — | 1 | 0 | — |
| `PIE42` | `PIE42` | Physical map/large map layer | — | 1,169 | 3 | Conflicts with Louisville River Marina |
| `PROJECTRVInterior42` | `modPROJECTRVInterior` | Physical interior map | — | 44 | 0 | Base for RV expansions |
| `Willowbrook Bastion!` | `Willowbrook Bastion!` | Physical map | — | 15 | 2 | Existing `willowbrookBastionCjsTweaks` follows the target |
| `RVInteriorExpansion` | `rvupdate` | Physical interior map | `PROJECTRVInterior42` | 121 | 0 | — |
| `RVInteriorExpansionPart2` | `rvupdate2` | Physical interior map | `PROJECTRVInterior42` | 30 | 0 | — |
| `dawn_town` | `DawnTown` | Physical map | `Roccos_Tiles` | 4 | 0 | Direct current Workshop payload; `dawnTownCjsTweaks` follows the target |
| `HavenFall` | `HavenFall` | Physical map | — | 16 | 0 | Direct current Workshop payload; `havenFallCjsTweaks` follows the target |
| `Maplewood` | `Maplewood` | Physical map | — | 4 | 0 | Direct current Workshop payload; `maplewoodCjsTweaks` follows the target |
| `BlackpineCounty` | `Blackpine County` | Physical map | `PertsPartyTiles`, `melos_tiles_for_miles_pack`, `Project_Seasons_B42`, `UnofficialMappersCommunityTilePack`, `Erikas_Tiles` | 40 | 0 | Direct current Workshop payload; `blackpineCountyCjsTweaks` follows the target |
| `WILDSTEEL` | `WILDSTEEL` | Physical map | — | 4 | 0 | Direct current Workshop payload; `wildsteelCjsTweaks` follows the target |
| `Begonia_Town` | `Begonia_Town` | Physical map | `LiuDing_Tiles`, `Roccos_Tiles` | 10 | 0 | Direct current Workshop payload; `begoniaTownCjsTweaks` follows the target |
| `Cathaya Valley 2.0 B42 version` | `Cathaya Valley 2.0` | Physical map | `UnofficialMappersCommunityTilePack` | 6 | 0 | Direct current Workshop core payload; `cathayaValleyCjsTweaks` follows the target; overlapping optional highway excluded |
| `littletown` | `LittleTown` | Physical map | — | 4 | 0 | Direct current Workshop payload; `littleTownCjsTweaks` follows the target |
| `rustbury_2026_b42` | `RustBury` | Physical map | — | 4 | 0 | Direct current Workshop payload; `rustBuryCjsTweaks` follows the target |
| `fairhavenmap` | `Fairhaven` | Physical map | — | 4 | 0 | Current Workshop payload with path-only `Common` to `common` normalization; `fairhavenCjsTweaks` follows the target |
| `RaccoonCityB42` | `RaccoonCityB42` | Physical map | — | 12 | 0 | Direct current Workshop payload; `raccoonCityCjsTweaks` follows the target |

Baseline total: 1,561 ownership rows, 1,553 distinct occupied cells, and eight
distinct cross-mod conflict cells.

Current total after Dawn Town: 1,565 ownership rows, 1,557 distinct occupied
cells, and the same eight pre-existing cross-mod conflict cells.

Current total after Haven Fall: 1,581 ownership rows, 1,573 distinct occupied
cells, and the same eight pre-existing cross-mod conflict cells.

Current total after Maplewood: 1,585 ownership rows, 1,577 distinct occupied
cells, and the same eight pre-existing cross-mod conflict cells.

Current total after Blackpine County: 1,625 ownership rows, 1,617 distinct
occupied cells, and the same eight pre-existing cross-mod conflict cells.

Current total after Wildsteel: 1,629 ownership rows, 1,621 distinct occupied
cells, and the same eight pre-existing cross-mod conflict cells.

Current total after Begonia Town: 1,639 ownership rows, 1,631 distinct occupied
cells, and the same eight pre-existing cross-mod conflict cells.

Current total after Cathaya Valley: 1,645 ownership rows, 1,637 distinct
occupied cells, and the same eight pre-existing cross-mod conflict cells.

Current total after Littletown: 1,649 ownership rows, 1,641 distinct occupied
cells, and the same eight pre-existing cross-mod conflict cells.

Current total after RustBury: 1,653 ownership rows, 1,645 distinct occupied
cells, and the same eight pre-existing cross-mod conflict cells.

Current total after Fairhaven: 1,657 ownership rows, 1,649 distinct occupied
cells, and the same eight pre-existing cross-mod conflict cells.

Current total after Raccoon City: 1,669 ownership rows, 1,661 distinct occupied
cells, and the same eight pre-existing cross-mod conflict cells.

### Existing Cross-Mod Cell Conflicts

| Cells | Owners | Decision |
|---|---|---|
| `24_42`, `24_43`, `24_44` | `42Grapeseed`, `Constown42` | Needs user-directed resolution |
| `33_38`, `33_39` | `Estate 39`, `Willowbrook Bastion!` | Needs user-directed resolution |
| `46_3`, `47_3`, `48_3` | `Louisville_River_Marina`, `PIE42` | Needs user-directed resolution |

### Incompatible Requested Candidates

| Candidate | Conflicting cells | Active owner | Decision |
|---|---|---|---|
| `GreenportB42` (`3747595202`) | `32_28`, `33_28` | `PIE42` (Project Indiana Expansion) | Skipped; never installed or enabled |
| `Greenleaf B42 version` (`3602388131`) | `24_42`, `25_42`, `26_42` | `42Grapeseed` at all three cells; `Constown42` also at `24_42` | Skipped; never installed or enabled |
| `DirkerdamB42` (`3754852031`) | 588 cells: `5..16_7..21`, `17..19_7..20`, `20..29_7..19`, `30..31_7..26`, `32..35_7..28`, and `36..41_7..24` | `PIE42` (Project Indiana Expansion) | Deferred by user on 2026-07-19 pending the planned single-player update; current standalone-MP payload was never installed or enabled |
| `GreenRiver` (`3555893112`) | All 180 cells in rectangle `0_0` through `17_9` | `PIE42` (Project Indiana Expansion) | Skipped; never installed or enabled; bundled tiledefs `830` and `7001` also collide with active Community Tile Pack |

### Deferred-Candidate Cross-Compatibility

These prospective comparisons use the current cached B42 `.lotheader` files.
They are intentionally not rows in `MAP_MOD_CELLS.tsv`, which records only
installed physical map ownership.

| Candidate pair | Direct cell result | Decision |
|---|---|---|
| `GreenportB42` + `DirkerdamB42` | Six overlaps: `31_28`, `31_29`, `32_28`, `32_29`, `33_28`, and `33_29` | Incompatible regardless of PIE42 or load order |
| `DirkerdamB42` + `GreenRiver` | 39 overlaps: every cell in rectangle `5_7` through `17_9` | Incompatible regardless of PIE42 or load order |
| `GreenportB42` + `GreenRiver` | No direct cell overlap | Cell-compatible with each other, but each retains the independent blockers recorded below |
| `Greenleaf B42 version` + any of Greenport, Dirkerdam, or Green River | No direct cell overlap | Greenleaf remains incompatible with active Grapeseed/Constown instead |

Removing PIE42 therefore does **not** make Greenport, Dirkerdam, and Green River
mutually compatible. The maximum cell-compatible subset of those three is
Greenport plus Green River. Choosing Dirkerdam excludes both of the others.

### Tile-Pack And Tiledef Compatibility

Dirkerdam's current `require=` line mandates the three standalone tile mods below
plus already-active `PertsPartyTiles`. The first three reuse pack names and
tiledef numbers already registered by active Community Tile Pack
(`UnofficialMappersCommunityTilePack`). They must not be enabled together without
a new compatibility implementation and asset audit.

| Dirkerdam dependency | Shared registration with Community Tile Pack | Current payload comparison | Compatibility result |
|---|---|---|---|
| `tkTiles_01` (`3754848589`) | pack `tkTiles_01`; tiledef `tkTiles_01 830` | Texture pack is byte-identical; `.tiles` definition differs by hash | Duplicate registration with different tile definitions; incompatible as-is |
| `DylansTiles` (`3754850359`) | pack `DTilesPack`; tiledef `dylanstiles 6985` | Both texture pack and `.tiles` definition differ by hash | Conflicting asset and tile definitions; incompatible as-is |
| `Diederiks Tile Palooza` (`3754850813`) | pack `diederiks_tile_palooza`; tiledef `diederikv_tile_def 7001` | Texture pack is byte-identical; `.tiles` definition differs by hash | Duplicate registration with different tile definitions; incompatible as-is |

Community Tile Pack cannot simply be removed from the current loadout:
`Cathaya Valley 2.0 B42 version` explicitly requires it, and Blackpine County's
compiled map content was verified to use it. Empty dependency-ID shims or editing
Dirkerdam's `require=` line have not been proven safe because the differing Dylan
pack and all three differing tiledefs may change sprite definitions used by the
compiled map.

Green River has a separate form of the same problem: its current payload bundles
tk/Diederik assets and tiledefs `830` and `7001`, colliding with active Community
Tile Pack even if PIE42 is removed and even when Dirkerdam stays disabled.

### Workshop Description Versus Payload Coordinates

Physical B42 `.lotheader` files are authoritative for compatibility. Workshop
descriptions can use legacy coordinates or drift from the downloadable payload.

| Mod | Description discrepancy | Authoritative payload result |
|---|---|---|
| Grapeseed (`2463499011`, `42Grapeseed`) | The B42 list includes `25x42` and `26x42` but omits `24x42`; it also lists `23x43` and `23x44`, which are absent from the current payload | Current Steam manifest and active copy contain `24_42`, `25_42`, and `26_42`; all three conflict with Greenleaf, and `24_42` also conflicts with Constown |
| Greenport (`3747595202`, `GreenportB42`) | Workshop text prints legacy four-cell coordinates | Current B42 POT payload contains nine physical cells, rectangle `31_28` through `33_30` |

Do not clear a recorded conflict from Workshop text alone. Re-download or inspect
the latest manifest, select the descriptor the game will load, and compare its
actual `.lotheader` filenames against the active ledger and every candidate being
considered in the same replacement set.

### Active Map-Metadata Companions With No Physical Cells

| Mod ID | Live folder | Role/dependency |
|---|---|---|
| `Authentic Z - Current` | `Authentic Z - Current` | Spawn/map metadata only |
| `DWAP` | `DWAP` | Safehouse overlay; requires `StarlitLibrary` |
| `DWAP_RavenCreek_Apts` | `DWAP_RavenCreek_Farm` | Raven Creek overlay; requires `RavenCreekB42` |
| `serellancustomspawn` | `SerellanCustomSpawn` | Custom spawn selector metadata |

### Missing-Buildings Incident And Packaging Repair (2026-07-19)

Fresh worlds spawned at Wildsteel and Little Town coordinates but showed
procedural forest instead of the compiled towns. This was not a cell conflict:
the saves' `map_ver.bin` files include the complete active map group, and the
authoritative physical cells remain clear in `MAP_MOD_CELLS.tsv`.

The cause was a partial same-token map override in each CJS tweaks project.
Build 42 maps the entire `media/maps/<token>` directory to the last loaded mod;
an override containing only `objects.lua` or `spawnpoints.lua` therefore hid
the target's lotheaders, lotpacks, and chunkdata. The following projects now
mirror their verified current Workshop target map directories while preserving
only their intended patched text files:

- `wildsteelCjsTweaks` (`f934211`, local repair commit)
- `littleTownCjsTweaks` (`5777e3d`, local repair commit)
- `blackpineCountyCjsTweaks` (`4f6af6d`, local repair commit)
- `begoniaTownCjsTweaks` (`7825c37`, local repair commit)
- `cathayaValleyCjsTweaks` (`d671e3c`, local repair commit)
- `fairhavenCjsTweaks` (`fd72760`, local repair commit)
- `raccoonCityCjsTweaks` (`71f316c`, local repair commit)

`rustBuryCjsTweaks` already carries a complete four-cell mirror and was not
modified during this repair because its repo contains pre-existing uncommitted
work. `.tools/pz-map-shadow-audit.sh` now rejects incomplete live-linked CJS map
overrides. `.tools/pz-map-cell-ledger.sh` keeps the mirrored cells attributed to
their third-party target so the patch is not misreported as a second map owner.
The regenerated ledger remains byte-for-byte unchanged: 1,669 rows, 1,661
distinct cells, and the same eight pre-existing conflict cells.

The failed worlds `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/Saves/Sandbox/2026-07-19_19-52-05`
and `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/Saves/Sandbox/2026-07-19_19-57-02` already contain
generated chunks at the affected coordinates. They were not edited or deleted;
use new worlds for verification.

All seven repair repos are clean after their local commits. Their regression
tests and Lua parse checks pass, and the shadow audit reports complete matching
lotheader/lotpack/chunkdata triads. These commits have not been pushed. Runtime
verification remains pending in new Wildsteel and Little Town worlds. The first
post-repair launch log confirms that Build 42 now resolves all four compiled
lotheader/lotpack/chunkdata triads from each of the Wildsteel and Little Town
tweaks directories, instead of resolving a partial directory.

## Requested Queue And Results

| Order | Workshop item/map | Status | Dependencies | Cell result | Comment/audit result | Tweaks repo | Install/review result |
|---:|---|---|---|---|---|---|---|
| 1 | Dawn Town (`3666180085`, `dawn_town`) | `INSTALLED_AND_REVIEWED` | Rocco's Tiles (`3666137359`, `Roccos_Tiles`); optional buildable companion was already active | Clear: B42 cells `11_31`, `11_32`, `12_31`, `12_32` | All 83 comments (Feb 14-Jun 27) reviewed; full payload/dependency audit completed | Private `pz-dawn-town-cjs-tweaks`; project/id `dawnTownCjsTweaks`; pushed at `3f58fc3` | Direct Workshop map copy plus project symlink; save/default/`b42-4` ordered once each; offline test and review gate pass |
| 2 | Haven Fall (`3728357493`, `HavenFall`) | `INSTALLED_AND_REVIEWED` | None required; three named vehicle mods are optional references and missing scripts fail safely | Clear: 16 B42 cells, `16_33` through `19_36` | All 88 comments reviewed; current payload, lotheaders, tiledefs, assets, Lua, room loot, and reported MP/render/power/performance issues audited | Private `pz-haven-fall-cjs-tweaks`; project/id `havenFallCjsTweaks`; pushed at `8c828b0` | Direct Workshop map copy plus project symlink; save/default/`b42-4` ordered once each; two offline tests and review gate pass |
| 3 | Maplewood (`3644794945`, `Maplewood`) | `INSTALLED_AND_REVIEWED` | None required; current page and `mod.info` declare no dependencies and the payload uses vanilla tiles only | Clear: B42 cells `31_32`, `31_33`, `32_32`, `32_33` | All 172 comments and all 39 pinned bug-thread posts reviewed; current payload, lotheaders, lotpacks, biome maps, zombie density, Lua, scripts, room/building metadata, and reported crashes/render/loot issues audited | Private `pz-maplewood-cjs-tweaks`; project/id `maplewoodCjsTweaks`; pushed at `2ff98a9` | Direct Workshop map copy plus project symlink; save/default/`b42-4` ordered once each; offline test and review gate pass |
| 4 | Blackpine County (`3565649631`, `BlackpineCounty`) | `INSTALLED_AND_REVIEWED` | Perts Party Tiles (`2837923608`, `PertsPartyTiles`); Melos Tiles for Miles (`2879745353`, `melos_tiles_for_miles_pack`); Project Seasons (`3412105017`, `Project_Seasons_B42`); compiled asset use also requires Community Tile Pack (`3628736763`, `UnofficialMappersCommunityTilePack`) and Erika's Tiles (`3346506593`, `Erikas_Tiles`) | Clear: 40 B42 cells, full rectangle `38_55` through `45_59` | All 73 comments and all 11 pinned bug-thread posts reviewed; current payload, lotheaders/lotpacks, room/building/spawn metadata, stairs, campfires, assets, dependencies, tiledefs, and reported issues audited | Private `pz-blackpine-county-cjs-tweaks`; project/id `blackpineCountyCjsTweaks`; pushed at `d9e1982` | Exact Workshop copies plus project symlink; save/default/`b42-4` ordered once each; two offline tests and review gate pass |
| 5 | Wildsteel (`3691773420`, `WILDSTEEL`) | `INSTALLED_AND_REVIEWED` | None required; current page and selected descriptor declare none, and the payload has no custom pack or tiledef | Clear: B42 cells `56_22`, `56_23`, `57_22`, `57_23` | All 46 comments and both discussion topics reviewed; current payload, lotheaders/lotpacks, room/building/spawn metadata, stairs, map objects, assets, and reported issues audited | Private `pz-wildsteel-cjs-tweaks`; project/id `wildsteelCjsTweaks`; pushed at `5b09135` | Direct Workshop map copy plus project symlink; save/default/`b42-4` ordered once each; three offline tests and review gate pass |
| 6 | Greenport (`3747595202`, `GreenportB42`) | `INCOMPATIBLE` | None required; Workshop API, page, and all selected descriptors declare none | Conflict: current nine-cell B42 POT payload overlaps active `PIE42` at `32_28` and `33_28` | All 25 comments and the sole three-reply discussion reviewed; current payload and reported ground-item, map-zone, stair/floor, map-UI, loot-map, asset, and MP issues audited | Not created because the conflicting candidate was not installed; proven findings are preserved below if the conflict is later resolved | Skipped: no live copy, tweaks symlink, load-list edit, backup, or ledger mutation |
| 7 | Begonia Town (`3736155379`, `Begonia_Town`) | `INSTALLED_AND_REVIEWED` | LiuDing Tiles (`3736154771`, `LiuDing_Tiles`) and already-active Rocco's Tiles (`3666137359`, `Roccos_Tiles`); no recursive dependencies | Clear: ten B42 cells, `44_29` through `48_30` | All 48 comments and the sole four-reply bug discussion reviewed; current payload, lotheaders/lotpacks, buildings/rooms, stairs, zones, animals, assets, Lua, and dependencies audited | Private `pz-begonia-town-cjs-tweaks` at `86952aa`; dependency-level private `pz-liu-ding-tiles-cjs-tweaks` at `1129d28` | Exact Workshop copies plus two project symlinks; save/default/`b42-4` ordered once each; three offline tests and review gate pass |
| 8 | Greenleaf (`3602388131`, `Greenleaf B42 version`) | `INCOMPATIBLE` | None required; current Workshop page and selected descriptor declare none | Conflict: current 12-cell POT payload overlaps active `42Grapeseed` at `24_42`, `25_42`, and `26_42`; `Constown42` also owns `24_42` | All 96 comments and the sole discussion reviewed; current payload, cells, lotheaders/lotpacks, rooms/buildings, zones, stairs, tiles, tiledef, scripts, Lua, and reported issues audited | Not created because the conflicting candidate was not installed; proven findings are preserved below if the conflict is later resolved | Skipped: no live copy, tweaks symlink, load-list edit, backup, or ledger mutation |
| 9 | Cathaya Valley (`3576150391`, `Cathaya Valley 2.0 B42 version`) | `INSTALLED_AND_REVIEWED` | Community Tile Pack (`3628736763`, `UnofficialMappersCommunityTilePack`), already active and byte-for-byte current; no recursive dependencies | Clear: core cells `28_49`, `28_50`, `28_51`, `29_49`, `29_50`, `29_51`; optional highway excluded because it overlaps the core at `29_49`-`29_51` | All 25 comments and the sole discussion reviewed; current core/highway payloads, lotheaders/lotpacks, buildings/rooms, zones, spawn metadata, stairs, assets, tiledefs, loot tables, and reported issues audited | Private `pz-cathaya-valley-cjs-tweaks`; functional commit pushed at `d7b514d`; local bytecode-ignore cleanup at `5549a66` awaits push authorization | Exact Workshop core copy plus project symlink; save/default/`b42-4` ordered once each; offline regression and review gate pass |
| 10 | Little Town (`3526415658`, `littletown`) | `INSTALLED_AND_REVIEWED` | None required; Workshop page and selected B42 descriptor declare none, and the POT payload uses current vanilla tiles only | Clear: B42 cells `50_43`, `50_44`, `51_43`, `51_44` | All 28 comments and all zero discussions reviewed; current payload, lotheaders/lotpacks, buildings/rooms, zones, spawn metadata, stairs, furniture grids, light switches, garage doors, assets, and reported issues audited | Private `pz-little-town-cjs-tweaks`; project/id `littleTownCjsTweaks`; pushed at `6fd71cf` | Exact Workshop copy plus project symlink; save/default/`b42-4` ordered once each; two offline tests and review gate pass |
| 11 | [B42] Dirkerdam (Standalone MP) (`3754852031`, `DirkerdamB42`) | `DEFERRED_PENDING_SP_UPDATE` | throttlekitty's tiles (`3754848589`, `tkTiles_01`); Dylan's tiles (`3754850359`, `DylansTiles`); Diederiks Tile Palooza (`3754850813`, `Diederiks Tile Palooza`); Perts Party Tiles (`2837923608`, `PertsPartyTiles`); no recursive dependencies; first three conflict with active Community Tile Pack | Conflict: 588 of the current 851 B42 cells overlap active `PIE42`; also overlaps Greenport in six cells and Green River in 39 cells if PIE42 is removed | All 28 comments and the sole three-reply discussion reviewed; current payload, binary triads, map/spawn metadata, world map, rooms, tiles, dependencies, and reported missing-city, spawn, and zombie-density issues audited | Not created because the current payload is a conflicting standalone-MP release; reassess the fresh payload after its planned single-player update | User chose Dirkerdam over Greenport/Green River, then deferred installation until the planned single-player update; no live copies, load-list edits, backup, or ledger mutation |
| 12 | [42.18+] RustBury (`3721711345`, `rustbury_2026_b42`) | `INSTALLED_AND_REVIEWED` | None required; Steam metadata and both selected descriptors declare none, and the payload has no custom pack or tiledef | Clear: B42 cells `35_49`, `35_50`, `36_49`, `36_50` | All 14 comments reviewed; current payload, lotheaders/lotpacks/chunkdata, buildings/rooms, zones, spawn metadata, stairs, assets, world-map data, and reported isolation/travel issue audited | Private `pz-rust-bury-cjs-tweaks`; project/id `rustBuryCjsTweaks`; pushed at `5e3262e` | Exact Workshop copy plus project symlink; save/default/`b42-4` ordered once each; offline regression and review gate pass |
| 13 | Green River (`3555893112`, `GreenRiver`) | `INCOMPATIBLE` | Erika's Tiles (`3346506593`, `Erikas_Tiles`); Melos Tiles for Miles (`2879745353`, `melos_tiles_for_miles_pack`); Perts Party Tiles (`2837923608`, `PertsPartyTiles`); all already active/current and none has recursive dependencies | Conflict: all 180 standalone cells, full rectangle `0_0` through `17_9`, overlap active `PIE42`; bundled Diederik/tk packs and tiledefs also collide with active Community Tile Pack | All 21 comments and the sole zero-reply bug discussion reviewed; current payload, binary triads, map/spawn/world-map metadata, rooms/buildings, zones, stairs, biomaps, tiles/assets, Lua, and the reported unbounded-map edge audited | Not created because the conflicting standalone candidate was not installed; proven findings are preserved below if the loadout changes | Skipped: no live copies, tweaks symlink, load-list edit, backup, or ledger mutation |
| 14 | Fairhaven - B42 (`3533512793`, `fairhavenmap`) | `INSTALLED_AND_REVIEWED` | None required; Workshop metadata, manifest, and selected descriptor declare none | Clear: B42 cells `41_51`, `41_52`, `42_51`, and `42_52` | All 24 comments and all zero discussions reviewed; current payload, Linux layout, binary triads, buildings/rooms, zones, spawn metadata, stairs, parking, assets, Lua, and reported map/spawn/vehicle/horde issues audited | Private `pz-fairhaven-cjs-tweaks`; project/id `fairhavenCjsTweaks`; pushed at `792606d` | Exact current Workshop files with path-only lowercase `common` normalization plus project symlink; save/default/`b42-4` ordered once each; offline regressions and review gate pass |
| 15 | Raccoon City (`3388468313`, `RaccoonCityB42`) | `INSTALLED_AND_REVIEWED` | None required; Steam metadata and both selected descriptors declare none, and the payload's custom packs/tiledef are self-contained | Clear: 12 B42 cells, `38_38` through `40_41` | Newest 300 of 407 comments plus all six discussions reviewed; current payload, binary map data, zones, rooms/buildings, spawns, assets, Lua, scripts, distributions, vehicle state, audio, puzzle, and reported issues audited | Private `pz-raccoon-city-cjs-tweaks`; project/id `raccoonCityCjsTweaks`; pushed at `8c71e55` | Exact Workshop copy plus project symlink; save/default/`b42-4` ordered once each; map/runtime regressions and review gate pass |

## Blockers And Decisions

- The baseline contains eight confirmed cross-mod `.lotheader` overlaps, listed
  above and row-by-row in `MAP_MOD_CELLS.tsv`. Do not assume an overlap is safe
  because both mods are already enabled.
- Do not remove, reorder, or replace an existing active map merely to clear a
  baseline conflict without first recording the save impact and obtaining user
  direction.
- The pre-rollout recovery snapshot is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-dawn-town-preinstall`;
  it contains the complete active save and the three active load-list files.
- Dawn Town's Workshop description uses legacy 300-square cell `10_27`; its
  current Build 42 POT payload correctly spans four 256-square lot cells. None
  overlap another active map mod and none had generated save data before install.
- Dawn Town comments reported entry freezes, furniture limitations, and alleged
  loot-respawn failure. Static review found no stack trace or asset defect for
  the density-related freeze, current Rocco tile definitions already make the
  relevant furniture movable/scrappable, and B42 biomaps affect biome/foraging
  zones rather than container loot respawn. The separate tweaks mod fixes the
  proven Rocco water-dispenser action defects used by the map; entering the town
  and exercising take/add-bottle actions remain explicit in-game checks because
  the game was not launched.
- Haven Fall's current B42 payload occupies `16_33` through `19_36`; all 16
  cells are clear and had no active-save footprint before installation. Its
  page lists no required Workshop items and `mod.info` has no `require=` line.
- All 88 Haven Fall comments were reviewed. The repeated Linux multiplayer
  report is current: upstream ships `HavenFallBiomemap.lua` while Build 42
  lowercases shared-Lua virtual paths for its checksum/load list. The separate
  tweaks mod supplies the lowercase override with idempotent map registration.
  It also maps 27 invalid non-empty compiled room names to existing vanilla
  room distributions, restoring room-specific initial loot and loot respawn.
- The current 16 Haven Fall lotheaders have no duplicate room meta IDs; every
  custom tile sheet referenced by the map exists, all 16 biomaps are present,
  and tiledef number `3344` is unique among active mods. The north farmhouse's
  upper electrical sprites are covered by valid room rectangles, so no forced
  power mutation was justified. The unlocated stone-arch occlusion and dense
  center-city performance reports remain explicit in-game checks; broad sprite
  or coordinate mutations would be speculative. Project Zomboid was not
  launched.
- Haven Fall's incremental pre-install load-list backup is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-haven-fall-preinstall`.
- Maplewood's current B42 payload occupies `31_32`, `31_33`, `32_32`, and
  `32_33`. All four cells were clear in the cumulative ledger and had no
  generated footprint in the active save before installation. The pinned
  conflict list names Little Township, Dustwell, and Oakshire as incompatible;
  Willowbrook Bastion's current B42 cells are elsewhere and its author now
  lists Maplewood as compatible. The queued Littletown candidate will receive
  its own current-payload comparison when reached.
- All 172 ordinary Maplewood comments and all 39 pinned bug-thread posts were
  reviewed. The February 16 Workshop update removed the animal path at the
  church crash location and the current carpet squares at `8234,8514` and
  `8235,8515` contain solid floor tiles. All four lotheaders parse with no
  duplicate room meta IDs, all four biomaps exist, and zombie-density metadata
  is populated rather than empty.
- Maplewood's gym, changing rooms, and a room named `hunting` are compiled into
  one building. Build 42's `forceForRooms` algorithm therefore selects
  `HuntingLockers` for all eight upstairs changing-room lockers. The separate
  tweaks mod replaces only those initial rolls, at the two exact four-locker
  rows, with vanilla `GymLockers`; its offline targeting test passes.
- The police station's roof/interior failure remains a required multiplayer
  unload/reload check. Current reports are reproducible after leaving and
  re-entering the area, but the static payload has complete multi-level room
  and roof geometry. The reported non-sequential building-ID log reflects the
  Build 42 loader appending a layered map's buildings after existing cell data
  while retaining each file-local ID; mutating every room/building ID and live
  lookup map from Lua would be broader and riskier than the evidence supports.
  The July autosave report names unknown biome zone `65`, but the referenced
  engine path only logs and skips an unknown zone and the report provides no
  crash stack. Upstream biome PNG rewriting was not justified. Project
  Zomboid was not launched.
- Maplewood's incremental pre-install load-list backup is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-maplewood-preinstall`.
- Blackpine County's current Build 42 payload occupies all 40 cells in the
  rectangle from `38_55` through `45_59`. Every cell was clear against the
  cumulative ledger and the active save had no generated footprint in that
  range before installation. The ledger remains at the same eight baseline
  conflicts after activation.
- Blackpine declares Perts Party Tiles, Melos Tiles for Miles, and Project
  Seasons. Its compiled sprite use additionally proves two omitted dependencies:
  Community Tile Pack supplies Dylan and Blackwood sheets, and Erika's Tiles
  supplies the `*_erika_*` sheets. Only the full B42 Project Seasons child is
  installed; its mutually incompatible Lite, No Rust, and B41 siblings are not.
  All 31 active tiledef numbers are unique.
- All 73 Blackpine comments and all 11 pinned bug-thread posts were reviewed.
  The current payload still contains an outdoor profession spawn at
  `10413,14161,0`, three unsafe stair destinations, a solid boiler blocking the
  roof stair at `11377,14915,4`, and eleven pre-lit or smouldering campfires.
  The separate tweaks mod moves all 23 invalid spawn records to the existing
  bedroom at `10410,14161,0`, restores only the three exact landing floors,
  removes only the blocking boiler, and converts only the eleven compiled fire
  objects into functional extinguished campfires before vanilla initializes
  them. Both offline tests pass from the live symlink.
- After all five dependencies are considered, Blackpine still references 249
  mapper/removal-era sprite names at 654 placements that are absent from known
  Build 42 tile definitions. The historical source pack needed for exact
  restoration is not locally available, so guessed or redistributed visual
  replacements were rejected. The map also has no biome maps. Basement-trap
  and southern-railroad world-map reports lack exact evidence for a bounded
  fix. These remain in-game/upstream validation items; Project Zomboid was not
  launched.
- Blackpine's author marks Fairhaven incompatible. Blackpine itself was clear
  and therefore installed; Fairhaven will receive an exact current-payload cell
  comparison when it reaches the queue and will be marked `INCOMPATIBLE` if it
  overlaps.
- Blackpine County's full incremental pre-install backup is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-blackpine-county-preinstall`.
- Wildsteel's current B42 payload occupies `56_22`, `56_23`, `57_22`, and
  `57_23`. All four cells were clear against the cumulative ledger and the
  active save had no generated metacell, chunkdata, zombie-population, or other
  named footprint in them before installation. The page and selected descriptor
  declare no dependencies, and the payload contains no custom texture pack or
  tiledef.
- All 46 Wildsteel comments and both discussion topics were reviewed. The
  current payload proves that all 29 profession spawns and the map SpawnPoint
  object target an outdoor square with no room/building at `14445,5755,0`; the
  separate tweaks mod moves only those records to the nearest compiled bedroom
  at `14441,5740,0`. Its two source overrides match the current Workshop files
  except for those coordinates and record the upstream SHA-256 values.
- Wildsteel's compiled cabin has a solid wall on the bathroom-door edge at
  `14437,5738,0`, nine garage-door segments have co-located matching-edge wall
  records, and the military storage office has six exact level-one floor holes.
  The tweaks mod removes only those ten bounded wall records and restores only
  the six missing floor squares, idempotently. It also aliases seventeen
  malformed compiled room names to existing vanilla room distributions without
  altering items, rolls, weights, or EasyDistro multipliers. All three offline
  tests pass from the live project symlink.
- The selected Wildsteel `42.0/mod.info` concatenates its `versionMin` and title
  text, but Build 42's version parser still accepts the value as major 42,
  minor 0; a separate patch cannot override the target descriptor. All four
  lotheaders have unique room metadata IDs, and all 68 top-stair destinations
  have a solid floor or continuing stair.
- Wildsteel still references 336 legacy/editor sprite names at 1,352 placements
  that are absent from current known Build 42 tile definitions, in addition to the
  engine/editor ceiling placeholder. No owned exact historical source pack is
  available, so visual replacements were not guessed or redistributed. The
  payload also has no biome maps. The current report of repeated errors while
  traveling the south road has no stack trace or coordinates, and the static
  road/zone/world-map data is present and parseable; it remains an explicit
  in-game multiplayer check. Project Zomboid was not launched.
- Wildsteel's full incremental pre-install backup is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-wildsteel-preinstall`.
- Greenport resolves to Workshop item `3747595202`, display name `Greenport,
  KY (B42)`, mod ID `GreenportB42`, and map folder `Greenport, KY`. Its current
  cache was refreshed on July 19 from the July 11 Workshop update. The page and
  all selected descriptors declare no dependencies, texture packs, or tiledefs.
- Greenport's current B42 POT payload occupies nine cells, the full rectangle
  `31_28` through `33_30`, rather than the legacy four-cell coordinates printed
  in its Workshop description. Cells `32_28` and `33_28` are already owned by
  active `PIE42` in map folder `PIElots`. `PIE42` is Project Indiana Expansion,
  which directly explains the July 19 comment reporting that a hosted game
  terminates when Greenport and Indiana Expansion are combined. Greenport is
  therefore `INCOMPATIBLE`; it was not copied live, enabled, or added to the
  ledger, and cumulative totals remain unchanged after Wildsteel.
- All 25 Greenport comments and its sole three-reply discussion were reviewed.
  The July 11 update fixed the immediate ground-item duplication causes by
  searching special objects and comparing normalized full item types. The
  author then confirmed against that current update that scripted items still
  respawn after leaving and returning to the chunk/cell, so persistence remains
  a current defect.
- Greenport's current `objects.lua` contains 55 `WaterZone` records with none of
  the `WaterGround`/`WaterShore` properties required by Build 42, plus one
  `Mannequin` record with no required properties. The current engine therefore
  logs and skips all 56 records. Static geometry review also found one upper
  stair destination at `8602,7584,1` with only a legacy carpet sprite and no
  solid-floor property; it is in the `greenportarcade` building. The reported
  hunting-store upper-floor cutaway failure could not be bounded to a distinct
  safe static mutation.
- Greenport's lootable-map definition requests nonexistent directory
  `media/maps/GreenportB42` instead of the shipped `media/maps/Greenport, KY`.
  Its nine lotheaders otherwise parse with no duplicate room metadata IDs, all
  nine biomaps are present, and no garage-door obstruction was found. The map
  references 144 sprite names at 11,838 placements that are absent from current
  vanilla and all locally available mod tile definitions, dominated by legacy
  tree/ceiling/editor sprites. No undeclared dependency supplying them was found.
- A separate `pz-greenport-cjs-tweaks` repo was deliberately not created: the
  map is ineligible for this active set regardless of code fixes, and the user
  directed the rollout to mark overlaps incompatible and continue. These proven
  findings are retained here so a tweaks project can be created if `PIE42` is
  ever removed through a separate save-impact decision. Project Zomboid was not
  launched and no Greenport backup was needed because no live state changed.
- Begonia Town resolves to Workshop item `3736155379`, mod ID and map token
  `Begonia_Town`. Its current B42 payload occupies ten cells: `44_29`, `44_30`,
  `45_29`, `45_30`, `46_29`, `46_30`, `47_29`, `47_30`, `48_29`, and `48_30`.
  All ten were clear against the cumulative ledger and had no named metacell,
  chunkdata, zombie-population, map-chunk, or isoregion footprint in the active
  save before installation.
- Begonia requires LiuDing Tiles (`3736154771`, `LiuDing_Tiles`) and Rocco's
  Tiles (`3666137359`, `Roccos_Tiles`). Rocco was already active and exact.
  LiuDing has no recursive dependencies, its tiledef number `1995` is unique
  among active mods, both server Lua files compile, and the direct live copy is
  byte-for-byte current Workshop. Begonia uses `LiuDing_Tiles_3DItem_0` exactly
  once, at `11984,7756,-1`.
- LiuDing's current 3D-item Lua passes a string timer ID to
  `Events.OnTick.Remove`, but Build 42's `zombie.Lua.Event` bridge only accepts the
  original Lua closure. The resulting offset callback therefore survives every
  later tick. The separate dependency-level `liuDingTilesCjsTweaks` override
  preserves the upstream conversion and removes both one-shot callbacks by
  their retained closures. Its private repo `pz-liu-ding-tiles-cjs-tweaks` is
  pushed at `1129d28`; its regression and CRLF-aware review pass.
- All 48 Begonia comments and the sole four-reply bug discussion were reviewed.
  The June 4 loot-respawn report remains current and the author confirmed that
  loot zones had not been created. Begonia's `objects.lua` contains 230 parking
  stalls, four Ranch records, one SpawnPoint, and 42 ZombiesType records, but no
  `TownZone`, `TownZones`, or `TrailerPark`. Build 42 loot respawn requires one of
  those zone types, so the inherited Muldraugh forest zones prevent refill.
- The separate `begoniaTownCjsTweaks` map override preserves every upstream map
  object and appends 345 disjoint `TownZone` rectangles covering the exact x/y
  union of all 24,642 compiled building-room squares. It also restores a solid
  magenta carpet floor only at `11980,7519,1`, the unsafe destination of the
  west-facing top stair at `11981,7519,0`. The private repo
  `pz-begonia-town-cjs-tweaks` is pushed at `86952aa`; both regressions, Lua
  syntax, packaging, source-delta, live-link, and post-install review pass.
- Begonia's four Ranch records use current vanilla names and dimensions,
  including `cowlarge`, so intermittent animal appearance did not justify a
  mutation. The reported police station is one compiled building with complete
  basement, ground, upper-floor, and roof room metadata; all ten lotheaders have
  unique room meta IDs. Its roof/cutaway report remains an explicit unload and
  reload check rather than a guessed metadata rewrite.
- After current vanilla, LiuDing, and Rocco definitions are combined, Begonia
  still references 1,658 unavailable sprite names at 14,458 placements. No
  exact owned source pack was found, so replacements were not guessed or
  redistributed. The payload also has no biome maps. Project Zomboid was not
  launched; loot respawn, the stair, the one 3D-item conversion, animals, and
  police roof/cutaway behavior remain explicit single-player/multiplayer checks.
- Begonia Town's full incremental pre-install backup is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-begonia-town-preinstall`.
- Greenleaf resolves to Workshop item `3602388131`, display name and mod ID
  `Greenleaf B42 version`, and map folder `Greenleaf`. Its refreshed current
  Workshop payload occupies 12 cells: the rectangle `24_39` through `26_42`.
  It has no declared or compiled external dependency; its own tiledef number
  `4876` is unique among the 33 active-plus-candidate tiledef numbers.
- Greenleaf conflicts with active `42Grapeseed` at `24_42`, `25_42`, and
  `26_42`; `Constown42` also owns `24_42`. Workshop comments and the author
  acknowledge these same edge overlaps and call them harmless forest cells,
  but the rollout invariant prohibits any candidate from overriding another
  map's cell regardless of apparent contents or load order. Greenleaf is
  therefore `INCOMPATIBLE` and was not copied, enabled, or added to the ledger.
  Totals remain 1,639 ownership rows, 1,631 distinct cells, and the same eight
  pre-existing conflict cells.
- All 96 Greenleaf comments and the sole zero-reply Worldgen Errors discussion
  were reviewed. Current reports include failed loot respawn, invisible
  furniture, roof/cutaway defects, a world-map gap, sparse zombies, and a July
  duplicate-room warning. The current 12 lotheaders parse with no duplicate
  room meta IDs; the exact reported square `6784,10293` belongs to a normal
  ground-floor bathroom room record. The discussion's non-sequential building
  IDs are consistent with layered-map loading and do not justify rewriting
  compiled IDs.
- The loot-respawn report has a current structural cause, although the claim
  that it is caused by missing biome maps is incomplete. Greenleaf does define
  48 rectangular and one polygonal `TownZone`, but they cover only 14,619 of
  25,177 unique compiled building-room x/y squares; 10,558 building squares are
  outside every `TownZone`, `TownZones`, or `TrailerPark` loot-respawn zone.
  The payload has no biome maps, but those govern biome/foraging behavior rather
  than container refill eligibility.
- Static payload review found all 108 top-stair destinations supported by a
  solid floor or continuing stair. Current vanilla plus Greenleaf's tiledef
  resolves 5,313 of 5,317 distinct compiled sprite names; the only four missing
  one-use names are `bed_overlays_large_4` through `bed_overlays_large_7`, not
  the reported invisible tables/desks. The backpack's B42 `ItemType =
  base:Container` form resolves through the current resource-location item-type
  registry, and all seven Lua/map scripts compile, so neither warranted a
  speculative fix. The multiline `map.info` does contain two bare unknown lines
  after `description=`, a current metadata defect that a separate layer cannot
  safely replace.
- A separate `pz-greenleaf-cjs-tweaks` repo was deliberately not created: the
  map is ineligible for this active set regardless of code fixes, and the user
  directed the rollout to mark overlaps incompatible and continue. The zone,
  metadata, and unresolved visual reports are retained here for a future
  loadout where Grapeseed and Constown are absent. Project Zomboid was not
  launched and no Greenleaf backup was needed because no live state changed.
- Cathaya Valley resolves to Workshop item `3576150391`, mod ID `Cathaya
  Valley 2.0 B42 version`, and map folder `Cathaya Valley2.0`. The current April
  11 payload's six core POT cells are `28_49`, `28_50`, `28_51`, `29_49`,
  `29_50`, and `29_51`; all were clear and had no metacell, zombie-population,
  map-chunk, chunkdata, or isoregion footprint in the active save.
- The item also contains optional mod `Cathaya Valley 2.0 B42 version highway`,
  which claims `29_48` through `30_51` and overlaps the core at `29_49`,
  `29_50`, and `29_51`. The author describes it as selectively enabled, not a
  dependency. It was excluded so no physical map layer overrides another map.
- Cathaya requires Community Tile Pack (`3628736763`,
  `UnofficialMappersCommunityTilePack`), which was already active for Blackpine,
  has no recursive dependency, and remains byte-for-byte equal to the current
  Workshop payload. Cathaya's own tiledef number `745` is unique among the 33
  active-plus-candidate tiledef numbers.
- All 25 Cathaya comments and the sole zero-reply Spawnpoint Error discussion
  were reviewed. The discussion proves that the shared spawn at `7330,12849,0`
  has no room/building; current static data shows only natural ground and fence
  there. The separate tweaks map overrides move that one object and all 29
  profession-list occurrences to unobstructed armystorage square
  `7294,12849,0`.
- The loot-respawn question also exposed incomplete current zoning. Cathaya's
  14 rectangular and one polygonal `TownZone` cover 12,413 of 14,119 unique
  compiled building-room x/y squares. The tweaks override appends 31 disjoint
  rectangles covering exactly the other 1,706 squares; the combined live
  override reports zero uncovered building squares.
- The current core has six parseable lotheaders with no duplicate room meta
  IDs, all 55 top-stair destinations supported, no garage-door obstruction,
  and all Lua files syntactically valid. After current vanilla, Cathaya, and
  Community Tile Pack definitions are combined, 45 legacy/editor sprite names
  at 4,140 placements remain unavailable, dominated by one removed jumbo-tree
  name and mapper roof/wall variants. No missing current Cathaya custom sprite
  or exact invisible speed-bump target was found, so the February collision
  report remains an in-game travel check rather than a guessed removal.
- The reported balcony/roof indoor classification lacks coordinates and cannot
  be safely corrected by rewriting compiled building metadata broadly. Three
  custom direct `SuburbsDistributions` tables also reference four nonexistent
  Build 42 Base items: `Elixir`, `Cutlass`, `Flares`, and `Flare gun`. Only
  `Cutlass` has a plausible current analogue, so the tweaks project documents
  these entries instead of inventing replacements and changing authored loot
  balance. The payload has no biome maps; those affect biome/foraging metadata,
  not the container-respawn zoning fixed here.
- Private repo `pz-cathaya-valley-cjs-tweaks` has its functional project commit
  pushed at `d7b514d`; local HEAD `5549a66` only deletes accidentally tracked
  generated Python bytecode and adds ignore rules. The external-action guard
  rejected that cleanup push, so it was not retried. The live project symlink
  uses the clean local HEAD. Target and tweaks occur exactly once and in order
  in the save, default list, and `b42-4`; the optional highway occurs zero times.
  Regression, Lua syntax, source-delta, live-link, dependency, exact-copy,
  ledger, and post-install review checks pass. Project Zomboid was not launched.
- Cathaya Valley's full incremental pre-install backup is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-cathaya-valley-preinstall`.
- The requested Littletown resolves to the exact title match Little Town - B42,
  Workshop item `3526415658`, mod ID and map token `littletown`, rather than the
  similarly named LittleTownship B42 item. The latter overlaps active Maplewood;
  the selected Little Town payload occupies only `50_43`, `50_44`, `51_43`, and
  `51_44`. All four cells were clear and had no generated map, chunkdata,
  population, or isoregion footprint in the active save. The only matching
  metacell was a one-byte empty sentinel outside the candidate's physical cell
  interpretation, so no save data was reset.
- Little Town declares no dependencies and has no custom pack or tiledef. Its
  four current POT lotheaders/lotpacks contain 102,467 non-empty squares and
  2,769 distinct sprite names. All sprite names resolve against Build 42 vanilla,
  all 30 top-stair destinations have solid support, no duplicate room metadata
  IDs were found, both spawn points resolve to solid interior rooms, and all
  map metadata literals parse. The payload has no biome maps.
- All 28 Workshop comments and all zero discussions were reviewed. A July 2025
  white-house report identifies overlapping beds and was acknowledged by the
  author without a later payload update; a separate October report identifies
  buildings without light switches. Current compiled content confirms three
  malformed four-piece Large Oak grids, including that southeast upstairs
  white-house room, and 21 buildings without usable switch coverage.
- The private `pz-little-town-cjs-tweaks` project at pushed commit `6fd71cf`
  repairs the three bed grids with eight exact sprite substitutions, adds 75
  room switches at statically validated wall positions, and removes three exact
  `location_restaurant_pizzawhirled_01_1` wall objects obstructing an operable
  garage door at `12993..12995,11191,0`. Two mechanic-complex `bathroom`
  metadata strips were deliberately excluded because they are physically open
  bay/street lanes and have no valid wall attachment.
- Little Town's original map objects leave 681 of 7,683 unique compiled
  building-room x/y squares outside its loot-respawn zones. The tweaks map
  override appends 19 disjoint `TownZone` rectangles covering exactly those
  681 squares and preserves a reconstructable byte-exact upstream source.
  The 134 apparent floor holes from the broad audit were classified as wall
  edges, stair voids, railings/atria, roofs, or `emptyoutside` squares; no
  unsupported traversable landing was found.
- Little Town is installed as a byte-identical direct Workshop copy and its
  tweaks project is a live symlink. Target and tweak IDs occur exactly once and
  in order in the save, default list, and `b42-4`. Python/Lua regression tests,
  Lua syntax, Java-bridge API verification, source reconstruction, live-link,
  direct-copy, load-list, ledger, and post-install review checks pass. The
  latest console predates this install, so the repaired beds, light switching,
  garage traversal, loot respawn, and SP/MP travel remain explicit in-game
  checks. Project Zomboid was not launched.
- Little Town's full incremental pre-install backup is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-little-town-preinstall`.
- The requested Dierkerdam resolves to the current B42 conversion [B42]
  Dirkerdam (Standalone MP), Workshop item `3754852031`, mod ID
  `DirkerdamB42`, and primary map token `Dirkerdam`. Its July 6 current cache
  manifest `4491090971850047494` matches Steam's latest manifest metadata.
  Steam currently marks the item removed/incompatible and the cached payload is
  therefore the only verified source available to this account.
- Dirkerdam claims every cell in the 37-by-23 rectangle `5_7` through `41_29`,
  totaling 851 cells. It intersects active `PIE42` in 588 cells: `x=5..16,
  y=7..21`; `x=17..19,y=7..20`; `x=20..29,y=7..19`; `x=30..31,y=7..26`;
  `x=32..35,y=7..28`; and `x=36..41,y=7..24`. The overlap invariant makes
  Dirkerdam `INCOMPATIBLE` regardless of load order, so it and its dependencies
  were not copied, enabled, or added to the ledger.
- Required dependencies resolve to throttlekitty's tiles (`3754848589`,
  `tkTiles_01`), Dylan's tiles (`3754850359`, `DylansTiles`), Diederiks Tile
  Palooza (`3754850813`, `Diederiks Tile Palooza`), and already-active Perts
  Party Tiles (`2837923608`, `PertsPartyTiles`); none declares a recursive
  dependency. The first three also reuse tiledef numbers `830`, `6985`, and
  `7001` and pack names already provided by active Community Tile Pack. Dylan's
  pack and all three tiledefs differ by hash, so enabling both dependency sets
  would introduce an additional asset/tiledef collision in this loadout.
- All 28 Dirkerdam comments and the sole three-reply heatmap discussion were
  reviewed. The July 2 missing-downtown report predates the July 6 update that
  added missing cells; the current payload has a complete lotheader, lotpack,
  and chunkdata triad for all 851 cells. All six map descriptors contain valid
  literals, both world-map XML forms exist and the source XML parses, and all
  eight spawn/map Lua files compile.
- The spawn complaints mix single-player use with an explicitly standalone MP
  item. The author states that single-player and vanilla-connected ports are
  future work, while a July 10 user confirms dedicated Build 42 operation. The
  current five spawn lists contain 118 syntactically valid non-empty target
  squares; 104 lie in compiled rooms and 14 are outdoor or unroomed floor
  points. This does not make the mod suitable for the active vanilla
  single-player save, whose map group it intentionally does not extend.
- The July 5 zombie-crash report was followed by the author's July 6 heatmap
  adjustment. A July 10 follow-up still measured city intensities of 12-24 per
  chunk versus 1-7 in dense vanilla areas, but also reported normal population
  as fine and tied the severe behavior to a six-to-eight-times multiplier. A
  balance rewrite was not justified for an ineligible map.
- Static POT review parsed 34,114,488 non-empty squares, 59,496,973 tile uses,
  and 13,432 distinct sprite names. It found four duplicate room meta IDs in
  `31_13` and 15 unresolved sprite names at 1,556,952 uses; 1,556,910 uses are
  the removed legacy `jumbo_tree_01_0`, with 42 uses spread across unfinished
  construction and one-off sign sprites. These findings would require a
  dedicated compatibility pass if Dirkerdam were ever moved to a non-PIE,
  standalone-MP loadout.
- No `pz-dirkerdam-cjs-tweaks` repo was created because neither a tweak nor load
  order can resolve 588 physical cell overrides, the required tile packs also
  collide with active Community Tile Pack, and this release targets a different
  standalone multiplayer world mode. No live state changed, no backup was
  needed, and the ledger remains at 1,649 rows / 1,641 unique cells / the same
  eight pre-existing conflicts. Project Zomboid was not launched.
- A later direct candidate-to-candidate comparison established that removing
  PIE42 would still not permit all three replacement maps together. Dirkerdam
  overlaps Greenport in six cells (`31_28`, `31_29`, `32_28`, `32_29`,
  `33_28`, and `33_29`) and Green River in the 39-cell rectangle `5_7` through
  `17_9`. Greenport and Green River do not overlap each other. The user preferred
  Dirkerdam over the other two, then decided on 2026-07-19 to defer it until the
  author releases the planned single-player update. PIE42 and all active load
  lists remain unchanged; no candidate or dependency was installed.
- The requested RustBury resolves to Workshop item `3721711345`, exact display
  name `[42.18+] RustBury`, mod ID `rustbury_2026_b42`, and map token
  `RustBury`. The exact current May 8 payload is Steam manifest
  `1301851528570221230`, 2,927,193 bytes, and both its `42` and `common`
  descriptors are identical. Steam metadata and the payload declare no
  dependencies, custom texture packs, or tiledefs.
- RustBury occupies `35_49`, `35_50`, `36_49`, and `36_50`. All four cells were
  clear in the cumulative ledger and the active save had no target physical-cell
  footprint in `map`, `isoregiondata`, `chunkdata`, `zpop`, `apop`, or
  `metagrid` before installation. The check uses B42's 32-by-32 chunk span per
  256-square map cell, not the obsolete 30-chunk interpretation.
- All 14 Workshop comments were reviewed. The sole negative report says that
  the map has no connection and cannot be left, while the author and page
  explain that the town is deliberately isolated and its northeastern dirt
  path requires chopping trees. The current profession spawn at
  `9201,12736,3` is a solid bedroom floor, so no spawn correction was justified.
  The static payload supports the intended hidden-forest design rather than a
  broken road or invalid-spawn defect.
- All four cells contain complete lotheader, lotpack, and chunkdata triads. The
  audit parsed 116,699 non-empty squares, 260,274 tile uses, and 4,288 distinct
  sprite names with no duplicate room metadata IDs. Map metadata and Lua parse,
  compiled and source world-map files are present, the 300-by-300 biome map is
  valid, and all 48 top-stair destinations have solid support.
- Current map objects contain 18 valid authored zone records but leave 2,217 of
  11,287 unique compiled building-room x/y squares outside a loot-respawn zone.
  The private `pz-rust-bury-cjs-tweaks` project at pushed commit `5e3262e`
  preserves the exact upstream `objects.lua` (SHA-256
  `ed4be92e34ed4bd19f5481b337df333684adb8c75cd9fdd843a5b3d4db8a3d49`) and
  appends 50 disjoint `TownZone` rectangles covering exactly those 2,217
  squares. The combined override covers all 11,287 building squares, and its
  reconstruction and targeting tests plus Lua syntax pass.
- RustBury references 27 unavailable vanilla/removal-era sprite names at 1,237
  placements; 987 are the removed `jumbo_tree_01_0`, and the remainder are
  floor grime, an animated clock, natural test tiles, and one-off signs. No
  declared or identifiable dependency supplies them, so replacements were not
  guessed. Five default garage-door warnings resolve to authored semi-trailer
  cargo/back sprites rather than building entrances. The broad upper-floor-hole
  results resolve almost entirely to authored `empty` voids, plus bounded
  wall/railing strips; none is an unsafe stair destination, so no geometry
  mutation was justified.
- RustBury is installed as a byte-identical direct copy of manifest
  `1301851528570221230`; `rustBuryCjsTweaks` is a live symlink to the clean
  private project. Target and tweak occur exactly once and adjacently in the
  active save, default list, and `b42-4`. The full pre-install backup is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-rustbury-preinstall`.
  Source/live comparison, project/link/repo state, load-order, backup delta,
  ledger, syntax/tests, and the post-change review gate pass with no findings.
  The latest console predates installation; loot respawn after its configured
  interval, northeastern travel, and multiplayer spawn behavior remain explicit
  in-game checks. Project Zomboid was not launched.
- Green River resolves to Workshop item `3555893112`, exact title `Green River`,
  mod ID and map token `GreenRiver`, and current April 16 manifest
  `4066934487600945827` (267,910,018 bytes). The cache manifest matches Steam's
  current API metadata. Its identical `42` and `common` descriptors and its
  `map.info` confirm that this is a standalone world rather than an addition to
  the vanilla map. Steam currently marks the item removed and incompatible.
- The selected B42 payload claims all 180 physical cells in the full rectangle
  `0_0` through `17_9`. Every one is already owned by active `PIE42`, so Green
  River is `INCOMPATIBLE` under the rollout's no-override invariant. It was not
  copied live, enabled, added to the ledger, or allowed to displace Project
  Indiana Expansion; totals remain 1,653 rows / 1,645 unique cells / the same
  eight pre-existing conflicts.
- Green River requires current Erika's Tiles (`3346506593`, `Erikas_Tiles`),
  Melos Tiles for Miles (`2879745353`, `melos_tiles_for_miles_pack`), and Perts
  Party Tiles (`2837923608`, `PertsPartyTiles`). All three are already active,
  byte-for-byte current Workshop copies and have no recursive dependencies.
  Green River also bundles `diederiks_tile_palooza` and `tkTiles_01` under
  tiledef numbers `7001` and `830`. Active Community Tile Pack owns the same
  pack names and numbers; both texture packs match, but both tile-definition
  binaries differ, creating a second load-order/asset collision if Green River
  were enabled in this active set.
- All 21 current comments and the sole zero-reply Bug Reports discussion were
  reviewed. Two users report successful long single-player play and B42.13.2
  single-/multiplayer operation. Most requests ask for a bridge to the vanilla
  map, while the author reiterates that the project was intentionally designed
  as standalone. The only authored known bug is that the map has no boundary
  and continues into endless forest; this remains current in the April payload
  and would require a deliberate standalone-world boundary design rather than
  a narrow compatibility edit.
- The current payload has a complete lotheader, lotpack, and chunkdata triad for
  every one of its 180 cells. Static POT review parsed 11,039,763 non-empty
  squares, 18,757,452 tile uses, 6,617 used sprite names, 6,259 rooms, and 1,331
  buildings. Building-room membership is internally valid. All 180 B42 biomaps
  are valid 256-by-256 images, both source world-map XML files parse and have
  compiled binaries, all five Lua files compile, and all 623 top-stair
  destinations have a solid floor or continuing stair.
- All seven unique spawn targets (175 profession-list records) are present in
  `objects.lua` and have solid floors; six are compiled living rooms and the
  fire-officer-only target is an authored outdoor road square. The negative
  local `posY` used for one target still resolves through Build 42's verified
  300-square spawn-coordinate formula to the valid global square `835,591,0`,
  so it is not a spawn defect.
- Green River's declared dependencies leave 182 used sprite names without a
  matching current tile definition at 96,171 placements. Active Community Tile
  Pack incidentally supplies 142 Dylan-prefixed names at 3,360 placements, but
  Green River does not declare that pack; even with it active, 40 names at
  92,811 placements remain unresolved, dominated by the removed
  `jumbo_tree_01_0` (92,493) plus 318 Simon MD/editor and overlay placements.
  Replacements were not guessed or redistributed.
- The 1,398 map-object records are syntactically valid, but only nine
  `TownZone` polygons cover 38,900 of 108,512 unique compiled building-room x/y
  squares; 69,612 building squares are outside a container-loot-respawn zone.
  No current comment reports this behavior, and balance intent cannot be
  separated from the standalone layout without in-game evidence. It is retained
  with the boundary and tile findings for a future non-PIE standalone loadout.
- No `pz-green-river-cjs-tweaks` repo was created because no tweak or load order
  can resolve 180 physical overrides, the bundled tiledefs separately collide
  with an active tile pack, and Steam already marks the item incompatible. No
  live state changed, no backup was needed, and Project Zomboid was not launched.
- Fairhaven resolves to Workshop item `3533512793`, exact title `Fairhaven -
  B42`, mod ID `fairhavenmap`, and map token `greenwood`. Steam's current
  manifest `1293595142229680414` is 2,314,999 bytes and was published July 24,
  2025. The item and selected descriptor declare no dependencies. Steam now
  marks the item removed/incompatible, but anonymous SteamCMD downloaded that
  exact latest manifest during this rollout.
- Its four cells, `41_51`, `41_52`, `42_51`, and `42_52`, are clear against
  every active ledger owner and had no map, metagrid, chunkdata, zombie-
  population, animal-population, or isoregion footprint in the active save.
  This also disproves the Blackpine author's broad conflict warning for the
  current payloads: Blackpine occupies y=55..59 while Fairhaven occupies
  y=51..52.
- All 24 current comments and all zero discussions were reviewed. Current
  reports say the map does not appear, has no spawn, and spawns no vehicles.
  The payload puts every functional map file under uppercase `Common/`, while
  the native Build 42 Linux loader resolves lowercase `common/` through
  `ZomboidFileSystem` and `ChooseGameInfo`. This is the shared root cause on
  case-sensitive ext4: the authored two spawn points and 62 valid parking-stall
  records are present but the map content is otherwise ignored.
- The direct live install preserves all 29 current Workshop regular files
  byte-for-byte while normalizing only the path `Common/` to `common/`. Six
  relative live-only asset aliases map declared `poster.png` and `icon.png`
  names to the shipped JPG files at the root, `42`, and `common` levels. No
  uppercase `Common` remains live.
- Static POT review found four complete lotheader/lotpack/chunkdata triads,
  107,604 non-empty squares, 207,398 tile uses, 2,639 distinct used sprites,
  615 rooms in 59 internally valid buildings, 41 supported top stairs, two
  valid solid-floor profession spawn targets, and 62 unobstructed parking-stall
  records covering 744 floor squares. World-map XML parses and both Lua files
  compile. Seven one-use sign sprites are unresolved; no exact owned source was
  available, so replacements were not guessed.
- Fairhaven's authored `TownZone` records leave 68 of 9,607 compiled building
  x/y squares outside loot-respawn coverage. Private project
  `pz-fairhaven-cjs-tweaks`, pushed at `792606d`, reconstructs the exact
  upstream `objects.lua` (SHA-256
  `c7bae2d6465c581361653faf4e33c002c074128e0edfea0ed6d0161c27c1cc75`) and
  appends eight disjoint rectangles covering only those 68 squares. It aliases
  only four invalid compiled container-bearing room names to existing vanilla
  distributions: `Office`, `foyer`, `garage`, and `miscstorage`.
- The January Atlanta/Foxtrot questions do not identify conflicts in this
  active set. The August huge-horde report matches the authored map description
  and density values up to 55, so no balance rewrite was made. Fairhaven and its
  tweak occur exactly once and adjacently in the active save, default list, and
  `b42-4`; the ledger now has 1,657 ownership rows, 1,649 distinct cells, and
  the same eight baseline conflicts. Python/Lua regressions, Lua syntax,
  current-distribution validation, source reconstruction, live mapping,
  symlink/assets/load-list/backup checks, and the post-change review pass.
  Selecting the map, spawning, vehicle creation, loot respawn, and the intended
  horde density remain explicit in-game checks. Project Zomboid was not
  launched. The full pre-install backup is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-fairhaven-preinstall`.
- Fairhaven also proved a durable native-Linux packaging issue: functional
  shared content must use lowercase `common/`. The closeout audit normalized all
  ten earlier uppercase rollout repos and pushed the reviewed commits: Dawn
  Town `7ea89ce`, Haven Fall `0b60162`, Maplewood `e5ac94b`, Blackpine County
  `735f5ca`, Wildsteel `cea445f`, LiuDing Tiles `c5d35ee`, Begonia Town
  `98bbd0a`, Cathaya Valley `a463f25`, Little Town `59a96fe`, and RustBury
  `f6f0efb`. Fairhaven and Raccoon City were already lowercase. Every affected
  repo is clean/even with origin, its live entry remains the correctly cased
  project symlink, and all relevant regressions pass.
- Raccoon City resolves to Workshop item `3388468313`, exact title and mod ID
  `RaccoonCityB42`, and map token `RaccoonCity`. The exact current March 9
  payload is Steam manifest `7565636503886228807`, 117,189,693 bytes. Steam
  currently marks the page removed/incompatible, but the verified current
  cached payload and app manifest match; both selected descriptors declare no
  dependencies. Its own texture packs are `shisantiles`, `shisantiles.floor`,
  and `shisanfloor.floor`; tiledef number `9527` is unique among active mods.
- The current physical payload occupies 12 cells: `38_38` through `40_41`.
  Every cell was clear against the cumulative ledger and the active save had
  no matching map chunks, metagrid, chunkdata, zombie/animal population, or
  isoregion footprint before installation. The refreshed ledger has 1,669
  ownership rows, 1,661 distinct cells, and the same eight baseline conflicts.
- The newest 300 of 407 Workshop comments (covering more than six months) and
  all six discussions were reviewed. Current repeat reports include missing
  loot respawn, gun-store/police containers containing ammunition but no guns,
  police music playing too loudly and duplicating or persisting, and backpack
  capacities above the engine limit. Other reports concerning the puzzle,
  authored zombie density, removed legacy tiles, optional vehicles, and older
  APIs were checked against the current payload rather than patched by report
  alone.
- Raccoon City's 27 existing loot-respawn zones cover 41,177 of 52,161 unique
  compiled building-room x/y squares. Private project
  `pz-raccoon-city-cjs-tweaks`, pushed at `8c71e55`, reconstructs upstream
  `objects.lua` SHA-256
  `2556b62a2efe59fa975d43be2b8b17d1bfb48111132c846296aaea9f3f908fdd`
  and appends 97 disjoint `TownZone` rectangles covering exactly the other
  10,984 squares.
- Build 42's current vanilla distributions assign ammunition-only tables to
  hundreds of Raccoon City's `gunstorestorage`, `gunstore`, and police/army
  crate, locker, and shelf pairs. The tweaks mod adds a small coordinate- and
  room/container-bounded chance for one valid vanilla firearm, scales it by
  `RangedWeaponLootNew`, verifies container capacity, and runs the engine's
  `randomizeFirearmAsLoot()` initialization. EasyDistro is deliberately not a
  dependency because this is direct map-specific `OnFillContainer` behavior,
  not reference-item distribution copying.
- The upstream police music stores one sound handle globally across local
  players and can stop through the wrong player/emitter, producing duplicate or
  orphaned audio. The tweaks callback maintains per-player emitter/handle state,
  uses verified typed Build 42 sound methods, and adds a namespaced 0-100 volume
  option defaulting to 35 while preserving the upstream disable option. It also
  supplies the two correct Simplified Chinese SE/NW fence translation keys.
- Upstream `Biochemical_Armor.lua` stores live vehicle and vehicle-part Java
  objects inside persisted player `modData`, risking cyclic Kahlua save data.
  The tweaks mod removes those two upstream event callbacks, clears only their
  unsafe `VehicleObject` key, keeps live objects in a weak runtime-only table,
  and preserves scalar per-part durability/difference records. Saved-data and
  sandbox boundaries are type-checked; offline regressions cover callback
  replacement, split-screen audio independence, volume/disable behavior,
  map-bounded firearm insertion, and non-persisted vehicle state.
- The current sliding-puzzle shuffle enforces even inversion parity with the
  blank in the target bottom-right position, so an unsolvable-board rewrite was
  not justified without reproduction. Build 42 Java caps item containers and
  effective bag capacity around 49-62 despite the upstream option advertising
  larger values; a separate Lua layer cannot safely replace those engine-internal
  checks. The authored RPD zombie density and unresolved removed/editor sprites
  were not broadly rebalanced or guessed.
- Raccoon City is installed as a byte-identical 306-file direct Workshop copy;
  `raccoonCityCjsTweaks` is a live symlink to the clean private project. Target
  and tweak occur exactly once and adjacently in the active save, default list,
  and `b42-4`. The full pre-install recovery archive is
  `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/map-rollout-20260719-raccoon-city-preinstall`.
  Lua/Python regressions, Lua syntax, JSON, map reconstruction, Java bridge,
  direct-copy, live-link, load-list, ledger, and post-change review checks pass
  with no findings. The latest console predates this install; map travel, loot
  refill, firearm rolls, split-screen/MP audio, the biochemical truck, Chinese
  labels, and puzzle completion remain explicit in-game checks. Project Zomboid
  was not launched.
- Cumulative closeout verifies that the active save and default mod list are
  byte-identical and the `b42-4` preset has the same full ID sequence. All
  installed map targets, dependencies, and tweaks occur exactly once and in
  dependency/target/tweak order; Greenport, Greenleaf, Dirkerdam, and Green
  River occur zero times. All ordinary direct map payloads remain byte-identical
  to their selected Workshop sources. Fairhaven differs only by its reviewed
  `Common` to `common` path normalization and six poster/icon aliases. Rocco's
  Tiles differs only by three byte-identical generated appliance entities moved
  to its existing disabled archive to avoid duplicate registration with the
  active Rocco buildable companion. The final cell ledger contains 1,669
  ownership rows, 1,661 distinct cells, and only the eight conflicts that
  predated this requested queue.
