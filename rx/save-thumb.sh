#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Monitor & Save Gallo Thumbs
# @raycast.mode silent
# @raycast.packageName Media

# 1. Configuration
SOURCE_DIR="$HOME/Library/Caches/com.raycast.macos/ai-images"
TARGET_DIR="$HOME/rc-thumbs"
DB_PATH="$HOME/.openclaw/memory/main.sqlite"
mkdir -p "$TARGET_DIR"

# 2. Find the most recent image in the Raycast cache
# This finds the newest .png file in the cache directory
LATEST_IMAGE=$(ls -t "$SOURCE_DIR"/*.png 2>/dev/null | head -n 1)

if [ -z "$LATEST_IMAGE" ]; then
    osascript -e "display notification \"No recent Raycast AI images found.\" with title \"Gallo Save Failed\""
    exit 1
fi

# 3. Process & Rename
TIMESTAMP=$(date +'%Y-%b-%d_%H%M%S' | awk '{print toupper($0)}')
FILENAME="${TIMESTAMP}.png"

# Copy from cache to your thumbnails folder
cp "$LATEST_IMAGE" "$TARGET_DIR/$FILENAME"

# 4. THE MEMORY TIER: Log to OpenClaw SQLite
if [ -f "$TARGET_DIR/$FILENAME" ]; then
    sqlite3 "$DB_PATH" "INSERT INTO visual_logs (timestamp, prompt_text, model_used, file_path) VALUES ('$TIMESTAMP', 'Auto-detected from Raycast Cache', 'Raycast AI', '$TARGET_DIR/$FILENAME');"
    osascript -e "display notification \"Auto-saved: $FILENAME\" with title \"Gallo Visuals Logged\""
else
    osascript -e "display notification \"Failed to copy image from cache.\" with title \"Save Error\""
fi
