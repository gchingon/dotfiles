-- ~/.config/nvim/lua/plugins/which-key.lua
-- Configures which-key.nvim and registers all leader-based keymaps using the modern spec.

local wk = require("which-key")

wk.setup({
  preset = "helix",
  win = { border = "rounded" },
  icons = {
    breadcrumb = "»",
    separator = "➜",
    group = "+",
  },
  layout = {
    height = { min = 4, max = 25 },
    width = { min = 20, max = 60 },
    align = "left",
  },
  show_help = true,
  show_keys = true,
})

-- Global mappings table (CLOSED PROPERLY)
local mappings = {

  -- Group Definitions
  { "<leader>/",   group = "Find " },
  { "<leader>c",   group = "Code" },
  { "<leader>t",   group = "mini.files"},
  { "<leader>G",   group = "Git" },
  { "<leader>s",   group = "Search (Flash)" },
  { "<leader>t",   group = "Toggle" },
  { "<leader>u",   group = "UI" },
  { "<leader>r",   group = "Rename" },

  { "K",           "Hover (Saga)" },
  { "gd",          "Goto Definition (Saga)" },
  { "gr",          "References (Saga Finder)" },
  { "gR",          "Rename (Saga)" },
  { "ga",          "Code Action (Saga)",                                           mode = { "n", "v" } },
  { "gl",          "Line Diagnostics (Saga)" },
  { "[d",          "Prev Diagnostic (Saga)" },
  { "]d",          "Next Diagnostic (Saga)" },

  -- FZF
  { "<leader>/f",  "<cmd>FzfLua files<cr>",                                        desc = "Files" },
  { "<leader>/g",  "<cmd>FzfLua git_files<cr>",                                    desc = "Git Files" },
  { "<leader>/b",  "<cmd>FzfLua buffers<cr>",                                      desc = "Buffers" },
  { "<leader>/h",  "<cmd>FzfLua help_tags<cr>",                                    desc = "Help Tags" },

  -- Buffer Navigation
  { "<leader>l",   "<cmd>bn<cr>",                                                  desc = "Next Buffer" },
  { "<leader>h",   "<cmd>bp<cr>",                                                  desc = "Previous Buffer" },

  -- Git / Gitsigns
  { "<leader>Gs",  ":Gitsigns stage_hunk<CR>",                                     desc = "Stage Hunk",               mode = { "n", "v" } },
  { "<leader>Gr",  ":Gitsigns reset_hunk<CR>",                                     desc = "Reset Hunk",               mode = { "n", "v" } },
  { "<leader>GS",  function() require("gitsigns").stage_buffer() end,              desc = "Stage Buffer" },
  { "<leader>Gu",  function() require("gitsigns").undo_stage_hunk() end,           desc = "Undo Stage" },
  { "<leader>GR",  function() require("gitsigns").reset_buffer() end,              desc = "Reset Buffer" },
  { "<leader>Gp",  function() require("gitsigns").preview_hunk() end,              desc = "Preview Hunk" },
  { "<leader>Gb",  function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame Line" },
  { "<leader>GD",  function() require("gitsigns").diffthis("~") end,               desc = "Diff This ~" },
  { "<leader>Gd",  function() require("gitsigns").diffthis() end,                  desc = "Diff This" },
  { "<leader>tb",  function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle Blame" },
  { "<leader>td",  function() require("gitsigns").toggle_deleted() end,            desc = "Toggle Deleted" },

  -- Markdown (main group + snippet subgroup)
  { "<leader>m",   group = "Markdown" },
  { "<leader>mh",  group = "Headings" },
  { "<leader>ml",  group = "Links" },
  { "<leader>ms",  group = "Markdown Snippets" },
  { "<leader>msc", function() require("core.markdown").actions.character() end,    desc = "Insert Character template" },
  { "<leader>mse", function() require("core.markdown").actions.entity() end,       desc = "Insert Entity template" },
  { "<leader>msl", group = "Language" },
  { "<leader>mt",  group = "Templates/TOC" },
  { "<leader>t",   group = "Todo" },

  -- LSP
  { "<leader>ca",  vim.lsp.buf.code_action,                                        desc = "Code Action",              mode = { "n", "v" } },
  { "<leader>rn",  vim.lsp.buf.rename,                                             desc = "Rename" },
  { "<leader>D",   vim.lsp.buf.type_definition,                                    desc = "Type Definition" },
  { "<leader>f",   function() vim.lsp.buf.format({ async = true }) end,            desc = "Format" },

  -- Flash
  { "<leader>s",   function() require("flash").jump() end,                         desc = "Flash Jump",               mode = { "n", "v", "o" } },
  { "<leader>S",   function() require("flash").treesitter() end,                   desc = "Flash Treesitter",         mode = { "n", "v", "o" } },

  -- Toggles
  { "<leader>uw",  "<cmd>set wrap!<cr>",                                           desc = "Toggle Wrap" },
}

-------------------------------------------------------------------------
-- Orgmode labels: global and buffer-scoped (kept separate on purpose)
-------------------------------------------------------------------------
local function add_orgmode_labels_global()
  wk.add({
    { "<leader>o",   group = "Orgmode" },
    { "<leader>oa",  "<cmd>Org agenda<cr>",     desc = "Agenda" },
    { "<leader>oc",  "<cmd>Org capture<cr>",    desc = "Capture" },
    { "<leader>ol",  group = "Links" },
    { "<leader>ols", "<cmd>Org store-link<cr>", desc = "Store Link" },
  })
end

local function add_orgmode_labels_buffer(bufnr)
  wk.add({
    { "<leader>o",   group = "Orgmode" },
    { "<leader>oa",  "<cmd>Org agenda<cr>",        desc = "Agenda" },
    { "<leader>oc",  "<cmd>Org capture<cr>",       desc = "Capture" },
    { "<leader>ol",  group = "Links" },
    { "<leader>oli", "<cmd>Org insert-link<cr>",   desc = "Insert Link" },
    { "<leader>ole", "<cmd>Org open-at-point<cr>", desc = "Open Link at Point" },
  }, { buffer = bufnr })
end

-- Register orgmode global labels now
add_orgmode_labels_global()

-- Register orgmode buffer labels on FileType=org
vim.api.nvim_create_autocmd("FileType", {
  pattern = "org",
  callback = function(args) add_orgmode_labels_buffer(args.buf) end,
})

-- Register the global mappings table
wk.add(mappings)
