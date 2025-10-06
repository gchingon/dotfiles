-- Helper function for safe plugin loading
local function setup_plugin(name, config_func)
  local ok, plugin = pcall(require, name)
  if ok then
    config_func(plugin)
  else
    vim.notify("Plugin not found: " .. name, vim.log.levels.WARN)
  end
end

setup_plugin("mini.basics", function(p)
  p.setup()
end)

setup_plugin("mini.trailspace", function(p)
  p.setup()
end)

setup_plugin("mini.pairs", function(p)
  p.setup({})
end)

setup_plugin("mini.files", function(p)
  p.setup({
    windows = {
      preview = true,
      width_focus = 40,
      width_nofocus = 25,
      width_preview = 60
    }
  })
end)

setup_plugin("mini.ai", function(p)
  p.setup({ n_lines = 500 })
end)

setup_plugin("mini.surround", function(p)
  p.setup({
    mappings = {
      add = "<leader>gza",
      delete = "<leader>gzd",
      find = "<leader>gzf",
      find_left = "<leader>gzF",
      highlight = "<leader>gzh",
      replace = "<leader>gzr",
      update_n_lines = "<leader>gzn",
      add_visual = "<leader>gzs",
      suffix_last = "<leader>gzl",
      suffix_next = "<leader>gzn",
    },
    n_lines = 50,
    respect_selection_type = true,
    search_method = "cover",
  })
end)

setup_plugin("mini.tabline", function(p)
  p.setup({ show_icons = true })
end)

setup_plugin("mini.statusline", function(p)
  p.setup()
end)

-- Mini.hipatterns with full callout config
setup_plugin("mini.hipatterns", function(hipatterns)
  local function wpat(word)
    return string.format("%%f[%%w]()%s()%%f[%%W]", vim.pesc(word))
  end

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

  table.insert(highlighters, {
    pattern = wpat("HACK"),
    group = "DiagnosticWarn"
  })

  for word, group in pairs(callout_map) do
    table.insert(highlighters, {
      pattern = wpat(word),
      group = group
    })
  end

  hipatterns.setup({ highlighters = highlighters })
end)
