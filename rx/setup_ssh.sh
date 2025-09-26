#!/bin/bash
# ln ~/.config/rx/setup_ssh.sh ~/.local/bin/setupssh

source "$(dirname "$0")/log_helpers.sh"

setup_ssh() {
  if ! is_completed "ssh"; then
    log "Setting up SSH..."
    if [ ! -f ~/.ssh/id_ed25519 ]; then
      ssh-keygen -t ed25519 -C "gchingon@proton.me"
      handle_error $? "Failed to generate SSH key"
    fi
    cat >~/.ssh/config <<EOF
Host github.com
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOF
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    handle_error $? "Failed to add SSH key to keychain"
    mark_complete "ssh"
  else
    log "SSH already configured"
  fi
}
