-- Hammerspoon config — Omarchy-style keybindings overlay
-- Reload after edits: `hs -c 'hs.reload()'` from terminal, or use the menu icon.

-- Enable the `hs` CLI so we can reload/test from the terminal
require("hs.ipc")

----------------------------------------------------------------------
-- Keybindings shown in the ALT+K popup (display only). The real bindings
-- live in ~/.config/kanata/*.kbd (layers) and the hs.hotkey.bind calls
-- below. Keys are PHYSICAL QWERTY positions (your Dvorak output differs).
-- Holding a layer key for 2s also pops up its own cheat sheet (see the
-- layerCheats table further down) — keep both in sync with kanata.kbd.
----------------------------------------------------------------------
local bindings = {
  -- Layer keys (kanata)
  { "HOLD caps",                "Apps layer + Meh (alt+ctrl+shift) · tap = esc" },
  { "HOLD tab",                 "Toggles layer + Shift+Cmd · tap = tab" },
  { "HOLD left ⌘",              "Yabai layer + Ctrl+Shift+Cmd · tap = Force Quit" },
  { "HOLD right ⌘",             "Goto layer + Hyper · tap = F18" },
  { "caps, then r",             "Raycast layer (one-shot, 3s)" },
  { "CTRL + DOWN + [",          "Restart yabai (lctl+down+[; / in Dvorak)" },
  { "RIGHT ALT (tap)",          "Empty Trash · hold = Alt+Cmd+Shift" },
  { "Hold any layer key 2s",    "Pop up that layer's cheat sheet" },

  -- Apps layer (hold caps)
  { "CAPS + y u i o p",         "Spotify · Passwords · Calendar · Preview · DaVinci Resolve" },
  { "CAPS + h j k l ; '",       "Comet · Claude · Obsidian · Notes · Messages · System Settings" },
  { "CAPS + return",            "kitty" },
  { "CAPS + n m , . /",         "Finder · Grok · WhatsApp · Clipboard history · Affinity Designer" },

  -- Toggles layer (hold tab)
  { "TAB + y u i o p",          "Screensaver · Printers & Scanners · Zoom · Calculator · AirDrop" },
  { "TAB + h j k l ; '",        "Wi-Fi · Bluetooth · Lock screen · Do Not Disturb · Mute mic · Caffeinate" },
  { "TAB + n m , . /",          "Sleep · Restart · Shut Down · Log Out · System Information" },
  { "TAB + 0",                  "(passes through) Shift+Cmd+0 → Vorssaint panel" },

  -- Yabai layer (hold left ⌘)
  { "LCMD + 1 2 3",             "Window to left / center / right third" },
  { "LCMD + q w e",             "Top-left / top-center / top-right sixth" },
  { "LCMD + a s d",             "Bottom-left / bottom-center / bottom-right sixth" },
  { "LCMD + j  /  p",           "Cycle left / right widths (repeat to cycle sizes)" },
  { "LCMD + i o  /  , .",       "Top-left·top-right / bottom-left·bottom-right quarters" },
  { "LCMD + r  f  v",           "Cycle top / bottom / thirds" },
  { "LCMD + m",                 "Fill the screen (not native fullscreen)" },
  { "LCMD + t  /  y",           "Move window to previous / next display" },

  -- Goto layer (hold right ⌘)
  { "RCMD + h j k l",           "nvim in ~/.config · repos · Documents · notes (kitty)" },
  { "RCMD + y u i o",           "Obsidian: ~/.config · repos · Documents · notes" },

  -- Raycast layer (caps, then r)
  { "RAYCAST e r t y u i o",    "kitty sessions: dots · nvim · docker · podcast · home · ssh-2mini · ssh-4mini" },
  { "RAYCAST a d f g h",        "Raycast AI · file search · emoji · Spotify search · YouTube search" },
  { "RAYCAST p j k m",          "Screenshot · AirDrop · Mute mic · Next meeting" },
  { "RAYCAST z x c",            "Audio MIDI · Wi-Fi · Bluetooth" },
  { "RAYCAST , . /",            "dots-sync · theme · restart SketchyBar" },

  -- Hammerspoon hotkeys
  { "CMD + ALT + SPACE",        "Omarchy menu" },
  { "CMD + SHIFT + SPACE",      "App launcher" },
  { "CMD + CTRL + SHIFT + SPACE","Theme chooser" },
  { "CMD + CTRL + P",           "Next wallpaper for this theme" },
  { "CMD + CTRL + R",           "Set a reminder (e.g. 20m stand up)" },
  { "CMD + CTRL + ALT + T / W / B", "Notice: time / weather / battery" },
  { "CMD + CTRL + G",           "Gaming mode" },
  { "CMD + CTRL + SHIFT + Q",   "Quit all apps" },
  { "ALT + K",                  "Show this keybindings overlay" },
}

----------------------------------------------------------------------
-- Tokyo Night palette
----------------------------------------------------------------------
local function hex(s)
  return { hex = s }
end

local COLORS = {
  bg       = hex("#1a1b26"),
  fg       = hex("#c0caf5"),
  blue     = hex("#7aa2f7"),
  magenta  = hex("#bb9af7"),
  comment  = hex("#565f89"),
}

----------------------------------------------------------------------
-- Build chooser
----------------------------------------------------------------------
local function showKeybindings()
  local choices = {}
  for _, b in ipairs(bindings) do
    table.insert(choices, {
      text    = b[1],
      subText = b[2],
    })
  end

  local chooser = hs.chooser.new(function(_) end)
  chooser:choices(choices)
  chooser:searchSubText(true)
  chooser:width(35)
  chooser:rows(12)
  chooser:bgDark(true)
  chooser:fgColor(COLORS.blue)
  chooser:subTextColor(COLORS.fg)
  chooser:placeholderText("Filter keybindings…")
  chooser:show()
end

----------------------------------------------------------------------
-- Auto-extend: force every display to extended (never mirrored) the
-- moment the screen setup changes. Some external monitors (a Dell at
-- work) come up mirrored on connect; this overrides that immediately.
----------------------------------------------------------------------
autoExtendWatcher = hs.screen.watcher.new(function()
  for _, screen in ipairs(hs.screen.allScreens()) do
    screen:setMirrorOfScreen(nil)
  end
end):start()

----------------------------------------------------------------------
-- Layer cheat sheet: hold a kanata layer key for 2s -> popup of its keys.
--
-- Kanata's layer holds also emit real modifiers (aliases-shared.kbd), so
-- the layer is detected from the exact modifier set that stays held:
--   tab = shift+cmd, caps = alt+ctrl+shift, LGUI = ctrl+cmd+shift,
--   RGUI = hyper (alt+ctrl+cmd+shift). Any real keypress or modifier
-- change cancels/hides it. Key lists are hand-copied from
-- ~/.config/kanata/kanata.kbd (physical QWERTY positions) — update both
-- when you rebind a layer.
----------------------------------------------------------------------
LAYER_CHEAT_DELAY = 2
layerCheats = {
  { flags = { shift = true, cmd = true }, text = [[
TOGGLES — hold tab   (physical keys)
y Screensaver  u Printers  i Zoom  o Calculator  p AirDrop
h Wi-Fi  j Bluetooth  k Lock  l DND  ; Mute mic  ' Caffeinate
n Sleep  m Restart  , Shut Down  . Log Out  / System Info]] },
  { flags = { alt = true, ctrl = true, shift = true }, text = [[
APPS — hold caps   (physical keys)
y Spotify  u Passwords  i Calendar  o Preview  p DaVinci
h Comet  j Claude  k Obsidian  l Notes  ; Messages  ' Settings  ret kitty
n Finder  m Grok  , WhatsApp  . Clipboard  / Affinity]] },
  { flags = { ctrl = true, cmd = true, shift = true }, text = [[
YABAI — hold left ⌘   (physical keys)
1/2/3 thirds  q/w/e top sixths  a/s/d bottom sixths
r cycle top  f cycle bottom  v cycle thirds
t/y prev/next display  j left  p right  m fill
i top-left  o top-right  , bottom-left  . bottom-right]] },
  { flags = { alt = true, ctrl = true, cmd = true, shift = true }, text = [[
GOTO — hold right ⌘   (physical keys)
h nvim ~/.config  j nvim repos  k nvim Documents  l nvim notes
y Obsidian ~/.config  u Obsidian repos  i Obsidian Documents  o Obsidian notes]] },
}

local function flagsMatch(f, want)
  for _, m in ipairs({ "cmd", "alt", "ctrl", "shift" }) do
    if (f[m] == true) ~= (want[m] == true) then return false end
  end
  return true
end

layerCheatTimer, layerCheatAlert = nil, nil
function hideLayerCheat()
  if layerCheatTimer then layerCheatTimer:stop(); layerCheatTimer = nil end
  if layerCheatAlert then hs.alert.closeSpecific(layerCheatAlert, 0.1); layerCheatAlert = nil end
end

function layerCheatOnFlags(f)
  hideLayerCheat()
  for _, c in ipairs(layerCheats) do
    if flagsMatch(f, c.flags) then
      layerCheatTimer = hs.timer.doAfter(LAYER_CHEAT_DELAY, function()
        layerCheatAlert = hs.alert.show(c.text, {
          textFont = "Menlo", textSize = 15, radius = 12, atScreenEdge = 0,
          fillColor = { white = 0.08, alpha = 0.94 },
          strokeColor = { white = 1, alpha = 0.25 },
          textColor = { white = 1, alpha = 1 },
        }, hs.screen.mainScreen(), 3600)
      end)
      return
    end
  end
end

layerCheatTap = hs.eventtap.new(
  { hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown },
  function(e)
    if e:getType() == hs.eventtap.event.types.keyDown then
      hideLayerCheat()
    else
      local f = e:getFlags()
      local t = {}
      for _, m in ipairs({ "cmd", "alt", "ctrl", "shift", "fn" }) do if f[m] then t[#t + 1] = m end end
      layerCheatLastSeen = os.date("%H:%M:%S") .. " flags=" .. table.concat(t, "+")
      layerCheatOnFlags(f)
    end
    return false
  end
):start()

----------------------------------------------------------------------
-- Hotkeys
----------------------------------------------------------------------
hs.hotkey.bind({"alt"}, "k", showKeybindings)

-- Run a shell script that prints "TITLE|||BODY" and show as notification
local function notifyFromScript(script)
  hs.task.new("/bin/bash", function(_, stdOut, _)
    local title, body = stdOut:match("^(.-)|||(.-)\n?$")
    if title then
      hs.notify.new({ title = title, informativeText = body, withdrawAfter = 5 }):send()
    end
  end, { "-lc", script }):start()
end

hs.hotkey.bind({"cmd", "ctrl", "alt"}, "t", function() notifyFromScript("~/.local/bin/omarchy-notice time")    end)
hs.hotkey.bind({"cmd", "ctrl", "alt"}, "w", function() notifyFromScript("~/.local/bin/omarchy-notice weather") end)
hs.hotkey.bind({"cmd", "ctrl", "alt"}, "b", function() notifyFromScript("~/.local/bin/omarchy-notice battery") end)
hs.hotkey.bind({"cmd", "ctrl"},        "p", function() notifyFromScript("~/.local/bin/omarchy-cycle-wallpaper") end)
hs.hotkey.bind({"cmd", "ctrl"},        "g", function() notifyFromScript("~/.local/bin/gaming-mode") end)
hs.hotkey.bind({"cmd", "ctrl", "shift"}, "q", function()
  hs.alert.show("Quitting all apps")
  hs.task.new("/bin/bash", nil, { "-lc", "~/.local/bin/quit-all" }):start()
end)

-- Reminder (v4: Super+Ctrl+R): "20m stand up", "1h30 call back", "45s tea".
-- A notification fires when the time is up. Timers live for this session.
local reminders = {}
local function setReminder()
  local button, text = hs.dialog.textPrompt("Reminder", "Delay then message, e.g. 20m stand up", "", "Set", "Cancel")
  if button ~= "Set" or text == "" then return end
  local delay, message = text:match("^%s*([%dhms%. ]+)%s+(.+)$")
  if not delay then hs.alert.show("Format: 20m message"); return end
  local seconds = 0
  for n, unit in delay:gmatch("([%d%.]+)%s*([hms]?)") do
    local v = tonumber(n) or 0
    seconds = seconds + (unit == "h" and v * 3600 or unit == "s" and v or v * 60)
  end
  if seconds <= 0 then hs.alert.show("Format: 20m message"); return end
  table.insert(reminders, hs.timer.doAfter(seconds, function()
    hs.notify.new({ title = "Reminder", informativeText = message, withdrawAfter = 0 }):send()
    hs.sound.getByName("Glass"):play()
  end))
  hs.alert.show("Reminder in " .. delay:gsub("^%s+", ""):gsub("%s+$", "") .. ": " .. message)
end
hs.hotkey.bind({"cmd", "ctrl"}, "r", setReminder)

----------------------------------------------------------------------
-- Screensaver (v4: ttfx ASCII art after 150 s idle, in a fullscreen
-- terminal per monitor). The scripts do the launching; this is the idle
-- clock and the "any input ends it" part that Hyprland gives Omarchy.
----------------------------------------------------------------------
local SCREENSAVER_IDLE = 150 -- seconds, Omarchy's shell.json idle.screensaver
local screensaverTap = nil
local screensaverRunning = false

local function stopScreensaver()
  if screensaverTap then screensaverTap:stop(); screensaverTap = nil end
  if not screensaverRunning then return end
  screensaverRunning = false
  hs.execute("pkill -f '[o]marchy-screensaver$'; pkill -x ttfx", true)
end

local function startScreensaver(force)
  if screensaverRunning then return end
  local ok = os.execute("~/.local/bin/omarchy-launch-screensaver " .. (force and "force" or ""))
  if not ok then return end
  screensaverRunning = true
  -- Arm after a beat so the launch itself does not end it.
  hs.timer.doAfter(1.5, function()
    if not screensaverRunning then return end
    screensaverTap = hs.eventtap.new({
      hs.eventtap.event.types.keyDown, hs.eventtap.event.types.mouseMoved,
      hs.eventtap.event.types.leftMouseDown, hs.eventtap.event.types.rightMouseDown,
      hs.eventtap.event.types.scrollWheel,
    }, function() stopScreensaver(); return false end)
    screensaverTap:start()
  end)
end
launchScreensaver = startScreensaver -- reachable from `hs -c` and the menu

hs.timer.doEvery(15, function()
  if screensaverRunning then
    -- Ended from inside the terminal (a key) without us noticing.
    if hs.execute("pgrep -f '[o]marchy-screensaver$'", true) == "" then stopScreensaver() end
    return
  end
  if hs.host.idleTime() >= SCREENSAVER_IDLE then startScreensaver(false) end
end)

----------------------------------------------------------------------
-- Forward declarations so mutually-referenced choosers can find each other
----------------------------------------------------------------------
local showAppsMenu, showThemeChooser, showOmarchyMenu

----------------------------------------------------------------------
-- Omarchy menu (SUPER+ALT+SPACE) — the v4 (Quattro) tree, nested search
----------------------------------------------------------------------
-- Mirrors omacom/omarchy default/omarchy/omarchy-menu.jsonc, keeping only
-- entries that do something on macOS. An entry is a leaf { text, sub,
-- action } or a branch { text, sub, children }. Empty query shows the
-- current level; typing searches every leaf below it (v4's nested search),
-- with the path as the subtitle. "‹ Back" climbs one level.

local function sh(cmd) return function() hs.execute(cmd, true) end end
local function app(name) return function() hs.application.launchOrFocus(name) end end
local function url(u) return sh("open '" .. u .. "'") end
local function settings(pane) return sh([[open "x-apple.systempreferences:]] .. pane .. [["]]) end
local function ghostty(cmd) return sh([[open -na Ghostty --args -e "$HOME/.local/bin/omarchy-tui" sh -c ']] .. cmd .. [[']]) end
local function nvimEdit(path) return sh([[open -na Ghostty --args -e nvim "]] .. path .. [["]]) end
local function keystroke(code, mods)
  return sh([[osascript -e 'tell application "System Events" to key code ]] .. code .. [[ using {]] .. mods .. [[}']])
end
local function toast(scriptName) return function() notifyFromScript("~/.local/bin/" .. scriptName) end end
-- The repo this init.lua lives in (dotfiles here, omarchy4mac for adopters):
-- resolve the symlink ~/.hammerspoon/init.lua and go two directories up.
local D = (function()
  local target = hs.execute("readlink " .. os.getenv("HOME") .. "/.hammerspoon/init.lua"):gsub("%s+$", "")
  if target == "" then target = os.getenv("HOME") .. "/.hammerspoon/init.lua" end
  return target:match("^(.*)/hammerspoon/[^/]+$") or (os.getenv("HOME") .. "/code/omarchy4mac")
end)()
-- Shell file: dotfiles keeps the whole zshrc; the public repo ships only the Omarchy block.
local ZSH = hs.fs.attributes(D .. "/zsh/omarchy.zsh") and (D .. "/zsh/omarchy.zsh") or (D .. "/zsh/zshrc")

local MENU = {
  { text = "Apps", sub = "Launch an app", action = function() showAppsMenu() end },
  { text = "Learn", sub = "Manuals and cheat sheets", children = {
    { text = "Keybindings", sub = "This desktop (alt-k)", action = function() showKeybindings() end },
    { text = "Omarchy manual", sub = "omarchy.org/manual", action = url("https://omarchy.org/manual/") },
    { text = "Omarchy hotkeys", sub = "The upstream table", action = url("https://omarchy.org/manual/hotkeys/") },
    { text = "yabai wiki", sub = "Window manager docs", action = url("https://github.com/asmvik/yabai/wiki") },
    { text = "Neovim", sub = "LazyVim keymaps", action = url("https://www.lazyvim.org/keymaps") },
    { text = "Tmux", sub = "Cheat sheet", action = url("https://tmuxcheatsheet.com") },
    { text = "Herdr", sub = "Keybindings", action = url("https://herdr.dev/docs/") },
  }},
  { text = "Trigger", sub = "Do a thing now", children = {
    { text = "Emoji", sub = "Raycast emoji picker", action = url("raycast://extensions/raycast/emoji-symbols/search-emoji-symbols") },
    { text = "Capture", sub = "Screenshot / record / colour", children = {
      { text = "Screenshot", sub = "macOS capture picker", action = keystroke(23, "command down, shift down") },
      { text = "Screenrecord", sub = "Same picker, choose Record", action = keystroke(23, "command down, shift down") },
      { text = "Color", sub = "Digital Color Meter", action = app("Digital Color Meter") },
    }},
    { text = "Share", sub = "LocalSend", children = {
      { text = "Send", sub = "Open LocalSend", action = app("LocalSend") },
      { text = "Receive", sub = "Open LocalSend", action = app("LocalSend") },
    }},
    { text = "Toggle", sub = "Switch something on or off", children = {
      { text = "Stay Awake", sub = "caffeinate on/off", action = sh([[pgrep -x caffeinate >/dev/null && pkill -x caffeinate || (caffeinate -dimsu &)]]) },
      { text = "Notifications", sub = "Do Not Disturb", action = sh([[shortcuts run "Toggle Do Not Disturb"]]) },
      { text = "Menu Bar", sub = "Hide or show SketchyBar", action = sh("/opt/homebrew/bin/sketchybar --bar hidden=toggle") },
      { text = "Gaming Mode", sub = "Quit apps, Tailscale down, Steam", action = toast("gaming-mode") },
      { text = "Quit All", sub = "Quit every Dock app, keep Finder", action = sh("~/.local/bin/quit-all") },
      { text = "Screensaver", sub = "Enable or disable the idle screensaver", action = toast("omarchy-toggle-screensaver") },
    }},
    { text = "Transcode", sub = "HandBrake", action = app("HandBrake") },
    { text = "Speed Test", sub = "Network (Cloudflare)", action = url("https://speed.cloudflare.com") },
    { text = "Reminder", sub = "20m message", action = function() setReminder() end },
    { text = "Notice", sub = "Time / weather / battery toast", children = {
      { text = "Time", sub = "Date and time", action = toast("omarchy-notice time") },
      { text = "Weather", sub = "wttr.in", action = toast("omarchy-notice weather") },
      { text = "Battery", sub = "Charge and source", action = toast("omarchy-notice battery") },
    }},
  }},
  { text = "Style", sub = "Theme, background, look", children = {
    { text = "Theme", sub = "Pick a theme", action = function() showThemeChooser() end },
    { text = "Theme random", sub = "Shuffle within light/dark", action = sh("~/.local/bin/theme random") },
    { text = "Background", sub = "Next wallpaper for this theme", action = toast("omarchy-cycle-wallpaper") },
    { text = "Screensaver text", sub = "Edit the ASCII art", action = nvimEdit(os.getenv("HOME") .. "/.config/omarchy/branding/screensaver.txt") },
    { text = "Sync themes", sub = "Pull Omarchy 4 themes", action = ghostty("~/.local/bin/theme --sync") },
    { text = "Appearance", sub = "macOS light / dark", action = settings("com.apple.Appearance-Settings.extension") },
  }},
  { text = "Setup", sub = "Configure the desktop", children = {
    { text = "Monitors", sub = "Displays", action = settings("com.apple.Displays-Settings.extension") },
    { text = "Keybindings", sub = "Edit kanata.kbd", action = nvimEdit(D .. "/kanata/kanata.kbd") },
    { text = "Input", sub = "Keyboard", action = settings("com.apple.Keyboard-Settings.extension") },
    { text = "Network", sub = "Wi-Fi", action = settings("com.apple.wifi-settings-extension") },
    { text = "Bluetooth", sub = "Devices", action = settings("com.apple.BluetoothSettings") },
    { text = "Audio", sub = "Sound", action = settings("com.apple.Sound-Settings.extension") },
    { text = "Security", sub = "Privacy & Security", action = settings("com.apple.settings.PrivacySecurity.extension") },
    { text = "Sharing", sub = "Sharing settings", action = settings("com.apple.preferences.sharing") },
    { text = "Config", sub = "Edit a config file", children = {
      { text = "Kanata", sub = "kanata.kbd", action = nvimEdit(D .. "/kanata/kanata.kbd") },
      { text = "yabai", sub = "yabairc", action = nvimEdit(D .. "/yabai/yabairc") },
      { text = "SketchyBar", sub = "sketchybarrc", action = nvimEdit(D .. "/sketchybar/sketchybarrc") },
      { text = "Hammerspoon", sub = "init.lua", action = nvimEdit(D .. "/hammerspoon/init.lua") },
      { text = "Ghostty", sub = "Application Support config", action = nvimEdit(os.getenv("HOME") .. "/Library/Application Support/com.mitchellh.ghostty/config") },
      { text = "Zsh", sub = "shell defaults", action = nvimEdit(ZSH) },
      { text = "Starship", sub = "starship.toml", action = nvimEdit(D .. "/starship.toml") },
    }},
  }},
  { text = "Install", sub = "Add software", children = {
    { text = "Package", sub = "brew search in Ghostty", action = ghostty("read -p \"brew search: \" q && brew search \"$q\"") },
    { text = "Homebrew", sub = "brew.sh", action = url("https://brew.sh") },
    { text = "Omarchy themes", sub = "Community themes", action = url("https://omarchy.org/themes/") },
  }},
  { text = "Remove", sub = "Remove software", children = {
    { text = "Package", sub = "brew uninstall in Ghostty", action = ghostty("brew list --cask; brew list --formula | column; read -p \"brew uninstall: \" q && brew uninstall \"$q\"") },
  }},
  { text = "Update", sub = "Update software and configs", children = {
    { text = "Homebrew", sub = "brew update && upgrade", action = ghostty("brew update && brew upgrade") },
    { text = "macOS", sub = "Software Update", action = settings("com.apple.Software-Update-Settings.extension") },
    { text = "Themes", sub = "theme --sync", action = ghostty("~/.local/bin/theme --sync") },
    { text = "Config", sub = "Reload a service", children = {
      { text = "yabai", sub = "restart service", action = sh(os.getenv("HOME") .. "/.config/rx/yabai-restart.sh") },
      { text = "SketchyBar", sub = "--reload", action = sh("/opt/homebrew/bin/sketchybar --reload") },
      { text = "Hammerspoon", sub = "hs.reload()", action = function() hs.reload() end },
      { text = "Borders", sub = "brew services restart", action = sh("/opt/homebrew/bin/brew services restart borders") },
    }},
  }},
  { text = "About", sub = "fastfetch", action = ghostty("fastfetch") },
  { text = "System", sub = "Lock, sleep, restart, shut down", children = {
    { text = "Screensaver", sub = "Start it now", action = function() launchScreensaver(true) end },
    { text = "Lock", sub = "Lock screen", action = keystroke(12, "control down, command down") },
    { text = "Sleep", sub = "pmset sleepnow", action = sh("pmset sleepnow") },
    { text = "Restart", sub = "Restart the Mac", action = sh([[osascript -e 'tell application "System Events" to restart']]) },
    { text = "Shut Down", sub = "Shut down the Mac", action = sh([[osascript -e 'tell application "System Events" to shut down']]) },
    { text = "Log Out", sub = "Log out", action = sh([[osascript -e 'tell application "System Events" to log out']]) },
  }},
}

-- hs.chooser choices must be plain data (no functions, no nested tables),
-- so rows carry indices into these side tables.
local function flatten(items, path, out)
  for _, item in ipairs(items) do
    local here = path and (path .. " › " .. item.text) or item.text
    if item.children then flatten(item.children, here, out)
    else table.insert(out, { text = item.text, path = here, action = item.action }) end
  end
  return out
end

local menuChooser
local function showMenuLevel(items, parents)
  parents = parents or {}
  local level = {}
  if #parents > 0 then table.insert(level, { text = "‹ Back", subText = parents[#parents].text, back = true }) end
  for i, item in ipairs(items) do
    table.insert(level, { text = item.text, subText = item.sub or "", idx = i })
  end
  local leaves = flatten(items, nil, {})
  local leafRows = {}
  for i, leaf in ipairs(leaves) do leafRows[i] = { text = leaf.text, subText = leaf.path, leaf = i } end

  menuChooser = hs.chooser.new(function(choice)
    if not choice then return end
    if choice.back then
      local up = {}
      for i = 1, #parents - 1 do up[i] = parents[i] end
      local parentItems = (#parents > 1) and parents[#parents - 1].item.children or MENU
      return showMenuLevel(parentItems, up)
    end
    if choice.leaf then return leaves[choice.leaf].action() end
    local item = items[choice.idx]
    if item.children then
      local down = {}
      for i, p in ipairs(parents) do down[i] = p end
      table.insert(down, { text = item.text, item = item })
      return showMenuLevel(item.children, down)
    end
    if item.action then item.action() end
  end)
  menuChooser:queryChangedCallback(function(query)
    if query == "" then menuChooser:choices(level); return end
    local q = query:lower()
    local hits = {}
    for _, row in ipairs(leafRows) do
      if (row.text .. " " .. row.subText):lower():find(q, 1, true) then table.insert(hits, row) end
    end
    menuChooser:choices(hits)
  end)
  menuChooser:choices(level)
  menuChooser:width(28)
  menuChooser:rows(12)
  menuChooser:bgDark(true)
  menuChooser:fgColor(COLORS.blue)
  menuChooser:subTextColor(COLORS.fg)
  local crumbs = ""
  for _, p in ipairs(parents) do crumbs = crumbs .. p.text .. " › " end
  menuChooser:placeholderText(crumbs == "" and "Omarchy…" or crumbs)
  menuChooser:show()
end

showOmarchyMenu = function(section)
  if section then
    for _, item in ipairs(MENU) do
      if item.text == section and item.children then
        return showMenuLevel(item.children, { { text = item.text, item = item } })
      end
    end
  end
  showMenuLevel(MENU)
end
-- `hs -c 'omarchyMenu("System")'` opens a section.
omarchyMenu = showOmarchyMenu

hs.hotkey.bind({"cmd", "alt"}, "space", function() showOmarchyMenu() end)

----------------------------------------------------------------------
-- Theme chooser (SUPER+CTRL+SHIFT+SPACE)
----------------------------------------------------------------------
showThemeChooser = function()
  local cache = os.getenv("HOME") .. "/.config/theme-switcher/cache"
  local themes = {}
  local handle = io.popen("ls -1 " .. cache .. " 2>/dev/null | sort")
  if handle then
    for line in handle:lines() do table.insert(themes, line) end
    handle:close()
  end
  if #themes == 0 then
    hs.notify.new({title="Theme", informativeText="No themes cached. Run: theme --sync", withdrawAfter=5}):send()
    return
  end

  local current = ""
  local f = io.open(os.getenv("HOME") .. "/.config/theme-switcher/current", "r")
  if f then current = f:read("*line") or ""; f:close() end

  local choices = {}
  for _, name in ipairs(themes) do
    table.insert(choices, {
      text = name,
      subText = (name == current) and "● current" or "",
      themeName = name,
    })
  end

  local chooser = hs.chooser.new(function(choice)
    if choice then
      hs.task.new("/bin/bash", function()
        hs.notify.new({title="Theme", informativeText="Switched to " .. choice.themeName, withdrawAfter=3}):send()
      end, { "-lc", "~/.local/bin/theme " .. choice.themeName }):start()
    end
  end)
  chooser:choices(choices)
  chooser:width(20)
  chooser:rows(10)
  chooser:bgDark(true)
  chooser:fgColor(COLORS.blue)
  chooser:subTextColor(COLORS.fg)
  chooser:placeholderText("Pick a theme…")
  chooser:show()
end

hs.hotkey.bind({"cmd", "ctrl", "shift"}, "space", showThemeChooser)
hs.hotkey.bind({"cmd", "shift"}, "space", function() showAppsMenu() end)

----------------------------------------------------------------------
-- Apps chooser — curated launcher (called from Omarchy menu's "Apps")
----------------------------------------------------------------------
local apps = {
  { name = "1Password",        sub = "Passwords",         action = function() hs.application.launchOrFocus("1Password") end },
  { name = "Basecamp",         sub = "Web",               action = function() hs.execute("open https://3.basecamp.com") end },
  { name = "Bluetooth",        sub = "Settings",          action = function() hs.execute([[open "x-apple.systempreferences:com.apple.BluetoothSettings"]]) end },
  { name = "Brave",            sub = "Browser",           action = function() hs.application.launchOrFocus("Brave Browser") end },
  { name = "Calculator",       sub = "Math",              action = function() hs.application.launchOrFocus("Calculator") end },
  { name = "Chrome",           sub = "Browser",           action = function() hs.application.launchOrFocus("Google Chrome") end },
  { name = "Claude",           sub = "AI",                action = function() hs.application.launchOrFocus("Claude") end },
  { name = "Discord",          sub = "Comms",             action = function() hs.application.launchOrFocus("Discord") end },
  { name = "Docker",           sub = "Containers",        action = function() hs.application.launchOrFocus("Docker") end },
  { name = "Figma",            sub = "Web · figma.com",   action = function() hs.execute("open https://figma.com") end },
  { name = "Finder",           sub = "Files",             action = function() hs.application.launchOrFocus("Finder") end },
  { name = "Ghostty",          sub = "Terminal",          action = function() hs.execute("open -na Ghostty") end },
  { name = "Ghostty + nvim",   sub = "Editor",            action = function() hs.execute("open -na Ghostty --args -e nvim") end },
  { name = "GitHub",           sub = "Web · github.com",  action = function() hs.execute("open https://github.com") end },
  { name = "Google Contacts",  sub = "Web",               action = function() hs.execute("open https://contacts.google.com") end },
  { name = "Google Messages",  sub = "Brave web app",     action = function() hs.application.launchOrFocusByBundleID("com.brave.Browser.app.hpfldicfbfomlpcikngkocigghgafkph") end },
  { name = "Google Photos",    sub = "Web",               action = function() hs.execute("open https://photos.google.com") end },
  { name = "HEY (mail)",       sub = "Web",               action = function() hs.execute("open https://app.hey.com") end },
  { name = "HEY Calendar",     sub = "Web",               action = function() hs.execute("open https://app.hey.com/calendar") end },
  { name = "Lazygit",          sub = "Ghostty + lazygit", action = function() hs.execute("open -na Ghostty --args -e lazygit") end },
  { name = "LocalSend",        sub = "Cross-device file share", action = function() hs.application.launchOrFocus("LocalSend") end },
  { name = "mpv",              sub = "Media player",      action = function() hs.application.launchOrFocus("mpv") end },
  { name = "OBS Studio",       sub = "brew install --cask obs", action = function() hs.application.launchOrFocus("OBS") end },
  { name = "Obsidian",         sub = "Notes",             action = function() hs.application.launchOrFocus("Obsidian") end },
  { name = "Pinta",            sub = "Image editor",      action = function() hs.application.launchOrFocus("Pinta") end },
  { name = "Signal",           sub = "Comms",             action = function() hs.application.launchOrFocus("Signal") end },
  { name = "Slack",            sub = "Comms",             action = function() hs.application.launchOrFocus("Slack") end },
  { name = "Spotify",          sub = "Music",             action = function() hs.application.launchOrFocus("Spotify") end },
  { name = "System Settings",  sub = "macOS preferences", action = function() hs.application.launchOrFocus("System Settings") end },
  { name = "Typora",           sub = "Markdown",          action = function() hs.application.launchOrFocus("Typora") end },
  { name = "WhatsApp",         sub = "Comms",             action = function() hs.application.launchOrFocus("WhatsApp") end },
  { name = "X (Twitter)",      sub = "Brave web app",     action = function() hs.application.launchOrFocusByBundleID("com.brave.Browser.app.lodlkdfmihgonocnmddehnfgiljnadcf") end },
  { name = "YouTube",          sub = "Brave web app",     action = function() hs.application.launchOrFocusByBundleID("com.brave.Browser.app.agimnkijcaahngcdmfeangaknmldooml") end },
}

showAppsMenu = function()
  local choices = {}
  for i, app in ipairs(apps) do
    table.insert(choices, { text = app.name, subText = app.sub, idx = i })
  end
  local chooser = hs.chooser.new(function(choice)
    if choice and apps[choice.idx] then apps[choice.idx].action() end
  end)
  chooser:choices(choices)
  chooser:width(25)
  chooser:rows(12)
  chooser:bgDark(true)
  chooser:fgColor(COLORS.blue)
  chooser:subTextColor(COLORS.fg)
  chooser:placeholderText("Launch…")
  chooser:show()
end

-- Let scripts reload us: osascript -e 'tell application "Hammerspoon" to execute lua code "hs.reload()"'
hs.allowAppleScript(true)

-- Tell us the config reloaded
hs.alert.show("Hammerspoon: keybindings ready (⌥K)")

-- Ghostty live reload. `theme` rewrites the Ghostty config, but Ghostty has no
-- reload signal and the theme-appearance listener (launchd) has no
-- Accessibility permission, so its AppleScript reload fails and open windows
-- keep the old colors. Hammerspoon has the permission: watch the config and
-- click Ghostty > Reload Configuration whenever it changes.
local ghosttyConfigs = {
  os.getenv("HOME") .. "/Library/Application Support/com.mitchellh.ghostty",
  os.getenv("HOME") .. "/.config/ghostty",
}
local ghosttyReloadTimer
local function reloadGhostty()
  local app = hs.application.find("com.mitchellh.ghostty")
  if not app then return end
  if not app:selectMenuItem({ "Ghostty", "Reload Configuration" }) then
    hs.eventtap.keyStroke({ "cmd", "shift" }, ",", 0, app)
  end
end
GhosttyWatchers = {}
for _, dir in ipairs(ghosttyConfigs) do
  GhosttyWatchers[#GhosttyWatchers + 1] = hs.pathwatcher.new(dir, function(paths)
    for _, p in ipairs(paths) do
      if p:match("/config$") then
        -- debounce: `theme` writes both configs within the same second
        if ghosttyReloadTimer then ghosttyReloadTimer:stop() end
        ghosttyReloadTimer = hs.timer.doAfter(0.5, reloadGhostty)
        return
      end
    end
  end):start()
end
