#!/usr/bin/env bash
# move-large-files — Find and move large files preserving directory structure
# Usage: move-large-files [SIZE]  # default: 99M

source "$(dirname "$0")/lib/common.sh"
check_deps fd

TARGET_DIR="${TARGET_DIR:-$HOME/jackpot}"
SIZE="${1:-99M}"

log "Finding files larger than $SIZE..."
fd -tf -S "+$SIZE" . | while read -r file; do
    relative_path=${file#./}
    dir_path=$(dirname "$relative_path")
    
    log "Moving '$relative_path'..."
    mkdir -p "$TARGET_DIR/$dir_path"
    safe-move "$file" "$TARGET_DIR/$relative_path"
done

log "Operation complete."
