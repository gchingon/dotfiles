#!/usr/bin/env bash
# Finds files larger than a specified size and moves them to a target directory,
# preserving the directory structure.

TARGET_DIR="$HOME/jackpot"
SIZE=${1:-99M} # Default to 99M if no size is provided

echo "Finding files larger than $SIZE..."
fd -tf -S "+$SIZE" . | while read -r file; do
    relative_path=${file#./}
    filename=$(basename "$relative_path")
    dir_path=$(dirname "$relative_path")

    echo "Moving '$relative_path'..."
    mkdir -p "$TARGET_DIR/$dir_path"
    mv "$file" "$TARGET_DIR/$dir_path/"
done

echo "Operation complete."
