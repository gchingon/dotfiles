#!/usr/bin/env bash
# ln ~/.config/rx/dedupe-mp3.sh ~/.local/bin/dedupemuz
# Find all .opus files and check for corresponding .mp3 duplicates
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<EOF
Usage: dedupemuz [path]

Deletes .mp3 files that have a same-basename .opus sibling.
Default path: current directory
EOF
  exit 0
fi

fd --type f --extension opus . "${1:-.}" --exec bash -c '
  for opus_file; do
    # Extract the base name without extension
    base_name="${opus_file%.*}"
    mp3_file="${base_name}.mp3"

    # Check if corresponding .mp3 file exists
    if [[ -f "$mp3_file" ]]; then
      echo "Found duplicate pair:"
      echo "  Keeping: $opus_file"
      echo "  Deleting: $mp3_file"
      rm -v "$mp3_file"
    fi
  done
' bash {}
