# ~/.config/zsh/modules/file-management.zsh
# File and directory operations

BACKUP_DIR="/Volumes/armor/"

# Move files matching pattern, excluding a directory
fd-move-exclude() {
  fd -tf "$1" -E "$2" -x mv {} "$2"
}

# Move files to directory (current dir only)
fd-move() {
  fd -tf -d 1 "$1" -x mv -v {} "$2"
}

# List file types by extension per directory
fd-types() {
  fd --type d | while read -r dir; do
    echo "$dir"
    eza -1 "$dir" 2>/dev/null | grep -v '/$' | awk -F. '{print "*."$NF}' | sort -u
  done
}

# Move files larger than size (default: 99M) to jackpot
move-large() {
  local target="${1:-$HOME/jackpot}"
  local size="${2:-99M}"
  fd -tf -S "+$size" -x sh -c 'mkdir -p "'"$target"'/${1%/*}"; mv "$1" "'"$target"'/$1"' _ {}
}

# Move ISO/NIX files to backup
move-iso() {
  local src="${1:-$DN}"
  local dst="${2:-$BACKUP_DIR/iso/}"
  [[ -d "$dst" ]] || { echo "Target not found: $dst"; return 1; }
  for f in "$src"/*.{iso,dmg,pkg}(N); do
    [[ -e "$f" ]] && mv "$f" "$dst" && echo "Moved: $(basename "$f")"
  done
}

# Move images to Pictures
move-pix() {
  local src="${1:-$DN}"
  local dst="${2:-$HOME/Pictures/}"
  for f in "$src"/*.{heic,jpg,jpeg,png,webp}(N); do
    [[ -e "$f" ]] && mv "$f" "$dst" && echo "Moved: $(basename "$f")"
  done
}

# Clean image files from directory
rm-pix() {
  local dir="${1:-.}"
  fd -e jpg -e jpeg -e png -e webp -e gif -e nfo -e txt . "$dir" -x rm -v {} \;
}
