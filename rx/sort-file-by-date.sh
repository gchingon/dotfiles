#!/usr/bin/env bash
# ln ~/.config/rx/sort-file-by-date.sh ~/.local/bin/bydate

set -euo pipefail

show_usage() {
  cat <<EOF
Usage: bydate [-d|--daily] <source_directory>

Default:
  Sort dated files into YYYY/

Options:
  -d, --daily  Sort into YYYY/MM/YYYY-MM-DD-filename.ext
  -h, --help   Show this help
EOF
}

daily=false
case "${1:-}" in
  -h|--help) show_usage; exit 0 ;;
  -d|--daily) daily=true; shift ;;
esac

source_dir="${1:-}"
[[ -n "$source_dir" && -d "$source_dir" ]] || { show_usage; exit 1; }

for path in "$source_dir"/*; do
  [[ -f "$path" ]] || continue
  base="$(basename "$path")"
  date_str="$(printf '%s\n' "$base" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1 || true)"
  [[ -n "$date_str" ]] || { echo "Skipping $base (no YYYY-MM-DD found)"; continue; }
  year="${date_str:0:4}"
  month="${date_str:5:2}"
  if $daily; then
    stem="${base#$date_str-}"
    target_dir="$source_dir/$year/$month"
    target_name="${date_str}-${stem}"
  else
    target_dir="$source_dir/$year"
    target_name="$base"
  fi
  mkdir -p "$target_dir"
  mv "$path" "$target_dir/$target_name"
done
