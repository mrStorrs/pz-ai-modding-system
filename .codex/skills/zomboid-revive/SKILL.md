---
name: zomboid-revive
description: Safely revive and fully heal a dead local single-player character in a Project Zomboid Build 42.20 save by selecting the newest save, archiving it, repairing both players.db isDead state and serialized body health, and verifying the binary and SQLite result. Use when the user asks to revive, resurrect, undeath, or recover a character; undo a recent character death; repair the most recent save; inspect a dead survivor's body health; or fix an instant-death loop left by changing only isDead. Supports worldversion 247 localPlayers only and stops on any other B42.20 layout; multiplayer/server characters are unsupported.
---

# Zomboid Revive

Use `scripts/revive_player.py` for all database and player-blob work. Do not recreate its binary edits with ad hoc SQL or hard-coded offsets.

## Safety rules

- Read and apply the workspace `b42.20-codex-instructions.md` before live save work.
- Never start, stop, or kill Project Zomboid for this workflow. The script must refuse all access while the game is running.
- Require an explicit user request before changing a live save. For questions or diagnosis, run `inspect` only.
- Keep backups under the existing `/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/.codex-backups/` tree. Do not create new top-level home paths.
- Never treat `isDead=0` alone as a complete revival. Serialized body-part health can still calculate to zero and immediately kill the character again.
- Never fall back to guessed byte offsets when parsing, schema, version, integrity, or player selection is ambiguous.

## Workflow

### 1. Inspect the target

From the Zomboid workspace root, run:

```bash
python3 .codex/skills/zomboid-revive/scripts/revive_player.py inspect
```

Omit `--save` when the user says newest, latest, or most recent. The script selects the newest local save containing `players.db` and reports the exact path.

Use an explicit save or player selector when needed:

```bash
python3 .codex/skills/zomboid-revive/scripts/revive_player.py inspect --save "/path/to/save"
python3 .codex/skills/zomboid-revive/scripts/revive_player.py inspect --save "/path/to/save" --player-id 1
python3 .codex/skills/zomboid-revive/scripts/revive_player.py inspect --save "/path/to/save" --player-name "CJ Storrs"
```

Confirm the selected save, character name, `isDead`, calculated body health, Food Sickness, zombie infection, and active wounds before changing anything.

### 2. Revive and heal

Run the same selector with `revive`:

```bash
python3 .codex/skills/zomboid-revive/scripts/revive_player.py revive
```

The script must complete these operations as one guarded workflow:

1. Recheck that the game is stopped and `players.db` passes `integrity_check`.
2. Create a timestamped raw database backup, full save archive, and manifest.
3. Clear `localPlayers.isDead`.
4. Rebuild the variable-length B42.20 body-damage records at full health with wounds, bites, bleeding, burns, fractures, and infection cleared.
5. Reset only physical danger stats and body-damage main fields; preserve inventory, XP, traits, position, and unrelated character stats and payload bytes.
6. Commit once, rerun SQLite integrity checks, decode the written blob, and prove the post-health payload is unchanged.

If the character is already alive with positive calculated body health, accept the no-op result and do not create a backup.

### 3. Close out

Report:

- the save and character selected;
- `isDead=0`;
- calculated body health `100` and all 17 body parts at `100`;
- cleared Food Sickness and zombie infection/fever;
- SQLite integrity success;
- the timestamped backup directory;
- that in-game Continue/load confirmation remains unless the user already tested it.

Do not launch the game as validation unless the user explicitly asks.

## Stop conditions

Stop without editing when any of these occurs:

- Project Zomboid is running;
- `players.db` is missing, locked, or fails integrity checks;
- more than one local player exists and the requested character is ambiguous;
- the character is only in `networkPlayers` or another multiplayer/server store;
- `worldversion` is not the supported value `247`;
- the decoder finds anything other than one valid ordered-stats/body-damage block;
- the full save archive cannot be created and verified;
- any unrelated stat or payload region changes during reconstruction.

Preserve the failed-state backup directory if backup creation began, and explain the exact blocker.
