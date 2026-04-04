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
