#!/usr/bin/env zsh
# yabai-layout.sh - named window placements for yabai

set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  real_user="$(stat -f "%Su" /dev/console)"
  real_uid="$(id -u "$real_user")"
  exec launchctl asuser "$real_uid" sudo -u "$real_user" "$0" "$@"
fi

usage() {
  cat <<'EOF'
Usage: yabai-layout.sh <command>

Layouts:
  full stack float bsp
  left right top bottom
  tl tr bl br
  l60 r40 l40 r60
  third-left third-center third-right
  quarter-top quarter-second quarter-third quarter-bottom
  third-top third-middle third-bottom
  sixth-tl sixth-tc sixth-tr sixth-bl sixth-bc sixth-br

Cycles:
  cycle-left cycle-right
  cycle-top cycle-bottom cycle-thirds

  focus-left focus-right focus-up focus-down
  move-left move-right move-up move-down
  display-prev display-next
EOF
}

need_yabai() {
  command -v yabai >/dev/null 2>&1 || {
    echo "yabai-layout: yabai not found" >&2
    exit 1
  }
}

focused_id() {
  yabai -m query --windows --window 2>/dev/null | jq -r '.id // empty'
}

ensure_float() {
  local floating
  floating="$(yabai -m query --windows --window | jq -r '.["is-floating"]')"
  [[ "$floating" == "true" ]] || yabai -m window --toggle float
}

place() {
  ensure_float
  yabai -m window --grid "$1"
}

now_ms() {
  zmodload zsh/datetime 2>/dev/null || true
  if [[ -n "${EPOCHREALTIME:-}" ]]; then
    printf "%.0f\n" $(( EPOCHREALTIME * 1000 ))
  else
    printf "%d\n" $(( $(date +%s) * 1000 ))
  fi
}

run_layout() {
  local layout="$1"

  case "$layout" in
    full)
      place 1:1:0:0:1:1
      ;;
    stack|float|bsp)
      yabai -m space --layout "$layout"
      ;;
    left)           place 1:2:0:0:1:1 ;;
    right)          place 1:2:1:0:1:1 ;;
    top)            place 2:1:0:0:1:1 ;;
    bottom)         place 2:1:0:1:1:1 ;;
    tl)             place 2:2:0:0:1:1 ;;
    tr)             place 2:2:1:0:1:1 ;;
    bl)             place 2:2:0:1:1:1 ;;
    br)             place 2:2:1:1:1:1 ;;
    l60)            place 1:5:0:0:3:1 ;;
    r40)            place 1:5:3:0:2:1 ;;
    l40)            place 1:5:0:0:2:1 ;;
    r60)            place 1:5:2:0:3:1 ;;
    third-left)     place 1:3:0:0:1:1 ;;
    third-center)   place 1:3:1:0:1:1 ;;
    third-right)    place 1:3:2:0:1:1 ;;
    # Ultrawide fractions (2mini/4mini hosts — see cycle-left/cycle-right below)
    l2-3)           place 1:3:0:0:2:1 ;;
    r2-3)           place 1:3:1:0:2:1 ;;
    l1-3)           place 1:3:0:0:1:1 ;;
    r1-3)           place 1:3:2:0:1:1 ;;
    l1-4)           place 1:4:0:0:1:1 ;;
    r1-4)           place 1:4:3:0:1:1 ;;
    quarter-top)    place 4:1:0:0:1:1 ;;
    quarter-second) place 4:1:0:1:1:1 ;;
    quarter-third)  place 4:1:0:2:1:1 ;;
    quarter-bottom) place 4:1:0:3:1:1 ;;
    third-top)      place 3:1:0:0:1:1 ;;
    third-middle)   place 3:1:0:1:1:1 ;;
    third-bottom)   place 3:1:0:2:1:1 ;;
    sixth-tl)       place 2:3:0:0:1:1 ;;
    sixth-tc)       place 2:3:1:0:1:1 ;;
    sixth-tr)       place 2:3:2:0:1:1 ;;
    sixth-bl)       place 2:3:0:1:1:1 ;;
    sixth-bc)       place 2:3:1:1:1:1 ;;
    sixth-br)       place 2:3:2:1:1:1 ;;
    focus-left)     yabai -m window --focus west ;;
    focus-right)    yabai -m window --focus east ;;
    focus-up)       yabai -m window --focus north ;;
    focus-down)     yabai -m window --focus south ;;
    move-left)      yabai -m window --swap west || yabai -m window --display prev ;;
    move-right)     yabai -m window --swap east || yabai -m window --display next ;;
    move-up)        yabai -m window --swap north ;;
    move-down)      yabai -m window --swap south ;;
    display-prev)   yabai -m window --display prev; yabai -m display --focus prev ;;
    display-next)   yabai -m window --display next; yabai -m display --focus next ;;
    *)
      return 1
      ;;
  esac
}

cycle_layout() {
  local timeout_ms="$1"
  local cycle_key="$2"
  shift 2

  local -a layouts=("$@")
  local state_dir="/tmp/yabai-layout-cycles"
  local state_file="$state_dir/window-${focused_window_id:-unknown}"
  local current_ms last_key last_index last_ms next_index

  mkdir -p "$state_dir"
  current_ms="$(now_ms)"
  last_key=""
  last_index=-1
  last_ms=0

  if [[ -r "$state_file" ]]; then
    read -r last_key last_index last_ms < "$state_file" || true
  fi

  if [[ "$last_key" == "$cycle_key" && $(( current_ms - last_ms )) -le "$timeout_ms" ]]; then
    next_index=$(( (last_index + 1) % ${#layouts[@]} ))
  else
    next_index=0
  fi

  run_layout "${layouts[$(( next_index + 1 ))]}"
  printf "%s %d %s\n" "$cycle_key" "$next_index" "$current_ms" > "$state_file"
}

cmd="${1:-}"
[[ -n "$cmd" ]] || { usage; exit 2; }

need_yabai
focused_window_id="$(focused_id)"

# Ultrawide monitors (2mini/4mini hosts) get finer-grained halves: repeated
# presses cycle half -> 2/3 -> 1/3 -> 1/4 -> half, instead of the laptop's
# half -> 60% -> 40%.
host="$(hostname -s 2>/dev/null || hostname)"
case "$host" in
  *2mini*|*4mini*) is_ultrawide_host=1 ;;
  *)                is_ultrawide_host=0 ;;
esac

case "$cmd" in
  cycle-left)
    if [[ "$is_ultrawide_host" -eq 1 ]]; then
      cycle_layout 1200 cycle-left left l2-3 l1-3 l1-4
    else
      cycle_layout 1200 cycle-left left l60 l40
    fi
    ;;
  cycle-right)
    if [[ "$is_ultrawide_host" -eq 1 ]]; then
      cycle_layout 1200 cycle-right right r2-3 r1-3 r1-4
    else
      cycle_layout 1200 cycle-right right r60 r40
    fi
    ;;
  cycle-top)    cycle_layout 1800 cycle-top top quarter-top quarter-second ;;
  cycle-bottom) cycle_layout 1800 cycle-bottom bottom quarter-third quarter-bottom ;;
  cycle-thirds) cycle_layout 1800 cycle-thirds third-top third-middle third-bottom ;;
  *)
    run_layout "$cmd" || { usage; exit 2; }
    ;;
esac

[[ -n "$focused_window_id" ]] && yabai -m window --focus "$focused_window_id" >/dev/null 2>&1 || true
