#!/usr/bin/env python3
"""Inspect or revive a local Project Zomboid B42.20 player save."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
import shutil
import sqlite3
import struct
import sys
import tarfile
from typing import Iterable


SUPPORTED_WORLD_VERSIONS = {247}
DEFAULT_ZOMBOID_DIR = Path(
    "/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid"
)
STAT_NAMES = (
    "Anger",
    "Boredom",
    "Discomfort",
    "Endurance",
    "Fatigue",
    "Fitness",
    "FoodSickness",
    "Hunger",
    "Idleness",
    "Intoxication",
    "Morale",
    "NicotineWithdrawal",
    "Pain",
    "Panic",
    "Poison",
    "Sanity",
    "Sickness",
    "Stress",
    "Temperature",
    "Thirst",
    "Unhappiness",
    "Wetness",
    "ZombieFever",
    "ZombieInfection",
)
STAT_RANGES = (
    (0.0, 1.0),
    (0.0, 100.0),
    (0.0, 100.0),
    (0.0, 1.0),
    (0.0, 1.0),
    (-1.0, 1.0),
    (0.0, 100.0),
    (0.0, 1.0),
    (0.0, 1.0),
    (0.0, 100.0),
    (0.0, 1.0),
    (0.0, 0.51),
    (0.0, 100.0),
    (0.0, 100.0),
    (0.0, 100.0),
    (0.0, 1.0),
    (0.0, 1.0),
    (0.0, 1.0),
    (20.0, 40.0),
    (0.0, 1.0),
    (0.0, 100.0),
    (0.0, 100.0),
    (0.0, 100.0),
    (0.0, 100.0),
)
PHYSICAL_STAT_DEFAULTS = {
    "Discomfort": 0.0,
    "FoodSickness": 0.0,
    "Pain": 0.0,
    "Poison": 0.0,
    "Sickness": 0.0,
    "Temperature": 37.0,
    "Wetness": 0.0,
    "ZombieFever": 0.0,
    "ZombieInfection": 0.0,
}
PART_NAMES = (
    "Hand_L",
    "Hand_R",
    "ForeArm_L",
    "ForeArm_R",
    "UpperArm_L",
    "UpperArm_R",
    "Torso_Upper",
    "Torso_Lower",
    "Head",
    "Neck",
    "Groin",
    "UpperLeg_L",
    "UpperLeg_R",
    "LowerLeg_L",
    "LowerLeg_R",
    "Foot_L",
    "Foot_R",
)
DAMAGE_MODIFIERS = (
    0.1,
    0.1,
    0.2,
    0.2,
    0.3,
    0.3,
    0.35,
    0.4,
    0.6,
    0.7,
    0.4,
    0.3,
    0.3,
    0.2,
    0.2,
    0.2,
    0.2,
)
WOUND_NAMES = (
    "cut",
    "bitten",
    "scratched",
    "bandaged",
    "bleeding",
    "deepWound",
    "fakeInfected",
    "infected",
)


class ReviveError(RuntimeError):
    """Raised when a save cannot be inspected or changed safely."""


class ParseError(ValueError):
    """Raised when a byte sequence is not a B42.20 body-damage block."""


@dataclass(frozen=True)
class PlayerRecord:
    player_id: int
    name: str
    wx: int
    wy: int
    x: float
    y: float
    z: float
    world_version: int
    data: bytes
    is_dead: bool


@dataclass(frozen=True)
class BodyPartState:
    name: str
    health: float
    flags: tuple[bool, ...]
    infected_wound: bool

    @property
    def conditions(self) -> tuple[str, ...]:
        active = [name for name, enabled in zip(WOUND_NAMES, self.flags) if enabled]
        if self.infected_wound:
            active.append("woundInfected")
        return tuple(active)


@dataclass(frozen=True)
class PlayerLayout:
    stats_start: int
    stats: tuple[float, ...]
    body_start: int
    parts: tuple[BodyPartState, ...]
    main_start: int
    main_end: int

    @property
    def body_health(self) -> float:
        damage = sum(
            (100.0 - part.health) * modifier
            for part, modifier in zip(self.parts, DAMAGE_MODIFIERS)
        )
        return max(0.0, 100.0 - min(100.0, damage))

    def stat(self, name: str) -> float:
        return self.stats[STAT_NAMES.index(name)]


class BufferReader:
    def __init__(self, data: bytes, position: int):
        self.data = data
        self.position = position

    def _require(self, size: int) -> None:
        if self.position + size > len(self.data):
            raise ParseError("unexpected end of player blob")

    def u8(self) -> int:
        self._require(1)
        value = self.data[self.position]
        self.position += 1
        return value

    def boolean(self) -> bool:
        value = self.u8()
        if value not in (0, 1):
            raise ParseError(f"invalid boolean byte {value}")
        return bool(value)

    def f32(self) -> float:
        self._require(4)
        value = struct.unpack_from(">f", self.data, self.position)[0]
        self.position += 4
        return value

    def i32(self) -> int:
        self._require(4)
        value = struct.unpack_from(">i", self.data, self.position)[0]
        self.position += 4
        return value

    def string_utf(self) -> str:
        self._require(2)
        length = struct.unpack_from(">h", self.data, self.position)[0]
        self.position += 2
        if length < 0 or length > 512:
            raise ParseError(f"invalid string length {length}")
        if length == 0:
            return ""
        self._require(length)
        raw = self.data[self.position : self.position + length]
        self.position += length
        try:
            value = raw.decode("utf-8")
        except UnicodeDecodeError as error:
            raise ParseError("invalid UTF-8 in body-damage record") from error
        if any(ord(character) < 32 for character in value):
            raise ParseError("control character in body-damage string")
        return value


def _sane_float(value: float, low: float = -1e7, high: float = 1e7) -> float:
    if not math.isfinite(value) or not low <= value <= high:
        raise ParseError(f"invalid float {value}")
    return value


def _parse_body_part(reader: BufferReader, name: str) -> BodyPartState:
    flags = tuple(reader.boolean() for _ in range(8))
    health = _sane_float(reader.f32(), 0.0, 100.01)
    if flags[3]:
        _sane_float(reader.f32())

    infected_wound = reader.boolean()
    if infected_wound:
        _sane_float(reader.f32())

    for _ in range(7):
        _sane_float(reader.f32())
    reader.boolean()
    reader.boolean()
    reader.boolean()
    _sane_float(reader.f32())
    reader.boolean()
    reader.boolean()
    _sane_float(reader.f32())
    splinted = reader.boolean()
    if splinted:
        _sane_float(reader.f32())
    reader.boolean()
    _sane_float(reader.f32())
    reader.boolean()
    _sane_float(reader.f32())
    reader.string_utf()
    reader.string_utf()
    tail = tuple(_sane_float(reader.f32()) for _ in range(6))
    if not 0.0 <= tail[1] <= 100.01 or not 0.0 <= tail[2] <= 100.01:
        raise ParseError("invalid body-part wetness or stiffness")

    return BodyPartState(name, health, flags, infected_wound)


def _parse_layout_candidate(data: bytes, body_start: int) -> PlayerLayout:
    stats_start = body_start - len(STAT_NAMES) * 4
    if stats_start < 0:
        raise ParseError("stats block would start before player blob")

    stats = struct.unpack_from(f">{len(STAT_NAMES)}f", data, stats_start)
    for value, (low, high) in zip(stats, STAT_RANGES):
        if not math.isfinite(value) or not low - 1e-4 <= value <= high + 1e-4:
            raise ParseError("values do not match the B42.20 ordered stats block")

    reader = BufferReader(data, body_start)
    parts = tuple(_parse_body_part(reader, name) for name in PART_NAMES)
    main_start = reader.position
    _sane_float(reader.f32())
    reader.boolean()
    _sane_float(reader.f32())
    reader.i32()
    reader.boolean()
    for _ in range(6):
        _sane_float(reader.f32())
    main_end = reader.position
    reader.boolean()  # Thermoregulator-present flag; preserve it and its payload.

    return PlayerLayout(stats_start, tuple(stats), body_start, parts, main_start, main_end)


def locate_player_layout(data: bytes) -> PlayerLayout:
    candidates: list[PlayerLayout] = []
    stats_size = len(STAT_NAMES) * 4
    for body_start in range(stats_size, len(data)):
        try:
            candidates.append(_parse_layout_candidate(data, body_start))
        except (ParseError, struct.error):
            continue
    if len(candidates) != 1:
        raise ReviveError(
            f"expected one B42.20 body-damage block, found {len(candidates)}; "
            "leave the save unchanged"
        )
    return candidates[0]


def _clean_body_part() -> bytes:
    output = bytearray(b"\x00" * 8)
    output.extend(struct.pack(">f", 100.0))
    output.extend(b"\x00")
    output.extend(struct.pack(">7f", *([0.0] * 7)))
    output.extend(b"\x00" * 3)
    output.extend(struct.pack(">f", 0.0))
    output.extend(b"\x00" * 2)
    output.extend(struct.pack(">f", 0.0))
    output.extend(b"\x00")
    output.extend(b"\x00")
    output.extend(struct.pack(">f", 0.0))
    output.extend(b"\x00")
    output.extend(struct.pack(">f", 0.0))
    output.extend(struct.pack(">h", 0))
    output.extend(struct.pack(">h", 0))
    output.extend(struct.pack(">6f", *([0.0] * 6)))
    if len(output) != 93:
        raise AssertionError(f"clean body-part record is {len(output)} bytes, expected 93")
    return bytes(output)


def _clean_body_main_fields() -> bytes:
    output = struct.pack(
        ">fBfiB6f",
        0.0,  # catch-a-cold progress
        0,  # has a cold
        0.0,  # cold strength
        -1,  # no scheduled sneeze/cough
        0,  # reduce fake infection
        0.0,  # health-from-food timer
        0.0,  # pain reduction
        0.0,  # cold reduction
        -1.0,  # infection time
        -1.0,  # infection mortality duration
        0.0,  # cold damage stage
    )
    if len(output) != 38:
        raise AssertionError(f"clean body main fields are {len(output)} bytes, expected 38")
    return output


def build_revived_blob(data: bytes, layout: PlayerLayout) -> tuple[bytes, PlayerLayout]:
    stats_bytes = bytearray(data[layout.stats_start : layout.body_start])
    for name, default in PHYSICAL_STAT_DEFAULTS.items():
        index = STAT_NAMES.index(name)
        struct.pack_into(">f", stats_bytes, index * 4, default)

    clean_body = _clean_body_part() * len(PART_NAMES)
    clean_main = _clean_body_main_fields()
    revived = b"".join(
        (
            data[: layout.stats_start],
            bytes(stats_bytes),
            clean_body,
            clean_main,
            data[layout.main_end :],
        )
    )
    revived_layout = locate_player_layout(revived)

    if revived[: layout.stats_start] != data[: layout.stats_start]:
        raise ReviveError("revive changed bytes before the health state")
    if revived[revived_layout.main_end :] != data[layout.main_end :]:
        raise ReviveError("revive changed bytes after the health state")
    for index, name in enumerate(STAT_NAMES):
        if name in PHYSICAL_STAT_DEFAULTS:
            continue
        old = data[layout.stats_start + index * 4 : layout.stats_start + (index + 1) * 4]
        new = revived[
            revived_layout.stats_start + index * 4 : revived_layout.stats_start + (index + 1) * 4
        ]
        if old != new:
            raise ReviveError(f"revive changed unrelated stat {name}")
    if revived_layout.body_health != 100.0:
        raise ReviveError(f"revived body health is {revived_layout.body_health}, expected 100")
    if any(part.conditions or part.health != 100.0 for part in revived_layout.parts):
        raise ReviveError("revived body-part state is not fully healed")
    for name, default in PHYSICAL_STAT_DEFAULTS.items():
        if revived_layout.stat(name) != default:
            raise ReviveError(f"revived {name} is not {default}")

    return revived, revived_layout


def _running_game_processes() -> list[tuple[int, str]]:
    matches: list[tuple[int, str]] = []
    own_pid = os.getpid()
    for entry in Path("/proc").iterdir():
        if not entry.name.isdigit() or int(entry.name) == own_pid:
            continue
        try:
            command = (entry / "cmdline").read_bytes().replace(b"\x00", b" ").decode(
                "utf-8", errors="replace"
            )
        except (FileNotFoundError, PermissionError, ProcessLookupError):
            continue
        lowered = command.lower()
        if "projectzomboid" in lowered or "zombie.gamestates." in lowered:
            matches.append((int(entry.name), command.strip()))
    return matches


def ensure_game_stopped() -> None:
    matches = _running_game_processes()
    if matches:
        detail = "; ".join(f"PID {pid}: {command}" for pid, command in matches)
        raise ReviveError(f"Project Zomboid appears to be running ({detail})")


def resolve_save_dir(save: Path | None, zomboid_dir: Path) -> Path:
    if save is not None:
        candidate = save.expanduser().resolve()
        if candidate.name == "players.db":
            candidate = candidate.parent
        if not (candidate / "players.db").is_file():
            raise ReviveError(f"save has no players.db: {candidate}")
        return candidate

    saves_root = zomboid_dir.expanduser().resolve() / "Saves"
    candidates = [path.parent for path in saves_root.glob("*/*/players.db") if path.is_file()]
    if not candidates:
        raise ReviveError(f"no local saves with players.db under {saves_root}")

    def save_time(path: Path) -> float:
        mtimes = [path.stat().st_mtime, (path / "players.db").stat().st_mtime]
        mtimes.extend(child.stat().st_mtime for child in path.iterdir() if child.is_file())
        return max(mtimes)

    return max(candidates, key=save_time).resolve()


def _connect_read_only(database: Path) -> sqlite3.Connection:
    return sqlite3.connect(f"file:{database}?mode=ro", uri=True)


def read_players(database: Path) -> list[PlayerRecord]:
    with _connect_read_only(database) as connection:
        integrity = connection.execute("pragma integrity_check").fetchone()[0]
        if integrity != "ok":
            raise ReviveError(f"players.db integrity check failed: {integrity}")
        columns = {row[1] for row in connection.execute("pragma table_info(localPlayers)")}
        required = {
            "id",
            "name",
            "wx",
            "wy",
            "x",
            "y",
            "z",
            "worldversion",
            "data",
            "isDead",
        }
        if not required.issubset(columns):
            raise ReviveError(f"localPlayers schema is missing: {sorted(required - columns)}")
        rows = connection.execute(
            "select id,name,wx,wy,x,y,z,worldversion,data,isDead from localPlayers order by id"
        ).fetchall()

    players = [
        PlayerRecord(
            int(row[0]),
            str(row[1]),
            int(row[2]),
            int(row[3]),
            float(row[4]),
            float(row[5]),
            float(row[6]),
            int(row[7]),
            bytes(row[8]),
            bool(row[9]),
        )
        for row in rows
    ]
    if not players:
        raise ReviveError(f"no local player records in {database}")
    return players


def select_player(
    players: Iterable[PlayerRecord], player_id: int | None, player_name: str | None
) -> PlayerRecord:
    choices = list(players)
    if player_id is not None:
        choices = [player for player in choices if player.player_id == player_id]
    if player_name is not None:
        folded = player_name.casefold()
        choices = [player for player in choices if player.name.casefold() == folded]
    if len(choices) == 1:
        return choices[0]

    listing = ", ".join(
        f"id={player.player_id} name={player.name!r} isDead={int(player.is_dead)}"
        for player in choices or players
    )
    if not choices:
        raise ReviveError(f"no player matched the selector; available: {listing}")
    raise ReviveError(f"multiple local players; specify --player-id or --player-name: {listing}")


def validate_world_version(player: PlayerRecord) -> None:
    if player.world_version not in SUPPORTED_WORLD_VERSIONS:
        supported = ", ".join(str(value) for value in sorted(SUPPORTED_WORLD_VERSIONS))
        raise ReviveError(
            f"worldversion {player.world_version} is not supported; expected {supported} "
            "for the supported B42.20-targeted layout"
        )


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def create_backup(
    save_dir: Path,
    backup_root: Path,
    player: PlayerRecord,
    layout: PlayerLayout,
) -> Path:
    backup_root = backup_root.expanduser().resolve()
    if backup_root == save_dir or save_dir in backup_root.parents:
        raise ReviveError("backup root must be outside the save directory")
    backup_root.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().astimezone().strftime("%Y%m%d-%H%M%S")
    backup_dir = backup_root / f"zomboid-revive-{timestamp}"
    suffix = 1
    while backup_dir.exists():
        backup_dir = backup_root / f"zomboid-revive-{timestamp}-{suffix}"
        suffix += 1
    backup_dir.mkdir()

    database = save_dir / "players.db"
    shutil.copy2(database, backup_dir / "players.db.before")
    journal = save_dir / "players.db-journal"
    if journal.exists():
        shutil.copy2(journal, backup_dir / "players.db-journal.before")

    archive = backup_dir / "save-before-revive.tar.gz"
    temporary_archive = archive.with_suffix(archive.suffix + ".part")
    try:
        with tarfile.open(temporary_archive, "w:gz") as tar:
            tar.add(save_dir, arcname=save_dir.name, recursive=True)
        os.replace(temporary_archive, archive)
        with tarfile.open(archive, "r:gz") as tar:
            if not any(member.name.endswith("/players.db") for member in tar.getmembers()):
                raise ReviveError("backup archive does not contain players.db")
    finally:
        temporary_archive.unlink(missing_ok=True)

    manifest = {
        "created_at": datetime.now().astimezone().isoformat(),
        "save_dir": str(save_dir),
        "player": {"id": player.player_id, "name": player.name},
        "world_version": player.world_version,
        "before": {
            "is_dead": player.is_dead,
            "body_health": layout.body_health,
            "player_blob_sha256": sha256_bytes(player.data),
            "players_db_sha256": sha256_file(database),
        },
        "archive_sha256": sha256_file(archive),
    }
    (backup_dir / "manifest.json").write_text(
        json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    return backup_dir


def update_player(database: Path, before: PlayerRecord, revived_data: bytes) -> PlayerRecord:
    connection = sqlite3.connect(database)
    connection.execute("pragma busy_timeout=5000")
    try:
        connection.execute("begin immediate")
        current = connection.execute(
            "select id,name,wx,wy,x,y,z,worldversion,data,isDead from localPlayers where id=?",
            (before.player_id,),
        ).fetchone()
        if current is None:
            raise ReviveError(f"player id {before.player_id} disappeared before update")
        current_record = PlayerRecord(
            int(current[0]),
            str(current[1]),
            int(current[2]),
            int(current[3]),
            float(current[4]),
            float(current[5]),
            float(current[6]),
            int(current[7]),
            bytes(current[8]),
            bool(current[9]),
        )
        if current_record != before:
            raise ReviveError("player record changed after inspection; retry from a fresh read")
        cursor = connection.execute(
            "update localPlayers set data=?, isDead=0 where id=?",
            (revived_data, before.player_id),
        )
        if cursor.rowcount != 1:
            raise ReviveError(f"updated {cursor.rowcount} rows, expected one")
        connection.commit()
        integrity = connection.execute("pragma integrity_check").fetchone()[0]
        if integrity != "ok":
            raise ReviveError(f"post-update integrity check failed: {integrity}")
    except Exception:
        connection.rollback()
        raise
    finally:
        connection.close()

    players = read_players(database)
    updated = select_player(players, before.player_id, None)
    unchanged = (
        updated.player_id,
        updated.name,
        updated.wx,
        updated.wy,
        updated.x,
        updated.y,
        updated.z,
        updated.world_version,
    ) == (
        before.player_id,
        before.name,
        before.wx,
        before.wy,
        before.x,
        before.y,
        before.z,
        before.world_version,
    )
    if not unchanged or updated.is_dead or updated.data != revived_data:
        raise ReviveError("post-update player verification failed")
    return updated


def print_report(save_dir: Path, player: PlayerRecord, layout: PlayerLayout) -> None:
    conditions = [
        f"{part.name}:{'/'.join(part.conditions)}" for part in layout.parts if part.conditions
    ]
    print(f"save: {save_dir}")
    print(f"player: id={player.player_id} name={player.name!r}")
    print(f"worldversion: {player.world_version}")
    print(f"isDead: {int(player.is_dead)}")
    print(f"body_health: {layout.body_health:.3f}")
    print(f"food_sickness: {layout.stat('FoodSickness'):.3f}")
    print(f"zombie_fever: {layout.stat('ZombieFever'):.3f}")
    print(f"zombie_infection: {layout.stat('ZombieInfection'):.3f}")
    print(f"active_conditions: {', '.join(conditions) if conditions else 'none'}")
    print(f"player_blob_sha256: {sha256_bytes(player.data)}")


def command_inspect(args: argparse.Namespace) -> int:
    ensure_game_stopped()
    save_dir = resolve_save_dir(args.save, args.zomboid_dir)
    player = select_player(read_players(save_dir / "players.db"), args.player_id, args.player_name)
    validate_world_version(player)
    layout = locate_player_layout(player.data)
    print_report(save_dir, player, layout)
    return 0


def command_revive(args: argparse.Namespace) -> int:
    ensure_game_stopped()
    save_dir = resolve_save_dir(args.save, args.zomboid_dir)
    database = save_dir / "players.db"
    player = select_player(read_players(database), args.player_id, args.player_name)
    validate_world_version(player)
    layout = locate_player_layout(player.data)
    if not player.is_dead and layout.body_health > 0.0:
        print_report(save_dir, player, layout)
        print("result: player is already alive; no files changed")
        return 0

    revived_data, _ = build_revived_blob(player.data, layout)
    backup_dir = create_backup(save_dir, args.backup_root, player, layout)
    updated = update_player(database, player, revived_data)
    updated_layout = locate_player_layout(updated.data)
    print_report(save_dir, updated, updated_layout)
    print(f"backup: {backup_dir}")
    print("result: revived and fully healed")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Safely inspect or revive a local Project Zomboid B42.20 player."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    def add_common(subparser: argparse.ArgumentParser) -> None:
        subparser.add_argument(
            "--save",
            type=Path,
            help="save directory or players.db; defaults to the most recently written local save",
        )
        subparser.add_argument(
            "--zomboid-dir",
            type=Path,
            default=DEFAULT_ZOMBOID_DIR,
            help="Zomboid data directory used for automatic save discovery",
        )
        subparser.add_argument("--player-id", type=int, help="localPlayers.id to select")
        subparser.add_argument("--player-name", help="exact local player name to select")

    inspect_parser = subparsers.add_parser("inspect", help="report revival-relevant save state")
    add_common(inspect_parser)
    inspect_parser.set_defaults(handler=command_inspect)

    revive_parser = subparsers.add_parser(
        "revive", help="back up the save, clear death state, and restore physical health"
    )
    add_common(revive_parser)
    revive_parser.add_argument(
        "--backup-root",
        type=Path,
        default=DEFAULT_ZOMBOID_DIR / ".codex-backups",
        help="existing organized area in which to create a timestamped backup directory",
    )
    revive_parser.set_defaults(handler=command_revive)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        return int(args.handler(args))
    except (ReviveError, OSError, sqlite3.Error, tarfile.TarError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
