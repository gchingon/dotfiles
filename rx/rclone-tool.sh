#!/usr/bin/env bash
set -euo pipefail
# ln ~/.config/rx/rclone-tool.sh ~/.local/bin/rctool
#
# Consolidated rclone utility. Performance profiles:
#   --large   few big files  (--transfers 2 --checkers 4 --multi-thread-streams 8 --multi-thread-cutoff 256M)
#   --small   many small files (--transfers 8 --checkers 8) [default]
#
# Operations: copy, move, sync, dedupe-new, dedupe-old
#
# Usage:
#   rctool [--large|--small] copy  <src> <dst>
#   rctool [--large|--small] move  <src> <dst>
#   rctool [--large|--small] sync  <src> <dst>
#   rctool dedupe-new <path>
#   rctool dedupe-old <path>

usage() {
  echo "Usage: $(basename "$0") [-l|--large|-s|--small] <operation> <source> [destination]"
  echo
  echo "  Profiles:      -l, --large  (2 transfers, 4 checkers, multi-thread for big files)"
  echo "                 -s, --small  (8 transfers, 8 checkers, default)"
  echo "                 -h, --help   Show this help"
  echo
  echo "  copy  <src> <dst>  — copy, preserving source"
  echo "  move  <src> <dst>  — move, removing empty source dirs"
  echo "  sync  <src> <dst>  — make dst identical to src"
  echo "  dedupe-new <path>  — deduplicate, keep newest"
  echo "  dedupe-old <path>  — deduplicate, keep oldest"
  exit "${1:-1}"
}

OPERATION=""
PROFILE="small"
SOURCE=""
DEST=""

# Parse args: pull out flags first, then positional args
for arg in "$@"; do
  case "$arg" in
    -h|--help) usage 0 ;;
    -l|--large) PROFILE="large" ;;
    -s|--small) PROFILE="small" ;;
    copy|move|sync|dedupe-new|dedupe-old) OPERATION="$arg" ;;
    *)
      if [[ -z "$SOURCE" ]]; then SOURCE="$arg"
      elif [[ -z "$DEST" ]];  then DEST="$arg"
      fi ;;
  esac
done

[[ -z "$OPERATION" ]] && usage

# Performance opts by profile
if [[ "$PROFILE" == "large" ]]; then
  PERF_OPTS=("--transfers" "2" "--checkers" "4" "--multi-thread-streams" "8" "--multi-thread-cutoff" "256M")
else
  PERF_OPTS=("--transfers" "8" "--checkers" "8")
fi

BASE_OPTS=("-P" "--exclude" ".DS_Store")

# Validate source + dest requirements
case "$OPERATION" in
  copy|move|sync)
    [[ -z "$SOURCE" ]] && { echo "Error: source required for $OPERATION"; exit 1; }
    [[ -z "$DEST"   ]] && { echo "Error: destination required for $OPERATION"; exit 1; }
    [[ ! -e "$SOURCE" ]] && { echo "Error: source '$SOURCE' not found"; exit 1; }
    ;;
  dedupe-new|dedupe-old)
    [[ -z "$SOURCE" ]] && { echo "Error: path required for $OPERATION"; exit 1; }
    ;;
esac

# Strip .DS_Store before operating on local source directories
if [[ -n "$SOURCE" && -d "$SOURCE" ]]; then
  find "$SOURCE" -type f -name ".DS_Store" -delete 2>/dev/null || true
fi

case "$OPERATION" in
  copy)
    rclone copy "${BASE_OPTS[@]}" "${PERF_OPTS[@]}" "$SOURCE" "$DEST" ;;
  move)
    rclone move "${BASE_OPTS[@]}" "${PERF_OPTS[@]}" --delete-empty-src-dirs "$SOURCE" "$DEST" ;;
  sync)
    rclone sync "${BASE_OPTS[@]}" "${PERF_OPTS[@]}" "$SOURCE" "$DEST" ;;
  dedupe-new)
    rclone dedupe "${BASE_OPTS[@]}" --dedupe-mode newest --by-hash "$SOURCE" ;;
  dedupe-old)
    rclone dedupe "${BASE_OPTS[@]}" --dedupe-mode oldest --by-hash "$SOURCE" ;;
  *)
    usage ;;
esac

echo "rctool '$OPERATION' ($PROFILE profile) complete."
