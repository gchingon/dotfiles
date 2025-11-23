# gen-epi.py - Installation & Setup Guide

## Files Created

The following files have been created in `/Users/schingon/.config/rx/`:

1. **gen-epi.py** (21KB) - The main executable script
2. **gen-epi-README.md** (6.3KB) - Complete documentation
3. **gen-epi-EXAMPLES.md** (16KB) - Real-world usage examples
4. **gen-epi-QUICKREF.md** (3.7KB) - Quick reference card
5. **gen-epi-INSTALL.md** (this file) - Installation guide

## Installation Steps

### Step 1: Verify Script is Executable

The script is already executable (`chmod +x` applied). Verify:

```bash
ls -l /Users/schingon/.config/rx/gen-epi.py
```

You should see `-rwxr-xr-x` permissions.

### Step 2: Add to PATH (Recommended)

Add the script directory to your PATH for easy access:

**For zsh (default on macOS):**
```bash
echo 'export PATH="$HOME/.config/rx:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**For bash:**
```bash
echo 'export PATH="$HOME/.config/rx:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Verify:**
```bash
which gen-epi.py
# Should output: /Users/schingon/.config/rx/gen-epi.py
```

### Step 3: Create Alias (Optional)

For even shorter command:

```bash
# Add to ~/.zshrc or ~/.bashrc
echo 'alias gen-epi="/Users/schingon/.config/rx/gen-epi.py"' >> ~/.zshrc
source ~/.zshrc
```

Now you can use just `gen-epi` instead of `gen-epi.py`.

### Step 4: Install Optional Dependencies

For colorized output (highly recommended):

```bash
pip3 install colorama
```

**Note:** The script works fine without colorama (falls back to plain text).

### Step 5: Verify Project Structure

Ensure project directories exist:

```bash
ls -la /Users/schingon/Documents/notes/projects/podcast/
```

Required directories:
- `publisht-podcast-epis/` - Where episodes are generated
- `templates/` - Episode templates
- `context/` - Generation logs
- `segments/` - Segment files

The script will auto-create missing directories except `templates/`.

### Step 6: Verify Templates

Check that all episode templates exist:

```bash
ls /Users/schingon/Documents/notes/projects/podcast/templates/episode-*.md
```

Should show:
- episode-standard.md
- episode-prerec.md
- episode-throwback.md
- episode-ethereal.md
- episode-conspiracy.md

**If any are missing**, the script will error when trying to use that episode type.

## Quick Test

Test the installation:

```bash
# Check version
gen-epi.py --version
# Output: gen-epi.py 1.0.0

# Check rotation schedule
gen-epi.py --check-rotation
# Shows next episode number and rotation schedule

# View help
gen-epi.py --help
# Shows full usage documentation
```

## Usage After Installation

### Quickest Start
```bash
gen-epi.py
```
Interactive mode walks you through everything.

### Common Commands
```bash
# Quick standard episode
gen-epi.py --topic "Your Episode Title"

# PREREC episode
gen-epi.py --prerec "Guest Name" --topic "Episode Topic"

# With source
gen-epi.py --topic "Title" --reddit "https://reddit.com/..."

# Check rotation
gen-epi.py --check-rotation
```

## Documentation

All documentation files are in `/Users/schingon/.config/rx/`:

| File | Purpose | Size |
|------|---------|------|
| **gen-epi-QUICKREF.md** | Quick reference card | 3.7KB |
| **gen-epi-README.md** | Complete documentation | 6.3KB |
| **gen-epi-EXAMPLES.md** | Real-world examples | 16KB |
| **gen-epi-INSTALL.md** | This file | - |

**Start with**: `gen-epi-QUICKREF.md` for most common commands
**Reference**: `gen-epi-README.md` for full features
**Learn by example**: `gen-epi-EXAMPLES.md` for workflows

## Next Steps

1. **Read Quick Reference**:
   ```bash
   cat ~/.config/rx/gen-epi-QUICKREF.md
   ```

2. **Test Interactive Mode**:
   ```bash
   gen-epi.py
   ```
   (Cancel when prompted to avoid creating test episode)

3. **Check Current Rotation**:
   ```bash
   gen-epi.py --check-rotation
   ```

4. **Create Your First Episode**:
   ```bash
   gen-epi.py --topic "Your First Episode Topic"
   ```

## Troubleshooting

### Command not found
- Check PATH: `echo $PATH` should include `/Users/schingon/.config/rx`
- Use full path: `/Users/schingon/.config/rx/gen-epi.py`
- Re-source shell config: `source ~/.zshrc`

### Template not found
- Check templates exist: `ls ~/Documents/notes/projects/podcast/templates/`
- If missing, create from examples or existing episodes

### Wrong episode number
- Script scans `publisht-podcast-epis/` for highest number
- Check existing files: `ls ~/Documents/notes/projects/podcast/publisht-podcast-epis/0*.md | sort`
- Episode files must match pattern: `0nnn-title.md`

### File already exists
- Script prevents overwriting
- Delete existing file or use different title
- Check: `ls ~/Documents/notes/projects/podcast/publisht-podcast-epis/`

### No colors in output
- Install colorama: `pip3 install colorama`
- Or ignore - script works fine without colors

## Uninstallation

To remove the script:

```bash
# Remove script and docs
rm /Users/schingon/.config/rx/gen-epi*

# Remove from PATH (edit ~/.zshrc or ~/.bashrc)
# Remove line: export PATH="$HOME/.config/rx:$PATH"

# Remove alias if created
# Remove line: alias gen-epi="..."

# Reload shell
source ~/.zshrc
```

Generated episodes and context logs in the project directory are not affected.

## Support

For issues or questions:
1. Check **gen-epi-QUICKREF.md** for common commands
2. Review **gen-epi-EXAMPLES.md** for usage patterns
3. Read **gen-epi-README.md** for full documentation
4. Check project CLAUDE.md for podcast workflow context

## Version

**Current Version**: 1.0.0
**Created**: 2025-11-02
**Python**: 3.8+ required
**Platform**: macOS (tested on Darwin 25.0.0)

---

Installation complete! Run `gen-epi.py --help` to get started.
