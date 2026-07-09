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
# Source classes come from the active local PZ build jar. Output is written to
# .pz-reference/<ver>/src/, mirroring the zombie/... package path, so it can be
# grepped/read directly.
set -euo pipefail

PZ_ROOT="${PZ_ROOT:-/home/cjstorrs/games/Project Zomboid Linux 42.19.0/game/projectzomboid}"
PZ_JAR="${PZ_JAR:-$PZ_ROOT/projectzomboid.jar}"
PZ_VERSION="${PZ_VERSION:-42.19}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REF_DIR="$SCRIPT_DIR/../.pz-reference/$PZ_VERSION"
VINEFLOWER="${VINEFLOWER_JAR:-$SCRIPT_DIR/vineflower.jar}"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <relative/path/to/Class.class | relative/package/dir>" >&2
    exit 1
fi

target="${1#/}"
target="${target%/}"

if [ ! -f "$PZ_JAR" ]; then
    echo "Project Zomboid jar not found: $PZ_JAR" >&2
    exit 1
fi

if [ ! -f "$VINEFLOWER" ]; then
    echo "Vineflower jar not found: $VINEFLOWER" >&2
    echo "Set VINEFLOWER_JAR or place an untracked jar at $SCRIPT_DIR/vineflower.jar" >&2
    exit 1
fi

entries=()
if [[ "$target" == *.class ]]; then
    base="${target%.class}"
    while IFS= read -r entry; do
        if [[ "$entry" == "$target" || "$entry" == "$base"\$*.class ]]; then
            entries+=("$entry")
        fi
    done < <(jar tf "$PZ_JAR")
else
    prefix="$target/"
    while IFS= read -r entry; do
        if [[ "$entry" == "$prefix"*.class ]]; then
            entries+=("$entry")
        fi
    done < <(jar tf "$PZ_JAR")
fi

if [ "${#entries[@]}" -eq 0 ]; then
    echo "Not found in PZ jar: $target" >&2
    exit 1
fi

mkdir -p "$REF_DIR/src"

tmpin="$(mktemp -d)"
tmpout="$(mktemp -d)"
trap 'rm -rf "$tmpin" "$tmpout"' EXIT

(
    cd "$tmpin"
    jar xf "$PZ_JAR" "${entries[@]}"
)

java -jar "$VINEFLOWER" --log-level=warn "$tmpin" "$tmpout"

cp -rf "$tmpout/." "$REF_DIR/src/"

echo "Decompiled ${#entries[@]} class file(s) into $REF_DIR/src/"
