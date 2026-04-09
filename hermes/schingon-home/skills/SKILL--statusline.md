---
description: Visual context manager with progress bar and backup reminders for Hermes
tags: [hermes, context, ui, monitoring, backup]
---

# STATUSLINE — Context Monitor & Backup Reminder

Visual status indicator for Hermes sessions with color-coded progress and automated backup prompts.

## When to Use

At the start of every response, after context compression events, or when explicitly asked for /statusline.

## Display Format

```
┌─ /path/to/current/dir ─┬─ 45% ─┬─ 12:34 ─┬─ 89.45K / 200.00K ─┐
│ context ████████░░    │ 70%   │ 1h 23m  │ 150.2K / 200.00K     │
│ 🔶 ⚠️ /back-up/session │ yellow│ time    │ tokens               │
└────────────────────────┴───────┴─────────┴──────────────────────┘
```

## Color Thresholds

| Range | Color | Icon | Message | Action |
|-------|-------|------|---------|--------|
| 0-60% | 🟢 Green | — | — | Normal operation |
| 60-70% | 🟡 Yellow | 👉 | /back-up/session | Consider backup |
| 70-80% | 🟠 Orange | 🔶 ⚠️ | /back-up/session | Strongly recommend backup |
| 80%+ | 🔴 Red (blinking) | 💀 🚨 | /back-up/session NOW❗ | MANDATORY backup |

## Progress Bar Blocks

█ = filled (10% each)
░ = empty

Examples:
- 30%: ███░░░░░░░
- 50%: █████░░░░░
- 75%: ███████▌░░
- 90%: █████████░

## Sections

| Section | Format | Example |
|---------|--------|---------|
| Directory | /path/to/dir | ~/projects/webapp |
| Context % | NN% | 65% |
| Session Time | HH:MM or Xm | 1h 23m |
| Tokens | X.XXK / YYY.YYK | 125.50K / 200.00K |

## Automations

### At Context Compression
When compression occurs, automatically display:
```
💾 Context compressed: NNNN → MMMM tokens (XX% reduction)
/statusline to see current state
```

### At 60% Context
Add after response:
```
👉 Context at 60%. Consider: /back-up/session
```

### At 70% Context
Add after response:
```
🔶 ⚠️ Context at 70%. Recommended: /back-up/session
```

### At 80%+ Context
Beginning of response must include:
```
🚨 Context at XX% — CRITICAL
💀 /back-up/session NOW❗
```

## Commands

| Command | Action |
|---------|--------|
| /statusline | Show full status |
| /back-up | Trigger session backup |
| /context | Show loaded context |
| /tokens | Show detailed token usage |

## Implementation Notes

- Estimate context percentage from tool call patterns
- Session time tracked from conversation start
- Token counts are estimates (actual limits vary by model)
- Green/yellow/orange = normal display
- Red/blinking = requires immediate action header

## Example Statuslines

```
# Normal (45%)
┌─ ~/projects/webapp ────┬─ 45% ─┬─ 0h 12m ─┬─ 90.00K / 200.00K ─┐
│ █████░░░░░             │       │          │                     │
└────────────────────────┴───────┴──────────┴─────────────────────┘

# Warning (70%)
┌─ ~/projects/webapp ────┬─ 70% ─┬─ 0h 45m ─┬─ 140.00K / 200.00K ┐
│ ███████░               │ 🟡    │          │                     │
│ 🔶 ⚠️ /back-up/session  │       │          │                     │
└────────────────────────┴───────┴──────────┴─────────────────────┘

# Critical (85%)
🚨 Context at 85% — CRITICAL
💀 /back-up/session NOW❗
┌─ ~/projects/webapp ────┬─ 85% ─┬─ 1h 30m ─┬─ 170.00K / 200.00K ┐
│ █████████░             │ 🔴💀  │          │                     │
💀 🚨 /back-up/session NOW❗
└────────────────────────┴───────┴──────────┴─────────────────────┘
```
