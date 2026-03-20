#!/bin/zsh
# app-switch.sh — Toggle app: launch → focus → hide cycle
# Handles: not running, running+hidden, running+minimized, running+active
# Safe to call from kanata running as root — resolves real user via /dev/console
#
# Usage: app-switch.sh "Application Name"
# Link:  ln -s ~/.config/rx/app-switch.sh ~/.local/bin/app-switch

APP="$1"

if [[ -z "$APP" ]]; then
  echo "Usage: $0 \"Application Name\""
  exit 1
fi

# When kanata runs as root, $USER is root — get the actual console user
REAL_USER=$(stat -f "%Su" /dev/console)

# Run the AppleScript as the real user
/usr/bin/su - "$REAL_USER" -c "osascript" <<EOF
tell application "System Events"
  set appList to name of every process
  set isRunning to "$APP" is in appList
end tell

if isRunning then
  tell application "System Events"
    tell process "$APP"
      set isHidden to (value of attribute "AXHidden") as boolean
    end tell
  end tell

  if isHidden then
    -- App is hidden (Cmd+H) → unhide and activate
    tell application "$APP" to activate
  else
    tell application "$APP"
      -- Check if it has any windows
      if (count of windows) > 0 then
        tell application "System Events"
          tell process "$APP"
            set isFront to frontmost
            -- Check for minimized windows
            set minCount to count (windows whose miniaturized is true)
          end tell
        end tell
        if isFront then
          -- App is active and frontmost → hide it
          tell application "System Events"
            tell process "$APP"
              set visible to false
            end tell
          end tell
        else
          -- App is running but not frontmost → bring to front
          activate
        end if
      else
        -- No windows open (e.g. app running but all windows closed) → activate to open a new window
        activate
      end if
    end tell
  end if
else
  -- Not running → launch it
  tell application "$APP" to activate
end if
EOF