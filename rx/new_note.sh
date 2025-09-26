#!/usr/bin/env bash
# ln ~/.config/rx/new_note.sh ~/.local/bin/newnote

# new-note.sh - Create a new markdown note with proper front matter and naming
# Usage: ./new-note.sh [category] [title]

# Default location for notes
NOTES_DIR="$HOME/notes"

# Get date info
DATE=$(date +%Y-%m-%d)
DATESTAMP=$(date +%Y%m%d)

# Check for arguments
if [ $# -lt 2 ]; then
  echo "Usage: new-note [category] [title]"
  echo "  category: project, area, resource, or archive"
  echo "  title: Title of the note (will be converted to kebab-case for filename)"
  exit 1
fi

CATEGORY="$1"
TITLE="$2"

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
