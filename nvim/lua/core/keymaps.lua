-- ~/.config/nvim/lua/core/keymaps.lua
-- Defines direct, single-press, non-popup keymaps.

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Custom mappings
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })
map("n", "S", ":%s//g<Left><Left>", { silent = false, desc = "Search and Replace" })

-- Use '.' to enter command mode instantly
map("n", ".", ":", { silent = false })
map("n", ":", ".", { silent = false })

-- Redo
map("n", "U", "<cmd>redo<cr>", { desc = "Redo" })

-- Movement shortcuts
map({ "n", "v", "x" }, "<S-l>", "$", { desc = "Go to Line End" })
map({ "n", "v", "x" }, "<S-h>", "^", { desc = "Go to Line Start" })

-- LSP & Diagnostics (Direct, non-leader mappings)
map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

-- Gitsigns (Direct, non-leader mappings)
map("n", "]c",
  function()
    if vim.wo.diff then return "]c" end; vim.schedule(function() require("gitsigns").next_hunk() end); return "<Ignore>"
  end, { expr = true, desc = "Next Hunk" })
map("n", "[c",
  function()
    if vim.wo.diff then return "[c" end; vim.schedule(function() require("gitsigns").prev_hunk() end); return "<Ignore>"
  end, { expr = true, desc = "Previous Hunk" })
