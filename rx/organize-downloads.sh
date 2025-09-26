#!/usr/bin/env bash
# ln ~/.config/rx/organize-downloads.sh ~/.local/bin/orgdn
# Moves files from the Downloads directory to organized locations.

# Centralized configuration for paths and extensions
SOURCE_DIR="$HOME/Downloads"
BACKUP_DIR="/Volumes/armor" # Or another default

declare -A CATEGORIES
CATEGORIES[iso]="iso dmg pkg:$BACKUP_DIR/iso/"
CATEGORIES[nix]="iso:$BACKUP_DIR/iso/nix/"
CATEGORIES[images]="heic jpg jpeg png webp:$HOME/Pictures/"
CATEGORIES[ipa]="ipa:$BACKUP_DIR/iso/ipa/"

usage() {
  echo "Usage: $(basename "$0") <category>"
  echo "Available categories: ${!CATEGORIES[@]}"
  exit 1
}

CATEGORY=$1
[ -z "$CATEGORY" ] && usage

CONFIG=${CATEGORIES[$CATEGORY]}
[ -z "$CONFIG" ] && echo "Error: Unknown category '$CATEGORY'" && usage

# Split config into extensions and destination
EXTENSIONS_STRING=$(echo "$CONFIG" | cut -d':' -f1)
DESTINATION=$(echo "$CONFIG" | cut -d':' -f2)

# Convert comma-separated string to array
IFS=',' read -r -a EXTENSIONS <<<"$EXTENSIONS_STRING"

if [ ! -d "$DESTINATION" ]; then
  echo "Warning: Destination '$DESTINATION' not found. Please ensure it is mounted/available."
  exit 1
fi

echo "Organizing category '$CATEGORY'. Moving files to '$DESTINATION'."

for ext in "${EXTENSIONS[@]}"; do
  # Use nullglob to avoid errors if no files match
  shopt -s nullglob
  for file in "$SOURCE_DIR"/*."$ext"; do
    mv -v "$file" "$DESTINATION"
  done
  shopt -u nullglob
done

echo "Organization for '$CATEGORY' complete."
