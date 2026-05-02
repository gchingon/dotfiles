#!/usr/bin/env bash

DEVICE="$(networksetup -listallhardwareports 2>/dev/null | awk '/Hardware Port: Wi-Fi|Hardware Port: AirPort/{getline; print $2; exit}')"

if [[ -z "$DEVICE" ]]; then
  DEVICE="$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')"
fi

if [[ -z "$DEVICE" ]]; then
  sketchybar --set "$NAME" icon=󰤭 icon.color=0xff6b7280 label.drawing=off
  exit 0
fi

POWER="$(networksetup -getairportpower "$DEVICE" 2>/dev/null)"
if [[ "$POWER" == *": Off" ]]; then
  sketchybar --set "$NAME" icon=󰤭 icon.color=0xff6b7280 label.drawing=off
  exit 0
fi

STATUS="$(ifconfig "$DEVICE" 2>/dev/null | awk '/status:/{print $2; exit}')"
ADDR="$(ipconfig getifaddr "$DEVICE" 2>/dev/null || true)"

if [[ "$STATUS" == "active" || -n "$ADDR" ]]; then
  sketchybar --set "$NAME" icon=󰤨 icon.color=0xff2dcc82 label.drawing=off
else
  sketchybar --set "$NAME" icon=󰤭 icon.color=0xff6b7280 label.drawing=off
fi
