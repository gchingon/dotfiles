# ~/.config/zsh/modules/git.zsh
# Unified Git workflow — merges git-tool.sh and previous git.zsh

# Repositories for multi-repo operations
GIT_REPOS=("$HOME/.dotfiles" "$HOME/.lua-is-the-devil" "$HOME/.noktados" "$HOME/notes" "$DX/widclub")

# ── SSH Agent Management ────────────────────────────────────────────────

setup-ssh() {
  if [[ -z "$SSH_AGENT_PID" ]] || ! ps -p "$SSH_AGENT_PID" >/dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" 2>/dev/null || true
  fi
}

# ── Single Repo Operations ─────────────────────────────────────────────

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

git-add-commit-push() {
  setup-ssh
  local branch remote upstream

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside a git repository."
    return 1
  fi

  branch="$(git rev-parse --abbrev-ref HEAD)" || return 1
  upstream="$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)" || upstream=""
  remote="${upstream%%/*}"
  [[ -n "$remote" ]] || remote="origin"

  # Stage everything, including deletions, so `gac` reflects the full local state.
  git add -A || return 1

  if git diff --cached --quiet; then
    echo "No changes to commit."
    return 0
  fi

  local msg="${1:-$(date +%Y-%m-%d) — $(git status --short | head -5 | tr '\n' ', ')}"
  git commit -m "$msg" || return 1

  if [[ -n "$upstream" ]]; then
    git push --force-with-lease -q "$remote" "$branch"
  else
    git push -u -q "$remote" "$branch"
  fi
}

# ── Multi-Repo Operations ──────────────────────────────────────────────

git-fetch-all() {
  setup-ssh
  for dir in "${GIT_REPOS[@]}"; do
    [[ -d "$dir/.git" ]] || continue
    echo "→ $dir"
    (cd "$dir" && git fetch -q)
  done
}

git-pull-all() {
  setup-ssh
  for dir in "${GIT_REPOS[@]}"; do
    [[ -d "$dir/.git" ]] || continue
    echo "→ $dir"
    (cd "$dir" && git pull --rebase -q 2>/dev/null || echo "  (failed)")
  done
}

git-status-all() {
  for dir in "${GIT_REPOS[@]}"; do
    [[ -d "$dir/.git" ]] || continue
    local status=$(cd "$dir" && git status --short)
    [[ -n "$status" ]] && echo "→ $dir" && echo "$status"
  done
}
