#!/usr/bin/env bash
set -euo pipefail

# Sync ~/repos/dots to ~/.config using hardlinks
# Preserves directory structure, hardlinks files only

SOURCE="$HOME/repos/dots"
TARGET="$HOME/.config"

# Files/dirs to exclude from syncing
EXCLUDE_PATTERNS=(
  ".DS_Store"
)

should_exclude() {
  local item="$1"
  local basename_item
  basename_item=$(basename "$item")

  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    if [[ "$basename_item" == "$pattern" ]]; then
      return 0
    fi
  done
  return 1
}

sync_directory() {
  local src="$1"
  local dst="$2"

  # Create target directory if it doesn't exist
  mkdir -p "$dst"

  # Iterate through items in source
  while IFS= read -r -d '' item; do
    local rel_path="${item#$src/}"
    local target_path="$dst/$rel_path"

    if should_exclude "$item"; then
      echo "Skipping: $rel_path"
      continue
    fi

    if [[ -d "$item" ]]; then
      # Create directory in target
      mkdir -p "$target_path"
      echo "Created dir: $rel_path"
    elif [[ -f "$item" ]]; then
      # Remove existing file/link if it exists
      if [[ -e "$target_path" ]] || [[ -L "$target_path" ]]; then
        # Check if already hardlinked
        if [[ -f "$target_path" ]] && [[ "$(stat -f '%i' "$item")" == "$(stat -f '%i' "$target_path")" ]]; then
          echo "Already linked: $rel_path"
          continue
        fi
        rm -f "$target_path"
      fi

      # Create parent directory if needed
      mkdir -p "$(dirname "$target_path")"

      # Create hardlink
      ln "$item" "$target_path"
      echo "Hardlinked: $rel_path"
    fi
  done < <(find "$src" -print0)
}

main() {
  echo "Syncing $SOURCE -> $TARGET"
  echo "Using hardlinks for files, creating directories..."
  echo

  sync_directory "$SOURCE" "$TARGET"

  echo
  echo "✓ Sync complete! Files are now hardlinked."
  echo "  Any changes in either location will be reflected in both."
}

main "$@"
