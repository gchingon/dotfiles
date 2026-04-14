#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$HOME/.config/rx/agent-vault-lib.sh"

agent_vault_require_repo
agent_vault_ensure_structure

if ! agent_vault_has_remote; then
  agent_vault_log "No origin remote configured. Local repo is ready; set AGENT_VAULT_REMOTE when the central bare repo exists."
  exit 0
fi

if ! agent_vault_remote_fetch; then
  agent_vault_fail "Could not fetch origin/$AGENT_VAULT_BRANCH"
fi

LOCAL_HEAD="$(agent_vault_git rev-parse HEAD)"
REMOTE_REF="$(agent_vault_upstream_ref)"
REMOTE_HEAD="$(agent_vault_git rev-parse "$REMOTE_REF" 2>/dev/null || true)"
DIRTY="$(agent_vault_git status --short)"

if [[ -z "$REMOTE_HEAD" ]]; then
  if agent_vault_git push -u origin "$AGENT_VAULT_BRANCH"; then
    agent_vault_log "Published initial branch to origin."
    exit 0
  fi
  agent_vault_fail "Initial push to origin failed."
fi

if [[ "$LOCAL_HEAD" == "$REMOTE_HEAD" ]]; then
  agent_vault_log "Already up to date."
  exit 0
fi

if agent_vault_git merge-base --is-ancestor "$LOCAL_HEAD" "$REMOTE_HEAD"; then
  if [[ -n "$DIRTY" ]]; then
    REPORT="$(agent_vault_conflict_report "Remote is ahead, but local working tree has uncommitted changes")"
    agent_vault_write_state "conflict" "Remote ahead while dirty; report at $REPORT"
    agent_vault_fail "Remote is ahead and working tree is dirty. Review $REPORT"
  fi
  agent_vault_git merge --ff-only "$REMOTE_REF"
  agent_vault_log "Fast-forwarded from origin."
  exit 0
fi

if agent_vault_git merge-base --is-ancestor "$REMOTE_HEAD" "$LOCAL_HEAD"; then
  agent_vault_git push origin "$AGENT_VAULT_BRANCH"
  agent_vault_log "Pushed local commits to origin."
  exit 0
fi

REPORT="$(agent_vault_conflict_report "Local and remote branches diverged")"
agent_vault_write_state "conflict" "Branches diverged; report at $REPORT"
agent_vault_fail "Local and remote history diverged. Review $REPORT"
