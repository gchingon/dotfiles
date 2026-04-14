#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$HOME/.config/rx/agent-vault-lib.sh"

MESSAGE="${*:-}"

agent_vault_require_repo
agent_vault_ensure_structure
agent_vault_write_state "checkpointing" "Starting checkpoint"

agent_vault_git add -A

if [[ -n "$(agent_vault_git status --short)" ]]; then
  if [[ -n "$MESSAGE" ]]; then
    COMMIT_MESSAGE="checkpoint(${AGENT_VAULT_MACHINE}): $MESSAGE"
  else
    COMMIT_MESSAGE="checkpoint(${AGENT_VAULT_MACHINE}): $(agent_vault_now_iso)"
  fi
  agent_vault_git commit -m "$COMMIT_MESSAGE"
  agent_vault_log "Created commit: $COMMIT_MESSAGE"
else
  agent_vault_log "No local changes to commit."
fi

"$HOME/.config/rx/agent-vault-sync.sh"
