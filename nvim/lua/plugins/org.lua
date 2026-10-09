-- Org mode for Neovim: https://github.com/xheisenbugx/org.nvim
-- Org files live in $NT/org (notes repo, resolved per-machine by zshenv) and
-- fall back to ~/org where $NT isn't set (e.g. nvim not started from a login shell).
local org_dir = (vim.env.NT and vim.env.NT ~= "") and (vim.env.NT .. "/org") or "~/org"

return {
  "xheisenbugx/org.nvim",
  main = "org",
  lazy = false, -- startup cost is small: heavy modules load on first use
  opts = {
    org_directory = org_dir,
    agenda_files = { org_dir .. "/**/*.org" },
    default_notes_file = org_dir .. "/refile.org",
  },
}
