-- ~/.config/nvim/lua/plugins/markview.lua

-- Helper function for safe plugin loading
local function setup_plugin(name, config_func)
  local ok, plugin = pcall(require, name)
  if ok then
    config_func(plugin)
  else
    vim.notify("Plugin not found: " .. name, vim.log.levels.WARN)
  end
end

-- Ensure our markdown core is set up (snippets/commands)
pcall(function() require("core.markdown").setup() end)

-- Start treesitter for markdown buffers if available
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    pcall(vim.treesitter.start, 0, "markdown")
    pcall(vim.treesitter.start, 0, "markdown_inline")
  end,
})

setup_plugin("markview", function(mv)
  mv.setup({
    -- Preview-related options
    preview = {
      filetypes = { "markdown", "markdown.mdx" },
      modes = { "i", "n", "no", "c" },
      hybrid_modes = { "i" , "n" },

      linewise_hybrid_mode = true,
    },

    -- Markdown-specific rendering options moved under markdown
    markdown = {
      headings = {
        enable = true,
        sign = false,
        style = {
          h1 = { prefix = " ", suffix = " " },
          h2 = { prefix = " ", suffix = " " },
          h3 = { prefix = " ", suffix = " " },
          h4 = { prefix = " ", suffix = " " },
          h5 = { prefix = " ", suffix = " " },
          h6 = { prefix = " ", suffix = " " },
        },
      },
      tables = { enable = true, strict = false, block_decorator = true },
      preview = { enable = true, enable_hybrid_mode = true },
      quote = { enable = true },
      hr = { enable = true },
      list = {
        enable = true,
        bullets = { "•", "◦", "▪" },
        checkbox = {
          enable = true,
          unchecked = "",
          checked = "",
          pending = "",
        },
      },
      code = {
        enable = true,
        style = {
          border = "rounded",
        },
      },
      inline = {
        enable = true,
        emphasis = true,
        links = true,
      },
      containers = {
        enable = true,
        definitions = {
          abstract  = { icon = "󰨸", hl = "DiagnosticInfo" },
          attention = { icon = "󰀪", hl = "DiagnosticWarn" },
          bug       = { icon = "󰨰", hl = "DiagnosticError" },
          caution   = { icon = "󰳦", hl = "DiagnosticWarn" },
          cite      = { icon = "󱆨", hl = "DiagnosticHint" },
          danger    = { icon = "󱐌", hl = "DiagnosticError" },
          done      = { icon = "󰄬", hl = "DiagnosticOk" },
          error     = { icon = "󱐌", hl = "DiagnosticError" },
          example   = { icon = "󰉹", hl = "DiagnosticHint" },
          fail      = { icon = "󰅖", hl = "DiagnosticError" },
          fix       = { icon = "󰗡", hl = "DiagnosticError" },
          help      = { icon = "󰘥", hl = "DiagnosticHint" },
          hint      = { icon = "󰌵", hl = "DiagnosticHint" },
          important = { icon = "󰅾", hl = "DiagnosticHint" },
          info      = { icon = "󰋽", hl = "DiagnosticInfo" },
          missing   = { icon = "󰅖", hl = "DiagnosticError" },
          note      = { icon = "󰋽", hl = "DiagnosticInfo" },
          question  = { icon = "󰘥", hl = "DiagnosticWarn" },
          success   = { icon = "󰄬", hl = "DiagnosticOk" },
          summary   = { icon = "󰨸", hl = "DiagnosticInfo" },
          tip       = { icon = "󰌶", hl = "DiagnosticOk" },
          tldr      = { icon = "󰨸", hl = "DiagnosticInfo" },
          todo      = { icon = "󰗡", hl = "DiagnosticInfo" },
          warn      = { icon = "󰀪", hl = "DiagnosticWarn" },
        },
      },
    },

    -- Global plugin behaviour
    throttle = 20,
  })
end)
