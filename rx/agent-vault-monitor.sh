#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$HOME/.config/rx/agent-vault-lib.sh"

agent_vault_require_repo
agent_vault_ensure_structure

STAMP="$(agent_vault_now_slug)"
REPORT="$AGENT_VAULT_PATH/hermes/monitor-${STAMP}.md"
STATUS_OUTPUT="$("$HOME/.config/rx/agent-vault-status.sh")"
CONFLICT_COUNT="$(find "$AGENT_VAULT_PATH/handoffs" -maxdepth 1 -type f -name 'conflict-*.md' | wc -l | tr -d ' ')"
HANDOFF_COUNT="$(find "$AGENT_VAULT_PATH/handoffs" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"

cat > "$REPORT" <<EOF
# Hermes Monitor Report

- current objective: Verify vault sync health and handoff hygiene
- repo/project path: \`$AGENT_VAULT_PATH\`
- what changed:
  - machine: \`$AGENT_VAULT_MACHINE\`
  - report time: $(agent_vault_now_iso)
  - handoff count: $HANDOFF_COUNT
  - conflict report count: $CONFLICT_COUNT
- blocking issues:
  - Review any conflict report files before continuing agent work
- recommended next agent: hermes
- exact next command or file to inspect:
  - \`agent-vault-status\`
  - \`ls -lt "$AGENT_VAULT_PATH/handoffs"\`

## Status Snapshot

\`\`\`
$STATUS_OUTPUT
\`\`\`
EOF

agent_vault_write_state "monitor" "Generated $(basename "$REPORT")"

if [[ "$CONFLICT_COUNT" -gt 0 ]]; then
  printf 'ALERT: %s conflict report(s) present. Review %s\n' "$CONFLICT_COUNT" "$AGENT_VAULT_PATH/handoffs"
else
  printf 'OK: vault healthy, %s handoff note(s), report saved to %s\n' "$HANDOFF_COUNT" "$REPORT"
fi
