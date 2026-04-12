#!/usr/bin/env bash
# ln ~/.config/rx/list-file-types.sh ~/.local/bin/lstype
# Lists all unique file extensions found in subdirectories of the current path.
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: lstype [path]"
  echo "Lists unique file extensions found under each subdirectory."
  exit 0
fi

fd --type d . "${1:-.}" | while read -r dir; do
  echo "Directory: $dir"
  # Use `eza` or `ls`, ensuring it lists one file per line
  ls -1 "$dir" | grep -v '/$' | awk -F. 'NF>1 {print tolower($NF)}' | sort -u | sed 's/^/  ./'
  echo
done
