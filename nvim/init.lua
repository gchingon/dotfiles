-- $HOME/.config/nvim/init.lua
vim.g.mapleader = ";"

-- ============================================================================
-- Plugin Setup Utilities
-- ============================================================================

local setup_plugin = require("core.util").setup_plugin

-- ============================================================================
-- Bootstrap vim-plug
-- ============================================================================

local plug_path = vim.fn.stdpath("data") .. "/site/autoload/plug.vim"
if vim.fn.empty(vim.fn.glob(plug_path)) > 0 then
  vim.notify("Installing vim-plug, please wait...", vim.log.levels.INFO)
  vim.fn.system({
    "curl", "-fLo", plug_path, "--create-dirs",
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
  })
  vim.cmd("autocmd VimEnter * PlugInstall --sync | source $MYVIMRC")
end

-- ============================================================================
-- Plugin Declarations
-- ============================================================================

vim.cmd([[
  call plug#begin()

  " Framework & UI
  Plug 'echasnovski/mini.nvim'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'folke/which-key.nvim'
  Plug 'folke/snacks.nvim'

  " LSP & Completion
  Plug 'j-hui/fidget.nvim'
  Plug 'saghen/blink.cmp', { 'tag': 'v1.*' }
  Plug 'rafamadriz/friendly-snippets'
  Plug 'moyiz/blink-emoji.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'Kaiser-Yang/blink-cmp-dictionary'
  Plug 'L3MON4D3/LuaSnip', {'do': 'make install_jsregexp'}
  Plug 'chomosuke/typst-preview.nvim', {'tag': 'v1.*'}
  Plug 'obsidian-nvim/obsidian.nvim'

  " Treesitter
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/nvim-treesitter-textobjects'
  Plug 'windwp/nvim-ts-autotag'
  Plug 'LhKipp/tree-sitter-nu'

  " Tools
  Plug 'ibhagwan/fzf-lua'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'mfussenegger/nvim-lint'
  Plug 'OXY2DEV/markview.nvim'
  Plug 'folke/flash.nvim'
  Plug 'knubie/vim-kitty-navigator'

  " Claude Code
  Plug 'coder/claudecode.nvim'

  call plug#end()
]])

-- ============================================================================
-- Load Core Config
-- ============================================================================

require("core.options")
require("core.autocmds")
require("core.keymaps")
require("core.checkbox-cycle").setup()
require("core.frontmatter").setup()

-- ============================================================================
-- Snacks (must be set up early so notifier replaces vim.notify ASAP)
-- ============================================================================

setup_plugin("snacks", function(snacks)
  snacks.setup({
    notifier = {
      enabled = true,
      timeout = 3000,
      style = "fancy",
    },
    terminal = {
      enabled = true,
    },
    -- everything else off
    bigfile    = { enabled = false },
    dashboard  = { enabled = false },
    indent     = { enabled = false },
    input      = { enabled = false },
    picker     = { enabled = false },
    quickfile  = { enabled = false },
    scroll     = { enabled = false },
    statuscolumn = { enabled = false },
    words      = { enabled = false },
  })

  -- snacks.setup() with notifier.enabled = true already replaces vim.notify
  -- internally with Snacks.notifier.notify — the proper backend that accepts
  -- the standard 3-arg (msg, level, opts) calling convention.
  --
  -- DO NOT set vim.notify = snacks.notify here. snacks.notify (M.notify) is
  -- a convenience wrapper whose signature is (msg, opts). It calls
  --   vim.notify(msg, opts.level, opts)     -- 3-arg form
  -- If vim.notify IS snacks.notify, that recursive call passes opts.level
  -- (a number) as the second arg → snacks.notify receives opts=number →
  -- crashes at line 19 trying to index opts.once on a number value.
  --
  -- snacks.setup() has already done the right thing. Leave vim.notify alone.
end)

-- ============================================================================
-- Other Plugin Setup (non-modular)
-- ============================================================================

-- ============================================================================
-- LSP Setup (vim.lsp.config / vim.lsp.enable — nvim 0.11+)
-- ============================================================================
do
    local capabilities
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink then
        capabilities = blink.get_lsp_capabilities()
    end

    vim.lsp.config("*", {
        capabilities = capabilities,
    })

    vim.lsp.enable({
        "lua_ls", "pyright", "bashls", "jsonls",
        "yamlls", "gopls", "tinymist", "markdown_oxide",
    })
end

setup_plugin("fidget", function(p) p.setup() end)
setup_plugin("gitsigns", function(p) p.setup() end)
setup_plugin("fzf-lua", function(p) p.setup() end)
setup_plugin("flash", function(p) p.setup() end)

setup_plugin("lint", function(lint)
  lint.linters_by_ft = {
    python = { "flake8" }
  }
end)

setup_plugin("luasnip.loaders.from_vscode", function(p) p.lazy_load() end)

setup_plugin("luasnip.loaders.from_lua", function(p)
  p.load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
end)

-- Claude Code (uses snacks terminal as provider)
setup_plugin("claudecode", function(p)
  p.setup({
    terminal = {
      provider = "snacks",
    },
  })
end)

-- ============================================================================
-- Load Plugin Configurations
-- ============================================================================

require("plugins.mini")
require("plugins.markview")
require("plugins.which-key")
require("plugins.blink-cmp")
require("plugins.obsidian")

-- ============================================================================
-- Theme Setup
-- ============================================================================

local ok, theme = pcall(require, "themes.init")

if ok and theme.setup then
  theme.setup()
else
  vim.notify("Theme configuration not found, using default colorscheme", vim.log.levels.WARN)
  vim.cmd("colorscheme default")
end

-- vim-kitty-navigator
vim.g.kitty_navigator_no_mappings = 1
vim.keymap.set("n", "<C-h>", ":KittyNavigateLeft<CR>",  { silent = true })
vim.keymap.set("n", "<C-j>", ":KittyNavigateDown<CR>",  { silent = true })
vim.keymap.set("n", "<C-k>", ":KittyNavigateUp<CR>",    { silent = true })
vim.keymap.set("n", "<C-l>", ":KittyNavigateRight<CR>", { silent = true })