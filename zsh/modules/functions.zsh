# ~/.config/zsh/modules/functions.zsh
# Editor and config shortcuts

# Config editors (already in config.zsh, removing duplicates)
# open-nvim-init() and open-ghostty() removed - use config.zsh versions

# App-specific reloads
reload-ghostty() {
  osascript <<-'EOF' 2>/dev/null
    tell application "System Events"
      tell application "Ghostty" to activate
      keystroke "," using {command down, shift down}
    end tell
EOF
}

# Quick entry points
dreams_md_shortcut() {
  local dream_date=$(date "+%Y-%m-%d")
  nvim "$CT/dreams.md" \
    -c "normal! G" \
    -c "normal! o# " \
    -c "normal! o#" \
    -c "normal! odate: $dream_date" \
    -c "normal! o" \
    -c "normal! 3k\$" \
    -c "startinsert"
}

unalias mkd dedupemuz cleannvimswp dots-sync lstype 2>/dev/null || true

mkd() {
  [[ $# -gt 0 ]] || { echo "Usage: mkd <directory_path>"; return 1; }
  mkdir -pv "$1" && cd "$1"
}

dedupemuz() {
  command -v fd >/dev/null || { echo "Missing: fd"; return 1; }
  fd -tf -e opus . "${1:-.}" -x bash -c '
    for opus; do mp3="${opus%.*}.mp3"; [[ -f "$mp3" ]] || continue
      echo "Keeping: $opus"; echo "Deleting: $mp3"; rm -v "$mp3"
    done
  ' bash {}
}

cleannvimswp() {
  command -v fd >/dev/null || { echo "Missing: fd"; return 1; }
  fd -tf -e swp --age 6h "${1:-$HOME}" -x rm -frv {} >/dev/null
}

dots-sync() {
  local real_user; real_user=$(stat -f "%Su" /dev/console)
  /usr/bin/su - "$real_user" -c \
    "cd \$CF || exit 1; kitten @ launch --type=tab zsh -lc 'cd ~/.config && gac \"sync \$(date +%Y-%m-%d)\" ; exec zsh'"
}

lstype() {
  command -v fd >/dev/null || { echo "Missing: fd"; return 1; }
  fd -td . "${1:-.}" | while read -r dir; do
    echo "Directory: $dir"
    ls -1 "$dir" | awk -F. 'NF>1 {print tolower($NF)}' | sort -u | sed 's/^/  ./'
    echo
  done
}
