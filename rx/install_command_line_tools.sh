#!/bin/bash
# filename install_command_line_tools.sh in $RX (~/.config/rx)

source "$(dirname "$0")/log_helpers.sh"

install_command_line_tools() {
  if ! is_completed "xcode"; then
    log "Installing Command Line Tools..."
    xcode-select --install
    handle_error $? "Failed to install Command Line Tools"
    mark_complete "xcode"
  else
    log "Command Line Tools already installed"
  fi
}
