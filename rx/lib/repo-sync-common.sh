#!/usr/bin/env bash

# Shared helpers for repo sync / pull peer scripts.

repo_sync_usage_suffix() {
  printf '%s\n' '[config|notes|crypt|agent-vault|pod-content|current] [-n|--dry-run]'
}

repo_sync_current_machine() {
  if [[ -n "${MACHINE_NAME:-}" ]]; then
    printf '%s\n' "$MACHINE_NAME"
  else
    hostname -s 2>/dev/null || hostname 2>/dev/null || printf 'unknown\n'
  fi
}

repo_sync_ssh_target_for_machine() {
  local machine="$1"
  case "$machine" in
    mbp*) printf '%s\n' 'schingon@mbp.local' ;;
    2mini*) printf '%s\n' '2chingon@192.168.1.153' ;;
    4mini*) printf '%s\n' 'salvajechingon@4mini-de-gallo.local' ;;
    *) return 1 ;;
  esac
}

repo_sync_path_for_machine() {
  local repo="$1" machine="$2"
  case "$machine" in
    mbp*)
      case "$repo" in
        config) printf '%s\n' '/Users/schingon/.config' ;;
        notes) printf '%s\n' '/Users/schingon/Documents/notes' ;;
        crypt|agent-vault) printf '%s\n' '/Users/schingon/Documents/crypt' ;;
        pod-content) printf '%s\n' '/Users/schingon/Documents/pod-content' ;;
      esac
      ;;
    2mini*)
      case "$repo" in
        config) printf '%s\n' '/Users/2chingon/.config' ;;
        notes) printf '%s\n' '/Users/2chingon/Documents/2mepos/notes' ;;
        crypt|agent-vault) printf '%s\n' '/Users/2chingon/Documents/2mepos/crypt' ;;
        pod-content) printf '%s\n' '/Users/2chingon/Documents/2mepos/pod-content' ;;
      esac
      ;;
    4mini*)
      case "$repo" in
        config) printf '%s\n' '/Users/salvajechingon/.config' ;;
        notes) printf '%s\n' '/Users/salvajechingon/Documents/repos/notes' ;;
        crypt|agent-vault) printf '%s\n' '/Users/salvajechingon/Documents/repos/crypt' ;;
        pod-content) printf '%s\n' '/Users/salvajechingon/Documents/repos/pod-content' ;;
      esac
      ;;
    *)
      return 1
      ;;
  esac
}

repo_sync_detect_current_repo_name() {
  local root base prefix first_component
  root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
  prefix="$(git rev-parse --show-prefix 2>/dev/null || true)"
  first_component="${prefix%%/*}"
  case "$first_component" in
    notes|crypt|agent-vault|pod-content)
      printf '%s\n' "$first_component"
      return 0
      ;;
  esac
  base="$(basename "$root")"
  case "$base" in
    .config) printf '%s\n' config ;;
    notes|crypt|agent-vault|pod-content) printf '%s\n' "$base" ;;
    *) return 1 ;;
  esac
}

repo_sync_validate_repo_name() {
  case "${1:-}" in
    config|notes|crypt|agent-vault|pod-content) return 0 ;;
    *) return 1 ;;
  esac
}
