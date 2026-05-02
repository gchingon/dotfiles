local setup_plugin = require("core.util").setup_plugin

setup_plugin("nvim-treesitter.configs", function(ts_config)
  ts_config.setup({
    highlight = {
      enable = true,
      disable = { "lua" },  -- Disable treesitter for Lua due to query mismatch
    },
    indent = {
      enable = true,
      disable = { "lua" },
    },
  })
end)
