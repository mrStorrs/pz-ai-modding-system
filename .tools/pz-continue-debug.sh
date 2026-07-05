#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GAME_DIR="${PZ_GAME_DIR:-/home/cjstorrs/games/Project Zomboid Linux 42.19.0/game}"
GAME_SCRIPT="${PZ_GAME_SCRIPT:-${GAME_DIR}/projectzomboid.sh}"
CACHE_PARENT="${PZ_CACHE_PARENT:-${PROJECT_ROOT}/.runtime/zomboid-cache-parent}"
DIAGNOSTICS_ROOT="${PZ_DIAGNOSTICS_ROOT:-${PROJECT_ROOT}/.runtime/pz-diagnostics}"
LAUNCHER_LOG="${PZ_LAUNCHER_LOG:-${HOME}/Zomboid/projectzomboid.sh.log}"
WINDOW_PATTERN="${PZ_WINDOW_PATTERN:-Project Zomboid}"

DEBUG_ARG="${PZ_DEBUG_ARG:--debug}"
DIAGNOSTICS_ON_LOAD_TIMEOUT="${PZ_DIAGNOSTICS_ON_LOAD_TIMEOUT:-1}"
WINDOW_TIMEOUT_SECONDS="${PZ_WINDOW_TIMEOUT_SECONDS:-90}"
MAIN_MENU_TIMEOUT_SECONDS="${PZ_MAIN_MENU_TIMEOUT_SECONDS:-120}"
LOAD_TIMEOUT_SECONDS="${PZ_LOAD_TIMEOUT_SECONDS:-420}"
MENU_SETTLE_SECONDS="${PZ_MENU_SETTLE_SECONDS:-1}"
LOAD_SETTLE_SECONDS="${PZ_LOAD_SETTLE_SECONDS:-1}"
POST_LOAD_WAIT_SECONDS="${PZ_POST_LOAD_WAIT_SECONDS:-60}"
CLICK_REPEAT_SECONDS="${PZ_CLICK_REPEAT_SECONDS:-0.35}"

CONTINUE_X_PCT="${PZ_CONTINUE_X_PCT:-0.13}"
CONTINUE_Y_PCT="${PZ_CONTINUE_Y_PCT:-0.535}"
START_X_PCT="${PZ_START_X_PCT:-0.50}"
START_Y_PCT="${PZ_START_Y_PCT:-0.875}"

MAIN_MENU_MARKER="${PZ_MAIN_MENU_MARKER:-STATE: exit zombie.gameStates.TermsOfServiceState}"
GAME_LOADED_MARKER="${PZ_GAME_LOADED_MARKER:-game loading took}"

usage() {
  cat <<USAGE
Usage: ${SCRIPT_NAME} [--no-click] [--click-only] [--help] [extra-game-args...]

Starts Project Zomboid B42.19 in debug mode, clicks Continue, waits for the
save to finish loading, then clicks the "Click to Start" prompt.

Environment overrides:
  PZ_GAME_DIR                 ${GAME_DIR}
  PZ_CACHE_PARENT             ${CACHE_PARENT}
  PZ_DIAGNOSTICS_ROOT         ${DIAGNOSTICS_ROOT}
  PZ_DIAGNOSTICS_ON_LOAD_TIMEOUT ${DIAGNOSTICS_ON_LOAD_TIMEOUT}
  PZ_WINDOW_PATTERN           ${WINDOW_PATTERN}
  PZ_CONTINUE_X_PCT/Y_PCT     ${CONTINUE_X_PCT} / ${CONTINUE_Y_PCT}
  PZ_START_X_PCT/Y_PCT        ${START_X_PCT} / ${START_Y_PCT}
  PZ_POST_LOAD_WAIT_SECONDS   ${POST_LOAD_WAIT_SECONDS}
USAGE
}

log() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf '[%s] missing required command: %s\n' "$SCRIPT_NAME" "$1" >&2
    exit 1
  fi
}

optional_command() {
  command -v "$1" >/dev/null 2>&1
}

deactivate_screensaver() {
  if optional_command cinnamon-screensaver-command; then
    cinnamon-screensaver-command --deactivate >/dev/null 2>&1 || true
  fi
  if optional_command xdg-screensaver; then
    xdg-screensaver reset >/dev/null 2>&1 || true
  fi
}

find_java_pid() {
  local pid

  if optional_command jcmd; then
    pid="$(jcmd -l 2>/dev/null | awk '/ProjectZomboid|projectzomboid|zombie/ { print $1; exit }')"
    if [[ -n "$pid" ]]; then
      printf '%s\n' "$pid"
      return 0
    fi
  fi

  pid="$(pgrep -f 'ProjectZomboid64|ProjectZomboid32|java.*[Zz]omboid|zombie\\.' | head -n 1 || true)"
  if [[ -n "$pid" ]]; then
    printf '%s\n' "$pid"
    return 0
  fi

  return 1
}

latest_debug_log() {
  find /media/cjstorrs/windows/Users/cjsto/Zomboid/Logs -maxdepth 1 -type f -name '*_DebugLog.txt' -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | awk 'NR == 1 { $1=""; sub(/^ /, ""); print }'
}

capture_diagnostics() {
  local reason="$1"
  local stamp diag_dir java_pid debug_log

  if [[ "$DIAGNOSTICS_ON_LOAD_TIMEOUT" != "1" ]]; then
    log "diagnostics disabled; set PZ_DIAGNOSTICS_ON_LOAD_TIMEOUT=1 to enable"
    return 0
  fi

  stamp="$(date +%Y%m%d-%H%M%S)"
  diag_dir="${DIAGNOSTICS_ROOT}/${stamp}-${reason}"
  mkdir -p "$diag_dir"
  log "capturing diagnostics in $diag_dir"

  {
    date
    printf 'reason=%s\n' "$reason"
    printf 'game_pid=%s\n' "${GAME_PID:-}"
    printf 'launcher_log=%s\n' "$LAUNCHER_LOG"
    printf 'window_id=%s\n' "${WINDOW_ID:-}"
  } > "${diag_dir}/metadata.txt"

  pgrep -af 'ProjectZomboid|projectzomboid.sh|java.*[Zz]omboid|zombie\\.' > "${diag_dir}/processes.txt" 2>&1 || true
  cp "$LAUNCHER_LOG" "${diag_dir}/projectzomboid.sh.log" 2>/dev/null || true

  debug_log="$(latest_debug_log || true)"
  if [[ -n "$debug_log" ]]; then
    cp "$debug_log" "${diag_dir}/$(basename "$debug_log")" 2>/dev/null || true
    tail -n 400 "$debug_log" > "${diag_dir}/debug-log-tail.txt" 2>/dev/null || true
  fi

  java_pid="$(find_java_pid || true)"
  if [[ -z "$java_pid" ]]; then
    log "no Project Zomboid Java pid found for diagnostics"
    return 0
  fi

  log "diagnostic Java pid: $java_pid"
  ps -o pid,ppid,etime,pcpu,pmem,stat,cmd -p "$java_pid" > "${diag_dir}/ps.txt" 2>&1 || true

  if optional_command jcmd; then
    jcmd "$java_pid" Thread.print > "${diag_dir}/jcmd-thread-print.txt" 2>&1 || true
  fi
  if optional_command jstack; then
    jstack "$java_pid" > "${diag_dir}/jstack.txt" 2>&1 || true
  fi
  if optional_command lsof; then
    lsof -p "$java_pid" > "${diag_dir}/lsof.txt" 2>&1 || true
  fi
  if optional_command strace && optional_command timeout; then
    timeout 20 strace -f -p "$java_pid" -tt -s 200 -e trace=file,read,write,openat,newfstatat,getdents64 -o "${diag_dir}/strace-file.txt" > "${diag_dir}/strace.stdout.txt" 2>&1 || true
  fi
}

find_window() {
  local ids
  ids="$(xdotool search --onlyvisible --name "$WINDOW_PATTERN" 2>/dev/null || true)"
  if [[ -z "$ids" ]]; then
    ids="$(xdotool search --onlyvisible --class ProjectZomboid64 2>/dev/null || true)"
  fi
  if [[ -z "$ids" ]]; then
    ids="$(xdotool search --onlyvisible --class ProjectZomboid 2>/dev/null || true)"
  fi
  printf '%s\n' "$ids" | tail -n 1
}

wait_for_window() {
  local deadline=$((SECONDS + WINDOW_TIMEOUT_SECONDS))
  local window_id=""

  while (( SECONDS < deadline )); do
    window_id="$(find_window)"
    if [[ -n "$window_id" ]]; then
      printf '%s\n' "$window_id"
      return 0
    fi
    sleep 1
  done

  return 1
}

wait_for_log_marker() {
  local marker="$1"
  local timeout="$2"
  local label="$3"
  local deadline=$((SECONDS + timeout))

  while (( SECONDS < deadline )); do
    if [[ -f "$LAUNCHER_LOG" ]] && grep -Fq "$marker" "$LAUNCHER_LOG"; then
      log "$label marker reached"
      return 0
    fi
    if [[ -n "${GAME_PID:-}" ]] && ! kill -0 "$GAME_PID" 2>/dev/null; then
      log "game process exited before $label marker"
      return 1
    fi
    sleep 1
  done

  log "timed out waiting for $label marker: $marker"
  return 1
}

click_pct() {
  local window_id="$1"
  local x_pct="$2"
  local y_pct="$3"
  local label="$4"
  local geometry
  local x y width height click_x click_y

  geometry="$(xdotool getwindowgeometry --shell "$window_id")"
  eval "$geometry"
  x="$X"
  y="$Y"
  width="$WIDTH"
  height="$HEIGHT"

  click_x="$(awk -v x="$x" -v w="$width" -v p="$x_pct" 'BEGIN { printf "%d", x + (w * p) }')"
  click_y="$(awk -v y="$y" -v h="$height" -v p="$y_pct" 'BEGIN { printf "%d", y + (h * p) }')"

  log "clicking $label at ${click_x},${click_y} (${x_pct},${y_pct} of ${width}x${height})"
  deactivate_screensaver
  xdotool windowactivate --sync "$window_id"
  xdotool mousemove --sync "$click_x" "$click_y"
  xdotool mousedown 1
  sleep 0.25
  xdotool mouseup 1
}

click_twice() {
  click_pct "$@"
  sleep "$CLICK_REPEAT_SECONDS"
  click_pct "$@"
}

NO_CLICK=0
CLICK_ONLY=0
GAME_ARGS=()

while (($#)); do
  case "$1" in
    --no-click)
      NO_CLICK=1
      shift
      ;;
    --click-only)
      CLICK_ONLY=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      shift
      GAME_ARGS+=("$@")
      break
      ;;
    *)
      GAME_ARGS+=("$1")
      shift
      ;;
  esac
done

require_command xdotool
require_command awk

if [[ ! -x "$GAME_SCRIPT" ]]; then
  printf '[%s] game launcher is not executable: %s\n' "$SCRIPT_NAME" "$GAME_SCRIPT" >&2
  exit 1
fi

if (( CLICK_ONLY == 0 )) && pgrep -f 'ProjectZomboid(64|32)' >/dev/null 2>&1; then
  printf '[%s] Project Zomboid is already running. Use --click-only to drive the existing window.\n' "$SCRIPT_NAME" >&2
  exit 1
fi

if (( CLICK_ONLY == 0 )); then
  mkdir -p "$CACHE_PARENT" "$(dirname "$LAUNCHER_LOG")"
  : > "$LAUNCHER_LOG"

  log "starting Project Zomboid in debug mode"
  log "launcher: $GAME_SCRIPT"
  log "cache parent: $CACHE_PARENT"
  (
    cd "$GAME_DIR"
    env JAVA_TOOL_OPTIONS="-Ddeployment.user.cachedir=${CACHE_PARENT}" "$GAME_SCRIPT" "$DEBUG_ARG" "${GAME_ARGS[@]}"
  ) &
  GAME_PID=$!
  log "launcher pid: $GAME_PID"
else
  log "click-only mode: using the existing Project Zomboid window"
fi

if (( NO_CLICK == 1 )); then
  log "no-click mode enabled; leaving game running"
  exit 0
fi

WINDOW_ID="$(wait_for_window)" || {
  printf '[%s] timed out waiting for Project Zomboid window matching %q\n' "$SCRIPT_NAME" "$WINDOW_PATTERN" >&2
  exit 1
}
log "window id: $WINDOW_ID"
deactivate_screensaver

if (( CLICK_ONLY == 0 )); then
  wait_for_log_marker "$MAIN_MENU_MARKER" "$MAIN_MENU_TIMEOUT_SECONDS" "main menu" || true
  if [[ -n "${GAME_PID:-}" ]] && ! kill -0 "$GAME_PID" 2>/dev/null; then
    log "game process exited before Continue could be clicked"
    exit 1
  fi
  sleep "$MENU_SETTLE_SECONDS"
fi

click_twice "$WINDOW_ID" "$CONTINUE_X_PCT" "$CONTINUE_Y_PCT" "Continue"

if (( CLICK_ONLY == 0 )); then
  if ! wait_for_log_marker "$GAME_LOADED_MARKER" "$LOAD_TIMEOUT_SECONDS" "game loaded"; then
    capture_diagnostics "load-timeout"
    exit 1
  fi
  sleep "$LOAD_SETTLE_SECONDS"
fi

click_twice "$WINDOW_ID" "$START_X_PCT" "$START_Y_PCT" "Click to Start"

if [[ "$POST_LOAD_WAIT_SECONDS" != "0" ]]; then
  log "waiting ${POST_LOAD_WAIT_SECONDS}s after entering gameplay for delayed errors"
  sleep "$POST_LOAD_WAIT_SECONDS"
fi

log "Continue automation complete; game remains running for log inspection"
