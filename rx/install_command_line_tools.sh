#!/usr/bin/env bash
# filename install_command_line_tools.sh in $RX (~/.config/rx)

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"

show_usage() {
  cat <<EOF
Usage: install_command_line_tools [-h|--help]

Installs Xcode Command Line Tools if they are not already present.
EOF
}

install_command_line_tools() {
  if xcode-select -p >/dev/null 2>&1; then
    log "Command Line Tools already installed"
  else
    log "Installing Command Line Tools..."
    xcode-select --install
  fi
}

case "${1:-}" in
  -h|--help) show_usage ;;
  "") install_command_line_tools ;;
  *) die "Unknown option: $1" ;;
esac
