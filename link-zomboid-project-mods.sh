#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_ROOT="${SOURCE_ROOT:-$SCRIPT_DIR}"
DEST_ROOT="${DEST_ROOT:-/home/cjstorrs/games/Project Zomboid Linux 42.20.0/user-data/Zomboid/mods}"
DRY_RUN="${DRY_RUN:-0}"
MOD_NAME="${MOD_NAME:-${1:-}}"

usage() {
  cat <<'EOF'
Usage: link-zomboid-project-mods.sh [modFolder]

Links Project Zomboid project mod folders from SOURCE_ROOT into DEST_ROOT.
Live symlink names use the project folder casing exactly.

Default behavior:
  Reconcile project-backed mods that are already present in the live mods
  folder as real folders or symlinks. Project-only folders are not installed
  unless a mod folder is supplied.

Overrides:
  MOD_NAME=ExampleMod ./link-zomboid-project-mods.sh
  ./link-zomboid-project-mods.sh ExampleMod
  DRY_RUN=1 ./link-zomboid-project-mods.sh
  SOURCE_ROOT=/path/to/project/mods DEST_ROOT=/path/to/Zomboid/mods ./link-zomboid-project-mods.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 1 ]]; then
  echo "error: expected at most one mod folder argument" >&2
  exit 1
fi

case "$DRY_RUN" in
  ""|0|false|False|FALSE|no|No|NO)
    dry_run=0
    ;;
  1|true|True|TRUE|yes|Yes|YES)
    dry_run=1
    ;;
  *)
    echo "error: DRY_RUN must be 0 or 1" >&2
    exit 1
    ;;
esac

export SOURCE_ROOT DEST_ROOT MOD_NAME DRY_RUN="$dry_run"

python3 - <<'PY'
import os
import shutil
import sys
from collections import defaultdict
from pathlib import Path

source_root = Path(os.environ["SOURCE_ROOT"]).expanduser().resolve()
dest_root = Path(os.environ["DEST_ROOT"]).expanduser().resolve()
mod_name = os.environ.get("MOD_NAME", "")
dry_run = os.environ.get("DRY_RUN") == "1"

skip_project_dirs = {
    "pz-linux-native-compat",
    "workshop-research",
}


def fail(message):
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


if not source_root.is_dir():
    fail(f"source directory does not exist: {source_root}")

if source_root == dest_root:
    fail("source and destination must be different directories")

home = Path.home().resolve()
if dest_root == Path("/") or dest_root == home:
    fail(f"refusing unsafe destination: {dest_root}")

if mod_name and ("/" in mod_name or mod_name in {".", ".."}):
    fail("mod folder must be a single top-level directory name")


def mod_info_paths(mod_dir):
    paths = []
    primary = mod_dir / "42.20" / "mod.info"
    if primary.is_file():
        paths.append(primary)

    for path in sorted(mod_dir.glob("42*/mod.info")):
        if path != primary and path.is_file():
            paths.append(path)

    for path in (
        mod_dir / "Common" / "mod.info",
        mod_dir / "common" / "mod.info",
        mod_dir / "mod.info",
    ):
        if path.is_file():
            paths.append(path)

    return paths


def ids_for(mod_dir):
    ids = []
    seen = set()

    for info_path in mod_info_paths(mod_dir):
        try:
            lines = info_path.read_text(errors="replace").splitlines()
        except OSError:
            continue

        for line in lines:
            line = line.rstrip("\r")
            if "=" not in line:
                continue
            key, value = line.split("=", 1)
            if key.strip() == "id":
                value = value.strip()
                if value and value not in seen:
                    ids.append(value)
                    seen.add(value)

    return ids


def is_project_mod_dir(path):
    return (
        path.is_dir()
        and not path.is_symlink()
        and not path.name.startswith(".")
        and path.name not in skip_project_dirs
        and bool(ids_for(path))
    )


project_dirs = sorted(
    (path for path in source_root.iterdir() if is_project_mod_dir(path)),
    key=lambda path: path.name.lower(),
)

project_by_name = {path.name: path for path in project_dirs}
project_by_lower = defaultdict(list)
project_by_id = defaultdict(list)
for path in project_dirs:
    project_by_lower[path.name.lower()].append(path)
    for mod_id in ids_for(path):
        project_by_id[mod_id].append(path)

unique_project_ids = {
    mod_id
    for mod_id, paths in project_by_id.items()
    if len(paths) == 1
}


def direct_live_entries():
    return sorted(
        (
            path
            for path in dest_root.iterdir()
            if (path.is_dir() or path.is_symlink())
            and not path.name.startswith(".")
            and path.name not in {"home"}
        ),
        key=lambda path: path.name.lower(),
    )


def symlink_project_target(live_path):
    if not live_path.is_symlink():
        return None

    try:
        target = live_path.resolve(strict=True)
    except OSError:
        return None

    try:
        target.relative_to(source_root)
    except ValueError:
        return None

    if target.parent == source_root and target in project_dirs:
        return target

    return None


def project_for_live(live_path):
    linked_project = symlink_project_target(live_path)
    if linked_project is not None:
        return linked_project, "symlink-target"

    if live_path.name in project_by_name:
        return project_by_name[live_path.name], "exact-name"

    lower_matches = project_by_lower.get(live_path.name.lower(), [])
    if len(lower_matches) == 1:
        return lower_matches[0], "case-name"
    if len(lower_matches) > 1:
        fail(
            "ambiguous case-insensitive project folder match for "
            f"{live_path.name}: {', '.join(path.name for path in lower_matches)}"
        )

    live_ids = ids_for(live_path)
    id_matches = []
    seen = set()
    for mod_id in live_ids:
        if mod_id not in unique_project_ids:
            continue
        for path in project_by_id[mod_id]:
            if path not in seen:
                id_matches.append(path)
                seen.add(path)

    if len(id_matches) == 1:
        return id_matches[0], "mod-id"
    if len(id_matches) > 1:
        fail(
            "ambiguous mod id project match for "
            f"{live_path.name}: {', '.join(path.name for path in id_matches)}"
        )

    return None, None


def remove_live_entry(path):
    if dry_run:
        print(f"would remove {path}")
        return

    print(f"removing {path}")
    if path.is_symlink():
        path.unlink()
    else:
        shutil.rmtree(path)


def link_project(project_path):
    project_ids = ids_for(project_path)
    if not project_ids:
        fail(f"project mod has no readable mod.info id=: {project_path}")

    destination = dest_root / project_path.name
    matching_entries = []
    for live_path in direct_live_entries():
        if live_path == destination and live_path.is_symlink():
            target = symlink_project_target(live_path)
            if target == project_path:
                continue

        should_remove = live_path.name.lower() == project_path.name.lower()
        linked_target = symlink_project_target(live_path)
        if linked_target == project_path:
            should_remove = True

        if not should_remove:
            live_ids = ids_for(live_path)
            should_remove = any(
                mod_id in live_ids and mod_id in unique_project_ids
                for mod_id in project_ids
            )

        if should_remove:
            matching_entries.append(live_path)

    already_linked = (
        destination.is_symlink()
        and symlink_project_target(destination) == project_path
    )

    print(f"linking {project_path.name}")
    for live_path in matching_entries:
        if live_path == destination and already_linked:
            continue
        remove_live_entry(live_path)

    if already_linked and not matching_entries:
        print(f"already linked {destination} -> {project_path}")
        return

    if destination.exists() or destination.is_symlink():
        if destination.is_symlink() and symlink_project_target(destination) == project_path:
            print(f"already linked {destination} -> {project_path}")
            return
        remove_live_entry(destination)

    if dry_run:
        print(f"would link {destination} -> {project_path}")
    else:
        destination.symlink_to(project_path)
        print(f"linked {destination} -> {project_path}")


dest_root.mkdir(parents=True, exist_ok=True)

if dry_run:
    print("dry run: no files will be changed")

if mod_name:
    project_path = source_root / mod_name
    if not project_path.is_dir():
        fail(f"requested project mod does not exist: {project_path}")
    if not is_project_mod_dir(project_path):
        fail(f"requested project folder is not a readable Zomboid mod: {project_path}")
    selected_projects = [project_path]
else:
    selected = []
    seen = set()
    for live_path in direct_live_entries():
        project_path, _reason = project_for_live(live_path)
        if project_path is not None and project_path not in seen:
            selected.append(project_path)
            seen.add(project_path)
    selected_projects = selected

for project_path in selected_projects:
    link_project(project_path)

print(f"done: linked {len(selected_projects)} project-backed mod(s) into {dest_root}")
PY
