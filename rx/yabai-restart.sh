#!/usr/bin/env zsh
# yabai-restart.sh — restart the yabai service (reloads yabairc), triggered
# from kanata via lalt+down+[ (physical keys; that's "/" in Dvorak output).

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  real_user="$(stat -f "%Su" /dev/console)"
  real_uid="$(id -u "$real_user")"
  exec launchctl asuser "$real_uid" sudo -u "$real_user" "$0" "$@"
fi

# `yabai --restart-service` hardcodes the label com.asmvik.yabai, which got
# into a broken state in launchd's database on this machine — every load
# attempt fails regardless of plist content. The service now runs under
# com.schingon.yabai instead (same file path yabai expects, different
# internal Label — see the comment in the plist itself). launchctl kickstart
# restarts an already-loaded service by label and works fine.
launchctl kickstart -k "gui/$(id -u)/com.schingon.yabai"
