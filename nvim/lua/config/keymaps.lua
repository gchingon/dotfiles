-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })
map("n", "S", ":%s//g<Left><Left>", { silent = false, desc = "Search and Replace" })

map("n", "U", "<cmd>redo<cr>", { desc = "Redo" })

-- NOTE: overrides LazyVim's default <S-h>/<S-l> (prev/next buffer) —
-- kept intentionally, this is the muscle-memory binding from the old config.
map({ "n", "v", "x" }, "<S-l>", "$", { desc = "Go to Line End" })
map({ "n", "v", "x" }, "<S-h>", "^", { desc = "Go to Line Start" })

-- NOTE: <C-k> is reserved for vim-kitty-navigator (KittyNavigateUp).
--       Signature help lives on gK (natural pair to K=hover).
map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Goto Implementation" })

map("n", "]c", function()
  if vim.wo.diff then return "]c" end
  vim.schedule(function() require("gitsigns").next_hunk() end)
  return "<Ignore>"
end, { expr = true, desc = "Next Hunk" })
map("n", "[c", function()
  if vim.wo.diff then return "[c" end
  vim.schedule(function() require("gitsigns").prev_hunk() end)
  return "<Ignore>"
end, { expr = true, desc = "Previous Hunk" })

map({ "i", "s" }, "<C-l>", function()
  local ls = require("luasnip")
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, { desc = "Cycle snippet choices" })

-- vim-kitty-navigator
vim.g.kitty_navigator_no_mappings = 1
map("n", "<C-h>", ":KittyNavigateLeft<CR>")
map("n", "<C-j>", ":KittyNavigateDown<CR>")
map("n", "<C-k>", ":KittyNavigateUp<CR>")
map("n", "<C-l>", ":KittyNavigateRight<CR>")
