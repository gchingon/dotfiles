---@type vim.lsp.Config
return {
  cmd = { 'markdown-oxide' },
  filetypes = { 'markdown', 'markdown.mdx' },
  root_markers = { 'oxide.toml', 'oxide.json', '.git' },
  settings = {
    markdown = {
      completion = { enable = true },
      diagnostics = { enable = true },
      links = { enable = true },
    },
  },
}
