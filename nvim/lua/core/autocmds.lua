-- ~/.config/nvim/lua/core/autocmds.lua
-- Defines autocommands for custom editor behavior.

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight text on yank
local yank_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Ensure undo directory exists
autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    local undodir = vim.fn.stdpath("cache") .. "/undo"
    if vim.fn.isdirectory(undodir) == 0 then
      vim.fn.mkdir(undodir, "p")
    end
    vim.opt.undodir = undodir
  end,
})
