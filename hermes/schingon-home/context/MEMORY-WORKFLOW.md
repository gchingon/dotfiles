# Memory Management Workflow

## What Goes Where

| Location | Content | Example | Updates |
|----------|---------|---------|---------|
| **USER.md** (~1375 chars) | User preferences, style, identity | "Concise responses", "Uses Dvorak" | User corrections, stated preferences |
| **MEMORY.md** (~2200 chars) | Agent's notes on environment | "Docker installed", "Project at ~/code/api" | Discoveries, patterns learned |
| **LEARNINGS.md** (unlimited) | Lessons from failures/corrections | "Always backup before editing configs" | Mistakes, important corrections |
| **Skills** | Reusable procedures | Debug workflow, PR workflow | Repeated successful patterns |
| **Session context** | Task-specific, transient | Current file being edited | Auto-cleared each session |

## When to Persist

**Always → USER.md:**
- User corrects you ("Actually, I prefer...")
- User states preference explicitly
- User's role, name, communication style

**Always → MEMORY.md:**
- Environment facts (OS, installed tools, paths)
- Project conventions discovered
- Tool quirks learned

**Always → LEARNINGS.md:**
- User had to correct or clarify
- Failed approach that wasted time
- Important insight that prevents future errors

**Consider → Skill:**
- Same procedure worked 3+ times
- Complex multi-step process succeeded
- Can be abstracted to other contexts

**Never persist:**
- Task progress (use session_search)
- Temporary state (use todo tool)
- One-off commands

## Nudge Response (every 10 turns)

When memory tool is offered:
1. Check if any facts discovered this session should persist
2. Check if any user corrections need recording
3. Prefer replacing/updating over adding duplicates
4. Keep entries atomic (one fact per § delimiter)

## Consolidation Rules (after 6+ turns)

When memory is full:
1. Merge related entries
2. Remove outdated environment facts
3. Archive older learnings to LEARNINGS.md
4. Summarize verbose entries
