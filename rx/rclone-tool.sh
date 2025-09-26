#!/usr/bin/env bash
# ln ~/.config/rx/rclone-tool.sh ~/.local/bin/rctool
# A consolidated rclone utility script.

usage() {
  echo "Usage: $(basename "$0") <operation> <source> [destination]"
  echo
  echo "Operations:"
  echo "  copy  <source> <destination> - Copy files."
  echo "  move  <source> <destination> - Move files, deleting empty source dirs."
  echo "  dedupe-new <path>             - Deduplicate, keeping the newest file."
  echo "  dedupe-old <path>             - Deduplicate, keeping the oldest file."
  exit 1
}

[ "$#" -lt 2 ] && usage

OPERATION=$1
SOURCE=$2
DESTINATION=$3

BASE_OPTS=("-P" "--exclude-from" "$HOME/.config/rclone/clear" "--fast-list")

# Check if source exists for copy/move operations
if [[ "$OPERATION" == "copy" || "$OPERATION" == "move" ]]; then
  [ ! -e "$SOURCE" ] && {
    echo "Error: Source '$SOURCE' not found."
    exit 1
  }
  [ -z "$DESTINATION" ] && {
    echo "Error: Destination is required for $OPERATION."
    exit 1
  }
fi

case "$OPERATION" in
copy)
  rclone copy "${BASE_OPTS[@]}" "$SOURCE" "$DESTINATION"
  ;;
move)
  rclone move "${BASE_OPTS[@]}" --delete-empty-src-dirs "$SOURCE" "$DESTINATION"
  ;;
dedupe-new)
  rclone dedupe "${BASE_OPTS[@]}" --dedupe-mode newest "$SOURCE"
  ;;
dedupe-old)
  rclone dedupe "${BASE_OPTS[@]}" --dedupe-mode oldest "$SOURCE"
  ;;
*)
  echo "Error: Unknown operation '$OPERATION'"
  usage
  ;;
esac

echo "Rclone operation '$OPERATION' complete."
