-- $HOME/.config/nvim/init.lua
vim.g.mapleader = " "

-- ============================================================================
-- Plugin Setup Utilities
-- ============================================================================

-- Defines early so that plugin configs can use it
local function setup_plugin(name, config_func)
  local ok, plugin = pcall(require, name)
  if ok then
    config_func(plugin)
  else
    vim.notify("Plugin not found: " .. name, vim.log.levels.WARN)
  end
end

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

  " LSP & Completion
  Plug 'j-hui/fidget.nvim'
  Plug 'folke/neodev.nvim'
  Plug 'saghen/blink.cmp', { 'tag': 'v1.*' }
  Plug 'rafamadriz/friendly-snippets'
  Plug 'moyiz/blink-emoji.nvim'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'Kaiser-Yang/blink-cmp-dictionary'
  Plug 'saghen/blink.compat'
  Plug 'hrsh7th/cmp-nvim-lsp'
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

  " Org ecosystem
  Plug 'nvim-orgmode/orgmode'
  Plug 'nvimdev/lspsaga.nvim'

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
-- Other Plugin Setup (non-modular)
-- ============================================================================
-- ============================================================================
-- LSP Setup (vim.lsp.config / vim.lsp.enable — nvim 0.11+)
-- ============================================================================
do
    -- Capabilities (blink.cmp -> cmp_nvim_lsp fallback)
    local capabilities
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink then
        capabilities = blink.get_lsp_capabilities()
    else
        local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
        if ok_cmp then
            capabilities = cmp_lsp.default_capabilities()
        end
    end

    -- Global on_attach for all LSPs: sets Saga keymaps buffer-locally
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local bufnr = args.buf
            local opts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "K",  "<cmd>Lspsaga hover_doc<CR>",            opts)
            vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>",      opts)
            vim.keymap.set("n", "gr", "<cmd>Lspsaga finder ref<CR>",           opts)
            vim.keymap.set("n", "gR", "<cmd>Lspsaga rename<CR>",               opts)
            vim.keymap.set({ "n", "v" }, "ga", "<cmd>Lspsaga code_action<CR>", opts)
            vim.keymap.set("n", "gl", "<cmd>Lspsaga show_line_diagnostics<CR>",opts)
            vim.keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
            vim.keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
        end,
    })

    -- Apply capabilities to all LSP servers via wildcard config
    vim.lsp.config("*", {
        capabilities = capabilities,
    })

    -- Enable all servers (configs live in ~/.config/nvim/lsp/*.lua)
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

-- Load custom lua snippets from ~/.config/nvim/snippets
setup_plugin("luasnip.loaders.from_lua", function(p)
  p.load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
end)

setup_plugin("lspsaga", function(saga)
    saga.setup({
        ui = { border = "rounded" },
        symbol_in_winbar = { enable = false },
        lightbulb = { enable = true },
        code_action = { extend_gitsigns = true },
    })
end)

setup_plugin("orgmode", function(orgmode)
  orgmode.setup({
    org_agenda_files = { vim.env.HOME .. "/Documents/org/**/*" },
    org_default_notes_file = vim.env.HOME .. "/Documents/org/inbox.org",
  })
end)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true  -- preserves indentation on wrapped lines
    vim.opt_local.showbreak = "↪ "    -- visual indicator for wrapped lines
  end,
})

-- ============================================================================
-- Load Plugin Configurations
-- ============================================================================

require("plugins.mini")
require("plugins.markview")
require("plugins.which-key")
require("plugins.blink-cmp")

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
