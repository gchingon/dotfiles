#!/usr/bin/env bash
# Uses AppleScript to send the reload shortcut (Cmd+Shift+,) to Ghostty.

osascript <<EOF
tell application "System Events"
  tell process "Ghostty"
    keystroke "," using {command down, shift down}
  end tell
end tell
EOF

echo "Reload command sent to Ghostty."
