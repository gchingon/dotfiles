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
  sixth-tl sixth-tc sixth-tr sixth-bl sixth-bc sixth-br
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

cmd="${1:-}"
[[ -n "$cmd" ]] || { usage; exit 2; }

need_yabai

case "$cmd" in
  full)
    place 1:1:0:0:1:1
    ;;
  stack|float|bsp)
    yabai -m space --layout "$cmd"
    ;;
  left)         place 1:2:0:0:1:1 ;;
  right)        place 1:2:1:0:1:1 ;;
  top)          place 2:1:0:0:1:1 ;;
  bottom)       place 2:1:0:1:1:1 ;;
  tl)           place 2:2:0:0:1:1 ;;
  tr)           place 2:2:1:0:1:1 ;;
  bl)           place 2:2:0:1:1:1 ;;
  br)           place 2:2:1:1:1:1 ;;
  l60)          place 1:5:0:0:3:1 ;;
  r40)          place 1:5:3:0:2:1 ;;
  l40)          place 1:5:0:0:2:1 ;;
  r60)          place 1:5:2:0:3:1 ;;
  third-left)   place 1:3:0:0:1:1 ;;
  third-center) place 1:3:1:0:1:1 ;;
  third-right)  place 1:3:2:0:1:1 ;;
  sixth-tl)     place 2:3:0:0:1:1 ;;
  sixth-tc)     place 2:3:1:0:1:1 ;;
  sixth-tr)     place 2:3:2:0:1:1 ;;
  sixth-bl)     place 2:3:0:1:1:1 ;;
  sixth-bc)     place 2:3:1:1:1:1 ;;
  sixth-br)     place 2:3:2:1:1:1 ;;
  focus-left)   yabai -m window --focus west ;;
  focus-right)  yabai -m window --focus east ;;
  focus-up)     yabai -m window --focus north ;;
  focus-down)   yabai -m window --focus south ;;
  move-left)    yabai -m window --swap west || yabai -m window --display prev ;;
  move-right)   yabai -m window --swap east || yabai -m window --display next ;;
  move-up)      yabai -m window --swap north ;;
  move-down)    yabai -m window --swap south ;;
  display-prev) yabai -m window --display prev; yabai -m display --focus prev ;;
  display-next) yabai -m window --display next; yabai -m display --focus next ;;
  *)
    usage
    exit 2
    ;;
esac

id="$(focused_id)"
[[ -n "$id" ]] && yabai -m window --focus "$id" >/dev/null 2>&1 || true
