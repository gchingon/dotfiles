-- diagnostic.lua
-- Place this file in ~/.config/nvim/lua/

local M = {}

function M.check_module_path()
  print('Current Lua package path:')
  print(package.path)
  
  print('\nAttempting to load a plugin module...')
  local status, module = pcall(require, 'plugins.mini')
  if status then
    print('Successfully loaded plugins.mini')
  else
    print('Failed to load plugins.mini:')
    print(module)
  end
  
  print('\nChecking if directory exists:')
  local handle = io.popen('ls -la ~/.config/nvim/lua/plugins')
  local result = handle:read('*a')
  handle:close()
  print(result)
  
  print('\nChecking Neovim runtimepath:')
  vim.cmd('echo &runtimepath')
end

return M