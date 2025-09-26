#!/bin/zsh
# filename delete_old_nvim_swap_files.sh in $RX (~/.config/rx)
cd
fd -tf -e swp --age 6h -x rm -frv {} > /dev/null
