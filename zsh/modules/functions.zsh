# ~/.config/zsh/modules/functions.zsh
#
# ===========================
# Miscellaneous Functions
# ===========================

# Centralized logging configuration
old_dir="$PWD"
LOG_DIR="$HOME/log"
mkdir -p "$LOG_DIR" 2>/dev/null

# Centralized logging function
log_message() {
  local function_name="$1"
  local level="$2"
  local message="$3"
  local log_file="${LOG_DIR}/${function_name}_$(date +%Y%m%d).log"
  local timestamp=$(date "+%Y%m%dT%H:%M:%S")
  echo "${timestamp} ${function_name} ${level}: ${message}" >> "$log_file"
  
  # Also print to stdout for INFO and ERROR
  if [[ "$level" == "INFO" || "$level" == "ERROR" ]]; then
    echo "[${level}] ${message}"
  fi
}

open-nvim-init() {
  nvim "$HOME/.config/nvim/init.lua"
}

open-ghostty() {
  nvim "$CF/ghostty/config" # $CF is exported to/from? $HOME/.config
}

reload_ghostty() {
  # Use AppleScript to send Cmd+Shift+, to Ghostty
  osascript <<EOF
tell application "System Events"
  tell application "Ghostty" to activate
  keystroke "," using {command down, shift down}
end tell
EOF
  success "Reload command sent to Ghostty."
}

