#!/usr/bin/env bash

set -euo pipefail

AGENT_VAULT_CONFIG="${AGENT_VAULT_CONFIG:-$HOME/.config/agent-vault.env}"

if [[ -f "$HOME/.config/machine.env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.config/machine.env"
fi

if [[ -f "$AGENT_VAULT_CONFIG" ]]; then
  # shellcheck disable=SC1090
  source "$AGENT_VAULT_CONFIG"
fi

AGENT_VAULT_PATH="${AGENT_VAULT_PATH:-$HOME/Documents/agent-vault}"
AGENT_VAULT_BRANCH="${AGENT_VAULT_BRANCH:-main}"
AGENT_VAULT_REMOTE="${AGENT_VAULT_REMOTE:-}"
AGENT_VAULT_HOME_WIFI="${AGENT_VAULT_HOME_WIFI:-}"

agent_vault_machine_name() {
  if [[ -n "${MACHINE_NAME:-}" ]]; then
    printf '%s\n' "$MACHINE_NAME"
  else
    hostname -s 2>/dev/null || hostname 2>/dev/null || printf 'unknown\n'
  fi
}

AGENT_VAULT_MACHINE="$(agent_vault_machine_name)"

agent_vault_now_iso() {
  date '+%Y-%m-%d %H:%M:%S %Z'
}

agent_vault_now_slug() {
  date '+%Y%m%d-%H%M%S'
}

agent_vault_log() {
  printf '[agent-vault] %s\n' "$*"
}

agent_vault_fail() {
  printf '[agent-vault] ERROR: %s\n' "$*" >&2
  exit 1
}

agent_vault_repo_exists() {
  [[ -d "$AGENT_VAULT_PATH/.git" ]]
}

agent_vault_ensure_structure() {
  mkdir -p \
    "$AGENT_VAULT_PATH/shared" \
    "$AGENT_VAULT_PATH/codex" \
    "$AGENT_VAULT_PATH/claude" \
    "$AGENT_VAULT_PATH/hermes" \
    "$AGENT_VAULT_PATH/openclaw" \
    "$AGENT_VAULT_PATH/handoffs" \
    "$AGENT_VAULT_PATH/state"
}

agent_vault_git() {
  git -C "$AGENT_VAULT_PATH" "$@"
}

agent_vault_has_remote() {
  agent_vault_git remote get-url origin >/dev/null 2>&1
}

agent_vault_upstream_ref() {
  printf 'origin/%s\n' "$AGENT_VAULT_BRANCH"
}

agent_vault_json_escape() {
  local value="${1:-}"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  printf '%s' "$value"
}

agent_vault_write_state() {
  local mode="${1:-idle}"
  local detail="${2:-}"
  local branch="(none)"
  local head="(none)"
  local dirty="false"
  local ahead="0"
  local behind="0"
  local remote=""
  local state_file

  agent_vault_ensure_structure

  if agent_vault_repo_exists; then
    branch="$(agent_vault_git rev-parse --abbrev-ref HEAD 2>/dev/null || printf '(detached)')"
    head="$(agent_vault_git rev-parse --short HEAD 2>/dev/null || printf '(none)')"
    if [[ -n "$(agent_vault_git status --short 2>/dev/null)" ]]; then
      dirty="true"
    fi
    if agent_vault_has_remote; then
      remote="$(agent_vault_git remote get-url origin 2>/dev/null || true)"
      if agent_vault_git show-ref --verify --quiet "refs/remotes/$(agent_vault_upstream_ref)"; then
        read -r ahead behind < <(
          agent_vault_git rev-list --left-right --count "$(agent_vault_upstream_ref)...HEAD" 2>/dev/null \
            | awk '{print $2" "$1}'
        )
      fi
    fi
  fi

  state_file="$AGENT_VAULT_PATH/state/${AGENT_VAULT_MACHINE}.json"
  cat > "$state_file" <<EOF
{
  "machine": "$(agent_vault_json_escape "$AGENT_VAULT_MACHINE")",
  "timestamp": "$(agent_vault_json_escape "$(agent_vault_now_iso)")",
  "mode": "$(agent_vault_json_escape "$mode")",
  "detail": "$(agent_vault_json_escape "$detail")",
  "path": "$(agent_vault_json_escape "$AGENT_VAULT_PATH")",
  "branch": "$(agent_vault_json_escape "$branch")",
  "head": "$(agent_vault_json_escape "$head")",
  "dirty": $dirty,
  "ahead": $ahead,
  "behind": $behind,
  "remote": "$(agent_vault_json_escape "$remote")"
}
EOF
}

agent_vault_conflict_report() {
  local reason="${1:-manual review required}"
  local file="$AGENT_VAULT_PATH/handoffs/conflict-$(agent_vault_now_slug)-${AGENT_VAULT_MACHINE}.md"
  local branch local_head remote_head status_summary diff_summary

  branch="$(agent_vault_git rev-parse --abbrev-ref HEAD 2>/dev/null || printf '%s' "$AGENT_VAULT_BRANCH")"
  local_head="$(agent_vault_git rev-parse --short HEAD 2>/dev/null || printf '(none)')"
  remote_head="$(agent_vault_git rev-parse --short "$(agent_vault_upstream_ref)" 2>/dev/null || printf '(none)')"
  status_summary="$(agent_vault_git status --short 2>/dev/null || true)"
  diff_summary="$(agent_vault_git diff --name-only 2>/dev/null || true)"

  cat > "$file" <<EOF
# Conflict Report

- current objective: Resolve synchronization conflict before additional agent work
- repo/project path: \`$AGENT_VAULT_PATH\`
- what changed:
  - machine: \`$AGENT_VAULT_MACHINE\`
  - branch: \`$branch\`
  - local head: \`$local_head\`
  - remote head: \`$remote_head\`
  - reason: $reason
- blocking issues:
  - Local and remote state cannot be reconciled with a fast-forward-only sync
  - Review the changed files below before continuing
- recommended next agent: Claude Code or OpenClaw reviewer
- exact next command or file to inspect:
  - \`cd "$AGENT_VAULT_PATH" && git status\`
  - \`cd "$AGENT_VAULT_PATH" && git log --oneline --decorate --graph --all -20\`

## Changed Files

\`\`\`
$diff_summary
\`\`\`

## Working Tree Status

\`\`\`
$status_summary
\`\`\`
EOF

  printf '%s\n' "$file"
}

agent_vault_require_repo() {
  agent_vault_repo_exists || agent_vault_fail "Vault repo not initialized at $AGENT_VAULT_PATH. Run: agent-vault-init"
}

agent_vault_remote_fetch() {
  agent_vault_has_remote || return 1
  agent_vault_git fetch origin "$AGENT_VAULT_BRANCH"
}
