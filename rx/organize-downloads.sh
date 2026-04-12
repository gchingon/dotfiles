#!/usr/bin/env bash
# ln ~/.config/rx/organize-downloads.sh ~/.local/bin/orgdn

set -euo pipefail

SOURCE_DIR="${DN:-$HOME/Downloads}"
ARMOR_DIR="/Volumes/armor"

destination_for() {
  case "$1" in
    images) echo "$HOME/Pictures" ;;
    ipa) echo "$ARMOR_DIR/ipa" ;;
    iso) echo "$ARMOR_DIR/iso" ;;
    nix) echo "$ARMOR_DIR/nix" ;;
  esac
}

extensions_for() {
  case "$1" in
    images) echo "heic jpg jpeg png webp" ;;
    ipa) echo "ipa" ;;
    iso) echo "dmg iso pkg img" ;;
    nix) echo "iso" ;;
  esac
}

show_usage() {
  cat <<EOF
Usage: orgdn [-a|all|images|ipa|iso|nix]

Default:
  -a, all    Process images, ipa, and iso categories

Notes:
  nix is opt-in because .iso overlaps with the general iso bucket.
EOF
}

move_category() {
  local name="$1" moved=0
  local destination; destination="$(destination_for "$name")"
  [[ -d "$destination" ]] || { echo "Skipping $name: '$destination' not available"; return 0; }
  shopt -s nullglob
  for ext in $(extensions_for "$name"); do
    for file in "$SOURCE_DIR"/*."$ext"; do
      mv -v "$file" "$destination"/
      ((moved+=1))
    done
  done
  shopt -u nullglob
  (( moved > 0 )) && echo "Moved ${name^^}s from $SOURCE_DIR" || echo "No ${name^^} files found in $SOURCE_DIR"
}

main() {
  local mode="${1:-all}"
  case "$mode" in
    -h|--help) show_usage ;;
    -a) for category in images ipa iso; do move_category "$category"; done ;;
    all) for category in images ipa iso; do move_category "$category"; done ;;
    images|ipa|iso|nix) move_category "$mode" ;;
    *) echo "Unknown category: $mode"; show_usage; exit 1 ;;
  esac
}

main "$@"
