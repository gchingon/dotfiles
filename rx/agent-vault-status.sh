#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$HOME/.config/rx/agent-vault-lib.sh"

agent_vault_ensure_structure

printf 'Agent vault path: %s\n' "$AGENT_VAULT_PATH"
printf 'Machine: %s\n' "$AGENT_VAULT_MACHINE"
printf 'Branch: %s\n' "$AGENT_VAULT_BRANCH"
printf 'Configured remote: %s\n' "${AGENT_VAULT_REMOTE:-"(unset)"}"

if ! agent_vault_repo_exists; then
  printf 'Repo: not initialized\n'
  exit 0
fi

CURRENT_BRANCH="$(agent_vault_git rev-parse --abbrev-ref HEAD 2>/dev/null || printf '(detached)')"
CURRENT_HEAD="$(agent_vault_git rev-parse --short HEAD 2>/dev/null || printf '(none)')"
DIRTY_OUTPUT="$(agent_vault_git status --short)"

printf 'Repo branch: %s\n' "$CURRENT_BRANCH"
printf 'HEAD: %s\n' "$CURRENT_HEAD"

if [[ -n "$DIRTY_OUTPUT" ]]; then
  printf 'Working tree: dirty\n'
else
  printf 'Working tree: clean\n'
fi

if agent_vault_has_remote; then
  if agent_vault_remote_fetch >/dev/null 2>&1; then
    if agent_vault_git show-ref --verify --quiet "refs/remotes/$(agent_vault_upstream_ref)"; then
      read -r AHEAD BEHIND < <(
        agent_vault_git rev-list --left-right --count "$(agent_vault_upstream_ref)...HEAD" 2>/dev/null \
          | awk '{print $2" "$1}'
      )
      printf 'Remote: %s\n' "$(agent_vault_git remote get-url origin)"
      printf 'Ahead: %s\n' "$AHEAD"
      printf 'Behind: %s\n' "$BEHIND"
    else
      printf 'Remote: %s (branch not published yet)\n' "$(agent_vault_git remote get-url origin)"
    fi
  else
    printf 'Remote: configured but fetch failed\n'
  fi
else
  printf 'Remote: none configured\n'
fi

printf '\nRecent handoffs:\n'
find "$AGENT_VAULT_PATH/handoffs" -maxdepth 1 -type f -name '*.md' -print 2>/dev/null | sort | tail -n 5

printf '\nState files:\n'
find "$AGENT_VAULT_PATH/state" -maxdepth 1 -type f -name '*.json' -print 2>/dev/null | sort
