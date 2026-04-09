---
name: skill-creation-workflow
description: When to create skills from successful work and how to structure them properly. Use after completing complex tasks.
version: 1.0.0
metadata:
  hermes:
    tags: [skills, memory, workflow, documentation]
---

# Skill Creation Workflow

## When to Create a Skill

Check ALL boxes before creating:
- [ ] Procedure succeeded end-to-end
- [ ] Approach was non-obvious or had pitfalls
- [ ] Pattern could apply to similar future tasks
- [ ] NOT a one-off edge case
- [ ] You'd want this guidance next time

**Strong candidates:**
- Multi-step processes that worked (5+ tool calls)
- Debugging patterns that resolved issues
- Configuration setups with specific ordering
- Integration workflows that required specific flags

**Don't skill:**
- Simple one-liners
- Single tool calls
- One-off data transformations
- Errors specific to transient state

## Skill Structure

```yaml
---
name: descriptive-name
version: 1.0.0
description: One-line when to use this
metadata:
  hermes:
    tags: [tag1, tag2]
---

# Title

## When to Use

Specific trigger conditions.

## Prerequisites

What's needed before starting.

## Steps

1. **Step name** — concise action
2. **Step name** — concise action

## Verification

How to confirm success.

## Pitfalls

Common mistakes to avoid.
```

## Naming Conventions

- Use kebab-case: `docker-compose-setup`
- Be specific: `kubernetes-helm-deploy` not just `k8s`
- Include verb if action: `verify-gpu-driver`
- Group by domain: `aws-s3-policy`, `git-rebase-workflow`

## Post-Creation

1. Record in LEARNINGS.md: Skill created for [task]
2. If skill fixes previous failure, link to lesson
3. Watch for skill usage — refine if unclear
4. Delete if never used (skills are cheap to recreate)
