#!/usr/bin/env bash
# ln ~/.config/rx/clipboard-to-file-operations-utility.sh ~/.local/bin/clipops
#
# Hardlinked to ~/.local/bin/clipops
# Aliases:
#   ctc = clipops copy    # Copy file contents to clipboard
#   pof = clipops paste   # Paste clipboard to file (overwrite)
#   paf = clipops append  # Append clipboard to file
#   ccc = clipops cmd     # Copy command output to clipboard
#   4c  = clipops cpcmd   # Copy command and its output to clipboard

set -euo pipefail

# Load logging utility if available
SCRIPT_NAME="clipops"
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

# Check if clipboard command is available
check_clipboard_command() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v pbcopy &>/dev/null || ! command -v pbpaste &>/dev/null; then
      log_error "macOS clipboard commands (pbcopy/pbpaste) not found"
      return 1
    fi
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! command -v xclip &>/dev/null; then
      log_error "xclip not found. Please install it with your package manager"
      return 1
    fi
  else
    log_error "Unsupported operating system: $OSTYPE"
    return 1
  fi

  return 0
}

# Copy file contents to clipboard
copy_to_clipboard() {
  local file_path="$1"

  # Check if file exists
  if [[ ! -f "$file_path" ]]; then
    log_error "File '$file_path' does not exist"
    return 1
  fi

  # Copy file contents to clipboard
  if [[ "$OSTYPE" == "darwin"* ]]; then
    cat "$file_path" | pbcopy
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    cat "$file_path" | xclip -selection clipboard
  fi

  log_msg "✅" "Contents of '$file_path' copied to clipboard"
  return 0
}

# Paste clipboard contents to file (overwrite)
paste_to_file() {
  local file_path="$1"
  local action_msg=""

  # Check if file exists
  if [[ -f "$file_path" ]]; then
    action_msg="pasted to"
  else
    action_msg="created"
  fi

  # Paste clipboard contents to file
  if [[ "$OSTYPE" == "darwin"* ]]; then
    pbpaste >"$file_path"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xclip -selection clipboard -o >"$file_path"
  fi

  log_msg "✅" "Clipboard contents $action_msg '$file_path'"
  return 0
}

# Append clipboard contents to file
append_to_file() {
  local file_path="$1"

  # Check if file exists, if not, ask to create it
  if [[ ! -f "$file_path" ]]; then
    read -p "File '$file_path' does not exist. Create it? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_msg "🚫" "Operation cancelled"
      return 1
    fi
  fi

  # Append clipboard contents to file with newline
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "" >>"$file_path"
    pbpaste >>"$file_path"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "" >>"$file_path"
    xclip -selection clipboard -o >>"$file_path"
  fi

  log_msg "✅" "Clipboard contents appended to '$file_path'"
  return 0
}

# Copy command output to clipboard
copy_cmd_output() {
  local cmd="$1"

  # Execute command and copy output to clipboard
  if [[ "$OSTYPE" == "darwin"* ]]; then
    eval "$cmd" | pbcopy
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    eval "$cmd" | xclip -selection clipboard
  fi

  log_msg "✅" "Output of '$cmd' copied to clipboard"
  return 0
}

# Copy command and its output to clipboard
copy_cmd_and_output() {
  local cmd="$1"
  local output

  # Execute command and capture output
  output=$(eval "$cmd")

  # Format command and output
  local content="$cmd\n$output"

  # Copy to clipboard
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "$content" | pbcopy
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "$content" | xclip -selection clipboard
  fi

  log_msg "✅" "Command and output of '$cmd' copied to clipboard"
  return 0
}

# Show usage information
show_usage() {
  cat <<EOF
Clipboard Operations Utility

USAGE:
  clipops <command> [arguments]

COMMANDS:
  copy <file>           Copy file contents to clipboard
  paste <file>          Paste clipboard contents to file (overwrite)
  append <file>         Append clipboard contents to file
  cmd <command>         Copy command output to clipboard
  cpcmd <command>       Copy command and its output to clipboard
  help                  Show this help message

EXAMPLES:
  clipops copy ~/.bashrc
  clipops paste ~/new-file.txt
  clipops append ~/.notes
  clipops cmd "ls -la"
  clipops cpcmd "ps aux | grep bash"

ALIASES:
  ctc = clipops copy
  pof = clipops paste
  paf = clipops append
  ccc = clipops cmd
  4c  = clipops cpcmd
EOF
}

# Main function
main() {
  # Check if clipboard commands are available
  check_clipboard_command || exit 1

  # Check if command is provided
  if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
  fi

  # Parse command
  local command="$1"
  shift

  case "$command" in
  copy)
    # Check if file is provided
    if [[ $# -eq 0 ]]; then
      log_error "No file specified"
      show_usage
      exit 1
    fi
    copy_to_clipboard "$1"
    ;;
  paste)
    # Check if file is provided
    if [[ $# -eq 0 ]]; then
      log_error "No file specified"
      show_usage
      exit 1
    fi
    paste_to_file "$1"
    ;;
  append)
    # Check if file is provided
    if [[ $# -eq 0 ]]; then
      log_error "No file specified"
      show_usage
      exit 1
    fi
    append_to_file "$1"
    ;;
  cmd)
    # Check if command is provided
    if [[ $# -eq 0 ]]; then
      log_error "No command specified"
      show_usage
      exit 1
    fi
    copy_cmd_output "$*"
    ;;
  cpcmd)
    # Check if command is provided
    if [[ $# -eq 0 ]]; then
      log_error "No command specified"
      show_usage
      exit 1
    fi
    copy_cmd_and_output "$*"
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
