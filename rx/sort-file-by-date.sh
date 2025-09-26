#!/bin/bash
# ln ~/.config/rx/sort-file-by-date.sh ~/.local/bin/bydate

# Source directory
source_dir="$1"

# Check if source directory is provided
if [ -z "$source_dir" ]; then
  echo "Usage: $0 <source_directory>"
  exit 1
fi

# Get current date and year
current_date=$(date +%Y-%m-%d)
current_year=$(date +%Y)
current_month=$(date +%m)
previous_month=$((current_month - 1))
if [ "$previous_month" -eq 0 ]; then
  previous_month=12
fi

# Function to get the month from a date string
get_month() {
  local date_str="$1"
  local month=$(date -j -f "%Y-%m-%d" "$date_str" "+%m")
  echo "$month"
}

# Iterate over files in the source directory
for filename in "$source_dir"/*; do
  if [ -f "$filename" ]; then
    # Extract date from filename
    date_str=$(echo "$filename" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    if [ -n "$date_str" ]; then
      year=$(echo "$date_str" | cut -d'-' -f1)
      month=$(get_month "$date_str")

      # Skip current month and previous month for the current year
      if [ "$year" == "$current_year" ] && [ "$month" == "$current_month" ]; then
        continue
      elif [ "$year" == "$current_year" ] && [ "$month" == "$previous_month" ]; then
        continue
      fi

      dest_dir="$source_dir/$year/$year-$month"
      mkdir -p "$dest_dir"
      mv "$filename" "$dest_dir/"
    else
      echo "Skipping $filename (invalid filename format)"
    fi
  fi
done
