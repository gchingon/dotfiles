#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$HOME/.config/rx/agent-vault-lib.sh"

usage() {
  cat <<EOF
Usage: agent-vault-init [--path PATH] [--remote URL] [--bare-remote PATH] [--skip-commit]

Create the shared agent vault, initialize its Git repo, and seed the standard structure.
EOF
}

VAULT_PATH="$AGENT_VAULT_PATH"
REMOTE_URL="$AGENT_VAULT_REMOTE"
BARE_REMOTE=""
SKIP_COMMIT="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)
      VAULT_PATH="$2"
      shift 2
      ;;
    --remote)
      REMOTE_URL="$2"
      shift 2
      ;;
    --bare-remote)
      BARE_REMOTE="$2"
      shift 2
      ;;
    --skip-commit)
      SKIP_COMMIT="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      agent_vault_fail "Unknown argument: $1"
      ;;
  esac
done

export AGENT_VAULT_PATH="$VAULT_PATH"
agent_vault_ensure_structure

mkdir -p "$AGENT_VAULT_PATH/.obsidian"

cat > "$AGENT_VAULT_PATH/README.md" <<EOF
# Agent Vault

This vault is the shared markdown-first memory layer for Codex, Claude Code, Hermes, and OpenClaw.

## Layout

- \`shared/\`: cross-agent briefs, decisions, and ongoing context
- \`codex/\`: Codex-specific notes and exports
- \`claude/\`: Claude Code-specific notes and exports
- \`hermes/\`: Hermes monitor notes and scheduled run output
- \`openclaw/\`: OpenClaw plans and reviews
- \`handoffs/\`: structured next-step notes between agents and machines
- \`state/\`: machine health and sync state snapshots

## Rules

1. Sync with Git first. Do not use mtime as the source of truth.
2. Keep internal agent databases outside the vault.
3. Write summaries and handoffs here, not raw session state.
4. Prefer fast-forward-only sync; conflicts should become explicit handoff notes.
EOF

cat > "$AGENT_VAULT_PATH/.gitignore" <<'EOF'
.DS_Store
.obsidian/workspace*.json
.obsidian/workspaces*.json
.obsidian/cache/
.obsidian/plugins/*/data.json
*.swp
*.tmp
EOF

cat > "$AGENT_VAULT_PATH/handoffs/TEMPLATE.md" <<'EOF'
# Handoff Title

- current objective:
- repo/project path:
- what changed:
- blocking issues:
- recommended next agent:
- exact next command or file to inspect:
EOF

if [[ ! -d "$AGENT_VAULT_PATH/.git" ]]; then
  git -C "$AGENT_VAULT_PATH" init -b "$AGENT_VAULT_BRANCH"
fi

if [[ -n "$BARE_REMOTE" ]]; then
  mkdir -p "$BARE_REMOTE"
  if [[ ! -d "$BARE_REMOTE/refs" ]]; then
    git init --bare "$BARE_REMOTE"
  fi
  REMOTE_URL="$BARE_REMOTE"
fi

if [[ -n "$REMOTE_URL" ]]; then
  if git -C "$AGENT_VAULT_PATH" remote get-url origin >/dev/null 2>&1; then
    git -C "$AGENT_VAULT_PATH" remote set-url origin "$REMOTE_URL"
  else
    git -C "$AGENT_VAULT_PATH" remote add origin "$REMOTE_URL"
  fi
fi

agent_vault_write_state "initialized" "Vault structure refreshed"

if [[ "$SKIP_COMMIT" != "true" ]]; then
  git -C "$AGENT_VAULT_PATH" add README.md .gitignore handoffs/TEMPLATE.md state
  if [[ -n "$(git -C "$AGENT_VAULT_PATH" status --short)" ]]; then
    git -C "$AGENT_VAULT_PATH" commit -m "Initialize agent vault for $AGENT_VAULT_MACHINE"
  fi
fi

agent_vault_log "Vault ready at $AGENT_VAULT_PATH"
if [[ -n "$REMOTE_URL" ]]; then
  agent_vault_log "Origin remote: $REMOTE_URL"
else
  agent_vault_log "No origin remote configured yet. Set AGENT_VAULT_REMOTE in $AGENT_VAULT_CONFIG when ready."
fi
