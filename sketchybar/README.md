# SketchyBar Map

This is the intended v1 shape while yabai padding stays unchanged:

- Left: Mission Control spaces.
- Left-adjacent: front app / active window context.
- Center: reserved for a future mode indicator or focused task.
- Right: Itsycal/date, volume, Wi-Fi, Bluetooth, battery percentage,
  Control Center, and the utility app popup.

Active utility app popup:

- `󱂀` shows only running utilities from Typinator, DockDoor, ProNotes, Alcove,
  Claude, Homerow, and Keyboard Maestro.
- Selecting a utility is a proxy click for its menu-bar/status item. SketchyBar
  cannot move native macOS menu extras into its popup directly; each item has to
  be listed here by process/app name.
- `󰅩` triggers macOS Control Center.
- Wi-Fi shows a bright connected icon or a dim slashed icon.
- Bluetooth shows state by icon and a bare connected-device count.

Theme integration should read from `~/.config/colors/colors.json` later. Do not
make yabai padding depend on SketchyBar until the final bar height and visible
items are settled.
