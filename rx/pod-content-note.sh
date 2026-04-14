#!/usr/bin/env bash

set -euo pipefail

show_usage() {
  cat <<'EOF'
Usage: podidea [--type wiki|ideation|source] [title...]

Create or open a podcast-content note in the machine-specific pod-content directory.

Behavior:
  - Title is required. If you do not pass one, the script prompts for it.
  - Type can be passed with --type or chosen interactively.
  - Filename format: YYYY-MM-slugged-title.md
  - If the exact file already exists, it opens it instead of creating a duplicate.

Examples:
  podidea --type wiki Segment dumping ground
  podidea --type ideation "Episode about mutual aid"
  podidea --type source "Article about tenant unions"
EOF
}

resolve_pod_content_dir() {
  local machine_name="" host_name=""

  [[ -f "$HOME/.config/machine.env" ]] && source "$HOME/.config/machine.env"

  machine_name="${MACHINE_NAME:-}"
  host_name="$(hostname -s 2>/dev/null || hostname 2>/dev/null || true)"

  case "${machine_name:-$host_name}" in
    mbp*)
      printf '%s\n' "$HOME/Documents/pod-content"
      ;;
    4mini*)
      printf '%s\n' "$HOME/Documents/repos/pod-content"
      ;;
    2mini*)
      printf '%s\n' "$HOME/Documents/2mepos/pod-content"
      ;;
    *)
      printf '%s\n' "$HOME/Documents/pod-content"
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

  printf '%s\n' "$slug"
}

prompt_nonempty() {
  local prompt_text="$1" value=""

  while [[ -z "$value" ]]; do
    read -r -p "$prompt_text" value
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
  done

  printf '%s\n' "$value"
}

prompt_type() {
  local reply=""

  while true; do
    read -r -p "Type [wiki/ideation/source]: " reply
    case "${reply,,}" in
      w|wiki|list|ideas)
        printf '%s\n' "wiki"
        return 0
        ;;
      i|idea|ideation|single)
        printf '%s\n' "ideation"
        return 0
        ;;
      s|source|url|pdf)
        printf '%s\n' "source"
        return 0
        ;;
    esac
  done
}

build_frontmatter() {
  local note_type="$1" title="$2" now slug target_kind source_kind source_ref

  now="$(date +%Y-%m-%d_%H:%M:%S)"
  slug="$(slugify "$title")"
  target_kind="idea"
  source_kind=""
  source_ref=""

  if [[ "$note_type" == "source" ]]; then
    source_kind="$(prompt_nonempty "Source kind [url/pdf]: ")"
    case "${source_kind,,}" in
      url|u)
        source_kind="url"
        ;;
      pdf|p)
        source_kind="pdf"
        ;;
      *)
        source_kind="other"
        ;;
    esac
    source_ref="$(prompt_nonempty "Paste source reference (URL or PDF path/filename): ")"
  fi

  cat <<EOF
---
title: "$title"
id: "$slug"
created: "$now"
updated: ""
type: "$note_type"
target: "$target_kind"
tags: []
status: "seed"
source_kind: "${source_kind}"
source_ref: "${source_ref}"
---
EOF
}

build_body() {
  local note_type="$1"

  case "$note_type" in
    wiki)
      cat <<'EOF'

# Idea Wiki

## Premise


## Running List

- 

## Possible segments

- 

## Related episodes

- 

## Notes


EOF
      ;;
    ideation)
      cat <<'EOF'

# Ideation

## Core idea


## Why it matters


## Angle


## Segments or beats

- 

## Research needed

- 

EOF
      ;;
    source)
      cat <<'EOF'

# Source Notes

## Summary


## Pull quotes or claims

- 

## Possible episode or segment hooks

- 

## Follow-up

- 

EOF
      ;;
  esac
}

main() {
  local note_type="" title="" pod_dir month_stamp slug file_path

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_usage
        exit 0
        ;;
      --type)
        shift
        [[ $# -gt 0 ]] || { echo "Missing value for --type" >&2; exit 1; }
        note_type="${1,,}"
        ;;
      --type=*)
        note_type="${1#*=}"
        note_type="${note_type,,}"
        ;;
      *)
        if [[ -n "$title" ]]; then
          title+=" "
        fi
        title+="$1"
        ;;
    esac
    shift
  done

  case "$note_type" in
    "" )
      note_type="$(prompt_type)"
      ;;
    wiki|ideation|source)
      ;;
    *)
      echo "Invalid type: $note_type" >&2
      echo "Use one of: wiki, ideation, source" >&2
      exit 1
      ;;
  esac

  if [[ -z "$title" ]]; then
    title="$(prompt_nonempty "Title: ")"
  fi

  slug="$(slugify "$title")"
  [[ -n "$slug" ]] || { echo "Unable to build a valid slug from title" >&2; exit 1; }

  pod_dir="$(resolve_pod_content_dir)"
  month_stamp="$(date +%Y-%m)"
  file_path="${pod_dir}/${month_stamp}-${slug}.md"

  mkdir -p "$pod_dir"

  if [[ ! -e "$file_path" ]]; then
    {
      build_frontmatter "$note_type" "$title"
      build_body "$note_type"
    } > "$file_path"
  fi

  exec nvim "$file_path"
}

main "$@"
