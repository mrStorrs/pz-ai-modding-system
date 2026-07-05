#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 || "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: link-project-mod.sh modFolder

Links one project-backed Project Zomboid mod by pointing the live
Zomboid/mods/modFolder entry back to the matching project folder in this
workspace.
EOF
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_ROOT="$SCRIPT_DIR" \
DEST_ROOT="/media/cjstorrs/windows/Users/cjsto/Zomboid/mods" \
MOD_NAME="$1" \
"$SCRIPT_DIR/../link-zomboid-project-mods.sh"
