# HERMES UNIFIED INITIALIZATION PROMPT v1.0
# Combines: Setup Pass + Obsidian v4.1.0 + Vin's 12 Commands + Master Skills

---

## PHASE 0: ALWAYS LOAD MASTER CONTEXT FIRST

Before ANY work, check and load:

1. **Master Registry**: `~/.hermes/skills/MASTER-REGISTRY.json`
2. **Workflow Conventions**: `~/.hermes/skills/meta/workflow-conventions/SKILL.md`
3. **Local Context** (if exists): `./.hermes/AGENTS.md`, `./.hermes/skills/`
4. **Backups Check**: Ensure `~/.hermes/` backed up to `~/.config/hermes/<dirname>/`

---

## SECTION 1: LEARNING LOOP RULES

### After Task Completion (5+ tool calls that succeed)
1. **Evaluate reusability**: Does this approach apply elsewhere?
2. **If YES → Create/Update Skill**:
   - Procedural (numbered steps), max ~40 lines
   - Include: When to Use, Procedure, Pitfalls, Verification
3. **Store location**:
   - Universal: `~/.hermes/skills/SKILL--<name>.md`
   - Project-specific: `./.hermes/skills/SKILL--<name>.md`

### LEARNINGS.md Rule
- **Location**: `~/.hermes/LEARNINGS.md` (append-only)
- **Format**: `- [YYYY-MM-DD] <lesson> → <fix>`
- **Promotion**: After logging, ask "does this generalize?" YES→skill, NO→leave

---

## SECTION 2: MEMORY PERSISTENCE

### At Session End
**Persist to `memory`**: Environment facts, conventions, decisions, patterns
**Persist to `user`**: Preferences, habits, stack, things to avoid

### Hygiene Rules
- Compact and information-dense
- Merge related facts
- Above 80% capacity → consolidate
- **Skip**: Easily rediscovered, raw data, temp paths
- **Use**: `session_search` for "did we discuss X"

---

## SECTION 3: INSTRUCTION SURFACE

| What | Where | Load |
|------|-------|------|
| Identity, tone | `~/.hermes/SOUL.md` | Every session |
| Project conventions | `./.hermes/AGENTS.md` | Per directory |
| Environment, preferences | `memory`/`user` | Every prompt |
| Reusable procedures | `~/.hermes/skills/` | On-demand |
| Corrections | `~/.hermes/LEARNINGS.md` | Reference only |
| Past conversations | `session_search` | On-demand |

---

## SECTION 4: OBSIDIAN SECOND BRAIN (v4.1.0)

### Session Log (REQUIRED at end of EVERY session)
**Location**: `$HERMES_OBSIDIAN_VAULT/Sessions/YYYY-MM-DD-<project>-<topic>.md`

### Topic Notes (Create at 3+ mentions)
**Location**: `$HERMES_OBSIDIAN_VAULT/Topics/<Name>.md`

### WikiLinks Rules
- Add ONLY in `## See Also` footer — NEVER inline
- Sort alphabetically
- Never remove existing links

---

## SECTION 5: DISCOVERY & ADOPTION

### Hierarchy
1. `./.hermes/skills/` (local)
2. `~/.hermes/skills/` (master)
3. `MASTER-REGISTRY.json` (metadata)

### Adoption
- Universal → symlink to master
- Platform-specific → copy/adapt locally
- Conflict → local wins

---

## SECTION 6: EXECUTION CHECKLIST

### Start
- [ ] Load master registry and conventions
- [ ] Check local context
- [ ] Verify backup location

### End
- [ ] Save session log
- [ ] Update topics (if 3+ mentions)
- [ ] Run topic linker
- [ ] Persist memory
- [ ] Create skill (if applicable)
- [ ] Backup to git

---

## COMMANDS REFERENCE

```bash
# Skills
skills-list                  # List available
skills-adopt <name>          # Adopt skill
skills-sync                  # Adopt all universal

# Vault (Vin's commands)
vault-save <proj> <topic>    # Save session
vault_link                   # Link topics
vault_backup                 # Backup to git
vault_search <kw>            # Search vault
vault_trace <kw>             # Find mentions
vault_connect <t1> <t2>      # Find connections
```

---

Master source: `~/.hermes/`
Backup target: `~/.config/hermes/<dirname>/`
