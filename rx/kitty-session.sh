#!/usr/bin/env bash
#
# kitty-session.sh — Focus an existing kitty tab or launch a new session
#
# Usage: kitty-session.sh <session-name>
#        e.g. kitty-session.sh nvim
#
# Behaviour:
#   1. Parse the session file for the ACTUAL tab title (may differ from filename).
#   2. If a tab with that title exists → focus it, bring kitty forward.
#   3. If kitty is running but no matching tab → create a new tab from
#      the session file's directives (title, cwd, command).
#   4. If kitty isn't running at all → launch kitty with --session.
#
# NOTE: kanata runs as root (LaunchDaemon). This script resolves the real
#       console user's home so paths work regardless of $HOME.

set -eu

SESSION="${1:?usage: kitty-session.sh <session-name>}"

# ---------------------------------------------------------------------------
# Resolve real user's home — kanata LaunchDaemon runs as root so $HOME is
# /var/root, but kitty/sessions live under the console user's home.
# ---------------------------------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
  REAL_USER="$(stat -f '%Su' /dev/console 2>/dev/null || echo "$USER")"
  REAL_HOME="$(dscl . -read "/Users/$REAL_USER" NFSHomeDirectory 2>/dev/null | awk '{print $2}')"
  [[ -z "$REAL_HOME" ]] && REAL_HOME="/Users/$REAL_USER"
else
  REAL_HOME="${HOME}"
fi

SESSION_DIR="${REAL_HOME}/.config/kitty/sessions"
SESSION_FILE="${SESSION_DIR}/${SESSION}.kitty-session"

if [[ ! -f "$SESSION_FILE" ]]; then
  echo "kitty-session: no such session file: $SESSION_FILE" >&2
  exit 1
fi

# The kitty remote-control socket must match listen_on in kitty.conf.
KITTY_SOCK="unix:/tmp/kitty"

# ---------------------------------------------------------------------------
# Parse the session file for tab title, working directory, and launch command.
# The tab title in the session file is the REAL title kitty uses (may differ
# from the filename, e.g. podcast.kitty-session → tab "GCpod").
# ---------------------------------------------------------------------------
TAB_TITLE="$(grep -m1 '^new_tab' "$SESSION_FILE" 2>/dev/null | sed 's/^new_tab[[:space:]]*//')"
[[ -z "$TAB_TITLE" ]] && TAB_TITLE="$SESSION"

CWD="$(grep -m1 '^cd ' "$SESSION_FILE" 2>/dev/null | sed 's/^cd[[:space:]]*//')"
CWD="${CWD/#\~/$REAL_HOME}"
[[ -z "$CWD" ]] && CWD="$REAL_HOME"

LAUNCH_CMD="$(grep -m1 '^launch' "$SESSION_FILE" 2>/dev/null | sed 's/^launch[[:space:]]*//')"
[[ -z "$LAUNCH_CMD" ]] && LAUNCH_CMD="zsh"

bring_kitty_forward() {
  if [[ "$(uname)" == "Darwin" ]]; then
    open -a kitty 2>/dev/null || true
  elif command -v wmctrl >/dev/null 2>&1; then
    wmctrl -xa kitty 2>/dev/null || true
  fi
}

# ---------------------------------------------------------------------------
# Case 1: tab with matching title exists → focus it
# ---------------------------------------------------------------------------
if kitten @ --to "$KITTY_SOCK" focus-tab --match "title:^${TAB_TITLE}$" >/dev/null 2>&1; then
  bring_kitty_forward
  exit 0
fi

# ---------------------------------------------------------------------------
# Case 2: kitty running but tab doesn't exist → create new tab
# ---------------------------------------------------------------------------
if kitten @ --to "$KITTY_SOCK" ls >/dev/null 2>&1; then
  # shellcheck disable=SC2086
  kitten @ --to "$KITTY_SOCK" launch \
    --type=tab \
    --tab-title "$TAB_TITLE" \
    --cwd "$CWD" \
    $LAUNCH_CMD
  bring_kitty_forward
  exit 0
fi

# ---------------------------------------------------------------------------
# Case 3: kitty not running → launch with session file
# ---------------------------------------------------------------------------
if [[ "$(uname)" == "Darwin" ]]; then
  open -a kitty --args --session "$SESSION_FILE"
else
  kitty --session "$SESSION_FILE" &
  disown || true
fi
