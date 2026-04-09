---
description: Obsidian vault integration for Hermes - second brain session logging
emoji: 🧠
---

# Obsidian Second Brain Integration for Hermes

Automatic session logging into Obsidian vault with topic notes and WikiLinks.

## Quick Commands

| Command | Purpose |
|---------|---------|
| `skill_view obsidian` | Load this skill and see all commands |
| `obsidian_session_save <project> <topic>` | Save current session log |
| `obsidian_search <keyword>` | Search vault for keyword |
| `obsidian_topic_add <name> <type>` | Create new topic note |

## Architecture

```
Hermes Session ──► Session Log ──► Vault/Sessions/YYYY-MM-DD-<project>-<topic>.md
                      │                          │
                      ├──► Topics/<Name>.md (people, projects, tools)
                      │     └── type: person|project|tool|concept|organization
                      └──► See Also footer with [[WikiLinks]]
```

## Session Log Template

When saving a session, use this exact format:

```markdown
---
date: [ISO-timestamp]
project: [project-name]
tags: [session-log, brief-topic]
---

# [Project] - [Brief Topic]

## Summary
[2-3 sentences]

## Key Decisions
- [Decision 1]
- [Decision 2]

## Changes Made
- [Change 1] - [details]
- [Change 2] - [details]

## Topics Referenced
- [[Topic Name 1]] (type)
- [[Topic Name 2]] (type)

## Open Items
- [ ] [item 1]
- [ ] [item 2]

## Next Steps
1. [Step 1]
2. [Step 2]

---
## See Also
- [[Topic Name 1]]
- [[Topic Name 2]]
```

## Topic Note Template

For recurring entities (appearing in 3+ sessions):

```markdown
---
type: [person|project|tool|concept|organization]
created: [YYYY-MM-DD]
tags: [topic-note, <type>]
---

# <Topic Name>

<Brief description — 1-2 sentences about who/what this is>

## Related Notes
- [[Session Log 1]]
- [[Session Log 2]]
```

## Search Protocol

**ALWAYS** search the vault before external research:

1. Topic notes: `grep -rl "keyword" "$VAULT/Topics/"`
2. Sessions: `grep -rl "keyword" "$VAULT/Sessions/"`
3. All vault: `find "$VAULT" -name "*.md" -exec grep -l "keyword" {} \;`

## Rules

### WRITE Rules
- Save session log at end of EVERY session
- Create topic notes for entities appearing 3+ times
- Use [[WikiLinks]] in "See Also" footer only — NEVER inline
- Never ask permission to save — just do it
- Use absolute paths everywhere

### READ Rules
- Search vault BEFORE web search / repo clone
- Read topic notes freely — they exist to be shared
- Don't scan entire vault on startup (too many tokens)
- Build on previous work rather than starting fresh

## Topic Types

**Always create for:** Named people, projects, paid services, organizations
**Never create for:** Common English words, generic concepts ("debugging")
**Must be proper nouns:** "Supabase" yes, "database" no

## File Locations

- Session logs: `$VAULT/Sessions/`
- Topic notes: `$VAULT/Topics/` (configurable)
- Archive: `$VAULT/Archive/`
- Templates: `$VAULT/Templates/`
