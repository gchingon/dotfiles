-- ~/.config/nvim/init.lua
-- Final, stable, and complete version using vim-plug

vim.g.mapleader = " "

-- ----------------------------------------------------------------------------
-- Bootstrap vim-plug
-- ----------------------------------------------------------------------------
local plug_path = vim.fn.stdpath('data') .. '/site/autoload/plug.vim'
if vim.fn.empty(vim.fn.glob(plug_path)) > 0 then
  vim.notify('Installing vim-plug, please wait...', vim.log.levels.INFO)
  vim.fn.system({
    'curl', '-fLo', plug_path, '--create-dirs',
    'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
  })
  vim.cmd('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
end

-- ----------------------------------------------------------------------------
-- Plugin Declaration
-- ----------------------------------------------------------------------------
vim.cmd([[
  call plug#begin()

  " Framework & UI
  Plug 'echasnovski/mini.nvim'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'folke/which-key.nvim'

  " LSP & Completion
  Plug 'neovim/nvim-lspconfig'
  Plug 'j-hui/fidget.nvim'
  Plug 'folke/neodev.nvim'
  Plug 'saghen/blink.cmp', { 'tag': 'v1.*' }
  Plug 'rafamadriz/friendly-snippets'
  Plug 'moyiz/blink-emoji.nvim'
  Plug 'Kaiser-Yang/blink-cmp-dictionary'
  Plug 'saghen/blink.compat'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'L3MON4D3/LuaSnip', {'do': 'make install_jsregexp'}

  " Treesitter
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-treesitter/nvim-treesitter-textobjects'
  Plug 'windwp/nvim-ts-autotag'
  Plug 'LhKipp/tree-sitter-nu'

  " Tools
  Plug 'ibhagwan/fzf-lua'
  Plug 'lewis6991/gitsigns.nvim'
  Plug 'mfussenegger/nvim-lint'
  Plug 'MeanderingProgrammer/render-markdown.nvim'
  Plug 'folke/flash.nvim'

  call plug#end()
]])

-- ============================================================================
-- Core & Plugin Loading (This Lua code runs AFTER plug#end())
-- ============================================================================

-- Helper function for safe plugin loading
local function setup_plugin(name, config_func)
  local ok, plugin = pcall(require, name)
  if ok then
    config_func(plugin)
  else
    vim.notify("Plugin not found: " .. name, vim.log.levels.WARN)
  end
end

-- Load core settings first
require("core.options")
require("core.autocmds")
require("core.keymaps") -- This contains ALL custom leader keymaps

-- -----------------------------------
-- Plugin Configurations
-- -----------------------------------

-- Mini.nvim
setup_plugin("mini.basics", function(p) p.setup() end)
setup_plugin("mini.trailspace", function(p) p.setup() end)
setup_plugin("mini.pairs", function(p) p.setup({}) end)
setup_plugin("mini.files",
  function(p) p.setup({ windows = { preview = true, width_focus = 40, width_nofocus = 25, width_preview = 60 } }) end)
setup_plugin("mini.ai", function(p) p.setup({ n_lines = 500 }) end)
setup_plugin("mini.surround", function(p) p.setup() end)
setup_plugin("mini.tabline", function(p) p.setup({ show_icons = true }) end)
setup_plugin("mini.statusline", function(p) p.setup() end)

-- Mini.hipatterns with your full callout config
setup_plugin("mini.hipatterns", function(hipatterns)
  local function wpat(word) return string.format("%%f[%%w]()%s()%%f[%%W]", vim.pesc(word)) end
  local callout_map = {
    ABSTRACT = "RenderMarkdownInfo",
    ATTENTION = "RenderMarkdownWarn",
    BUG = "RenderMarkdownError",
    CAUTION = "RenderMarkdownError",
    CHECK = "RenderMarkdownSuccess",
    CITE = "RenderMarkdownQuote",
    DANGER = "RenderMarkdownError",
    DONE = "RenderMarkdownSuccess",
    ERROR = "RenderMarkdownError",
    EXAMPLE = "RenderMarkdownHint",
    FAIL = "RenderMarkdownError",
    FAQ = "RenderMarkdownWarn",
    HELP = "RenderMarkdownWarn",
    IMPORTANT = "RenderMarkdownHint",
    INFO = "RenderMarkdownInfo",
    MISSING = "RenderMarkdownError",
    NOTE = "RenderMarkdownInfo",
    QUESTION = "RenderMarkdownWarn",
    SUMMARY = "RenderMarkdownInfo",
    TLDR = "RenderMarkdownInfo",
    TIP = "RenderMarkdownSuccess",
    TODO = "RenderMarkdownInfo",
    WARNING = "RenderMarkdownWarn",
    FIX = "RenderMarkdownError",
  }
  local highlighters = {}
  table.insert(highlighters, { pattern = wpat("HACK"), group = "DiagnosticWarn" })
  for word, group in pairs(callout_map) do
    table.insert(highlighters, { pattern = wpat(word), group = group })
  end
  hipatterns.setup({ highlighters = highlighters })
end)

-- which-key.nvim - Load its dedicated config file
setup_plugin("which-key", function() require("plugins.which-key")() end)

-- LSP
setup_plugin("lspconfig", function(lspconfig)
  local capabilities = require("cmp_nvim_lsp").default_capabilities()
  local servers = { "lua_ls", "pyright", "bashls", "jsonls", "yamlls", "marksman", "gopls", "tinymist" }
  for _, server_name in ipairs(servers) do
    lspconfig[server_name].setup({ capabilities = capabilities })
  end
end)
setup_plugin("fidget", function(p) p.setup({}) end)

-- Treesitter
setup_plugin("nvim-treesitter.configs", function(configs)
  configs.setup({
    ensure_installed = { "lua", "python", "bash", "json", "yaml", "html", "css", "javascript", "typescript", "tsx", "c", "cpp", "rust", "go", "markdown", "markdown_inline" },
    sync_install = false,
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    autotag = { enable = true },
  })
end)

-- Blink Completion
setup_plugin("blink-cmp", function(blink_cmp)
  blink_cmp.setup({
    keymap = { preset = "default" },
    snippets = {
      expand = function(snippet) require("luasnip").lsp_expand(snippet) end,
      active = function(filter)
        if filter and filter.direction then return require("luasnip").jumpable(filter.direction) end
        return require("luasnip").in_snippet()
      end,
      jump = function(direction) require("luasnip").jump(direction) end,
    },
  })
end)

-- Render-Markdown with your full callout config
setup_plugin("render-markdown", function(rm)
  local callout_definitions = {
    abstr = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
    attent = { raw = "[!ATTENTION]", rendered = "󰀪 Attention", highlight = "RenderMarkdownWarn" },
    bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "RenderMarkdownError" },
    caut = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
    check = { raw = "[!CHECK]", rendered = "󰄬 Check", highlight = "RenderMarkdownSuccess" },
    cite = { raw = "[!CITE]", rendered = "󱆨 Cite", highlight = "RenderMarkdownQuote" },
    danger = { raw = "[!DANGER]", rendered = "󱐌 Danger", highlight = "RenderMarkdownError" },
    done = { raw = "[!DONE]", rendered = "󰄬 Done", highlight = "RenderMarkdownSuccess" },
    error = { raw = "[!ERROR]", rendered = "󱐌 Error", highlight = "RenderMarkdownError" },
    example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "RenderMarkdownHint" },
    fail = { raw = "[!FAIL]", rendered = "󰅖 Fail", highlight = "RenderMarkdownError" },
    faq = { raw = "[!FAQ]", rendered = "󰘥 Faq", highlight = "RenderMarkdownWarn" },
    help = { raw = "[!HELP]", rendered = "󰘥 Help", highlight = "RenderMarkdownWarn" },
    important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
    info = { raw = "[!INFO]", rendered = "󰋽 Info", highlight = "RenderMarkdownInfo" },
    miss = { raw = "[!MISSING]", rendered = "󰅖 Missing", highlight = "RenderMarkdownError" },
    note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
    quest = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
    summary = { raw = "[!SUMMARY]", rendered = "󰨸 Summary", highlight = "RenderMarkdownInfo" },
    tldr = { raw = "[!TLDR]", rendered = "󰨸 Tldr", highlight = "RenderMarkdownInfo" },
    tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
    todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownInfo" },
    warn = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
    fix = { raw = "[!FIX]", rendered = "󰗡 Fix", highlight = "RenderMarkdownError" },
  }
  rm.setup({
    bullet = { enabled = true },
    checkbox = { enabled = true, position = "inline" },
    html = { enabled = true, comment = { conceal = false } },
    heading = { sign = false },
    callout = callout_definitions,
  })
end)

-- Other plugins
setup_plugin("gitsigns", function(p) p.setup() end)
setup_plugin("fzf-lua", function(p) p.setup() end)
setup_plugin("flash", function(p) p.setup() end)
setup_plugin("luasnip.loaders.from_vscode", function(p) p.lazy_load() end)
setup_plugin("lint", function(lint) lint.linters_by_ft = { python = { "flake8" } } end)

-- Load theme last
require("core.theme").setup()
