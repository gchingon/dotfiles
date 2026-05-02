#!/usr/bin/env bash

MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo false)"

if [[ "$MUTED" == "true" ]]; then
  osascript -e 'set volume without output muted' >/dev/null 2>&1
else
  osascript -e 'set volume with output muted' >/dev/null 2>&1
fi

SENDER=mouse.clicked NAME=volume "${HOME}/.config/sketchybar/plugins/volume.sh"
