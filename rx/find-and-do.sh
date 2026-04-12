#!/usr/bin/env bash
# ln ~/.config/rx/find-and-do.sh ~/.local/bin/findo
# Compatibility wrapper for filemgr

set -euo pipefail

exec "$(dirname "$0")/file-finder-and-mover-utility.sh" "$@"
