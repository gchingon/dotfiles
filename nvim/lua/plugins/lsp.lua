-- Per-server settings live in lsp/*.lua (native vim.lsp.config convention,
-- nvim 0.11+) — this just tells LazyVim/mason which servers to install & enable.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {},
        pyright = {},
        bashls = {},
        jsonls = {},
        yamlls = {},
        gopls = {},
        tinymist = {},
        markdown_oxide = {},
        html = {},
        taplo = {},
      },
    },
  },
}
