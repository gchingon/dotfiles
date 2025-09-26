#!/bin/bash
# ln ~/.config/rx/cd-into-made-dir.sh ~/.local/bin/mkcd
# mkd - Make directory and change into it (simple version)

cd-into-made-dir() {
  if [ $# -eq 0 ]; then
    echo "Usage: mkd <directory_path>"
    return 1
  fi

  mkdir -pv "$1" && cd "$1"
}
