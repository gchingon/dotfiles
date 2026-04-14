#!/usr/bin/env bash

set -euo pipefail

show_usage() {
  cat <<'EOF'
Usage: daily [title...]

Create or open today's note in the machine-specific notes directory.

Behavior:
  - No title: open an existing YYYY-MM-DD-*.md note for today if one exists.
  - With title: open YYYY-MM-DD-slugged-title.md if it exists, otherwise create it.

Examples:
  daily
  daily Project kickoff
  daily "Ideas / wins & next steps"
EOF
}

resolve_notes_dir() {
  local machine_name="" host_name=""

  [[ -f "$HOME/.config/machine.env" ]] && source "$HOME/.config/machine.env"

  machine_name="${MACHINE_NAME:-}"
  host_name="$(hostname -s 2>/dev/null || hostname 2>/dev/null || true)"

  case "${machine_name:-$host_name}" in
    mbp*)
      printf '%s\n' "$HOME/Documents/notes/raw"
      ;;
    4mini*)
      printf '%s\n' "$HOME/Documents/repos/notes/raw"
      ;;
    2mini*)
      printf '%s\n' "$HOME/Documents/2mepos/notes/raw"
      ;;
    *)
      if [[ -n "${NT:-}" ]]; then
        printf '%s\n' "$NT"
      elif [[ -d "$HOME/Documents/notes/raw" ]]; then
        printf '%s\n' "$HOME/Documents/notes/raw"
      else
        printf '%s\n' "$HOME/notes/raw"
      fi
      ;;
  esac
}

slugify() {
  local input="$*" slug=""

  if command -v iconv >/dev/null 2>&1; then
    slug="$(
      printf '%s' "$input" \
        | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || printf '%s' "$input"
    )"
  else
    slug="$input"
  fi

  slug="$(
    printf '%s' "$slug" \
      | tr '[:upper:]' '[:lower:]' \
      | tr -cs '[:alnum:]' '-' \
      | sed 's/^-*//; s/-*$//'
  )"

  printf '%s\n' "${slug:-daily}"
}

find_existing_daily() {
  local notes_dir="$1" today="$2"
  local preferred fallback

  preferred="${notes_dir}/${today}-daily.md"

  if [[ -f "$preferred" ]]; then
    printf '%s\n' "$preferred"
    return 0
  fi

  shopt -s nullglob
  local matches=("${notes_dir}/${today}-"*.md)
  shopt -u nullglob

  if [[ ${#matches[@]} -gt 0 ]]; then
    fallback="$(printf '%s\n' "${matches[@]}" | sort | head -n 1)"
    printf '%s\n' "$fallback"
    return 0
  fi

  return 1
}

main() {
  local today notes_dir suffix file_path

  case "${1:-}" in
    -h|--help)
      show_usage
      exit 0
      ;;
  esac

  today="$(date +%F)"
  notes_dir="$(resolve_notes_dir)"

  if [[ $# -gt 0 ]]; then
    suffix="$(slugify "$*")"
    file_path="${notes_dir}/${today}-${suffix}.md"
    mkdir -p "$notes_dir"
    [[ -e "$file_path" ]] || : > "$file_path"
  else
    mkdir -p "$notes_dir"
    if file_path="$(find_existing_daily "$notes_dir" "$today")"; then
      :
    else
      file_path="${notes_dir}/${today}-daily.md"
      : > "$file_path"
    fi
  fi

  exec nvim "$file_path"
}

main "$@"
