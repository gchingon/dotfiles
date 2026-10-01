-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("cache") .. "/undo"

opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Kanata/KMonad keyboard config files -> lisp syntax
vim.filetype.add({
  extension = {
    kbd = "lisp",
  },
})
