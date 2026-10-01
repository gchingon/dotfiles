#!/usr/bin/env zsh
# system-toggle.sh — system/power actions triggered from kanata's toggles layer
#
# Kept as a real script (not inline kanata cmd strings) because kanata's own
# string syntax doesn't support escaped double-quotes the way most shells do
# (embedding them broke silently — see aliases-toggles.kbd history). Plain
# shell quoting here just works.
#
# osascript/System Events actions need Accessibility + Automation permission
# granted to this script's caller — if these don't work, check System
# Settings > Privacy & Security > Accessibility / Automation.

set -u
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

usage() {
  cat <<'EOF'
Usage: system-toggle.sh <command>
  lock zoom restart shutdown logout dnd trash
EOF
}

cmd="${1:-}"
[[ -n "$cmd" ]] || { usage; exit 2; }

case "$cmd" in
  lock)
    osascript -e 'tell application "System Events" to keystroke "q" using {control down, command down}'
    ;;
  zoom)
    osascript -e 'tell application "System Events" to key code 28 using {option down, command down}'
    ;;
  restart)
    osascript -e 'tell application "System Events" to restart'
    ;;
  shutdown)
    osascript -e 'tell application "System Events" to shut down'
    ;;
  logout)
    osascript -e 'tell application "System Events" to log out'
    ;;
  dnd)
    shortcuts run 'Toggle Do Not Disturb'
    ;;
  trash)
    osascript -e 'tell application "Finder" to empty trash'
    ;;
  *)
    usage
    exit 2
    ;;
esac
