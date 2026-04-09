---
description: Create a master skill registry system for Hermes agent coordination and discovery
tags: [skills, registry, coordination, multi-agent, hermes]
---

# Master Skill Registry System

Create a centralized skill registry enabling Hermes agents to discover, adopt, and share skills across projects.

## When to Use

- Setting up Hermes on a new machine
- Creating skills that should be reusable across projects
- Establishing backup/sync patterns for ~/.hermes/
- Enabling agent-to-agent skill sharing

## Procedure

1. **Create registry structure**
   ```bash
   mkdir -p ~/.hermes/skills/meta
   ```

2. **Write MASTER-REGISTRY.json**
   Include:
   - `schema_version`: "1.0"
   - `discovery_rules`: search paths and priority
   - `adoption_policy`: symlink vs copy rules
   - `skill_categories`: group skills by type
   - `indexed_skills`: array of skill metadata
   - `environment_signature`: platform, tools, preferences

3. **Create discovery script**
   Write `~/.hermes/scripts/skill-adopt.py`:
   - `list`: Show available skills with adoption status
   - `adopt <name>`: Symlink (universal) or copy (platform-specific)
   - `sync`: Adopt all universal skills

4. **Establish backup pattern**
   Create `~/.hermes/scripts/backup-to-git.sh`:
   - Sync ~/.hermes/ to ~/.config/hermes/<dirname>/
   - Generate manifest.json
   - Git integration for version control

5. **Write startup prompt**
   Create `~/hermes-startup.md`:
   - Environment signature
   - Active projects and current state
   - Critical paths and decisions
   - Verification checklist

6. **Update zsh integration**
   Add to `~/.config/zsh/modules/skills.zsh`:
   - `skills-list`, `skills-adopt`, `skills-sync` aliases
   - `skill-view()` and `has-skill()` functions

7. **Test the system**
   ```bash
   skills-list
   skills-adopt obsidian
   vault_backup
   ```

## Adoption Rules

| Skill Type | Action | Example |
|------------|--------|---------|
| universal=true | Symlink to master | obsidian, workflow-conventions |
| universal=false | Copy and adapt locally | kanata (platform-specific) |
| Conflict exists | Local version wins | Always |

## Directory Conventions

```
~/.hermes/skills/
├── MASTER-REGISTRY.json        # Central index
├── SKILL--<name>.md            # Universal skills
└── meta/
    └── workflow-conventions/SKILL.md
    └── backup-strategy/SKILL.md

~/.config/hermes/
└── <dirname>/                   # Git-backed backups
    ├── skills/
    ├── obsidian/
    └── LEARNINGS.md
```

## Pitfalls

- ❌ Don't hardcode paths in skills — use env vars
- ❌ Don't sync venvs, caches, or state.db
- ❌ Don't forget to update registry when adding skills
- ✅ Always include environment_signature for new machines
- ✅ Test skill adoption in fresh directory before committing

## Verification

```bash
# Registry loads
cat ~/.hermes/skills/MASTER-REGISTRY.json | jq .schema_version

# Adoption works
skills-list  # Shows available skills
has-skill obsidian  # Returns local/master/none

# Backup completes
vault_backup  # Reports files backed up
ls ~/.config/hermes/<dirname>/manifest.json

# Startup prompt is readable
cat ~/hermes-startup.md | head -20
```
