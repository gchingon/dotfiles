# Shared agent-vault helpers

export AGENT_VAULT_CONFIG="${AGENT_VAULT_CONFIG:-$HOME/.config/agent-vault.env}"

if [[ -f "$AGENT_VAULT_CONFIG" ]]; then
  source "$AGENT_VAULT_CONFIG"
fi

export AGENT_VAULT_PATH="${AGENT_VAULT_PATH:-$HOME/Documents/crypt}"

cryptsync() {
  agent-vault-sync "$@"
}

agentsync() {
  agent-vault-sync "$@"
}

vault_context() {
  local vault="${AGENT_VAULT_PATH}"
  find "${vault}/shared" "${vault}/handoffs" -type f -name '*.md' 2>/dev/null \
    | sort \
    | tail -n 10
}

vault_recent() {
  local vault="${AGENT_VAULT_PATH}"
  find "${vault}" -type f -name '*.md' -mtime -7 2>/dev/null | sort
}

vault_handoffs() {
  local vault="${AGENT_VAULT_PATH}"
  ls -lt "${vault}/handoffs"/*.md 2>/dev/null | head -20
}

vault_state() {
  local vault="${AGENT_VAULT_PATH}"
  ls -lt "${vault}/state"/*.json 2>/dev/null
}

vault_search() {
  local keyword="$1"
  local vault="${AGENT_VAULT_PATH}"

  [[ -n "$keyword" ]] || {
    echo "Usage: vault_search <keyword>"
    return 1
  }

  grep -ril "${keyword}" "${vault}/shared" "${vault}/codex" "${vault}/claude" \
    "${vault}/hermes" "${vault}/openclaw" "${vault}/handoffs" 2>/dev/null
}

vault_today() {
  local vault="${AGENT_VAULT_PATH}"
  local today
  today="$(date +%F)"
  find "${vault}" -type f -name "${today}*.md" 2>/dev/null | sort
}
