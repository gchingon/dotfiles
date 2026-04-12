#!/usr/bin/env zsh
# calendar-next-meeting.sh
# Opens the URL from the next calendar event starting within 60 minutes.
# Falls back to just activating Calendar if no meeting found.
# Safe to call from kanata (runs as root, uses REAL_USER via /dev/console).

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: calendar-next-meeting"
  echo "Opens the URL from the next calendar event starting within 60 minutes."
  exit 0
fi

REAL_USER=$(stat -f "%Su" /dev/console)

/usr/bin/su - "$REAL_USER" -c "osascript" <<'EOF'
tell application "Calendar"
  activate
  set now to current date
  set cutoff to now + (60 * 60)
  set foundURL to ""
  
  repeat with cal in calendars
    repeat with ev in (every event of cal)
      try
        set evStart to start date of ev
        if evStart >= now and evStart <= cutoff then
          set evURL to url of ev
          if evURL is not missing value then
            if evURL is not "" then
              if foundURL is "" then
                set foundURL to evURL
              end if
            end if
          end if
        end if
      end try
    end repeat
  end repeat
  
  if foundURL is not "" then
    open location foundURL
  end if
end tell
EOF
