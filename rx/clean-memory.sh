#!/usr/bin/env bash
# ln ~/.config/rx/clean-memory.sh ~/.local/bin/freemem

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

show_usage() {
  cat <<EOF
Usage: freemem [--aggressive] [--help]

Reclaims caches conservatively by default.
  --aggressive  Also cycle swap on Linux after dropping caches
  -h, --help    Show this help
EOF
}

clean_memory() {
  local aggressive="${1:-false}"
  case "$(uname -s)" in
    Darwin)
      log "macOS manages RAM aggressively; reclaiming purgeable caches if available..."
      if command -v purge >/dev/null 2>&1; then
        sudo purge
      else
        command -v memory_pressure >/dev/null 2>&1 && memory_pressure || true
        log "No purge command available; reported memory pressure instead."
      fi
      ;;
    Linux)
      log "Dropping Linux page cache..."
      sync
      echo 1 | sudo tee /proc/sys/vm/drop_caches >/dev/null
      if [[ "$aggressive" == "true" ]] && command -v swapon >/dev/null 2>&1 && command -v swapoff >/dev/null 2>&1; then
        log "Cycling swap for a deeper cleanup..."
        sudo swapoff -a && sudo swapon -a
      fi
      ;;
    *)
      die "Unsupported OS: $(uname -s)"
      ;;
  esac
}

case "${1:-}" in
  -h|--help) show_usage ;;
  --aggressive) clean_memory true ;;
  "") clean_memory false ;;
  *) die "Unknown option: $1" ;;
esac
