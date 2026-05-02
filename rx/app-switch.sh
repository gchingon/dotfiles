#!/usr/bin/env bash

# Filename: $RX/app-switch.sh

set -u

APP="${1:?Usage: app-switch.sh <app-name>}"

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  REAL_USER="$(stat -f "%Su" /dev/console)"
  REAL_UID="$(id -u "$REAL_USER")"
  exec launchctl asuser "$REAL_UID" sudo -u "$REAL_USER" "$0" "$@"
fi

activate_app() {
  open -a "$APP" >/dev/null 2>&1 || true
  osascript -e "tell application \"$APP\" to activate" >/dev/null 2>&1 || true
}

windows_json="$(yabai -m query --windows 2>/dev/null || true)"
if [[ -z "$windows_json" ]]; then
  activate_app
  exit 0
fi

ID="$(jq -r --arg app "$APP" '[.[] | select(.app==$app)][0].id // empty' <<<"$windows_json")"

if [[ -n "$ID" ]]; then
  yabai -m window --focus "$ID" >/dev/null 2>&1 || activate_app
  exit 0
fi

activate_app
for _ in {1..20}; do
  windows_json="$(yabai -m query --windows 2>/dev/null || true)"
  [[ -n "$windows_json" ]] || exit 0

  ID="$(jq -r --arg app "$APP" '[.[] | select(.app==$app)][0].id // empty' <<<"$windows_json")"
  if [[ -n "$ID" ]]; then
    yabai -m window --focus "$ID" >/dev/null 2>&1 || true
    break
  fi
  sleep 0.2
done
