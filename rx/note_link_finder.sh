#!/usr/bin/env bash
# filename note_link_finder.sh in $RX (~/.config/rx)

# link-finder.sh - Find related notes based on content similarity
# Usage: ./link-finder.sh [path-to-markdown-file] [max-results=5]

# Default notes directory
NOTES_DIR="$HOME/notes"

# Check if a file was provided
if [ $# -lt 1 ] || [ ! -f "$1" ]; then
  echo "Usage: link-finder [path-to-markdown-file] [max-results=5]"
  exit 1
fi

FILE_PATH="$1"
MAX_RESULTS=${2:-5}

# Extract content from the file (excluding front matter)
CONTENT=$(sed -n '/^---$/,/^---$/!p' "$FILE_PATH")

# Extract significant words from the content
SIGNIFICANT_WORDS=$(echo "$CONTENT" |
  tr '[:upper:]' '[:lower:]' |
  tr -cs 'a-z0-9' ' ' |
  tr ' ' '\n' |
  grep -v -E '^.{1,3}$' |
  grep -v -E '^(the|and|for|you|this|that|with|from|have|are|not|was|were)$' |
  sort | uniq -c | sort -nr | head -20 | awk '{print $2}')

# Check if no significant words were found
if [ -z "$SIGNIFICANT_WORDS" ]; then
  echo "No significant words found in the content."
  exit 1
fi

# Building search pattern
SEARCH_PATTERN=$(echo "$SIGNIFICANT_WORDS" | tr '\n' '|')
FILENAME=$(basename "$FILE_PATH")

echo "Looking for notes related to $(basename "$FILE_PATH")..."
echo "Using keywords: $(echo $SEARCH_PATTERN | tr '|' ' ')"

# Find related files using ripgrep
RELATED_FILES=$(rg -l "$SEARCH_PATTERN" --type md --glob "!${FILENAME}" "${NOTES_DIR}" | head -n "$MAX_RESULTS")

if [ -z "$RELATED_FILES" ]; then
  echo "No related notes found."
  exit 0
fi

echo "Found related notes:"
echo "$RELATED_FILES" | while read -r related_file; do
  # Extract title from front matter if it exists, otherwise use filename
  TITLE=$(grep -m 1 "^title:" "$related_file" | sed 's/title: "\(.*\)"/\1/')

  if [ -z "$TITLE" ]; then
    TITLE=$(basename "$related_file" .md)
  fi

  # Get shortened relative path
  REL_PATH=$(realpath --relative-to="$NOTES_DIR" "$related_file")

  # Extract id from front matter
  ID=$(grep -m 1 "^id:" "$related_file" | sed 's/id: \(.*\)/\1/')

  echo "- $TITLE ($REL_PATH) [$ID]"
done

# Ask if user wants to update the file with links
read -p "Would you like to add these links to your note? (y/n): " CHOICE
if [[ $CHOICE =~ ^[Yy] ]]; then
  # Extract current links
  CURRENT_LINKS=$(grep -E "^links: \[.*\]" "$FILE_PATH" | sed 's/links: \[\(.*\)\]/\1/')

  # Prepare new links
  NEW_LINKS=""
  echo "$RELATED_FILES" | while read -r related_file; do
    ID=$(grep -m 1 "^id:" "$related_file" | sed 's/id: \(.*\)/\1/')
    if [ -n "$ID" ]; then
      if [ -n "$NEW_LINKS" ]; then
        NEW_LINKS="$NEW_LINKS, \"$ID\""
      else
        NEW_LINKS="\"$ID\""
      fi
    fi
  done

  # Combine current and new links
  if [ -n "$CURRENT_LINKS" ]; then
    COMBINED_LINKS="$CURRENT_LINKS, $NEW_LINKS"
  else
    COMBINED_LINKS="$NEW_LINKS"
  fi

  # Update the file
  sed -i "s/links: \[.*\]/links: [$COMBINED_LINKS]/" "$FILE_PATH"
  echo "Links added to note!"

  # Update modification date
  TODAY=$(date +%Y-%m-%d)
  sed -i "s/modified: .*/modified: $TODAY/" "$FILE_PATH"
else
  echo "No changes made to the note."
fi
