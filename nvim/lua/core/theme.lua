-- ~/.config/nvim/lua/core/theme.lua
-- Loader that syncs Neovim to the active theme from ~/.config/colors/active_theme.json

local M = {}

local uv = vim.uv or vim.loop

local active_theme_path = vim.fn.expand("~/.config/colors/active_theme.json")
local colors_json_path = vim.fn.expand("~/.config/colors/colors.json")

-- Map slugs from colors.json to the Neovim theme module to load.
-- This is the critical link between your shell script and Neovim.
local slug_to_module = {
  ["tokyodarknite"] = "tokyonight",
  ["deepdark"]      = "onedark",
  ["eldritch"]      = "eldritch",
  ["niteblossom"]   = "nightblossom",
  ["nugotham"]      = "nugotham",
  ["nightowl"]      = "nightowl",
  ["vague"]         = "vague", -- Mapped to the vague.nvim plugin
}

-- ... (the rest of your theme file is unchanged as it is correct)
local function read_file(path)
  local fd = uv.fs_open(path, "r", 438)
  if not fd then return nil end
  local stat = uv.fs_fstat(fd)
  if not stat then uv.fs_close(fd); return nil end
  local data = uv.fs_read(fd, stat.size, 0)
  uv.fs_close(fd)
  return data
end

local function decode_json(path)
  local data = read_file(path)
  if not data then return nil end
  local ok, obj = pcall(vim.json.decode, data)
  if not ok then return nil end
  return obj
end

local function get_active_slug()
  local obj = decode_json(active_theme_path)
  if type(obj) == "table" then
    if obj.active then return obj.active end
    if obj.theme then return obj.theme end
    if obj.slug then return obj.slug end
  end
  return nil
end

local function hex_to_rgb(h)
  local r = tonumber(h:sub(2, 3), 16)
  local g = tonumber(h:sub(4, 5), 16)
  local b = tonumber(h:sub(6, 7), 16)
  return r, g, b
end
local function rgb_to_hex(r, g, b)
  return string.format("#%02x%02x%02x", r, g, b)
end
local function blend(h1, h2, alpha)
  local r1, g1, b1 = hex_to_rgb(h1)
  local r2, g2, b2 = hex_to_rgb(h2)
  local r = math.floor(r1 * (1 - alpha) + r2 * alpha + 0.5)
  local g = math.floor(g1 * (1 - alpha) + g2 * alpha + 0.5)
  local b = math.floor(b1 * (1 - alpha) + b2 * alpha + 0.5)
  return rgb_to_hex(r, g, b)
end

local function build_base_from_colors(slug)
  local all = decode_json(colors_json_path)
  if not all or not all.themes or not all.themes[slug] then
    return nil, "Theme slug not found in colors.json: " .. tostring(slug)
  end
  local t = all.themes[slug]
  local g = t.ghostty or {}
  local bg  = g.background or "#000000"
  local fg  = g.foreground or "#ffffff"
  local c = {}
  for i = 0, 15 do c[i] = g["color" .. i] or fg end

  local bg0 = bg
  local bg1 = blend(bg, fg, 0.06)
  local bg2 = blend(bg, fg, 0.10)
  local bg3 = blend(bg, fg, 0.15)
  local bg4 = blend(bg, fg, 0.20)
  local bg5 = blend(bg, fg, 0.25)

  local red, green, yellow = c[1], c[2], c[3]
  local blue, magenta, cyan = c[4], c[5], c[6]
  local gray = c[8] or c[7]

  return {
    meta = { slug = slug, module = slug_to_module[slug], name = (t.name or slug) },
    ghostty = g,
    base = {
      bg0 = bg0, bg1 = bg1, bg2 = bg2, bg3 = bg3, bg4 = bg4, bg5 = bg5,
      fg = fg, red = red, green = green, yellow = yellow, blue = blue, magenta = magenta, cyan = cyan,
      gray = gray, black = c[0], white = c[15], cursor = g.cursor or blue,
    },
    ansi = c,
    extras = t.palette or {},
  }
end

local function resolve_placeholders(tbl, base)
  local function resolve_val(v)
    if type(v) == "string" then
      local var = v:match("^%$(%w+)$")
      if var and base[var] then return base[var] end
      return v
    end
    return v
  end
  local function walk(x)
    if type(x) == "table" then
      local out = {}
      for k, v in pairs(x) do out[k] = walk(v) end
      return out
    else
      return resolve_val(x)
    end
  end
  return walk(tbl)
end

local function apply_highlight_groups(groups)
  local set = vim.api.nvim_set_hl
  for group, spec in pairs(groups) do
    if spec.link then set(0, group, { link = spec.link, default = false })
    else set(0, group, spec) end
  end
end

local function apply_theme_module(module_name, palette)
  -- For non-plugin themes
  if vim.fn.filereadable(vim.fn.expand("~/.config/nvim/lua/themes/"..module_name..".lua")) == 1 then
    local ok, mod = pcall(require, "themes." .. module_name)
    if not ok then
      vim.notify("Theme module not found: " .. tostring(module_name), vim.log.levels.ERROR)
      return
    end
    local def = mod.build(palette)
    def = resolve_placeholders(def, palette.base)
    local order = {
      "base_palette", "syntax_highlighting", "ui_elements",
      "diagnostic_colors", "plugin_specific", "treesitter_groups",
      "lsp_semantic_tokens", "markdown_groups",
    }
    for _, key in ipairs(order) do
      local section = def[key]
      if section and type(section) == "table" then apply_highlight_groups(section) end
    end
  else -- For plugin-based themes like vague.nvim
    local ok, theme_plugin = pcall(require, module_name)
    if ok and theme_plugin.setup then
      theme_plugin.setup(palette.extras or {}) -- Pass extras as config
      vim.cmd("colorscheme " .. module_name)
    else
        vim.cmd("colorscheme " .. module_name)
    end
  end
end

function M.setup()
  local slug = get_active_slug()
  if not slug then
    vim.notify("No active theme slug found in active_theme.json", vim.log.levels.WARN)
    return
  end
  local p, err = build_base_from_colors(slug)
  if not p then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end
  local module_name = p.meta.module
  if not module_name then
    vim.notify("No module mapping for slug: " .. slug, vim.log.levels.ERROR)
    return
  end

  apply_theme_module(module_name, p)
end

return M
