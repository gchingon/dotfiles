# gen-epi.py - Podcast Episode Generator

**Location**: `/Users/schingon/.config/rx/gen-epi.py`
**Version**: 1.0.0

## Overview

Automated Python script for creating podcast episodes without training wheels. Handles episode numbering, rotation schedules, template substitution, and context logging.

## Quick Start

```bash
# Add to PATH (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/.config/rx:$PATH"

# Or create alias
alias gen-epi="/Users/schingon/.config/rx/gen-epi.py"
```

## Usage Examples

### Interactive Mode (Recommended for first-time use)
```bash
gen-epi.py
```
Prompts for:
- Episode type (auto-suggests based on rotation)
- Title/topic
- Guest name (if PREREC)
- Source URL (optional)

### Quick Standard Episode
```bash
gen-epi.py --topic "Dating Red Flags in Your 30s"
```

### PREREC Episode
```bash
gen-epi.py --prerec "Dr. Emily Nagoski" --topic "Come As You Are"
```

### With Reddit Source
```bash
gen-epi.py --topic "Ghosting After 3 Dates" --reddit "https://reddit.com/r/dating_advice/comments/abc123"
```

### With Video Source
```bash
gen-epi.py --topic "Gen-X Nostalgia" --video "https://youtube.com/watch?v=abc123" --type throwback
```

### Check Rotation Schedule
```bash
gen-epi.py --check-rotation
```

### Force Specific Type (Override Rotation)
```bash
gen-epi.py --type conspiracy --topic "Did Dating Apps Kill Romance?"
```

## Episode Types

| Type | Template | Description |
|------|----------|-------------|
| **standard** | `episode-standard.md` | Regular episode with 2-5 segments on core content pillars |
| **prerec** | `episode-prerec.md` | Pre-recorded guest interview (PremiereHybrid format) |
| **throwback** | `episode-throwback.md` | 80s/90s nostalgia or personal story time |
| **ethereal** | `episode-ethereal.md` | Consciousness, deity, religion topics |
| **conspiracy** | `episode-conspiracy.md` | Conspiracy theory (Gallo picks: for/against/skeptic) |

## Rotation Rules

- **Every 5th episode**: Throwback (80s/90s nostalgia)
- **Every 7th episode**: Conspiracy
- **Every 9th episode**: Ethereal (consciousness/deity/religion)

The script auto-detects rotation matches and suggests the appropriate template.

## What It Does

1. **Auto-detects next episode number** by scanning `publisht-podcast-epis/` for highest `0nnn-*.md`
2. **Checks rotation schedule** and suggests special episode types
3. **Loads appropriate template** from `templates/episode-*.md`
4. **Substitutes variables**:
   - `{episode_number}` → Auto-incremented (e.g., `0126`)
   - `{title}` → Provided topic
   - `{date}` → Today's date (YYYY-MM-DD)
   - `{guest_name}` → Guest name (PREREC only)
   - `{source}` → Reddit/video URL (if provided)
5. **Creates episode file** in `publisht-podcast-epis/`
6. **Generates context log** in `context/YYYY-MM-DD-episode-NNN-generated.md`
7. **Displays next steps** with file paths

## Output Files

### Episode File
**Location**: `/Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/`
**Format**: `0126-dating-red-flags.md` (standard) or `0126-PREREC-guest-name.md` (prerec)

### Context Log
**Location**: `/Users/schingon/Documents/notes/projects/podcast/context/`
**Format**: `2025-11-02-episode-0126-generated.md`
**Contents**:
- Generation timestamp
- Episode details
- Rotation match info
- Next steps checklist
- Quick commands

## Next Steps After Generation

1. **Review episode file** - Check template structure and placeholders
2. **Assign segments** - Create 2-5 segment files in `segments/`
3. **Gather content** - Research, find sources, identify references
4. **Complete production checklist** - Work through tasks in episode file
5. **Refine hook** - Craft compelling opening based on content
6. **SEO keywords** - Finalize keywords and target phrases
7. **Brand alignment** - Check tone/voice against `brand.md`

## Error Handling

- **Missing templates**: Error message with missing file path
- **File exists**: Won't overwrite existing episodes
- **Invalid input**: Validates episode type and required fields
- **Directory creation**: Auto-creates `publisht-podcast-epis/` and `context/` if missing

## Features

- ✓ Auto-incrementing episode numbers (scans existing files)
- ✓ Rotation schedule detection (5th/7th/9th episodes)
- ✓ Interactive and CLI modes
- ✓ Template substitution (YAML frontmatter + content)
- ✓ Context logging for tracking
- ✓ Colorized output (with graceful fallback)
- ✓ Comprehensive help documentation
- ✓ Source URL integration (Reddit/video)
- ✓ PREREC guest handling
- ✓ Slug generation for filenames

## Dependencies

**Required**: Python 3.8+

**Optional**:
- `colorama` - For colored terminal output (graceful fallback if missing)

```bash
# Install optional dependencies
pip3 install colorama
```

## Troubleshooting

### Script not found
```bash
# Make sure it's executable
chmod +x /Users/schingon/.config/rx/gen-epi.py

# Add to PATH or use full path
/Users/schingon/.config/rx/gen-epi.py --help
```

### Template not found
Check that templates exist:
```bash
ls /Users/schingon/Documents/notes/projects/podcast/templates/episode-*.md
```

### Episode number wrong
The script scans `publisht-podcast-epis/` for highest episode number. Make sure:
- Files follow format: `0nnn-title.md`
- Episode directory path is correct

### No color output
Install colorama or ignore (works fine without colors):
```bash
pip3 install colorama
```

## Project Structure

```
/Users/schingon/Documents/notes/projects/podcast/
├── publisht-podcast-epis/     # Generated episodes
│   └── 0126-topic.md
├── templates/                  # Episode templates
│   ├── episode-standard.md
│   ├── episode-prerec.md
│   ├── episode-throwback.md
│   ├── episode-ethereal.md
│   └── episode-conspiracy.md
├── context/                    # Generation logs
│   └── 2025-11-02-episode-0126-generated.md
├── segments/                   # Segment files
└── brand.md                    # Brand guidelines
```

## Version History

- **1.0.0** (2025-11-02)
  - Initial release
  - Auto-detection of episode numbers
  - Rotation schedule checking
  - Template substitution
  - Context logging
  - Interactive and CLI modes
  - Colorized output

## Author

Gallo (via Claude)

---

Generated: 2025-11-02
