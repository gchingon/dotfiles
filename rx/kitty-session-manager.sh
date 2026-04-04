#!/bin/zsh
# kitty-session-manager.sh — Manage kitty sessions with consistent naming
# Usage: kitty-session <session-name>
#   docs     → ~/Documents
#   config   → ~/.config  
#   2mini    → ssh to 2mini
#   4mini    → ssh to 4mini

SESSION_NAME="$1"

# Ensure kitty remote control is available
if ! command -v kitten >/dev/null 2>&1; then
  echo "Error: kitten not found. Ensure kitty is installed."
  exit 1
fi

# Focus existing or create new tab
case "$SESSION_NAME" in
  docs|doc|documents)
    kitten @ focus-window --match title:Documents 2>/dev/null || \
      kitten @ launch --type=tab --tab-title=Documents --cwd="$HOME/Documents" zsh
    ;;
  config|cfg|dotfiles)
    kitten @ focus-window --match title:Config 2>/dev/null || \
      kitten @ launch --type=tab --tab-title=Config --cwd="$HOME/.config" zsh
    ;;
  2mini|mini2|2m)
    kitten @ focus-window --match title:2mini 2>/dev/null || \
      kitten @ launch --type=tab --tab-title=2mini ssh prescient@2mini
    ;;
  4mini|mini4|4m)
    kitten @ focus-window --match title:4mini 2>/dev/null || \
      kitten @ launch --type=tab --tab-title=4mini ssh prescient@4mini
    ;;
  *)
    echo "Unknown session: $SESSION_NAME"
    echo "Available: docs, config, 2mini, 4mini"
    exit 1
    ;;
esac
