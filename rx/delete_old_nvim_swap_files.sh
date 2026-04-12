#!/bin/zsh
# filename delete_old_nvim_swap_files.sh in $RX (~/.config/rx)
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: cleannvimswp [path]"
  echo "Deletes .swp files older than 6 hours from the given path (default: \$HOME)."
  exit 0
fi

fd -tf -e swp --age 6h "${1:-$HOME}" -x rm -frv {} > /dev/null
