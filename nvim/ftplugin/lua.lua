-- Custom Lua ftplugin that skips treesitter (query error in Neovim 0.12.2)
-- Use standard syntax highlighting instead

vim.opt_local.syntax = "lua"
vim.opt_local.textwidth = 0

-- Standard Lua indentation
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.expandtab = true
vim.opt_local.softtabstop = 2
