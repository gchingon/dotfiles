#!/usr/bin/env bash
# ln ~/.config/rx/find-and-do.sh ~/.local/bin/findo
# A general purpose script to find files and perform an action (move, delete).

usage() {
  echo "Usage: $(basename "$0") <action> --pattern <pattern> [options]"
  echo
  echo "Actions:"
  echo "  move    <destination>   - Move found files to a destination directory."
  echo "  rm                      - Delete found files."
  echo
  echo "Options:"
  echo "  --pattern <pattern>     - (Required) The pattern to search for."
  echo "  --exclude <dir>         - Directory/pattern to exclude from search."
  echo "  --type <f|d>            - Search for files (f) or directories (d)."
  echo "  --in <path>             - The directory to search in (default: current)."
  echo "  --depth <num>           - Set max search depth."
  echo "  --ext <extension>       - Search by file extension."
  exit 1
}

# Default values
ACTION="$1"
shift
SEARCH_PATH="."
FD_OPTS=()

# Parse arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
  --pattern)
    FD_OPTS+=("$2")
    shift 2
    ;;
  --exclude)
    FD_OPTS+=("--exclude" "$2")
    shift 2
    ;;
  --type)
    FD_OPTS+=("--type" "$2")
    shift 2
    ;;
  --in)
    SEARCH_PATH="$2"
    shift 2
    ;;
  --depth)
    FD_OPTS+=("--max-depth" "$2")
    shift 2
    ;;
  --ext)
    FD_OPTS+=("--extension" "$2")
    shift 2
    ;;
  *) usage ;;
  esac
done

case "$ACTION" in
move)
  DESTINATION="$1"
  [ -z "$DESTINATION" ] && echo "Error: 'move' action requires a destination." && usage
  echo "Moving files to '$DESTINATION'..."
  fd "${FD_OPTS[@]}" "$SEARCH_PATH" -x mv {} "$DESTINATION"
  ;;
rm)
  echo "Deleting files..."
  fd "${FD_OPTS[@]}" "$SEARCH_PATH" -x rm -rfv {}
  ;;
*)
  echo "Error: Unknown action '$ACTION'"
  usage
  ;;
esac

echo "Action '$ACTION' complete."
