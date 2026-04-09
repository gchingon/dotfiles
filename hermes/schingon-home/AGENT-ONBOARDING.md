# Agent Onboarding: schingon Home Directory

You are joining a Hermes agent network. This environment has established conventions.

## Quick Context Load

```bash
# 1. Load master context
cat ~/.hermes/skills/MASTER-REGISTRY.json | head -50
cat ~/.hermes/skills/meta/workflow-conventions/SKILL.md

# 2. Check environment
ls ~/.hermes/skills/          # Available skills
cat ~/.hermes/LEARNINGS.md    # Recent lessons
echo $HERMES_OBSIDIAN_VAULT   # Vault path

# 3. Verify backup
ls ~/.config/hermes/schingon-home/
```

## This Environment

- **Platform**: macOS (Apple Silicon)
- **Shell**: zsh
- **Keyboard**: Dvorak, Kanata chords
- **Window Management**: Yabai (focus), Raycast (sizing)
- **Terminal**: Kitty
- **Notes**: Obsidian (iCloud)

## Key Preferences

| Preference | Value |
|------------|-------|
| Config changes | Create alternatives first, don't overwrite |
| Leader keys | Tab+Return chord OR LShift hold |
| Session logs | ALWAYS save to vault |
| Backups | Git to ~/.config/hermes/ |
| Skill conflicts | Master→symlink, Local→copy, Local wins |

## Critical Rules

1. **Search vault BEFORE external** (git, web, etc.)
2. **Save session log** at end (no exceptions)
3. **Backup ~/.hermes/** after changes
4. **5+ successful steps** → evaluate for skill creation
5. **Never overwrite** configs without explicit confirmation

## Quick Commands

```bash
vault-save "project" "topic"    # Save this session
skills-adopt obsidian           # Load obsidian skill
vault_backup                    # Backup to git
```

## Directory Inventory

```
~/.config/
  rx/              # Custom scripts (lib/common.sh)
  kanata/          # alt-dvorak-chord.kbd
  zsh/modules/     # obsidian.zsh, git.zsh, file_management.zsh
  hermes/          # Git-backed backups

~/.hermes/
  skills/          # MASTER-REGISTRY.json + skills
  obsidian/        # Session logging system
  scripts/         # skill-adopt.py, backup-to-git.sh
  LEARNINGS.md     # Cross-session lessons
```

## First Actions

1. Run `skills-list` to see available skills
2. Run `skills-adopt obsidian` (universal skill)
3. Check `~/.hermes/LEARNINGS.md` for recent context
4. Verify backup: `vault_backup`

## Finish Checklist

- [ ] Session log saved
- [ ] Topics linked (if applicable)
- [ ] Memory persisted
- [ ] Skills created (if 5+ steps)
- [ ] Backed up to ~/.config/hermes/schingon-home/

---

Ready to work. Load skill with `skill_view <name>` or check available with `skills-list`.
