# Zomboid B42.19 Update Notes Archive

Archived on 2026-07-01 when the active anchor was shortened. This file preserves old run-by-run notes, historical logs, and completed investigation details that are no longer needed in the day-to-day restart anchor.

Current live-link policy supersedes older archive instructions: project-backed mods now live in `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods` as symlinks back to `/home/cjstorrs/projects/game-mods/zomboid/<modFolder>`, with symlink names matching project folder casing. Use `~/projects/game-mods/zomboid/link-project-mod.sh <modFolder>` for one mod and `~/projects/game-mods/link-zomboid-project-mods.sh` to reconcile already-present project-backed live entries. Older copy/rsync/no-`.git` project-backed install notes and lowercase live project-folder caveats are historical.

---

# Original Anchor Before Cleanup

Last updated: 2026-07-01 for the corrected Continue-save baseline and startup-blocker plan.

## Mission

Move this Project Zomboid mod setup from B42.12-era compatibility to B42.19. Start the game, continue the active save, inspect logs, and fix mod errors until the save loads and runs without actionable mod errors.

Save policy: do not spend time on broad save cleanup or save repair as the default strategy. Treat saves as test fixtures for compatibility work. If the current save appears contaminated, unrecoverable, or no longer useful for testing, stop and ask the user for a new save instead of trying to clean the save.

Use this file as the session anchor. Read it first after any context compaction, session corruption, or restart.

## Current Checkpoint

- Active baseline now comes from the user's latest Continue-save workflow, not the earlier Solo -> Custom Sandbox binary-search loop. Use `Continue` for the current baseline test unless a code/loadout change requires a different path or the user asks for a new save.
- Latest save discovered for this checkpoint: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-06-30_23-36-46`.
- User-confirmed startup blockers currently left out of the working baseline:
  - `CasterPlus`
  - `ImprovedSv2`
  - `VanillaFoodsExpanded`
- User-confirmed clothing/body-location suspects now ruled out:
  - `[J&G] Neon Vandals Uniform` works when restored.
  - `TombWardrobeALTVanilla` works when restored.
  - Leave `GanydeBielovzki's Frockin Splendor! Vol.4` disabled for now.
- Load-list hygiene rule for adding mods back: use the exact `id=` from the mod's active `mod.info`, and update all three active load points together: the current save `mods.txt`, `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/default.txt`, and the active `b42-4` line in `/media/cjstorrs/windows/Users/cjsto/Zomboid/Lua/pz_modlist_settings.cfg`. Verify each added ID appears exactly once in each active target before launching.
- Immediate plan:
  1. Make the latest Continue-save/default/preset files match the user-stated baseline: Neon and Tomb enabled, Frockin Vol.4 plus `CasterPlus`/`ImprovedSv2`/`VanillaFoodsExpanded` disabled.
  2. Read the newest successful-start logs from that baseline and fix concrete log spam in log order.
  3. Re-enable and fix `CasterPlus`, `ImprovedSv2`, and `VanillaFoodsExpanded` one at a time, using the direct-Workshop decision rule before importing or patching any third-party mod.
  4. Commit any project-owned or imported compatibility edits with messages shaped like `feat(4.19)/{description}`.

- Current user-directed isolation procedure:
  - Keep `disabled-mods.md` as the live ledger for mod-list changes during isolation.
  - Test with a new game path: `Solo -> Custom Sandbox -> Next` repeatedly until the world starts or the game errors/crashes.
  - If there are only a few strong suspects, disable that small set first.
  - If the suspect set is broad, use binary search: disable half; if the game starts, the bad mod is in the disabled half, so re-enable half of those; if the game still fails, the bad mod is still in the enabled half, so keep narrowing there.
  - Every temporary isolation mod must be restored unless it is confirmed bad by a matching log/crash. Do not let the test loadout silently shrink.
  - Once the bad-mod list is known, fix confirmed bad mods one at a time, using the direct-Workshop rule before creating/importing any project repo.
- Next test target from `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_22-16_DebugLog.txt`: the disabled `TheOnlyCureCjs`/`Ivmakk_MilkThemAll`/`neonMoodleLevels` run still failed with `BodyLocation.isMultiItem()` null during randomized corpse outfit creation. The first narrow body-location isolation batch is:
  - `GanydeBielovzki's Frockin Splendor! Vol.4`
  - `[J&G] Neon Vandals Uniform`
  - `TombWardrobeALTVanilla`
  These are temporary suspects, not confirmed bad yet.
- Temporary disable test requested by user: remove the current known bad/suspect mod IDs and see whether the latest save starts. Exact IDs disabled:
  - `TheOnlyCureCjs` (`cjstheonlycure`; latest hard crash consistently follows TOC startup/cache logs and `KahluaTableImpl.save` recursion).
  - `Ivmakk_MilkThemAll` (`MilkThemAll`; still logs `[MTA] ERROR [AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed ... StackOverflowError`).
  - `neonMoodleLevels` (`neonMoodleIndicator`; latest 22:04 log still throws `attempted index: index of non-table: null` at `neonMoodleLevels.lua:120`).
- Disabled-list scope: removed those exact IDs from every `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/*/*/mods.txt`, from `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/default.txt`, and from the active `b42-4` line in `/media/cjstorrs/windows/Users/cjsto/Zomboid/Lua/pz_modlist_settings.cfg`.
- Verification after removal: `rg -n "TheOnlyCureCjs|Ivmakk_MilkThemAll|neonMoodleLevels"` across save `mods.txt` files and `mods/default.txt` returns no matches; the same exact IDs are absent from the `b42-4` preset. Other inactive presets may still mention related old entries such as non-CJS `TheOnlyCure`; do not treat those as active for this test unless the user selects that preset.
- Latest save to test: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-06-30_22-05-19`.
- Disable-test result: failed. The game launched and auto-entered the latest save loading screen without a manual Continue click. It reached `WorldDictionary.init() end` and `game loading took 31 seconds`, then crashed before a usable world session.
- Disable-test log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_22-16_DebugLog.txt`.
- Disabled-mod verification in that log: no `Starting The Only Cure`, `TheOnlyCureCjs`, `Milk Them All`/`MTA_`, `Ivmakk_MilkThemAll`, `neonMoodle`, or `neonMoodleLevels` matches. The exact IDs are also absent from latest save `mods.txt`, `mods/default.txt`, and active preset `b42-4`.
- New first explicit blocker with those three disabled: two `RandomizedBuildingBase.ChunkLoaded` exceptions at 22:17:42.963 and 22:17:42.987:
  `NullPointerException: Cannot invoke "zombie.characters.WornItems.BodyLocation.isMultiItem()" because "location" is null`
  Stack path: `WornItems.setFromItemVisuals` -> `IsoZombie.DoCorpseInventory` -> randomized dead body/outfit creation (`RBSafehouse` and `RDSGunmanInBathroom`).
- The hard crash still follows at 22:17:44.547 as `Unhandled java.lang.StackOverflowError` in repeated `se.krka.kahlua.j2se.KahluaTableImpl.save(...)`.
- Interpretation: disabling `TheOnlyCureCjs`, `Ivmakk_MilkThemAll`, and `neonMoodleLevels` is not enough to start the save. Keep those three disabled for isolation until told otherwise. Next concrete fix target is the active custom body-location/outfit item that resolves to nil during randomized dead-body inventory creation; previous static candidates still include `B42PackMule:Pocket`, `FcknSpldr:KIU2/KIUB/KIUC`, `LegendaryDuffelbag:LowerBack`, `TABAS:BodyGrime/BodyShampoo`, old `[J&G] Neon Vandals` slots, and Tomb's Wardrobe old slots.

- Latest retest log after TOC commit `43b3770` is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_21-53_DebugLog.txt`.
- Do not use the main-menu `Continue` path blindly for the next retest. The 21:53 launch unexpectedly opened a spawn/new-character flow for save `2026-06-30_21-53-56`; Back still proceeded into `THIS IS HOW YOU DIED` loading and then crashed. If another in-game validation is needed, use `Load` and explicitly select the intended save, or ask the user which save to use.
- TOC commit `43b3770` did execute in single-player and logged `Applying data for JewelDoucette`, but the save still crashed with `Unhandled java.lang.StackOverflowError` in repeated `se.krka.kahlua.j2se.KahluaTableImpl.save(...)`.
- Follow-up TOC commit `767777c` (`feat(4.19)/skip-default-only-cure-sp-persistence`) changes single-player persistence so fresh/default TOC state is kept in memory and not written to player `modData` during startup. TOC now persists only when there is actual TOC state to save: infected/ignored state, cut/operated/cicatrized/visible limb state, or prosthesis state. This avoids an unnecessary B42.19 Kahlua save pass immediately after new-player TOC setup.
- `767777c` was synced by targeted file copy to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjstheonlycure/common/media/lua/client/TOC/Controllers/DataController.lua`. This predates the current symlink workflow; future project-backed TOC live repairs should use `link-project-mod.sh cjsTheOnlyCure` and preserve the project folder casing.
- The first explicit runtime exception in that log is now before MTA and TOC setup: `RandomizedBuildingBase.ChunkLoaded` throws `NullPointerException` in `BodyLocationGroup.isMultiItem()` while `IsoZombie.DoCorpseInventory()` creates a randomized dead body. Investigate active clothing/body-location script definitions next, especially TOC body-location registrations and any item body-location references that B42.19 no longer registers.
- Game-code review for that corpse crash: `Item.load` resolves `BodyLocation = ...` via `ItemBodyLocation.get(ResourceLocation.of(value))`, `WornItems.setFromItemVisuals()` passes the resulting item location into `WornItems.setItem()`, and `BodyLocationGroup.isMultiItem()` dereferences the group lookup without a nil guard. Missing or ungrouped body locations from active outfit-capable clothing can cause this NPE.
- Active-mod static scan from save `2026-06-30_21-53-56` found 268 active mod IDs mapped to 271 live roots. TOC registers and groups its `TOC:...` body locations. Non-TOC candidates for the corpse NPE include active custom body-location mods/items with incomplete-looking old or namespaced registrations: `B42PackMule:Pocket`, `FcknSpldr:KIU2/KIUB/KIUC`, `LegendaryDuffelbag:LowerBack`, `TABAS:BodyGrime/BodyShampoo`, old `[J&G] Neon Vandals` unnamespaced slots, and Tomb's Wardrobe old slots. Do not patch those blindly; use the next log after `767777c` to see whether the corpse NPE recurs and whether it becomes the first remaining blocker.
- Still pending after that body-location failure: `Milk Them All` continues to auto-disable `MTA_ISMilkAnimal` with a `StackOverflowError`; revisit it after the first concrete body-location exception is resolved or proven unrelated.

## Fresh Save Baseline

- User abandoned the old corrupted save and created a new save: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-06-30_20-17-40`.
- Latest user-run log before this checkpoint: `/media/cjstorrs/windows/Users/cjsto/Zomboid/console.txt` and `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_20-16_DebugLog.txt`.
- The user-run process was launched without `JAVA_TOOL_OPTIONS`; `/proc/<ProjectZomboid64>/environ` had no `deployment.user.cachedir`. Therefore the early `67gt500` `FileNotFoundException` for `/home/cjstorrs/Zomboid/mods/home/cjstorrs/zomboid/mods/67gt500/.../template_gt500_armor.txt` is the known B42.19 lowercase-URI launch bug, not a missing 67gt500 file. The project and live copies already contain `67gt500/42.0/media/scripts/vehicles/template_gt500_armor.txt`, and project/live diff is clean.
- When Codex drives the game, launch from `/home/cjstorrs/games/Project Zomboid Linux 42.19.0` with:
  `env JAVA_TOOL_OPTIONS=-Ddeployment.user.cachedir=/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent ./start.sh`
- Current concrete fresh-save blocker after the bad-launch path issue: `Hephas Stalker PDA` crashes during `Events.OnNewGame` at `HSP_ItemDistri.lua:17`, logging `ItemContainer.AddItem: can't find Base.Hephas_StalkerPDA` followed by `Object tried to call nil`. Fix in project repo `HephasStalkerPDA`, then sync live lowercase folder `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/hephasstalkerpda`.

## Current Fresh Save: 2026-06-30_20-25-56

- Latest user-created fresh save: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-06-30_20-25-56`.
- Latest logs for this checkpoint: `/media/cjstorrs/windows/Users/cjsto/Zomboid/console.txt` and `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_20-25_DebugLog.txt`.
- `Hephas Stalker PDA` no longer throws the hard `Base.Hephas_StalkerPDA` nil-call crash in this log. The project fix is still uncommitted until post-change review/commit is finished: guard the missing starter item and skip the new-character PDA grant when `ScriptManager.instance:FindItem("Base.Hephas_StalkerPDA")` is absent. Remaining Hephas lines are `require("Items/Distributions") failed` warnings only.
- New hard blocker: `Starving Zombies` repeatedly throws from `RYUKU_StarvingZombies_SmellFuncs.lua:15` via `szCanSmellBody(...)` and `onZombieUpdate(...)`, alternating:
  - `java.lang.IllegalStateException: Not in debug` from `getNumClassFields(...)`, because the stale live mod uses debug-only Java reflection to read `IsoDeadBody.deathTime`.
  - `__sub not defined for operands in getDeathTime`, because that failed lookup returns a non-number into `gameTime:getWorldAgeHours() - getDeathTime(...)`.
- The same log then dies with `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)`. Starving Zombies also stores live `IsoDeadBody` and player objects in zombie `modData` (`szBody`, `szBodies`, `szPlayer`), so clearing the updated Workshop version is the next targeted fix before chasing serializer fallout.
- Classification for `Starving Zombies`: direct Workshop update, not a project import. Workshop cache `3396867685/mods/starving-zombies` has a newer `42.15` payload with the same `id=StarvingZombies`; its smell code already uses `isoDeadBody:getDeathTime()` instead of debug reflection. No project repo exists and no intentional local edits were found, so install the Workshop payload straight to live lowercase `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/starving-zombies`.
- Completed `Hephas Stalker PDA` project fix: commit `f815d5d` (`feat(4.19)/guard-hephas-starter-pda`) on branch `feat(4.19)/lowercase-hephas-stalker-pda-script-paths`. Changed `42/media/lua/client/HSP_ItemDistri.lua` to guard the missing `Base.Hephas_StalkerPDA` script item before adding it on `Events.OnNewGame`. Live lowercase copy `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/hephasstalkerpda/42/media/lua/client/HSP_ItemDistri.lua` matches the project file.
- Completed `Starving Zombies` direct Workshop live install: moved stale live `starving-zombies` into `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/_disabled-b4219-backups/20260630-203320/starving-zombies`, then copied Workshop `3396867685/mods/starving-zombies` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/starving-zombies`.
- Starving Zombies validation after install: live and Workshop directories compare clean; live contains `42.0` and `42.15` with `id=StarvingZombies`; all live Lua files pass `luac5.1 -p`; no live `.git`; active save/default/preset still reference `StarvingZombies`.
- 20:35 retest after `f815d5d` and Starving Workshop install: launched B42.19 with the cache bridge, clicked Continue at physical X coordinate `(356,766)`, and loaded save `2026-06-30_20-25-56`.
  - Cleared: the Starving Zombies `getDeathTime`/`Not in debug` stack did not recur.
  - Still present but not first blocker: `Milk Them All` logs `[AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed ... StackOverflowError` and then reports hook setup completed.
  - New first concrete Lua blocker: `Neon moodle levels` throws `Object tried to call nil` at `common/media/lua/client/neonMoodleLevels.lua:120` from both `Events.OnPreUIDraw` and `Events.OnPostUIDraw`. Failing code is `MoodleType.ToIndex(MoodleType.MAX)`; B42.19 local Lua patterns use enum `:index()` methods instead.
  - Final hard crash still follows as `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)`. Keep treating the explicit Lua stack before the serializer crash as the next fix target.
- `Neon moodle levels` classification: Workshop cache `3392116408` exists and live compares identical to Workshop, so there is no already-updated drop-in. No project repo exists. Because this needs a real compatibility code edit, import live `neonMoodleIndicator` into the project workspace with an untouched baseline commit before editing; the vertical companion only provides assets and `require=\neonMoodleLevels`.
- Completed `Neon moodle levels` project import and fix:
  - Imported live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/neonMoodleIndicator` into project `/home/cjstorrs/projects/game-mods/zomboid/neonMoodleIndicator` and committed untouched baseline `fdbfc1d` (`feat(4.19)/import-neon-moodle-live-baseline`).
  - Compatibility fix committed as `f8dad4a` (`feat(4.19)/use-b42-moodle-enum-indexes`) on branch `feat(4.19)/guard-neon-moodle-count`.
  - Changed `common/media/lua/client/neonMoodleLevels.lua`: `MoodleType.MAX:index()` replaces removed `MoodleType.ToIndex(MoodleType.MAX)`, and `MoodleType.FOOD_EATEN` replaces stale `MoodleType.FoodEaten`.
  - Live sync completed to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/neonMoodleIndicator/common/media/lua/client/neonMoodleLevels.lua`.
  - Validation passed: project/live diff clean excluding `.git`, live Lua parses with `luac5.1 -p`, file is CRLF-only, live folder has no `.git`, `id=neonMoodleLevels` is unique among direct live providers, and vertical companion keeps `require=\neonMoodleLevels`.
- Next action: relaunch with the cache bridge and retest latest save. Confirm Neon line-120 stack clears; if the save still crashes, inspect the next explicit Lua/mod stack before the `KahluaTableImpl.save` serializer crash.
- 20:45 retest after the Neon Moodle fix:
  - Latest logs: `/media/cjstorrs/windows/Users/cjsto/Zomboid/console.txt` and `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_20-45_DebugLog.txt`.
  - Cleared: Neon Moodle line-120 stack did not recur; Starving Zombies `getDeathTime`/`Not in debug` stack did not recur; Hephas hard starter-PDA crash did not recur.
  - Still present: `Milk Them All` logs `[MTA] ERROR [AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed and has been permanently disabled: null java.lang.StackOverflowError`, then continues with later MTA hook setup. Fix this after the harder load blocker unless it becomes the direct crash source.
  - New hard crash sequence immediately before the serializer crash: `The Only Cure CJS` starts version `2.1.7`, creates a new `DataController` for `MyongKincaid`, reports `Local data failed to load! Running setup`, triggers `CalculateHighestAmputatedLimbs`, calculates hand feasibility `L` and `R`, then the game dies with `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)`.
  - Important interpretation: current `cjsTheOnlyCure` already skips `apply()`/`ModData.transmit()` in single-player, so this 20:45 crash is likely another unsafe player/world `modData` serializer path exposed during new-player setup, not the old TOC global transmit path.
  - Next action: diagnose the next explicit mod/save-data writer from logs or minimal instrumentation in a project-owned mod. Do not add a broad save-cleanup pass. If diagnosis shows the save itself is a bad test fixture, ask the user for a new save.
- User correction after 20:45: ask for a new save when needed instead of trying save cleanup. In response, stale `cjsZombieCountGuard/42/media/lua/client/CJS_B42SaveCleanup.lua` was removed from the project and live install. That file had been deleting `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L` on player load and writing a cleanup marker. `cjsZombieCountGuard` should remain only the zombie-count warning mod unless the user explicitly approves future save-modifying behavior.
- `Milk Them All` classification: no suitable Workshop payload was found in the Windows Workshop cache, and no project repo existed. Imported live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/MilkThemAll` to project `/home/cjstorrs/projects/game-mods/zomboid/MilkThemAll` and committed untouched baseline `c6d5051` (`feat(4.19)/import-milk-them-all-live-baseline`).
- `Milk Them All` first compatibility fix: B42.19 moved vanilla `ISMilkAnimal` to `TimedActions/Animals/ISMilkAnimal`. Patched `MTA_ISMilkAnimal.lua` and `TimedActions/MTA_SequentialBucketsMilkAnimal.lua` to require the B42.19 path, then synced live `MilkThemAll`. Validation passed: project/live diff clean excluding `.git`, live Lua syntax passes, touched files are CRLF-only, no live `.git`, and `id=Ivmakk_MilkThemAll` is preserved. Retest still needed to confirm the MTA auto-disable stack clears.
- 21:04 retest after removing the stale cleanup hook and applying the first Milk Them All path fix:
  - Latest logs: `/media/cjstorrs/windows/Users/cjsto/Zomboid/console.txt` and `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_21-04_DebugLog.txt`.
  - Save `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-06-30_20-25-56` reached world startup after Continue and Click-to-Start.
  - Cleared: no `[CJS B42 Save Cleanup]` log remains; the removed cleanup file is no longer active.
  - Still present: `Milk Them All` still logs `[MTA] ERROR [AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed and has been permanently disabled: null java.lang.StackOverflowError` even after the B42.19 require-path fix. It still reports later hooks and `All components loaded successfully`, but this is not clean.
  - New first concrete runtime exception: `IsoChunk.doLoadGridsquare` throws `NullPointerException` in `HandWeapon.randomizeFirearmAsLoot(HandWeapon.java:2413)` because `HandWeapon.getAmmoType()` returned null during loot fill. This is likely an active mod script defining or spawning a firearm-like `Weapon` without a valid `AmmoType`; search active mod scripts before patching.
  - Context immediately before the NPE: `ItemPickInfo -> cannot get ID for container: ATA2InteractiveTrunkRoofRack` repeated, then `TrailerAnimalFood`. These are adjacent warnings, not yet proven causal.
  - Final crash still follows after The Only Cure CJS creates fresh player data for `ManuelWalters`, calculates hand feasibility `L` and `R`, then hits `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)`.
  - Current order of work: fix the explicit firearm loot NPE first, then the remaining MTA auto-disable stack, then diagnose the Kahlua serializer recursion. Do not add save cleanup; if the save stops being a useful fixture, ask the user for a new save.
- Completed first 21:15 firearm loot NPE fix:
  - Root cause: active project-owned `Rain's Firearms & Gun Parts - More Combos` had partial B42.19 `Type = Weapon`/`ItemType = base:weapon` overlays for `Base` firearms. The earlier item-type fix cleared `ComboItem` casts but left those overlay-created `HandWeapon` definitions without ammo metadata, causing `HandWeapon.randomizeFirearmAsLoot` to dereference a null `AmmoType`.
  - Fix commit: `d87b331` on branch `feat(4.19)/lowercase-rain-more-combos-script-paths`, message `feat(4.19)/preserve-more-combos-firearm-data`.
  - Changed project files: `42/media/scripts/rfngpex_pistols.txt`, `rfngpex_revolvers.txt`, `rfngpex_shotguns.txt`, and `rfngpex_smgs.txt`.
  - Fix shape: replace the partial More Combos firearm item blocks with the full matching Rain's Expanded firearm definitions, then preserve the More Combos-added `ModelWeaponPart` lines and the two existing sawnoff weight overrides.
  - Live sync completed to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/rain's firearms & gun parts - more combos`.
  - Validation passed before retest: project/live diff clean excluding `.git`, live folder has no `.git`, `id=B42RainsFirearmsAndGunPartsMoreCombos` preserved, touched files remain CRLF, CRLF-aware `git diff --check` passed, and an active-live script parser reports `missing_ammo_count 0` for firearm-like weapons.
  - Next action: relaunch B42.19, continue the latest save, and confirm the `HandWeapon.randomizeFirearmAsLoot` null-ammo stack is gone.
- 21:20 retest after `d87b331`:
  - Latest logs: `/media/cjstorrs/windows/Users/cjsto/Zomboid/console.txt` and `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_21-20_DebugLog.txt`.
  - Cleared: no `HandWeapon.randomizeFirearmAsLoot`, no `getAmmoType()` null NPE, and no `IsoChunk.doLoadGridsquare` firearm stack in the targeted scan.
  - Still present: `Milk Them All` `MTA_ISMilkAnimal` auto-disable `StackOverflowError`.
  - New first concrete world-entry Lua stack: `CJS Zombies Can't Hide` called removed `PropertyContainer:Is(...)` at `cjs_zombiesCantHide.lua:49` via `propIs -> isZombieOccluded -> youCantHide`, immediately before the recurring `KahluaTableImpl.save` serializer crash.
- Completed `CJS Zombies Can't Hide` B42.19 property API fix:
  - Project repo: `/home/cjstorrs/projects/game-mods/zomboid/cjsZombiesCantHide`.
  - Live mod: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsZombiesCantHide`.
  - Fix commit: `b6a8cb4` on branch `master`, message `feat(4.19)/use-zombie-hide-property-has`.
  - Changed `42/media/lua/client/cjs_zombiesCantHide.lua`: `propIs` now calls `properties:has(flag)` instead of removed B42.12-era `properties:Is(flag)`.
  - Validation passed before retest: project/live diff clean excluding `.git` and `.cjs-zomboid-mirror-source`, live folder has no `.git`, `id=cjsZombiesCantHide` preserved, Lua syntax passes in project and live, LF line endings preserved, and CRLF-aware `git diff --check` passed.
  - Next action: relaunch B42.19, continue the latest save, and confirm the `CJS Zombies Can't Hide` stack is gone.
- 21:24 retest after `b6a8cb4`:
  - Latest logs: `/media/cjstorrs/windows/Users/cjsto/Zomboid/console.txt` and `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_21-24_DebugLog.txt`.
  - Cleared: the `CJS Zombies Can't Hide` `PropertyContainer:Is(...)` stack did not recur in the targeted scan.
  - Still present: `Milk Them All` still logs `[MTA] ERROR [AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed and has been permanently disabled: null java.lang.StackOverflowError`.
  - Still present and first hard runtime exception: `IsoChunk.doLoadGridsquare` still throws `NullPointerException` in `HandWeapon.randomizeFirearmAsLoot(HandWeapon.java:2413)` because `HandWeapon.getAmmoType()` is null.
  - New bytecode finding: B42.19 `HandWeapon.randomizeFirearmAsLoot()` calls `getAmmoType():getItemKey()` when a weapon has `AmmoBox` and the ammo-box roll chooses loose ammo. The crash can be caused by old item-style `AmmoType = Base.Bullets9mm` values, not just a missing `AmmoType` property. B42.19 expects registry resources such as `base:bullets_9mm`.
- Completed second Rain firearms ammo-resource fix:
  - Project repos: `/home/cjstorrs/projects/game-mods/zomboid/B42 Rain's Firearms & Gun Parts Expanded` and `/home/cjstorrs/projects/game-mods/zomboid/Rain's Firearms & Gun Parts - More Combos`.
  - Live mods: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/b42 rain's firearms & gun parts expanded` and `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/rain's firearms & gun parts - more combos`.
  - Expanded commit: `eab0d25` on branch `feat(4.19)/lowercase-rains-expanded-script-paths`, message `feat(4.19)/register-rain-ammo-resources`.
  - More Combos commit: `599f74d` on branch `feat(4.19)/lowercase-rain-more-combos-script-paths`, message `feat(4.19)/use-b42-rain-ammo-resources`.
  - Fix shape: added Rain custom ammo resources in `B42 Rain's Firearms & Gun Parts Expanded/42/media/registries.lua` for `RFNGP:bullets_223`, `RFNGP:bullets_762`, and `RFNGP:bullets_762x39`, mapped to `Base.223Bullets`, `Base.762Bullets`, and `Base.762x39Bullets`.
  - Changed Rain script `AmmoType` fields from old item fulltypes to B42 registry resources: vanilla ammo now uses `base:bullets_9mm`, `base:bullets_45`, `base:bullets_44`, `base:bullets_38`, `base:bullets_556`, `base:bullets_308`, and `base:shotgun_shells`; Rain custom ammo now uses `RFNGP:bullets_223`, `RFNGP:bullets_762`, and `RFNGP:bullets_762x39`.
  - Validation passed before retest: project/live diff clean excluding `.git`, both live Rain folders have no `.git`, `id=B42RainsFirearmsAndGunPartsExpanded` and `id=B42RainsFirearmsAndGunPartsMoreCombos` preserved, live registry Lua syntax passes, CRLF-aware `git diff --check` passes in both repos, touched script files remain CRLF, and the active live Rain parser reports `live_bad_ammo_refs 0` plus `live_old_ammoBox_weapon_refs 0`.
  - Next action: relaunch B42.19 only after this code change, continue the latest save, and confirm the `HandWeapon.randomizeFirearmAsLoot` null-ammo stack is gone.
- 21:36 retest after the Rain ammo-resource fix:
  - Latest log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_21-36_DebugLog.txt`.
  - The Rain `HandWeapon.randomizeFirearmAsLoot` null-ammo stack did not recur in the targeted scan.
  - The save reached `game loading took 29 seconds`, then after Click-to-Start it logged MTA's still-pending auto-disable stack, started `The Only Cure` version `2.1.7`, created a new `DataController` for `AnnabelleFuller`, logged `Local data failed to load! Running setup`, calculated hand feasibility `L`/`R`, then hard-crashed with `Unhandled java.lang.StackOverflowError` in repeated `se.krka.kahlua.j2se.KahluaTableImpl.save(...)`.
  - Active TOC project repo: `/home/cjstorrs/projects/game-mods/zomboid/cjsTheOnlyCure`.
  - Active TOC live folder for `id=TheOnlyCureCjs`: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjstheonlycure`.
  - Historical casing caveat: this predates the current symlink workflow, where `link-project-mod.sh cjsTheOnlyCure` should create the project-cased live symlink. A duplicate uppercase live folder created during this pass was moved to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/cjsTheOnlyCure-duplicate-20260630-2151`; the active live root then had only `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjstheonlycure`.
  - Stale upstream folders `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/The-Only-Cure` and `The-Only-Cure (1)` are not the active CJS save-facing mod. Do not patch those for the active `TheOnlyCureCjs` crash.
  - B42.19 game-code review: `KahluaTableImpl.save(ByteBuffer)` recursively saves string/number/boolean/table keys and values with no cycle detection. Any cyclic table in a saved Kahlua table can stack-overflow the main thread during player/global/item save. Do not store TOC controller/module/self tables in saved modData.
  - Current TOC fix committed as `43b3770` (`feat(4.19)/persist-only-cure-sp-flat-data`): single-player `DataController:apply()` now sanitizes `self.tocData`, writes only flat scalar player `modData` keys through the existing `TOC_B42_Data_*` schema, and removes the legacy `TOC_<username>` GlobalModData key. `ensureCurrentSchema()` also persists through the flat single-player path. Player death now clears those flat TOC keys.
  - Current TOC zombie-amputation fix shape: in single-player, zombie amputation reapply data is a transient Lua table and removes stale `TOC_ZOMBIES` GlobalModData; multiplayer clients still use `ModData.getOrCreate(TOC_ZOMBIES)` and transmit as before.
  - Current TOC server fix shape: `ServerDataHandler.lua` now returns unless `isServer()` is true, so single-player does not install the MP GlobalModData receive handler.
  - Validation before retest passed: project Lua syntax for all four changed files, live Lua syntax for all four changed files, `git diff --check`, LF-only touched files, project/live diff clean against lowercase live `cjstheonlycure`, no live `.git`, and live `42/mod.info` still has `id=TheOnlyCureCjs`.
  - Next action: relaunch B42.19 with the cache bridge and continue the latest save. Confirm whether the TOC/Kahlua stack clears. MTA auto-disable remains a known pending issue if it still appears after TOC no longer hard-crashes.

## Critical Steering From User

- Do not resume corrupted session `019f15e4-dd1d-7963-9268-d916dfbe69f7`; only read logs/history from it.
- Check the Windows Workshop cache before patching a mod, but preserve local CJS/project functionality when Workshop differs.
- If the Workshop cache has an already-updated B42.19-compatible third-party mod and we have not made intentional local edits to that mod, do not import or patch it in `~/projects/game-mods/zomboid`. Install the Workshop payload directly into `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods`, preserving the save-facing `id=` values and ensuring the live folder is a direct child with the structure B42.19 expects. Record the live install in this anchor instead of creating project commits.
- Only keep/use a project repo for a Workshop mod when there are real local edits to preserve, the Workshop version is not a drop-in replacement for the active save, or no suitable Workshop source exists.
- Hard rule from user correction: an updated third-party Workshop mod with no intentional local edits does not belong in the project workspace. Copy it straight from Workshop into live `Zomboid/mods`, then apply only live-only B42.19/Linux structure normalization as needed. Do not make project branches/commits for those mods, and do not treat any already-created mistaken project repo/branch as the source of truth.
- Prefer fixing individual mods over creating a helper compatibility mod.
- This migration is B42.12 to B42.19, not B41 to B42.19. Backward compatibility can be gutted if it gets in the way of B42.19 compatibility.
- Do not default to save cleanup/repair. If a save is corrupted, contaminated by earlier crashes, or no longer worth using as a test fixture, ask the user for a new save.
- Do not silently modify save data to work around compatibility issues. Target the broken mod code or loadout first; only touch save data with explicit user approval.
- If a missing-mod/savefile confirmation list appears after clicking Continue, do not accept it. Read it and fix the missing mod/load problem.
- Game driving notes: there should be no login; click Continue and Okay as needed. If normal clicks fail, try pyautogui, gamepad input, or longer synthetic mouse down/up clicks.

## Direct-Workshop Decision Rule

- Current user correction, hard rule: updated third-party Workshop mods with no intentional local edits go directly from the Windows Workshop cache into live `Zomboid/mods`. They do not belong in `~/projects/game-mods/zomboid`, and mistaken historical project repos/branches for those mods are not source of truth.
- Decision order for every non-CJS mod named by a log:
  - Check the active save-facing `id=` and the Windows Workshop cache first.
  - If Workshop has a current payload, the `id=` is a safe match, and there are no real local edits to preserve, move the old live folder to disabled holding and `rsync` the Workshop mod straight into live.
  - Apply only live-only B42.19/Linux normalization when needed: lowercase the live root and `media/scripts` path components, and preserve `id=`, dependencies, posters, and active load-list IDs.
  - Do not create project branches or commits for those live-only Workshop installs.
  - Keep/use a project repo only when there are intentional local edits, Workshop is not a drop-in replacement for the active save, no Workshop source exists, or the compatibility fix requires real content/code changes beyond live-only structure normalization.
- Before touching any already-created third-party project repo from this migration, reclassify it. Do not assume its latest commit is authoritative just because it exists.

## Batch Casing Audit Decision

- User explicitly directed switching from one-launch-per-mod to a batch fix for the repeated known pattern.
- Batch scope is enabled active save/loadout mods, not every installed folder.
- Known repeated pattern: B42.19 on Linux requests lowercase live roots and lowercase path components under `media/scripts`; many B42.12-era/Workshop payloads still have uppercase script filenames or directories.
- Batch workflow:
  - Parse active IDs from `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-06-27_21-27-42/mods.txt`.
  - Map those IDs to installed live mod folders by reading `mod.info`.
  - Scan only mapped enabled live folders for uppercase files/directories under `media/scripts`.
  - For each hit, classify before editing: project-owned/local edits means project `git mv` + `feat(4.19)/...` commit + live sync; no local edits with Workshop match means direct Workshop live-only install + lowercase normalization and anchor entry, no project commit.
  - Relaunch after the batch to catch non-casing blockers, missed path casing, or runtime/menu/Continue issues.
- Batch result at 17:28:
  - Corrected parser scanned all 269 active save IDs from `Saves/Sandbox/2026-06-27_21-27-42/mods.txt`.
  - Before the batch, 25 enabled live folders had root or `media/scripts` casing issues.
  - After direct installs, project fixes, and duplicate cleanup, the rescan reported `MISSING_IDS 0`, `ACTIONABLE_CASING_ROWS 0`.
  - Remaining duplicate active IDs are `MoodleFramework` and `AutoMechanics`; neither currently has the known `media/scripts` casing pattern, so they were left alone.
  - Stale duplicate active-ID folders `DrivingSkill` and `ScavengerSkill` were moved to disabled holding after confirming their fixed B42 project folders exist in lowercase live.

## Current Restart Checkpoint

- Latest retest log before this edit: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_18-14_DebugLog.txt`.
  - `WorldDictionary.init() end` still appears, so the LongTermPreservationExtended save-ID fix remains good.
  - `cjsFurnitureStorageBoost` still failed because `character:HasTrait(...)` is not available in the B42.19 UI refresh path. Committed fix `26d232d` (`feat(4.19)/use-character-trait-storage-checks`): use `character:hasTrait(CharacterTrait.ORGANIZED/DISORGANIZED)` from known-working local B42 patterns and return false when the registry constants are unavailable. Live sync completed and project/live file diff is clean.
  - `CP_MoreTraits` previous `Blissful` stack cleared, then exposed the next runtime stack in `albino(MoreTraits.lua:2274)`: `stats:getPain()` is no longer a valid B42.19 call and ran before checking the player has the albino trait. Committed fix `75f2f54` (`feat(4.19)/guard-more-traits-albino`): return before touching pain/BodyDamage unless the player has `albino`, guard BodyDamage/head, and use the mod's own `AlbinoTimeSpentOutside` value for the announce threshold. Live copy matches the project file.
  - New Java item-spawn exception to investigate after the current Lua stacks clear: `HandWeapon.randomizeFirearmAsLoot` NPE because `getAmmoType()` returned null during `IsoChunk.doLoadGridsquare`/`ItemSpawner.spawnItem`.
  - `Milk Them All` still logs `[MTA] ERROR [AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed and has been permanently disabled: null java.lang.StackOverflowError`; keep it on the queue after harder blockers.
  - Final hard crash still recurs as `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)`. After concrete Lua/item-spawn stacks are gone, inspect save/modData recursion.
- 18:22 retest after commits `26d232d` and `75f2f54`:
  - Game launched, Continue required a long mouse-down/up click at `(356,766)`, and Click-to-Start worked at `(1280,1302)`.
  - `WorldDictionary.init() end` and `game loading took 30 seconds` still appear.
  - The old `cjsFurnitureStorageBoost`, `MoreTraits.Blissful`, and `MoreTraits.albino` stack traces did not recur.
  - New first More Traits stack: `SuperImmuneFakeInfectionHealthLoss(MoreTraits.lua:2804)` from `MainPlayerUpdate(MoreTraits.lua:4586)`, `Object tried to call nil`. Line 2804 is `player:getStats():getStress()`, another removed B42.19 stats getter. Committed fix `49fa8e8` (`feat(4.19)/guard-more-traits-superimmune`): uses `CharacterStat.STRESS`, guarded BodyDamage/stats, and removes unguarded repeated `player:getBodyDamage()` calls from that function. Live copy matches the project file.
  - The HandWeapon ammo-type NPE still recurs twice during `IsoChunk.doLoadGridsquare`, before the More Traits stack.
  - MTA still auto-disables `MTA_ISMilkAnimal` with StackOverflow but completes later hook setup.
  - Final `KahluaTableImpl.save` StackOverflow still crashes the game shortly after world entry.
- 18:35 retest after `CP_MoreTraits` commit `49fa8e8`:
  - Game launched cleanly, Continue needed the long click at `(356,766)`, and Click-to-Start worked at `(1280,1302)`.
  - `WorldDictionary.init() end` and `game loading took 30 seconds` still appear.
  - The old `cjsFurnitureStorageBoost`, `MoreTraits.Blissful`, `MoreTraits.albino`, and `MoreTraits.SuperImmune` stack traces did not recur.
  - The prior `HandWeapon.randomizeFirearmAsLoot`/`getAmmoType()` NPE did not recur in this log.
  - Remaining runtime sequence: MTA logs `[AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed ... StackOverflowError`, then The Only Cure CJS logs `Found and loaded local data`, `Added Hand_L to known amputated limbs`, `Healing area - Hand_L`, `Applying data for CJStorrs`, and the game crashes in `KahluaTableImpl.save(...)`.
  - Root cause inference: TOC calls `ModData.transmit(TOC_CJStorrs)` while the loaded TOC modData table is not safe for B42.19 serialization, likely because it contains a legacy/cyclic table. The stack is the serializer, not normal Lua code.
  - Fixed `cjsTheOnlyCure` on branch `feat(4.19)/sanitize-only-cure-moddata`, commit `163400e` (`feat(4.19)/sanitize-only-cure-moddata`): rebuild TOC modData from known primitive `limbs` and `prostheses` fields when loading/receiving data and immediately before `ModData.transmit`, preserving saved amputation/infection/cicatrization/prosthesis scalar state while dropping unsafe legacy table references.
  - Live sync went to existing lowercase `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjstheonlycure`, not the mixed-case project folder name, to avoid a duplicate `id=TheOnlyCureCjs` folder. Validation passed: project/live `DataController.lua` diff clean, full project/live diff clean excluding `.git` and `.cjs-zomboid-mirror-source`, live Lua syntax passes, no live `.git`, and only `cjstheonlycure/42/mod.info` provides `id=TheOnlyCureCjs`.
  - 18:45 retest after `163400e` still crashed. Evidence: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_18-45_DebugLog.txt` has `Applying data for CJStorrs` at line 19215 followed immediately by `Unhandled java.lang.StackOverflowError` in `KahluaTableImpl.save` at line 19216. This means sanitizing the Lua reference was not enough; B42.19 likely kept the old cyclic Global ModData table under the same key when `ModData.add(key, sanitizedTable)` was called.
  - Follow-up fix committed in `cjsTheOnlyCure` as `c5818ec` (`feat(4.19)/replace-only-cure-moddata-before-transmit`): added a local `ReplaceModData(key, data)` helper that calls `ModData.remove(key)` before `ModData.add(key, data)` and uses it for TOC setup, schema repair, online-data apply, and `apply()` before `ModData.transmit(key)`.
  - Follow-up validation passed: project and live `DataController.lua` syntax, CRLF-aware diff check, live/project file diff, live `42/mod.info` with `id=TheOnlyCureCjs`, no live `.git`, and no duplicate mixed-case `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsTheOnlyCure`.
  - 18:51 retest after `c5818ec` still crashed. Evidence: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_18-51_DebugLog.txt` reached `game loading took 30 seconds`, clicked `Click to Start`, logged The Only Cure `Found and loaded local data`, `Added Hand_L to known amputated limbs for CJStorrs`, and `Applying data for CJStorrs`, then immediately hit `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)`. This proved replacing the global modData table before transmit was still not enough.
  - Next TOC fix committed as `4ad14fa` (`feat(4.19)/skip-only-cure-sp-transmit`): keep the sanitized/replaced TOC modData table, but only call `ModData.transmit(key)` when `isClient()` is true. The active test save is single-player, so there is no server target for the transmit; skipping it should avoid the B42.19 serializer path that crashes on this legacy save data while preserving multiplayer sync behavior.
  - Validation for `4ad14fa` passed: project and live `DataController.lua` syntax, CRLF-aware diff check, project/live file diff, live `42/mod.info` with `id=TheOnlyCureCjs`, no live `.git`, and no duplicate mixed-case `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsTheOnlyCure`.
  - 18:57 retest after `4ad14fa` still crashed. Evidence: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_18-57_DebugLog.txt` reached `WorldDictionary.init() end`, `game loading took 22 seconds`, and world entry, then logged The Only Cure `Found and loaded local data`, `Added Hand_L to known amputated limbs for CJStorrs`, and `Applying data for CJStorrs` before another `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)`. Because `ModData.transmit` was already skipped in SP, the remaining crash is likely the single-player global modData save path itself, not network transmit.
  - Next TOC fix committed as `ff34a40` (`feat(4.19)/migrate-only-cure-sp-data`): in single-player, read migrated flat player modData first, otherwise read the legacy global `TOC_<username>` table once; sanitize it into known primitive TOC fields; remove the unsafe legacy global modData key; persist TOC state only as flat scalar `player:getModData()` keys. Multiplayer keeps the existing global `ModData.add`/`ModData.transmit` flow.
  - Validation for `ff34a40` passed: project and live `DataController.lua` syntax, CRLF-aware diff check, project/live file diff, live `42/mod.info` with `id=TheOnlyCureCjs`, no live `.git`, and no duplicate mixed-case `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsTheOnlyCure`.
  - 19:05 retest after `ff34a40` still crashed. Evidence: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_19-05_DebugLog.txt` reached `WorldDictionary.init() end`, `game loading took 31 seconds`, and world entry. The log then showed `HandWeapon.randomizeFirearmAsLoot` null ammo-type NPE at lines 19042-19045, MTA auto-disable at line 19100, The Only Cure CJS `Found and loaded local data` at line 19135, `Applying data for CJStorrs` at line 19142, then `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)` starting at line 19143.
  - Important inference after `ff34a40`: this was still the first-run legacy global data path (`Found and loaded local data`, not `Found and loaded local player data`). The crash happens after `apply()`, so the next TOC fix should stop single-player `apply()` from writing save data during world entry and keep the sanitized table in memory. If that clears the hard crash, inspect the next fresh log for remaining actionable errors, especially `HandWeapon.randomizeFirearmAsLoot` null ammo-type NPE, `Neon moodle levels` nil-call at `neonMoodleLevels.lua:120`, and MTA auto-disable if they persist as standalone issues.
  - Next TOC fix committed as `2d4983a` (`feat(4.19)/skip-only-cure-sp-apply-persistence`): `DataController:apply()` now sanitizes `self.tocData` and returns immediately in single-player, so world-entry TOC damage/heal handling keeps the state in memory without writing player/global modData or triggering the B42.19 Kahlua serializer path. Multiplayer still replaces and transmits global modData.
  - Validation for `2d4983a` passed: project and live `DataController.lua` syntax, CRLF-aware diff check, project/live file diff, live `42/mod.info` with `id=TheOnlyCureCjs`, no live `.git`, and only one live TOC folder: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjstheonlycure`.
  - Historical live-install caveat: this predates the current symlink workflow. Future TOC live repairs should use `link-project-mod.sh cjsTheOnlyCure`, which links to the project folder using project casing.
  - 19:13 retest after `2d4983a` still crashed. Evidence: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_19-13_DebugLog.txt` reached `game loading took 30 seconds`; after Click-to-Start it logged the `HandWeapon.randomizeFirearmAsLoot` null ammo-type NPE at 19:17:27, MTA auto-disable at 19:17:28, TOC `Found and loaded local data` at 19:17:29.120 and `Applying data for CJStorrs` at 19:17:29.131, then `Unhandled java.lang.StackOverflowError` in `KahluaTableImpl.save(...)` at 19:17:29.172. Since `apply()` was already a single-player no-op, the remaining TOC suspect is the earlier single-player startup/schema path that still wrote/removes modData after `Found and loaded local data`.
  - Next TOC fix committed as `c84217c` (`feat(4.19)/avoid-only-cure-sp-save-writes`): removed the remaining single-player `RemoveGlobalModData(...)` and `WriteLocalPlayerData(...)` calls from `setup()`, `ensureCurrentSchema()`, and `applyOnlineData()`. In single-player TOC now reads/sanitizes legacy data and keeps it in memory during startup/world-entry; multiplayer still uses global modData replacement/transmit.
  - Validation for `c84217c` passed: project and live `DataController.lua` syntax, CRLF-aware diff check, project/live file diff, live `42/mod.info` with `id=TheOnlyCureCjs`, no live `.git`, and only one live TOC folder: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjstheonlycure`.
  - 19:19 retest after `c84217c` still crashed. Evidence: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_19-19_DebugLog.txt` reached `WorldDictionary.init() end` at line 17048 and `game loading took 30 seconds` at line 17561. After Click-to-Start it logged MTA auto-disable at line 19077, `Error: Too many physics objects on gridsquare: 5176, 15489, 0` at line 19109, The Only Cure `Found and loaded local data` at line 19112, `Applying data for CJStorrs` at line 19119, then `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)` at line 19120.
  - New important evidence from the same 19:19 log: `PlayerDB.loadPlayer` threw `BufferUnderflowException` before world entry, immediately after `InventoryItem.loadItem() data length not matching` for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`. The player record then continues far enough to world entry, but this makes the hard crash suspect broader than global TOC modData: the runtime may be saving a partially loaded or cyclic player/item/object modData table.
  - Save-file evidence: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-06-27_21-27-42/global_mod_data.bin` contains a `TOC_CJStorrs` table. Parsing the block table shows 62 global entries and `TOC_CJStorrs` as entry 57 with 2222 bytes of table payload. The on-disk TOC table appears primitive rather than cyclic; it records `Hand_L.isCut=true`, `Hand_L.isVisible=true`, and `Top_L.isProstEquipped=true`.
  - Save-file evidence: active `players.db` and `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-06-27_21-27-42_backup/players.db` are byte-for-byte identical, so restoring that backup will not fix the 19:19 player-load underflow. The local player row is `CJ Storrs`, position roughly `5112.85,15502.37,2`, worldversion `238`, data blob length `44138`, alive.
  - Next TOC diagnostic/fix committed as `797ef08` (`feat(4.19)/skip-only-cure-sp-apply-work`): in single-player, `DataController:apply()` returns before logging, rebuilding, replacing, or transmitting any TOC data. Multiplayer behavior remains unchanged. This retest boundary should prove whether the crash is directly caused by `apply()`/TOC event state or by the subsequent player save path.
  - Validation for `797ef08` passed: project and live `DataController.lua` syntax, project/live file diff clean, CRLF count remains zero, live `42/mod.info` has `id=TheOnlyCureCjs`, no live `.git`, and active save/default plus the `b42-4` preset use `TheOnlyCureCjs`. Old installed/preset references to non-CJS `TheOnlyCure` exist outside the active Continue path and are not part of this blocker.
  - 19:41 retest after the broader Universal Gun Repair list cleanup still crashed. Fresh log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_19-41_DebugLog.txt`. Evidence: `WorldDictionary.init() end` at line 17048, `PlayerDB.loadPlayer` `BufferUnderflowException` after the same `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L` item length mismatches at lines 17527-17531, `game loading took 30 seconds` at line 17561, MTA auto-disable at line 19078, `unknown command:TWF_GC.ApplyOptions` at line 19108, `Too many physics objects` at line 19110, TOC `Found and loaded local data` at line 19113, then `Unhandled java.lang.StackOverflowError` at line 19120. There was still no TOC `Applying data` marker, confirming `apply()` is not the direct trigger.
  - The 19:41 log still prints unknown `UniversalGunRepair.*` sandbox options at lines 14065-14073 even though all text load lists and text sandbox presets are clean. Treat those as active-save sandbox metadata unless a safe editable source is found; do not re-add Universal Gun Repair.
  - Next TOC diagnostic/fix committed as `c9a354a` (`feat(4.19)/remove-only-cure-legacy-sp-global-data`): when single-player falls back to legacy global TOC data (`ModData.get(key)`), TOC now sanitizes the data into the controller and then removes the legacy global modData key. Multiplayer still keeps the existing global modData replace/transmit behavior.
  - Validation for `c9a354a` passed: project and live `DataController.lua` syntax, project/live file diff clean, `git diff --check`, live `42/mod.info` has `id=TheOnlyCureCjs`, and live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjstheonlycure` has no `.git`.
  - 19:46 retest after `c9a354a` still crashed. Fresh log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_19-46_DebugLog.txt`. Evidence: TOC logged `Found and loaded local data`, `Removed legacy single-player global data`, completed amputated-limb cache calculation, and logged `Calculated hand feasibility: L/R`, then hit `Unhandled java.lang.StackOverflowError` in `KahluaTableImpl.save(...)`. This proves removing the legacy global TOC key is not sufficient.
  - Next TOC fix committed as `6fac7ca` (`feat(4.19)/guard-only-cure-interact-keybind`): `CachedDataHandler.OverrideBothHandsFeasibility()` now reads the current Interact key once, caches it, and only calls `getCore():addKeyBinding(...)` when the key actually needs to change. This avoids the no-op B42.19 keybinding write that happened immediately after the last successful TOC log line.
  - Validation for `6fac7ca` passed: project and live `CachedDataHandler.lua` syntax, project/live file diff clean, `git diff --check`, live `42/mod.info` still has `id=TheOnlyCureCjs`, live TOC has no `.git`, and the touched handler was normalized to LF line endings.
  - 19:53 retest after `6fac7ca` still crashed. Fresh log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_19-53_DebugLog.txt`. Evidence: the keybinding guard avoided any `Disabling interact key` / keybinding rewrite logs, but the crash still occurred after TOC `Calculated hand feasibility: L/R`, so the keybinding write was not the root cause.
  - New stronger hypothesis: the hard crash is tied to the player-load corruption that always precedes world entry. Every fresh log has the same three `InventoryItem.loadItem() data length not matching` items (`Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, `TOC.Prost_HookArm_L`), then `PlayerDB.loadPlayer` underflows in `BodyDamage.load`, then the first save path crashes in `KahluaTableImpl.save(...)`.
  - WorldDictionary clue: active `WorldDictionaryReadable.lua` currently records these and many other modded items under `modID = "2VCESSPONGIESEXPANSION"` after `WorldDictionaryLog.lua` `modchange_item` entries moved them from their original mod IDs. Do not manually edit binary WorldDictionary files; treat this as context for save/load drift.
  - Active-save cleanup committed as `66f8458` in `cjsZombieCountGuard` (`feat(4.19)/remove-corrupt-player-load-items`): because `cjsZombieCountGuard` is already active in the save/default/preset path, it now runs a one-shot B42 save cleanup on `OnCreatePlayer`, `OnGameStart`, and early `OnTick`, removing only the three player-load problem item types after clearing hand/worn references. It writes a primitive player modData marker `CJS_B42_SaveCleanup_20260630_PlayerLoadItems` and logs `[CJS B42 Save Cleanup] ...` counts.
  - Validation for `66f8458` passed: project and live `CJS_B42SaveCleanup.lua` syntax, project/live diff clean, live `42/mod.info` has `id=cjsZombieCountGuard`, live folder has no `.git`, and `cjsZombieCountGuard` remains active in save/default/preset lists.
- Latest user steering: `UniversalGunRepair` failed to load after the post-batch launch. User explicitly said the mod is no longer needed and should be removed from the loadout rather than fixed.
- Removed exact active ID `2899457928/UniversalGunRepair` from every `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/*/*/mods.txt`, `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/default.txt`, and `/media/cjstorrs/windows/Users/cjsto/Zomboid/Lua/pz_modlist_settings.cfg`.
- Follow-up cleanup after user reiterated save/default/preset removal: removed the exact semicolon token `UniversalGunRepair` from `/media/cjstorrs/windows/Users/cjsto/Zomboid/Lua/saved_modlists.txt`, `/media/cjstorrs/windows/Users/cjsto/Zomboid/Lua/saved_modlists_server.txt`, and `/media/cjstorrs/windows/Users/cjsto/Zomboid/Lua/modmanager-mods.txt`. Also removed stale `UniversalGunRepair.*` lines from the text sandbox presets under `/media/cjstorrs/windows/Users/cjsto/Zomboid/Lua/Sandbox Presets/`.
- Verification after removal: `rg -n "UniversalGunRepair|2899457928"` across save `mods.txt`, default, `pz_modlist_settings.cfg`, saved modlists, Mod Manager's mod list, and sandbox presets returned no matches. A control search still finds `UniversalRepairAnything`, confirming the similarly named active repair mod was not removed.
- Leave WorldDictionary files alone when removing a mod from the loadout; they are save dictionary/history artifacts, not active load lists.
- The 17:42 relaunch cleared the UGR load failure: the newest log no longer loads `UniversalGunRepair`.
- Remaining UGR fallout in older logs was save sandbox metadata only: unknown `UniversalGunRepair.*` sandbox options printed after Continue. Safe text sandbox presets are now cleaned; do not re-add the mod for this and do not edit binary save files blindly if old save dictionary/history references remain.
- Current hard blocker is a WorldDictionary crash in `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_17-42_DebugLog.txt`: `Cannot override existing registry id (186) to new id (11316), item: Base.CuredChickenWing`.
- Root cause: `LongTermPreservationExtended` was installed directly from Workshop as current B42.13, but that payload changed its save-facing item module from `Skittles.*` in `42.12` to `Base.*` in `42.13`. The active save already has old `Skittles.*` items in the WorldDictionary, so B42.19 registering the same items as `Base.*` collides.
- This became a real save-compatibility content fix, so `LongTermPreservationExtended` is now project-owned despite the earlier direct-Workshop install.
- Imported the current live/Workshop payload into `/home/cjstorrs/projects/game-mods/zomboid/LongTermPreservationExtended` on branch `feat(4.19)/long-term-preservation-save-ids`; baseline commit `f6fdfa8` (`feat(4.19)/import-long-term-preservation-extended-baseline`).
- Fix commit `8d54d12` (`feat(4.19)/preserve-long-term-preservation-item-ids`) changes active `42.13/media/scripts` modules from `Base` back to `Skittles`, rewrites only LongTermPreservationExtended-defined item references back to `Skittles.*`, and updates `42.13/media/lua/shared/Foraging/forageable_items.lua` from `Base.SaltRock` to `Skittles.SaltRock`.
- Vanilla recipe ingredients such as `Base.Beef`, `Base.EmptyJar`, and `Base.Salt` were intentionally preserved as `Base.*`.
- Live sync completed to lowercase `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/longtermpreservationextended`; previous live copy moved to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/longtermpreservationextended-pre-save-id-fix`.
- Validation passed before relaunch: project/live `diff -qr --exclude=.git` clean, no live `.git`, `id=LongTermPreservationExtended` and `require=\SKITTLE_LongTermPreservation` preserved, no `Base.*` references remain for LongTermPreservationExtended-defined 42.13 items, `lua5.1 loadfile` passed for the foraging Lua, and `git -c core.whitespace=cr-at-eol diff --check` passed.
- Do not edit save `WorldDictionary*.lua/bin` or `WD_ERROR_*` backups; they are evidence/history, not the fix.
- The 17:55 relaunch confirmed `LongTermPreservationExtended` is fixed: `WorldDictionary.init() end` appears at 17:57 and the prior `Base.CuredChickenWing` registry conflict does not return.
- The save reached `Click to Start`, then the world started and crashed in runtime UI/player update.
- Nonfatal but notable load warnings before world entry:
  - `InventoryItem.loadItem() data length not matching` for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.
  - `PlayerDB.loadPlayer` threw `BufferUnderflowException` in `BodyDamage.load`, but the game still reached world startup.
- First actionable runtime blocker was `cjsFurnitureStorageBoost`: `effectiveCapacityForCharacter(CJS_FurnitureStorageBoost.lua:620)` called `character:getTraits()` when CleanUI/SmarterStorage inventory refresh passed an unsafe character value.
- Fixed `cjsFurnitureStorageBoost` on branch `feat(4.19)/guard-furniture-storage-traits`, commit `d04173a` (`feat(4.19)/guard-furniture-storage-trait-capacity`), by adding a guarded `pcall`-based trait lookup and preserving Organized/Disorganized capacity behavior only when traits are available.
- `cjsFurnitureStorageBoost` live sync completed through the old CJS installer; this predates the current `link-project-mod.sh cjsFurnitureStorageBoost` symlink workflow. At that time `id=cjsFurnitureStorageBoost` was preserved and Lua syntax passed.
- Second runtime stack in the same run was `More Traits. ComputerPers FIX`: `Blissful(MoreTraits.lua:1411)` called nil from `MainPlayerUpdate`. If it recurs after the furniture fix, patch More Traits next.
- The final hard crash in the 17:55 run was `Unhandled java.lang.StackOverflowError` while saving a Kahlua table shortly after TheOnlyCureCjs loaded local player data (`Applying data for CJStorrs`). If it recurs after the furniture fix and More Traits fix, inspect cyclic modData from the player/update path, especially TheOnlyCureCjs and any mod that writes tables during `OnPlayerUpdate`.
- 18:02 relaunch/retest log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_18-02_DebugLog.txt`.
  - Continue click initially did not take; screenshot showed main menu. Re-clicking Continue at active 2560x1440 window coordinate `(356,766)` loaded the save.
  - `WorldDictionary.init() end` appears at line 17048, so the LongTermPreservationExtended save-ID fix still holds.
  - Game reached `game loading took 25 seconds`, then clicking `Click to Start` at `(1280,1302)` entered world startup.
  - Universal Gun Repair is no longer active in load points; any remaining `UniversalGunRepair` hits under `WorldDictionary*.lua`, `WorldDictionaryLog.lua`, or `WD_ERROR_*` are save dictionary/history evidence and must not be treated as active load-list entries.
  - `cjsFurnitureStorageBoost` still errors after the first fix: the `pcall` trait probe logs `Object tried to call nil in pcall` at `CJS_FurnitureStorageBoost.lua:619`, then `characterHasTrait` and `effectiveCapacityForCharacter` at lines `618/631/632`. Kahlua logs Java/userdata method failures even through `pcall`; patch this to use direct B42 `character:HasTrait("Organized"/"Disorganized")` instead of `getTraits():contains(...)`.
  - `More Traits. ComputerPers FIX` still errors: `Blissful(MoreTraits.lua:1411)` from `MainPlayerUpdate(MoreTraits.lua:4523)` throws `Object tried to call nil`. The failing line is `bodydamage:getUnhappynessLevel()` after `PlayerDB.loadPlayer` has already thrown a `BodyDamage.load` buffer underflow, so treat BodyDamage as hostile/unreliable on this save and guard the mood update path.
  - `Neon moodle levels` now appears as a repeated UI-draw error: `update(neonMoodleLevels.lua:120)` from both `onPreUIDraw(neonMoodleLevels.lua:377)` and `onPostUIDraw(neonMoodleLevels.lua:381)`. Live folders include `neonMoodleIndicator` and `neonMoodleIndicatorVertical`; inspect live first and check Workshop before importing.
  - `Milk Them All` logs `[MTA] ERROR [AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed and has been permanently disabled: null java.lang.StackOverflowError`.
  - Final hard crash recurred as `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)`. Keep investigating after clearing the concrete Lua/UI stacks unless it remains the only blocker.
- Immediate next actions:
  - `cjsFurnitureStorageBoost` second-pass fix is committed as `862f235` (`feat(4.19)/use-direct-storage-trait-checks`) on branch `feat(4.19)/guard-furniture-storage-traits`.
    - Changed `characterHasTrait` to reject non-`IsoGameCharacter` values and call `character:HasTrait(trait)` directly.
    - Removed the noisy `pcall(function() character:getTraits():contains(...) end)` path because Kahlua still logged failures through `pcall`.
    - Validation passed under the old copy workflow: project syntax, CRLF-aware diff check, live syntax, live `id=cjsFurnitureStorageBoost`, and project/live file diff clean. Current relinks should use `link-project-mod.sh cjsFurnitureStorageBoost`.
  - `CP_MoreTraits` BodyDamage guard fix is committed as `16c1b18` (`feat(4.19)/guard-more-traits-body-damage`) on branch `feat(4.19)/workshop-update`.
    - Added `MT_GetBodyDamage`.
    - `Blissful` now checks `MT_HasTrait(player, "blissful")` before touching BodyDamage and returns if BodyDamage is missing.
    - Adjacent depression/self-harm/antigun/alcoholism mood writes now reuse the guarded BodyDamage path.
    - Validation passed: project syntax, CRLF-aware diff check, copied changed `42/media/lua/client/MoreTraits.lua` to live `CP_MoreTraits`, live syntax, project/live file diff clean, live `id=CP_MoreTraits`, and no live `.git`.
  - Relaunch and retest next. If these two stacks are clear, handle Neon Moodle Levels next, then the remaining StackOverflow/modData issue.
- Latest active log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_17-13_DebugLog.txt`, which cleared RebalancedYieldsButchering and stopped on `ScavengingSkill [B42]`: `ScriptManager.Load FileNotFoundException` for `/mods/scavengingskill [b42]/42/media/scripts/scavengerskillitems.txt`.
- Enabled-mod batch direct Workshop live-only installs completed:
  - `StarlitLibrary` from Workshop `3378285185` to lowercase live `starlitlibrary`; existing project repo is not authoritative unless a future real local edit is added.
  - `SIMBA_TheySEEyou` from Workshop `3609311749` to lowercase live `simba_theyseeyou`.
  - `WeightlessKeys42` from Workshop `3526523796` to lowercase live `weightlesskeys42`.
  - `2899457928/UniversalGunRepair` from Workshop `2899457928` to lowercase live `universalgunrepair`.
  - `SimpleOverhaulTraitsAndOccupations` from Workshop `2840805724` to lowercase live `simpleoverhaultraitsandoccupations`; existing project repo is not authoritative unless a future real local edit is added.
  - `StairsEastSouth` from Workshop `3557652317` to lowercase live `stairseastsouth`.
  - `StandardizedVehicleUpgrades3V` from Workshop `3304582091` to lowercase live `standardizedvehicleupgrades3vanilla`.
  - `Vanilla_MRE_42` from Workshop `3100032203` to lowercase live `vanilla mre - main - b42`.
  - `Waterpipes` from Workshop `3546314080` to lowercase live `waterpipes`; only active `WaterPipes (1)` was replaced because other similarly named folders have different IDs.
  - `Willowbrook Bastion! (items part)` from Workshop `3479667649` to lowercase live `willowbrook bastion! (items part)`.
  - `TombWardrobeALTVanilla` from Workshop `3616536783` to lowercase live `tomb's wardrobe - alternative - vanilla`; existing project repo is not authoritative unless a future real local edit is added.
- Enabled-mod batch project-owned fixes completed:
  - `Bug Zapper 9000`: branch/commit `adf753d` (`feat(4.19)/lowercase-bug-zapper-live-folder`), lowercase live `bug zapper 9000`.
  - `InfiniteSearchMode`: branch/commit `d4e6340` (`feat(4.19)/lowercase-infinite-search-live-folder`), lowercase live `infinitesearchmode`.
  - `TearAllClothes`: branch/commit `a45b98e` (`feat(4.19)/lowercase-tear-all-clothes-live-folder`), lowercase live `tearallclothes`.
  - `ScavengingSkill [B42]`: branch/commit `bb3089e` (`feat(4.19)/lowercase-scavenging-skill-script-paths`), lowercased `42/media/scripts/ScavengerSkillItems.txt`, lowercase live `scavengingskill [b42]`.
  - `ShelterHold_Beehive`: branch/commit `1d3fab7` (`feat(4.19)/lowercase-shelterhold-beehive-script-paths`), lowercased active `common/media/scripts` directories/files, lowercase live `shelterhold_beehive`.
  - `SimpleShortSpears`: branch/commit `42a9e05` (`feat(4.19)/lowercase-simple-short-spears-live-folder`), lowercase live `simpleshortspears`.
  - `SimpleSilencersCjs`: imported live-only local fork into project `SimpleSilencers`, baseline commit `8823fa4` (`feat(4.19)/import-simple-silencerscjs-live-baseline`), then branch/commit `49c868b` (`feat(4.19)/lowercase-simple-silencers-script-paths`), lowercase live `simplesilencers`.
  - `TakeABathAndShower42`: branch/commit `26aef54` (`feat(4.19)/lowercase-take-a-bath-live-folder`), lowercase live `take a bath and shower`.
  - `VanillaFoodsExpanded`: branch/commit `2ee57f5` (`feat(4.19)/lowercase-vanilla-foods-expanded-live-folder`), lowercase live `vanilla foods expanded`; pre-existing untracked `.dreamers/` remains in the project repo and was not staged.
  - `Video_Game_Consoles`: branch/commit `c3bc7a8` (`feat(4.19)/lowercase-video-game-consoles-script-paths`), lowercased active script filenames, lowercase live `video game consoles`.
  - `UndeadSurvivor42`: branch/commit `fe01f78` (`feat(4.19)/lowercase-undead-survivor-script-paths`), lowercased active script filenames, lowercase live `undead survivor`.
  - `VorpallySauced`: branch/commit `d4b7244` (`feat(4.19)/lowercase-vorpallysauced-live-folder`), lowercase live `vorpallysauced`.
- Batch validation passed:
  - No live `.git` folders under `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods`.
  - Corrected enabled-mod scan reports no missing active IDs and no actionable root/`media/scripts` casing rows.
  - Project-owned live syncs are `diff -qr --exclude=.git` clean.
  - Direct Workshop installs have no non-`media/scripts` drift from Workshop after filtering for expected case-only script path changes.
  - Touched live Lua files pass `lua5.1 loadfile` syntax checks.
  - Active IDs are preserved in touched live `mod.info` files.
- The 16:30 retest cleared `LongTermPreservationExtended` / `SKITTLE_LongTermPreservation` and stopped on `Louder Noisemakers + Extended Range Remotes`: `ScriptManager.Load FileNotFoundException` for `/mods/louder noisemakers + extended range remotes/42/media/scripts/lsmrr/items.txt` at log lines 9788-9789.
- `Louder Noisemakers + Extended Range Remotes` has now been fixed as project-owned, not direct-Workshop, because the project has intentional local compatibility commits (`0178f37`, `6e8f4cf`) and differs from Workshop in `42/media/lua/server/LSMRR/Events.lua`. Branch `feat(4.19)/lowercase-lsmrr-script-paths`, commit `0deb0bb` (`feat(4.19)/lowercase-lsmrr-script-paths`), lowercased `42/media/scripts/LSMRR` to `42/media/scripts/lsmrr` and lowercased legacy root script filenames.
- LSMRR live sync completed: moved old live `Louder Noisemakers + Extended Range Remotes` to disabled holding and synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/louder noisemakers + extended range remotes`.
- LSMRR validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, failed 16:30 path exists, no uppercase path components remain under project/live `media/scripts`, project Lua files pass `lua5.1 loadfile`, CRLF-aware `git diff --check` passed, and `id=LSMRR` plus `require=\StarlitLibrary` are preserved.
- The 16:38 retest cleared LSMRR and stopped on `Mad Max 2 Pursuit Special [fhq]`: `ScriptManager.Load FileNotFoundException` for `/mods/mad max 2 pursuit special [fhq]/42.0/media/scripts/vehicles/fhqmm2ps.txt` at log lines 9788-9789.
- `Mad Max 2 Pursuit Special [fhq]` uses the corrected direct-Workshop workflow: no project repo exists, live and Workshop were identical before the casing fix, and active save/default/preset entries use `id=MM2PursuitSpecial`. Old live `Mad Max 2 Pursuit Special [fhq]` was moved to disabled holding, Workshop cache `3017359186/mods/Mad Max 2 Pursuit Special [fhq]` was copied directly to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/mad max 2 pursuit special [fhq]`, and only live script filenames were lowercased under active `42.0/media/scripts/vehicles` and legacy root `media/scripts/vehicles`.
- Mad Max validation passed: failed 16:38 path exists, no live `.git`, no uppercase path components remain under live `media/scripts`, live Lua files pass `lua5.1 loadfile`, `id=MM2PursuitSpecial` is preserved, and live-vs-Workshop differs only by expected script filename case pairs. The installed companion `Mad Max 2 Pursuit Special SVU [fhq]` was left unchanged because it is not enabled in the active save/default list.
- The 16:41 retest cleared Mad Max and stopped on `ManageContainers`: `ScriptManager.Load FileNotFoundException` for `/mods/managecontainers/42/media/scripts/clothing/claire_item.txt` at log lines 9788-9789.
- `ManageContainers` has been fixed as project-owned, not direct-Workshop, because the project has intentional local commit `63e1140` (`Guard container transfer data`), live matched the project before the fix, and Workshop differs materially. Branch `feat(4.19)/lowercase-managecontainers-script-paths`, commit `59b0564` (`feat(4.19)/lowercase-managecontainers-script-paths`), lowercased active and legacy script filenames: `ManageContainers.txt`, `claire_Item.txt`, and `claire_Model.txt`.
- ManageContainers live sync completed: moved old live `ManageContainers` to disabled holding and synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/managecontainers`.
- ManageContainers validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, failed 16:41 path exists, no uppercase path components remain under project/live `media/scripts`, project Lua files pass `lua5.1 loadfile`, CRLF-aware `git diff --check` passed, and `id=manageContainers` is preserved.
- The 16:44 retest cleared ManageContainers and stopped on `MilitaryPonchosRELOADED`: `ScriptManager.Load FileNotFoundException` for `/mods/militaryponchosreloaded/42/media/scripts/clothing/ak_clothing_jacket.txt` at log lines 9788-9789.
- `MilitaryPonchosRELOADED` uses the corrected direct-Workshop workflow: no project repo exists, Workshop cache `3439247001/mods/MilitaryPonchosRELOADED` is newer than old live, and `id=MilitaryPonchosRELOADED` is preserved. Old live `MilitaryPonchosRELOADED` was moved to disabled holding, Workshop was copied directly to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/militaryponchosreloaded`, and only live script filenames were lowercased under active `42/media/scripts/clothing`.
- Military Ponchos validation passed: active Workshop-current path `/42/media/scripts/clothing/mponchos.txt` exists, no live `.git`, no uppercase path components remain under live `media/scripts`, live Lua files pass `lua5.1 loadfile`, `id=MilitaryPonchosRELOADED` is preserved, and live-vs-Workshop differs only by expected script filename case pairs. The old `AK_clothing_jacket.txt` file existed only in stale live and is no longer part of the Workshop-current payload.
- The 16:46 retest cleared Military Ponchos and stopped on `More Traits`: `ScriptManager.Load FileNotFoundException` for `/mods/more traits/42.17/media/scripts/toadrecipes.txt` at log lines 9788-9789.
- `More Traits` has been fixed as project-owned, not direct-Workshop, because the project already had local B42.19 compatibility commits (`e0292d0`, `6473ce4`, `df3991d`, `012bcb8`), live matched the project before the fix, and Workshop differs materially. Branch `feat(4.19)/lowercase-more-traits-script-paths`, commit `e8421d1` (`feat(4.19)/lowercase-more-traits-script-paths`), lowercased all `ToadRecipes.txt`, `ToadTems.txt`, and `ToadTraits.txt` script filenames under active and legacy `media/scripts` roots.
- More Traits live sync completed: moved old live `More Traits` to disabled holding and synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/more traits`.
- More Traits validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, failed 16:46 path exists, no uppercase path components remain under project/live `media/scripts`, project Lua files pass `lua5.1 loadfile`, CRLF-aware `git diff --check` passed, and active IDs are preserved (`1299328280/ToadTraits`, root `ToadTraits`).
- The 16:49 retest cleared More Traits and stopped on `MorePlushies`: `ScriptManager.Load FileNotFoundException` for `/mods/moreplushies/42/media/scripts/moreplushies_items.txt` at log lines 9788-9789.
- `MorePlushies` has been fixed as project-owned, not direct-Workshop, because the project has intentional local loot/capsule commits and Workshop differs materially. Branch `feat(4.19)/lowercase-moreplushies-script-paths`, commit `7e99f30` (`feat(4.19)/lowercase-moreplushies-script-paths`), lowercased active script filenames: `MorePlushies_Items.txt`, `MorePlushies_models_Items.txt`, and `MorePlushies_Recipes.txt`.
- MorePlushies live sync completed: moved old live `MorePlushies` to disabled holding and synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/moreplushies`.
- MorePlushies validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, failed 16:49 path exists, no uppercase path components remain under project/live `media/scripts`, project Lua files pass `lua5.1 loadfile`, CRLF-aware `git diff --check` passed, and `id=MorePlushies` plus `require=\NepEasyDistro` are preserved.
- The 16:57 retest cleared MorePlushies and stopped on `N&C's Narcotics`: `ScriptManager.Load FileNotFoundException` for `/mods/n&c's narcotics/42/media/scripts/nnc_glassmakingrecipes.txt` at log lines 9788-9789.
- `N&C's Narcotics` uses the corrected direct-Workshop workflow: the project repo only contained an import plus `2e93762` (`Update N&C's Narcotics from Windows workshop cache for 42.19`), project/live/Workshop compared clean before the casing fix, and active save/default/preset entries use `id=N&CsNarcotics`. The project repo is not authoritative unless a future real local edit is added.
- N&C's Narcotics live install completed: moved old live `N&C's Narcotics` to disabled holding, copied Workshop cache `3404956403/mods/N&C's Narcotics` directly to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/n&c's narcotics`, and only live script filenames were lowercased under active `42/media/scripts`.
- N&C's Narcotics validation passed: failed 16:57 path exists, no live `.git`, no uppercase path components remain under live `media/scripts`, live Lua files pass `lua5.1 loadfile`, `id=N&CsNarcotics` and `require=\MoodleFramework` are preserved, and live-vs-Workshop differs only by expected script filename case pairs.
- The 17:00 retest cleared N&C's Narcotics and stopped on `PIE42`: `ScriptManager.Load FileNotFoundException` for `/mods/pie42/common/media/scripts/pie_printmedia.txt` at log lines 9788-9789. The same log also emitted `require("Maps/ISMapDefinitions") failed` from `PIE_MapDefinitions.lua`; retest after the script-path fix before deciding whether that warning is still actionable.
- `PIE42` has been fixed as project-owned, not direct-Workshop, because project/live contained an existing `common/media/maps/PIElots/map.info` title fix (`title=PIElots`) that differs from Workshop and is already live. Existing fix committed as `e8fd38f` (`feat(4.19)/pie-map-folder-case`).
- PIE42 script-path fix completed on branch `feat(4.19)/lowercase-pie-script-paths`, commit `bfa9d21` (`feat(4.19)/lowercase-pie-script-paths`), lowercasing `common/media/scripts/PIE_printmedia.txt` to `common/media/scripts/pie_printmedia.txt`.
- PIE42 live sync completed: moved old live `PIE42` to disabled holding and synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/pie42`.
- PIE42 validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, failed 17:00 path exists, no uppercase path components remain under project/live `media/scripts`, project Lua files pass `lua5.1 loadfile`, CRLF-aware `git diff --check` passed, worktree is clean, and active IDs are preserved (`PIE42` in `42.0/mod.info` and `common/mod.info`).
- The 17:03 retest cleared PIE42 and stopped on `ProjectArcade`: `ScriptManager.Load FileNotFoundException` for `/mods/projectarcade/42.15/media/scripts/entities/entity_obsolete.txt` at log lines 9788-9789. The same log also emitted `require("TimedActions/ISWalkToTimedAction") failed` warnings from several ProjectArcade Lua files; retest after the script-path fix before deciding whether those warnings are still actionable.
- `ProjectArcade` has been fixed as project-owned, not direct-Workshop, because it has intentional local B42 compatibility commits (`4bb6d18`, `29cad0f`, `ebd5826`, `b25a6c`, `50955d9`) and differs materially from Workshop. Project/live compared clean before the casing fix.
- ProjectArcade script-path fix completed on branch `feat(4.19)/lowercase-projectarcade-script-paths`, commit `f17be4e` (`feat(4.19)/lowercase-projectarcade-script-paths`), lowercasing all active uppercase filenames under project `media/scripts`: versioned `entity_OBSOLETE.txt`, common `ProjectArcade_Craft.txt`, common sound scripts, and common item scripts.
- ProjectArcade live sync completed: moved old live `ProjectArcade` to disabled holding and synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/projectarcade`.
- ProjectArcade validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, failed 17:03 path exists, no uppercase path components remain under project/live `media/scripts`, project Lua files pass `lua5.1 loadfile`, CRLF-aware `git diff --check` passed, worktree is clean, and `id=ProjectArcade` is preserved across `42`, `42.13`, and `42.15`.
- The 17:06 retest cleared ProjectArcade and stopped on `Rain's Firearms & Gun Parts - More Combos`: `ScriptManager.Load FileNotFoundException` for `/mods/rain's firearms & gun parts - more combos/42/media/scripts/rfngp_fixing.txt` at log lines 9788-9789.
- `Rain's Firearms & Gun Parts - More Combos` has been fixed as project-owned, not direct-Workshop, because it has intentional local B42.19 compatibility commit `997e507` (`feat(4.19)/more-combos-item-types`) and differs materially from Workshop. Project/live compared clean before the casing fix.
- More Combos script-path fix completed on branch `feat(4.19)/lowercase-rain-more-combos-script-paths`, commit `963b0d8` (`feat(4.19)/lowercase-rain-more-combos-script-paths`), lowercasing all active uppercase filenames under `42/media/scripts`: `RFNGP_fixing.txt` plus the `RFNGPEX_*` script files.
- More Combos live sync completed: moved old live `Rain's Firearms & Gun Parts - More Combos` to disabled holding and synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/rain's firearms & gun parts - more combos`.
- More Combos validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, failed 17:06 path exists, no uppercase path components remain under project/live `media/scripts`, project Lua files pass `lua5.1 loadfile`, CRLF-aware `git diff --check` passed, worktree is clean, and `id=B42RainsFirearmsAndGunPartsMoreCombos` is preserved.
- The 17:09 retest cleared More Combos and stopped on `ReactiveSoundEvents`: `ScriptManager.Load FileNotFoundException` for `/mods/reactivesoundevents/common/media/scripts/sounds_rse.txt` at log lines 9788-9789.
- `ReactiveSoundEvents` uses the corrected direct-Workshop workflow: project/live/Workshop compared clean, the project repo only has import commit `34333f6` (`Import Reactive Sound Events legacy`), and active save/default/preset entries use `id=ReactiveSoundEvents`. The project repo is not authoritative unless a future real local edit is added.
- ReactiveSoundEvents live install completed: moved old live `ReactiveSoundEvents` to disabled holding, copied Workshop cache `2969551071/mods/ReactiveSoundEvents` directly to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/reactivesoundevents`, and only live script filenames were lowercased under active `media/scripts` paths.
- ReactiveSoundEvents validation passed: failed 17:09 path exists, no live `.git`, no uppercase path components remain under live `media/scripts`, live Lua files pass `lua5.1 loadfile`, `id=ReactiveSoundEvents` is preserved across `42` and `42.13`, and live-vs-Workshop differs only by expected script filename case pairs.
- The 17:11 retest cleared ReactiveSoundEvents and stopped on `RebalancedYieldsButchering`: `ScriptManager.Load FileNotFoundException` for `/mods/rebalancedyieldsbutchering/42/media/scripts/recipes/rybutchering_recipes_cooking.txt` at log lines 9788-9789.
- `RebalancedYieldsButchering` uses the corrected direct-Workshop workflow: no project repo exists, live and Workshop compared clean before the casing fix, and active save/default/preset entries use `id=RebalancedYieldsButchering`.
- RebalancedYieldsButchering live install completed: moved old live `RebalancedYieldsButchering` to disabled holding, copied Workshop cache `3564838872/mods/RebalancedYieldsButchering` directly to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/rebalancedyieldsbutchering`, and only the live script filename was lowercased under `42/media/scripts/recipes`.
- RebalancedYieldsButchering validation passed: failed 17:11 path exists, no live `.git`, no uppercase path components remain under live `media/scripts`, live Lua files pass `lua5.1 loadfile`, `id=RebalancedYieldsButchering` is preserved, and live-vs-Workshop differs only by the expected script filename case pair.
- Next action: relaunch B42.19 with the cache bridge, continue the active save, and inspect the newest log for the next actionable blocker.
- Workflow correction from user at 15:41 and repeated at 16:29: already-updated Workshop mods with no intentional local edits must be installed direct to live, not imported into `~/projects/game-mods/zomboid`. Frockin exposed the problem first; the rule applies to all third-party Workshop mods in this migration.
- Frockin mistake status:
  - `Frockin Splendor! Vol.2`: I mistakenly committed project branch `feat(4.19)/lowercase-frockin-splendor-vol2-script-paths` at `b254b39`, then started copying Workshop into the project. The unfinished project copy was cleaned; project checkout was returned to `feat(4.19)/body-location-compat`. Live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/frockin splendor! vol.2` is now a direct `rsync -a --delete` copy of Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3411888105/mods/Frockin Splendor! Vol.2`.
  - `Frockin Splendor! Vol.4`: I mistakenly committed project branch `feat(4.19)/lowercase-frockin-splendor-vol4-script-paths` at `ed77da0` and installed that project copy to live. Project checkout was returned to `feat(4.19)/workshop-update`. Live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/frockin splendor! vol.4` is now a direct `rsync -a --delete` copy of Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3475347500/mods/Frockin Splendor! Vol.4`; do not build further on the manual casing commit.
  - `Frockin Stompers!`: I started a casing branch but reverted the uncommitted changes before installing; project checkout was returned to `main`. Live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/frockin stompers!` is now a direct `rsync -a --delete` copy of Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3736813592/mods/Frockin Stompers!`.
  - `Frockin Stompers! Vanilla Footwear Replacer`: untouched by the mistaken project workflow. Live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/frockin stompers! vanilla footwear replacer` is now a direct `rsync -a --delete` copy of Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3736813592/mods/Frockin Stompers! Vanilla Footwear Replacer`.
  - 15:49 retest proved direct Workshop alone was not enough on Linux: B42.19 requested `/frockin splendor! vol.2/42.15/media/scripts/clothing/fs2_cotton.txt`, while Workshop had `42.15/media/Scripts/clothing/FS2_Cotton.txt`.
  - Applied live-only structure normalization to the four Frockin live folders: lowercased all `media/Scripts` directories to `media/scripts` and lowercased every file under those script trees. Do not copy this into the project repos; it is a live structure adaptation on top of Workshop-current payloads.
  - Validation passed after normalization: the 15:49 failed path now exists, no `media/Scripts` directories remain, no uppercase filenames remain under live `media/scripts`, all live Frockin Lua files pass `lua5.1 loadfile`, no live `.git` directories exist, and save-facing IDs are preserved (`GanydeBielovzki's Frockin Splendor! Vol.2`, `GanydeBielovzki's Frockin Splendor! Vol.4`, `GanydeBielovzki's Frockin Stompers!`, `GanydeBielovzki's Frockin Stompers! VFR`).
- Direct-Workshop audit is now active context below. Known mistakes/candidates are recorded here; continue classifying older project imports as they come up.
- Direct-Workshop audit queue created after user correction:
  - Answer to the user's direct question: yes, this mistake happened on other mods besides Frockin. The mistake was creating/importing project repos or commits for third-party Workshop payloads when the live result should have been Workshop-current plus live-only path normalization. Do not delete those historical repos during this pass, but do not use them as authority unless a later intentional local edit is identified.
  - Confirmed mistake: Frockin family. Live has been corrected to direct Workshop installs; wrong project branches/commits exist but must not be treated as source of truth.
  - `FixBlowTorchPropaneTank` has been corrected under the new rule: no pre-existing project/local edit was known, so live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/fixblowtorchpropanetank` was replaced from Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3044705007/mods/FixBlowTorchPropaneTank`. The previous project-patched live copy was moved to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/fixblowtorchpropanetank-pre-workshop-direct`. Only live script filenames were normalized lowercase (`OnCreate_RefillBlowTorch.txt`, `BlowTorch.txt`, `RefillBlowTorch.txt`) because the 15:27 log proved B42.19 requests lowercase script paths on this Linux run. Validation: Lua syntax passed, no live `.git`, `id=FixBlowTorchPropaneTank` preserved, no uppercase script filenames remain; live-vs-Workshop differs only by those script filename case changes.
  - Confirmed mistake: `KATTAJ1 Clothes Core` had been put in a project repo from Workshop (`8200eef Update KATTAJ1 Clothes Core from Windows workshop cache for 42.19`) even though no intentional local edit was identified. Live has been corrected to a direct Workshop install from `3470422050`, with live-only lowercase script filename normalization. Do not use the project repo as source of truth for the active save.
  - Correct direct-live application: `KATTAJ1 Military Pack` had no project repo and was proactively installed straight from Workshop `3470426196` to live, then live-only script filenames were lowercased. This matches the corrected rule.
  - Process-level mistake: `Big Salt` had no local project history and Workshop/live were identical before the casing fix, so under the corrected rule it should have been direct Workshop/live plus live-only normalization instead of a new project repo/commit. Live is currently correct; the project repo is not authoritative.
  - Process-level mistake: `B42Makefruitinjar` had no local project history and Workshop `3432006285` was the B42.19 base; live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/b42makefruitinjar` is Workshop-current except for required lowercase script filenames (`items_makefruitinjar.txt`, `models_x.txt`, `recipes_makefruitinjar.txt`). No live correction needed, but the project repo/commit should not be treated as authoritative under the corrected rule.
  - Process-level mistake: `[J&G] Neon Vandals Uniform` was identical to Workshop `3497172953` before the casing patch. Live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/[j&g] neon vandals uniform` is Workshop-current except for required lowercase script filenames. No live correction needed, but the project repo/commit should not be treated as authoritative under the corrected rule unless a real local edit is added later.
  - Process-level mistake: `AirCond42` had no project repo and live exactly matches Workshop `3449592259` with only the live folder root lowercased. No live correction needed, but the project repo/empty marker commit should not be treated as authoritative under the corrected rule.
  - Additional process-level mistakes identified from the anchor: `Computer`, `DJG_BoundMaterials`, `DonazosFisticuffs`, `EasyOutfits`, `ExtraBooks`, and `AutoTurret` were imported/patched in project repos even though their anchor entries say Workshop and live matched before the casing fix. Their live installs are currently usable, but those project repos are not authoritative unless a future real local edit is added.
  - Additional confirmed process-level mistake: `N&C's Narcotics` had a project repo from Workshop (`2e93762`) with no identified intentional local edits. Live has been corrected to direct Workshop install plus live-only lowercase script filename normalization. Do not use the project repo as source of truth for the active save.
  - Additional confirmed process-level mistake: `ReactiveSoundEvents` had a project repo from Workshop/import (`34333f6`) with no identified intentional local edits. Live has been corrected to direct Workshop install plus live-only lowercase script filename normalization. Do not use the project repo as source of truth for the active save.
  - Correct direct-live applications after the correction include `KATTAJ1 Military Pack`, `Gun's Elevator`, `LegendaryBackpack`, `LegendaryFannypack`, `LongTermPreservationExtended`, and `SKITTLE_LongTermPreservation`.
  - Confirmed project-owned examples to preserve: CJS mods/forks, `HephasStalkerPDA`, Hot Brass, Immersive Preservation, Korkuluk's Gooner/Poster Tube, `Ladders`, `LegendaryDuffelbag`, and `LegendarySatchel`, because their anchor entries list intentional local edits or non-drop-in Workshop differences.
  - Continue auditing older vehicle/library imports whose only change may have been live-folder/script-path casing. Before reusing project repos such as `70dodge`, `73fordFalcon`, `91range`, `StandardizedVehicleUpgrades3Core`, or `tsarslib`, re-check Workshop vs local history and classify them under the direct-Workshop rule.
  - Do not assume the existing project commits are wrong; classify each as: direct Workshop install now, preserve local project because of intentional edits/save compatibility, or leave as-is because Workshop is not a drop-in replacement.
- `Gun's Elevator` was fixed after the 15:50 retest. Latest fixed blocker:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/gun's elevator/42/media/scripts/entities/furniture/entity_elevator_altdoor.txt`.
- `Gun's Elevator` had no project repo and no known intentional local edits. Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3411580812/mods/gun's elevator` is newer than old live: it replaces the old `42/` layout with `42.12`, `42.13`, and `common`, preserves `id=Gelevator`, and sets `42.13/versionMin=42.13`.
- Corrected workflow applied: moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/gun's elevator` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/gun's elevator-pre-workshop-direct`, copied Workshop directly to live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/gun's elevator`, then made only live compatibility normalizations.
- Live normalizations for `Gun's Elevator`: lowercased script filenames under `42.12/media/scripts` and `42.13/media/scripts` (`entity_elevator_Door.txt` and `entity_elevator_altDoor.txt`), and changed the nested `--[[` marker inside the already-commented block in both `42.12/media/lua/client/GE_UI.lua` and `42.13/media/lua/client/GE_UI.lua` to a plain comment so Lua 5.1 can parse it.
- `Gun's Elevator` validation passed: active failed path now exists under `42.13`, all live Lua files pass `lua5.1 loadfile`, no uppercase filenames remain under live `media/scripts`, no live `.git`, and `id=Gelevator` is preserved. Live-vs-Workshop differs only by the script filename case changes and the two `GE_UI.lua` comment-marker parse fixes.
- `HephasStalkerPDA` was fixed after the 15:54 retest. Latest fixed blocker:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/hephasstalkerpda/42/media/scripts/hsp_items.txt`.
- `HephasStalkerPDA` has an intentional local project edit (`b807e13 Reduce PDA encumbrance`), and live matched the project before this fix. Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3479108127/mods/HephasStalkerPDA` differs and is not a safe direct replacement for this active setup, so preserve the project payload.
- `HephasStalkerPDA` project repo `/home/cjstorrs/projects/game-mods/zomboid/HephasStalkerPDA` is now on branch `feat(4.19)/lowercase-hephas-stalker-pda-script-paths`, commit `e904cd1` (`feat(4.19)/lowercase-hephas-stalker-pda-script-paths`).
- `HephasStalkerPDA` fix completed: lowercased active and legacy script filenames (`HSP_items.txt`, `HSP_models.txt`), moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/HephasStalkerPDA` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/HephasStalkerPDA-pre-lowercase-folder`, and synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/hephasstalkerpda`.
- `HephasStalkerPDA` validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, no uppercase filenames remain under project/live `media/scripts`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and `id=HephasStalkerPDA` is preserved.
- `Hot Brass - Visible Casing Ejection Framework` was fixed after the 15:58 retest. Latest fixed blocker:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/hot_brass_visible_casing_ejection_framework/42.15/media/scripts/spentcasingsphysics/items/new_spentcasings.txt`.
- Hot Brass has intentional project edits (`b258230 Add Rain firearms support`, `e47bb2f Fix Hot Brass property flag checks`, `c95905b fix: prune B42.19 reload animation channels`) and live matched the project before this fix. Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3610677934/mods/Hot_Brass_Visible_Casing_Ejection_Framework` differs materially, so preserve the project payload.
- Hot Brass project repo `/home/cjstorrs/projects/game-mods/zomboid/Hot_Brass_Visible_Casing_Ejection_Framework` is now on branch `feat(4.19)/lowercase-hot-brass-script-paths`, commit `d42899c` (`feat(4.19)/lowercase-hot-brass-script-paths`).
- Hot Brass fix completed: lowercased script directory/file path components under active `42.15/media/scripts`, older `42/media/scripts`, and root `media/scripts`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Hot_Brass_Visible_Casing_Ejection_Framework` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/Hot_Brass_Visible_Casing_Ejection_Framework-pre-lowercase-folder`, and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/hot_brass_visible_casing_ejection_framework`.
- Hot Brass validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, no uppercase filenames remain under project/live `media/scripts`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and `id=HBVCEFb42` / root `id=zHBVCEF` are preserved.
- `Immersive Preservation: Canning and Jarring` was fixed after the 16:01 retest. Latest fixed blocker:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/immersivepreservationcanningjarring/42/media/scripts/items/ipjarring_items_food_prepared.txt`.
- Immersive Preservation has an intentional project edit (`c90ad61 Use learned recipes for 42.19`), and live matched the project before this fix. Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3560836822/mods/ImmersivePreservationCanningJarring` differs in that local recipe tweak, so preserve the project payload.
- Immersive Preservation project repo `/home/cjstorrs/projects/game-mods/zomboid/ImmersivePreservationCanningJarring` is now on branch `feat(4.19)/lowercase-immersive-preservation-script-paths`, commit `2e041d2` (`feat(4.19)/lowercase-immersive-preservation-script-paths`).
- Immersive Preservation fix completed: lowercased `IPJarring_items_food_prepared.txt` and `IPJarring_recipes_cooking.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/ImmersivePreservationCanningJarring` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/ImmersivePreservationCanningJarring-pre-lowercase-folder`, and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/immersivepreservationcanningjarring`.
- Immersive Preservation validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, no uppercase filenames remain under project/live `media/scripts`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and `id=ImmersivePreservationCanningJarring` is preserved.
- `KATTAJ1 Clothes Core` was fixed after the 16:04 retest. Latest fixed blocker:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/kattaj1 clothes core/42.15/media/scripts/kattaj1_armor_modelsitems.txt`.
- `KATTAJ1 Clothes Core` uses the corrected direct-Workshop workflow. Old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/KATTAJ1 Clothes Core` was moved to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/KATTAJ1 Clothes Core-pre-workshop-direct`, Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3470422050/mods/KATTAJ1 Clothes Core` was copied directly to live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/kattaj1 clothes core`, and live-only script filenames were lowercased under `42.12`, `42.13`, `42.15`, and root `media/scripts`.
- `KATTAJ1 Clothes Core` validation passed: the failed 16:04 path exists, no uppercase filenames remain under live `media/scripts`, all live Lua files pass `lua5.1 loadfile`, no live `.git` exists, `id=KATTAJ1_ClothesCore` is preserved, and live-vs-Workshop differs only by script filename case pairs.
- `KATTAJ1 Military Pack` was proactively fixed under the same corrected direct-Workshop workflow because it shares the KATTAJ1 script casing pattern and depends on `KATTAJ1_ClothesCore`. Old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/KATTAJ1 Military Pack` was moved to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/KATTAJ1 Military Pack-pre-workshop-direct`, Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3470426196/mods/KATTAJ1 Military Pack` was copied directly to live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/kattaj1 military pack`, and live-only script filenames were lowercased under `42.12`, `42.13`, `42.15`, and root `media/scripts`.
- `KATTAJ1 Military Pack` validation passed: no uppercase filenames remain under live `media/scripts`, all live Lua files pass `lua5.1 loadfile`, no live `.git` exists, `id=KATTAJ1_Military` and `require=\KATTAJ1_ClothesCore` are preserved, and live-vs-Workshop differs only by script filename case pairs.
- `Korkuluk's Gooner Poster Tiles NSFW` was fixed after the 16:13 retest. Latest fixed blocker:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/korkuluk's gooner poster tiles nsfw/42/media/scripts/gooner_items.txt`.
- `Korkuluk's Gooner Poster Tiles NSFW` remains project-owned because the project has intentional local poster visibility/keybind fixes (`5f14529`, `cdb347e`, `0e1c139`, `7997cc0`, `ed5df6c`) and differs materially from Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3739287118/mods/Korkuluk's Gooner Poster Tiles NSFW`.
- Gooner fix completed on branch `feat(4.19)/lowercase-gooner-script-paths`, commit `e51ff89` (`feat(4.19)/lowercase-gooner-script-paths`): lowercased project script filenames `42/media/scripts/Gooner_Items.txt` and `media/scripts/Gooner_Items.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Korkuluk's Gooner Poster Tiles NSFW` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/Korkuluk's Gooner Poster Tiles NSFW-pre-lowercase-folder`, and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/korkuluk's gooner poster tiles nsfw`.
- Gooner validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, failed 16:13 path exists, no uppercase filenames remain under project/live `media/scripts`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and `id=Gooner` plus `require=\Kposter` are preserved.
- `Korkuluk's Poster Tube` was fixed after the 16:16 retest. Latest fixed blocker:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/korkuluk's poster tube/42/media/scripts/kposter-items.txt`.
- `Korkuluk's Poster Tube` remains project-owned because the project has intentional B42/context-menu/loot-weight commits (`9120fa9`, `a9497b2`, `5da32f1`, `4bc212a`) and differs materially from Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3737012396/mods/Korkuluk's Poster Tube`.
- Poster Tube fix completed on branch `feat(4.19)/lowercase-poster-tube-script-paths`, commit `0ce3670` (`feat(4.19)/lowercase-poster-tube-script-paths`): lowercased project script filenames `42/media/scripts/Kposter-Items.txt` and `media/scripts/Kposter-Items.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Korkuluk's Poster Tube` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/Korkuluk's Poster Tube-pre-lowercase-folder`, and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/korkuluk's poster tube`.
- Poster Tube validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, failed 16:16 path exists, no uppercase filenames remain under project/live `media/scripts`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and `id=Kposter` plus `require=\NepEasyDistro` are preserved.
- `Ladders` was fixed after the 16:19 retest. Latest fixed blocker:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/ladders/42/media/scripts/items/items_ladder.txt`.
- `Ladders` remains project-owned because the project has a prior B42.19 tile property API fix (`8edbc0d`) and differs from Workshop cache `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2737665235/mods/Ladders` in `Ladders.lua`.
- Ladders fix completed on branch `feat(4.19)/lowercase-ladders-script-paths`, commit `906294b` (`feat(4.19)/lowercase-ladders-script-paths`): lowercased project script filename `42/media/scripts/recipes/recipes_Ladders.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Ladders` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/Ladders-pre-lowercase-folder`, and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/ladders`.
- Ladders validation passed: project/live `diff -qr --exclude=.git` clean, no live `.git`, failed 16:19 path exists, no uppercase filenames remain under project/live `media/scripts`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and `id=Ladders` is preserved. `CollapsibleLadders` is a separate already-lowercase live folder (`/mods/collapsibleladder`) and was left unchanged unless a later log names it.
- Active Legendary bag family was fixed after the 16:22 retest. Latest fixed blocker:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/legendarybackpack/42.0/media/scripts/lb_items.txt`.
- `LegendaryBackpack` and `LegendaryFannypack` had no project repos/local edits, so the corrected direct-Workshop rule was applied. Old live `LegendaryBackpack` and `LegendaryFannypack` folders were moved to disabled holding with `-pre-workshop-direct` suffixes, Workshop caches `3538353228/mods/LegendaryBackpack` and `3552050880/mods/LegendaryFannypack` were copied directly to lowercase live roots `/mods/legendarybackpack` and `/mods/legendaryfannypack`, and only live path casing was normalized (`Media`/`Scripts` dirs plus script filenames under `media/scripts`).
- `LegendaryDuffelbag` and `LegendarySatchel` remain project-owned because they have intentional B42.19 body-location compatibility commits (`f98bfbb`, `d74a436`, `2da1637`). Duffelbag fix committed on branch `feat(4.19)/lowercase-legendary-duffelbag-script-paths`, commit `35ef468` (`feat(4.19)/lowercase-legendary-duffelbag-script-paths`): lowercased `LDItems.txt`, `LDRecipes.txt`, and `LD_models.txt`, moved old live `LegendaryDuffelbag` to disabled holding, and synced project to `/mods/legendaryduffelbag`. Satchel fix committed on branch `feat(4.19)/lowercase-legendary-satchel-script-paths`, commit `024cd91` (`feat(4.19)/lowercase-legendary-satchel-script-paths`): lowercased `LSItems.txt`, `LSRecipes.txt`, and `LS_models.txt`, moved old live `LegendarySatchel` to disabled holding, and synced project to `/mods/legendarysatchel`.
- Legendary validation passed: no live `.git`, no uppercase filenames remain under any active Legendary bag `media/scripts`, the failed 16:22 Backpack path now resolves under Workshop-current `42.15/media/scripts/lb_items.txt`, all live Legendary bag Lua files pass `lua5.1 loadfile`, Duffelbag/Satchel project-live `diff -qr --exclude=.git` clean, Backpack/Fannypack live-vs-Workshop differs only by expected path casing, and active IDs are preserved (`LBB42`, `LFB42`, `LDB42`, `LSB42`).
- `LongTermPreservationExtended` was fixed after the 16:26 retest. Latest fixed blocker:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/longtermpreservationextended/42/media/scripts/items/items_dried.txt`.
- `LongTermPreservationExtended` has no project repo/local edits and Workshop cache `3597673472/mods/LongTermPreservationExtended` is a current B42.13 payload, so the corrected direct-Workshop rule was applied. Old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/LongTermPreservationExtended` was moved to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/LongTermPreservationExtended-pre-workshop-direct`, and Workshop was copied directly to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/longtermpreservationextended`.
- The required base mod `SKITTLE_LongTermPreservation` was also proactively corrected. It had no project repo/local edits and was installed under odd mixed-case live folder `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/ModName`; Workshop cache `3406392630/mods/ModName` is current B42.13 and preserves `id=SKITTLE_LongTermPreservation`. Old live `ModName` was moved to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/ModName-SKITTLE_LongTermPreservation-pre-workshop-direct`, and Workshop was copied directly to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/modname`.
- LongTermPreservation validation passed: base and extended live folders equal Workshop, no live `.git`, no uppercase filenames remain under live `media/scripts`, failed 16:26 extended item path now resolves under active `42.13/media/scripts/items/items_dried.txt`, all live Lua files pass `lua5.1 loadfile`, and IDs/dependency are preserved (`SKITTLE_LongTermPreservation`, `LongTermPreservationExtended`, `require=\SKITTLE_LongTermPreservation`).
- Next action: relaunch B42.19 with the cache bridge and inspect the newest log.
- `cjsEvolvingTraitsWorld` was fixed and confirmed cleared by the 14:31 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjsevolvingtraitsworld/common/media/scripts/etwsounds.txt`.
- `cjsEvolvingTraitsWorld` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/cjsEvolvingTraitsWorld`; active branch is `feat(4.19)/lowercase-evolving-traits-script-paths`, commit `37b3ee7` (`feat(4.19)/lowercase-evolving-traits-script-paths`). Preserve prior local B42.19 fork commits including trait registration / definitions work (`c665c72`, `98d3c74`, `b5dfbfd`, `e3ce4b2`, `e072b47`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2914075159/mods/Evolving Traits World`. Upstream has B42.19 content but still uses mixed-case script names (`42.19/media/scripts/ETW_Traits.txt`, `common/media/scripts/ETWSounds.txt`, and root `media/scripts/ETWSounds.txt`), and its IDs differ from the CJS fork, so preserve the CJS project payload.
- Confirmed `cjsEvolvingTraitsWorld` issue had both script filename and live-root casing: project/live contained `common/media/scripts/ETWSounds.txt` and root `media/scripts/ETWSounds.txt`, while B42.19 requests `etwsounds.txt` from lowercased live root `cjsevolvingtraitsworld`.
- `cjsEvolvingTraitsWorld` fix completed under the old copy/lowercase workflow: lowercased both project `ETWSounds.txt` script files and moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsEvolvingTraitsWorld` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/cjsEvolvingTraitsWorld-pre-lowercase-folder`. Current relinks should use `link-project-mod.sh cjsEvolvingTraitsWorld`.
- `cjsEvolvingTraitsWorld` validation passed under the old copy workflow: project worktree clean, live `42/mod.info` preserved `id=cjsEvolvingTraitsWorld`, all project Lua files passed `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components remained under project or live `media/scripts`. Current relinks should use `link-project-mod.sh cjsEvolvingTraitsWorld`.
- `cjsFastTravelWaypoints` was fixed and confirmed cleared by the 14:35 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjsfasttravelwaypoints/42/media/scripts/items_waypoints.txt`.
- `cjsFastTravelWaypoints` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/cjsFastTravelWaypoints`; active branch is `feat(4.19)/lowercase-fast-travel-live-folder`, commit `455a95c` (`feat(4.19)/lowercase-fast-travel-live-folder`). Preserve prior local feature commits (`2e93b0b`, `bf4459c`, `dc7917f`, `03f577d`, `370ce1c`).
- Workshop cache search under `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600` found no matching Fast Travel Waypoints source, so preserve the CJS project payload.
- Confirmed `cjsFastTravelWaypoints` issue was live folder casing only: project/live script files were already lowercase (`42/media/scripts/items_waypoints.txt`, `recipes_waypoints.txt`), while B42.19 requests them from lowercased live root `cjsfasttravelwaypoints`.
- `cjsFastTravelWaypoints` fix completed under the old copy/lowercase workflow: moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsFastTravelWaypoints` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/cjsFastTravelWaypoints-pre-lowercase-folder` and committed empty marker `455a95c`. Current relinks should use `link-project-mod.sh cjsFastTravelWaypoints`.
- `cjsFastTravelWaypoints` validation passed: project worktree clean, project/live `diff -qr --exclude=.git --exclude=.cjs-zomboid-mirror-source` clean, live has no `.git`, live `42/mod.info` preserves `id=cjsFastTravelWaypoints`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components exist under project or live `media/scripts`. `rsync -ani` reports permission-bit differences only because of the Windows live mount.
- `cjsPkmnTradingCards` was fixed and confirmed cleared by the 14:38 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjspkmntradingcards/42/media/scripts/pkmncards_items.txt`.
- `cjsPkmnTradingCards` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/cjsPkmnTradingCards`; active branch is `feat(4.19)/lowercase-pkmn-trading-live-folder`, commit `d3670fb` (`feat(4.19)/lowercase-pkmn-trading-live-folder`). Preserve prior local B42 recipe/loot commits (`d249e7c`, `0af70f4`, `7f75e28`, `01234cb`, `368eaf5`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2860583078/mods/PKMNTradingCards1.3`; it is a legacy/root-layout source with different `id=pkmntradingcards1.2`, so preserve the CJS project payload.
- Confirmed `cjsPkmnTradingCards` issue was live folder casing only: project/live script files were already lowercase (`42/media/scripts/pkmncards_items.txt`, `pkmncards_models.txt`), while B42.19 requests them from lowercased live root `cjspkmntradingcards`.
- `cjsPkmnTradingCards` fix completed under the old copy/lowercase workflow: moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsPkmnTradingCards` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/cjsPkmnTradingCards-pre-lowercase-folder` and committed empty marker `d3670fb`. Current relinks should use `link-project-mod.sh cjsPkmnTradingCards`.
- `cjsPkmnTradingCards` validation passed: project worktree clean, project/live `diff -qr --exclude=.git --exclude=.cjs-zomboid-mirror-source` clean, live has no `.git`, live `42/mod.info` preserves `id=cjsPkmnTradingCards`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components exist under project or live `media/scripts`.
- `cjsProteinShake` was fixed and confirmed cleared by the 14:42 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjsproteinshake/42/media/scripts/fluids_proteinshake.txt`.
- `cjsProteinShake` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/cjsProteinShake`; active branch is `feat(4.19)/lowercase-protein-shake-script-paths`, commit `afbe428` (`feat(4.19)/lowercase-protein-shake-script-paths`). Preserve prior local B42 fluid compatibility commits (`8ffb79e`, `ee689d8`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3441138219/mods/ProteinShake`; it has the same mixed-case script filenames and different `id=ProteinShake`, so preserve the CJS fork.
- Confirmed `cjsProteinShake` issue had both script filename and live-root casing: project/live contained `42/media/scripts/*_ProteinShake.txt`, while B42.19 requests lowercase filenames from lowercased live root `cjsproteinshake`.
- `cjsProteinShake` fix completed under the old copy/lowercase workflow: lowercased four project script filenames (`fluids_`, `items_`, `models_`, `recipes_`), moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsProteinShake` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/cjsProteinShake-pre-lowercase-folder`, and committed `afbe428`. Current relinks should use `link-project-mod.sh cjsProteinShake`.
- `cjsProteinShake` validation passed: project worktree clean, project/live `diff -qr --exclude=.git --exclude=.cjs-zomboid-mirror-source` clean, live has no `.git`, live `42/mod.info` preserves `id=ProteinShakeCjs`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components remain under project or live `media/scripts`.
- `cjsTheOnlyCure` was fixed and confirmed cleared by the 14:45 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjstheonlycure/42/media/scripts/toc_recipes.txt`.
- `cjsTheOnlyCure` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/cjsTheOnlyCure`; active branch is `feat(4.19)/lowercase-only-cure-script-paths`, commit `6249626` (`feat(4.19)/lowercase-only-cure-script-paths`). Preserve prior local B42 body-location and trait commits (`dc5dbb5`, `e2c064b`, `d42252f`, `e1b553f`, `00bda5a`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3580276809/mods/The-Only-Cure`; it has the same uppercase `TOC_` script filenames and different `id=TheOnlyCure`, so preserve the CJS fork.
- Confirmed `cjsTheOnlyCure` issue had both script filename and live-root casing: project/live contained active/common `TOC_*.txt` script filenames, while B42.19 requests lowercase filenames from lowercased live root `cjstheonlycure`.
- `cjsTheOnlyCure` fix completed under the old copy/lowercase workflow: lowercased six project script filenames (`TOC_recipes.txt` plus five common `TOC_*.txt` files), moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsTheOnlyCure` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/cjsTheOnlyCure-pre-lowercase-folder`, and committed `6249626`. Current relinks should use `link-project-mod.sh cjsTheOnlyCure`.
- `cjsTheOnlyCure` validation passed: project worktree clean, project/live `diff -qr --exclude=.git --exclude=.cjs-zomboid-mirror-source` clean, live has no `.git`, live `42/mod.info` preserves `id=TheOnlyCureCjs`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components remain under project or live `media/scripts`.
- `cjsTwoWeaponsonBack` was fixed and confirmed cleared by the 14:49 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjstwoweaponsonback/42/media/scripts/clothing/slingfix_att.txt`.
- Actual project/live folder casing is `cjsTwoWeaponsonBack` (lowercase `on`), not `cjsTwoWeaponsOnBack`.
- `cjsTwoWeaponsonBack` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/cjsTwoWeaponsonBack`; active branch is `feat(4.19)/lowercase-two-weapons-script-paths`, commit `bb21ee6` (`feat(4.19)/lowercase-two-weapons-script-paths`). Preserve prior local B42 body-location commits (`8bfb871`, `b50c2b5`, `a7e38f1`, `64d7969`, `508a094`).
- Workshop cache search found `NoirRifleSlingFix`, not a replacement for this CJS fork. Preserve the project payload.
- Confirmed `cjsTwoWeaponsonBack` issue had both script filename and live-root casing: project/live contained `42/media/scripts/clothing/Slingfix_*.txt`, while B42.19 requests lowercase filenames from lowercased live root `cjstwoweaponsonback`.
- `cjsTwoWeaponsonBack` fix completed under the old copy/lowercase workflow: lowercased four project script filenames under `42/media/scripts/clothing`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsTwoWeaponsonBack` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/cjsTwoWeaponsonBack-pre-lowercase-folder`, and committed `bb21ee6`. Current relinks should use `link-project-mod.sh cjsTwoWeaponsonBack`.
- `cjsTwoWeaponsonBack` validation passed: project worktree clean, project/live `diff -qr --exclude=.git --exclude=.cjs-zomboid-mirror-source` clean, live has no `.git`, live `42/mod.info` preserves `id=TwoWeaponsBcjs`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components remain under project or live `media/scripts`.
- `cjsZuperCarts` was fixed after the 14:49 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjszupercarts/42/media/scripts/items_trolley.txt`.
- `cjsZuperCarts` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/cjsZuperCarts`; active branch is `feat(4.19)/lowercase-zupercarts-live-folder`, commit `852ee6b` (`feat(4.19)/lowercase-zupercarts-live-folder`). Preserve prior local B42.19 fixes including commits `e0367a4`, `3c25430`, `44d12b4`, `d2902ca`, and `f991883`.
- Workshop cache was checked under `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600`, including `3433203442/mods/[B42] ZuperCarts - Carts & Trolleys (forked)`. Workshop is not a drop-in replacement for the CJS fork and does not supersede the local B42.19 fixes, so preserve the CJS payload.
- Confirmed `cjsZuperCarts` issue was live folder casing only: project/live script filenames were already lowercase (`42/media/scripts/items_trolley.txt`, `models_trolley.txt`), while B42.19 requests them from lowercased live root `cjszupercarts`.
- `cjsZuperCarts` fix completed under the old copy/lowercase workflow: moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsZuperCarts` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/cjsZuperCarts-pre-lowercase-folder` and committed empty marker `852ee6b`. Current relinks should use `link-project-mod.sh cjsZuperCarts` if that mod becomes active again.
- `cjsZuperCarts` validation passed: project worktree clean, project/live `diff -qr --exclude=.git --exclude=.cjs-zomboid-mirror-source` clean, live has no `.git`, live `42/mod.info` preserves `id=cjsZuperCarts`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components exist under project or live `media/scripts`.
- `Computer` was fixed after the 14:55 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/computer/common/media/scripts/computer_items.txt`.
- `Computer` project repo now exists at `/home/cjstorrs/projects/game-mods/zomboid/Computer`; baseline commit is `b326c5c` (`chore: import Computer live baseline`), active branch is `feat(4.19)/lowercase-computer-script-paths`, and fix commit is `a0ae67f` (`feat(4.19)/lowercase-computer-script-paths`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3548006452/mods/Computer`; Workshop and live were identical and both had mixed-case `common/media/scripts/Computer_*.txt` filenames, so the project was imported from live/Workshop-equivalent payload and patched in place.
- Confirmed `Computer` issue had both script filename and live-root casing: live contained `common/media/scripts/Computer_Items.txt` and `Computer_Sounds.txt`, while B42.19 requests lowercase filenames from lowercased live root `computer`.
- `Computer` fix completed: imported the live folder into the project repo, made an untouched baseline commit, lowercased the two project script filenames, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Computer` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/Computer-pre-lowercase-folder`, synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/computer`, and committed `a0ae67f`.
- `Computer` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `common/mod.info` preserves `id=Starman.Computer`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, only one active live Computer folder remains, and no uppercase path components remain under project or live `media/scripts`.
- `DJG_BoundMaterials` was fixed after the 14:58 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/djg_boundmaterials/42/media/scripts/djg_boundmaterials_ii_models.txt`.
- `DJG_BoundMaterials` project repo now exists at `/home/cjstorrs/projects/game-mods/zomboid/DJG_BoundMaterials`; baseline commit is `ab00311` (`chore: import DJG_BoundMaterials live baseline`), active branch is `feat(4.19)/lowercase-djg-boundmaterials-script-paths`, and fix commit is `e9c1e5c` (`feat(4.19)/lowercase-djg-boundmaterials-script-paths`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3479505015/mods/DJG_BoundMaterials`; Workshop and live were identical and both had mixed-case active and legacy `media/scripts` filenames, so the project was imported from live/Workshop-equivalent payload and patched in place.
- Confirmed `DJG_BoundMaterials` issue had both script filename and live-root casing: live contained mixed-case `42/media/scripts/DJG_BoundMaterials_*.txt` plus root `media/scripts/DJG_BoundMaterials_*.txt`, while B42.19 requests lowercase filenames from lowercased live root `djg_boundmaterials`.
- `DJG_BoundMaterials` fix completed: imported the live folder into the project repo, made an untouched baseline commit, lowercased 18 project script filenames under `42/media/scripts` and root `media/scripts`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/DJG_BoundMaterials` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/DJG_BoundMaterials-pre-lowercase-folder`, synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/djg_boundmaterials`, and committed `e9c1e5c`.
- `DJG_BoundMaterials` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` preserves `id=DJG_BoundMaterials` with `modversion=2.0.3`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, only one active live DJG Bound Materials folder remains, and no uppercase path components remain under project or live `media/scripts`.
- `DonazosFisticuffs` was fixed after the 15:01 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/donazosfisticuffs/42/media/scripts/fist.txt`.
- `DonazosFisticuffs` project repo now exists at `/home/cjstorrs/projects/game-mods/zomboid/DonazosFisticuffs`; baseline commit is `2d05ee5` (`chore: import DonazosFisticuffs live baseline`), active branch is `feat(4.19)/lowercase-donazosfisticuffs-script-paths`, and fix commit is `1b2cd74` (`feat(4.19)/lowercase-donazosfisticuffs-script-paths`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3590517705/mods/DonazosFisticuffs`; Workshop and live were identical. `fist.txt` was already lowercase, but the live root was mixed-case and the active `42/media/scripts/module_TWBase.txt` / `module_TWeapons.txt` filenames still had uppercase path components.
- Confirmed `DonazosFisticuffs` issue was live folder casing for the logged `fist.txt` path, with two additional active mixed-case script filenames that B42.19 could request later.
- `DonazosFisticuffs` fix completed: imported the live folder into the project repo, made an untouched baseline commit, lowercased the two active project script filenames to `module_twbase.txt` and `module_tweapons.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/DonazosFisticuffs` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/DonazosFisticuffs-pre-lowercase-folder`, synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/donazosfisticuffs`, and committed `1b2cd74`.
- `DonazosFisticuffs` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` preserves `id=DonazosFisticuffs` with `versionMin=42.0.0`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, only one active live Donazos Fisticuffs folder remains, and no uppercase path components remain under project or live `media/scripts`.
- `DrivingSkill [B42]` was fixed after the 15:04 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/drivingskill [b42]/42/media/scripts/drivingskillitems.txt`.
- `DrivingSkill [B42]` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/DrivingSkill [B42]`; active branch is `feat(4.19)/lowercase-driving-skill-script-paths`, and fix commit is `7e2ac0c` (`feat(4.19)/lowercase-driving-skill-script-paths`). Preserve prior local B42.19 commits `e67cb65`, `bec6230`, and `5f6faee`.
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3407791878/mods/DrivingSkill [B42]`; Workshop differs from the local project in trait/registry B42.19 fixes, so preserve the project payload.
- Confirmed `DrivingSkill [B42]` issue had both script filename and live-root casing: project/live contained `42/media/scripts/DrivingSkillItems.txt`, while B42.19 requests lowercase `drivingskillitems.txt` from lowercased live root `drivingskill [b42]`.
- `DrivingSkill [B42]` fix completed: lowercased the project script filename to `42/media/scripts/drivingskillitems.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/DrivingSkill [B42]` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/DrivingSkill [B42]-pre-lowercase-folder`, synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/drivingskill [b42]`, and committed `7e2ac0c`.
- `DrivingSkill [B42]` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `common/mod.info` preserves `id=DrivingSkill` with `modversion=1.1.0` and `versionMin=42.0.0`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, lowercase live `/mods/drivingskill [b42]` exists, and no uppercase path components remain under project or live `media/scripts`.
- `DWAP` was fixed after the 15:07 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/dwap/42/media/scripts/dwap/dwap_entities.txt`.
- `DWAP` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/DWAP`; active branch is `feat(4.19)/lowercase-dwap-script-paths`, and fix commit is `c9275ce` (`feat(4.19)/lowercase-dwap-script-paths`). Preserve prior local B42.19 API update commit `129f1c6`.
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3440887907/mods/DWAP`; project/live/Workshop were effectively the same payload, aside from the project `.git`.
- Confirmed `DWAP` issue had script directory and live-root casing: project/live contained `42/media/scripts/DWAP/dwap_entities.txt` and `42/media/scripts/DWAP/Items.txt`, while B42.19 requests lowercase `42/media/scripts/dwap/...` from lowercased live root `dwap`.
- `DWAP` fix completed: lowercased the project script directory to `42/media/scripts/dwap`, lowercased `Items.txt` to `items.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/DWAP` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/DWAP-pre-lowercase-folder`, synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/dwap`, and committed `c9275ce`.
- `DWAP` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` preserves `id=DWAP` and `require=\StarlitLibrary`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, lowercase live `/mods/dwap` exists, and no uppercase path components remain under project or live `media/scripts`.
- `EasyOutfits` was fixed after the 15:10 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/easyoutfits/42.0/media/scripts/easyoutfits_items.txt`.
- `EasyOutfits` project repo now exists at `/home/cjstorrs/projects/game-mods/zomboid/EasyOutfits`; baseline commit is `03573df` (`chore: import EasyOutfits live baseline`), active branch is `feat(4.19)/lowercase-easyoutfits-script-paths`, and fix commit is `3ef6402` (`feat(4.19)/lowercase-easyoutfits-script-paths`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2927625589/mods/EasyOutfits`; Workshop and live were identical and both had mixed-case active and legacy `EasyOutfits_Items.txt` script filenames.
- Confirmed `EasyOutfits` issue had both script filename and live-root casing: live contained `42.0/media/scripts/EasyOutfits_Items.txt` and root `media/scripts/EasyOutfits_Items.txt`, while B42.19 requests lowercase `easyoutfits_items.txt` from lowercased live root `easyoutfits`.
- `EasyOutfits` fix completed: imported the live folder into the project repo, made an untouched baseline commit, lowercased active and legacy script filenames to `easyoutfits_items.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/EasyOutfits` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/EasyOutfits-pre-lowercase-folder`, synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/easyoutfits`, and committed `3ef6402`.
- `EasyOutfits` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42.0/mod.info` preserves `id=2927625589/EasyOutfits` with `modversion=42` and `versionMin=42.00`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, lowercase live `/mods/easyoutfits` exists, and no uppercase path components remain under project or live `media/scripts`.
- `Estate 39` was fixed after the 15:14 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/estate 39/common/media/scripts/mikubackpack.txt`.
- `Estate 39` project repo now exists at `/home/cjstorrs/projects/game-mods/zomboid/Estate 39`; baseline commit is `e10081a` (`chore: import Estate 39 live baseline`), active branch is `feat(4.19)/lowercase-estate-39-script-paths`, and fix commit is `d579a84` (`feat(4.19)/lowercase-estate-39-script-paths`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3606927986/mods/Estate 39`; Workshop differs materially from live in map binaries, depthmaps, tile assets, scripts, and texture packs, so preserve the current live payload for save compatibility.
- Confirmed `Estate 39` issue had both script filename and live-root casing: live contained `common/media/scripts/MikuBackPack.txt` and `MikuCanteen.txt`, while B42.19 requests lowercase script filenames from lowercased live root `estate 39`.
- `Estate 39` fix completed: imported the live folder into the project repo, made an untouched baseline commit, lowercased the two common script filenames to `mikubackpack.txt` and `mikucanteen.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Estate 39` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/Estate 39-pre-lowercase-folder`, synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/estate 39`, and committed `d579a84`.
- `Estate 39` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` and `common/mod.info` preserve `id=Estate 39` with `modversion=1.0`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, lowercase live `/mods/estate 39` exists, and no uppercase path components remain under project or live `media/scripts`.
- `ExtraBooks` was fixed after the 15:17 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/extrabooks/42.0/media/scripts/extrabooks-books.txt`.
- `ExtraBooks` project repo now exists at `/home/cjstorrs/projects/game-mods/zomboid/ExtraBooks`; baseline commit is `5aa3b7e` (`chore: import ExtraBooks live baseline`), active branch is `feat(4.19)/lowercase-extrabooks-script-paths`, and fix commit is `7e29492` (`feat(4.19)/lowercase-extrabooks-script-paths`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2859508566/mods/ExtraBooks`; Workshop and live were identical and both had mixed-case active and legacy `ExtraBooks-Books.txt` script filenames.
- Confirmed `ExtraBooks` issue had both script filename and live-root casing: live contained `42.0/media/scripts/ExtraBooks-Books.txt` and root `media/scripts/ExtraBooks-Books.txt`, while B42.19 requests lowercase `extrabooks-books.txt` from lowercased live root `extrabooks`.
- `ExtraBooks` fix completed: imported the live folder into the project repo, made an untouched baseline commit, lowercased active and legacy script filenames to `extrabooks-books.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/ExtraBooks` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/ExtraBooks-pre-lowercase-folder`, synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/extrabooks`, and committed `7e29492`.
- `ExtraBooks` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42.0/mod.info` preserves `id=ExtraBooks`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, lowercase live `/mods/extrabooks` exists, and no uppercase path components remain under project or live `media/scripts`.
- `FeedThatAnimal` was fixed after the 15:21 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/feedthatanimal/42/media/scripts/items_feedthatanimal.txt`.
- `FeedThatAnimal` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/FeedThatAnimal`; prior local fix commit is `8e1675f` (`Remove missing haybale tiledef declaration`), active branch is `feat(4.19)/lowercase-feed-that-animal-script-paths`, and fix commit is `eff0407` (`feat(4.19)/lowercase-feed-that-animal-script-paths`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3487450124/mods/FeedThatAnimal`; Workshop differs from the project/live payload and still uses mixed-case `FeedThatAnimal` script names, so preserve the local project payload and the prior haybale tiledef fix.
- Confirmed `FeedThatAnimal` issue had both script filename and live-root casing: project/live contained active and legacy `items_FeedThatAnimal.txt`, `models_FeedThatAnimal.txt`, and `recipes_FeedThatAnimal.txt`, while B42.19 requests lowercase filenames from lowercased live root `feedthatanimal`.
- `FeedThatAnimal` fix completed: lowercased six project script filenames under `42/media/scripts` and root `media/scripts`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/FeedThatAnimal` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/FeedThatAnimal-pre-lowercase-folder`, synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/feedthatanimal`, and committed `eff0407`.
- `FeedThatAnimal` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` preserves `id=FeedThatAnimal`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, lowercase live `/mods/feedthatanimal` exists, and no uppercase path components remain under project or live `media/scripts`.
- `FixBlowTorchPropaneTank` was fixed after the 15:27 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/fixblowtorchpropanetank/42.0/media/scripts/oncreate_refillblowtorch.txt`.
- `FixBlowTorchPropaneTank` project repo now exists at `/home/cjstorrs/projects/game-mods/zomboid/FixBlowTorchPropaneTank`; baseline commit is `2fc99d2` (`chore: import FixBlowTorchPropaneTank live baseline`), active branch is `feat(4.19)/lowercase-fix-blowtorch-script-paths`, and fix commit is `2b7be11` (`feat(4.19)/lowercase-fix-blowtorch-script-paths`).
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3044705007/mods/FixBlowTorchPropaneTank`; Workshop differs from live in Lua behavior and extra server file content but has the same mixed-case script filenames, so preserve the current live payload and apply only the B42.19 path-casing fix.
- Confirmed `FixBlowTorchPropaneTank` issue had both script filename and live-root casing: live contained `42.0/media/scripts/OnCreate_RefillBlowTorch.txt` plus root `BlowTorch.txt` and `RefillBlowTorch.txt`, while B42.19 requests lowercase filenames from lowercased live root `fixblowtorchpropanetank`.
- `FixBlowTorchPropaneTank` fix completed: imported the live folder into the project repo, made an untouched baseline commit, lowercased three project script filenames, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/FixBlowTorchPropaneTank` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/FixBlowTorchPropaneTank-pre-lowercase-folder`, synced the project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/fixblowtorchpropanetank`, and committed `2b7be11`.
- `FixBlowTorchPropaneTank` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42.0/mod.info` preserves `id=FixBlowTorchPropaneTank`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, lowercase live `/mods/fixblowtorchpropanetank` exists, and no uppercase path components remain under project or live `media/scripts`.
- Next action: relaunch B42.19 with the cache bridge, continue the active save, and inspect the newest log for the next actionable blocker.
- `B42Survival` was fixed and confirmed cleared by the 14:10 retest. The latest fixed blocker from the prior log was:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/b42survival/42/media/scripts/items_survival.txt`.
- `B42Survival` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/B42Survival`, clean on branch `feat(4.19)/timed-action-compat`, with commits `443a77e` (`Import B42Survival live mod baseline`) and `95b56f0` (`Update survival timed actions for 42.19`).
- Workshop cache was checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3402516345/mods/B42Survival`. Workshop has `42.12/`, `42.14/`, and `common/`, but its latest `42.14/media/scripts` still has mixed-case script filenames (`Items_Survival.txt`, `recipes_Survival.txt`, `models_Survival.txt`). The project has the local B42.19 `42/` layout and no uppercase path components under `media/scripts`, so preserve the project payload instead of replacing it with Workshop.
- Confirmed `B42Survival` issue was live folder casing only: live active folder was `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/B42Survival`; B42.19 requests lowercased root `b42survival`; project/live script paths were already lowercase.
- `B42Survival` fix completed: created branch `feat(4.19)/lowercase-b42survival-live-folder`, moved old live folder to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/B42Survival-pre-lowercase-folder`, synced the project repo to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/b42survival`, and committed empty marker `4c77c81` (`feat(4.19)/lowercase-b42survival-live-folder`).
- `B42Survival` validation passed: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` preserves `id=B42Survival`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components remain under project or live `media/scripts`.
- Latest fixed blocker is `Big Salt`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/big salt/42.0/media/scripts/big_items.txt`.
- `Big Salt` project repo now exists at `/home/cjstorrs/projects/game-mods/zomboid/Big Salt`, with baseline commit `c2c062f` (`chore: import Big Salt live baseline`) and active branch `feat(4.19)/lowercase-big-salt-script-paths`.
- Workshop cache was checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3004563786/mods/Big Salt`. Workshop and live are identical and both have mixed-case script filenames under `42.0/media/scripts` and root `media/scripts`, so the fix is to import live/Workshop payload unchanged, then lowercase active script path components and install under lowercase live root.
- `Big Salt` fix completed: lowercased six script filenames under project `42.0/media/scripts` and root `media/scripts`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Big Salt` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/Big Salt-pre-lowercase-folder`, synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/big salt`, and committed `4c7981f` (`feat(4.19)/lowercase-big-salt-script-paths`).
- `Big Salt` validation passed: project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42.0/mod.info` and root `mod.info` preserve `id=Bigsalt`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, only one active live Big Salt folder remains, and no uppercase path components remain under project or live `media/scripts`.
- Latest fixed blocker is `Caster Plus`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/caster plus/42/media/scripts/clothing/items_zitcaster_armor.txt`.
- `Caster Plus` project repo now exists at `/home/cjstorrs/projects/game-mods/zomboid/Caster Plus`, with baseline commit `134cfa2` (`chore: import Caster Plus live baseline`) and active branch `feat(4.19)/lowercase-caster-plus-live-folder`.
- Workshop cache was checked by `id=CasterPlus`, `name=Caster Plus`, and directory-name fallback under `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600`; no matching Workshop source was found. Preserve the live payload.
- Confirmed `Caster Plus` issue was live folder casing only: B42.19 requests lowercased root `caster plus`, while the old live folder was `Caster Plus`; no uppercase path components exist under active `media/scripts`.
- `Caster Plus` fix completed: moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Caster Plus` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/Caster Plus-pre-lowercase-folder`, synced the project repo to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/caster plus`, and committed empty marker `1e0df4a` (`feat(4.19)/lowercase-caster-plus-live-folder`).
- `Caster Plus` validation passed: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` preserves `id=CasterPlus`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components exist under project or live `media/scripts`. Active load lists contain `CasterPlus`; `CasterPlusRealistic` is only installed, not active, so it was left unchanged.
- Latest fixed blocker is `cjsArmorWearingSkill`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjsarmorwearingskill/42/media/scripts/skillbooks.txt`.
- `cjsArmorWearingSkill` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/cjsArmorWearingSkill`; active branch is `feat(4.19)/lowercase-armor-wearing-script-paths`. Untracked `.dreamers/` is unrelated and must not be staged. Recent local commits include `8b093b8` (`Add armor wearing XP multiplier option`), `44e51ea`, and `b7eb600`; preserve this CJS fork and its `id=cjsArmorWearingSkill`.
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3547360242/mods/ArmorWearingSkill`. It is the upstream `id=ARMOR_WEARING_SKILL`, differs materially from the CJS fork, and still uses mixed-case `SkillBooks.txt`, so it is evidence only, not a replacement.
- Confirmed `cjsArmorWearingSkill` issue had both script filename and live-root casing: project/live contained `42/media/scripts/SkillBooks.txt` and root `media/scripts/SkillBooks.txt`, while B42.19 requests `skillbooks.txt` from lowercased live root `cjsarmorwearingskill`.
- `cjsArmorWearingSkill` fix completed under the old copy/lowercase workflow: lowercased both project `SkillBooks.txt` script files, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsArmorWearingSkill` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/cjsArmorWearingSkill-pre-lowercase-folder`, and committed `f7ee84c` (`feat(4.19)/lowercase-armor-wearing-script-paths`). Current relinks should use `link-project-mod.sh cjsArmorWearingSkill`.
- `cjsArmorWearingSkill` validation passed under the old copy workflow: live `42/mod.info` preserved `id=cjsArmorWearingSkill`, all project Lua files passed `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components remained under project or live `media/scripts`. Current relinks should use `link-project-mod.sh cjsArmorWearingSkill`.
- Latest fixed blocker is `cjsEfficiencySkillMod`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjsefficiencyskillmod/42/media/scripts/efficiencybooks.txt`.
- `cjsEfficiencySkillMod` project repo exists at `/home/cjstorrs/projects/game-mods/zomboid/cjsEfficiencySkillMod`; active branch is `feat(4.19)/lowercase-efficiency-script-paths`. Recent local commits include `04f8710`, `3f1bf5f`, and `65da479`; preserve this CJS fork and its `id=cjsEfficiencySkillMod`.
- Workshop cache was checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3374408921/mods/EfficiencySkillMod` and `EfficiencySkillMod2`. These are upstream IDs (`efficiencySkillModLegacy` / other upstream payload), differ materially from the CJS fork, and do not replace the local B42.19 trait-registration fixes.
- Confirmed `cjsEfficiencySkillMod` issue had both script filename and live-root casing: project/live contained `42/media/scripts/EfficiencyBooks.txt`, while B42.19 requests `efficiencybooks.txt` from lowercased live root `cjsefficiencyskillmod`.
- `cjsEfficiencySkillMod` fix completed under the old copy/lowercase workflow: lowercased project `42/media/scripts/EfficiencyBooks.txt`, moved old live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsEfficiencySkillMod` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/cjsEfficiencySkillMod-pre-lowercase-folder`, and committed `da773b6` (`feat(4.19)/lowercase-efficiency-script-paths`). Current relinks should use `link-project-mod.sh cjsEfficiencySkillMod`.
- `cjsEfficiencySkillMod` validation passed under the old copy workflow: live `42/mod.info` preserved `id=cjsEfficiencySkillMod`, all project Lua files passed `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components remained under project or live `media/scripts`. Current relinks should use `link-project-mod.sh cjsEfficiencySkillMod`.
- 14:25 retest with the cache bridge confirmed `cjsEfficiencySkillMod` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_14-25_DebugLog.txt`.
- New immediate blocker from that retest was `ScriptManager.Load FileNotFoundException` for `cjsEvolvingTraitsWorld`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjsevolvingtraitsworld/common/media/scripts/etwsounds.txt`.
- `cjsEvolvingTraitsWorld` fix completed as commit `37b3ee7` (`feat(4.19)/lowercase-evolving-traits-script-paths`) on branch `feat(4.19)/lowercase-evolving-traits-script-paths`: lowercased `common/media/scripts/ETWSounds.txt` and `media/scripts/ETWSounds.txt`, moved the old mixed-case live folder to disabled holding, installed via the CJS script, and moved the active live folder to lowercase `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsevolvingtraitsworld`.
- 14:31 retest with the cache bridge confirmed `cjsEvolvingTraitsWorld` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_14-31_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `cjsFastTravelWaypoints`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjsfasttravelwaypoints/42/media/scripts/items_waypoints.txt`.
- `cjsFastTravelWaypoints` fix completed as empty commit `455a95c` (`feat(4.19)/lowercase-fast-travel-live-folder`) on branch `feat(4.19)/lowercase-fast-travel-live-folder`: preserved the project payload unchanged, moved the old mixed-case live folder to disabled holding, installed via the CJS script, and moved the active live folder to lowercase `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsfasttravelwaypoints`.
- 14:35 retest with the cache bridge confirmed `cjsFastTravelWaypoints` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_14-35_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `cjsPkmnTradingCards`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjspkmntradingcards/42/media/scripts/pkmncards_items.txt`.
- `cjsPkmnTradingCards` fix completed as empty commit `d3670fb` (`feat(4.19)/lowercase-pkmn-trading-live-folder`) on branch `feat(4.19)/lowercase-pkmn-trading-live-folder`: preserved the project payload unchanged, moved the old mixed-case live folder to disabled holding, installed via the CJS script, and moved the active live folder to lowercase `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjspkmntradingcards`.
- 14:38 retest with the cache bridge confirmed `cjsPkmnTradingCards` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_14-38_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `cjsProteinShake`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjsproteinshake/42/media/scripts/fluids_proteinshake.txt`.
- `cjsProteinShake` fix completed as commit `afbe428` (`feat(4.19)/lowercase-protein-shake-script-paths`) on branch `feat(4.19)/lowercase-protein-shake-script-paths`: lowercased four active script filenames, moved the old mixed-case live folder to disabled holding, installed via the CJS script, and moved the active live folder to lowercase `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjsproteinshake`.
- 14:42 retest with the cache bridge confirmed `cjsProteinShake` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_14-42_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `cjsTheOnlyCure`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjstheonlycure/42/media/scripts/toc_recipes.txt`.
- `cjsTheOnlyCure` fix completed as commit `6249626` (`feat(4.19)/lowercase-only-cure-script-paths`) on branch `feat(4.19)/lowercase-only-cure-script-paths`: lowercased six active/common script filenames, moved the old mixed-case live folder to disabled holding, installed via the CJS script, and moved the active live folder to lowercase `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjstheonlycure`.
- 14:45 retest with the cache bridge confirmed `cjsTheOnlyCure` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_14-45_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `cjsTwoWeaponsOnBack`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjstwoweaponsonback/42/media/scripts/clothing/slingfix_att.txt`.
- `cjsTwoWeaponsonBack` fix completed as commit `bb21ee6` (`feat(4.19)/lowercase-two-weapons-script-paths`) on branch `feat(4.19)/lowercase-two-weapons-script-paths`: lowercased four active clothing script filenames, moved the old mixed-case live folder to disabled holding, installed via the CJS script, and moved the active live folder to lowercase `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/cjstwoweaponsonback`.
- 14:49 retest with the cache bridge confirmed `cjsTwoWeaponsonBack` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_14-49_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `cjsZuperCarts`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/cjszupercarts/42/media/scripts/items_trolley.txt`.
- Next action after any restart: inspect live/project/Workshop state for `cjsZuperCarts`, apply the same lowercased live-folder/script-path pattern if confirmed, then relaunch B42.19 with the cache bridge and continue the active save.

## Current Active State

- Project Zomboid is not running; `pgrep -af ProjectZomboid64` returned no process before the `tsarslib` pass.
- Immediate blocker is the 13:22 B42.19 startup failure in `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_13-22_DebugLog.txt`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/tsarslib (1)/common/media/scripts/commonlibrary/templates/template_incabin.txt`.
- Live has duplicate `tsarslib` folders: stale root-layout `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/tsarslib` with root `mod.info` and B42-ready `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/tsarslib (1)` with `common/mod.info`, `id=tsarslib`, and `versionMin=42.0.0`.
- Workshop cache was checked before patching. Current B42 source is `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3402491515/mods/tsarslib` with `common/mod.info`, `id=tsarslib`, `modversion=3.25`, plus `42.13` and `42.17` overlays. Older root source exists at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2392709985/mods/tsarslib`.
- Workshop current is newer than live and should be used for this B42.19 pass, but it still has the same Linux lowercase-path defect: uppercase script path components such as `common/media/scripts/commonlibrary/templates/template_InCabin.txt`, `template_Light*.txt`, `template_TV.txt`, and `template_TruckTank.txt`, plus `42.13`/`42.17` `template_TruckTank.txt`.
- `tsarslib` project repo created at `/home/cjstorrs/projects/game-mods/zomboid/tsarslib` from live `tsarslib (1)` with untouched baseline commit `0c0fe52` (`chore: import tsarslib live baseline`), branch `feat(4.19)/tsarslib-workshop-update`.
- `tsarslib` project update committed as `4a6749a` (`feat(4.19)/update-tsarslib-for-b42.19`): replaced the baseline payload with Workshop `3402491515`, added the current `42.13` and `42.17` overlays, recursively lowercased all path components under every `media/scripts` tree, and changed three Workshop executable Lua literals from `0.0f` to `0.0` in `42/media/lua/client/TimedActions/ISInstallTuningVehiclePart.lua`, `42/media/lua/client/TimedActions/ISUninstallTuningVehiclePart.lua`, and `common/media/lua/shared/ATAActionsTools.lua`.
- `tsarslib` live sync completed: moved stale root-layout `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/tsarslib` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/tsarslib-pre-b42-root`, moved B42-ready duplicate `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/tsarslib (1)` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/tsarslib (1)-pre-workshop-update`, and synced the project repo to lowercase active live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/tsarslib`.
- `tsarslib` validation: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, only one active live `tsarslib` folder remains, live `common/mod.info` preserves `id=tsarslib` and has `modversion=3.25`, all project and live Lua files pass `lua5.1 loadfile`, no `0.0f` executable literals remain, and no uppercase path components remain under any project or live `media/scripts` tree. Plain `git diff --check` reports CRLF line endings as trailing whitespace, so preserve CRLF rather than normalizing this Windows-origin Workshop payload.
- 13:32 retest with the cache bridge confirmed `tsarslib` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_13-32_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `2 - spongies clothing expansion`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/2 - spongies clothing expansion/42/media/scripts/clothing/spongieclothes_clothing_gloves.txt`.
- The 13:32 Project Zomboid process `3190441` was killed after capturing the failure, and the launcher session exited. Next action: inspect live/project/Workshop state for Spongie's Clothing, then apply the same lowercased live-folder/script-path pattern if confirmed.
- `2 - Spongies Clothing Expansion` project exists at `/home/cjstorrs/projects/game-mods/zomboid/2 - Spongies Clothing Expansion`, clean on `main` before patching, with prior local B42 commits `bb749f9`, `80a4357`, and `cf2329e`.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3264062541/mods/2 - Spongies Clothing Expansion`. Workshop is not a direct replacement for this setup because it lacks the project's `42/` and `Common/` B42 migration and differs from the local loot-distribution guard. Preserve the project payload.
- Confirmed Spongie's casing issue: project/live contain uppercase script filenames under both `42/media/scripts` and root `media/scripts` (`SpongieClothing_Recipes.txt`, `SpongieClothes_clothing_*.txt`), while B42.19 loads lowercased paths from a lowercased live root `2 - spongies clothing expansion`.
- Spongie's fix committed as `b1a2a9c` (`feat(4.19)/lowercase-spongies-script-paths`) on branch `feat(4.19)/lowercase-script-paths`: lowercased ten script filenames under project `42/media/scripts` and root `media/scripts`; no file contents changed.
- Spongie's live sync completed: moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/2 - Spongies Clothing Expansion` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/2 - Spongies Clothing Expansion-pre-lowercase-folder` and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/2 - spongies clothing expansion`.
- Spongie's validation: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` preserves `id=2VCESSPONGIESEXPANSION`, all project/live Lua files pass `lua5.1 loadfile`, only one active live Spongie folder remains, and no uppercase path components remain under live or project `media/scripts`.
- 13:35 retest with the cache bridge confirmed Spongie's no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_13-35_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `[J&G] Neon Vandals Uniform`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/[j&g] neon vandals uniform/42.13/media/scripts/clothing/neon_vandals_clothing.txt`.
- The 13:35 Project Zomboid process `3200586` was killed after capturing the failure, and the launcher session exited. Next action: inspect live/project/Workshop state for `[J&G] Neon Vandals Uniform`.
- `[J&G] Neon Vandals Uniform` project exists at `/home/cjstorrs/projects/game-mods/zomboid/[J&G] Neon Vandals Uniform`, clean on branch `feat(4.19)/workshop-update`, with commits `41702bd` baseline and `fea5f07` Workshop 42.19 update.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3497172953/mods/[J&G] Neon Vandals Uniform`; project and Workshop are identical before the casing patch.
- Confirmed Neon Vandals casing issue: project/live/Workshop contain uppercase script filenames under `42.13/media/scripts`, `42/media/scripts`, and root `media/scripts`, while B42.19 requests lowercased paths from lowercased live root `[j&g] neon vandals uniform`.
- Neon Vandals fix committed as `b8a6dd3` (`feat(4.19)/lowercase-neon-vandals-script-paths`) on branch `feat(4.19)/lowercase-script-paths`: lowercased eleven script filenames under project `42.13/media/scripts`, `42/media/scripts`, and root `media/scripts`; no file contents changed.
- Neon Vandals live sync completed: moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/[J&G] Neon Vandals Uniform` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/[J&G] Neon Vandals Uniform-pre-lowercase-folder` and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/[j&g] neon vandals uniform`.
- Neon Vandals validation: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42.13/mod.info` and `42/mod.info` preserve `id=[J&G] Neon Vandals Uniform` and `require=\KATTAJ1_ClothesCore`, all project/live Lua files pass `lua5.1 loadfile`, only one active live Neon Vandals folder remains, and no uppercase path components remain under live or project `media/scripts`.
- 13:39 retest with the cache bridge confirmed Neon Vandals no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_13-39_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `aircond42`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/aircond42/common/media/scripts/ac_sounds.txt`.
- The 13:39 Project Zomboid process `3210668` was killed after capturing the failure, and the launcher session exited. Next action: inspect live/project/Workshop state for `aircond42`.
- `AirCond42` live folder exists at `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/AirCond42`, but no project repo existed before this pass.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3449592259/mods/AirCond42`; live and Workshop are identical before patching.
- Confirmed `AirCond42` issue is live folder casing only: `common/media/scripts/ac_sounds.txt` is already lowercase in live/Workshop, and no uppercase script path components exist, but B42.19 requests the lowercased live root `aircond42`.
- `AirCond42` project repo created at `/home/cjstorrs/projects/game-mods/zomboid/AirCond42` from live with untouched baseline commit `e09aa63` (`chore: import AirCond42 live baseline`), branch `feat(4.19)/lowercase-live-folder`.
- `AirCond42` live sync completed: moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/AirCond42` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/AirCond42-pre-lowercase-folder` and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/aircond42`.
- `AirCond42` validation: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` preserves `id=AirCond42`, all project/live Lua files pass `lua5.1 loadfile`, only one active live AirCond folder remains, and no uppercase path components exist under live or project `media/scripts`.
- `AirCond42` commit `9acc5ba` (`feat(4.19)/lowercase-aircond42-live-folder`) is an intentional empty commit documenting the live-folder casing compatibility fix because no tracked file content changed.
- 13:43 retest with the cache bridge confirmed `AirCond42` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_13-43_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `Authentic Z - Current`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/authentic z - current/42/media/scripts/authenticz_edited_items.txt`.
- The 13:43 Project Zomboid process `3220770` was killed after capturing the failure, and the launcher session exited. Next action: inspect live/project/Workshop state for `Authentic Z - Current`.
- `Authentic Z - Current` project exists at `/home/cjstorrs/projects/game-mods/zomboid/Authentic Z - Current`, clean on branch `feat(4.19)/workshop-update`.
- Existing project commits must be preserved: `976fe9d` updated from Workshop, `5a3c431` guarded B42.19 body-location rebuild, and `8059b2e` pruned B42.19 clothing animation channels.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2335368829/mods/Authentic Z - Current`. The Workshop copy has the same mixed-case `media/scripts` paths, and project differs from Workshop in intentional local B42.19 fixes, so preserve the project payload.
- Confirmed Authentic Z casing issue: live/project/Workshop all contain uppercase script path components under active `42/media/scripts` and legacy root `media/scripts`, while B42.19 requests lowercased paths from lowercased live root `authentic z - current`.
- Authentic Z fix committed as `d88e177` (`feat(4.19)/lowercase-authenticz-script-paths`) on branch `feat(4.19)/lowercase-authenticz-script-paths`: recursively lowercased 86 script path components under project `42/media/scripts` and root `media/scripts`; no file contents changed.
- Authentic Z live sync completed: moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Authentic Z - Current` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/Authentic Z - Current-pre-lowercase-folder` and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/authentic z - current`.
- Authentic Z validation: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live root is lowercase while live `42/mod.info` and root `mod.info` preserve `id=Authentic Z - Current`, all project Lua files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, only one active live Authentic Z Current folder remains, and no uppercase path components remain under live or project `media/scripts`.
- 13:50 retest with the cache bridge confirmed `Authentic Z - Current` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_13-49_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `B42 PZLinux`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/b42 pzlinux/42/media/scripts/pzlinux-sounds.txt`.
- The 13:49 Project Zomboid process `3238253` was killed after capturing the failure, and the launcher session exited. Next action: inspect live/project/Workshop state for `B42 PZLinux`.
- `B42 PZLinux` project exists at `/home/cjstorrs/projects/game-mods/zomboid/B42 PZLinux`, clean on branch `feat(4.19)/trait-factory-compat`, with existing local gameplay commits such as contract reward tuning and sale filtering.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3414468585/mods/B42 PZLinux`. Workshop differs materially from the local project and does not fix the lowercase live-root issue, so preserve the local project payload.
- Confirmed `B42 PZLinux` issue is live folder casing only: project/live script path `42/media/scripts/pzlinux-sounds.txt` is already lowercase and no uppercase script path components exist, but B42.19 requests the lowercased live root `b42 pzlinux`.
- `B42 PZLinux` live sync completed: moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/B42 PZLinux` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/B42 PZLinux-pre-lowercase-folder` and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/b42 pzlinux`.
- `B42 PZLinux` validation: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` and `common/mod.info` preserve `id=B42_PZLinux`, all project `42/media/lua` files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, only one active live PZLinux folder remains, and no uppercase path components exist under live/project `media/scripts`.
- `B42 PZLinux` commit `6602811` (`feat(4.19)/lowercase-b42-pzlinux-live-folder`) is an intentional empty commit documenting the live-folder casing compatibility fix because no tracked file content changed.
- 13:53 retest with the cache bridge confirmed `B42 PZLinux` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_13-53_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `B42 Rain's Firearms & Gun Parts Expanded`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/b42 rain's firearms & gun parts expanded/42/media/scripts/rfngp_ammo.txt`.
- The 13:53 Project Zomboid process `3247172` was killed after capturing the failure, and the launcher session exited. Next action: inspect live/project/Workshop state for `B42 Rain's Firearms & Gun Parts Expanded`; preserve prior Rain's item-type / upgrade-table fixes.
- `B42 Rain's Firearms & Gun Parts Expanded` project exists at `/home/cjstorrs/projects/game-mods/zomboid/B42 Rain's Firearms & Gun Parts Expanded`, clean on branch `feat(4.19)/rains-weapon-upgrade-cleanup`.
- Existing project commits must be preserved, especially `7891c13` (`feat(4.19)/rains-weapon-upgrade-item-types`) plus the trait script fixes. These fixed the earlier `ItemPickerJava.DoWeaponUpgrade` world-entry casts.
- Workshop cache checked first with exact `id=B42RainsFirearmsAndGunPartsExpanded` and folder-name searches under `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600`; no matching Workshop source was found, so preserve the project payload.
- Confirmed Rain's Expanded casing issue: project/live contain mixed-case `42/media/scripts/RFNGP_*.txt` files, while B42.19 requests lowercased script names from lowercased live root `b42 rain's firearms & gun parts expanded`.
- Rain's Expanded fix committed as `073566a` (`feat(4.19)/lowercase-rains-expanded-script-paths`) on branch `feat(4.19)/lowercase-rains-expanded-script-paths`: lowercased 23 script filenames under project `42/media/scripts`; no file contents changed.
- Rain's Expanded live sync completed: moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/B42 Rain's Firearms & Gun Parts Expanded` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/B42 Rain's Firearms & Gun Parts Expanded-pre-lowercase-folder` and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/b42 rain's firearms & gun parts expanded`.
- Rain's Expanded validation: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` and root `mod.info` preserve `id=B42RainsFirearmsAndGunPartsExpanded`, all project `42/media/lua` files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, only one active live Rain's Expanded folder remains, and no uppercase path components remain under live/project `media/scripts`.
- 13:56 retest with the cache bridge confirmed Rain's Expanded no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_13-56_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `B42Makefruitinjar`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/b42makefruitinjar/42/media/scripts/items_makefruitinjar.txt`.
- The 13:56 Project Zomboid process `3256180` was killed after capturing the failure, and the launcher session exited. Next action: inspect live/project/Workshop state for `B42Makefruitinjar`.
- No `B42Makefruitinjar` project repo existed before this pass, so import the live mod into `/home/cjstorrs/projects/game-mods/zomboid/B42Makefruitinjar` and make an untouched baseline commit before patching.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3432006285/mods/B42Makefruitinjar`. Workshop is newer than live (`name=[B42.13] Make pickled fruit in jar`, `versionMin=42.13`, adds `42/media/registries.lua`, and changes model/script layout), but it still has mixed-case script filenames. Since no local project history exists, use Workshop current as the B42.19 base and then apply lowercase script/live-root compatibility.
- Confirmed `B42Makefruitinjar` casing issue: live has mixed-case script files such as `items_Makefruitinjar.txt`, while B42.19 requests lowercase `items_makefruitinjar.txt` from lowercase live root `b42makefruitinjar`.
- `B42Makefruitinjar` project repo created at `/home/cjstorrs/projects/game-mods/zomboid/B42Makefruitinjar` from live with untouched baseline commit `0d7cba6` (`chore: import B42Makefruitinjar live baseline`).
- `B42Makefruitinjar` fix committed as `a343016` (`feat(4.19)/update-makefruitinjar-for-b42.19`) on branch `feat(4.19)/makefruitinjar-workshop-lowercase`: replaced the project payload with Workshop `3432006285`, added Workshop `42/media/registries.lua` and current `Translate/EN` files, changed `42/mod.info` to Workshop B42.13 metadata, and lowercased active script filenames to `items_makefruitinjar.txt`, `models_x.txt`, and `recipes_makefruitinjar.txt`.
- `B42Makefruitinjar` live sync completed: moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/B42Makefruitinjar` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/B42Makefruitinjar-pre-workshop-update` and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/b42makefruitinjar`.
- `B42Makefruitinjar` validation: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` preserves `id=Makefruitinjar` with `versionMin=42.13`, no project/live uppercase path components remain under `media/scripts`, and only one active live Makefruitinjar folder remains. There are no Lua files to syntax-check. `git -c core.whitespace=cr-at-eol diff --check` flagged trailing whitespace in Workshop script text; preserved Workshop content rather than mixing a whitespace cleanup into this compatibility pass.
- 14:01 retest with the cache bridge confirmed `B42Makefruitinjar` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_14-01_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `B42PackMule`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/b42packmule/42/media/scripts/items_mule.txt`.
- The 14:01 Project Zomboid process `3265736` was killed after capturing the failure, and the launcher session exited. Next action: inspect live/project/Workshop state for `B42PackMule`.
- `B42PackMule` project exists at `/home/cjstorrs/projects/game-mods/zomboid/B42PackMule`, clean on branch `feat(4.19)/body-location-compat`, with existing local commits `d0abb7f` and `023de0f` for B42.19 body-location compatibility.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3540903327/mods/B42PackMule`. Workshop uses a different `42.14`/`common` layout and still has mixed-case script paths, so preserve the local project payload.
- Confirmed `B42PackMule` issue is live folder casing only: project/live script filenames are already lowercase (`items_mule.txt`, `models_mule.txt`, `recipes_mule.txt`), but B42.19 requests the lowercased live root `b42packmule`.
- `B42PackMule` live sync completed: moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/B42PackMule` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/B42PackMule-pre-lowercase-folder` and synced project to lowercase live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/b42packmule`.
- `B42PackMule` validation: project worktree clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` preserves `id=B42PackMulev2`, all project `42/media/lua` files pass `lua5.1 loadfile`, `git -c core.whitespace=cr-at-eol diff --check` passed, and no uppercase path components exist under live/project `media/scripts`.
- `B42PackMule` commit `b7bc184` (`feat(4.19)/lowercase-packmule-live-folder`) is an intentional empty commit documenting the live-folder casing compatibility fix because no tracked file content changed.
- 14:05 retest with the cache bridge confirmed `B42PackMule` no longer blocks startup. New latest log is `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_14-05_DebugLog.txt`.
- New immediate blocker: `ScriptManager.Load FileNotFoundException` for `B42Survival`:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/b42survival/42/media/scripts/items_survival.txt`.
- The 14:05 Project Zomboid process `3273477` was killed after capturing the failure, and the launcher session exited. Next action: inspect live/project/Workshop state for `B42Survival`.
- TchernoLib still needs final validation after the current startup file-not-found chain is cleared.
- `PIE42` is on branch `feat(4.19)/pie-map-folder-case`; only intentional project diff is `common/media/maps/PIElots/map.info` changing `title=maplots` to `title=PIElots`. Temporary PIE diagnostics are removed from project and live. Savefile modal no longer shows `PIElots` red.
- `TchernoLib` is on branch `feat(4.19)/tchernolib-workshop-update`; project uses minimal `common/` layout, lowercase `common/media/scripts/spawnitems.txt`, nil guards in `common/media/lua/client/Spectate/SpectateRemoveContext.lua`, and a guarded `TraitCollection.class` lookup in `common/media/lua/shared/Movement/WalkSpeedReverseEngineering.lua`.
- Live active TchernoLib folder is exactly `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/tchernolib`, with `common/mod.info`, `common/media/scripts/spawnitems.txt`, and no `.git`.
- Uppercase live TchernoLib duplicates remain disabled under `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/TchernoLib-pre-lowercase` and `TchernoLib (1)-pre-lowercase`.
- The accidental live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/home` tree was moved to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/home-pre-cleanup`. It mirrored lowercased paths under `home/cjstorrs/zomboid/mods/...`, including `tchernolib`, and likely caused the bogus `mods/home/cjstorrs/zomboid/mods/tchernolib/common/media/scripts/spawnitems.txt` FileNotFound path in the 12:30 log.
- The first retest after moving `mods/home` exposed the same broader B42.19 path issue on `67gt500`: `ScriptManager.Load` tried `/home/cjstorrs/Zomboid/mods/home/cjstorrs/zomboid/mods/67gt500/42.0/media/scripts/vehicles/template_gt500_armor.txt`. The root cause is B42.19 lowercasing mod root URIs on Linux; if the lowercased path does not exist, `File.toURI()` treats the lowercased version/common dir as a file and `URI.relativize()` fails.
- Runtime bridge added inside the workspace, not as a new top-level home entry: `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid` and `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid` both symlink to `/media/cjstorrs/windows/Users/cjsto/Zomboid`.
- Launch B42.19 with `JAVA_TOOL_OPTIONS=-Ddeployment.user.cachedir=/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent ./start.sh`. This makes `Core.getMyDocumentFolder()` use the bridge's `Zomboid` symlink while B42.19's lowercased URI base also exists through the bridge's `zomboid` symlink. Logs/saves/mods still resolve to the same Windows Zomboid data.
- `70dodge` project repo created from the live folder at `/home/cjstorrs/projects/game-mods/zomboid/70dodge`, baseline commit `5555d6c` (`chore: import 70dodge live baseline`), active branch `feat(4.19)/lowercase-vehicle-script-files`.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2873290424/mods/70dodge`; it has a newer `42.13` layout but still uses mixed-case `template_DG70*.txt` script filenames, so it does not directly fix the Linux lowercase load failure.
- `70dodge` fix synced live: renamed all root and `42.0/media/scripts/vehicles/*.txt` files with uppercase letters to all-lowercase names. File contents were not changed. Project/live `diff -qr --exclude=.git` is clean, live has no `.git`, and live `42.0/media/scripts` plus root `media/scripts` have no uppercase `.txt` filenames.
- Fix pattern learned: B42.19 lowercases script load paths on Linux. Active versioned script filenames containing uppercase letters can produce `ScriptManager.Load FileNotFoundException` paths like `<cache>/Zomboid/mods/home/.../template_dg70_armor.txt`. Rename active `media/scripts/*.txt` filenames to lowercase instead of restoring the bogus `mods/home` mirror.
- 12:46 bridge retest confirmed `70dodge` no longer fails; the next concrete `ScriptManager.Load FileNotFoundException` was `73fordfalcon/42.0/media/scripts/vehicles/template_flc73_armor.txt`.
- `73fordFalcon` project repo created from the live folder at `/home/cjstorrs/projects/game-mods/zomboid/73fordFalcon`, baseline commit `5bb8437` (`chore: import 73fordFalcon live baseline`), active branch `feat(4.19)/lowercase-vehicle-script-files`.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3490370700/mods/73fordFalcon`; it includes `42.13` but still uses mixed-case active script filenames, so it does not directly fix the Linux lowercase load failure.
- `73fordFalcon` fix synced live: renamed all root and `42.0/media/scripts/vehicles/*.txt` files with uppercase letters to all-lowercase names. File contents were not changed.
- `73fordFalcon` validation: `git diff --check` clean, Lua syntax passed for all root and `42.0` Lua files, project/live `diff -qr --exclude=.git` clean, live has no `.git`, and live root plus `42.0` `media/scripts` have no uppercase `.txt` filenames.
- `89fordBronco` was already a project repo at `/home/cjstorrs/projects/game-mods/zomboid/89fordBronco`; created branch `feat(4.19)/lowercase-vehicle-script-files` from the prior clean `feat(4.19)/bronco-template-fix` state.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2886833398/mods/89fordBronco`; it includes `42.13` but still uses mixed-case active script filenames, so it does not directly fix the Linux lowercase load failure.
- `89fordBronco` fix synced live: renamed all root and `42.0/media/scripts/vehicles/*.txt` files with uppercase letters to all-lowercase names. File contents were not changed.
- `89fordBronco` validation: `git diff --check` clean, Lua syntax passed for all root and `42.0` Lua files, project/live `diff -qr --exclude=.git` clean, live has no `.git`, and live root plus `42.0` `media/scripts` have no uppercase `.txt` filenames.
- Because the 12:46 failure path lowercased the full mod path, not only the filename, mixed-case live vehicle root folders also need the TchernoLib-style live casing fix. Moved active mixed-case live folders to disabled holding paths and synced the same project copies into lowercase live folders:
  - `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/73fordFalcon` -> `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/73fordFalcon-pre-lowercase-folder`; active live folder is now `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/73fordfalcon` with `id=73fordFalcon`.
  - `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/89fordBronco` -> `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/89fordBronco-pre-lowercase-folder`; active live folder is now `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/89fordbronco` with `id=89fordBronco`.
  - Project/live diffs against the lowercase folders are clean and no live `.git` exists.
- `67gt500` is enabled, but live/project active `media/scripts/vehicles/*.txt` filenames are already lowercase; no patch applied in this pass.
- `91range` project repo created from the live folder at `/home/cjstorrs/projects/game-mods/zomboid/91range`, baseline commit `2f231fb` (`chore: import 91range live baseline`), active branch `feat(4.19)/lowercase-vehicle-script-files`.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2409333430/mods/91range`; it includes `42.13` but still uses mixed-case active script filenames.
- `91range` fix synced live: renamed all root and `42.0/media/scripts/vehicles/*.txt` files with uppercase letters to all-lowercase names. File contents were not changed. Validation: `git diff --check` clean, Lua syntax passed, project/live diff clean, live has no `.git`, and live root plus `42.0` `media/scripts` have no uppercase `.txt` filenames.
- `97bushmaster` was already a project repo at `/home/cjstorrs/projects/game-mods/zomboid/97bushmaster`; created branch `feat(4.19)/lowercase-vehicle-script-files` from the prior clean `feat(4.19)/bushmaster-template-fix` state.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2897390033/mods/97bushmaster`; it includes `42.13` but still uses mixed-case active script filenames.
- `97bushmaster` fix synced live: renamed all root and `42.0/media/scripts/vehicles/*.txt` files with uppercase letters to all-lowercase names. File contents were not changed. Validation: `git diff --check` clean, Lua syntax passed, project/live diff clean, live has no `.git`, and live root plus `42.0` `media/scripts` have no uppercase `.txt` filenames.
- Vehicle filename commits:
  - `70dodge` `b314a27` (`feat(4.19)/lowercase-70dodge-script-files`).
  - `73fordFalcon` `65498ac` (`feat(4.19)/lowercase-73fordfalcon-script-files`).
  - `89fordBronco` `e2d0f49` (`feat(4.19)/lowercase-89fordbronco-script-files`).
  - `91range` `3a136c9` (`feat(4.19)/lowercase-91range-script-files`).
  - `97bushmaster` `6e7096c` (`feat(4.19)/lowercase-97bushmaster-script-files`).
- 12:59 relaunch with the cache bridge hit the next same-class failure before menu:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/ata_bus/common/media/scripts/vehicles/templates/template_ata2bus.txt`.
- `ATA_Bus` project repo already existed at `/home/cjstorrs/projects/game-mods/zomboid/ATA_Bus`; worktree was clean. Created branch `feat(4.19)/lowercase-live-folder`.
- Workshop cache checked first:
  - Current B42 Workshop source found at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3402812859/mods/ATA_Bus/common/mod.info`.
  - Older Workshop source also exists at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2592358528/mods/ATA_Bus/mod.info`.
  - Project/live script filenames were already lowercase, so the failure was the mixed-case live root folder name.
- `ATA_Bus` live fix: moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/ATA_Bus` to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/ATA_Bus-pre-lowercase-folder` and synced the project copy to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/ata_bus`.
- `ATA_Bus` validation: project/lowercase-live `diff -qr --exclude=.git` clean, live has no `.git`, live `common/mod.info` still has `id=ATA_Bus`, and live active script filenames under `common` and `42.13` have no uppercase `.txt` names.
- `ATA_Bus` commit `4be81d8` (`feat(4.19)/lowercase-ata-bus-live-folder`) is an intentional empty commit documenting the live-folder casing compatibility fix because no tracked file content changed.
- 13:02 relaunch with the cache bridge hit the next same-class failure before menu:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/autotsartrailers (1)/common/media/scripts/vehicles/templates/template_earthing.txt`.
- Live had duplicate Autotsar Trailers folders:
  - `AutotsarTrailers`: stale root-layout copy with root `mod.info`.
  - `AutotsarTrailers (1)`: B42-ready copy with `common/mod.info`, and the source of the failing path.
- Workshop cache checked first:
  - Current B42 Workshop source found at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3402493701/mods/AutotsarTrailers`.
  - Older Workshop source exists at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2282429356/mods/AutotsarTrailers`.
  - Workshop current differs materially from the live payload, so this pass preserved the live B42-ready payload and fixed only the path/discovery issue.
- `autotsartrailers` project repo created from live `AutotsarTrailers (1)` at `/home/cjstorrs/projects/game-mods/zomboid/autotsartrailers`, baseline commit `097e030` (`chore: import autotsartrailers live baseline`), branch `feat(4.19)/lowercase-live-folder`.
- `autotsartrailers` live fix: moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/AutotsarTrailers` and `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/AutotsarTrailers (1)` to disabled holding, then synced the project copy to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/autotsartrailers`.
- `autotsartrailers` validation: project/lowercase-live `diff -qr --exclude=.git` clean, live has no `.git`, live `common/mod.info` still has `id=autotsartrailers`, active script filenames have no uppercase `.txt` names, and Lua syntax passed for all imported `common/media/lua` files.
- `autotsartrailers` commit `193cf1d` (`feat(4.19)/lowercase-autotsartrailers-live-folder`) is an intentional empty commit documenting the live-folder casing compatibility fix because no tracked file content changed.
- 13:06 relaunch with the cache bridge hit the next same-class failure before menu:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/autoturret/42.0/media/scripts/vehicles/turret/template_turret60mmmotor.txt`.
- `AutoTurret` had no project repo. Live and Workshop matched before patching; Workshop source checked at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3388599064/mods/AutoTurret`.
- `AutoTurret` project repo created from live at `/home/cjstorrs/projects/game-mods/zomboid/AutoTurret`, baseline commit `00d359b` (`chore: import AutoTurret live baseline`), branch `feat(4.19)/lowercase-script-paths`.
- `AutoTurret` fix:
  - Recursively lowercased all path components under `42.0/media/scripts`, including root script filenames, `vehicles/Turret` -> `vehicles/turret`, and vehicle/template filenames.
  - Moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/AutoTurret` to disabled holding and synced the project copy to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/autoturret`.
- `AutoTurret` validation: `git diff --check` clean, Lua syntax passed for all `42.0/media/lua` files, project/lowercase-live `diff -qr --exclude=.git` clean, live has no `.git`, live `42.0/mod.info` still has `id=AutoTurret`, and live `42.0/media/scripts` has no uppercase path components.
- `AutoTurret` commit `34b19e8` (`feat(4.19)/lowercase-autoturret-script-paths`).
- 13:10 relaunch with the cache bridge hit the next same-class failure before menu:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/damnlib/42.17/media/scripts/airbrake/template_airbrake.txt`.
- `damnlib` project repo already existed at `/home/cjstorrs/projects/game-mods/zomboid/damnlib` on clean branch `feat(4.19)/damnlib-workshop-update`; current line included prior commits `dfdd6d3` and `33adde7`.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3171167894/mods/damnlib`; it has the same mixed-case script path pattern.
- `damnlib` fix:
  - Created branch `feat(4.19)/lowercase-script-paths`.
  - Recursively lowercased all path components under `42.0/media/scripts`, `42.13/media/scripts`, `42.17/media/scripts`, and root `media/scripts`.
  - This included active selected path `42.17/media/scripts/airBrake/template_airBrake.txt` -> `42.17/media/scripts/airbrake/template_airbrake.txt`, plus commonItems/runFlat/USMIL/damnCraft/CTIsystem and related script filenames.
- `damnlib` validation: `git diff --check` clean, project/live `diff -qr --exclude=.git` clean, live has no `.git`, live `42.0`, `42.13`, and `42.17` mod infos still have `id=damnlib`, and live script trees have no uppercase path components. No Lua files were changed.
- `damnlib` commit `1667e00` (`feat(4.19)/lowercase-damnlib-script-paths`).
- 13:13 relaunch with the cache bridge hit the next same-class failure before menu:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/ki5campers/42.13/media/scripts/vehicles/template_ki5cr_armor.txt`.
- `KI5campers` project repo already existed at `/home/cjstorrs/projects/game-mods/zomboid/KI5campers` on clean branch `feat(4.19)/stabilizer-template-fix`.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3670064951/mods/KI5campers`; it has the same mixed-case script path pattern.
- `KI5campers` fix:
  - Created branch `feat(4.19)/lowercase-script-paths`.
  - Recursively lowercased all path components under `42.0/media/scripts`, `42.13/media/scripts`, and root `media/scripts`.
  - Moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/KI5campers` to disabled holding and synced the project copy to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/ki5campers`.
- `KI5campers` validation: `git diff --check` clean, Lua syntax passed for `42.0`, `42.13`, and root Lua files, project/lowercase-live `diff -qr --exclude=.git` clean, live has no `.git`, live `42.0` and `42.13` mod infos still have `id=KI5campers`, and live script trees have no uppercase path components.
- `KI5campers` commit `15350ce` (`feat(4.19)/lowercase-ki5campers-script-paths`).
- 13:16 relaunch with the cache bridge hit the next same-class failure before menu:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/rsemitruck/common/media/scripts/vehicles/template_vehicle_freezer.txt`.
- `rSemiTruck` project repo already existed at `/home/cjstorrs/projects/game-mods/zomboid/rSemiTruck` on clean branch `feat(4.19)/vehicle-template-fixes`.
- Workshop cache checked first at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3409472393/mods/rSemiTruck`; it has the same mixed-case script path pattern.
- `rSemiTruck` fix:
  - Created branch `feat(4.19)/lowercase-script-paths`.
  - Recursively lowercased all path components under `common/media/scripts`.
  - Moved `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/rSemiTruck` to disabled holding and synced the project copy to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/rsemitruck`.
- `rSemiTruck` validation: `git diff --check` clean, Lua syntax passed for `common`, `42`, and `42.17` Lua files, project/lowercase-live `diff -qr --exclude=.git` clean, live has no `.git`, live `common`, `42`, and `42.17` mod infos still have `id=rSemiTruck`, and live `common/media/scripts` has no uppercase path components.
- `rSemiTruck` commit `92ad206` (`feat(4.19)/lowercase-rsemitruck-script-paths`).
- 13:19 relaunch with the cache bridge hit the next same-class failure before menu:
  `/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/Zomboid/mods/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent/zomboid/mods/standardizedvehicleupgrades3core/common/media/scripts/tuning2/template_ata2_roof_lights.txt`.
- Live had duplicate SVU Core folders:
  - `StandardizedVehicleUpgrades3Core`: B42-ready copy with `42/` and `common/`, active source.
  - `StandardizedVehicleUpgrades3Core (1)`: stale root-layout copy.
- Workshop cache checked first:
  - Current B42 Workshop source at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3403490889/mods/StandardizedVehicleUpgrades3Core`.
  - Older/root Workshop package also exists at `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3304580957/mods/StandardizedVehicleUpgrades3Core`.
  - Script filenames were already lowercase; failure was the mixed-case live root folder.
- `StandardizedVehicleUpgrades3Core` project repo created from the B42-ready live folder at `/home/cjstorrs/projects/game-mods/zomboid/StandardizedVehicleUpgrades3Core`, baseline commit `b3af595` (`chore: import StandardizedVehicleUpgrades3Core live baseline`), branch `feat(4.19)/lowercase-live-folder`.
- SVU Core live fix: moved both old live folders to disabled holding and synced the project copy to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/standardizedvehicleupgrades3core`.
- SVU Core validation: project/lowercase-live `diff -qr --exclude=.git` clean, live has no `.git`, live `42/mod.info` still has `id=StandardizedVehicleUpgrades3Core`, and live `common/media/scripts` has no uppercase path components.
- SVU Core commit `910e657` (`feat(4.19)/lowercase-svu-core-live-folder`) is an intentional empty commit documenting the live-folder casing compatibility fix because no tracked file content changed.
- Immediate next action: relaunch B42.19 with the cache bridge and confirm the `ScriptManager.Load FileNotFoundException` chain is gone or identify the next exact failing mod path.

## User Steering

- Prior Codex session `019f15e4-dd1d-7963-9268-d916dfbe69f7` is corrupted. Do not resume it. It is okay to read its JSONL log at `/home/cjstorrs/.codex/sessions/2026/06/29/rollout-2026-06-29T17-19-08-019f15e4-dd1d-7963-9268-d916dfbe69f7.jsonl`.
- Pay close attention to user steering from that log.
- If the mod confirmation or missing-mod list appears after Continue, a mod is not loading properly. Do not click Yes/Continue through it. Stop, read the list/logs, and fix the missing mod.
- Check the Windows Steam Workshop cache for an update before patching a mod. The cache root is `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600`.
- Do not give up on driving the game. Short `xdotool` clicks were unreliable. Try pyautogui, gamepad input, AutoHotkey-like approaches if available, or longer click down/up timings. Reacquire the current window after prompts because the window ID can change.
- Commits/branches for fixes should be named like `feat(4.19)/{description}`.
- Work in project mod repos under `/home/cjstorrs/projects/game-mods/zomboid/<mod>`, then sync live mods. Do not edit live as the source of truth unless importing first.
- Prefer fixing the actual broken mod over adding one broad helper/compatibility mod.
- Preserve local/new functionality in mods that were already modified. When using Workshop updates, inspect and carry forward local behavior that still matters.
- This is a B42.12-to-B42.19 migration, not a B41-to-B42 migration. Old compatibility can be removed when it slows or complicates the B42.19 fix.

## Paths

- Project workspace: `/home/cjstorrs/projects/game-mods/zomboid`
- Live Zomboid data: `/media/cjstorrs/windows/Users/cjsto/Zomboid`
- Convenience symlink: `/home/cjstorrs/Zomboid -> /media/cjstorrs/windows/Users/cjsto/Zomboid`
- Live mods: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods`
- Active save: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-06-27_21-27-42`
- Active save backup from last launch: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-06-27_21-27-42_backup`
- Native B42.19 launch path: `/home/cjstorrs/games/Project Zomboid Linux 42.19.0/start.sh`
- Logs to inspect first: `/media/cjstorrs/windows/Users/cjsto/Zomboid/console.txt`, then `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/`

## Workflow

1. Read this file and the latest `console.txt`.
2. Confirm no Project Zomboid process is still running before editing or syncing.
3. For the mod named by the log, check the active `id=`, project repo history, and Windows Workshop cache before editing.
4. If it is an updated third-party Workshop mod with no intentional local edits and a safe matching `id=`, install Workshop directly to live `Zomboid/mods`, move the old live folder to disabled holding, and apply only live-only B42.19/Linux casing normalization. Do not create a project branch or commit.
5. If there are intentional local edits, no safe Workshop source, non-drop-in Workshop differences, or real content/code fixes needed, patch the project repo on a `feat(4.19)/...` branch.
6. Run Lua syntax checks with `lua5.1 -e "assert(loadfile('path.lua'))"` for changed Lua files.
7. Current superseding workflow: link project-backed mods live with `DRY_RUN=1 ./link-project-mod.sh <mod>` then `./link-project-mod.sh <mod>`. Use `../link-zomboid-project-mods.sh` only to reconcile already-present project-backed live entries unless the user explicitly asks for a broader link pass.
8. Run the Zomboid review gate: changed files, B42 layout, live drift, no live `.git`, line endings, latest logs.
9. Launch B42.19 and continue the active save. Stop at any missing-mod confirmation.
10. Check logs again. Fix the next concrete error.
11. Commit each project-owned mod repo separately once its fix is validated and synced. Direct-Workshop live-only installs are recorded here, not committed.

## In Progress: Rain's Weapon Upgrade Cleanup

- Current target log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_09-17_DebugLog.txt`.
- Current error: repeated `IsoChunk.doLoadGridsquare` `ClassCastException: zombie.inventory.types.ComboItem cannot be cast to zombie.inventory.types.HandWeapon` at `ItemPickerJava.DoWeaponUpgrade(ItemPickerJava.java:1730)`.
- Bytecode/static cause: `DoWeaponUpgrade` reads global Lua `WeaponUpgrades`; if an item type is a key in that table, Java blindly casts the rolled item to `HandWeapon`.
- Active save/log only load `B42RainsFirearmsAndGunPartsExpanded` and `B42RainsFirearmsAndGunPartsMoreCombos` among the firearms upgrade providers. Installed but inactive upgrade providers include Guns93, Arsenal/GunFighter, and VFE.
- Active Rain's Expanded file: `/home/cjstorrs/projects/game-mods/zomboid/B42 Rain's Firearms & Gun Parts Expanded/42/media/lua/server/Items/RFNGP_Upgrades.lua`.
- Live Rain's Expanded file: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/B42 Rain's Firearms & Gun Parts Expanded/42/media/lua/server/Items/RFNGP_Upgrades.lua`.
- Project branch: `feat(4.19)/rains-weapon-upgrade-cleanup`.
- Workshop cache check for `id=B42RainsFirearmsAndGunPartsExpanded` under `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600` returned no matching `mod.info` before patching.
- Static parser result against vanilla B42.19 scripts plus active Rain's Expanded scripts: every real `WeaponUpgrades` key resolves to a `Type = Weapon` item except `P90`.
- `P90` in Rain's Expanded is orphaned: it appears in `RFNGP_Upgrades.lua`, the 9mm P90 magazine `GunType`, and translations, but there is no active `item P90` script definition and the Expanded package no longer inserts `Base.P90` into distributions.
- Base Rain's patch in progress: removed the orphaned `P90 = {...}` row from `RFNGP_Upgrades.lua`, preserving CRLF line endings, and synced the changed file to live.
- 09:35 retest after the P90 cleanup still reproduced `ItemPickerJava.DoWeaponUpgrade` at world-entry:
  - `ComboItem` -> `HandWeapon` at log lines `32811` and `32833`;
  - `ComboItem` -> `WeaponPart` at log line `32855`.
- Revised cause: active More Combos addon (`B42RainsFirearmsAndGunPartsMoreCombos`) has partial `item` blocks in `RFNGPEX_*.txt` that add `ModelWeaponPart`, `MountOn`, or recipe metadata without the B42 `Type` field. In B42.19 those overlays can materialize as generic `ComboItem`, which matches both Java casts.
- Active More Combos project repo: `/home/cjstorrs/projects/game-mods/zomboid/Rain's Firearms & Gun Parts - More Combos`.
- Active More Combos live folder: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Rain's Firearms & Gun Parts - More Combos`.
- More Combos branch: `feat(4.19)/more-combos-item-types`.
- More Combos patch in progress: add explicit `Type = Weapon` to partial weapon blocks, `Type = WeaponPart` to partial weapon-part blocks, and `Type = Literature` to the `SuppressorMag` overlay, preserving CRLF line endings.
- Additional base Rain's upgrade-table fix: `8xScope` and `8xACOGScope` were stale IDs; actual B42 item IDs are `x8Scope` and `x8ACOGScope`. Replaced those stale upgrade values in `RFNGP_Upgrades.lua`.
- Static validator after both patches: `problems 0` across vanilla B42.19 scripts, Rain's Expanded scripts, and More Combos scripts. Meaning every active `WeaponUpgrades` key resolves to a weapon and every referenced upgrade item resolves to a weapon part.
- 09:45 retest after Rain's + More Combos fixes reduced `DoWeaponUpgrade` to one remaining `ComboItem` cast. Active-save script-order validator across all 269 enabled mods found `UndeadSurvivor42` as the last provider redefining active weapon-part IDs (`AmmoStraps`, `Laser`, `RecoilPad`, `RedDot`, `Sling`, `x2Scope`, `x4Scope`, `x8Scope`) without type fields.
- Active Undead Survivor project repo: `/home/cjstorrs/projects/game-mods/zomboid/Undead Survivor`; branch `feat(4.19)/attachment-compat`.
- Active Undead Survivor live folder: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Undead Survivor`.
- Workshop source checked: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3739427877/mods/Undead Survivor`. Project/live intentionally differ from Workshop due prior local B42.19 attachment commits; preserve local changes.
- Undead Survivor project patch synced live: added `Type = WeaponPart` to those partial weapon-part overlay blocks, preserving CRLF line endings.
- Review/validation after Undead sync:
  - CRLF-aware `git diff --check` passed.
  - Live Undead file matches the project file.
  - Live Undead folder has `42/mod.info` and no `.git`.
  - Active-save script-order validator across all 269 enabled mods found `missing_ids 0`, `bad_weapon_last 0`, and `bad_part_last 0`.
- 09:56 retest after the Rain's Expanded, More Combos, and Undead Survivor script-type patches still reproduced two `ItemPickerJava.DoWeaponUpgrade` casts at world-entry:
  - `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_09-56_DebugLog.txt` line `32811`: `ComboItem` cannot be cast to `WeaponPart`.
  - Same log line `32835`: `ComboItem` cannot be cast to `HandWeapon`.
  - The static selected-root validator still reported `missing_ids 0`, `bad_weapon_last 0`, and `bad_part_last 0`, so text-level script parsing is not enough. Use runtime diagnostics or a more exact B42 script-resolution audit to identify which `WeaponUpgrades` key or upgrade value is still creating `ComboItem`.
  - Immediate suspects to inspect before more broad fixes: More Combos `RFNGPEX_attachments.txt` still has `item 12gSuppressorImproved`; Undead Survivor `Firearms_UndeadSurvivor.txt` starts with legacy `ItemType = base:weaponpart` and has other `ItemType = base:...` overlay blocks.
- 10:10 retest with a temporary Rain's Expanded diagnostic reached world-entry and did not contain any `DoWeaponUpgrade`, `ComboItem cannot be cast`, or `ClassCastException` lines in `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_10-10_DebugLog.txt`.
  - The temporary diagnostic itself was flawed: it called inventory methods on a runtime script item and produced a `RFNGP_WeaponUpgradeDiagnostics.lua` Lua stack. That diagnostic has been removed from both project and live copies and must not be committed.
  - Do not treat this as proof because the diagnostic changed load/runtime behavior and then crashed itself.
- 10:15 clean retest with the diagnostic removed still reproduced one `ItemPickerJava.DoWeaponUpgrade` cast at world-entry:
  - `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_10-15_DebugLog.txt` line `32812`: `ComboItem` cannot be cast to `HandWeapon`.
  - The previous `WeaponPart` cast was absent in the targeted search, so the attachment/item-part side is likely fixed by the More Combos and Undead Survivor `Type = WeaponPart` patches.
  - Current blocker is one remaining `WeaponUpgrades` key whose active B42.19 script definition still materializes as `ComboItem`, or whose type is changed by a load path the static parser does not model.
- 10:24 diagnostic retest with a temporary Rain's script confirmed the static parser was missing a B42.19 script-field change:
  - Runtime script lookups reported many custom Rain weapon definitions as `ItemType:base:normal` even though they still had legacy `Type = Weapon`.
  - Vanilla B42.19 generated scripts use `ItemType = base:weapon`, `ItemType = base:weaponpart`, and `ItemType = base:literature`.
  - Keep the existing legacy `Type = ...` lines, but add the matching B42.19 `ItemType = base:...` line immediately after them.
  - The temporary diagnostic produced early noise and has been removed from both project and live copies. Do not commit it.
- Current Rain's/More Combos/Undead patch state:
  - Rain's Expanded adds `ItemType = base:weapon`, `base:weaponpart`, or `base:literature` to every changed active `42/media/scripts/*.txt` item definition that declares `Type = Weapon`, `Type = WeaponPart`, or `Type = Literature`.
  - More Combos adds the same `ItemType` fields to its partial weapon, weapon-part, and SuppressorMag overlays.
  - Undead Survivor adds `ItemType = base:weaponpart` to the active partial weapon-part overlays for `x2Scope`, `x4Scope`, `x8Scope`, `AmmoStraps`, `Sling`, `RecoilPad`, `RedDot`, and `Laser`.
  - Rain's Expanded also still removes orphaned `P90` from `WeaponUpgrades` and corrects stale `8xScope` / `8xACOGScope` upgrade IDs to `x8Scope` / `x8ACOGScope`.
  - Validation before the next clean retest: `lua5.1 loadfile` passed for `RFNGP_Upgrades.lua`; CRLF-aware `git diff --check` passed; changed script files still use CRLF; corrected adjacency check passed for `Type` followed by `ItemType`; live changed files match project copies; live folders have `42/mod.info` and no `.git`.
- 10:36 clean retest result:
  - Log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_10-36_DebugLog.txt`.
  - Reached main menu, clicked Continue, no missing-mod confirmation appeared, reached `Click to Start`, clicked into world-entry, then the game exited after the existing save recursion.
  - Targeted scan found no `DoWeaponUpgrade`, no `ComboItem`, no `ClassCastException`, and no leftover Rain diagnostic lines.
  - Rain's Expanded commit `7891c13` on branch `feat(4.19)/rains-weapon-upgrade-cleanup`: `feat(4.19)/rains-weapon-upgrade-item-types`.
  - More Combos commit `997e507` on branch `feat(4.19)/more-combos-item-types`: `feat(4.19)/more-combos-item-types`.
  - Undead Survivor commit `960c3c9` on branch `feat(4.19)/attachment-compat`: `feat(4.19)/undead-attachment-item-types`.
- Next active errors after the Rain weapon-upgrade fix:
  - `PlayerDB.loadPlayer` `BufferUnderflowException` after data-length mismatches for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.
  - `TchernoLib` `ContextDebugHighlights(SpectateRemoveContext.lua:99)`.
  - `Right-click Watch To Set Alarm`: `expected argument of type ItemBodyLocation, got String` at `RightClickWatchToSetAlarm.lua:7`, called both from its own Add path and from `Two Weapons on Back cjs`.
  - `Neon moodle levels`: `Object tried to call nil` at `neonMoodleLevels.lua:120`.
  - `CJS Furniture Storage Boost`: `Object tried to call nil` at `CJS_FurnitureStorageBoost.lua:620`, through CleanUI/SmarterStorage/Proximity Inventory.
  - `More Traits. ComputerPers FIX`: `Blissful(MoreTraits.lua:1411)` calls a nil API during `MainPlayerUpdate`.
  - Final crash remains `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)`.
- Next action: investigate the next concrete mod stack. The earliest high-signal mod stack after world-entry is `Right-click Watch To Set Alarm`; `PlayerDB.loadPlayer` and final save recursion remain important but need careful save-data handling.

## Completed Fix: Right-click Watch To Set Alarm

- Target logs:
  - Broken: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_10-36_DebugLog.txt`.
  - Validated: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_10-44_DebugLog.txt`.
- Error: `expected argument of type ItemBodyLocation, got String` at `RightClickWatchToSetAlarm.lua:7`, from both the mod's own `Add` path and `Two Weapons on Back cjs` attachment updates.
- Project repo imported from the live copy because it was not previously present: `/home/cjstorrs/projects/game-mods/zomboid/RightClickWatchToSetAlarm`.
- Untouched baseline commit: `ccde5c2` (`chore: import RightClickWatchToSetAlarm baseline`) on `main`.
- Active branch: `feat(4.19)/watch-alarm-body-location`.
- Live mod: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/RightClickWatchToSetAlarm`.
- Workshop source checked: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3494878047/mods/RightClickWatchToSetAlarm`.
- Live and Workshop copies matched before patching, so there is no upstream B42.19 fix to adopt.
- B42.19 cause: `IsoGameCharacter:getWornItem` now expects an `ItemBodyLocation` value, not legacy strings like `"LeftWrist"` / `"RightWrist"`.
- Patch in progress:
  - `42/media/lua/client/RightClickWatchToSetAlarm.lua` now uses `ItemBodyLocation.LEFT_WRIST` and `ItemBodyLocation.RIGHT_WRIST`.
  - `media/lua/client/RightClickWatchToSetAlarm.lua` has the same change for the root copy.
  - CRLF line endings preserved; no final newline churn.
- Validation before retest:
  - `lua5.1 loadfile` passed for both changed Lua files.
  - CRLF-aware `git diff --check` passed.
  - Project/live changed files match.
  - Live folder has `42/mod.info`, `42/poster.png`, `42/icon.png`, and no `.git`.
- 10:44 retest result:
  - Reached main menu, clicked Continue, no missing-mod confirmation appeared, reached `Click to Start`, clicked into world-entry, then the game exited after the existing save recursion.
  - Targeted scan found only normal `RightClickWatchToSetAlarm` mod-load lines and no `expected argument of type ItemBodyLocation`, `getAlarmItem`, `LeftWrist`, or `RightWrist` stack hits.
  - Commit `ea97979` on branch `feat(4.19)/watch-alarm-body-location`: `feat(4.19)/watch-alarm-body-location`.

## Next Active Errors From 10:44

- `PlayerDB.loadPlayer` still reports `BufferUnderflowException` after data-length mismatches for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.
- `TchernoLib`: `ContextDebugHighlights(SpectateRemoveContext.lua:99)` throws while vanilla initializes `ISMenuContextWorld`.
- `CJS Furniture Storage Boost`: `Object tried to call nil` in `effectiveCapacityForCharacter(CJS_FurnitureStorageBoost.lua:620)` through CleanUI, Smarter Storage, and Proximity Inventory.
- `More Traits. ComputerPers FIX`: `Object tried to call nil` in `Blissful(MoreTraits.lua:1411)` during `MainPlayerUpdate`.
- `Milk Them All` still auto-disables because `MTA_ISMilkAnimal initialise()` sees `null java.lang.StackOverflowError`.
- Final crash remains `Unhandled java.lang.StackOverflowError` in repeated `KahluaTableImpl.save(...)`.
- The watch fix is validated; do not reinvestigate it unless a later log shows a new watch stack.

## In Progress: TchernoLib

- Current target log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_10-44_DebugLog.txt`.
- Error: `Lua((MOD:TchernoLib)).ContextDebugHighlights(SpectateRemoveContext.lua:99)` throws during vanilla `ISMenuContextWorld` init.
- Live has two same-id copies:
  - `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/TchernoLib` is an old root-layout copy with root `mod.info`.
  - `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/TchernoLib (1)` is a partial B42-layout copy, but it is behind the Workshop cache and lacks the `42.13` spectate override.
- Workshop cache checked:
  - Current B42 Workshop copy: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3389605231/mods/TchernoLib`.
  - Older Workshop copy: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2986578314/mods/TchernoLib`.
- Workshop `3389605231` already contains the relevant B42 guard in `42.13/media/lua/client/Spectate/SpectateRemoveContext.lua`: it captures `ISWorldMenuElements.ContextDebugHighlights` only when present before wrapping it.
- Project repo: `/home/cjstorrs/projects/game-mods/zomboid/TchernoLib`.
- Baseline commit: `2d58e0a` (`chore: import TchernoLib live baseline`) on `main`.
- Active branch: `feat(4.19)/tchernolib-workshop-update`.
- Patch state:
  - Project tree has been replaced with Workshop `3389605231`.
  - The same project tree has been synced to both live duplicate folders with `.git` excluded.
  - Project/live `diff -qr --exclude=.git` is clean for both live `TchernoLib` and `TchernoLib (1)`.
  - Neither live folder has a `.git` directory.
  - Live B42 layout now has `common/mod.info`, `42/TchernoLib.png`, and the `42.13` Lua overrides.
- Validation notes:
  - Targeted `lua5.1 loadfile` passed for `42.13/media/lua/client/Spectate/SpectateRemoveContext.lua`.
  - Project-wide stock `lua5.1` syntax checks are not useful for this upstream mod because several files use Kahlua/Java numeric suffixes such as `0.0F` / `1.0D` or require live PZ globals/modules.
- 10:55 failed packaging retest:
  - Log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_10-55_DebugLog.txt`.
  - The full Workshop B42 layout loaded far enough to show TchernoLib B42 overrides, but then `ScriptManager.Load` threw `FileNotFoundException` for `/home/cjstorrs/Zomboid/mods/home/cjstorrs/zomboid/mods/tchernolib/42.15/media/scripts/spawnitems.txt`.
  - This appears to be a Linux/path-case/versioned-script packaging issue, not the original world-entry `ContextDebugHighlights` runtime error.
  - The PZ process was stopped after the failed run.
- Revised targeted patch:
  - Restored the project tree from the live-baseline commit to keep the old root layout.
  - Applied the upstream `ISWorldMenuElements` nil guards only to `media/lua/client/Spectate/SpectateRemoveContext.lua`.
  - Preserved CRLF line endings in the touched Lua file.
  - `lua5.1 loadfile` passed for the touched root-layout Lua file.
  - CRLF-aware `git diff --check` passed.
  - Synced the same targeted root-layout project tree to both live duplicate folders with `.git` excluded.
  - Project/live `diff -qr --exclude=.git` is clean for both live folders, and no live `.git` exists.
- Next action: launch B42.19 again and confirm no missing-mod prompt appears, no TchernoLib script-path `FileNotFoundException` appears, and the latest log no longer has the `TchernoLib` `ContextDebugHighlights` stack.
- 10:59 retest with targeted root-layout patch:
  - Log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_10-59_DebugLog.txt`.
  - The TchernoLib script-path `FileNotFoundException` did not recur.
  - Continue showed the savefile warning panel instead of loading to `Click to Start`; do not click `Yes`.
  - Save-required mod IDs were all installed.
  - Root cause found in enabled/default list drift: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/default.txt` had one extra enabled mod, `cjsSimpleBows`, that is not in the active save.
  - Removed only `mod = \cjsSimpleBows,` from `mods/default.txt`, preserved CRLF, and verified the default mod list now exactly matches the save's 269 mod IDs.
- Next action: retest Continue again; expect no savefile warning panel, no TchernoLib `FileNotFoundException`, and no `ContextDebugHighlights` stack after world-entry.
- 11:10 retest after aligning `mods/default.txt`:
  - Log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_11-10_DebugLog.txt`.
  - The same `Error loading savefile` modal still appeared.
  - Reading vanilla `MainScreen.checkSaveFile()` showed the modal is raised for missing maps, missing mods, invalid/corrupt/old/newer save metadata.
  - Save/default mod order matches exactly and all save mod IDs are installed, so this is not a missing-mod-ID modal.
  - Map comparison found the likely missing custom map: the save expects `PIELots`, but live/Workshop `PIE42` currently has `common/media/maps/PIElots` and no `PIELots/map.info`.
  - The game was stopped without clicking `Yes`.

## In Progress: PIE42 Missing Map Folder

- Current target: fix the `PIELots` save-map availability check so Continue does not show the `Error loading savefile` modal.
- Live mod: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/PIE42`.
- Workshop source checked: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3507117617/mods/PIE42`; it also has `common/media/maps/PIElots`, not `PIELots`.
- Project repo created from the live copy: `/home/cjstorrs/projects/game-mods/zomboid/PIE42`.
- Baseline commit: `3a0148c` (`chore: import PIE42 live baseline`) on `main`.
- Active branch: `feat(4.19)/pie-map-folder-case`.
- Patch state:
  - Renamed project folder `common/media/maps/PIElots` to `common/media/maps/PIELots` so the installed map folder matches the active save's map name on Linux.
  - Updated `common/media/lua/client/ISUI/Maps/PIE_MapDefinitions.lua` to use `LootMaps.PIE_MAP_DIRECTORY = 'media/maps/PIELots'`.
- Validation before live sync:
  - `lua5.1 -e "assert(loadfile('common/media/lua/client/ISUI/Maps/PIE_MapDefinitions.lua'))"` passed.
  - `git diff --check` passed.
  - `find common/media/maps -maxdepth 1 -type d` shows `PIELots` and no `PIElots`.
  - `rg -n "PIElots|PIELots" common` shows only the updated `PIELots` Lua path.
- Live sync/review state:
  - Synced project to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/PIE42` with `.git` excluded.
  - Live `common/media/maps/PIELots/map.info` exists.
  - Live old `common/media/maps/PIElots` no longer exists.
  - `diff -qr --exclude=.git` between project and live PIE42 is clean.
  - No live `.git` directories exist under PIE42.
- 11:30 retest:
  - Log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_11-30_DebugLog.txt`.
  - Continue still showed the `Error loading savefile` modal. Do not click `Yes`.
  - `PIELots` was still the red map entry. `Elizabeth, IN`, `Georgetown, IN`, and `New Middletown, IN` from the same `PIE42/common/media/maps` tree were white, so PIE42 is loading but the core lots map still is not accepted as available.
  - The log shows `LOG : Mod > loading PIE42` and PIE42 texture override lines, but no useful map-specific warning.
  - Vanilla `MapGroups` bytecode appears to use the immediate map folder name as the map identity, and `map.info` `lots=` lines for dependencies. However, the current `PIELots/map.info` still has `title=maplots` while the save expects `PIELots`.
- Next action:
  - Project `PIE42/common/media/maps/PIELots/map.info` now uses `title=PIELots`, with the file normalized to CRLF.
  - CR-at-EOL-aware `git diff --check` passed with `git -c core.whitespace=cr-at-eol diff --check`.
  - `lua5.1 loadfile` still passes for `common/media/lua/client/ISUI/Maps/PIE_MapDefinitions.lua`.
  - Synced project PIE42 to the live PIE42 folder with `.git` excluded.
  - Project/live `diff -qr --exclude=.git` is clean, no live `.git` exists, live `PIELots/map.info` has `title=PIELots`, and live old `PIElots` is absent.
  - 11:43 retest still showed the `Error loading savefile` modal with `PIELots` red. Do not click `Yes`.
  - The game was stopped after the screenshot. `PIELots` folder case and `map.info` title are both now aligned, so the remaining cause is a deeper B42.19 map-discovery rule or how this PIE core lots map is declared.
  - Java `MapGroups` disassembly shows `handleMapDirectory()` only requires `map.info` to exist and reads `lots=` lines; `title=` is not checked. `getAllMapsInOrder()` returns folder names from grouped `MapDirectory.name`.
  - A read-only filesystem probe that mirrors the `MapGroups` algorithm found live `PIE42/common/media/maps/PIELots/map.info` and reported `PIELots` available, so the remaining question is the exact runtime `saveInfo.mapName` token and runtime `lotDirs`.
  - Temporary diagnostic installed in project and live: `PIE42/common/media/lua/client/PIE_MapAvailabilityDiagnostics.lua`.
  - The diagnostic wraps `MainScreen.checkMapsAvailable`, prints the exact `mapName` string, byte values for `PIELots`/`PIElots` and each token, and runtime `lotDirs:contains()` results for PIE maps.
  - This diagnostic is temporary. Remove it from project and live before committing PIE42.
  - 11:52 diagnostic retest:
    - Log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_11-52_DebugLog.txt`.
    - Exact save token is `PIElots`, bytes `80,73,69,108,111,116,115` (lowercase `l` after `PIE`).
    - Runtime `lotDirs` contains `PIELots=true`, bytes `80,73,69,76,111,116,115`, and `PIElots=false`.
    - The modal text was therefore not `PIELots`; it was `PIElots`. The previous visual read confused uppercase `L` and lowercase `l`.
  - Cleanup/fix applied after the diagnostic:
    - Removed temporary `common/media/lua/client/PIE_MapAvailabilityDiagnostics.lua` from project and live.
    - Restored the live/project map folder to exact save casing `common/media/maps/PIElots`.
    - Restored `LootMaps.PIE_MAP_DIRECTORY` to the original exact path `media/maps/PIElots`.
    - Updated `common/media/maps/PIElots/map.info` title from `maplots` to `PIElots`.
    - Project/live `diff -qr --exclude=.git` is clean; live `PIELots` is absent; live diagnostic is absent.
  - Next action: launch B42.19 and retest Continue cleanly. The savefile modal should not appear for the PIE map casing mismatch now.
  - 12:02 clean retest:
    - Log: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_12-02_DebugLog.txt`.
    - The savefile modal still appeared, but `PIElots` was no longer red. The map-casing issue is fixed.
    - Scrolling confirmed the visible map list is white. The modal has advanced to a missing/unavailable mod condition.
    - A file-based reproduction of `ChooseGameInfo.Mod:isAvailable()` found active metadata blockers:
      - `CleanUI`: `versionMax=42.12.999`.
      - `MiniHealthPanel`: `versionMax=41.99`.
      - `ReplaceBandage`: `versionMax=41.99`.
      - `VanillaFoodsExpanded`: `versionMax=42.12.3`.
      - `ProjectArcade`: `versionMax=42.14.1`.
      - `N&CsNarcotics`: malformed `require=\MoodleFramework,`.
      - `Project_Cook_Pixel_Icon_Pack`: malformed `require=\NeatUI_Framework,\Project_Cook` needs exact B42 slash-separated IDs without comma suffixes.
      - `StandardizedVehicleUpgrades3V`: malformed `require=tsarslib,StandardizedVehicleUpgrades3Core`.
      - `cjsLegendaryBagsRareLoot`: malformed `require=\LBB42,\LDB42,\LSB42,\LFB42`.
      - `InteractiveTailoring`: malformed `require=\ChuckleberryFinnAlertSystem,\errorMagnifier,`.
      - `cjsEvolvingTraitsWorld`: malformed `require=MoodleFramework,KillCount,modoptions,TchernoLib`.
  - Next action: patch active mod metadata in project repos (import live first when missing), sync live, rerun the availability resolver, and retest Continue.

## Current Blocker: TchernoLib B42 Discovery

- After the PIE42 case fix, an improved resolver based on B42.19 bytecode found the savefile modal has exactly one remaining missing/unavailable active mod: `TchernoLib`.
- B42.19 `getAllModFoldersAux()` discovers mods only when the selected version folder has `mod.info` or `common/mod.info` exists. A bare root `mod.info` is not enough.
- B42.19 `readModInfoAux()` reads the selected version `mod.info` first, then `common/mod.info`; it does not read root `mod.info` for discovered B42 mods.
- B42.19 `require=` parsing strips backslashes and splits on commas, so lines such as `require=\MoodleFramework,` are not automatically broken just because of commas. Empty trailing entries are ignored by the availability recursion in practice.
- The earlier suspected unavailable mods resolve cleanly when B42 version-folder selection is mirrored:
  - `CleanUI` uses `42.19/mod.info`.
  - `MiniHealthPanel` uses `42/mod.info`.
  - `ReplaceBandage` uses `42/mod.info`.
  - `Vanilla Foods Expanded` uses `42.18/mod.info`.
  - `ProjectArcade` uses `42.15/mod.info`.
  - `N&CsNarcotics`, `Project_Cook_Pixel_Icon_Pack`, `StandardizedVehicleUpgrades3V`, `cjsLegendaryBagsRareLoot`, `InteractiveTailoring`, and `cjsEvolvingTraitsWorld` all resolve to installed requirements after B42 parsing.
- TchernoLib project repo: `/home/cjstorrs/projects/game-mods/zomboid/TchernoLib` on branch `feat(4.19)/tchernolib-workshop-update`.
- Current TchernoLib patch direction:
  - Keep the targeted `ISWorldMenuElements` nil guards from the prior root-layout patch.
  - Convert the local root-layout files into a minimal B42 `common/` layout: `common/mod.info`, `common/TchernoLib.png`, `common/TchernoLibIcon.png`, and `common/media/...`.
  - Do not reintroduce Workshop `42.13`/`42.14`/`42.15` folders, because the prior full Workshop sync caused a Linux script path failure for `42.15/media/scripts/spawnitems.txt`.
- Validation after the project layout conversion:
  - `lua5.1 -e "assert(loadfile('common/media/lua/client/Spectate/SpectateRemoveContext.lua'))"` passed.
  - `git -c core.whitespace=cr-at-eol diff --check` passed.
- Live sync/review state:
  - First live sync to uppercase `TchernoLib` and `TchernoLib (1)` made the savefile modal disappear, but boot logged:
    - `ScriptManager.Load` `FileNotFoundException` for `/home/cjstorrs/Zomboid/mods/home/cjstorrs/zomboid/mods/tchernolib/common/media/scripts/spawnitems.txt`.
    - `TchernoLib` `WalkSpeedReverseEngineering.lua:66` `attempted index: class of non-table: null` from stale `TraitCollection.class` metatable access.
  - Cause of the script path failure: B42.19 lowercases `commonDir` before URI-relative file mapping. On Linux, an uppercase live folder path such as `TchernoLib/common` does not match its lowercased URI base, so script paths can be mangled.
  - Moved the two uppercase live folders out of active mods to `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods-disabled-b42-20260630/`.
  - Synced the project layout into the single lowercase live folder `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/tchernolib`.
  - Renamed project/live script file `common/media/scripts/SpawnItems.txt` to lowercase `common/media/scripts/spawnitems.txt`.
  - Patched `common/media/lua/shared/Movement/WalkSpeedReverseEngineering.lua` so missing `TraitCollection.class` falls back to a false trait check instead of throwing during boot.
  - Project/live `diff -qr --exclude=.git` is clean for lowercase `tchernolib`.
  - No live `.git` directories exist under lowercase `tchernolib`; uppercase duplicates are no longer direct children of `mods/`.
  - The B42.19 availability resolver now reports `bad_count 0` and resolves `TchernoLib` from `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/tchernolib/common/mod.info`, selected version `42.0`, source `common`.
  - `lua5.1 loadfile` passes for `common/media/lua/client/Spectate/SpectateRemoveContext.lua`; stock Lua cannot parse `WalkSpeedReverseEngineering.lua` because this upstream file uses Kahlua numeric suffixes such as `0.0F`.
- Next action: launch B42.19 again, Continue the active save, confirm the TchernoLib `FileNotFoundException` and `WalkSpeedReverseEngineering` stack are gone, then handle the next blocker. If the save reaches player load again, the current next blocker is `PlayerDB.loadPlayer` `BufferUnderflowException` after missing/removed saved item types from `2VCESSPONGIESEXPANSION`, `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.

## Current State

- Workspace root is not a git repo. Most mods are individual git repos.
- Latest retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_08-57_DebugLog.txt` reached menu, continued the active save without a missing-mod prompt, reached `Click to Start`, clicked into world-entry, then exited/crashed at `09:01:51`.
  - Conditional Speech loaded its B42 overlay (`mod "Conditional-Speech" overrides media/lua/client/conditionalspeech_core.lua`) and no longer logs `ConditionalSpeech`, `load_n_set_Moodles`, `check_PlayerStatus`, reflection, `Not in debug`, or `getMoodleLevel` errors.
  - Next actionable error is `Video Game Consoles`: repeated `Object tried to call nil in replaceDummies` at `Video_Game_Consoles_distributions.lua:186`, called by `onFillContainer` at line `203`.
  - Other active 08:57 errors still pending after Video Game Consoles: `Take A Bath And Shower` `SetProperty`, `TchernoLib` `ContextDebugHighlights`, `Right-click Watch To Set Alarm` `expected argument of type ItemBodyLocation, got String`, `Neon moodle levels` `update`, `CJS Furniture Storage Boost` `effectiveCapacityForCharacter`, `More Traits. ComputerPers FIX` `Blissful`, `PlayerDB.loadPlayer` buffer underflow after `Base.Hephas_StalkerPDA` / `TOC.Amputation_Hand_L` / `TOC.Prost_HookArm_L`, `ItemPickerJava.DoWeaponUpgrade` `ComboItem` -> `HandWeapon` cast, and final `KahluaTableImpl.save` recursion.
- Latest launch attempt `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_06-51_DebugLog.txt` was terminated manually after the log stopped at repeated `ImportedSkeleton.collectBoneFrames` lines.
  - This is not proven to be a startup deadlock. The previous successful 06:33 launch also stopped logging right after the same skeleton burst, then only resumed logging several minutes later when menu/Continue activity happened.
  - Treat the next attempt as a UI-driving/check-window-visibility problem first. Reacquire the `Project Zomboid` window, inspect its geometry/screenshot, and click Continue if the menu is actually present.
  - If the visible screen is only the Linux Mint desktop, check whether the PZ window is minimized/offscreen/behind another surface before assuming the game is hung.
- 07:00 run `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_06-59_DebugLog.txt` reached menu, save load, `Click to Start`, then world-entry hooks before the game thread exited.
  - The Linux Mint screensaver was active and blocked screenshots/clicks until `cinnamon-screensaver-command --deactivate` was run.
  - No missing-mod confirmation appeared.
  - The prior Safe Indoor Campfire, Ladders, and DWAP stack traces were absent in targeted search; those fixes are ready to commit after review checks.
  - New/remaining actionable errors:
    - `cjsZuperCarts` still throws `Object tried to call nil in isValidSpawnLocation` from `SpawnTrolleyContainer.lua:40` and `:51` during `IngameState.enter`; the remaining culprit is `props:Is(...)`, not just nil sprite/property chains.
    - `Dynamic Infinite Search Mode` triggers vanilla forage `player:hasTrait(...)` null-map errors at world UI creation.
    - `CleanUI` calls `hasTag(..., "KeyRing")` and hits the B42.19 string-tag Java binding removal.
    - `MoodleFramework` / `Neon moodle levels` calls nil in `MF_ISMoodle.lua:getXYPosition`.
    - `PlayerDB.loadPlayer` still reports buffer underflow after `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.
    - Save/world-entry crash still ends in very deep `KahluaTableImpl.save` recursion; investigate after clearing the explicit Lua stacks above unless it remains the only blocker.
- `DBD_NearbyAnimals` is clean on branch `feat(4.19)/nearby-animals-load-root` at commit `73a62a0` (`fix: make Nearby Animals load in B42.19`).
- `DBD_NearbyAnimals` packaging fix:
  - Keeps `id=DBD_NearbyAnimals`.
  - Moves active version folder from `42.12/` to `42/`.
  - Changes visible compatibility text to `42.19`.
  - Changes `versionMin=42.19`.
  - Changes `versionMax=42.99`.
  - Live copy already matches this packaging and the latest log showed `[DBD_NearbyAnimals] Initialized`.
- 07:09 run `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_07-09_DebugLog.txt` reached menu, save load, `Click to Start`, then world-entry hooks before the game thread exited.
  - The ZuperCarts `SpawnTrolleyContainer` / `isValidSpawnLocation` stack from 07:00 was absent after the B42.19 `PropertyContainer:has(...)` follow-up.
  - The process exited after an unhandled `java.lang.StackOverflowError` in `KahluaTableImpl.save`.
  - Next actionable errors from this run, before the final save recursion:
    - `Dynamic Infinite Search Mode` repeatedly triggers vanilla forage `player:hasTrait(...)` null-map errors in `forageSystem.lua:1837` and `forageSystem.lua:1883`, called from `ISDynamicInfiniteSearchManager.lua:212/215`.
    - `CleanUI` still hits the B42.19 string item-tag binding removal through `refreshBackpacks(ISInventoryPage.lua:1706)` when checking `Base.KeyRing` tags.
    - `MoodleFramework` / `Neon moodle levels` repeatedly calls nil `getXYPosition` at `MF_ISMoodle.lua:421`, then Neon moodle update paths also hit null moodle data.
    - `CJS Efficiency Skill Mod` throws at `EfficiencyDefaultXP.lua:61` during `GameLoadingState.exit`; the log says `Initializing player: nil` immediately after, so inspect whether this is caused by the failed player load before patching it.
    - `Milk Them All` still logs `[MTA] ERROR [AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed and has been permanently disabled: null java.lang.StackOverflowError`.
    - There are additional `replaceDummies`, `SetProperty`, `MotionSickness`, and `MTPlayerHit` nil-call stacks near the crash; identify the owning mods from the surrounding stack before patching.
  - No Project Zomboid process remained after this run.
- `InfiniteSearchMode` is in progress on branch `feat(4.19)/workshop-update` with an uncommitted B42.19 forage-trait/load-root patch.
  - Changed files:
    - `media/lua/client/Foraging/ISDynamicInfiniteSearchManager.lua`
    - `media/lua/shared/NPCs/RelentlessScavengerTrait_MainCreationMethods.lua`
    - `42.0/media/lua/client/Foraging/ISDynamicInfiniteSearchManager.lua`
    - `42.0/media/lua/shared/NPCs/RelentlessScavengerTrait_MainCreationMethods.lua`
  - Root B41 files now return early under B42 so stale root code does not override B42 files.
  - B42 custom trait checks now use `pcall(player:hasTrait(...))` and return false if the existing save lacks that trait key in the Java trait map.
  - B42 trait setup still defines `DynamicInfiniteSearchMode:relentlessscavenger` but no longer adds it to vanilla `forageSkills`, because B42.19 vanilla forage loops call `player:hasTrait(...)` for every forage trait and existing saves can throw a null-map NPE for newly registered custom traits.
  - 07:22 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_07-22_DebugLog.txt` still reproduced the Dynamic Infinite Search Mode stack at world-entry:
    - `forageSystem.getDarknessEffectReduction(forageSystem.lua:1837)` via `ISDynamicInfiniteSearchManager.lua:214`.
    - `forageSystem.getTraitVisionBonus(forageSystem.lua:1883)` via vanilla `ISSearchManager:getOverlayRadius()` and `ISDynamicInfiniteSearchManager.lua:217`.
    - Root cause: B42.19 vanilla forage code directly calls `player:hasTrait(...)` while iterating `forageSystem.skillDefs.trait`; an existing save can lack map entries for those trait definitions and throw `Cannot invoke "java.lang.Boolean.booleanValue()"`.
  - Current patch adds B42 safe forage wrappers in `42.0/media/lua/client/Foraging/ISDynamicInfiniteSearchManager.lua` for `getWeatherEffectReduction`, `getDarknessEffectReduction`, `getTraitVisionBonus`, `getCategoryBonus`, and `hasNeededTraits`. The wrappers use the local `pcall`-guarded `hasTrait(...)`.
  - Validation after the wrapper patch:
    - Lua syntax passed for all four changed files.
    - Project/live copies match for all four files.
    - Live `InfiniteSearchMode` has `42.0/mod.info` and no `.git`.
    - 07:32 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_07-32_DebugLog.txt` reached world-entry and no longer contains `ISDynamicInfiniteSearchManager`, `getDarknessEffectReduction`, `getTraitVisionBonus`, or `Cannot invoke "java.lang.Boolean.booleanValue()"` forage trait-map errors.
  - `git diff --check` reports CRLF as trailing whitespace in the two root B41 files. `git ls-files --eol` shows those root files are tracked/worktree CRLF; do not normalize the whole files as part of this patch unless intentionally accepting broad newline churn.
  - Committed fix: `9f01f22` (`fix: prevent Infinite Search forage trait errors in B42.19`).
  - Next active errors after this fix: `CleanUI` string `hasTag(..., "KeyRing")`, MoodleFramework/Neon moodle `getXYPosition`, Conditional Speech moodle load path, `PlayerDB.loadPlayer` buffer underflow, and the final `KahluaTableImpl.save` recursion.
- `CleanUI` is clean on branch `feat(4.19)/cleanui-workshop-b42-update` at commit `3c7d0c4` (`fix: update CleanUI for B42.19`).
  - Project repo: `/home/cjstorrs/projects/game-mods/zomboid/CleanUI`.
  - Live mod: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/CleanUI`.
  - Workshop source: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3437629766/mods/CleanUI`.
  - Baseline commit from the stale live copy: `3cf169a` (`chore: import CleanUI live baseline`).
  - The committed project tree has the Workshop B42.19 update applied. The old `42/` folder is deleted and the new upstream layout contains `42.12/`, `42.13/`, `42.14/`, `42.15/`, `42.16/`, `42.19/`, and `common/`.
  - The live copy has been replaced from the project copy with `.git` excluded. Project/live `diff -qr --exclude=.git` was clean, and the live copy has no `.git`.
  - The stale live copy previously only had `42/mod.info`, which is where the 07:32 `hasTag(..., "KeyRing")` failure came from.
  - `42.19/mod.info` in the Workshop copy has `id=CleanUI`, `name=CleanUI [B42.19+]`, `versionMin=42.19.0`, and `require=\NeatUI_Framework`.
  - `NeatUI_Framework` is installed at `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/NeatUI_Framework/42/mod.info` and is enabled in the active save/default/preset lists. The CleanUI dependency should not produce a missing-mod confirmation.
  - Workshop B42.19 already fixes the B42.19 item-tag API change by using `ItemType.KEY_RING` / `ItemTag.KEY_RING` instead of string `hasTag(..., "KeyRing")`.
  - Validation before retest:
    - Lua syntax passed under `42.19` and `common`.
    - `git diff --check` passed.
    - `42.19/poster.png` and `42.19/icon1.png` exist in project and live.
    - Active live `42.19`/`common` Lua has no string-style `hasTag(...)` calls.
  - 07:46 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_07-46_DebugLog.txt` reached world-entry and no longer contains the old CleanUI `No implementation found for function: hasTag(..., "KeyRing")` stack.
  - Committed fix: `3c7d0c4` (`fix: update CleanUI for B42.19`).
  - New active world-entry errors after the CleanUI fix:
    - `More Traits` / `More Traits. ComputerPers FIX` run inventory container hooks through CleanUI refresh and call B42.19 `player:hasTrait(...)` or removed APIs unsafely:
      - `Lua((MOD:More Traits)).ToadTraitScrounger(MoreTraits .lua:970)` via `ContainerEvents(MoreTraits .lua:4224)` throws `Cannot invoke "java.lang.Boolean.booleanValue()" because the return value of "java.util.Map.get(Object)" is null`.
      - `Lua((MOD:More Traits. ComputerPers FIX )).ToadTraitIncomprehensive(MoreTraits.lua:977)` via `ContainerEvents(MoreTraits.lua:3357)` throws `Object tried to call nil`.
    - `PlayerDB.loadPlayer` still throws `BufferUnderflowException` after item data-length mismatches for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.
    - Final crash still ends in repeated `se.krka.kahlua.j2se.KahluaTableImpl.save(...)` recursion / `MainThread.uncaughtException`.
  - Current target is More Traits first, because it is now the earliest concrete Lua stack after UI/world-entry.
  - Before patching More Traits, locate both live variants, check whether project repos already exist, and check the Windows Workshop cache for updates.
- `More Traits` is clean on branch `feat(4.19)/more-traits-42-17-update` at commit `012bcb8` (`fix: update More Traits trait checks for B42.19`).
  - Project repo: `/home/cjstorrs/projects/game-mods/zomboid/More Traits`.
  - Live mod: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/More Traits`.
  - Workshop source checked: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/1299328280/mods/More Traits`.
  - Active save ID: `1299328280/ToadTraits`.
  - Project/live copies matched before editing.
  - Project intentionally differs from Workshop in `42.15`/`42.17` B42.19 migration files; preserve existing local migration commits instead of replacing from Workshop.
  - Active B42.19 file from the log is `42.17/media/lua/shared/MoreTraits .lua` (`ToadTraitScrounger` line 970 in the 07:46 log).
  - Patch adds local `MT_HasTrait(player, trait)` helper and routes active 42.17 trait checks through it.
  - Revised helper no longer uses `pcall(player:hasTrait(...))`. It reads `player:getCharacterTraits():getTraits():get(trait)` directly so missing trait-map entries return false instead of throwing through `CharacterTraits.get(...)`.
  - Local validation passed for `42.17/media/lua/shared/MoreTraits .lua`: `lua5.1 loadfile` and `git diff --check`.
  - Live sync applied after dry-run showed only `42.17/media/lua/shared/MoreTraits .lua` would update.
  - Review checks passed after the revised helper: project/live active file diff clean, project and live syntax checks passed, `generic.png`/`icon.png` exist, no live `.git`, `git diff --check` passed, and the active file no longer contains direct `player:hasTrait(...)`, `player:HasTrait(...)`, or `getTraits():contains(...)` calls. File remains intentionally mixed CRLF/LF as it was before; avoid broad newline churn.
  - 08:18 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_08-18_DebugLog.txt` still did not show the original `ToadTraitScrounger` stack or the B42.19 trait-map Boolean unboxing error.
- `CP_MoreTraits` is clean on branch `feat(4.19)/workshop-update` at commit `1d9c879` (`fix: update CP More Traits checks for B42.19`).
  - Project repo: `/home/cjstorrs/projects/game-mods/zomboid/CP_MoreTraits`.
  - Live mod: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/CP_MoreTraits`.
  - Workshop source checked: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3587315482/mods/CP_MoreTraits`.
  - Active save ID: `CP_MoreTraits`; requires `\1299328280/ToadTraits`.
  - Project/live/workshop copies matched before editing.
  - Active file from the log is `42/media/lua/client/MoreTraits.lua` (`ToadTraitIncomprehensive` line 977 in the 07:46 log).
  - Patch adds the same local `MT_HasTrait(player, trait)` helper and replaces old removed B42.19 `player:HasTrait(...)` calls with the helper.
  - Revised helper resolves legacy string IDs to actual B42 trait objects before reading the trait map:
    - Vanilla aliases: `AllThumbs`, `Clumsy`, `Cowardly`, `Dextrous`, `FastHealer`, `FastReader`, `Graceful`, `SlowHealer`, `SlowReader`, `Smoker`, `Tailor`.
    - More Traits aliases: `Brooding`, `Immunocompromised`, `Lightdrinker`, `Lucky`, `SuperImmune`, `Terminator`, `Unlucky`, `Unwavering`.
    - Lowercase More Traits IDs resolve through `ToadTraitsRegistries[id]`.
    - Missing optional IDs such as old `motionsickness`/`MotionSickness` and inactive `Hoarder` return false without calling Java.
  - The helper reads `player:getCharacterTraits():getTraits():get(resolvedTrait)` directly instead of `player:hasTrait(...)` so existing saves with missing map entries do not throw a Java Boolean unboxing NPE.
  - Local validation passed for `42/media/lua/client/MoreTraits.lua`: `lua5.1 loadfile` and `git diff --check`.
  - Live sync applied after dry-run showed only `42/media/lua/client/MoreTraits.lua` would update.
  - Review checks passed after the revised helper: project/live active file diff clean, project and live syntax checks passed, `generic.png`/`icon.png` exist, no live `.git`, `git diff --check` passed, and the active file no longer contains direct `player:hasTrait(...)`, `player:HasTrait(...)`, or `getTraits():contains(...)` calls.
  - 07:58 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_07-58_DebugLog.txt` reached menu, continued the save without a missing-mod prompt, reached `Click to Start`, clicked into world-entry, then exited/crashed again.
  - Base `More Traits` 42.17 no longer showed the original `ToadTraitScrounger(MoreTraits .lua:970)` stack in the targeted 07:58 grep; confirm again before committing.
  - `CP_MoreTraits` still fails and is the current active target. Its helper calls `player:hasTrait(<string>)` inside `pcall`, but B42.19 still logs Java binding errors:
    - `No implementation found for function: hasTrait(..., class java.lang.String incomprehensive)` at `MT_HasTrait(MoreTraits.lua:109)`.
    - Same pattern for `scrounger`, `vagabond`, `gourmand`, and `antique`.
    - The fallback `player:getTraits():contains(<string>)` inside `pcall` also logs errors at `MT_HasTrait(MoreTraits.lua:116/117)`.
  - Next fix should avoid the bad Java calls entirely. Resolve legacy string trait IDs to actual B42 `CharacterTrait`/`ToadTraitsRegistries` objects before calling `player:hasTrait(...)`, or return false when no object can be resolved. Do not call `hasTrait` or `getTraits():contains` with raw strings in B42.19.
  - 08:09 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_08-09_DebugLog.txt` reached menu, continued the save without a missing-mod prompt, reached `Click to Start`, clicked into world-entry, then exited/crashed again.
  - The 08:09 retest no longer showed the 07:58 CP raw-string `hasTrait(...)` / Boolean-unboxing stacks, and the base `More Traits` scrounger stack still did not reappear.
  - New CP error from 08:09: `Lua((MOD:More Traits. ComputerPers FIX )).MotionSickness(MoreTraits.lua:3945)` throws `Object tried to call nil` because B42.19 removed `BodyDamage:getFakeInfectionLevel()` / `setFakeInfectionLevel()`. The function read that removed API before its trait guard could return.
  - Current uncommitted follow-up patch:
    - Adds `MotionSickness = "motionsickness"` to `MT_TRAIT_ALIASES`.
    - Adds `MT_GetSickness(player)` / `MT_SetSickness(player, sickness)` helpers using `player:getStats():get(CharacterStat.SICKNESS)` and `stats:set(CharacterStat.SICKNESS, CharacterStat.SICKNESS:clamp(sickness / 100.0))`.
    - Moves `MotionSickness` and `MotionSicknessHealthLoss` trait guards before sickness reads.
    - Replaces removed fake-infection level calls in those functions with the new B42.19 sickness helpers.
  - Validation after the motion-sickness patch: project syntax passed, live syntax passed, `git diff --check` passed, and project/live active file diff is clean.
  - 08:18 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_08-18_DebugLog.txt` confirmed the 08:09 CP `MotionSickness` stack is gone. A targeted scan found no `MotionSickness`, raw-string `hasTrait`, trait-map Boolean-unboxing, `ToadTraitScrounger`, `ToadTraitIncomprehensive`, or `MT_HasTrait` errors.
  - Commit `1d9c879` includes both the B42.19 trait object resolution helper and the `CharacterStat.SICKNESS` motion-sickness follow-up.
  - Active 08:18 world-entry errors to handle next:
    - `More Description for Traits [42.0]`: `Object tried to call nil in loadProfession` at `MDFT_TweakTraitTooltip.lua:47`, called while creating the character info UI.
    - `MoodleFramework` / `Neon moodle levels`: repeated `Object tried to call nil in getXYPosition` at `MF_ISMoodle.lua:421`.
    - `Conditional Speech`: `Object tried to call nil in load_n_set_Moodles` at `ConditionalSpeech_Core.lua:93`, plus `check_PlayerStatus(ConditionalSpeech_Core.lua:387)` near world update.
    - `N&C's Narcotics`: `attempted index: setValue of non-table: null` at `NnC_Moodles.lua:55`, likely because its moodle object was not created/found.
    - Additional 08:18 stacks need ownership inspection before patching: `replaceDummies`, `SetProperty`, `effectiveCapacityForCharacter`, and `Blissful`.
    - `PlayerDB.loadPlayer` still reports buffer underflow after item data-length mismatches for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.
    - Final crash still ends in deep `KahluaTableImpl.save(...)` recursion / `MainThread.uncaughtException`.
- `MoreDescriptionForTraits4166` is clean on branch `feat(4.19)/workshop-update` at commit `011403f` (`fix: update More Description profession lookup for B42.19`).
  - Project repo: `/home/cjstorrs/projects/game-mods/zomboid/MoreDescriptionForTraits4166`.
  - Live mod: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/MoreDescriptionForTraits4166`.
  - Workshop source checked: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2685168362/mods/MoreDescriptionForTraits4166`.
  - Active error from 08:18: `Object tried to call nil in loadProfession` at `42.0/media/lua/client/MDFT_TweakTraitTooltip.lua:47`.
  - Root cause: B42.19 `SurvivorDesc` no longer exposes `getProfession()`. Vanilla `ISCharacterScreen.loadProfession` now calls `getCharacterProfession()` and passes that object to `CharacterProfessionDefinition.getCharacterProfessionDefinition(...)`.
  - Committed project/live patch:
    - `42.0/media/lua/client/MDFT_TweakTraitTooltip.lua` now reads `self.char:getDescriptor():getCharacterProfession()` and passes the object into `MDFT.getProfessionDefinition(...)`.
    - `42.0/media/lua/client/MDFT_CharacterCreationProfession.lua` now accepts an existing `CharacterProfession` object directly, while retaining the old string path for callers that still pass IDs.
  - Validation before retest: project syntax passed for both changed files, live syntax passed for both changed files, `git diff --check` passed, project/live changed-file diffs are clean, and the live mod has no `.git`.
  - 08:27 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_08-27_DebugLog.txt` reached menu, continued the active save without a missing-mod prompt, reached `game loading took 31 seconds`, accepted the black-screen world-entry click, then exited/crashed.
  - Targeted scan confirmed the 08:18 `MDFT_TweakTraitTooltip.lua:47` / `loadProfession` stack is gone. Only earlier load-order warnings remain:
    - `MDFT_CharacterCreationProfession.lua> require("CharacterCreationProfession") failed`
    - `MDFT_TweakTraitTooltip.lua> require("ISCharacterScreen") failed`
  - Active 08:27 world-entry errors to handle next:
    - `MoodleFramework` / `Neon moodle levels`: repeated `Object tried to call nil in getXYPosition` at `MF_ISMoodle.lua:421`, via `MF_ISMoodle.lua:509`, `neonMoodleLevels.lua:399`, and `MF_ISMoodle.lua:25`.
    - `Conditional Speech`: `Object tried to call nil in load_n_set_Moodles` at `ConditionalSpeech_Core.lua:93`, plus `Cannot invoke "zombie.characters.Moodles.Moodle.getLevel()" because the return value of "java.util.Map.get(Object)" is null` in `check_PlayerStatus`.
    - `Video Game Consoles`: repeated `Object tried to call nil in replaceDummies`.
    - `Take A Bath And Shower`: `Object tried to call nil in SetProperty`.
    - `Right-click Watch To Set Alarm`: `getAlarmItem` throws; inspect stack before patching.
    - `CJS Furniture Storage Boost`: `Object tried to call nil in effectiveCapacityForCharacter`.
    - `More Traits. ComputerPers FIX`: `Object tried to call nil in Blissful`.
    - `N&C's Narcotics`: moodle update errors, likely downstream of missing/failed moodle objects.
    - `PlayerDB.loadPlayer` still reports buffer underflow after item data-length mismatches for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.
    - Final crash still ends in deep `KahluaTableImpl.save(...)` recursion / `MainThread.uncaughtException`.
  - Next target: inspect `MoodleFramework` and `Neon moodle levels` project/live/workshop copies. Fix the B42.19 moodle positioning API first, because it is the earliest repeated concrete world-entry stack and likely causes Neon/Narcotics/Conditional Speech follow-on failures.
- `MoodleFramework` is clean on branch `feat(4.19)/moodle-framework-workshop-update` at commit `eca4433` (`fix: update MoodleFramework for B42.19 moodle APIs`).
  - Project repo: `/home/cjstorrs/projects/game-mods/zomboid/MoodleFramework`.
  - Active live mod folder: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/MoodleFramework (1)`.
  - Stale/obsolete live folder also exists: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/MoodleFramework`. Its `42.0/mod.info` says `id=MoodleFrameworkOBSOLETE`; do not patch that folder unless logs prove it is active.
  - Workshop source checked: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3396446795/mods/MoodleFramework`.
  - Baseline import commit: `7bd5318` (`chore: import MoodleFramework live baseline`).
  - Root cause of 08:27 `getXYPosition` stack: active live folder only had Workshop's stale `42.0` file. At `42.0/media/lua/client/MF_ISMoodle.lua:421`, it calls removed B42.19 API `self.char:getMoodles():getNumMoodles()`.
  - Workshop `3396446795` already includes a `42.13/media/lua/client/MF_ISMoodle.lua` overlay that removes `getNumMoodles()` and iterates `Registries.MOODLE_TYPE:values()` instead. The active live folder was missing this `42.13` overlay and most `common/` files.
  - Committed project/live sync adds:
    - `42.13/media/lua/client/MF_ISMoodle.lua`
    - `common/mod.info`
    - `common/MoodleFramework.png`
    - `common/MoodleFrameworkIcon.png`
    - `common/media/lua/client/MF_Config.lua`
    - `common/media/lua/client/MF_ISMoodle.lua`
    - `common/media/lua/shared/Translate/EN/UI.json`
    - `common/media/lua/shared/Translate/EN/UI_EN.txt`
    - `42.0/media/lua/shared/Translate/EN/UI.json`
  - Validation before retest: project syntax passed for `42.13` and `common` Lua files, live syntax passed for the same active files, `git diff --check` passed, project/live changed-file diffs are clean, and active live folder has no `.git`.
  - 08:36 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_08-36_DebugLog.txt` reached menu, continued the active save without a missing-mod prompt, reached `game loading took 31 seconds`, accepted the black-screen world-entry click, then exited/crashed.
  - Log confirms updated layout loaded: `mod "MoodleFramework" overrides media/lua/client/mf_ismoodle.lua`.
  - Targeted scan confirmed the 08:27 `MoodleFramework.getXYPosition` / `Neon moodle levels` stack is gone.
  - Active 08:36 world-entry errors to handle next:
    - `Conditional Speech`: `Object tried to call nil in load_n_set_Moodles` at `ConditionalSpeech_Core.lua:93`, plus a later `check_PlayerStatus` moodle null-map `getLevel()` error.
    - `Video Game Consoles`: repeated `Object tried to call nil in replaceDummies` at `Video_Game_Consoles_distributions.lua:186`, called by `onFillContainer` at line `203`.
    - `IsoChunk.doLoadGridsquare`: `ClassCastException: zombie.inventory.types.ComboItem cannot be cast to zombie.inventory.types.HandWeapon` in `ItemPickerJava.DoWeaponUpgrade`. Need identify the item/distribution owner from nearby log/data if it persists.
    - `Take A Bath And Shower`: `Object tried to call nil in SetProperty` at `TABAS_OnGameStart.lua:4`.
    - `Right-click Watch To Set Alarm`: `getAlarmItem` throws; inspect stack before patching.
    - `CJS Furniture Storage Boost`: `Object tried to call nil in effectiveCapacityForCharacter`.
    - `More Traits. ComputerPers FIX`: `Object tried to call nil in Blissful`.
    - `PlayerDB.loadPlayer` still reports buffer underflow after item data-length mismatches for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.
    - Final crash still ends in deep `KahluaTableImpl.save(...)` recursion / `MainThread.uncaughtException`.
  - Next target: inspect `Conditional Speech` project/live/workshop state. The earlier MoodleFramework loop is gone, so treat Conditional Speech as the first active concrete error.
- `Conditional Speech` is clean on branch `feat(4.19)/conditional-speech-workshop-update` at commit `8d3d8e3` (`fix: update Conditional Speech for B42.19`).
  - No project repo existed at the start of this pass.
  - Live mod: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/zomboid-cnd-speech`.
  - Workshop source checked: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2398253681/mods/zomboid-cnd-speech`.
  - Active 08:36 error: `Lua((MOD:Conditional Speech)).load_n_set_Moodles(ConditionalSpeech_Core.lua:93)` throws `Object tried to call nil`; live `42.0/media/lua/client/ConditionalSpeech_Core.lua` calls removed B42 moodle API `player:getMoodles():getNumMoodles()`.
  - Later 08:36 error: `check_PlayerStatus(ConditionalSpeech_Core.lua:375)` throws a B42.19 moodle null-map `getLevel()` NPE.
  - Workshop already has a B42 update under `42.13/media/lua/client/ConditionalSpeech_Core.lua` and `common/`; its moodle load path iterates `MoodleType` objects instead of `getNumMoodles()`.
  - Imported the live mod into `/home/cjstorrs/projects/game-mods/zomboid/zomboid-cnd-speech`, initialized git, and committed untouched live baseline `bcccec1` (`chore: import Conditional Speech live baseline`).
  - Active branch: `feat(4.19)/conditional-speech-workshop-update`.
  - Applied the Workshop `42.13` and `common` update, but restored pre-existing legacy `.txt` translation/changelog files to avoid broad line-ending churn; newly added B42/common text files are LF-normalized and binary assets are untouched.
  - First local guard attempted to read the private player `Moodles.moodles` Java map via `getNumClassFields`/`getClassField`/`getClassFieldVal`.
  - 08:52 retest reached menu, continued the save without a missing-mod prompt, reached `Click to Start`, clicked world-entry, then exited/crashed.
  - The 08:52 retest proved the reflection approach is invalid in normal game mode: `getNumClassFields` throws `IllegalStateException: Not in debug`, followed by `__sub not defined` in `findJavaField`.
  - Replacement local B42.19 guard in `42.13/media/lua/client/ConditionalSpeech_Core.lua`: removed reflection entirely; tracks only Conditional Speech's vanilla filtered moodles via B42 uppercase `MoodleType` constants (`ENDURANCE`, `TIRED`, `PANIC`, `BORED`, `BLEEDING`, `ANGRY`, `PAIN`, `DRUNK`, `HYPERTHERMIA`, `HAS_A_COLD`). This avoids iterating modded/late-registered moodles that are not present in the player's moodle map.
  - Synced project `42.13/` and `common/` into live `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/zomboid-cnd-speech`.
  - Validation before retest: project syntax passed for `42.13` and `common/media/lua` files; live syntax passed for the same paths; `git diff --cached --check` passed; project/live `42.13` and `common` diffs are clean; live mod has no `.git`; dependency IDs `ChuckleberryFinnAlertSystem` and `errorMagnifier` are installed and enabled in the active save/default/preset lists.
  - Validation after replacement fix: project syntax passed for `42.13/media/lua/client/ConditionalSpeech_Core.lua`; live syntax passed for the same file; `git diff --cached --check` passed; project/live active file diff is clean; live mod has no `.git`.
  - 08:57 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_08-57_DebugLog.txt` reached menu, continued the active save without a missing-mod prompt, reached `Click to Start`, clicked world-entry, then exited/crashed.
  - Targeted scan confirmed the prior Conditional Speech `load_n_set_Moodles`, `check_PlayerStatus`, reflection, `Not in debug`, and `getMoodleLevel` stacks are gone.
  - Review checks passed before commit: project syntax passed for `42.13` and `common/media/lua`; live syntax passed for the same paths; `git diff --cached --check` passed; project/live `42.13` and `common` diffs were clean; live mod has no `.git`.
  - Active 08:57 world-entry errors to handle next:
    - `Video Game Consoles`: repeated `Object tried to call nil in replaceDummies` at `Video_Game_Consoles_distributions.lua:186`, called by `onFillContainer` at line `203`. Treat this as the next target.
    - `IsoChunk.doLoadGridsquare`: `ClassCastException: zombie.inventory.types.ComboItem cannot be cast to zombie.inventory.types.HandWeapon` in `ItemPickerJava.DoWeaponUpgrade`.
    - `Take A Bath And Shower`: `Object tried to call nil in SetProperty` at `TABAS_OnGameStart.lua:4`.
    - `TchernoLib`: `ContextDebugHighlights(SpectateRemoveContext.lua:99)`.
    - `Right-click Watch To Set Alarm`: `getAlarmItem(RightClickWatchToSetAlarm.lua:7)` throws `expected argument of type ItemBodyLocation, got String`.
    - `Neon moodle levels`: `update(neonMoodleLevels.lua:120)` via `onPreUIDraw` and `onPostUIDraw`.
    - `CJS Furniture Storage Boost`: `Object tried to call nil in effectiveCapacityForCharacter` at `CJS_FurnitureStorageBoost.lua:620`.
    - `More Traits. ComputerPers FIX`: `Object tried to call nil in Blissful` at `MoreTraits.lua:1411`.
    - `PlayerDB.loadPlayer` still reports buffer underflow after item data-length mismatches for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.
    - Final crash still ends in deep `KahluaTableImpl.save(...)` recursion / `MainThread.uncaughtException`.
- `Video Game Consoles` is clean on branch `feat(4.19)/video-game-consoles-dummy-replacement` at commit `9968b90` (`fix: update Video Game Consoles dummy replacement for B42.19`).
  - Project repo: `/home/cjstorrs/projects/game-mods/zomboid/Video Game Consoles`.
  - Live mod: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Video Game Consoles`.
  - Workshop source checked: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/2831786301/mods/Video Game Consoles`.
  - Active save/default/preset ID: `Video_Game_Consoles`.
  - Imported live mod and committed untouched baseline `18b4b1d` (`chore: import Video Game Consoles live baseline`).
  - Active branch: `feat(4.19)/video-game-consoles-dummy-replacement`.
  - Active 08:57 error: repeated `Object tried to call nil in replaceDummies` at `42/media/lua/server/items/Video_Game_Consoles_distributions.lua:186`, called by `onFillContainer` at line `203`.
  - Root cause: live B42 file calls removed/nil `ItemContainer:addItemOnServer(item)` after `container:AddItem(...)`; Workshop's newer B42.13-compatible file removed this call and guards nil dummy result lists.
  - Current project/live patch in `42/media/lua/server/items/Video_Game_Consoles_distributions.lua` preserves the live mod's local spawn multiplier behavior while applying the focused Workshop-compatible replacement-path changes:
    - guards `container:getAllType(dummyType)` before iterating;
    - removes `container:addItemOnServer(item)`;
    - skips the `OnFillContainer` hook on clients with `if isClient() then return end`.
  - Validation before retest: project syntax passed for the changed file; live syntax passed; `git diff --check` passed; project/live changed-file diff is clean; live mod has no `.git`; active `42/mod.info` still has `id=Video_Game_Consoles`.
  - 09:07 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_09-07_DebugLog.txt` reached menu, continued the active save without a missing-mod prompt, reached `Click to Start`, clicked world-entry, then exited/crashed.
  - Targeted scan confirmed the prior `replaceDummies` / `addItemOnServer` stack is gone.
  - Review checks passed before commit: project syntax passed for the changed file; live syntax passed; `git diff --check` passed; project/live changed-file diff is clean; live mod has no `.git`; latest log has no `replaceDummies` or `addItemOnServer`.
  - Active 09:07 world-entry errors to handle next:
    - `Take A Bath And Shower`: `Object tried to call nil in SetProperty` at `TABAS_OnGameStart.lua:4`, called by `TABAS_OnGameStart.lua:75`. Treat this as the next target.
    - `TchernoLib`: `ContextDebugHighlights(SpectateRemoveContext.lua:99)`.
    - `Right-click Watch To Set Alarm`: `getAlarmItem(RightClickWatchToSetAlarm.lua:7)` throws `expected argument of type ItemBodyLocation, got String`.
    - `CJS Furniture Storage Boost`: `Object tried to call nil in effectiveCapacityForCharacter` at `CJS_FurnitureStorageBoost.lua:620`.
    - `More Traits. ComputerPers FIX`: `Object tried to call nil in Blissful` at `MoreTraits.lua:1411`.
    - `Milk Them All`: `[MTA] ERROR [AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed and has been permanently disabled: null java.lang.StackOverflowError`.
    - `PlayerDB.loadPlayer` still reports buffer underflow after item data-length mismatches for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`.
    - Final crash still ends in deep `KahluaTableImpl.save(...)` recursion / `MainThread.uncaughtException`.
- `Take A Bath And Shower` is clean on branch `feat(4.19)/body-location-compat` at commit `acc6028` (`fix: update Take A Bath tile properties for B42.19`).
  - Project repo: `/home/cjstorrs/projects/game-mods/zomboid/Take A Bath And Shower`.
  - Live mod: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/Take A Bath And Shower`.
  - Active save/default/preset ID: `TakeABathAndShower42`.
  - Workshop source checked: `/media/cjstorrs/windows/Program Files (x86)/Steam/steamapps/workshop/content/108600/3592172476/mods/Take A Bath And Shower`; old save-compatible `42.13` uses the same ID and has the relevant B42 property API rename. The incompatible replacement is `Take A Bath And Shower New` with `id=TakeABathAndShowerNew`; do not switch this save to that ID without explicit user approval.
  - Active 09:07 error: `Lua((MOD:Take A Bath And Shower)).SetProperty(TABAS_OnGameStart.lua:4)`, called by `TABAS_OnGameStart.lua:75`, throws `Object tried to call nil`.
  - Root cause: `common/media/lua/shared/TABAS_OnGameStart.lua` used removed B42.19 `PropertyContainer` methods `Is`, `Val`, `Set`, and `UnSet`.
  - Committed project/live patch:
    - `props:Is(property)` -> `props:has(property)`;
    - `props:Val(property)` / `props:Val("Facing")` -> `props:get(...)`;
    - `props:Set(...)` -> `props:set(...)`;
    - `props:UnSet(property)` -> `props:unset(property)`.
  - Validation before retest: project syntax passed for the changed file; live syntax passed; project/live changed-file diff is clean; live mod has no `.git`; file remains CRLF (`git ls-files --eol` reports `i/crlf w/crlf`). Plain `git diff --check` reports CRLF carriage returns on touched lines as trailing whitespace, matching this repo's tracked Windows line endings; do not normalize the file to LF just to appease that check.
  - 09:17 retest `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_09-17_DebugLog.txt` reached menu, continued the active save without a missing-mod prompt, reached `Click to Start`, clicked world-entry, then exited/crashed with the known `KahluaTableImpl.save` recursion.
  - Targeted scan confirmed the prior `TABAS_OnGameStart.lua:4` / `SetProperty` stack is gone. Only Take A Bath `require("MF_ISMoodle") failed` warnings remain in this log.
  - Review checks before commit: CRLF-aware `git diff --check` passed, project/live changed-file diff is clean, project and live Lua syntax checks passed, live mod has no `.git`, and latest log has no `TABAS_OnGameStart` or `SetProperty` error.
  - Active 09:17 world-entry errors to handle next:
    - `IsoChunk.doLoadGridsquare`: repeated `ClassCastException: zombie.inventory.types.ComboItem cannot be cast to zombie.inventory.types.HandWeapon` in `ItemPickerJava.DoWeaponUpgrade`. Treat this as the next target; it is likely an item/distribution assigning weapon-upgrade data to a non-`HandWeapon` item.
    - `TchernoLib`: `ContextDebugHighlights(SpectateRemoveContext.lua:99)`.
    - `Right-click Watch To Set Alarm`: `getAlarmItem(RightClickWatchToSetAlarm.lua:7)` throws `expected argument of type ItemBodyLocation, got String`; also triggered through `Two Weapons on Back cjs` hotbar attach.
    - `Neon moodle levels`: `update(neonMoodleLevels.lua:120)` via both `onPreUIDraw` and `onPostUIDraw`.
    - `CJS Furniture Storage Boost`: `Object tried to call nil in effectiveCapacityForCharacter` at `CJS_FurnitureStorageBoost.lua:620`.
    - `More Traits. ComputerPers FIX`: `Object tried to call nil in Blissful` at `MoreTraits.lua:1411`.
    - `PlayerDB.loadPlayer` still reports `BufferUnderflowException` after `GameWindow.StringUTF.load> numBytes:25972 is higher than the remaining bytes in the buffer:8119`.
    - Final crash still ends in deep `KahluaTableImpl.save(...)` recursion / `MainThread.uncaughtException`.
- `cjsZuperCarts` is clean on branch `feat(4.19)/zupercarts-spawn-square-guards` at commit `e0367a4` (`fix: update ZuperCarts property checks for B42.19`).
- `cjsZuperCarts` live-synced fix:
  - `42/media/lua/server/Items/SpawnCartContainer.lua`
  - `42/media/lua/server/Items/SpawnTrolleyContainer.lua`
  - It guards `obj:getSprite()` / `sprite:getProperties()` before checking `FloorOverlay`, `WallOverlay`, and `SolidFloor`.
  - It replaces adjacent-square `isFreeOrMidair(false)` with the more conservative `isFree(false)`.
  - Lua syntax passed for both files.
  - Files are CRLF-only after normalization; avoid introducing mixed line endings.
  - Project and live copies match after install.
  - Follow-up commit `e0367a4` replaces remaining `PropertyContainer:Is(...)` calls in both cart and trolley spawners with a guarded helper using B42.19 `PropertyContainer:has(...)`.
  - Lua syntax passed for both files; CRLF line endings preserved; project and live copies match after install.
  - 07:09 world-entry retest no longer showed `SpawnTrolleyContainer`, `SpawnCartContainer`, or `isValidSpawnLocation` errors.
- `Safe Indoor Campfire` was imported into a project repo with baseline commit `ce94b80`, then patched on branch `feat(4.19)/safe-indoor-campfire-tiledefs`.
  - Committed fix: `64b6298` (`fix: update Safe Indoor Campfire tile properties for B42.19`).
  - Fix copied the current Workshop B42 update for:
    - `42/media/lua/shared/zCampfire_Set_solidtrans.lua`: `props:Set(...)` -> `props:set(...)`.
    - `42/media/lua/server/Safe Indoor Campfire.lua`: adds upstream `if isClient() then return end`.
    - `media/lua/server/Safe Indoor Campfire.lua`: adds upstream `if isClient() then return end`.
  - Lua syntax passed. Live files match project. 07:00 in-game retest no longer showed the `Campfire_Set` stack.
- `Ladders` was imported into a project repo with baseline commit `452724e`, then patched on branch `feat(4.19)/ladders-tile-property-api`.
  - Committed fix: `8edbc0d` (`fix: update Ladders tile property API for B42.19`).
  - Fix updates tile property calls in both `42/media/lua/client/Ladders/Ladders.lua` and `media/lua/client/Ladders/Ladders.lua` from old `Set`/`UnSet` to B42.19 `set`/`unset`.
  - Verified with local B42.19 `javap`: `zombie.core.properties.PropertyContainer` exposes `set(...)` and `unset(...)`, not uppercase `Set`/`UnSet`.
  - Lua syntax passed. Live files match project. 07:00 in-game retest no longer showed the `setLadderClimbingFlags` stack.
- `DWAP` was imported into a project repo with baseline commit `d463f52`, then synced from Workshop ID `3440887907` on branch `feat(4.19)/dwap-workshop-b42-update`.
  - Committed fix: `129f1c6` (`fix: update DWAP for B42.19 APIs`).
  - Update replaces stale live B42 files with the current Workshop layout.
  - Important fixes: `WGParams.instance` -> `WorldGenParams.INSTANCE` in `42/media/lua/shared/DWAPUtils.lua`; old client `DWAP/LootSpawning` files removed; new server `DWAP/LootSpawning` files added; item tag checks use `ItemTag.MAGAZINE`, `ItemTag.IS_SEED`, and `ItemTag.IS_CUTTING`.
  - Lua syntax passed for changed/new files. Live copy matches project and contains no `.git`. 07:00 in-game retest no longer showed the `DWAPUtils` null-instance or `hasTag(..., "isSeed")` stacks.

## Known Log Findings

Latest useful run: `/media/cjstorrs/windows/Users/cjsto/Zomboid/Logs/2026-06-30_06-33_DebugLog.txt`, after continuing the active save at about 06:37 local.

- `DBD_NearbyAnimals` missing-mod prompt was fixed enough for the save to enter world startup. Evidence: latest logs include `[DBD_NearbyAnimals] Initialized`.
- Fixed repeated startup/runtime error:
  - `Lua((MOD:cjsZuperCarts)).isValidSpawnLocation(SpawnTrolleyContainer.lua:38)`
  - `Lua((MOD:cjsZuperCarts)).onLoadGridsquare(SpawnTrolleyContainer.lua:203)`
  - `java.lang.RuntimeException: Object tried to call nil in isValidSpawnLocation`
  - Initially reduced by `cjsZuperCarts` commit `3c25430`; fully cleared in the 07:09 retest by follow-up commit `e0367a4`.
- New concrete errors from the 06:37 save-load run:
  - `Safe Indoor Campfire`: `Object tried to call nil in Campfire_Set` at `zCampfire_Set_solidtrans.lua:4`, called by `zCampfire_Set_solidtrans.lua:13`. Pending fix synced; retest next.
  - `Ladders!? (v0.0.13)`: `Object tried to call nil in setLadderClimbingFlags` at `Ladders.lua:257`. Pending fix synced; retest next.
  - `Uncle Dave Was a Prepper`: repeated `attempted index: instance of non-table: null` in `DWAPUtils.lua:203`, `DWAPUtils.lua:131`, `DWAPUtils.lua:147`, `DWAPUtils.lua:302`, plus callers `Props.lua:410`, `SolarSupport.lua:146/216`, `Water.lua:45`. Pending Workshop update synced; retest next.
  - `Uncle Dave Was a Prepper`: `No implementation found for function: hasTag(..., "isSeed")` at `ItemLists.lua:626`, called by `populateItems(ItemLists.lua:686)` and `Events.lua:465`. Pending Workshop update synced; retest next.
  - `PlayerDB.loadPlayer`: `java.nio.BufferUnderflowException` after `InventoryItem.loadItem() data length not matching` for `Base.Hephas_StalkerPDA`, `TOC.Amputation_Hand_L`, and `TOC.Prost_HookArm_L`. It reached the black `Click to Start` screen despite this. Investigate after clearing explicit mod Lua stacks unless this blocks actually entering the character.
- Runtime warning/error to investigate after ZuperCarts:
  - `[MTA] ERROR [AUTO-DISABLE] MTA_ISMilkAnimal initialise() failed and has been permanently disabled: null java.lang.StackOverflowError`
  - Mod folder in live install: `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/MilkThemAll`
  - Need check project copy/import status and Workshop cache before patching.
- Other lower-priority logged issues to revisit after hard errors:
  - `unknown command:TWF_GC.ApplyOptions` from `twistonfire - orderly chaos`.
  - `ItemPickInfo -> cannot get ID for container: ATA2InteractiveTrunkRoofRack`.
  - `ItemPickInfo -> cannot get ID for container: TrailerAnimalFood`.
  - `Error: Too many physics objects on gridsquare: 5176, 15489, 0`.
- Exit/save crash at the end of the latest run:
  - Very large repeated stack in `se.krka.kahlua.j2se.KahluaTableImpl.save`.
  - Treat this as likely save/modData recursion or cyclic table serialization. Investigate after clearing earlier concrete Lua/runtime errors unless it remains the only blocker.
- Prior animation-channel pass cleared mod-caused non-skeleton animation channel errors. Remaining `ImportedSkeleton.collectBoneFrames` noise was not mapped to a loaded mod at that time.

## Fix Patterns Learned

- B42.19 may not load a mod if the only version folder is old or `mod.info` caps `versionMax` below 42.19. For save-facing IDs, keep the same `id=` and make the active folder/version metadata eligible instead of changing IDs.
- When a save says a mod is missing, compare the save-required ID in `mods.txt` with installed live `42/mod.info` IDs. Do not rely on display names.
- B42.19 `IsoGameCharacter:hasTrait(...)` can throw `Cannot invoke "java.lang.Boolean.booleanValue()"` when an existing save lacks a key in the Java trait map. `pcall` may keep Lua running but Java/Kahlua still logs the exception, so it is not a clean final fix for noisy world-entry paths.
- B42.19 removed old uppercase `player:HasTrait(...)` calls and no longer exposes `player:hasTrait(player, string)` overload behavior for raw strings. Replace old string-based checks by resolving to real `CharacterTrait`/mod registry objects first; never call `hasTrait` or `getTraits():contains` with a raw legacy string in B42.19.
- For B42 grid-square/object compatibility, avoid unguarded chains like `obj:getSprite():getProperties():Is(...)`. Guard each step before calling methods.
- B42.19 `PropertyContainer` uses lowercase methods (`has`, `get`, `set`, `unset`). Old `Is`, `Val`, `Set`, and `UnSet` calls throw `Object tried to call nil` in tile/object setup code.
- Be cautious with Java/Kahlua userdata method probing. Direct method calls can log binding errors if the method is gone. Prefer known working calls from local mods and conservative fallbacks.
- For Windows-origin mods, preserve line endings. Use `git ls-files --eol` and `file` to check. Mixed CRLF/LF is a review issue.
- For project-backed mods, link project to live with `link-project-mod.sh <modFolder>` and verify the live entry is a symlink whose name matches the project folder casing.

## Launch Notes

Launch command:

```bash
cd "/home/cjstorrs/games/Project Zomboid Linux 42.19.0"
JAVA_TOOL_OPTIONS="-Ddeployment.user.cachedir=/home/cjstorrs/projects/game-mods/zomboid/.runtime/zomboid-cache-parent" ./start.sh
```

Expected UI path:

1. Wait through mod-loading to the menu.
2. If the B42 notice appears, click OK.
3. Click Continue for the latest save.
4. If a missing-mod confirmation list appears, do not accept it. Read it and fix the missing mod.
5. If no missing-mod list appears, continue into the world and watch `console.txt`.

Input lessons:

- Screenshot coordinates may be scaled versus the real 2560x1440 game window.
- Reacquire the active Project Zomboid window before each click.
- Prefer pyautogui or long mouse down/up over short `xdotool click`.
- Enter can activate highlighted controls in some dialogs, but it was unreliable on the Continue/missing-mod path.
