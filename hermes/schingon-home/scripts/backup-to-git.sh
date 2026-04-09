#!/usr/bin/env zsh
# ~/.hermes/scripts/backup-to-git.sh
# Backup Hermes state to ~/.config/hermes/ (git-backed repo)
# Only syncs files the agent works on, not runtime/cache data

set -e

HERMES_DIR="${HOME}/.hermes"
PROJECT_NAME="${1:-$(basename "$PWD")}"

# GUARDRAIL: Never backup if we're in ~/.config itself
if [[ "$PWD" == "$HOME/.config" ]] || [[ "$PWD" == "$HOME/.config/" ]]; then
  echo "❌ Guardrail: Cannot backup ~/.config to itself"
  echo "   ~/.config is already a git repository"
  exit 1
fi

# GUARDRAIL: Never backup to a subdirectory of ~/.config
if [[ "$PROJECT_NAME" == ".config" ]] || [[ "$PROJECT_NAME" == ".hermes" ]]; then
  echo "❌ Guardrail: Refusing to backup '${PROJECT_NAME}' - would nest within git repo"
  exit 1
fi

BACKUP_DIR="${HOME}/.config/hermes/${PROJECT_NAME}"

echo "🔄 Backing up Hermes state to ${BACKUP_DIR}..."

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Only sync files the agent actually works on
# Explicit includes prevent copying venv, cache, logs, state
rsync -av --delete \
  --include='LEARNINGS.md' \
  --include='AGENT-ONBOARDING.md' \
  --include='INIT-PROMPT.md' \
  --include='SYSTEM-PROMPT.md' \
  --include='SOUL.md' \
  --include='AGENTS.md' \
  --include='skills/' \
  --include='skills/SKILL--*.md' \
  --include='skills/MASTER-REGISTRY.json' \
  --include='skills/meta/' \
  --include='skills/meta/***' \
  --include='context/' \
  --include='context/***' \
  --include='obsidian/' \
  --include='obsidian/config.json' \
  --include='obsidian/templates/' \
  --include='obsidian/templates/***' \
  --include='obsidian/topic-linker.py' \
  --include='obsidian/README.md' \
  --include='scripts/' \
  --include='scripts/backup-to-git.sh' \
  --include='scripts/save-session.sh' \
  --include='scripts/skill-adopt.py' \
  --include='memories/' \
  --include='memories/LEARNINGS.md' \
  --include='memories/DECISIONS.md' \
  --include='memories/*.md' \
  --exclude='*' \
  "${HERMES_DIR}/" "${BACKUP_DIR}/"
echo "✓ Backup complete: ${BACKUP_DIR}"
echo "  Files backed: $(find "${BACKUP_DIR}" -type f | wc -l | tr -d ' ')"

# If ~/.config is a git repo, suggest commit
if [ -d "${HOME}/.config/.git" ]; then
  echo ""
  echo "Next steps:"
  echo "  cd ~/.config/hermes"
  echo "  git add ${1:-$(basename "$PWD")}"
  echo "  git commit -m \"hermes backup: ${1:-$(basename "$PWD")} $(date +%Y-%m-%d)\""
fi
