#!/bin/bash
# script to copy file contents or shell command in markdown codeblock and language

get_language() {
  local file="$1"
  case "$file" in
    *.*) echo "${file##*.}" ;;
    *)
      if [[ -f "$file" ]]; then
        local shebang
        shebang=$(head -n1 "$file" 2>/dev/null)
        case "$shebang" in
          "#!/bin/bash"* | "#!/usr/bin/bash"* | "#!/usr/bin/env bash"*) echo "bash" ;;
          "#!/bin/sh"* | "#!/usr/bin/sh"* | "#!/usr/bin/env sh"*) echo "sh" ;;
          "#!/usr/bin/python"* | "#!/usr/bin/env python"*) echo "python" ;;
          "#!/usr/bin/python3"* | "#!/usr/bin/env python3"*) echo "python" ;;
          "#!/usr/bin/ruby"* | "#!/usr/bin/env ruby"*) echo "ruby" ;;
          "#!/usr/bin/perl"* | "#!/usr/bin/env perl"*) echo "perl" ;;
          "#!/usr/bin/node"* | "#!/usr/bin/env node"*) echo "javascript" ;;
          "#!/usr/bin/php"* | "#!/usr/bin/env php"*) echo "php" ;;
          "#!/usr/bin/zsh"* | "#!/usr/bin/env zsh"*) echo "zsh" ;;
          *) echo "bash" ;;
        esac
      else
        echo "bash"
      fi
      ;;
  esac
}

is_command() {
  local cmd="$1"
  if [[ -x /usr/bin/"$cmd" || -x /bin/"$cmd" || -x ~/.local/bin/"$cmd" ]]; then
    echo "bash"
  elif [[ -x /opt/homebrew/bin/"$cmd" ]]; then
    echo "brew"
  else
    echo ""
  fi
}

COPY_COMMAND=false
if [[ "$1" == "-c" || "$1" == "--add-command" ]]; then
  COPY_COMMAND=true
  shift
fi

COMMAND="$@"

if [[ $# -eq 1 && -f "$1" ]]; then
  LANGUAGE=$(get_language "$1")
  OUTPUT=$(cat "$1")
  IS_FILE=true
else
  LANGUAGE=$(get_language "$1")
  if [[ "$LANGUAGE" == "bash" && ! -f "$1" ]]; then
    CMD_LANG=$(is_command "$1")
    [[ -n "$CMD_LANG" ]] && LANGUAGE="$CMD_LANG"
  fi
  OUTPUT=$($COMMAND 2>&1)
  IS_FILE=false
fi

MARKDOWN_BLOCK=""
if $COPY_COMMAND && ! $IS_FILE; then
  MARKDOWN_BLOCK="\\\`\\\`\\\`$LANGUAGE
$COMMAND
$OUTPUT
\\\`\\\`\\\`"
else
  MARKDOWN_BLOCK="\\\`\\\`\\\`$LANGUAGE
$OUTPUT
\\\`\\\`\\\`"
fi

# Clipboard handling
# 1) macOS local
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "$MARKDOWN_BLOCK" | pbcopy
  echo "✓ Content copied to clipboard as markdown block (macOS)"

# 2) Remote session inside kitty: use kitty clipboard kitten (OSC52)
elif [[ -n "$KITTY_INSTALLATION_DIR" || "$TERM" == "xterm-kitty" ]] && command -v kitty >/dev/null 2>&1; then
  echo "$MARKDOWN_BLOCK" | kitty +kitten clipboard
  echo "✓ Content copied to local clipboard via kitty (OSC52)"

# 3) Generic Linux desktop
elif [[ "$OSTYPE" == "linux-gnu"* ]] && command -v xclip >/dev/null 2>&1; then
  echo "$MARKDOWN_BLOCK" | xclip -selection clipboard
  echo "✓ Content copied to clipboard as markdown block (Linux)"

else
  echo "No supported clipboard mechanism detected. Printing output instead:"
  echo
  echo "$MARKDOWN_BLOCK"
fi
