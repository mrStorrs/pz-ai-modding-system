# Disabled Mods Ledger

Purpose: track every mod disabled during B42.19 isolation so temporary suspects are restored unless confirmed bad by logs.

## Procedure

- Current baseline test path: use `Continue` on the latest save unless code/loadout changes require another path or the user asks for a new save.
- When adding a disabled mod back, add the exact `id=` only to the latest save `mods.txt` and `mods/default.txt` before testing.
- Ignore saved presets such as `Lua/pz_modlist_settings.cfg` unless the user explicitly asks for preset edits.
- Use small suspect batches when evidence is strong.
- For broad suspects, binary search: disable half, test, then re-enable or keep narrowing based on whether the crash follows that half.
- Status meanings:
  - `temporary`: disabled only to isolate a crash; restore when ruled out.
  - `confirmed bad`: reproduced or directly matched to a log error; keep disabled until fixed.
  - `parked`: previously disabled due to known errors and intentionally left out while isolating another blocker.

## Current Disabled Mods

| Mod ID | Status | Reason | Restore Rule |
| --- | --- | --- | --- |
| `GanydeBielovzki's Frockin Splendor! Vol.4` | parked | Leave disabled per user. Latest Frockin versions may already support B42.19, but this mod is not part of the current baseline. | Restore only if the user asks. Apply the direct-Workshop rule before considering any project work. |

## Restored/Ruled Out

| Mod ID | Status | Notes |
| --- | --- | --- |
| `[J&G] Neon Vandals Uniform` | restored / ruled out | User re-added and confirmed it works. Keep enabled in the Continue-save baseline with the exact leading `[` in the ID. |
| `TombWardrobeALTVanilla` | restored / ruled out | User re-added and confirmed it works. Keep enabled in the Continue-save baseline. |
| `TheOnlyCureCjs` | restored / watch | Earlier TOC serializer work exists; current baseline has the mod enabled. Fix fresh logs only if it emits new concrete errors. |
| `Ivmakk_MilkThemAll` | restored / watch | Earlier MTA stack was not a startup blocker in the user-isolated baseline. Fix fresh logs only if it still emits concrete errors. |
| `neonMoodleLevels` | restored / watch | Project B42.19 fix exists; current baseline has the mod enabled. Fix fresh logs only if it regresses. |
| `VanillaFoodsExpanded` | restored / stacktrace-clean | Re-enabled in the latest save/default list and validated with `Continue`; fresh `2026-07-01_06-29_DebugLog.txt` has no stacktrace matches. Existing VFE recipe item warning is non-stacktrace and out of scope for now. |
| `ImprovedSv2` | restored / stacktrace-clean | Live `b42Sneak.lua` was refreshed from Workshop `3053929034` so the live folder matches the cached Workshop payload. Re-enabled in latest save/default and validated with `Continue`; fresh `2026-07-01_06-33_DebugLog.txt` has no stacktrace matches. |
| `CasterPlus` | restored / stacktrace-clean | Workshop ID `3457003463` was noted from local `workshopPage.txt`, but no cached Workshop payload was available. Re-enabled the existing live copy in latest save/default and validated with `Continue`; fresh `2026-07-01_06-36_DebugLog.txt` has no stacktrace matches. |

## Removed Mods

| Mod ID | Status | Notes |
| --- | --- | --- |
| `AutoTurret` | removed per user | Absent from the latest save `mods.txt` and `mods/default.txt`. Presets are ignored. Do not chase old AutoTurret log errors unless the user re-adds it. |
| `AutoTailoring` | removed per user / confirmed bad | Removed from current save/default and every saved preset line after the 2026-07-03 11:52 log spammed `Lua((MOD:AutoTailoring)).render(AutoTailoring_CharacterProtection.lua:120)` with `__concat not defined for operands: base:shirt and ]`. Old live folder was deleted from `.runtime/live-mod-backups/20260703-120304-auto-tailoring-better-auto-mechanics/AutoTailoring`; no project repo or active live folder remains. Restore only if the user explicitly asks, then audit against current Workshop first. |
| `AutoMechanics` | removed / replaced | Removed from current save/default and every saved preset line, then replaced by Workshop `better-auto-mechanics` from item `3635856965`. Old live folders parked under `.runtime/live-mod-backups/20260703-120304-auto-tailoring-better-auto-mechanics/AutoMechanics*`. Do not re-enable old `AutoMechanics`; use `better-auto-mechanics` unless the user asks otherwise. |
| `BugZapper9000` | removed per user | Removed from `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/default.txt` and latest save `/media/cjstorrs/windows/Users/cjsto/Zomboid/Saves/Sandbox/2026-07-02_13-03-51/mods.txt`; deleted from the Zomboid install area. Presets are ignored. |
| `KatanaStance2` | removed per user | Removed from all active save `mods.txt` files, `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/default.txt`, and every preset line in `/media/cjstorrs/windows/Users/cjsto/Zomboid/Lua/pz_modlist_settings.cfg`. Live symlink `/media/cjstorrs/windows/Users/cjsto/Zomboid/mods/KatanaStance2` was unlinked; project copy remains at `/home/cjstorrs/projects/game-mods/zomboid/KatanaStance2`. |
| `TakeABathAndShower42` | removed / replaced | Removed from the active default/latest-save/`b42-4` load points per user and replaced by Workshop `TakeABathAndShowerNew` from item `3592172476`. Old live symlink and project copy were moved under `.runtime` backups; other saved preset lines were not changed. |

## Isolation Runs

| Run | Disabled Temporary Batch | Result | Decision |
| --- | --- | --- | --- |
| 2026-07-01 checkpoint | `CasterPlus`, `ImprovedSv2`, `VanillaFoodsExpanded`, `GanydeBielovzki's Frockin Splendor! Vol.4` | User found the first three as crash-before-startup blockers. User re-added Neon and Tomb and said both work. | Under the stacktrace-only scope, `VanillaFoodsExpanded`, `ImprovedSv2`, and `CasterPlus` were restored and validated. Frockin remains parked by user choice. |
