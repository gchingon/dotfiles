#!/usr/bin/env bash
# Ensures ssh-agent is running and the key is loaded.
if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" >/dev/null; then
  echo "Initializing new SSH agent..."
  eval "$(ssh-agent -s)"
  ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
else
  echo "SSH agent is already running (PID: $SSH_AGENT_PID)."
fi
