#!/usr/bin/env bash
# ln ~/.config/rx/file-finder-and-mover-utility.sh ~/.local/bin/filemgr
# Hardlinked to ~/.local/bin/filemgr

set -euo pipefail
source "$(dirname "$0")/lib/common.sh"
check_deps fd

ACTION=""
PATTERN=""
SEARCH_PATH="."
DESTINATION=""
TYPE="f"
DEPTH=""
EXTENSION=""
YES=false
MKDIR=false
EXCLUDES=()

show_usage() {
  cat <<EOF
Usage: filemgr <command> [args] [options]

Commands:
  find <pattern> [depth]           Legacy find form
  move <pattern> <dir>             Legacy move form
  exclude <pattern> <dir>          Legacy exclude form
  rm --pattern <pattern> [opts]    Remove matched entries

Unified options:
  --pattern <pattern>              Pattern to search for
  --exclude <name>                 Exclude path/pattern (repeatable)
  --type <f|d>                     Match files or directories
  --in <path>                      Search root (default: .)
  --depth <num>                    Max search depth
  --ext <ext>                      Match extension
  --to <dir>                       Destination for move
  --mkdir                          Create destination if missing
  -y, --yes                        Skip confirmation prompt
  -h, --help                       Show this help

Examples:
  filemgr find "*.md" 2
  filemgr move "*.mp4" videos
  filemgr move --pattern "*.mp4" --to videos --depth 2 --mkdir
  filemgr rm --pattern "*.log" --exclude node_modules -y
  filemgr exclude "*.pdf" docs
EOF
}

add_fd_filters() {
  FD_ARGS=()
  [[ -n "$TYPE" ]] && FD_ARGS+=(--type "$TYPE")
  [[ -n "$DEPTH" ]] && FD_ARGS+=(--max-depth "$DEPTH")
  [[ -n "$EXTENSION" ]] && FD_ARGS+=(--extension "$EXTENSION")
  for item in "${EXCLUDES[@]}"; do FD_ARGS+=(--exclude "$item"); done
}

collect_matches() {
  add_fd_filters
  fd "${FD_ARGS[@]}" "$PATTERN" "$SEARCH_PATH"
}

ensure_destination() {
  [[ -n "$DESTINATION" ]] || die "Move requires a destination. Use --to <dir>."
  if [[ ! -d "$DESTINATION" ]]; then
    $MKDIR && mkdir -p "$DESTINATION" || die "Destination not found: $DESTINATION"
  fi
}

confirm_or_exit() {
  local prompt="$1"
  $YES && return 0
  confirm "$prompt" || { log "Cancelled."; exit 1; }
}

parse_common_options() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --pattern) PATTERN="${2:-}"; shift 2 ;;
      --exclude) EXCLUDES+=("${2:-}"); shift 2 ;;
      --type) TYPE="${2:-}"; shift 2 ;;
      --in) SEARCH_PATH="${2:-}"; shift 2 ;;
      --depth) DEPTH="${2:-}"; shift 2 ;;
      --ext) EXTENSION="${2:-}"; shift 2 ;;
      --to) DESTINATION="${2:-}"; shift 2 ;;
      --mkdir) MKDIR=true; shift ;;
      -y|--yes) YES=true; shift ;;
      -h|--help|help) show_usage; exit 0 ;;
      *) die "Unknown option: $1" ;;
    esac
  done
}

parse_args() {
  [[ $# -gt 0 ]] || { show_usage; exit 1; }
  ACTION="$1"; shift
  case "$ACTION" in
    find)
      if [[ $# -gt 0 && "${1:-}" != --* ]]; then PATTERN="$1"; shift; fi
      if [[ $# -gt 0 && "${1:-}" != --* ]]; then DEPTH="$1"; shift; fi
      parse_common_options "$@"
      ;;
    move)
      if [[ $# -gt 0 && "${1:-}" != --* ]]; then PATTERN="$1"; shift; fi
      if [[ $# -gt 0 && "${1:-}" != --* ]]; then DESTINATION="$1"; shift; fi
      parse_common_options "$@"
      ;;
    exclude)
      [[ $# -ge 2 ]] || die "Usage: filemgr exclude <pattern> <dir>"
      PATTERN="$1"; DESTINATION="$2"; EXCLUDES+=("$2"); shift 2
      parse_common_options "$@"
      ;;
    rm|delete|remove)
      ACTION="rm"
      parse_common_options "$@"
      ;;
    -h|--help|help) show_usage; exit 0 ;;
    *) die "Unknown command: $ACTION" ;;
  esac
  [[ -n "$PATTERN" ]] || die "Missing pattern. Use --pattern <pattern>."
}

run_find() {
  collect_matches
}

run_move() {
  ensure_destination
  local matches=() line
  while IFS= read -r line; do matches+=("$line"); done < <(collect_matches)
  [[ ${#matches[@]} -gt 0 ]] || { log "No matches found."; return 0; }
  printf '%s\n' "${matches[@]}" | head -10
  [[ ${#matches[@]} -gt 10 ]] && log "... and $(( ${#matches[@]} - 10 )) more"
  confirm_or_exit "Move ${#matches[@]} item(s) to '$DESTINATION'?"
  printf '%s\0' "${matches[@]}" | xargs -0 -I{} mv -v "{}" "$DESTINATION"
}

run_rm() {
  local matches=() line
  while IFS= read -r line; do matches+=("$line"); done < <(collect_matches)
  [[ ${#matches[@]} -gt 0 ]] || { log "No matches found."; return 0; }
  printf '%s\n' "${matches[@]}" | head -10
  [[ ${#matches[@]} -gt 10 ]] && log "... and $(( ${#matches[@]} - 10 )) more"
  confirm_or_exit "Delete ${#matches[@]} item(s)?"
  printf '%s\0' "${matches[@]}" | xargs -0 rm -rfv
}

main() {
  parse_args "$@"
  case "$ACTION" in
    find) run_find ;;
    move|exclude) run_move ;;
    rm) run_rm ;;
  esac
}

main "$@"
