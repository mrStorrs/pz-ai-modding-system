#!/usr/bin/env bash
# Decompile Project Zomboid engine classes for reference when writing Lua-Java calls.
#
# Usage:
#   decompile-pz.sh <relative/path/to/Class.class | relative/package/dir>
#
# Examples:
#   decompile-pz.sh zombie/iso/areas/SafeHouse.class
#   decompile-pz.sh zombie/inventory
#
# Source classes come from the installed PZ build below (GOG 42.12, the version CJS mods
# target -- see versionMin in each mod.info). Output is written to .pz-reference/<ver>/src/,
# mirroring the zombie/... package path, so it can be grepped/read directly.
set -euo pipefail

PZ_ROOT="/media/cjstorrs/windows/Program Files (x86)/GOG Galaxy/Games/Project Zomboid"
PZ_VERSION="42.12"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REF_DIR="$SCRIPT_DIR/../.pz-reference/$PZ_VERSION"
VINEFLOWER="${VINEFLOWER_JAR:-$SCRIPT_DIR/vineflower.jar}"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <relative/path/to/Class.class | relative/package/dir>" >&2
    exit 1
fi

target="$1"
src="$PZ_ROOT/$target"

if [ ! -e "$src" ]; then
    echo "Not found in PZ install: $src" >&2
    exit 1
fi

if [ ! -f "$VINEFLOWER" ]; then
    echo "Vineflower jar not found: $VINEFLOWER" >&2
    echo "Set VINEFLOWER_JAR or place an untracked jar at $SCRIPT_DIR/vineflower.jar" >&2
    exit 1
fi

mkdir -p "$REF_DIR/src/zombie"

# Vineflower mirrors the input's package-relative structure under the output dir, but drops the
# leading "zombie" segment when fed a path inside zombie/ -- decompile into a temp dir, then
# fold the result under src/zombie/ so the on-disk layout always matches the Java package path.
tmpout="$(mktemp -d)"
trap 'rm -rf "$tmpout"' EXIT

java -jar "$VINEFLOWER" --log-level=warn "$src" "$tmpout"

if [ -d "$tmpout/zombie" ]; then
    cp -rf "$tmpout/zombie/." "$REF_DIR/src/zombie/"
else
    # Path was already inside zombie/<...>; reconstruct the matching subpath.
    rel="${target#zombie/}"
    rel_dir="$(dirname "$rel")"
    mkdir -p "$REF_DIR/src/zombie/$rel_dir"
    cp -rf "$tmpout/." "$REF_DIR/src/zombie/$rel_dir/"
fi

echo "Decompiled into $REF_DIR/src/zombie/$(dirname "${target#zombie/}")/"
