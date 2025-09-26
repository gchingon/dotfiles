#!/usr/bin/env bash
# ln ~/.config/rx/slugged.sh ~/.local/bin/slug

#: Name        : slugged
#: Date        : 2025-02-26
#: Author      : Gallo-S-Chingon
#: Description : Convert filenames to a slug format: lowercase alphanumeric with single delimiters,
#:               removing non-ASCII, punctuation, and emojis, preserving extensions.

declare -A CONFIG=(
  ["verbose"]=0
  ["dry_run"]=0
  ["delimiter"]="-"
)

print_usage() {
  cat <<EOF
usage: slugged [options] source_file ...
  -h, --help            Show this help
  -v, --verbose         Verbose mode (show rename actions)
  -n, --dry-run         Dry run mode (no changes, implies -v)
  -u, --underscore      Use underscores instead of hyphens as delimiter
EOF
}

log_verbose() {
  [ "${CONFIG["verbose"]}" -eq 1 ] && echo "$1"
}

slugify_file() {
  local input="$1"
  local delimiter="${CONFIG["delimiter"]}"
  local dir_name base_name extension result

  # Handle paths correctly
  if [[ "$input" == */* ]]; then
    dir_name="$(dirname "$input")"
    base_name="$(basename "$input")"
  else
    dir_name="."
    base_name="$input"
  fi

  # Handle extensions
  if [[ "$base_name" =~ \. ]]; then
    extension="${base_name##*.}"
    base_name="${base_name%.*}"
  else
    extension=""
  fi

  # Convert to slug format
  result=$(echo "$base_name" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' "$delimiter")
  result="${result#$delimiter}"
  result="${result%$delimiter}"

  # Add extension back if it exists
  [ -n "$extension" ] && result="$result.$extension"

  # Add directory back if it exists and isn't current directory
  if [ "$dir_name" != "." ]; then
    result="$dir_name/$result"
  fi

  echo "$result"
}

handle_duplicates() {
  local target="$1"
  local target_slug=$(slugify_file "$target")
  local counter=1
  local new_slug="$target_slug"

  # Check for existing files and modify the slug if needed
  while [[ -e "$new_slug" ]]; do
    new_slug="${target_slug%.*}-$counter.${target_slug##*.}"
    ((counter++))
  done

  echo "$new_slug"
}

main() {
  local files=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      print_usage
      exit 0
      ;;
    -v | --verbose)
      CONFIG["verbose"]=1
      ;;
    -n | --dry-run)
      CONFIG["dry_run"]=1
      CONFIG["verbose"]=1
      ;;
    -u | --underscore)
      CONFIG["delimiter"]="_"
      ;;
    *)
      files+=("$1")
      ;;
    esac
    shift
  done

  if [ ${#files[@]} -eq 0 ]; then
    print_usage
    exit 1
  fi

  for file in "${files[@]}"; do
    if [ ! -e "$file" ]; then
      echo "ERROR: File '$file' not found." >&2
      continue
    fi

    local slug=$(slugify_file "$file")
    local new_slug=$(handle_duplicates "$slug")

    if [ "${CONFIG["dry_run"]}" -eq 1 ]; then
      echo "Would rename: $file -> $new_slug"
    else
      mv "$file" "$new_slug" 2>/dev/null || {
        echo "ERROR: Failed to rename '$file' to '$new_slug'" >&2
      }
      log_verbose "Renamed: $file -> $new_slug"
    fi
  done
}
