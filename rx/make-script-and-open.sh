#!/bin/bash
# ln ~/.config/rx/make-script-and-open.sh ~/.local/bin/mkd
# Hardlinked to ~/.local/bin/mkrx

# mkrx - Create blank executable script and open in Neovim
# Usage: mkrx <script_name>[.sh|.py|.go]

set -euo pipefail

# Define the base directory for scripts
RX="$HOME/.config/rx"

# Determine script type from extension or default to bash
determine_script_type() {
  local script_name="$1"

  if [[ "$script_name" == *.sh ]]; then
    echo "bash"
    return
  elif [[ "$script_name" == *.py ]]; then
    echo "python"
    return
  elif [[ "$script_name" == *.go ]]; then
    echo "go"
    return
  else
    # Default to bash if no extension provided
    echo "bash"
    return
  fi
}

# Create a blank script file based on type
create_script_file() {
  local script_name="$1"
  local script_type="$2"
  local script_file=""
  local script_dir=""

  case "$script_type" in
  bash)
    # If no extension provided, add .sh
    if [[ "$script_name" != *.sh ]]; then
      script_name="${script_name}.sh"
    fi
    script_file="$RX/${script_name}"
    script_dir="$(dirname "$script_file")"
    ;;
  python)
    # If no extension provided, add .py
    if [[ "$script_name" != *.py ]]; then
      script_name="${script_name}.py"
    fi
    script_file="$RX/${script_name}"
    script_dir="$(dirname "$script_file")"
    ;;
  go)
    # For Go, create a directory structure
    if [[ "$script_name" == *.go ]]; then
      # Remove .go extension for directory name
      script_name="${script_name%.go}"
    fi
    script_dir="$RX/${script_name}"
    script_file="$script_dir/main.go"
    ;;
  *)
    echo "❌ Unsupported script type: $script_type"
    return 1
    ;;
  esac

  # Check if script already exists
  if [ -f "$script_file" ]; then
    echo "❌ (눈︿눈) Script '$script_file' already exists."
    return 1
  fi

  # Create directory if it doesn't exist
  mkdir -p "$script_dir"

  # Create empty file
  touch "$script_file"

  # Make bash/python scripts executable
  case "$script_type" in
  bash | python)
    chmod +x "$script_file"
    ;;
  go)
    # For Go, also create a minimal go.mod file if it doesn't exist
    local go_mod_file="$script_dir/go.mod"
    if [ ! -f "$go_mod_file" ]; then
      echo "module $script_name" >"$go_mod_file"
      echo "" >>"$go_mod_file"
      echo "go 1.21" >>"$go_mod_file"
    fi
    ;;
  esac

  echo "✅ Created empty script: $script_file"
  return 0
}

# Open the script file in Neovim
open_script_file_in_editor() {
  local script_file="$1"

  if [ ! -f "$script_file" ]; then
    echo "❌ (눈︿눈) Script '$script_file' not found."
    return 1
  fi

  nvim "$script_file"
}

# Build/compile script after editing (only if file has content)
post_edit_actions() {
  local script_name="$1"
  local script_type="$2"
  local script_file="$3"

  # Skip checks if file is empty
  if [ ! -s "$script_file" ]; then
    echo "ℹ️  File is empty, skipping syntax/build checks."
    return 0
  fi

  case "$script_type" in
  bash)
    # Check syntax
    if bash -n "$script_file" 2>/dev/null; then
      echo "✅ Bash syntax check passed."
    else
      echo "❌ Bash syntax check failed."
    fi
    ;;
  python)
    # Check syntax
    if python3 -m py_compile "$script_file" 2>/dev/null; then
      echo "✅ Python syntax check passed."
      # Clean up the __pycache__ directory if created
      rm -rf "$(dirname "$script_file")/__pycache__"
    else
      echo "❌ Python syntax check failed."
    fi
    ;;
  go)
    # Build Go program only if there's actual code
    script_dir="$(dirname "$script_file")"
    if (cd "$script_dir" && go build -o "$(basename "$script_dir")" 2>/dev/null); then
      echo "✅ Go build successful: $script_dir/$(basename "$script_dir")"
      # Create symlink in ~/.local/bin if it doesn't exist
      local bin_path="$HOME/.local/bin/$(basename "$script_dir")"
      if [ ! -f "$bin_path" ] && [ ! -L "$bin_path" ]; then
        ln -s "$script_dir/$(basename "$script_dir")" "$bin_path"
        echo "✅ Created symlink in ~/.local/bin/$(basename "$script_dir")"
      fi
    else
      echo "ℹ️  Go build skipped (likely empty file or build errors)."
    fi
    ;;
  esac
}

# Create and open script
create_script_and_open() {
  local script_name="$1"
  local script_type=$(determine_script_type "$script_name")
  local script_file=""

  # Determine the full script file path based on type
  case "$script_type" in
  bash)
    if [[ "$script_name" != *.sh ]]; then
      script_name="${script_name}.sh"
    fi
    script_file="$RX/${script_name}"
    ;;
  python)
    if [[ "$script_name" != *.py ]]; then
      script_name="${script_name}.py"
    fi
    script_file="$RX/${script_name}"
    ;;
  go)
    if [[ "$script_name" == *.go ]]; then
      script_name="${script_name%.go}"
    fi
    script_file="$RX/${script_name}/main.go"
    ;;
  esac

  if create_script_file "$script_name" "$script_type"; then
    echo "ℹ️  Opening empty file in Neovim. Use your templates or copy-paste as needed."
    open_script_file_in_editor "$script_file"
    # After editing, perform any necessary post-edit actions
    post_edit_actions "$script_name" "$script_type" "$script_file"
  else
    # If file exists, ask if user wants to open it anyway
    echo -n "Would you like to open the existing script? [y/N]: "
    read -r response
    case "$response" in
    [yY] | [yY][eE][sS])
      open_script_file_in_editor "$script_file"
      post_edit_actions "$script_name" "$script_type" "$script_file"
      ;;
    *)
      echo "Operation cancelled."
      return 1
      ;;
    esac
  fi
}

# Main function
main() {
  # Check if script name provided
  if [ $# -eq 0 ]; then
    echo "❌ Error: Missing script name"
    echo "Usage: $0 <script_name>[.sh|.py|.go]"
    echo "Examples:"
    echo "  $0 my-script         # Creates an empty bash script"
    echo "  $0 my-script.sh      # Creates an empty bash script"
    echo "  $0 my-script.py      # Creates an empty Python script"
    echo "  $0 my-script.go      # Creates an empty Go program"
    exit 1
  fi

  local script_name="$1"

  # Check if Neovim is installed
  if ! command -v nvim >/dev/null 2>&1; then
    echo "❌ Error: Neovim (nvim) is not installed"
    exit 1
  fi

  # For Go scripts, check if Go is installed
  if [[ "$script_name" == *.go ]] && ! command -v go >/dev/null 2>&1; then
    echo "❌ Error: Go is not installed but required for .go scripts"
    exit 1
  fi

  create_script_and_open "$script_name"
}

# Call main function
main "$@"

