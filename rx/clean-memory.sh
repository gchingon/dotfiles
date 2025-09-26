#!/bin/bash
# ln  ~/.config/rx/clean-memory.sh ~/.local/bin/freemem

# run sudo purge to clear memory to continue a bit faster
clean_memory() {
  echo "Freeing up system memory..."
  if command -v purge &>/dev/null && [[ "$(uname)" == "Darwin" ]]; then
    sudo purge || echo "Warning: Memory purge failed" >&2
  elif [[ "$(uname)" == "Linux" ]]; then
    echo 3 | sudo tee /proc/sys/vm/drop_caches &>/dev/null || echo "Warning: Memory cleanup failed" >&2
  else
    echo "Warning: Memory cleanup not supported on this OS" >&2
  fi
  sleep 1
}
