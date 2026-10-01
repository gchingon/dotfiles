return {
  -- fzf-lua as LazyVim's picker (swaps LazyVim's default snacks-picker leader-f keys)
  { import = "lazyvim.plugins.extras.editor.fzf" },

  -- Custom file finder (ff/fg/fz/fc keymaps)
  {
    "dmtrKovalenko/fff.nvim",
    build = function() require("fff.download").download_or_build_binary() end,
    lazy = false,
    opts = {
      debug = { enabled = true, show_scores = true },
    },
    config = function(_, opts)
      local fff = require("fff")
      fff.setup(opts)
      vim.keymap.set("n", "ff", function() fff.find_files() end, { desc = "FFF: find files" })
      vim.keymap.set("n", "fg", function() fff.live_grep() end, { desc = "FFF: live grep" })
      vim.keymap.set("n", "fz", function()
        fff.live_grep({ grep = { modes = { "fuzzy", "plain" } } })
      end, { desc = "FFF: fuzzy grep" })
      vim.keymap.set("n", "fc", function()
        fff.live_grep({ query = vim.fn.expand("<cword>") })
      end, { desc = "FFF: grep current word" })
    end,
  },

  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "flake8" },
      },
    },
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "flake8" },
    },
  },

  -- Claude Code, using snacks' terminal as provider
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = { provider = "snacks" },
    },
  },

  -- Custom notifier tuning; LazyVim's other snacks features (dashboard,
  -- picker, indent, etc.) are left on their LazyVim defaults on purpose.
  {
    "folke/snacks.nvim",
    opts = {
      notifier = {
        enabled = true,
        timeout = 3000,
        style = "fancy",
      },
    },
  },

  { "knubie/vim-kitty-navigator" },
}
