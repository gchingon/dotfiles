#!/bin/zsh

# app-switch.sh - Toggle app: open if not running, focus if hidden, hide if active
# Usage: app-switch.sh "Application Name"
# ln ~/.config/rx/app-switch.sh ~/.local/bin/app-switch

APP="$1"

if [[ -z "$APP" ]]; then
  echo "Usage: $0 \"Application Name\""
  exit 1
fi

# Use AppleScript to check app status and toggle
osascript <<EOF
tell application "System Events"
  set appList to (name of processes)
  set isRunning to "$APP" is in appList
end tell

if isRunning then
  tell application "$APP"
    set isActive to (frontmost of it)
    if isActive then
      -- App is active → hide it using Command+H (universal hide shortcut)
      tell application "System Events"
        keystroke "h" using command down
      end tell
    else
      -- App is running but not active → activate it
      activate
    end if
  end tell
else
  -- App is not running → launch and activate it
  tell application "$APP"
    activate
  end tell
end if
EOF
