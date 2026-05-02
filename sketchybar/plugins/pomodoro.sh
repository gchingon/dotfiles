#!/usr/bin/env bash
set -euo pipefail

ITEM="itsycal"
PREFIX_ITEM="date.prefix"
DAY_ITEM="date.day"
STATE_DIR="${TMPDIR:-/tmp}/sketchybar-pomodoro-${USER}"
STATE_FILE="$STATE_DIR/state"
PID_FILE="$STATE_DIR/pid"
POPUP_PID_FILE="$STATE_DIR/popup-pid"

WORK_SECONDS=1500
BREAK_SECONDS=300
WHITE="0xffd8dee9"
GREEN="0xff2dcc82"
YELLOW="0xffe0af68"
RED="0xfff7768e"
MUTED="0xff6b7280"

theme_color() {
  local key="$1"
  local fallback="$2"
  local color_json="${HOME}/.config/colors/colors.json"
  local active_json="${HOME}/.config/colors/active_theme.json"
  local slug value

  slug="$(jq -r '.active // empty' "$active_json" 2>/dev/null || true)"
  value="$(jq -r --arg t "$slug" --arg k "$key" '.themes[$t].terminal[$k] // empty' "$color_json" 2>/dev/null || true)"

  if [[ "$value" =~ ^#[0-9a-fA-F]{6}$ ]]; then
    printf '0xff%s\n' "${value#\#}"
  else
    printf '%s\n' "$fallback"
  fi
}

THEME_FG="$(theme_color foreground "$WHITE")"
THEME_RED="$(theme_color color1 "$RED")"

mkdir -p "$STATE_DIR"

read_state() {
  MODE="idle"
  STATUS="idle"
  DURATION="$WORK_SECONDS"
  REMAINING=0
  END_EPOCH=0

  if [[ -f "$STATE_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE"
  fi
}

write_state() {
  cat >"$STATE_FILE" <<EOF
MODE="${MODE}"
STATUS="${STATUS}"
DURATION="${DURATION}"
REMAINING="${REMAINING}"
END_EPOCH="${END_EPOCH}"
EOF
}

kill_loop() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid="$(cat "$PID_FILE" 2>/dev/null || true)"
    if [[ -n "$pid" ]]; then
      kill "$pid" >/dev/null 2>&1 || true
    fi
    rm -f "$PID_FILE"
  fi
}

kill_popup_timer() {
  if [[ -f "$POPUP_PID_FILE" ]]; then
    local pid
    pid="$(cat "$POPUP_PID_FILE" 2>/dev/null || true)"
    if [[ -n "$pid" ]]; then
      kill "$pid" >/dev/null 2>&1 || true
    fi
    rm -f "$POPUP_PID_FILE"
  fi
}

close_popup_later() {
  kill_popup_timer
  ( sleep 5; sketchybar --set "$ITEM" popup.drawing=off >/dev/null 2>&1 ) &
  echo $! >"$POPUP_PID_FILE"
}

format_seconds() {
  local seconds="$1"
  printf "%02d:%02d" "$((seconds / 60))" "$((seconds % 60))"
}

render() {
  read_state
  local label color prefix remaining

  if [[ "$STATUS" == "idle" ]]; then
    sketchybar \
      --set "$PREFIX_ITEM" label="$(date '+%a')" label.color="$THEME_FG" label.drawing=on \
      --set "$DAY_ITEM" label="$(date '+%d')" label.color="$THEME_RED" label.drawing=on \
      --set "$ITEM" label="$(date '+%b %Y %H:%M')" label.color="$THEME_FG" label.padding_left=0 label.drawing=on
    return
  fi

  sketchybar \
    --set "$PREFIX_ITEM" label.drawing=off \
    --set "$DAY_ITEM" label.drawing=off

  if [[ "$STATUS" == "running" ]]; then
    remaining="$((END_EPOCH - $(date +%s)))"
    (( remaining < 0 )) && remaining=0
  else
    remaining="$REMAINING"
  fi

  case "$MODE" in
    work)
      prefix="Focus"
      color="$GREEN"
      ;;
    break)
      prefix="Break"
      color="$YELLOW"
      ;;
    *)
      prefix="Timer"
      color="$THEME_FG"
      ;;
  esac

  if [[ "$STATUS" == "paused" ]]; then
    color="$MUTED"
  elif (( remaining <= 60 )); then
    color="$RED"
  fi

  label="$prefix $(format_seconds "$remaining")"
  [[ "$STATUS" == "paused" ]] && label="$label paused"
  sketchybar --set "$ITEM" label="$label" label.color="$color"
}

start_loop() {
  kill_loop
  nohup "$0" loop >/dev/null 2>&1 &
  echo $! >"$PID_FILE"
}

start_timer() {
  MODE="$1"
  DURATION="$2"
  STATUS="running"
  REMAINING="$DURATION"
  END_EPOCH="$(($(date +%s) + DURATION))"
  write_state
  render
  start_loop
}

pause_timer() {
  read_state
  [[ "$STATUS" != "running" ]] && return 0
  REMAINING="$((END_EPOCH - $(date +%s)))"
  (( REMAINING < 0 )) && REMAINING=0
  STATUS="paused"
  END_EPOCH=0
  write_state
  kill_loop
  render
}

resume_timer() {
  read_state
  [[ "$STATUS" != "paused" ]] && return 0
  STATUS="running"
  END_EPOCH="$(($(date +%s) + REMAINING))"
  write_state
  render
  start_loop
}

pause_resume() {
  read_state
  case "$STATUS" in
    running) pause_timer ;;
    paused) resume_timer ;;
  esac
}

stop_timer() {
  kill_loop
  MODE="idle"
  STATUS="idle"
  DURATION="$WORK_SECONDS"
  REMAINING=0
  END_EPOCH=0
  write_state
  render
}

reset_timer() {
  kill_loop
  MODE="work"
  STATUS="paused"
  DURATION="$WORK_SECONDS"
  REMAINING="$WORK_SECONDS"
  END_EPOCH=0
  write_state
  render
}

finish_current() {
  read_state
  if [[ "$MODE" == "work" ]]; then
    afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 || true
    start_timer break "$BREAK_SECONDS"
  else
    afplay /System/Library/Sounds/Funk.aiff >/dev/null 2>&1 || true
    stop_timer
  fi
}

loop() {
  while true; do
    read_state
    [[ "$STATUS" != "running" ]] && exit 0

    local remaining
    remaining="$((END_EPOCH - $(date +%s)))"
    if (( remaining <= 0 )); then
      finish_current
      exit 0
    fi

    render
    sleep 1
  done
}

case "${1:-update}" in
  popup)
    sketchybar --set "$ITEM" popup.drawing=toggle
    close_popup_later
    ;;
  start)
    kill_popup_timer
    start_timer work "$WORK_SECONDS"
    ;;
  break)
    kill_popup_timer
    start_timer break "$BREAK_SECONDS"
    ;;
  pause)
    kill_popup_timer
    pause_resume
    ;;
  stop)
    kill_popup_timer
    stop_timer
    ;;
  reset)
    kill_popup_timer
    reset_timer
    ;;
  update)
    render
    ;;
  loop)
    loop
    ;;
esac
