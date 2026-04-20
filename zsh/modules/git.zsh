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

  local repo_root repo_name repo_prefix repo_component
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
  repo_prefix="$(git rev-parse --show-prefix 2>/dev/null || true)"
  repo_component="${repo_prefix%%/*}"
  case "$repo_component" in
    notes|crypt|agent-vault|pod-content) repo_name="$repo_component" ;;
    *) repo_name="$(basename "${repo_root:-}")" ;;
  esac
  case "$repo_name" in
    .config)
      "$RX/repo-sync-peers.sh" config
      ;;
    notes|crypt|agent-vault|pod-content)
      "$RX/repo-sync-peers.sh" "$repo_name"
      ;;
  esac
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

# ── Legacy Compatibility ───────────────────────────────────────────────
# Keep aliases that depend on these functions
alias gac='git-add-commit-push'
alias gpl='git-pull'
alias gph='git-push'
alias gfh='git fetch'
alias notesync='$RX/repo-sync-peers.sh notes'
alias podsync='$RX/repo-sync-peers.sh pod-content'
