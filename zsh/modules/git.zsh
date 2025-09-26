# ~/.config/zsh/modules/git.zsh
# Git functions

is-apple-silicon() { [ "$(uname -m)" = "arm64" ] && return 0 || return 1; }

setup-ssh() {
  if [ -z "$SSH_AGENT_PID" ] || ! ps -p "$SSH_AGENT_PID" >/dev/null; then
    eval "$(ssh-agent -s)"
    ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
  else
    echo "Using SSH agent PID $SSH_AGENT_PID"
  fi
}

git-pull() {
  setup-ssh
  local remote="${1:-origin}" branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"
  git pull --rebase -q "$remote" "$branch"
}

git-push() {
  setup-ssh
  local remote="${1:-origin}" branch="${2:-$(git rev-parse --abbrev-ref HEAD)}"
  git push -q "$remote" "$branch"
}

git-add() { git add .; }

git-commit-message() {
  local message="$1"
  [ -z "$message" ] && message="$(date +%Y-%m-%d)\nChanged files:\n$(git status --short | awk '{print $2}')"
  git commit -m "$message" || { echo "(X︿x ) Commit failed."; return 1; }
}

git-fetch-all() {
  local dirs=("$HOME/.dotfiles" "$HOME/.lua-is-the-devil" "$HOME/.noktados" "$HOME/notes" "$DX/widclub")
  setup-ssh
  for dir in "${dirs[@]}"; do
    [ -d "$dir" ] || { echo "(눈︿눈) Skipping: $dir not found."; continue; }
    echo "Processing: $dir"
    (cd "$dir" && [ -d .git ] && git fetch || echo "(눈︿눈) Not a git repo or fetch failed: $dir")
  done
}

check-git-status() {
  for repo in "${REPOS[@]}"; do  # REPOS defined in torrent.zsh, assumes global access
    [ -d "$repo" ] || { echo "Directory $repo does not exist"; continue; }
    cd "$repo" || continue
    echo "Checking git status for $repo"
    git status "$repo"
    cd - >/dev/null || continue
  done
}

git-pull-all() {
  local dirs=("$HOME/.dotfiles" "$HOME/.lua-is-the-devil" "$HOME/.noktados" "$HOME/notes" "$DX/widclub")
  setup-ssh
  for dir in "${dirs[@]}"; do
    [ -d "$dir" ] || { echo "(눈︿눈) Skipping: $dir not found."; continue; }
    echo "Processing: $dir"
    (cd "$dir" && [ -d .git ] && git-pull || echo "(눈︿눈) Not a git repo or pull failed: $dir")
  done
}

git-add-commit-push() {
  setup-ssh
  git-add "$@"
  git-commit-message "$@"
  git-push "$@"
}