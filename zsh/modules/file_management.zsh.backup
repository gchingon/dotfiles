# ~/.config/zsh/modules/file-management.zsh
# File and directory management functions

BACKUP_DIR="/Volumes/armor/"

fd-exclude-dir-find-name-move-to-exclude-dir() {
  fd -tf "$1" -E "$2" -x mv {} "$2"  # `-tf` = files only, `-E` = exclude dir
}

fd-files-move-to-dir() {
  fd -tf -d 1 "$1" -x mv -v {} "$2"  # `-d 1` = current dir only
}

fd-type() {
  fd --type d | while read -r dir; do
    echo "$dir"
    eza -1 "$dir" | grep -v '/$' | awk -F. '{print "*."$NF}' | sort -u
  done
}

move-repo-files-larger-than-99M() {
  local target_dir="$HOME/jackpot"
  local files_to_move=($(fd -tf -S +99M))  # `-S +99M` = size > 99MB
  for file in "${files_to_move[@]}"; do
    filename="${file##*/}"
    mk "$target_dir/${file%/*}"
    mv "$file" "$target_dir/${file%/*}/$filename"
  done
}

move-iso() {
  local source_dir="$DN/"
  local target_dir="$BACKUP_DIR/iso/"
  [ -d "$target_dir" ] || { echo "0-0 Target '$target_dir' not found."; return 1; }
  setopt null_glob
  for ext in iso dmg pkg; do
    for file in "$source_dir"/*.$ext; do
      [ -e "$file" ] && mv "$file" "$target_dir" && echo "( ⋂‿⋂) $(basename "$file") moved."
    done
  done
}

move-nix() {
  local source_dir="$DN/"
  local target_dir="$BACKUP_DIR/iso/nix/"
  [ -d "$target_dir" ] || { echo "0-0 Target '$target_dir' not found."; return 1; }
  setopt null_glob
  for file in "$source_dir"/*.iso; do
    [ -e "$file" ] && mv "$file" "$target_dir" && echo "( ⋂‿⋂) $(basename "$file") moved."
  done
}

move-download-pix-to-pictures-dir() {
  local source_dir="$DN/"
  local target_dir="$HOME/Pictures/"
  setopt null_glob
  for ext in heic jpg jpeg png webp; do
    for file in "$source_dir"/*.$ext; do
      [ -e "$file" ] && mv "$file" "$target_dir" && echo "( ⋂‿⋂) $(basename "$file") moved."
    done
  done
}

move-ipa-to-target-directory() {
  local source_dir="$DN"
  local target_dir="$BACKUP_DIR/iso/ipa/"
  for file in "$source_dir"/*.ipa; do
    [ -e "$file" ] && mv "$file" "$target_dir" && echo "( ⋂‿⋂) $(basename "$file") moved."
  done
}

remove-pix() {
  local old_dir="$PWD"
  cd /Volumes/hold/ulto/ || return
  fd -e jpg -e jpeg -e png -e webp -e nfo -e txt -e gif -x rm -v {} \;  # `-e` = extension match
  cd "$old_dir" || return
}
