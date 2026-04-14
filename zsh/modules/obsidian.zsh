# ~/.config/zsh/modules/obsidian.zsh
# Shared Obsidian/agent-vault helpers

export AGENT_VAULT_CONFIG="${AGENT_VAULT_CONFIG:-$HOME/.config/agent-vault.env}"

if [[ -f "$AGENT_VAULT_CONFIG" ]]; then
  source "$AGENT_VAULT_CONFIG"
fi

export HERMES_OBSIDIAN_VAULT="${AGENT_VAULT_PATH:-$HOME/Documents/agent-vault}"

# Obsidian CLI (if installed)
alias obs="obsidian"

# Search commands
alias obsidian_search="grep -r"
alias vault_grep="grep -r"

vault_context() {
  local vault="${HERMES_OBSIDIAN_VAULT}"
  find "${vault}/shared" "${vault}/handoffs" -type f -name '*.md' 2>/dev/null \
    | sort \
    | tail -n 10
}

vault_recent() {
  local vault="${HERMES_OBSIDIAN_VAULT}"
  find "${vault}" -type f -name '*.md' -mtime -7 2>/dev/null | sort
}

vault_handoffs() {
  local vault="${HERMES_OBSIDIAN_VAULT}"
  ls -lt "${vault}/handoffs"/*.md 2>/dev/null | head -20
}

vault_state() {
  local vault="${HERMES_OBSIDIAN_VAULT}"
  ls -lt "${vault}/state"/*.json 2>/dev/null
}

unalias vault_search 2>/dev/null || true
vault_search() {
  local keyword="$1"
  local vault="${HERMES_OBSIDIAN_VAULT}"

  [[ -n "$keyword" ]] || {
    echo "Usage: vault_search <keyword>"
    return 1
  }

  grep -ril "${keyword}" "${vault}/shared" "${vault}/codex" "${vault}/claude" \
    "${vault}/hermes" "${vault}/openclaw" "${vault}/handoffs" 2>/dev/null
}

vault_today() {
  local vault="${HERMES_OBSIDIAN_VAULT}"
  local today
  today="$(date +%F)"
  find "${vault}" -type f -name "${today}*.md" 2>/dev/null | sort
}
