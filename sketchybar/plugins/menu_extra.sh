#!/usr/bin/env bash

target="$1"

if [[ -z "$target" ]]; then
  exit 1
fi

result="$(osascript - "$target" <<'APPLESCRIPT' 2>/dev/null || true
on run argv
  set wanted to item 1 of argv
  tell application "System Events"
    if exists process "Control Center" then
      tell process "Control Center"
        repeat with mb in menu bars
          repeat with mbi in menu bar items of mb
            set itemName to ""
            set itemDescription to ""
            try
              set itemName to name of mbi as text
            end try
            try
              set itemDescription to description of mbi as text
            end try
            if itemName contains wanted or itemDescription contains wanted then
              click mbi
              return "clicked"
            end if
          end repeat
        end repeat
      end tell
    end if
  end tell
  return "missing"
end run
APPLESCRIPT
)"

[[ "$result" == "clicked" ]]
