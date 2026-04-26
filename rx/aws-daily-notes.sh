#!/usr/bin/env bash

set -euo pipefail

show_usage() {
  cat <<'EOF'
Usage: daws [title...]

Create or open today's note in $RP/aws.

Behavior:
  - No title: open an existing YYYY-MM-DD-*.md note for today if one exists.
  - With title: open YYYYMMDD-slugged-title.md if it exists, otherwise create it.

Examples:
  daws
  daws Project kickoff
  daws "Ideas / wins & next steps"
EOF
}

resolve_notes_dir() {
  printf '%s\n' "${RP:-$HOME/Documents}/aws"
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
  local today daily_stamp notes_dir suffix file_path

  case "${1:-}" in
    -h|--help)
      show_usage
      exit 0
      ;;
  esac

  today="$(date +%F)"
  daily_stamp="$(date +%Y%m%d)"
  notes_dir="$(resolve_notes_dir)"

  if [[ $# -gt 0 ]]; then
    suffix="$(slugify "$*")"
    file_path="${notes_dir}/${daily_stamp}-${suffix}.md"
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
