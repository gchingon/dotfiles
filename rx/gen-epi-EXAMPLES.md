# gen-epi.py - Real-World Usage Examples

## Scenario 1: Standard Episode (Auto-Rotation)

You want to create the next episode. The script detects it's episode 126, which matches the conspiracy rotation (divisible by 7).

```bash
$ gen-epi.py

======================================================================
              Podcast Episode Generator - Interactive Mode
======================================================================

ℹ Next episode number: 0126
⚠ Rotation match detected: Episode 126 should be CONSPIRACY
  Use conspiracy template? [Y/n]: y
✓ Episode type: conspiracy

Enter episode title: Did Dating Apps Kill Romance?
Enter source URL (Reddit/video) [optional]:

──────────────────────────────────────────────────────────────────────
Episode 0126: Did Dating Apps Kill Romance?
Type: conspiracy
──────────────────────────────────────────────────────────────────────

Generate episode? [Y/n]: y
✓ Episode created: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0126-conspiracy-did-dating-apps-kill-romance.md
✓ Context log created: /Users/schingon/Documents/notes/projects/podcast/context/2025-11-02-episode-0126-generated.md

──────────────────────────────────────────────────────────────────────
Next Steps:
──────────────────────────────────────────────────────────────────────
1. Open episode file: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0126-conspiracy-did-dating-apps-kill-romance.md
2. Review context log: /Users/schingon/Documents/notes/projects/podcast/context/2025-11-02-episode-0126-generated.md
3. Create segments in: /Users/schingon/Documents/notes/projects/podcast/segments/
4. Complete production checklist in episode file
```

**Result**:
- Episode 0126 created with conspiracy template
- Context log tracks generation details
- Ready to fill in segments and content

---

## Scenario 2: Quick Standard Episode (CLI)

You're in a hurry and want to create a standard episode about dating red flags.

```bash
$ gen-epi.py --topic "5 Red Flags That Scream Avoidant Attachment"

======================================================================
                      Podcast Episode Generator
======================================================================

ℹ Next episode number: 0127
✓ Episode type: standard
✓ Episode created: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0127-5-red-flags-that-scream-avoidant-attachment.md
✓ Context log created: /Users/schingon/Documents/notes/projects/podcast/context/2025-11-02-episode-0127-generated.md

──────────────────────────────────────────────────────────────────────
Episode 0127 Generated Successfully
──────────────────────────────────────────────────────────────────────
File: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0127-5-red-flags-that-scream-avoidant-attachment.md
Log:  /Users/schingon/Documents/notes/projects/podcast/context/2025-11-02-episode-0127-generated.md
```

**Result**:
- Episode 0127 created instantly
- Standard template used (no rotation match)
- Filename auto-slugified: `5-red-flags-that-scream-avoidant-attachment`

---

## Scenario 3: PREREC with Guest

You recorded an interview with Dr. Emily Nagoski about sexual wellness.

```bash
$ gen-epi.py --prerec "Dr. Emily Nagoski" --topic "Come As You Are: Stress and Desire"

======================================================================
                      Podcast Episode Generator
======================================================================

ℹ Next episode number: 0128
✓ Episode type: prerec
✓ Episode created: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0128-PREREC-come-as-you-are-stress-and-desire.md
✓ Context log created: /Users/schingon/Documents/notes/projects/podcast/context/2025-11-02-episode-0128-generated.md

──────────────────────────────────────────────────────────────────────
Episode 0128 Generated Successfully
──────────────────────────────────────────────────────────────────────
File: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0128-PREREC-come-as-you-are-stress-and-desire.md
Log:  /Users/schingon/Documents/notes/projects/podcast/context/2025-11-02-episode-0128-generated.md
```

**Result**:
- PREREC template with guest information
- Guest name auto-filled in YAML frontmatter
- PremiereHybrid format checklist included

---

## Scenario 4: Reddit Source Integration

You found a great Reddit post about situationships and want to create an episode.

```bash
$ gen-epi.py --topic "Why Your Situationship is Actually Trauma Bonding" --reddit "https://reddit.com/r/dating_advice/comments/xyz123/situationship_or_trauma"

======================================================================
                      Podcast Episode Generator
======================================================================

ℹ Next episode number: 0129
✓ Episode type: standard
✓ Episode created: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0129-why-your-situationship-is-actually-trauma-bonding.md
✓ Context log created: /Users/schingon/Documents/notes/projects/podcast/context/2025-11-02-episode-0129-generated.md

──────────────────────────────────────────────────────────────────────
Episode 0129 Generated Successfully
──────────────────────────────────────────────────────────────────────
File: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0129-why-your-situationship-is-actually-trauma-bonding.md
Log:  /Users/schingon/Documents/notes/projects/podcast/context/2025-11-02-episode-0129-generated.md
```

**Result**:
- Reddit URL added to `source:` field in YAML frontmatter
- URL also added to "Notes / Content Links" section
- Ready to pull quotes and examples from Reddit thread

---

## Scenario 5: Throwback Episode (Rotation Override)

It's episode 130 (divisible by 5), so the script suggests throwback. You want a different type.

```bash
$ gen-epi.py

======================================================================
              Podcast Episode Generator - Interactive Mode
======================================================================

ℹ Next episode number: 0130
⚠ Rotation match detected: Episode 130 should be THROWBACK
  Use throwback template? [Y/n]: n

Select episode type:
  1. standard     - Regular episode (2-5 segments on core pillars)
  2. prerec       - Pre-recorded guest interview (PremiereHybrid)
  3. throwback    - 80s/90s nostalgia or personal story time
  4. ethereal     - Consciousness, deity, religion topics
  5. conspiracy   - Conspiracy theory (Gallo picks: for/against/skeptic)

Enter choice [1-5]: 1
✓ Episode type: standard

Enter episode title: Open Relationships: Who Actually Benefits?
Enter source URL (Reddit/video) [optional]:

──────────────────────────────────────────────────────────────────────
Episode 0130: Open Relationships: Who Actually Benefits?
Type: standard
──────────────────────────────────────────────────────────────────────

Generate episode? [Y/n]: y
```

**Result**:
- Rotation suggestion overridden
- Standard template used instead
- User maintains creative control

---

## Scenario 6: Check What's Coming Up

Before planning content, you want to see the rotation schedule.

```bash
$ gen-epi.py --check-rotation

======================================================================
                      Episode Rotation Schedule
======================================================================

ℹ Current episode number: 0126

Episode 126 matches rotation:
  Type: CONSPIRACY
  Description: Conspiracy theory (Gallo picks: for/against/skeptic)

Upcoming Rotation Schedule:
──────────────────────────────────────────────────────────────────────
  Episode 0126: CONSPIRACY
  Episode 0130: THROWBACK
  Episode 0133: CONSPIRACY
  Episode 0135: THROWBACK
  Episode 0140: THROWBACK
  Episode 0144: ETHEREAL
  Episode 0145: THROWBACK
──────────────────────────────────────────────────────────────────────
```

**Result**:
- See next 15-20 episodes and their rotation types
- Plan content calendar ahead
- No episode generated (info only)

---

## Scenario 7: Ethereal Episode with Video Source

Episode 144 is ethereal. You want to create an episode about consciousness based on a video.

```bash
$ gen-epi.py --type ethereal --topic "The Illusion of Self in Modern Dating" --video "https://youtube.com/watch?v=quantum-consciousness-123"

======================================================================
                      Podcast Episode Generator
======================================================================

ℹ Next episode number: 0144
✓ Episode type: ethereal
✓ Episode created: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0144-ethereal-the-illusion-of-self-in-modern-dating.md
✓ Context log created: /Users/schingon/Documents/notes/projects/podcast/context/2025-11-02-episode-0144-generated.md

──────────────────────────────────────────────────────────────────────
Episode 0144 Generated Successfully
──────────────────────────────────────────────────────────────────────
File: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0144-ethereal-the-illusion-of-self-in-modern-dating.md
Log:  /Users/schingon/Documents/notes/projects/podcast/context/2025-11-02-episode-0144-generated.md
```

**Result**:
- Ethereal template used
- Video URL added to sources
- Ready for consciousness/philosophy content

---

## Scenario 8: File Already Exists

You try to create episode 126 again.

```bash
$ gen-epi.py --topic "Another Topic"

======================================================================
                      Podcast Episode Generator
======================================================================

ℹ Next episode number: 0126
⚠ Rotation match: Episode 126 should be CONSPIRACY
✓ Episode type: conspiracy
✗ Episode file already exists: /Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0126-conspiracy-another-topic.md
```

**Result**:
- Script prevents overwriting existing episodes
- Safe against accidental data loss
- Clear error message with file path

---

## Workflow Integration Examples

### Morning Content Planning
```bash
# Check what's coming up
gen-epi.py --check-rotation

# Plan next 3 episodes based on rotation
# Episode 126: conspiracy
# Episode 127: standard
# Episode 128: standard
```

### Quick Episode Creation
```bash
# Monday: Create episode for Friday premiere
gen-epi.py --topic "Why Anxious-Avoidant Traps Feel Like Love"

# Tuesday: Review and assign segments
# Wednesday: Record segments
# Thursday: Edit and finalize
# Friday: Premiere
```

### PREREC Saturday Workflow
```bash
# Saturday: Record guest interview
gen-epi.py --prerec "Dr. Alexandra Solomon" --topic "Loving Bravely in the Age of Tinder"

# Sunday: Order transcript
# Monday: Review transcript, create segments
# Friday: PremiereHybrid live event
```

### Content Sprint
```bash
# Generate 3 episodes in one sitting
gen-epi.py --topic "Love Languages Are Bullshit"
gen-epi.py --topic "Your Ex Isn't Toxic, You're Just Incompatible"
gen-epi.py --topic "Why Good Sex Requires Uncomfortable Conversations"

# Spend rest of week filling in content
```

---

## Advanced Usage

### Scripted Batch Creation
```bash
#!/bin/bash
# batch-create-episodes.sh

TOPICS=(
    "Dating with ADHD: Chaos or Charm?"
    "Why Your Mom's Dating Advice is Outdated"
    "Polyamory Isn't the Answer to Monogamy's Problems"
)

for topic in "${TOPICS[@]}"; do
    gen-epi.py --topic "$topic"
    echo "---"
done
```

### Integration with Task Manager
```bash
# Create episode and open in Obsidian
gen-epi.py --topic "Title" && open -a Obsidian "/Users/schingon/Documents/notes/projects/podcast/publisht-podcast-epis/0126-*.md"
```

### Combining with Segment Generator
```bash
# Create episode
EPISODE_FILE=$(gen-epi.py --topic "Title" | grep "Episode created" | awk '{print $NF}')

# Create segments for episode
# (future segment generator integration)
```

---

## Tips & Best Practices

1. **Use `--check-rotation` regularly** - Plan content calendar ahead
2. **Interactive mode first** - Get familiar with the flow
3. **CLI for speed** - Once comfortable, use flags for quick creation
4. **Source URLs are optional** - Add them when you have specific Reddit/video inspiration
5. **Don't override rotations without reason** - They exist for content diversity
6. **Review context logs** - They track generation history and next steps
7. **Slugs auto-generate** - Don't worry about filename formatting

---

## Common Questions

**Q: What if I want to skip a rotation?**
A: Override with `--type standard` or choose different type in interactive mode

**Q: Can I create episodes out of order?**
A: Script always uses next highest number. Rename existing files if needed.

**Q: What if template is missing?**
A: Script will error with clear message. Check `templates/` directory.

**Q: How do I add segments?**
A: Manually create segment files in `segments/` and link in episode file

**Q: Can I edit generated episodes?**
A: Yes! They're markdown files. Edit freely after generation.

**Q: What if I made a mistake?**
A: Delete episode file and context log, run script again

---

Generated: 2025-11-02
