# ~/.config/zsh/modules/vi-cursor.zsh
# Vi mode cursor shape configuration

# Cursor shapes (ANSI escape sequences)
# \e[1 q - Blinking block
# \e[2 q - Steady block
# \e[3 q - Blinking underline
# \e[4 q - Steady underline
# \e[5 q - Blinking bar (pipe)
# \e[6 q - Steady bar (pipe)

# Change cursor shape based on vi mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    # Vi command mode - blinking block
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    # Vi insert mode - blinking bar
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Initialize cursor to blinking bar when starting a new line
function zle-line-init {
  echo -ne '\e[5 q'
}
zle -N zle-line-init

# Reset cursor to blinking bar after each command
function reset-cursor {
  echo -ne '\e[5 q'
}
precmd_functions+=(reset-cursor)

# Set initial cursor shape on shell start
echo -ne '\e[5 q'