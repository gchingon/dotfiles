#!/usr/bin/env bash
# filename note_move.sh in $RX (~/.config/rx)

# migrate-notes.sh - Convert existing notes to the new format
# Usage: ./migrate-notes.sh [source-directory] [destination-directory]

# Default directories
SOURCE_DIR="${1:-$HOME/old-notes}"
DEST_DIR="${2:-$HOME/notes}"

# Create destination directories if they don't exist
mkdir -p "$DEST_DIR/1-jackpot"
mkdir -p "$DEST_DIR/2-zk"
mkdir -p "$DEST_DIR/3-resources"
mkdir -p "$DEST_DIR/4-archive"

# Get current date
TODAY=$(date +%Y-%m-%d)
DATESTAMP=$(date +%Y%m%d)

# Function to resolve directory path from shorthand
resolve_dir() {
  local category="$1"
  case "$category" in
  "1" | "jackpot") echo "1-jackpot" ;;
  "2" | "zk") echo "2-zk" ;;
  "3" | "resource" | "resources") echo "3-resources" ;;
  "4" | "archive" | "archives") echo "4-archive" ;;
  *) echo "2-zk" ;; # Default to zk if not matched
  esac
}

# Function to check for date in file header
extract_date() {
  local file="$1"
  local date_str=$(head -n 14 "$file" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" | head -n 1)

  if [ -n "$date_str" ]; then
    echo "$date_str"
  else
    echo "$TODAY"
  fi
}

# Function to guess category based on content and filename
guess_category() {
  local file="$1"
  local content=$(cat "$file")
  local filename=$(basename "$file")

  # Check for recipe indicators
  if grep -q -i -E "(recipe|ingredient|cook|bake|tbsp|cup|teaspoon|tablespoon)" <<<"$content" ||
    grep -q -i "recipe" <<<"$filename"; then
    echo "3"
    return
  fi

  # Check for dream indicators
  if grep -q -i -E "(dream|dreamt|dreamed|sleep|nightmare)" <<<"$content" ||
    grep -q -i "dream" <<<"$filename"; then
    echo "2"
    return
  fi

  # Check for technical notes
  if grep -q -i -E "(code|function|script|command|terminal|programming|python|bash)" <<<"$content"; then
    echo "3"
    return
  fi

  # Default fallback
  echo "1"
}

# Function to extract title from content
extract_title() {
  local file="$1"

  # Try to find a markdown H1 header
  h1_title=$(grep -m 1 "^# " "$file" | sed 's/^# //')

  if [ -n "$h1_title" ]; then
    echo "$h1_title"
    return
  fi

  # Use filename as fallback
  filename=$(basename "$file" .md)
  # Clean up filename to make it presentable
  clean_title=$(echo "$filename" | sed 's/-/ /g' | sed 's/_/ /g' | sed -r 's/\b\w/\U&/g')

  echo "$clean_title"
}

# Counter for processed files
processed=0
total=$(find "$SOURCE_DIR" -type f -name "*.md" | wc -l)
echo "Found $total markdown files to process..."

# Process each markdown file
find "$SOURCE_DIR" -type f -name "*.md" | while read -r file; do
  filename=$(basename "$file")

  # Skip if it's already in the new format
  if [[ "$filename" =~ ^[0-9]{8}- ]]; then
    echo "Skipping already formatted file: $filename"
    continue
  fi

  # Extract info
  category_num=$(guess_category "$file")
  category_dir=$(resolve_dir "$category_num")
  title=$(extract_title "$file")
  slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

  # Extract date from file or use default
  file_date=$(extract_date "$file")
  file_datestamp=$(echo "$file_date" | tr -d '-')

  # Create new filename
  new_filename="${file_datestamp}-${slug}.md"
  new_path="${DEST_DIR}/${category_dir}/${new_filename}"

  # Create temporary file with new front matter
  temp_file=$(mktemp)

  cat >"$temp_file" <<EOF
---
id: ${category_num}-${slug}
aliases: ["${title}"]
tags: []
title: "${title}"
date: ${file_date}
modified: ${TODAY}
category: ${category_num}
status: active
links: []
---
EOF

  # Append original content, skipping any existing front matter
  if grep -q "^---$" "$file"; then
    # Has front matter, extract content only
    sed -n '/^---$/,/^---$/!p' "$file" >>"$temp_file"
  else
    # No front matter, copy all content
    cat "$file" >>"$temp_file"
  fi

  # Move temp file to destination
  mkdir -p "$(dirname "$new_path")"
  mv "$temp_file" "$new_path"

  echo "Migrated: $file → $new_path"

  # Increment counter
  ((processed++))
  if ((processed % 10 == 0)); then
    echo "Progress: $processed/$total files processed"
  fi
done

echo "Migration complete! $processed files processed."
echo "You may want to run the tag-helper script on your newly migrated notes to generate appropriate tags."
