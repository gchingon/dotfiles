#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<EOF
Usage: install-peer-ssh-key.sh [2mini|4mini|all]

Appends ~/.ssh/id_ed25519.pub to the peer machine(s) authorized_keys.
Prompts may appear if password auth is still required.
EOF
}

append_key() {
  local host="$1"
  local pubkey
  pubkey="$(cat "$HOME/.ssh/id_ed25519.pub")"
  ssh "$host" "umask 077; mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; grep -qxF '$pubkey' ~/.ssh/authorized_keys || printf '%s\n' '$pubkey' >> ~/.ssh/authorized_keys"
}

target="${1:-all}"
case "$target" in
  -h|--help) usage; exit 0 ;;
  2mini) append_key 2mini ;;
  4mini) append_key 4mini ;;
  all) append_key 2mini; append_key 4mini ;;
  *) echo "Unknown target: $target" >&2; usage; exit 1 ;;
esac
