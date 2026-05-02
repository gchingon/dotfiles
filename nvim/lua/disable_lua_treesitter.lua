-- Disable treesitter for Lua before anything loads
-- This prevents the query error in Neovim 0.12.2

-- Intercept the treesitter.start function to skip Lua
local orig_start = vim.treesitter.start
vim.treesitter.start = function(bufnr, lang, ...)
  if lang == "lua" then
    return nil  -- Skip treesitter for Lua
  end
  return orig_start(bufnr, lang, ...)
end
