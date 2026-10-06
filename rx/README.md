# Global Scripts Reference (rx/)

50 executable scripts available from anywhere via `~/.local/bin/`. Each script is symlinked for easy access.

---

## ✅ Refactoring Complete

### ❌ Deleted (4)
1. **`find-and-do.sh`** — Wrapper, use `filemgr` directly
2. **`dedupe-mp3.sh`** → Converted to `dedupemuz()` function in modules/functions.zsh
3. **`delete_old_nvim_swap_files.sh`** → Converted to `cleannvimswp()` function in modules/functions.zsh
4. **`app-switch.sh`** — Redundant with yabai window switching
5. **`calendar-next-meeting.sh`** — Niche, low usage

### ✅ Converted to ZSH Functions
- **`cd-into-made-dir.sh`** → `mkd()` in modules/functions.zsh (already existed)
- **`sketchybar-restart.sh`** → Added to modules/config.zsh as `sketchybar-restart()`

### ✓ Keep As-Is (41 scripts)
- Vault suite (agent-vault-*.sh) — essential
- Note-taking (daily-notes, pod-content-note) — daily use
- Large utilities (expand.sh, bak.sh, meta_helper.sh) — full-featured
- Media (video-converter) — specialized but useful
- System (yabai-layout, macos-defaults) — essential

---

## 📊 Summary

**Before refactoring:** 50 scripts
**After refactoring:** 45 scripts

| Action | Count | Scripts |
|--------|-------|---------|
| Deleted | 5 | find-and-do, dedupe-mp3, delete_swaps, app-switch, calendar-next-meeting |
| Converted → ZSH functions | 2 | mkd (already existed), sketchybar-restart |
| Kept | 43 | Vault suite, notes, media, utilities, system tools |
| Archive (saved for reference) | 1 | igdn (Instagram downloader) |

**Result:** Cleaner, more cohesive setup. Functions in shell for quick access, larger utilities remain as scripts.

---

## 🎯 Most-Used Scripts

**Daily:**
- `daily-notes` — Daily note creation
- `dots-sync` — Push config changes
- `yabai-layout` — Window management
- `vault-sync` — Backup sync

**Weekly:**
- `video-converter` — Media conversion
- `pod-content-note` — Podcast notes
- `blog` — Blog posting
- `bak` — Backup with versions

**One-Time/Setup:**
- `bootstrap` — New machine setup
- `setup_ssh` — SSH configuration
- `vault-init` — Vault initialization

---

## See Also

- [STRUCTURE.md](../STRUCTURE.md) — Config organization
- [SETUP.md](../SETUP.md) — Setup & maintenance guide
