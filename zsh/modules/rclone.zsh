# ~/.config/zsh/modules/rclone.zsh
# Rclone functions

base_opts="-P --exclude-from $CF/clear --fast-list"
move_opts="--delete-empty-src-dirs"
new_dedupe="--dedupe-mode newest"
old_dedupe="--dedupe-mode oldest"

# Execute rclone command
# Usage: execute-rclone-command CMD SOURCE TARGET [EXTRA_OPTS]
execute-rclone-command() {
  local cmd="$1" source="$2" target="$3" extra="$4"
  [ -e "$source" ] || { echo "(눈︿눈) Source '$source' not found."; return 1; }
  rclone "$cmd" "$base_opts" "$source" "$target" "$extra"
}

rclone-copy() { execute-rclone-command "copy" "$1" "$2"; }
rclone-move() { execute-rclone-command "move" "$1" "$2" "$move_opts"; }
rclone-dedupe-new() { execute-rclone-command "dedupe" "$1" "--by-hash" "$new_dedupe"; }
rclone-dedupe-old() { execute-rclone-command "dedupe" "$1" "--by-hash" "$old_dedupe"; }
