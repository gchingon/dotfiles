#!/usr/bin/env bash
set -euo pipefail

if command -v brew >/dev/null 2>&1; then
  brew services restart sketchybar >/dev/null 2>&1 && exit 0
  brew services start sketchybar >/dev/null 2>&1 && exit 0
fi

if pgrep -x sketchybar >/dev/null 2>&1; then
  sketchybar --reload >/dev/null 2>&1 && exit 0
fi

nohup sketchybar >/tmp/sketchybar.log 2>&1 &
