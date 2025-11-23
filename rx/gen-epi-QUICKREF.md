# gen-epi.py - Quick Reference Card

## One-Liner Setup
```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/.config/rx:$PATH"
```

## Most Common Commands

```bash
# Interactive mode (best for learning)
gen-epi.py

# Quick standard episode
gen-epi.py --topic "Your Title Here"

# PREREC episode
gen-epi.py --prerec "Guest Name" --topic "Episode Topic"

# Check rotation schedule
gen-epi.py --check-rotation

# With Reddit source
gen-epi.py --topic "Title" --reddit "URL"

# Help
gen-epi.py --help
```

## Flags Cheat Sheet

| Flag | Description | Example |
|------|-------------|---------|
| `--topic` | Episode title | `--topic "Dating Red Flags"` |
| `--type` | Force episode type | `--type conspiracy` |
| `--prerec` | Guest name (implies PREREC) | `--prerec "Dr. Smith"` |
| `--reddit` | Reddit source URL | `--reddit "https://..."` |
| `--video` | Video source URL | `--video "https://..."` |
| `--check-rotation` | Show schedule, don't create | `--check-rotation` |
| `--version` | Show version | `--version` |
| `--help` | Full help | `--help` |

## Episode Types

| Type | When | Template |
|------|------|----------|
| **standard** | Default | Regular 2-5 segments |
| **prerec** | Guest interview | PremiereHybrid format |
| **throwback** | Every 5th (or manual) | 80s/90s nostalgia |
| **conspiracy** | Every 7th (or manual) | Conspiracy theory |
| **ethereal** | Every 9th (or manual) | Consciousness/deity |

## Rotation Math

- **Episode ÷ 5 = 0 remainder** → Throwback
- **Episode ÷ 7 = 0 remainder** → Conspiracy
- **Episode ÷ 9 = 0 remainder** → Ethereal

Examples:
- 125, 130, 135 → Throwback
- 126, 133, 140 → Conspiracy
- 126, 135, 144 → Ethereal

## File Locations

```
~/.config/rx/
├── gen-epi.py           # The script
├── gen-epi-README.md    # Full documentation
├── gen-epi-EXAMPLES.md  # Real-world examples
└── gen-epi-QUICKREF.md  # This file

~/Documents/notes/projects/podcast/
├── publisht-podcast-epis/  # Generated episodes
├── templates/               # Episode templates
├── context/                 # Generation logs
└── segments/                # Segment files
```

## Generated Files

**Episode**: `publisht-podcast-epis/0126-topic-slug.md`
**Context Log**: `context/2025-11-02-episode-0126-generated.md`

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Script not found | `chmod +x ~/.config/rx/gen-epi.py` |
| Template missing | Check `templates/episode-*.md` exists |
| File exists error | Delete old file or increment episode # |
| Wrong episode number | Check `publisht-podcast-epis/` for highest # |
| No colors | `pip3 install colorama` (optional) |

## Typical Workflow

```bash
# 1. Check rotation
gen-epi.py --check-rotation

# 2. Create episode
gen-epi.py --topic "Your Title"

# 3. Open episode file
open publisht-podcast-epis/0126-your-title.md

# 4. Create segments
cd segments/
# ... create segment files ...

# 5. Link segments in episode
# Edit episode file, add segment links

# 6. Complete checklist
# Work through production checklist in episode
```

## Next Steps After Generation

1. ✓ Review episode file
2. ✓ Create 2-5 segments
3. ✓ Gather content/sources
4. ✓ Complete production checklist
5. ✓ Refine hook
6. ✓ Finalize SEO keywords
7. ✓ Check brand alignment

## Remember

- Script auto-detects next episode number
- Rotation is suggestion, not requirement
- Templates live in `templates/`
- Context logs track generation history
- Filenames auto-slugify (spaces → hyphens)
- Source URLs are optional

---

**Full Docs**: `~/.config/rx/gen-epi-README.md`
**Examples**: `~/.config/rx/gen-epi-EXAMPLES.md`
**Version**: 1.0.0
