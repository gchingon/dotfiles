#!/usr/bin/env bash
# ln ~/.config/rx/new_note.sh ~/.local/bin/newnote

set -euo pipefail

show_usage() {
  cat <<EOF
Usage: new-note <category> <title>
  category: project, area, resource, or archive
  title: Title of the note (used for the filename and front matter)
EOF
}

resolve_notes_dir() {
  local machine_name=""
  [[ -f "$HOME/.config/machine.env" ]] && source "$HOME/.config/machine.env"
  machine_name="${MACHINE_NAME:-}"
  case "$machine_name" in
    mbp) echo "$HOME/Documents/notes" ;;
    2mini) echo "$HOME/Documents/2mepos/notes" ;;
    4mini) echo "$HOME/Documents/repos/notes" ;;
    *)
      if [[ -n "${NT:-}" ]]; then
        echo "$NT"
      elif [[ -d "$HOME/Documents/notes" ]]; then
        echo "$HOME/Documents/notes"
      else
        echo "$HOME/notes"
      fi
      ;;
  esac
}

# Get date info
DATE=$(date +%Y-%m-%d)
DATESTAMP=$(date +%Y%m%d)
NOTES_DIR="$(resolve_notes_dir)"

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { show_usage; exit 0; }
[[ $# -ge 2 ]] || { show_usage; exit 1; }

CATEGORY="$1"
shift
TITLE="$*"

# Convert title to kebab-case for filename
FILENAME=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

# Create the full path with datestamp
FULL_FILENAME="${DATESTAMP}-${CATEGORY}-${FILENAME}.md"
FULL_PATH="${NOTES_DIR}/${CATEGORY}s/${FULL_FILENAME}"

# Create directory if it doesn't exist
mkdir -p "${NOTES_DIR}/${CATEGORY}s"

# Generate slug for obsidian id field
SLUG="${CATEGORY}-${FILENAME}"

# Create file with front matter
cat >"$FULL_PATH" <<EOF
---
id: ${SLUG}
aliases: ["${TITLE}"]
tags: ["${CATEGORY}"]
title: "${TITLE}"
date: ${DATE}
modified: ${DATE}
category: ${CATEGORY}
status: active
links: []
---

# ${TITLE}

## Summary

<!-- Content starts here -->


EOF

echo "Created note at: $FULL_PATH"

# Open the file in Neovim and position cursor after the Summary heading
nvim "+call cursor(13, 1)" "$FULL_PATH"
