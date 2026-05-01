return {
  require("core.util").setup_plugin("nvim-treesitter", function(ts)
    ts.setup({
      highlight = {
        enable = true,
        disable = { "lua" },  -- Disable treesitter for Lua due to query mismatch
      },
      indent = {
        enable = true,
      },
    })
  end)
}
