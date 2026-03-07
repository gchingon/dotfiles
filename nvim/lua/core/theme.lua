local function read_json(path)
  local lines = vim.fn.readfile(path)
  if not lines or #lines == 0 then return nil end
  return vim.json.decode(table.concat(lines, "\n"))
end

local function notify(msg)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.WARN)
  end)
end

local function get_nvim_theme_from_colors()
  local cf = vim.fn.expand("~/.config")
  local active = read_json(cf .. "/colors/active_theme.json")
  local colors = read_json(cf .. "/colors/colors.json")
  if not active or not active.active then return nil end
  if not colors or not colors.themes or not colors.themes[active.active] then return nil end

  local t = colors.themes[active.active]
  local nv = t.neovim or {}
  return nv.theme, nv.style, active.active
end

local function apply_theme()
  local theme, style, key = get_nvim_theme_from_colors()
  if not theme then
    notify("No active theme found (colors.json / active_theme.json)")
    return
  end

  -- If you have per-theme Lua modules, require by *theme*, not by key:
  -- local ok, mod = pcall(require, "themes." .. theme)
  -- if ok and mod.setup then mod.setup({ style = style }) end

  local ok = pcall(vim.cmd.colorscheme, theme)
  if not ok then
    notify(("Theme not installed: key=%s theme=%s"):format(key, theme))
    pcall(vim.cmd.colorscheme, "habamax")
  end
end

return { setup = apply_theme }
