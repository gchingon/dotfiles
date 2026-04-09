#!/usr/bin/env zsh
# ~/.hermes/scripts/save-session.sh
# Save Hermes session to Obsidian vault

set -e

PROJECT="${1:-unknown}"
TOPIC="${2:-session}"
VAULT="${HERMES_OBSIDIAN_VAULT:-${HOME}/Library/Mobile Documents/iCloud~md~obsidian/Documents/Second Brain}"
SESSIONS_DIR="${VAULT}/Sessions"

# Generate timestamp
DATE=$(date +%Y-%m-%d)
DATETIME=$(date +%Y-%m-%dT%H:%M:%S)
SESSION_ID=$(date +%s)

# Create sessions directory
mkdir -p "${SESSIONS_DIR}"

FILENAME="${DATE}-${PROJECT}-${TOPIC}.md"
FILEPATH="${SESSIONS_DIR}/${FILENAME}"

# Build the session content
cat > "${FILEPATH}" << EOF
---
date: ${DATETIME}
project: ${PROJECT}
topic: ${TOPIC}
tags: [session-log, ${PROJECT}, ${TOPIC}]
agent: hermes
session_id: ${SESSION_ID}
---

# ${PROJECT} - ${TOPIC}

## Summary
<!-- Fill in 2-3 sentences -->

## Key Decisions
- <!-- Decision 1 -->
- <!-- Decision 2 -->

## Changes Made
- <!-- Change 1 -->
- <!-- Change 2 -->

## Topics Referenced
- <!-- [[Topic Name]] (type: person|project|tool) -->

## Actions Taken
- <!-- Action 1 -->

## Files Modified
- <!-- /path/to/file -->

## Open Items
- [ ] <!-- Open item 1 -->

## Next Steps
1. <!-- Step 1 -->

---
## See Also
<!-- Links added automatically by topic linker -->
EOF

echo "Session log created: ${FILEPATH}"
