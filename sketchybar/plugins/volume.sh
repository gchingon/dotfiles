#!/usr/bin/env bash

MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo false)"
THEME_FG="$(jq -r '
  input as $active
  | ($active.active // empty) as $slug
  | .themes[$slug].terminal.foreground // "#d8dee9"
' "$HOME/.config/colors/colors.json" "$HOME/.config/colors/active_theme.json" 2>/dev/null | sed 's/^#/0xff/')"
[[ -n "$THEME_FG" ]] || THEME_FG="0xffd8dee9"

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
else
  VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo 0)"
fi

if [[ "$MUTED" == "true" ]]; then
  ICON="󰖁"
  COLOR="0xff6b7280"
else
  COLOR="$THEME_FG"
  case "$VOLUME" in
    [6-9][0-9]|100) ICON="󰕾" ;;
    [3-5][0-9]) ICON="󰖀" ;;
    [1-9]|[1-2][0-9]) ICON="󰕿" ;;
    *) ICON="󰖁" ;;
  esac
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$VOLUME%" label.color="$COLOR"
