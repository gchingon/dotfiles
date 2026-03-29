-- ~/.config/nvim/lua/core/options.lua
-- Sets Neovim's fundamental editor options.

local opt = vim.opt

-- -----------------------------------------------------------------------------
-- Behavior & Editor Functionality
-- -----------------------------------------------------------------------------
opt.mouse = "a"             -- Enable mouse support in all modes
opt.clipboard = "unnamedplus" -- Use system clipboard for all operations
opt.swapfile = false        -- Disable the swap file
opt.undofile = true         -- Enable persistent undo
opt.undodir = vim.fn.stdpath("cache") .. "/undo" -- Set undo directory

-- -----------------------------------------------------------------------------
-- Search
-- -----------------------------------------------------------------------------
opt.hlsearch = true         -- Highlight search results
opt.incsearch = true        -- Show search results as you type
opt.ignorecase = true       -- Ignore case when searching
opt.smartcase = true        -- ...unless the query contains uppercase letters

-- -----------------------------------------------------------------------------
-- UI & Appearance
-- -----------------------------------------------------------------------------
opt.termguicolors = true    -- Enable 24-bit RGB color
opt.number = true           -- Show line numbers
opt.relativenumber = true     -- Show relative line numbers
opt.signcolumn = "yes"      -- Always show the sign column
opt.scrolloff = 8           -- Keep 8 lines visible above/below the cursor
opt.sidescrolloff = 8       -- Keep 8 columns visible left/right of the cursor
opt.cursorline = true       -- Highlight the current line

-- -----------------------------------------------------------------------------
-- Formatting & Whitespace
-- -----------------------------------------------------------------------------
opt.expandtab = true        -- Use spaces instead of tabs
opt.shiftwidth = 2          -- Number of spaces to use for each step of (auto)indent
opt.softtabstop = 2         -- Number of spaces a <Tab> counts for
opt.tabstop = 2             -- Number of spaces a tab character is displayed as
opt.wrap = false            -- Do not wrap lines

-- -----------------------------------------------------------------------------
-- Performance & System
-- -----------------------------------------------------------------------------
opt.updatetime = 250        -- Time in ms to wait for trigger autocommands
opt.timeoutlen = 300        -- Time in ms to wait for a mapped sequence to complete

-- -----------------------------------------------------------------------------
-- Filetype Overrides
-- -----------------------------------------------------------------------------
vim.filetype.add({
  extension = {
    kbd = "lisp",   -- Kanata/KMonad keyboard config files → lisp syntax
  },
})
