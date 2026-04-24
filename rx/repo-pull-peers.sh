#!/usr/bin/env bash

set -euo pipefail

if [[ -f "$HOME/.config/machine.env" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.config/machine.env"
fi

# shellcheck disable=SC1091
source "$HOME/.config/rx/lib/repo-sync-common.sh"

usage() {
  cat <<EOF
Usage: repo-pull-peers.sh [config|notes|crypt|agent-vault|pod-content|current] [-n|--dry-run]

SSH to peer machines and run:
  git -C <repo> pull --ff-only
EOF
}

pull_peer() {
  local repo="$1" machine="$2" dry_run="$3"
  local repo_path ssh_target remote_cmd

  repo_path="$(repo_sync_path_for_machine "$repo" "$machine")" || {
    printf '[repo-pull] %s: unknown repo path mapping for %s\n' "$machine" "$repo" >&2
    return 1
  }
  ssh_target="$(repo_sync_ssh_target_for_machine "$machine")" || {
    printf '[repo-pull] %s: unknown ssh target\n' "$machine" >&2
    return 1
  }
  remote_cmd="if [ -d \"$repo_path/.git\" ]; then git -C \"$repo_path\" pull --ff-only; else echo \"missing repo: $repo_path\"; exit 3; fi"

  if [[ "$dry_run" == "true" ]]; then
    printf '[repo-pull] %s -> ssh %s %q\n' "$machine" "$ssh_target" "$remote_cmd"
    return 0
  fi

  if ssh -o BatchMode=yes -o ConnectTimeout=8 "$ssh_target" "$remote_cmd"; then
    printf '[repo-pull] %s: ok\n' "$machine"
  else
    printf '[repo-pull] %s: failed\n' "$machine" >&2
    return 1
  fi
}

main() {
  local repo="${1:-}" dry_run="false"
  [[ -n "$repo" ]] || { usage; exit 1; }
  shift || true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--dry-run) dry_run="true"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
  done

  if [[ "$repo" == "current" ]]; then
    repo="$(repo_sync_detect_current_repo_name)" || {
      echo "[repo-pull] Current repo is not one of: config, notes, crypt, agent-vault, pod-content" >&2
      exit 1
    }
  fi

  repo_sync_validate_repo_name "$repo" || { echo "Unknown repo: $repo" >&2; usage; exit 1; }

  local here failed=0
  here="$(repo_sync_current_machine)"
  local peers=(mbp 2mini 4mini)

  for machine in "${peers[@]}"; do
    [[ "$machine" == "$here" ]] && continue
    pull_peer "$repo" "$machine" "$dry_run" || failed=1
  done

  return "$failed"
}

main "$@"
