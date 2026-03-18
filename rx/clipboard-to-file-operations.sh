#!/usr/bin/env bash
# ln ~/.config/rx/clipboard-to-file-operations-utility.sh ~/.local/bin/clipops
#
# Hardlinked to ~/.local/bin/clipops
# Aliases:
#   ctc  = clipops copy    # Copy file contents to clipboard
#   pof  = clipops paste   # Paste clipboard to file (overwrite)
#   paf  = clipops append  # Append clipboard to file
#   ccc  = clipops cmd     # Copy command output to clipboard
#   4c   = clipops cpcmd   # Copy command and its output to clipboard
#   wcmd = clipops wcmd    # Copy command output wrapped in markdown block
#   wcp  = clipops wcpcmd  # Copy command + output wrapped in markdown block

set -euo pipefail

SCRIPT_NAME="clipops"
if [[ -f "$HOME/.config/rx/utils/log-util.sh" ]]; then
  source "$HOME/.config/rx/utils/log-util.sh"
  log_available=true
else
  log_available=false
fi

log_msg() {
  local emoji="$1"
  local message="$2"
  if [[ "$log_available" == true ]]; then
    log_message "$SCRIPT_NAME" "INFO" "$message"
  fi
  echo "$emoji $message"
}

log_error() {
  local message="$1"
  if [[ "$log_available" == true ]]; then
    log_message "$SCRIPT_NAME" "ERROR" "$message"
  fi
  echo "❌ Error: $message" >&2
}

# ── Clipboard helpers ────────────────────────────────────────────────────────

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

_clip_copy() {
  # Usage: echo "..." | _clip_copy
  if [[ "$OSTYPE" == "darwin"* ]]; then
    pbcopy
  elif [[ -n "${KITTY_INSTALLATION_DIR:-}" || "${TERM:-}" == "xterm-kitty" ]] && command -v kitty &>/dev/null; then
    kitty +kitten clipboard
  elif [[ "$OSTYPE" == "linux-gnu"* ]] && command -v xclip &>/dev/null; then
    xclip -selection clipboard
  else
    cat  # fallback: just emit to stdout (caller handles messaging)
    return 2
  fi
}

_clip_paste() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    pbpaste
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xclip -selection clipboard -o
  fi
}

# ── File helpers ─────────────────────────────────────────────────────────────

ensure_parent_dir() {
  local file_path="$1"
  local parent_dir
  parent_dir=$(dirname "$file_path")
  [[ "$parent_dir" == "." ]] && return 0
  if [[ ! -d "$parent_dir" ]]; then
    if ! mkdir -p "$parent_dir" 2>/dev/null; then
      log_error "No permission to create directories in '$parent_dir'"
      return 1
    fi
  fi
  return 0
}

check_write_permission() {
  local file_path="$1"
  local parent_dir
  parent_dir=$(dirname "$file_path")
  if [[ -f "$file_path" ]]; then
    [[ ! -w "$file_path" ]] && { log_error "No permission to write '$file_path'"; return 1; }
  else
    [[ ! -w "$parent_dir" ]] && { log_error "No permission to write in '$parent_dir'"; return 1; }
  fi
  return 0
}

# ── Language detection (from wrap-output-to-md-block.sh) ────────────────────

_get_lang_from_file() {
  local file="$1"
  case "$file" in
    *.*)
      echo "${file##*.}"
      ;;
    *)
      if [[ -f "$file" ]]; then
        local shebang
        shebang=$(head -n1 "$file" 2>/dev/null)
        case "$shebang" in
          "#!/bin/bash"*|"#!/usr/bin/bash"*|"#!/usr/bin/env bash"*)   echo "bash" ;;
          "#!/bin/sh"*|"#!/usr/bin/sh"*|"#!/usr/bin/env sh"*)         echo "sh" ;;
          "#!/usr/bin/python"*|"#!/usr/bin/env python"*)               echo "python" ;;
          "#!/usr/bin/python3"*|"#!/usr/bin/env python3"*)             echo "python" ;;
          "#!/usr/bin/ruby"*|"#!/usr/bin/env ruby"*)                   echo "ruby" ;;
          "#!/usr/bin/perl"*|"#!/usr/bin/env perl"*)                   echo "perl" ;;
          "#!/usr/bin/node"*|"#!/usr/bin/env node"*)                   echo "javascript" ;;
          "#!/usr/bin/php"*|"#!/usr/bin/env php"*)                     echo "php" ;;
          "#!/usr/bin/zsh"*|"#!/usr/bin/env zsh"*)                     echo "zsh" ;;
          *)                                                            echo "bash" ;;
        esac
      else
        echo "bash"
      fi
      ;;
  esac
}

# Returns: "system" | "brew" | ""
_cmd_origin() {
  local cmd="$1"
  if [[ -x /usr/bin/"$cmd" || -x /bin/"$cmd" || -x "${HOME}/.local/bin/$cmd" ]]; then
    echo "system"
  elif [[ -x /opt/homebrew/bin/"$cmd" ]]; then
    echo "brew"
  else
    echo ""
  fi
}

# Resolve language for a command token.
# For system commands → "bash"; for brew/unknown → prompt user.
# Writes resolved lang to stdout.
_resolve_cmd_lang() {
  local first_token="$1"
  local origin
  origin=$(_cmd_origin "$first_token")

  case "$origin" in
    system)
      echo "bash"
      ;;
    brew|"")
      # Ask user
      local label
      label="${origin:-unknown}"
      printf "Add 'bash' lang to wrapper? (%s command) [y/N]: " "$label" >&2
      local reply
      read -r reply </dev/tty
      if [[ "$reply" =~ ^[Yy]$ ]]; then
        echo "bash"
      else
        echo ""
      fi
      ;;
  esac
}

# ── Core clipboard operations ────────────────────────────────────────────────

copy_to_clipboard() {
  local file_path="$1"
  [[ ! -f "$file_path" ]] && { log_error "File '$file_path' does not exist"; return 1; }
  cat "$file_path" | _clip_copy
  log_msg "✅" "Contents of '$file_path' copied to clipboard"
}

paste_to_file() {
  local file_path="$1"
  ensure_parent_dir "$file_path" || return 1
  local action_msg="pasted to"
  [[ ! -f "$file_path" ]] && action_msg="created"
  check_write_permission "$file_path" || return 1
  _clip_paste >"$file_path"
  log_msg "✅" "Clipboard contents $action_msg '$file_path'"
}

append_to_file() {
  local file_path="$1"
  ensure_parent_dir "$file_path" || return 1
  if [[ ! -f "$file_path" ]]; then
    read -p "File '$file_path' does not exist. Create it? (y/n): " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && { log_msg "🚫" "Operation cancelled"; return 1; }
  fi
  check_write_permission "$file_path" || return 1
  echo "" >>"$file_path"
  _clip_paste >>"$file_path"
  log_msg "✅" "Clipboard contents appended to '$file_path'"
}

copy_cmd_output() {
  local cmd="$*"
  eval "$cmd" | _clip_copy
  log_msg "✅" "Output of '$cmd' copied to clipboard"
}

copy_cmd_and_output() {
  local cmd="$*"
  local output
  output=$(eval "$cmd" 2>&1)
  printf '%s\n%s' "$cmd" "$output" | _clip_copy
  log_msg "✅" "Command and output of '$cmd' copied to clipboard"
}

# ── Markdown-wrapped commands ────────────────────────────────────────────────

# wcmd: wrap command output only in a markdown block
wrap_cmd_output() {
  local cmd="$*"
  local first_token="$1"
  local lang output block

  # File path supplied instead of a command?
  if [[ $# -eq 1 && -f "$first_token" ]]; then
    lang=$(_get_lang_from_file "$first_token")
    output=$(cat "$first_token")
  else
    lang=$(_resolve_cmd_lang "$first_token")
    output=$(eval "$cmd" 2>&1)
  fi

  block=$(printf '```%s\n%s\n```' "$lang" "$output")

  local rc=0
  echo "$block" | _clip_copy || rc=$?
  if [[ $rc -eq 2 ]]; then
    echo "No supported clipboard mechanism detected. Output:"
    echo
    echo "$block"
  else
    log_msg "✅" "Wrapped output copied to clipboard (lang: ${lang:-none})"
  fi
}

# wcpcmd: wrap command + its output in a markdown block
wrap_cmd_and_output() {
  local cmd="$*"
  local first_token="$1"
  local lang output block

  if [[ $# -eq 1 && -f "$first_token" ]]; then
    lang=$(_get_lang_from_file "$first_token")
    output=$(cat "$first_token")
    # For a file, don't prepend the filename as a "command"
    block=$(printf '```%s\n%s\n```' "$lang" "$output")
  else
    lang=$(_resolve_cmd_lang "$first_token")
    output=$(eval "$cmd" 2>&1)
    block=$(printf '```%s\n%s\n%s\n```' "$lang" "$cmd" "$output")
  fi

  local rc=0
  echo "$block" | _clip_copy || rc=$?
  if [[ $rc -eq 2 ]]; then
    echo "No supported clipboard mechanism detected. Output:"
    echo
    echo "$block"
  else
    log_msg "✅" "Wrapped command + output copied to clipboard (lang: ${lang:-none})"
  fi
}

# ── Help ─────────────────────────────────────────────────────────────────────

show_short_help() {
  cat <<'EOF'
clipops - clipboard operations utility

USAGE: clipops <command> [args]

COMMANDS:
  copy   <file>      Copy file to clipboard
  paste  <file>      Paste clipboard → file (overwrite)
  append <file>      Append clipboard → file
  cmd    <cmd...>    Copy command output to clipboard
  cpcmd  <cmd...>    Copy command + output to clipboard
  wcmd   <cmd...>    Copy output wrapped in markdown block
  wcpcmd <cmd...>    Copy command + output in markdown block

  -h                 This help
  --help             Full help with all options and examples

ALIASES: ctc copy · pof paste · paf append · ccc cmd · 4c cpcmd · wcmd · wcp wcpcmd
EOF
}

show_long_help() {
  cat <<'EOF'
clipops - clipboard operations utility
Copies file contents or command output to the system clipboard,
with optional markdown code block wrapping.

USAGE:
  clipops <command> [arguments]

COMMANDS:
  copy <file>
      Copy the contents of <file> to the clipboard.

  paste <file>
      Overwrite <file> with the current clipboard contents.
      Creates the file (and any parent directories) if needed.

  append <file>
      Append the current clipboard contents to <file>.
      Prompts to create the file if it doesn't exist.

  cmd <command> [args...]
      Execute <command> and copy its stdout/stderr to the clipboard.
      No formatting applied — raw output only.

  cpcmd <command> [args...]
      Execute <command> and copy both the command string and its
      output to the clipboard, separated by a newline.

  wcmd <command|file> [args...]
      Execute <command> (or read <file>) and copy the output wrapped
      in a markdown fenced code block.
      Language is inferred from the file extension, shebang line, or
      command origin. For brew/unknown commands, prompts:
        "Add 'bash' lang to wrapper? [y/N]"
      Answering N produces a plain ``` block with no language tag.

  wcpcmd <command|file> [args...]
      Same as wcmd but also prepends the command string inside the
      block, matching the cpcmd pattern:
        ```bash
        fd -td -d 1 dirName | wc -l
        17
        ```

  -h, help
      Short command reference (this screen without --help).

  --help
      This full help text.

LANGUAGE DETECTION (wcmd / wcpcmd):
  1. File with extension  → use extension  (e.g. script.py → python)
  2. File without ext     → read shebang line
  3. System command       → bash
  4. Brew / unknown cmd   → prompt user (y = bash, N = no lang tag)

CLIPBOARD BACKENDS (auto-detected, in priority order):
  1. macOS          pbcopy / pbpaste
  2. Kitty terminal kitty +kitten clipboard (OSC 52, works over SSH)
  3. Linux X11      xclip -selection clipboard
  4. Fallback       prints block to stdout

EXAMPLES:
  clipops copy ~/.zshrc
  clipops paste ~/tmp/notes.txt
  clipops append ~/.notes

  clipops cmd "ls -la ~"
  clipops cpcmd "git log --oneline -5"

  clipops wcmd "df -h"
  clipops wcmd config.json
  clipops wcmd script.py

  clipops wcpcmd "fd -td -d 1 src | wc -l"
  # → prompts: Add 'bash' lang to wrapper? (brew command) [y/N]: y
  # → copies:
  #   ```bash
  #   fd -td -d 1 src | wc -l
  #   4
  #   ```

  clipops wcpcmd server.ts
  # → copies file contents wrapped in ```ts ... ```

ALIASES (add to your shell rc):
  alias ctc='clipops copy'
  alias pof='clipops paste'
  alias paf='clipops append'
  alias ccc='clipops cmd'
  alias 4c='clipops cpcmd'
  alias wcmd='clipops wcmd'
  alias wcp='clipops wcpcmd'
EOF
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
  # Short-circuit help flags before clipboard check
  case "${1:-}" in
    -h)       show_short_help; exit 0 ;;
    --help)   show_long_help;  exit 0 ;;
  esac

  check_clipboard_command || exit 1

  if [[ $# -eq 0 ]]; then
    show_short_help
    exit 1
  fi

  local command="$1"
  shift

  case "$command" in
    copy)
      [[ $# -eq 0 ]] && { log_error "No file specified"; show_short_help; exit 1; }
      copy_to_clipboard "$1"
      ;;
    paste)
      [[ $# -eq 0 ]] && { log_error "No file specified"; show_short_help; exit 1; }
      paste_to_file "$1"
      ;;
    append)
      [[ $# -eq 0 ]] && { log_error "No file specified"; show_short_help; exit 1; }
      append_to_file "$1"
      ;;
    cmd)
      [[ $# -eq 0 ]] && { log_error "No command specified"; show_short_help; exit 1; }
      copy_cmd_output "$@"
      ;;
    cpcmd)
      [[ $# -eq 0 ]] && { log_error "No command specified"; show_short_help; exit 1; }
      copy_cmd_and_output "$@"
      ;;
    wcmd)
      [[ $# -eq 0 ]] && { log_error "No command or file specified"; show_short_help; exit 1; }
      wrap_cmd_output "$@"
      ;;
    wcpcmd)
      [[ $# -eq 0 ]] && { log_error "No command or file specified"; show_short_help; exit 1; }
      wrap_cmd_and_output "$@"
      ;;
    help)
      show_long_help
      ;;
    *)
      log_error "Unknown command: $command"
      show_short_help
      exit 1
      ;;
  esac
}

main "$@"
