return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- Disabled for Lua: query error on this nvim build (see ftplugin/lua.lua
      -- for the syntax-highlighting fallback).
      highlight = { disable = { "lua" } },
      indent = { disable = { "lua" } },
    },
  },
}
