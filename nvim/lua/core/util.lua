-- lua/core/util.lua
-- Shared utilities used across plugin configs and init.lua

local M = {}

--- Safe plugin loader. Calls config_func(plugin) if `name` can be required,
--- otherwise fires a WARN notification. Keeps plugin files from exploding on
--- missing deps.
function M.setup_plugin(name, config_func)
  local ok, plugin = pcall(require, name)
  if ok then
    config_func(plugin)
  else
    vim.notify("Plugin not found: " .. name, vim.log.levels.WARN)
  end
end

return M
