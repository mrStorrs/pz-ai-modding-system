#!/usr/bin/env python3
"""Convert narrowly identified legacy tiledefs for Project Zomboid B42.20.

The binary format is:
  magic, version, sheet count,
  then for each sheet: name, image, width, height, number, tile count,
  then each tile's property count followed by newline-terminated key/value pairs.

This tool refuses trailing data, duplicate target sheets, malformed counts, and
unexpected legacy magic so a compatibility conversion cannot silently corrupt a
tile definition.
"""

from __future__ import annotations

import argparse
import dataclasses
import math
import pathlib
import struct


TDEF_MAGIC = b"tdef"
LEGACY_ZERO_MAGIC = b"\x00\x00\x00\x00"


@dataclasses.dataclass
class Tile:
    properties: list[tuple[bytes, bytes]]


@dataclasses.dataclass
class Sheet:
    name: bytes
    image: bytes
    width: int
    height: int
    number: int
    tiles: list[Tile]


class Reader:
    def __init__(self, payload: bytes) -> None:
        self.payload = payload
        self.offset = 0

    def read_bytes(self, count: int) -> bytes:
        end = self.offset + count
        if end > len(self.payload):
            raise ValueError(f"unexpected EOF at byte {self.offset}")
        result = self.payload[self.offset:end]
        self.offset = end
        return result

    def read_int(self) -> int:
        return struct.unpack("<i", self.read_bytes(4))[0]

    def read_line(self) -> bytes:
        end = self.payload.find(b"\n", self.offset)
        if end < 0:
            raise ValueError(f"unterminated string at byte {self.offset}")
        result = self.payload[self.offset:end]
        self.offset = end + 1
        return result


def parse(payload: bytes, allow_legacy_zero_magic: bool) -> tuple[int, list[Sheet]]:
    reader = Reader(payload)
    magic = reader.read_bytes(4)
    allowed_magic = {TDEF_MAGIC}
    if allow_legacy_zero_magic:
        allowed_magic.add(LEGACY_ZERO_MAGIC)
    if magic not in allowed_magic:
        raise ValueError(f"unsupported magic {magic!r}")

    version = reader.read_int()
    if version != 1:
        raise ValueError(f"unsupported tiledef version {version}")

    sheet_count = reader.read_int()
    if not 0 <= sheet_count <= 100_000:
        raise ValueError(f"invalid sheet count {sheet_count}")

    sheets: list[Sheet] = []
    for _ in range(sheet_count):
        name = reader.read_line()
        image = reader.read_line()
        width = reader.read_int()
        height = reader.read_int()
        number = reader.read_int()
        tile_count = reader.read_int()
        if not 0 <= tile_count <= 100_000:
            raise ValueError(
                f"invalid tile count {tile_count} in {name.decode(errors='replace')}"
            )

        tiles: list[Tile] = []
        for _ in range(tile_count):
            property_count = reader.read_int()
            if not 0 <= property_count <= 100_000:
                raise ValueError(
                    "invalid property count "
                    f"{property_count} in {name.decode(errors='replace')}"
                )
            properties = [
                (reader.read_line(), reader.read_line())
                for _ in range(property_count)
            ]
            tiles.append(Tile(properties))
        sheets.append(Sheet(name, image, width, height, number, tiles))

    if reader.offset != len(payload):
        raise ValueError(
            f"unparsed trailing data: {len(payload) - reader.offset} bytes"
        )
    return version, sheets


def encode(version: int, sheets: list[Sheet]) -> bytes:
    output = bytearray(TDEF_MAGIC)
    output.extend(struct.pack("<i", version))
    output.extend(struct.pack("<i", len(sheets)))
    for sheet in sheets:
        output.extend(sheet.name)
        output.append(10)
        output.extend(sheet.image)
        output.append(10)
        output.extend(
            struct.pack(
                "<iiii",
                sheet.width,
                sheet.height,
                sheet.number,
                len(sheet.tiles),
            )
        )
        for tile in sheet.tiles:
            output.extend(struct.pack("<i", len(tile.properties)))
            for key, value in tile.properties:
                output.extend(key)
                output.append(10)
                output.extend(value)
                output.append(10)
    return bytes(output)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=pathlib.Path)
    parser.add_argument("output", type=pathlib.Path)
    parser.add_argument("--truncate-sheet")
    parser.add_argument(
        "--set-sheet-number",
        nargs=2,
        metavar=("SHEET", "NUMBER"),
    )
    parser.add_argument("--max-tiles", type=int, default=512)
    parser.add_argument("--upgrade-legacy-zero-magic", action="store_true")
    args = parser.parse_args()

    version, sheets = parse(
        args.source.read_bytes(),
        allow_legacy_zero_magic=args.upgrade_legacy_zero_magic,
    )

    changed = False
    if args.truncate_sheet:
        matches = [
            sheet
            for sheet in sheets
            if sheet.name.decode("utf-8") == args.truncate_sheet
        ]
        if len(matches) != 1:
            raise ValueError(
                f"expected exactly one sheet named {args.truncate_sheet!r}, "
                f"found {len(matches)}"
            )
        sheet = matches[0]
        if len(sheet.tiles) <= args.max_tiles:
            raise ValueError(
                f"{args.truncate_sheet} has {len(sheet.tiles)} tiles; "
                f"expected more than {args.max_tiles}"
            )
        original_count = len(sheet.tiles)
        sheet.tiles = sheet.tiles[: args.max_tiles]
        if sheet.width > 0:
            sheet.height = min(
                sheet.height,
                math.ceil(args.max_tiles / sheet.width),
            )
        print(
            f"truncated {args.truncate_sheet}: "
            f"{original_count} -> {len(sheet.tiles)} tiles"
        )
        changed = True

    if args.set_sheet_number:
        sheet_name, number_text = args.set_sheet_number
        number = int(number_text)
        if not 1 <= number <= 512:
            raise ValueError(f"sheet number must be from 1 to 512, got {number}")
        matches = [
            sheet
            for sheet in sheets
            if sheet.name.decode("utf-8") == sheet_name
        ]
        if len(matches) != 1:
            raise ValueError(
                f"expected exactly one sheet named {sheet_name!r}, "
                f"found {len(matches)}"
            )
        sheet = matches[0]
        if sheet.number == number:
            raise ValueError(f"{sheet_name} already has sheet number {number}")
        if any(other is not sheet and other.number == number for other in sheets):
            raise ValueError(f"sheet number {number} is already in use")
        original_number = sheet.number
        sheet.number = number
        print(f"renumbered {sheet_name}: {original_number} -> {number}")
        changed = True

    if args.upgrade_legacy_zero_magic:
        if args.source.read_bytes()[:4] != LEGACY_ZERO_MAGIC:
            raise ValueError("legacy magic upgrade requested, but source is not zero-magic")
        print("upgraded legacy zero magic to tdef")
        changed = True

    if not changed:
        raise ValueError("no conversion requested")

    output = encode(version, sheets)
    parse(output, allow_legacy_zero_magic=False)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.output.with_name(args.output.name + ".tmp")
    temporary.write_bytes(output)
    temporary.replace(args.output)
    print(f"wrote {args.output} ({len(output)} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
