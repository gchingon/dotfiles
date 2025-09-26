#!/usr/bin/env bash
# ln ~/.config/rx/file-finder-and-mover-utility.sh ~/.local/bin/filemgr
# Hardlinked to ~/.local/bin/filemgr
# Aliases:
#   fdm = filemgr move     # Move files matching pattern to directory
#   fdd = filemgr exclude  # Move files matching pattern excluding directory
#   fdf = filemgr find     # Find files matching pattern in current directory

set -euo pipefail

# Load logging utility if available
SCRIPT_NAME="filemgr"
if [[ -f "$HOME/.config/rx/utils/log-util.sh" ]]; then
  source "$HOME/.config/rx/utils/log-util.sh"
  log_available=true
else
  log_available=false
fi

# Log message with emoji prefix
log_msg() {
  local emoji="$1"
  local message="$2"

  if [[ "$log_available" == true ]]; then
    log_message "$SCRIPT_NAME" "INFO" "$message"
  fi

  echo "$emoji $message"
}

# Log error message
log_error() {
  local message="$1"

  if [[ "$log_available" == true ]]; then
    log_message "$SCRIPT_NAME" "ERROR" "$message"
  fi

  echo "❌ Error: $message" >&2
}

# Check if fd command is available
check_fd_command() {
  if ! command -v fd &>/dev/null; then
    log_error "fd command not found. Please install it with your package manager"
    echo "  macOS: brew install fd"
    echo "  Linux: apt install fd-find or equivalent"
    return 1
  fi

  return 0
}

# Function to find similar directories
find_similar_directories() {
  local first_letter="$1"
  local current_dir="${2:-.}"

  log_msg "🔍" "Searching for directories starting with '$first_letter'..."
  fd -td "^${first_letter}" "$current_dir" | head -10
}

# Function to prompt user for directory creation or selection
prompt_directory_choice() {
  local target_dir="$1"
  local first_letter="${target_dir:0:1}"

  log_msg "⚠️" "SAFETY CHECK: Directory '$target_dir' does not exist!"
  echo "This prevents data loss from files being renamed instead of moved."
  echo ""
  echo "What would you like to do?"
  echo "1) Create directory '$target_dir'"
  echo "2) Choose from existing directories starting with '$first_letter'"
  echo "3) Enter a different directory name"
  echo "4) Cancel operation (recommended if unsure)"

  # Find similar directories
  local similar_dirs
  similar_dirs=$(find_similar_directories "$first_letter")

  if [ -n "$similar_dirs" ]; then
    echo ""
    log_msg "📁" "Found these directories starting with '$first_letter':"
    echo "$similar_dirs" | nl -w2 -s') '
  fi

  echo ""
  read -p "Enter your choice (1-4): " choice

  case $choice in
  1)
    log_msg "🔨" "Creating directory '$target_dir'..."
    mkdir -p "$target_dir"
    if [ $? -eq 0 ]; then
      log_msg "✅" "Successfully created directory '$target_dir'"
      echo "$target_dir"
    else
      log_error "Failed to create directory '$target_dir'"
      return 1
    fi
    ;;
  2)
    if [ -z "$similar_dirs" ]; then
      log_error "No directories found starting with '$first_letter'"
      return 1
    fi

    echo "Select a directory from the list above:"
    local dir_array=()
    while IFS= read -r line; do
      dir_array+=("$line")
    done <<<"$similar_dirs"

    read -p "Enter the number of your choice: " dir_choice
    if [[ "$dir_choice" =~ ^[0-9]+$ ]] && [ "$dir_choice" -ge 1 ] && [ "$dir_choice" -le "${#dir_array[@]}" ]; then
      local selected_dir="${dir_array[$((dir_choice - 1))]}"
      log_msg "✅" "Selected directory: $selected_dir"
      echo "$selected_dir"
    else
      log_error "Invalid selection"
      return 1
    fi
    ;;
  3)
    read -p "Enter new directory name: " new_dir
    if [ -n "$new_dir" ]; then
      if [ -d "$new_dir" ]; then
        log_msg "✅" "Using existing directory: $new_dir"
        echo "$new_dir"
      else
        read -p "Directory '$new_dir' doesn't exist. Create it? (y/n): " create_new
        if [[ "$create_new" =~ ^[Yy] ]]; then
          mkdir -p "$new_dir"
          if [ $? -eq 0 ]; then
            log_msg "✅" "Created directory '$new_dir'"
            echo "$new_dir"
          else
            log_error "Failed to create directory '$new_dir'"
            return 1
          fi
        else
          log_msg "🚫" "Operation cancelled"
          return 1
        fi
      fi
    else
      log_error "No directory name provided"
      return 1
    fi
    ;;
  4)
    log_msg "🚫" "Operation cancelled by user"
    return 1
    ;;
  *)
    log_error "Invalid choice"
    return 1
    ;;
  esac
}

# Find files matching pattern in current directory
find_files() {
  local pattern="$1"
  local depth="${2:-1}" # Default depth is 1

  # Check if pattern is provided
  if [ -z "$pattern" ]; then
    log_error "No search pattern provided"
    return 1
  fi

  log_msg "🔍" "Finding files matching pattern '$pattern' (depth: $depth)..."
  fd -tf -d "$depth" "$pattern"

  return 0
}

# Move files matching pattern to directory
move_files_to_dir() {
  # Input validation
  if [ -z "$1" ] || [ -z "$2" ]; then
    log_error "Missing required arguments"
    echo "Usage: filemgr move <pattern> <target_directory>"
    echo "Example: filemgr move '*.mp4' videos"
    return 1
  fi

  local pattern="$1"
  local target_dir="$2"
  local final_target_dir="$target_dir"

  # SAFETY CHECK: Verify target directory exists
  if [ ! -d "$target_dir" ]; then
    log_msg "🔍" "Checking target directory '$target_dir'..."
    final_target_dir=$(prompt_directory_choice "$target_dir")

    if [ $? -ne 0 ] || [ -z "$final_target_dir" ]; then
      log_error "Directory validation failed. Operation cancelled for safety."
      return 1
    fi
  fi

  # Double-check the final directory exists
  if [ ! -d "$final_target_dir" ]; then
    log_error "CRITICAL ERROR: Directory '$final_target_dir' still doesn't exist!"
    echo "This would cause data loss. Operation aborted."
    return 1
  fi

  log_msg "✅" "Using target directory: $final_target_dir"

  # Preview what will be moved
  log_msg "🔍" "Scanning for files matching pattern '$pattern'..."
  local files_found
  files_found=$(fd -tf -d 1 "$pattern")

  if [ -z "$files_found" ]; then
    log_msg "ℹ️" "No files found matching pattern '$pattern' in current directory"
    return 0
  fi

  local file_count
  file_count=$(echo "$files_found" | wc -l)

  log_msg "📋" "Found $file_count file(s) matching pattern '$pattern':"
  echo "$files_found" | head -10 # Show first 10 files

  if [ "$file_count" -gt 10 ]; then
    echo "... and $((file_count - 10)) more files"
  fi

  echo ""
  log_msg "🎯" "Target directory: $final_target_dir"
  read -p "Proceed with moving these files? (y/n): " confirm

  if [[ "$confirm" =~ ^[Yy] ]]; then
    log_msg "🚀" "Moving files..."
    # Execute the move with verbose output
    fd -tf -d 1 "$pattern" -x mv -v {} "$final_target_dir"

    if [ $? -eq 0 ]; then
      log_msg "✅" "File move operation completed successfully!"
      log_msg "📁" "Files moved to: $final_target_dir"
    else
      log_error "Some files may not have been moved successfully"
      return 1
    fi
  else
    log_msg "🚫" "Operation cancelled by user"
    return 0
  fi
}

# Move files matching pattern excluding directory
move_files_excluding_dir() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    log_error "Missing required arguments"
    echo "Usage: filemgr exclude <pattern> <exclude_dir>"
    echo "Example: filemgr exclude '*.pdf' documents"
    return 1
  fi

  local pattern="$1"
  local exclude_dir="$2"
  local final_exclude_dir="$exclude_dir"

  # Check if exclude directory exists
  if [ ! -d "$exclude_dir" ]; then
    log_msg "🔍" "Checking directory '$exclude_dir'..."
    final_exclude_dir=$(prompt_directory_choice "$exclude_dir")

    if [ $? -ne 0 ] || [ -z "$final_exclude_dir" ]; then
      log_error "Directory validation failed. Exiting."
      return 1
    fi
  fi

  # Verify the final directory exists
  if [ ! -d "$final_exclude_dir" ]; then
    log_error "Directory '$final_exclude_dir' still doesn't exist"
    return 1
  fi

  log_msg "✅" "Using directory: $final_exclude_dir"

  # Count files first
  local file_count
  file_count=$(fd -tf "$pattern" -E "$final_exclude_dir" | wc -l)

  if [ "$file_count" -eq 0 ]; then
    log_msg "ℹ️" "No files found matching pattern '$pattern' (excluding '$final_exclude_dir')"
    return 0
  fi

  log_msg "📋" "Found $file_count file(s) matching pattern '$pattern'"
  read -p "Proceed with moving files to '$final_exclude_dir'? (y/n): " confirm

  if [[ "$confirm" =~ ^[Yy] ]]; then
    log_msg "🚀" "Moving files..."
    # Find files matching the pattern, excluding the specified directory, and move them
    fd -tf "$pattern" -E "$final_exclude_dir" -x mv -v {} "$final_exclude_dir"
    log_msg "✅" "File move operation completed!"
  else
    log_msg "🚫" "Operation cancelled by user"
  fi
}

# Show usage information
show_usage() {
  cat <<EOF
File Finder and Mover Utility

USAGE:
  filemgr <command> [arguments]

COMMANDS:
  find <pattern> [depth]      Find files matching pattern in current directory
  move <pattern> <target_dir> Move files matching pattern to directory
  exclude <pattern> <dir>     Move files matching pattern excluding directory
  help                        Show this help message

EXAMPLES:
  filemgr find "*.md"         Find markdown files in current directory
  filemgr find "*.pdf" 3      Find PDF files up to 3 directories deep
  filemgr move "*.mp4" videos Move MP4 files to videos directory
  filemgr exclude "*.pdf" docs Move PDF files, excluding those in docs directory

ALIASES:
  fdf = filemgr find
  fdm = filemgr move
  fdd = filemgr exclude
EOF
}

# Main function
main() {
  # Check if fd command is available
  check_fd_command || exit 1

  # Check if command is provided
  if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
  fi

  # Parse command
  local command="$1"
  shift

  case "$command" in
  find)
    # Check if pattern is provided
    if [[ $# -eq 0 ]]; then
      log_error "No pattern specified"
      show_usage
      exit 1
    fi

    local pattern="$1"
    local depth="${2:-1}" # Default depth is 1

    find_files "$pattern" "$depth"
    ;;
  move)
    # Check if pattern and target directory are provided
    if [[ $# -lt 2 ]]; then
      log_error "Missing required arguments"
      show_usage
      exit 1
    fi

    move_files_to_dir "$1" "$2"
    ;;
  exclude)
    # Check if pattern and exclude directory are provided
    if [[ $# -lt 2 ]]; then
      log_error "Missing required arguments"
      show_usage
      exit 1
    fi

    move_files_excluding_dir "$1" "$2"
    ;;
  help)
    show_usage
    ;;
  *)
    log_error "Unknown command: $command"
    show_usage
    exit 1
    ;;
  esac
}

# Run main function
main "$@"
