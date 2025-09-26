-- ~/.config/nvim/lua/plugins/which-key.lua
-- Configures which-key.nvim and registers all leader-based keymaps using the modern spec.

return function()
  local wk = require("which-key")

  -- Configuration with the correct 'win' option and helix preset
  wk.setup({
    preset = "helix",
    win = {
      border = "rounded",
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
  })

  -- Keymap definitions using the new, flat specification.
  -- This single table is the source of truth for all leader mappings.
  local mappings = {
    -- Group Definitions
    { "<leader>/",  group = "Find (FZF)" },
    { "<leader>c",  group = "Code" },
    { "<leader>G",  group = "Git" },
    { "<leader>s",  group = "Search (Flash)" },
    { "<leader>t",  group = "Toggle" },
    { "<leader>u",  group = "UI" },
    { "<leader>r",  group = "Rename" },

    -- Individual Keymaps
    -- Note: Mappings for multiple modes are defined with mode = { "n", "v" }

    -- FZF (Normal Mode only)
    { "<leader>/f", "<cmd>FzfLua files<cr>",                                        desc = "Files" },
    { "<leader>/g", "<cmd>FzfLua git_files<cr>",                                    desc = "Git Files" },
    { "<leader>/b", "<cmd>FzfLua buffers<cr>",                                      desc = "Buffers" },
    { "<leader>/h", "<cmd>FzfLua help_tags<cr>",                                    desc = "Help Tags" },

    -- Buffer Navigation (Normal Mode only)
    { "<leader>l",  "<cmd>bn<cr>",                                                  desc = "Next Buffer" },
    { "<leader>h",  "<cmd>bp<cr>",                                                  desc = "Previous Buffer" },

    -- Git / Gitsigns
    { "<leader>Gs", ":Gitsigns stage_hunk<CR>",                                     desc = "Stage Hunk",       mode = { "n", "v" } },
    { "<leader>Gr", ":Gitsigns reset_hunk<CR>",                                     desc = "Reset Hunk",       mode = { "n", "v" } },
    { "<leader>GS", function() require("gitsigns").stage_buffer() end,              desc = "Stage Buffer" },
    { "<leader>Gu", function() require("gitsigns").undo_stage_hunk() end,           desc = "Undo Stage" },
    { "<leader>GR", function() require("gitsigns").reset_buffer() end,              desc = "Reset Buffer" },
    { "<leader>Gp", function() require("gitsigns").preview_hunk() end,              desc = "Preview Hunk" },
    { "<leader>Gb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame Line" },
    { "<leader>GD", function() require("gitsigns").diffthis("~") end,               desc = "Diff This ~" },
    { "<leader>Gd", function() require("gitsigns").diffthis() end,                  desc = "Diff This" },
    { "<leader>tb", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle Blame" },
    { "<leader>td", function() require("gitsigns").toggle_deleted() end,            desc = "Toggle Deleted" },

    -- LSP
    { "<leader>ca", vim.lsp.buf.code_action,                                        desc = "Code Action",      mode = { "n", "v" } },
    { "<leader>rn", vim.lsp.buf.rename,                                             desc = "Rename" },
    { "<leader>D",  vim.lsp.buf.type_definition,                                    desc = "Type Definition" },
    { "<leader>f",  function() vim.lsp.buf.format({ async = true }) end,            desc = "Format" },

    -- Flash
    { "<leader>s",  function() require("flash").jump() end,                         desc = "Flash Jump",       mode = { "n", "v", "o" } },
    { "<leader>S",  function() require("flash").treesitter() end,                   desc = "Flash Treesitter", mode = { "n", "v", "o" } },

    -- Toggles
    { "<leader>uw", "<cmd>set wrap!<cr>",                                           desc = "Toggle Wrap" },
  }

  -- Register all mappings at once.
  -- which-key will handle creating the keymaps based on the spec.
  wk.add(mappings)
end
