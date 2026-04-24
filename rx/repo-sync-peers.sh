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
Usage: repo-sync-peers.sh [config|notes|crypt|agent-vault|pod-content|current] [-n|--dry-run]

After a successful local push, push the same branch directly into the peer
working-tree repos. Peer repos must have:
  git config receive.denyCurrentBranch updateInstead
EOF
}

ensure_ssh_key_ready() {
  if ssh-add -L >/dev/null 2>&1; then
    return 0
  fi

  echo "[repo-sync] No SSH identities are loaded in ssh-agent." >&2
  echo "[repo-sync] Run: ssh-add --apple-use-keychain ~/.ssh/id_ed25519" >&2
  return 1
}

sync_peer() {
  local repo="$1" machine="$2" local_repo_path="$3" branch="$4" dry_run="$5"
  local repo_path ssh_target remote_url remote_status
  repo_path="$(repo_sync_path_for_machine "$repo" "$machine")" || {
    printf '[repo-sync] %s: unknown repo path mapping for %s\n' "$machine" "$repo" >&2
    return 1
  }
  ssh_target="$(repo_sync_ssh_target_for_machine "$machine")" || {
    printf '[repo-sync] %s: unknown ssh target\n' "$machine" >&2
    return 1
  }
  remote_url="${ssh_target}:${repo_path}"

  if ! ssh -o BatchMode=yes -o ConnectTimeout=8 "$ssh_target" "test -d \"$repo_path/.git\""; then
    printf 'missing repo: %s\n' "$repo_path" >&2
    printf '[repo-sync] %s: failed\n' "$machine" >&2
    return 1
  fi

  remote_status="$(
    ssh -o BatchMode=yes -o ConnectTimeout=8 "$ssh_target" \
      "git -C \"$repo_path\" status --porcelain 2>/dev/null || exit 4" 2>/dev/null || true
  )"
  if [[ -n "$remote_status" ]]; then
    printf '[repo-sync] %s: peer repo is not clean:\n' "$machine" >&2
    printf '%s\n' "$remote_status" >&2
    printf '[repo-sync] %s: failed\n' "$machine" >&2
    return 1
  fi

  if [[ "$dry_run" == "true" ]]; then
    printf '[repo-sync] %s -> git -C %q push %q %q\n' "$machine" "$local_repo_path" "$remote_url" "$branch"
    return 0
  fi

  if git -C "$local_repo_path" push "$remote_url" "$branch"; then
    printf '[repo-sync] %s: ok\n' "$machine"
  else
    printf '[repo-sync] %s: failed\n' "$machine" >&2
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
      echo "[repo-sync] Current repo is not one of: config, notes, crypt, agent-vault, pod-content" >&2
      exit 1
    }
  fi

  repo_sync_validate_repo_name "$repo" || { echo "Unknown repo: $repo" >&2; usage; exit 1; }

  if [[ "$dry_run" != "true" ]]; then
    ensure_ssh_key_ready || exit 1
  fi

  local here local_repo_path branch
  here="$(repo_sync_current_machine)"
  local_repo_path="$(repo_sync_path_for_machine "$repo" "$here")" || {
    printf '[repo-sync] %s: unknown local repo path mapping for %s\n' "$here" "$repo" >&2
    exit 1
  }
  [[ -d "$local_repo_path/.git" ]] || {
    printf '[repo-sync] local repo missing: %s\n' "$local_repo_path" >&2
    exit 1
  }
  branch="$(git -C "$local_repo_path" rev-parse --abbrev-ref HEAD 2>/dev/null)" || {
    printf '[repo-sync] could not determine branch for %s\n' "$local_repo_path" >&2
    exit 1
  }
  local failed=0
  local peers=(mbp 2mini 4mini)

  for machine in "${peers[@]}"; do
    [[ "$machine" == "$here" ]] && continue
    sync_peer "$repo" "$machine" "$local_repo_path" "$branch" "$dry_run" || failed=1
  done

  return "$failed"
}

main "$@"
