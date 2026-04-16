#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$HOME/.config/rx/agent-vault-lib.sh"

TITLE="${1:-codex-memory-backup}"
SHIFTED="false"
if [[ $# -gt 0 ]]; then
  shift
  SHIFTED="true"
fi

SUMMARY="${*:-Summarize the current conversation, active work, and next best continuation point.}"
STAMP="$(agent_vault_now_slug)"
SLUG="$(
  printf '%s' "$TITLE" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs '[:alnum:]' '-' \
    | sed 's/^-*//; s/-*$//'
)"
FILE="$AGENT_VAULT_PATH/codex/${STAMP}-${SLUG}.md"

agent_vault_ensure_structure

cat > "$FILE" <<EOF
# ${TITLE}

- current objective: Preserve high-signal memory before compaction or context switching
- repo/project path: \`$(pwd)\`
- what changed:
  - machine: \`$AGENT_VAULT_MACHINE\`
  - timestamp: $(agent_vault_now_iso)
  - note type: Codex memory backup
- blocking issues:
  - Fill in unresolved questions or blockers before checkpointing if needed
- recommended next agent: codex
- exact next command or file to inspect:
  - \`agent-vault-status\`
  - \`$(basename "$FILE")\`

## Summary To Fill In

$SUMMARY
EOF

agent_vault_write_state "memory-backup" "Created $(basename "$FILE")"
printf '%s\n' "$FILE"
