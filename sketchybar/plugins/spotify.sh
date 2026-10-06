#!/usr/bin/env bash
source "$CONFIG_DIR/colors.sh"

# Hide both the marquee and the next button together.
hide() { sketchybar --set spotify drawing=off --set spotify_next drawing=off; exit 0; }

# Single atomic AppleScript call: the running-check and the queries happen in
# one osascript invocation, so there's no gap between a bash-level pgrep and
# a later `tell application "Spotify"` for the app to finish quitting in —
# that gap used to let a straggling notification relaunch Spotify right after
# quitting it, since `tell application` auto-launches a non-running target.
INFO="$(osascript <<'APPLESCRIPT' 2>/dev/null
tell application "System Events"
	if not (exists process "Spotify") then return ""
end tell
tell application "Spotify"
	set st to player state as string
	if st is not "playing" and st is not "paused" then return ""
	set trk to name of current track
	set art to artist of current track
end tell
return st & linefeed & trk & linefeed & art
APPLESCRIPT
)"
[ -n "$INFO" ] || hide

STATE="$(sed -n '1p' <<<"$INFO")"
TRACK="$(sed -n '2p' <<<"$INFO")"
ARTIST="$(sed -n '3p' <<<"$INFO")"
[ -n "$TRACK" ] || hide

if [ -n "$ARTIST" ]; then
  TEXT="$ARTIST - $TRACK"
else
  TEXT="$TRACK"
fi

# Bright + green when playing, dimmed when paused.
if [ "$STATE" = "playing" ]; then
  ICON_COLOR="$GREEN"; LABEL_COLOR="$FG"
else
  ICON_COLOR="$COMMENT"; LABEL_COLOR="$COMMENT"
fi

sketchybar --set spotify drawing=on icon="" icon.color="$ICON_COLOR" \
                         label="$TEXT" label.color="$LABEL_COLOR" \
           --set spotify_next drawing=on icon.color="$LABEL_COLOR"
