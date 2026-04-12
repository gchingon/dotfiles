#!/usr/bin/env bash
# ln ~/.config/rx/setup_ssh.sh ~/.local/bin/setupssh
# One-time SSH key setup + runtime agent management.

source "$(dirname "$0")/lib/common.sh"

setup_ssh() {
  if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
    log "SSH key already exists"
  else
    log "Generating SSH key..."
    ssh-keygen -t ed25519 -C "gchingon@proton.me" || die "Failed to generate SSH key"
  fi

  log "Writing SSH config..."
  mkdir -p "$HOME/.ssh"
  cat > "$HOME/.ssh/config" <<'EOF'
Host github.com
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOF

  ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" || die "Failed to add SSH key to keychain"
  log "SSH setup complete"
}

ensure_agent() {
  if [[ -z "${SSH_AGENT_PID:-}" ]] || ! ps -p "$SSH_AGENT_PID" >/dev/null 2>&1; then
    log "Starting SSH agent..."
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
  else
    log "SSH agent running (PID: $SSH_AGENT_PID)"
  fi
}

show_help() {
  cat <<'EOF'
Usage: setupssh [-s|--setup | -a|--agent | -h|--help]

  -s, --setup   Generate key and write SSH config (one-time)
  -a, --agent   Ensure ssh-agent is running and key loaded
  (no args) Run both setup and agent
EOF
}

case "${1:-}" in
  -s|--setup) setup_ssh ;;
  -a|--agent) ensure_agent ;;
  --help|-h) show_help ;;
  "") setup_ssh; ensure_agent ;;
  *) die "Unknown option: $1. Use --help for usage." ;;
esac
