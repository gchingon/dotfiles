#!/usr/bin/env bash
# ln ~/.config/rx/git-tool.sh ~/.local/bin/gitool
# A consolidated Git utility script for common repository operations.

# Internal function to ensure the SSH agent is running.
# Not meant to be called directly.
_setup_ssh() {
  if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" > /dev/null; then
    echo "Initializing new SSH agent..."
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
  fi
}

usage() {
    echo "Usage: $(basename "$0") <operation> [arguments...]"
    echo
    echo "Operations:"
    echo "  acp <\"message\">   - Add all, commit with message, and push."
    echo "  pull [remote] [branch] - Pull with rebase from a remote branch."
    echo "  push [remote] [branch] - Push to a remote branch."
    echo "  fetch-all            - Fetch updates from all predefined repos."
    echo "  pull-all             - Pull updates from all predefined repos."
    echo "  status-all           - Check git status for all predefined repos."
    exit 1
}

# The operation is the first argument
OPERATION=$1
shift

# Predefined repositories for multi-repo operations
REPOS=("$HOME/.dotfiles" "$HOME/.lua-is-the-devil" "$HOME/.noktados" "$HOME/notes" "$DX/widclub")

case "$OPERATION" in
    acp)
        [ -z "$1" ] && { echo "Error: Commit message is required."; exit 1; }
        _setup_ssh
        echo "--> Staging all changes..."
        git add .
        echo "--> Committing with message: '$1'..."
        git commit -m "$1" || { echo "Commit failed. Aborting."; exit 1; }
        echo "--> Pushing changes..."
        git push
        ;;

    pull)
        _setup_ssh
        REMOTE=${1:-origin}
        BRANCH=${2:-$(git rev-parse --abbrev-ref HEAD)}
        echo "--> Pulling from $REMOTE/$BRANCH with rebase..."
        git pull --rebase "$REMOTE" "$BRANCH"
        ;;

    push)
        _setup_ssh
        REMOTE=${1:-origin}
        BRANCH=${2:-$(git rev-parse --abbrev-ref HEAD)}
        echo "--> Pushing to $REMOTE/$BRANCH..."
        git push "$REMOTE" "$BRANCH"
        ;;

    fetch-all | pull-all | status-all)
        _setup_ssh
        ACTION_CMD="git fetch"
        if [ "$OPERATION" = "pull-all" ]; then ACTION_CMD="git pull --rebase"; fi
        if [ "$OPERATION" = "status-all" ]; then ACTION_CMD="git status"; fi
        
        for dir in "${REPOS[@]}"; do
            if [ -d "$dir/.git" ]; then
                echo "--- Processing $dir ---"
                (cd "$dir" && $ACTION_CMD)
            else
                echo "--- Skipping $dir (not a git repo) ---"
            fi
        done
        ;;

    *)
        echo "Error: Unknown operation '$OPERATION'"
        usage
        ;;
esac

echo "Git operation '$OPERATION' complete."
