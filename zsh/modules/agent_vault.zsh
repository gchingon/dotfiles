# Shared agent-vault helpers

export AGENT_VAULT_CONFIG="${AGENT_VAULT_CONFIG:-$HOME/.config/agent-vault.env}"

if [[ -f "$AGENT_VAULT_CONFIG" ]]; then
  source "$AGENT_VAULT_CONFIG"
fi

export AGENT_VAULT_PATH="${AGENT_VAULT_PATH:-$HOME/Documents/crypt}"

alias av='cd "$AGENT_VAULT_PATH"'
alias crypt='cd "$AGENT_VAULT_PATH"'
alias avi='agent-vault-init'
alias avs='agent-vault-status'
alias avsync='agent-vault-sync'
alias avc='agent-vault-checkpoint'
alias avh='agent-vault-handoff'
alias avm='agent-vault-monitor'
alias avb='agent-vault-memory-backup'
alias cryptstatus='agent-vault-status'
alias cryptcheck='agent-vault-checkpoint'

cryptsync() {
  agent-vault-sync "$@"
}

agentsync() {
  agent-vault-sync "$@"
}
