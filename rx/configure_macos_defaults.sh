#!/bin/bash

source "$(dirname "$0")/log_helpers.sh"

configure_macos_defaults() {
  if ! is_completed "macos"; then
    log "Configuring macOS defaults..."

    # You can expand this section with more commands if needed
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    defaults write NSGlobalDomain KeyRepeat -int 1
    # Add more `defaults write` commands here...

    mark_complete "macos"
  else
    log "macOS already configured"
  fi
}

configure_macos_defaults
