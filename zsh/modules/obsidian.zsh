# ~/.config/zsh/modules/obsidian.zsh
# Hermes-Obsidian integration aliases

# Vault environment
export HERMES_OBSIDIAN_VAULT="${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second Brain"
export HERMES_OBSIDIAN_CONFIG="${HOME}/.hermes/obsidian/config.json"

# Session logging
alias obsidian_session_save="${HOME}/.hermes/scripts/save-session.sh"
alias vault-save="${HOME}/.hermes/scripts/save-session.sh"

# Search commands
alias obsidian_search="grep -r"
alias vault_grep="grep -r"

# Topic linker
alias obsidian_link="python3 ${HOME}/.hermes/obsidian/topic-linker.py"
alias vault_link="python3 ${HOME}/.hermes/obsidian/topic-linker.py"
alias vault_link_dry="python3 ${HOME}/.hermes/obsidian/topic-linker.py --dry-run"

# Backup
alias obsidian_backup="${HOME}/.hermes/scripts/backup-to-git.sh"
alias vault_backup="${HOME}/.hermes/scripts/backup-to-git.sh"
alias vault_backup_home="${HOME}/.hermes/scripts/backup-to-git.sh schingon-home"

# Vin's 12 Commands (adapted for Hermes)
alias vault_context="cat ${HOME}/.hermes/context/*.md 2>/dev/null | head -100"
alias vault_topics="ls \${HERMES_OBSIDIAN_VAULT}/Topics/ 2>/dev/null || echo 'Topics folder not found'"
alias vault_sessions="ls -lt \${HERMES_OBSIDIAN_VAULT}/Sessions/ 2>/dev/null | head -20"
alias vault_recent="find \${HERMES_OBSIDIAN_VAULT}/Sessions -name '*.md' -mtime -7 2>/dev/null"

# Obsidian CLI (if installed)
alias obs="obsidian"

# Create a new topic note
obsidian_topic_add() {
  local name="$1"
  local type="${2:-concept}"
  local vault="${HERMES_OBSIDIAN_VAULT}"
  local topics_dir="${vault}/Topics"
  
  mkdir -p "${topics_dir}"
  
  local filepath="${topics_dir}/${name}.md"
  
  cat > "${filepath}" << EOF
---
type: ${type}
created: $(date +%Y-%m-%d)
tags: [topic-note, ${type}]
---

# ${name}

<!-- Brief description -->

## Related Notes
<!-- Session logs that mention ${name} -->
EOF

  echo "Created topic note: ${filepath}"
}

# Search vault for keyword
unalias vault_search 2>/dev/null || true
vault_search() {
  local keyword="$1"
  local vault="${HERMES_OBSIDIAN_VAULT}"
  
  echo "=== Topics matching '${keyword}' ==="
  grep -ril "${keyword}" "${vault}/Topics/" 2>/dev/null | while read f; do
    echo "  Topic: $(basename "$f" .md)"
  done
  
  echo ""
  echo "=== Sessions matching '${keyword}' ==="
  grep -ril "${keyword}" "${vault}/Sessions/" 2>/dev/null | head -10 | while read f; do
    echo "  Session: $(basename "$f" .md)"
  done
}

# Trace idea evolution (find all mentions)
vault_trace() {
  local keyword="$1"
  local vault="${HERMES_OBSIDIAN_VAULT}"
  
  echo "Tracing '${keyword}' across vault..."
  grep -rh "${keyword}" "${vault}/Sessions/" "${vault}/Topics/" 2>/dev/null |     sort | uniq -c | sort -rn | head -20
}

# Today's note path
vault_today() {
  local date_str=$(date +%Y-%m-%d)
  echo "${HERMES_OBSIDIAN_VAULT}/Sessions/"
  ls -lt "${HERMES_OBSIDIAN_VAULT}/Sessions/${date_str}"*.md 2>/dev/null | head -5
}

# Connect two topics (find links between them)
vault_connect() {
  local topic1="$1"
  local topic2="$2"
  local vault="${HERMES_OBSIDIAN_VAULT}"
  
  echo "Finding connections between [[${topic1}]] and [[${topic2}]]..."
  
  # Find sessions mentioning both
  grep -rl "${topic1}" "${vault}/Sessions/" 2>/dev/null | while read f; do
    if grep -q "${topic2}" "$f" 2>/dev/null; then
      echo "  Connection found: $(basename "$f" .md)"
    fi
  done
}
