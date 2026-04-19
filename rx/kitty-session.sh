#!/usr/bin/env zsh
# kitty-session.sh — focus an existing kitty session window or launch a new one
#
# Usage: kitty-session.sh <session-name>
#   Looks up: ~/.config/kitty/sessions/<session-name>.kitty-session
#
# Matching strategy:
#   Each session's launch line carries --env SESSION_NAME=<name>.
#   We match with focus-window --match "env:SESSION_NAME=<name>".
#   This is immune to title changes from the shell or running programs.
#
# Socket discovery:
#   kitty appends PID to listen_on: unix:/tmp/kitty → unix:/tmp/kitty-<PID>.
#   We iterate all running kitty PIDs to find the right socket.
#
# Runs as root (kanata LaunchDaemon) — all paths are hardcoded.

SESSION_NAME="${1:?Usage: kitty-session.sh <session-name>}"

REAL_HOME="/Users/schingon"
SESSIONS_DIR="$REAL_HOME/.config/kitty/sessions"
SESSION_FILE="$SESSIONS_DIR/${SESSION_NAME}.kitty-session"
KITTEN="/Applications/kitty.app/Contents/MacOS/kitten"

# ── sanity checks ──────────────────────────────────────────────────────────
if [[ ! -x "$KITTEN" ]]; then
    echo "kitty-session: kitten not found at $KITTEN" >&2
    open -a kitty
    exit 1
fi

if [[ ! -f "$SESSION_FILE" ]]; then
    echo "kitty-session: session file not found: $SESSION_FILE" >&2
    open -a kitty
    exit 1
fi

# ── search all kitty instances for a window with our session var ───────────
# Each session window is tagged: launch --env SESSION_NAME=<name>
# focus-window also raises the containing OS window automatically.
FOCUSED=false
for KITTY_PID in $(pgrep -x kitty); do
    KITTY_SOCKET="unix:/tmp/kitty-${KITTY_PID}"
    "$KITTEN" @ --to "$KITTY_SOCKET" ls &>/dev/null 2>&1 || continue
    if "$KITTEN" @ --to "$KITTY_SOCKET" \
            focus-window --match "env:SESSION_NAME=${SESSION_NAME}" 2>/dev/null; then
        FOCUSED=true
        break
    fi
done

# ── launch if not found ───────────────────────────────────────────────────
if [[ "$FOCUSED" == false ]]; then
    open -na kitty --args --session "$SESSION_FILE"
fi
