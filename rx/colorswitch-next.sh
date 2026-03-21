#!/usr/bin/env bash
THEME_JSON="${HOME}/.config/colors/colors.json"
ACTIVE_FILE="${HOME}/.config/colors/active_theme.json"
COLORSELECTOR="${HOME}/.local/bin/colorswitch"
themes=($(jq -r '.themes | keys[]' "$THEME_JSON"))
current=$(jq -r '.active' "$ACTIVE_FILE" 2>/dev/null || echo "${themes[0]}")
for i in "${!themes[@]}"; do
  [[ "${themes[$i]}" == "$current" ]] && idx=$i && break
done
next="${themes[$(( (idx + 1) % ${#themes[@]} ))]}"
"$COLORSELECTOR" "$next"
