#!/usr/bin/env bash
set -euo pipefail

default_live_root="/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/mods"
live_root=${1:-$default_live_root}

if [[ ! -d "$live_root" ]]; then
    printf 'live mods directory not found: %s\n' "$live_root" >&2
    exit 2
fi

declare -A max_headers_by_token=()
declare -A source_by_token=()

map_directories() {
    local mod_path=$1
    local directory parent

    while IFS= read -r -d '' directory; do
        parent=$(basename "$(dirname "$directory")")
        if [[ "${parent,,}" == "maps" ]]; then
            printf '%s\0' "$directory"
        fi
    done < <(find -L "$mod_path" -type d -path '*/media/maps/*' -print0 2>/dev/null)
}

while IFS= read -r -d '' mod_path; do
    while IFS= read -r -d '' map_directory; do
        token=${map_directory##*/}
        token=${token,,}
        header_count=$(find "$map_directory" -maxdepth 1 -type f -name '*.lotheader' | wc -l)
        current_max=${max_headers_by_token[$token]:-0}
        if (( header_count > current_max )); then
            max_headers_by_token[$token]=$header_count
            source_by_token[$token]=$map_directory
        fi
    done < <(map_directories "$mod_path")
done < <(find "$live_root" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -print0)

printf 'status\tmod\tmap_token\tlotheaders\tlotpacks\tchunkdata\texpected\tphysical_source\n'
failure=0

while IFS= read -r -d '' mod_path; do
    [[ -L "$mod_path" ]] || continue
    mod_name=${mod_path##*/}
    [[ "${mod_name,,}" == *cjstweaks* ]] || continue

    while IFS= read -r -d '' map_directory; do
        token_name=${map_directory##*/}
        token=${token_name,,}
        expected=${max_headers_by_token[$token]:-0}
        (( expected > 0 )) || continue

        header_count=$(find "$map_directory" -maxdepth 1 -type f -name '*.lotheader' | wc -l)
        lotpack_count=$(find "$map_directory" -maxdepth 1 -type f -name 'world_*.lotpack' | wc -l)
        chunkdata_count=$(find "$map_directory" -maxdepth 1 -type f -name 'chunkdata_*.bin' | wc -l)

        status=OK
        if (( header_count != expected || lotpack_count != expected || chunkdata_count != expected )) \
            || [[ ! -f "$map_directory/map.info" ]]; then
            status=INCOMPLETE_SHADOW
            failure=1
        fi

        printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
            "$status" "$mod_name" "$token_name" "$header_count" "$lotpack_count" \
            "$chunkdata_count" "$expected" "${source_by_token[$token]}"
    done < <(map_directories "$mod_path")
done < <(find "$live_root" -mindepth 1 -maxdepth 1 \( -type d -o -type l \) -print0)

exit "$failure"
