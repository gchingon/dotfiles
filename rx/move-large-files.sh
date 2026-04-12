#!/usr/bin/env bash
# move-large-files — Find and move large files preserving directory structure
# Usage: move-large-files [SIZE]  # default: 99M

source "$(dirname "$0")/lib/common.sh"
check_deps fd

show_usage() {
  cat <<EOF
Usage: move-large-files [-s|--size SIZE] [-t|--target DIR]

Default size: 99M
Default target: \$HOME/jackpot
EOF
}

TARGET_DIR="${TARGET_DIR:-$HOME/jackpot}"
SIZE="99M"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) show_usage; exit 0 ;;
    -s|--size) SIZE="${2:-}"; shift 2 ;;
    -t|--target) TARGET_DIR="${2:-}"; shift 2 ;;
    *) SIZE="$1"; shift ;;
  esac
done

log "Finding files larger than $SIZE..."
fd -tf -S "+$SIZE" . | while read -r file; do
    relative_path=${file#./}
    dir_path=$(dirname "$relative_path")
    
    log "Moving '$relative_path'..."
    mkdir -p "$TARGET_DIR/$dir_path"
    safe-move "$file" "$TARGET_DIR/$relative_path"
done

log "Operation complete."
