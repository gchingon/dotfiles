#!/usr/bin/env bash

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  8[0-9]|9[0-9]|100)
    ICON=""
    COLOR="0xff2dcc82"
  ;;
  [5-7][0-9])
    ICON=""
    COLOR="0xffe0af68"
  ;;
  [3-4][0-9])
    ICON=""
    COLOR="0xffff9e64"
  ;;
  [1-2][0-9])
    ICON=""
    COLOR="0xfff7768e"
  ;;
  *)
    ICON=""
    COLOR="0xfff7768e"
esac

sketchybar --set "$NAME" icon.drawing=off label="${PERCENTAGE}%" label.color="$COLOR"
