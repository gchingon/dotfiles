#!/usr/bin/env bash
#
# kitty-session.sh — Focus an existing kitty tab or launch a new session
#
# Usage: kitty-session.sh <session-name>
#        e.g. kitty-session.sh nvim
#
# Behaviour:
#   1. If a tab with matching title exists in any running kitty instance,
#      focus it and bring kitty to the foreground.
#   2. If kitty is running but no matching tab exists, parse the session
#      file and create a new tab with the same title/cwd/command.
#   3. If kitty isn't running at all, launch it with --session.

set -eu

SESSION="${1:?usage: kitty-session.sh <session-name>}"
SESSION_FILE="$HOME/.config/kitty/sessions/${SESSION}.kitty-session"

if [[ ! -f "$SESSION_FILE" ]]; then
  echo "kitty-session: no such session file: $SESSION_FILE" >&2
  exit 1
fi

# The kitty remote-control socket must match listen_on in kitty.conf.
export KITTY_LISTEN_ON="${KITTY_LISTEN_ON:-unix:/tmp/kitty}"

bring_kitty_forward() {
  if [[ "$(uname)" == "Darwin" ]]; then
    open -a kitty 2>/dev/null || true
  elif command -v wmctrl >/dev/null 2>&1; then
    wmctrl -xa kitty 2>/dev/null || true
  fi
}

# Parse a single directive from the session file.
session_get() {
  local key="$1"
  grep -m1 "^${key}" "$SESSION_FILE" 2>/dev/null | sed "s|^${key}[[:space:]]*||" || true
}

# --- Case 1: tab with matching title exists → focus it ------------------------
if kitten @ --to "$KITTY_LISTEN_ON" focus-tab --match "title:^${SESSION}$" >/dev/null 2>&1; then
  bring_kitty_forward
  exit 0
fi

# --- Case 2: kitty is running but the tab doesn't exist → create new tab ------
if kitten @ --to "$KITTY_LISTEN_ON" ls >/dev/null 2>&1; then
  tab_title=$(session_get new_tab)
  [[ -z "$tab_title" ]] && tab_title="$SESSION"

  cwd=$(session_get cd)
  cwd="${cwd/#\~/$HOME}"
  [[ -z "$cwd" ]] && cwd="$HOME"

  launch_cmd=$(session_get launch)
  [[ -z "$launch_cmd" ]] && launch_cmd="zsh"

  # shellcheck disable=SC2086
  kitten @ --to "$KITTY_LISTEN_ON" launch \
    --type=tab \
    --tab-title "$tab_title" \
    --cwd "$cwd" \
    $launch_cmd
  bring_kitty_forward
  exit 0
fi

# --- Case 3: kitty not running → launch with session file ---------------------
if [[ "$(uname)" == "Darwin" ]]; then
  open -a kitty --args --session "$SESSION_FILE"
else
  kitty --session "$SESSION_FILE" &
  disown || true
fi
