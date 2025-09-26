-- $HOME/.config/nvim/init.lua
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
  Plug 'nvim-lua/plenary.nvim'
  Plug 'Kaiser-Yang/blink-cmp-dictionary'
  Plug 'saghen/blink.compat'
  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'L3MON4D3/LuaSnip', {'do': 'make install_jsregexp'}
  Plug 'chomosuke/typst-preview.nvim', {'tag': 'v1.*'}

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

  " Org ecosystem
  Plug 'nvim-orgmode/orgmode'
  Plug 'obsidian-nvim/obsidian.nvim'

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

-- Ensure plenary is available before providers that require it
pcall(require, "plenary")

-- Load core settings first
-- Check if these files exist before requiring them
local function safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("Module not found: " .. module, vim.log.levels.WARN)
  end
  return ok, result
end

safe_require("core.options")
safe_require("core.autocmds")
safe_require("core.keymaps") -- This contains ALL custom leader keymaps

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
setup_plugin("mini.surround", function(p)
    p.setup({
        mappings = {
            add = "gza",            -- add surrounding: gza + motion/textobject + char(s)
            delete = "gzd",         -- delete surrounding: gzd + char
            find = "gzf",           -- find surrounding to the right
            find_left = "gzF",      -- find surrounding to the left
            highlight = "gzh",      -- highlight surrounding
            replace = "gzr",        -- replace surrounding: gzr + target + replacement
            update_n_lines = "gzn", -- update n_lines
            add_visual = "s",       -- in VISUAL mode: s to surround the selection
            suffix_last = "l",
            suffix_next = "n",
        },
        n_lines = 50,
        respect_selection_type = true,
        search_method = "cover",
    })
end)

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

-- LSP
setup_plugin("lspconfig", function(lspconfig)
  -- Check if we have blink.cmp or fallback to cmp-nvim-lsp
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

  local servers = { "lua_ls", "pyright", "bashls", "jsonls", "yamlls", "marksman", "gopls", "tinymist" }
  for _, server_name in ipairs(servers) do
    lspconfig[server_name].setup({ capabilities = capabilities })
  end
end)
setup_plugin("fidget", function(p) p.setup({}) end)

setup_plugin("nvim-treesitter.configs", function(configs)
  configs.setup({
    ensure_installed = {
      "lua", "python", "bash", "json", "yaml", "html", "css", "javascript", "typescript", "tsx",
      "c", "cpp", "rust", "go", "markdown", "markdown_inline",
    },
    sync_install = false,
    auto_install = true,
    highlight = {
      enable = true,
      -- Disable treesitter for org files, use orgmode's highlighting instead
      disable = { "org" },
      additional_vim_regex_highlighting = {},
    },
    indent = { enable = true },
    autotag = { enable = true },
  })
end)

-- Blink Completion (with ";" gate for snippets)
setup_plugin("plugins.blink-cmp", function(mod) mod.setup() end)

require("core.markdown").setup()

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
    checkbox = { enabled = true },
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
setup_plugin("lint", function(lint)
  lint.linters_by_ft = { python = { "flake8" } }
end)

-- Org-mode
setup_plugin("orgmode", function(orgmode)
  orgmode.setup({
    org_agenda_files = { "$HOME/Documents/org/**/*" },
    org_default_notes_file = "$HOME/Documents/org/inbox.org",
  })
end)

-- obsidian.nvim
setup_plugin("obsidian", function(obsidian)
  obsidian.setup({
    workspaces = {
      {
        name = "notes",
        path = "$HOME/Documents/notes",
      },
      {
        name = "novel",
        path = "$HOME/Documents/widows-club",
      },
      {
        name = "braindump",
        path = "$HOME/Documents/markdown",
      },
    },
    -- daily_notes = {
    --   folder = "$HOME/Documents/daily",
    --   date_format = "%Y-%^b-%d_%a",       -- 2025-SEP-17_Wed
    -- },
    completion = {
      blink = true,
      min_chars = 2,
    },
    new_notes_location = "current_dir",
    legacy_commands = false,     -- Disable deprecated commands
    note_id_func = function(title)
      -- Create note IDs from title, removing spaces and special chars
      local suffix = ""
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        suffix = tostring(os.time())
      end
      return suffix
    end,
    -- Configure which workspace should handle daily notes
    note_frontmatter_func = function(note)
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,
  })
end)

-- which-key.nvim - Load its dedicated config AFTER orgmode
setup_plugin("which-key", function()
  local ok, which_key_config = pcall(require, "plugins.which-key")
  if ok and type(which_key_config) == "function" then
    which_key_config()
  else
    -- Fallback basic which-key setup
    local which_key = require("which-key")
    which_key.setup()
  end
end)

-- Load theme last
local ok, theme = pcall(require, "themes.init")
if ok and theme.setup then
  theme.setup()
else
  vim.notify("Theme configuration not found, using default colorscheme", vim.log.levels.WARN)
  vim.cmd("colorscheme default")
end
