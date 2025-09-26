#!/bin/bash
# ln $RX/wrap-output-to-md-block.sh $HOME/.local/bin/wrap2block
# script to copy file contents or shell command in markdown codeblock and language, with the option to capture the called command

# Function to determine the language based on file extension or shebang
get_language() {
  local file="$1"

  # If it has an extension, use that
  case "$file" in
  *.*) echo "${file##*.}" ;;
  *)
    # No extension - check if it's a file and has a shebang
    if [[ -f "$file" ]]; then
      local shebang=$(head -n1 "$file" 2>/dev/null)
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
        *) echo "bash" ;; # Default fallback
      esac
    else
      echo "bash" # Default for commands
    fi
    ;;
  esac
}

# Function to check if a command exists in specified directories
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

# Check if the flag is provided
COPY_COMMAND=false
if [[ "$1" == "-c" || "$1" == "--add-command" ]]; then
  COPY_COMMAND=true
  shift
fi

# Capture the command and its arguments
COMMAND="$@"

# Check if we're dealing with a single file argument
if [[ $# -eq 1 && -f "$1" ]]; then
  # It's a file - read its contents
  LANGUAGE=$(get_language "$1")
  OUTPUT=$(cat "$1")
  IS_FILE=true
else
  # It's a command - execute it
  LANGUAGE=$(get_language "$1")

  # If we couldn't determine language from file/shebang and it's not a file,
  # check if it's a command in the system paths
  if [[ "$LANGUAGE" == "bash" && ! -f "$1" ]]; then
    CMD_LANG=$(is_command "$1")
    if [[ -n "$CMD_LANG" ]]; then
      LANGUAGE="$CMD_LANG"
    fi
  fi

  # Execute the command and capture the output
  OUTPUT=$($COMMAND 2>&1)
  IS_FILE=false
fi

show_usage() {
  cat <<'EOF'
USAGE:
    wrap2block [OPTIONS] <file_or_command> [args...]

OPTIONS:
    --add-command | -c  copy command with content

EXAMPLES:
    ./wrap2block filename.md
    ```md
    ---
    title: Amazing Title for Markdown File
    author: gchingon
    date: $date
    ---
    # First heading
    Lorem ipsum dolor sit...
    ```

    ./wrap2block ls $HOME
    ```bash
    dir1
    dir2
    file1
    file2
    file3
    ```

    ./wrap2block -c ls path/to/dir
    ```bash
    ls path/to/dir
    file1
    file2
    file3
    ```

    ./wrap2block --add-command cat path/to/file.txt
    ```txt
    cat path/to/file.txt
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
    incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
    nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore
    eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,
    sunt in culpa qui officia deserunt mollit anim id est laborum
    ```
EOF
}

# Create the markdown block and copy to clipboard
MARKDOWN_BLOCK=""

# Print the command if the flag was provided (and it's not just a file)
if $COPY_COMMAND && ! $IS_FILE; then
  MARKDOWN_BLOCK="\`\`\`$LANGUAGE
$COMMAND
$OUTPUT
\`\`\`"
else
  MARKDOWN_BLOCK="\`\`\`$LANGUAGE
$OUTPUT
\`\`\`"
fi

# Copy to clipboard instead of just printing
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "$MARKDOWN_BLOCK" | pbcopy
  echo "✓ Content copied to clipboard as markdown block (macOS)"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "$MARKDOWN_BLOCK" | xclip -selection clipboard
  echo "✓ Content copied to clipboard as markdown block (Linux)"
else
  echo "Unsupported OS for clipboard operations."
  echo "$MARKDOWN_BLOCK"
fi
