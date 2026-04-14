#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$HOME/.config/rx/agent-vault-lib.sh"

usage() {
  cat <<'EOF'
Usage: agent-vault-handoff [title] [--repo PATH] [--objective TEXT] [--changed TEXT] [--blocking TEXT] [--next AGENT] [--inspect TEXT]

Create a structured handoff note in the shared vault.
EOF
}

TITLE=""
REPO_PATH="$(pwd)"
OBJECTIVE="Fill in current objective."
CHANGED="Summarize what changed."
BLOCKING="None noted."
NEXT_AGENT="claude"
INSPECT="git status"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO_PATH="$2"
      shift 2
      ;;
    --objective)
      OBJECTIVE="$2"
      shift 2
      ;;
    --changed)
      CHANGED="$2"
      shift 2
      ;;
    --blocking)
      BLOCKING="$2"
      shift 2
      ;;
    --next)
      NEXT_AGENT="$2"
      shift 2
      ;;
    --inspect)
      INSPECT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -z "$TITLE" ]]; then
        TITLE="$1"
      else
        agent_vault_fail "Unexpected argument: $1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$TITLE" ]]; then
  TITLE="handoff-$(agent_vault_now_slug)"
fi

SLUG="$(
  printf '%s' "$TITLE" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs '[:alnum:]' '-' \
    | sed 's/^-*//; s/-*$//'
)"

FILE="$AGENT_VAULT_PATH/handoffs/$(agent_vault_now_slug)-${SLUG}.md"

agent_vault_ensure_structure

cat > "$FILE" <<EOF
# $TITLE

- current objective: $OBJECTIVE
- repo/project path: \`$REPO_PATH\`
- what changed: $CHANGED
- blocking issues: $BLOCKING
- recommended next agent: $NEXT_AGENT
- exact next command or file to inspect: \`$INSPECT\`
EOF

agent_vault_write_state "handoff" "Created $(basename "$FILE")"
printf '%s\n' "$FILE"
