#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$HOME/.config/rx/agent-vault-lib.sh"

WIFI_INFO_CMD="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
STAMP="$(date '+%Y%m%d-%H%M%S')"
LOG_DIR="$AGENT_VAULT_PATH/hermes"
LOG_FILE="$LOG_DIR/wifi-sync-${STAMP}.md"

current_ssid() {
  if [[ -x "$WIFI_INFO_CMD" ]]; then
    "$WIFI_INFO_CMD" -I 2>/dev/null | awk -F': ' '/ SSID/ {print $2; exit}'
  else
    printf '%s\n' ""
  fi
}

main() {
  local ssid

  ssid="$(current_ssid)"
  mkdir -p "$LOG_DIR"

  if [[ -z "${AGENT_VAULT_HOME_WIFI:-}" ]]; then
    echo "[agent-vault] AGENT_VAULT_HOME_WIFI is not configured."
    exit 0
  fi

  if [[ "$ssid" != "$AGENT_VAULT_HOME_WIFI" ]]; then
    echo "[agent-vault] Current SSID '$ssid' does not match home Wi-Fi '$AGENT_VAULT_HOME_WIFI'."
    exit 0
  fi

  cat > "$LOG_FILE" <<EOF
# Wi-Fi Sync Check

- current objective: Attempt a vault sync after joining the home Wi-Fi
- repo/project path: \`$AGENT_VAULT_PATH\`
- what changed:
  - machine: \`$AGENT_VAULT_MACHINE\`
  - ssid: \`$ssid\`
  - timestamp: $(agent_vault_now_iso)
- blocking issues:
  - Review sync output if the remote is unavailable or divergent
- recommended next agent: hermes
- exact next command or file to inspect:
  - \`agent-vault-status\`
  - \`agent-vault-sync\`
EOF

  if "$HOME/.config/rx/agent-vault-sync.sh"; then
    echo "[agent-vault] Home Wi-Fi sync completed."
  else
    echo "[agent-vault] Home Wi-Fi sync attempted but did not fully complete."
  fi
}

main "$@"
