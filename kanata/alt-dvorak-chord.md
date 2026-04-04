# Alt Dvorak Chord Kanata Config

## Overview
Chord-based sublayer system for ergonomic app switching without HYPER key combos.

## Key Bindings

### Modifier Keys (unchanged from your current)
- **Caps** — Tap: Esc, Hold: Meh (⌃⌥⇧)
- **Right Shift** — Tap: Esc, Hold: Shift  [NEW]

### Chord Entry (NEW)
Press **Return + Tab together** → enters leader layer
- Then tap a key to select sublayer (no holding required)
- One-shot: automatically returns to main layer after action

### Sublayer Selection (in Leader layer)
| Key | Sublayer |
|-----|----------|
| a | Apps (yabai app switching) |
| o | Sessions (kitty sessions) |
| e | Nav (arrow keys) |
| h | Raycast commands |

### Apps Layer (yabai focus/launch)
| Key | App |
|-----|-----|
| e (.) | Kitty |
| r (p) | Obsidian |
| t (y) | Arc |
| y (f) | Raycast |
| u (g) | Discord |
| i (c) | Spotify |
| o (r) | Claude |
| p (l) | Safari |
| h (d) | Calendar |
| n (t) | Finder |

### Sessions Layer (kitty)
| Key | Session |
|-----|---------|
| e (.) | ~/Documents |
| r (p) | ~/.config |
| t (y) | ssh 2mini |
| y (f) | ssh 4mini |
| n (t) | New kitty window |

### Nav Layer
| Key | Action |
|-----|--------|
| d/h/t/n | ← ↓ ↑ → |
| f/g | word left/right |
| c/r | pgup/pgdn |
| s | home/end |

### Raycast Layer
| Key | Command |
|-----|---------|
| a | AI Chat |
| e | Clipboard history |
| i | Emoji picker |
| u | File search |
| g | Calculator |
| ; | Toggle fullscreen |
| / | Left half (window position) |

## Testing

1. Backup your current kanata:
   ```bash
   cp ~/.config/kanata/macos.kbd ~/.config/kanata/macos.kbd.backup
   ```

2. Test the new config:
   ```bash
   # Stop current kanata first
   sudo launchctl unload ~/Library/LaunchAgents/com.example.kanata.plist
   
   # Test new config (foreground, exits on error)
   sudo kanata -c ~/.config/kanata/alt-dvorak-chord.kbd --debug
   ```

3. If working, create a launch agent for it or switch the config file name.

## Differences from Current Config

| Feature | Current | New |
|---------|---------|-----|
| App switching | HYPER+key via Raycast | Chord → tap key via yabai |
| Leader | N/A | Return+Tab chord |
| Sublayers | Hold key (s, c, ret) | Tap key (one-shot) |
| Right Shift | Shift | Esc tap, Shift hold |
| Window sizing | N/A | Raycast (keep existing) |

## Troubleshooting

**Chord not working?**
- Try pressing Return and Tab closer together (<80ms)
- Check with `--debug` flag to see chord detection

**Apps not focusing?**
- Ensure `$RX` environment variable is set (in zshenv)
- Check `app-switch.sh` has execute permissions

**Kitty sessions not working?**
- Ensure kitty has `allow_remote_control yes` in kitty.conf
- Test `kitty-session docs` from terminal first
