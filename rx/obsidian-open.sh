#!/usr/bin/env bash
# Filename: $RX/obsidian-open.sh
# Opens a directory in Obsidian by resolving it through the user's own login
# shell (so $RP/$DX/$NT come from zshenv's per-hostname case block — same
# path resolution as the nvim-* kitty sessions). Directories with no
# .obsidian/ vault just won't do much in Obsidian; that's expected for
# dots/repos.

set -u

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  real_user="$(stat -f "%Su" /dev/console)"
  real_uid="$(id -u "$real_user")"
  exec launchctl asuser "$real_uid" sudo -u "$real_user" "$0" "$@"
fi

KEY="${1:?Usage: obsidian-open.sh <dots|repos|docs|notes>}"

DIR="$(zsh --login -c "
  case '$KEY' in
    dots)  echo ~/.config ;;
    repos) echo \"\${RP:-\$HOME/repos}\" ;;
    docs)  echo \"\${DX:-\$HOME/Documents}\" ;;
    notes) echo \"\${NT:-\$HOME/repos/notes}\" ;;
  esac
")"

ENC="$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$DIR")"
open "obsidian://open?path=$ENC"
