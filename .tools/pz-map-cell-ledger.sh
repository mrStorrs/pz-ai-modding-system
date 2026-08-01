#!/usr/bin/env bash

set -euo pipefail

usage() {
    printf '%s\n' \
        'Usage: pz-map-cell-ledger.sh [--load-list PATH] [--live-root PATH]' \
        '' \
        'Prints a tab-separated ledger of occupied map cells for active mods.' \
        'The newest single-player save mods.txt and /home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/mods are used by default.'
}

live_root="/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/mods"
load_list=

while (($# > 0)); do
    case "$1" in
        --load-list)
            [[ $# -ge 2 ]] || { usage >&2; exit 2; }
            load_list=$2
            shift 2
            ;;
        --live-root)
            [[ $# -ge 2 ]] || { usage >&2; exit 2; }
            live_root=$2
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown argument: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ -z "$load_list" ]]; then
    load_list=$(
        find "/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/Saves" -mindepth 3 -maxdepth 3 \
            -type f -name mods.txt -printf '%T@ %p\n' \
            | sort -nr \
            | head -n 1 \
            | cut -d' ' -f2-
    )
fi

[[ -f "$load_list" ]] || { printf 'Load list not found: %s\n' "$load_list" >&2; exit 1; }
[[ -d "$live_root" ]] || { printf 'Live mods root not found: %s\n' "$live_root" >&2; exit 1; }

audit_tmp=$(mktemp -d)
trap 'rm -rf -- "$audit_tmp"' EXIT

active_ids="$audit_tmp/active-ids.txt"
raw_cells="$audit_tmp/raw-cells.tsv"
sorted_cells="$audit_tmp/sorted-cells.tsv"

awk '
    /^[[:space:]]*mod[[:space:]]*=/ {
        line = $0
        sub(/^[[:space:]]*mod[[:space:]]*=[[:space:]]*/, "", line)
        sub(/,[[:space:]]*$/, "", line)
        sub(/^\\/, "", line)
        sub(/\r$/, "", line)
        print line
    }
' "$load_list" | sort -u > "$active_ids"

: > "$raw_cells"

while IFS= read -r -d '' mod_dir; do
    live_folder=${mod_dir##*/}
    case "$live_folder" in
        home|.codex-*|_disabled-*)
            continue
            ;;
    esac

    # Same-token CJS map tweaks mirror the target's complete map payload because
    # B42.20 resolves media/maps/<token> as one winning directory. Keep cell
    # ownership attributed to the third-party target instead of reporting the
    # byte-identical patch mirror as a second physical map owner. The companion
    # pz-map-shadow-audit.sh verifies that each winning CJS directory is complete.
    if [[ "${live_folder,,}" == *cjstweaks* ]]; then
        continue
    fi

    selected_version=$(
        find -L "$mod_dir" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' \
            | awk '/^42([.][0-9]+)*$/' \
            | sort -V \
            | tail -n 1
    )

    active_id=
    descriptor_candidates=()
    if [[ -n "$selected_version" ]]; then
        descriptor_candidates+=("$mod_dir/$selected_version/mod.info")
    fi
    descriptor_candidates+=(
        "$mod_dir/common/mod.info"
        "$mod_dir/Common/mod.info"
        "$mod_dir/mod.info"
    )

    for descriptor in "${descriptor_candidates[@]}"; do
        [[ -f "$descriptor" ]] || continue
        descriptor_id=$(sed -n 's/^id=//p' "$descriptor" | head -n 1 | tr -d '\r')
        if [[ -n "$descriptor_id" ]] && grep -Fqx -- "$descriptor_id" "$active_ids"; then
            active_id=$descriptor_id
            break
        fi
    done

    [[ -n "$active_id" ]] || continue

    content_roots=()
    [[ -d "$mod_dir/common" ]] && content_roots+=("$mod_dir/common")
    [[ -d "$mod_dir/Common" ]] && content_roots+=("$mod_dir/Common")
    if [[ -n "$selected_version" ]] && [[ -d "$mod_dir/$selected_version" ]]; then
        content_roots+=("$mod_dir/$selected_version")
    fi

    found_versioned_cells=0
    for content_root in "${content_roots[@]}"; do
        while IFS= read -r -d '' cell_file; do
            found_versioned_cells=1
            cell_name=${cell_file##*/}
            cell_name=${cell_name%.lotheader}
            if [[ "$cell_name" =~ ^(-?[0-9]+)_(-?[0-9]+)$ ]]; then
                cell_x=${BASH_REMATCH[1]}
                cell_y=${BASH_REMATCH[2]}
            else
                printf 'Ignoring unrecognized lotheader name: %s\n' "$cell_file" >&2
                continue
            fi

            source_file=${cell_file#"$mod_dir"/}
            map_relative=${cell_file#*'/media/maps/'}
            map_folder=${map_relative%/*}
            source_layout=${content_root#"$mod_dir"/}
            printf '%s\t%s\t%s_%s\t%s\t%s\t%s\t%s\t%s\n' \
                "$cell_x" "$cell_y" "$cell_x" "$cell_y" "$active_id" \
                "$live_folder" "$map_folder" "$source_layout" "$source_file" \
                >> "$raw_cells"
        done < <(find -L "$content_root/media/maps" -type f -name '*.lotheader' -print0 2>/dev/null || true)
    done

    # Legacy-root maps are included only when the active package has no B42/Common
    # lotheaders. This avoids counting dormant B41 cells beside a B42 payload.
    if ((found_versioned_cells == 0)) && [[ -d "$mod_dir/media/maps" ]]; then
        while IFS= read -r -d '' cell_file; do
            cell_name=${cell_file##*/}
            cell_name=${cell_name%.lotheader}
            if [[ "$cell_name" =~ ^(-?[0-9]+)_(-?[0-9]+)$ ]]; then
                cell_x=${BASH_REMATCH[1]}
                cell_y=${BASH_REMATCH[2]}
            else
                printf 'Ignoring unrecognized lotheader name: %s\n' "$cell_file" >&2
                continue
            fi

            source_file=${cell_file#"$mod_dir"/}
            map_relative=${cell_file#*'/media/maps/'}
            map_folder=${map_relative%/*}
            printf '%s\t%s\t%s_%s\t%s\t%s\t%s\tlegacy-root\t%s\n' \
                "$cell_x" "$cell_y" "$cell_x" "$cell_y" "$active_id" \
                "$live_folder" "$map_folder" "$source_file" \
                >> "$raw_cells"
        done < <(find -L "$mod_dir/media/maps" -type f -name '*.lotheader' -print0)
    fi
done < <(find -H "$live_root" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -print0)

LC_ALL=C sort -u -t $'\t' \
    -k1,1n -k2,2n -k4,4 -k5,5 -k6,6 -k8,8 \
    "$raw_cells" > "$sorted_cells"

awk -F '\t' -v OFS='\t' '
    NR == FNR {
        cell = $3
        entries[cell]++
        owner_key = cell SUBSEP $4
        if (!seen_owner[owner_key]++) {
            owners[cell]++
        }
        next
    }
    FNR == 1 {
        print "cell_x", "cell_y", "cell", "mod_id", "live_folder", "map_folder", \
            "source_layout", "source_file", "owner_count", "entry_count", "status"
    }
    {
        cell = $3
        if (owners[cell] > 1) {
            status = "CROSS_MOD_CONFLICT"
        } else if (entries[cell] > 1) {
            status = "SAME_MOD_DUPLICATE"
        } else {
            status = "CLEAR"
        }
        print $0, owners[cell], entries[cell], status
    }
' "$sorted_cells" "$sorted_cells"
