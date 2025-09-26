#!/usr/bin/env bash
# ln ~/.config/rx/list-file-types.sh ~/.local/bin/lstype
# Lists all unique file extensions found in subdirectories of the current path.
fd --type d . | while read -r dir; do
  echo "Directory: $dir"
  # Use `eza` or `ls`, ensuring it lists one file per line
  ls -1 "$dir" | grep -v '/$' | awk -F. 'NF>1 {print tolower($NF)}' | sort -u | sed 's/^/  ./'
  echo
done
