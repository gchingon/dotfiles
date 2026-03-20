#!/bin/zsh
# dots-sync.sh — sync dotfiles repo from anywhere via kanata
# hardlink to ~/.local/bin/dots-sync

REAL_USER=$(stat -f "%Su" /dev/console)
/usr/bin/su - "$REAL_USER" -c "
  cd \$CF || exit 1
  kitten @ launch --type=tab zsh -lc 'cd ~/.config && gac \"sync \$(date +%Y-%m-%d)\" ; exec zsh'
"
