# ~/.config/zsh/modules/functions.zsh
# Editor and config shortcuts

# Config editors (already in config.zsh, removing duplicates)
# open-nvim-init() and open-ghostty() removed - use config.zsh versions

# App-specific reloads
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

unalias mkd dedupemuz cleannvimswp dots-sync lstype oct occ ocd 2>/dev/null || true

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

_openclaw_or_note() {
  if command -v openclaw >/dev/null 2>&1; then
    command openclaw "$@"
  else
    echo "openclaw is not installed on this machine. Expected on 2mini; current machine: ${MACHINE_NAME:-$(hostname -s 2>/dev/null || hostname 2>/dev/null)}"
    return 127
  fi
}

oct() {
  _openclaw_or_note tui "$@"
}

occ() {
  _openclaw_or_note configure "$@"
}

ocd() {
  _openclaw_or_note doctor "$@"
}

lstype() {
  command -v fd >/dev/null || { echo "Missing: fd"; return 1; }
  fd -td . "${1:-.}" | while read -r dir; do
    echo "Directory: $dir"
    ls -1 "$dir" | awk -F. 'NF>1 {print tolower($NF)}' | sort -u | sed 's/^/  ./'
    echo
  done
}
