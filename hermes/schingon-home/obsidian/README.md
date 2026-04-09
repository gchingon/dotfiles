# Hermes-Obsidian Second Brain Integration

This system connects Hermes agent sessions to your Obsidian vault for persistent knowledge management.

## Directory Structure

```
~/.hermes/
├── obsidian/
│   ├── config.json              # Configuration (vault path, folders, etc.)
│   ├── templates/
│   │   ├── session.md           # Session log template
│   │   └── topic.md             # Topic note template
│   └── topic-linker.py          # Auto-link sessions to topics
├── skills/
│   └── SKILL--obsidian.md       # Skill file (load with `skill_view obsidian`)
└── scripts/
    ├── backup-to-git.sh         # Backup to ~/.config/hermes/
    └── save-session.sh          # Save session to vault
```

## Quick Start

1. **Set your vault path** in `~/.hermes/obsidian/config.json`:
   ```json
   "vault_path": "/path/to/your/Obsidian/Vault"
   ```

2. **Save a session**:
   ```bash
   ~/.hermes/scripts/save-session.sh "project-name" "topic"
   ```
   Or use: `obsidian_session_save <project> <topic>`

3. **Link topics automatically**:
   ```bash
   python3 ~/.hermes/obsidian/topic-linker.py
   ```

4. **Create a topic note**:
   ```bash
   # Create Topics/Kanata.md
   obsidian_topic_add "Kanata" "tool"
   ```

5. **Search the vault**:
   ```bash
   obsidian_search "kanata"
   ```

## Backup Strategy

Each Hermes instance backs up to `~/.config/hermes/<dirname>/`:

```bash
# From any project directory:
~/.hermes/scripts/backup-to-git.sh          # Uses current dir name
~/.hermes/scripts/backup-to-git.sh myname   # Custom name
```

For this home directory: backups go to `~/.config/hermes/schingon-home/`

## Topic Notes

- **Types**: person, project, tool, concept, organization
- **Threshold**: Meeting 3+ session logs
- **Location**: `$VAULT/Topics/`
- **Auto-linking**: Runs via `topic-linker.py`

## Session Logs

- **Location**: `$VAULT/Sessions/`
- **Naming**: `YYYY-MM-DD-<project>-<topic>.md`
- **Template**: Includes summary, decisions, changes, topics, actions, next steps

## Recommended Workflow

1. Start work with Hermes
2. Hermes searches vault for context (automatic)
3. Work happens (files modified, decisions made)
4. At session end: "Save session log?"
5. Hermes creates session log with proper structure
6. Topic linker runs to add WikiLinks
7. Vault backed up to git

## Vin's 12 Commands (Adapted for Hermes)

These shell commands can be added to your zshrc:

```zsh
# /context — Load full life/work state
alias vault_context="cat ~/.hermes/context/*.md 2>/dev/null | head -100"

# /search — Quick vault search
alias vault_search="grep -r"

# /trace — Track idea evolution  
alias vault_trace="grep -rl"

# /topics — List all topic notes
alias vault_topics="ls ~/.hermes/obsidian/topics/"

# /save — Save session
alias vault_save="~/.hermes/scripts/save-session.sh"
```

Or better — use the skill-loaded commands via Hermes.
