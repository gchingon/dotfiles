return {
  {
    "folke/which-key.nvim",
    opts = {
      preset = "helix",
      win = { border = "rounded" },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 60 },
        align = "left",
      },
      sort = { "frecency", "order", "group", "alphanum" },
      show_help = true,
      show_keys = true,
      spec = {
        { "<leader>/", group = "Find / Search" },
        { "<leader>G", group = "Git" },
        { "<leader>m", group = "Markdown" },
        { "<leader>mh", group = "Headings" },
        { "<leader>ml", group = "Links" },
        { "<leader>ms", group = "Snippets" },
        { "<leader>msl", group = "Language" },
        { "<leader>mt", group = "Templates / TOC" },
        { "<leader>s", group = "Surround" },
        { "<leader>a", group = "AI / Claude" },
        { "<leader>N", group = "Notifications" },

        -- Find / Search
        { "<leader>/f", "<cmd>FzfLua files<cr>", desc = "Files" },
        { "<leader>/g", "<cmd>FzfLua git_files<cr>", desc = "Git Files" },
        { "<leader>/b", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
        { "<leader>/h", "<cmd>FzfLua help_tags<cr>", desc = "Help Tags" },
        { "<leader>/r", "<cmd>FzfLua grep<cr>", desc = "Grep (ripgrep)" },
        { "<leader>/j", function() require("flash").jump() end, desc = "Flash Jump", mode = { "n", "v", "o" } },
        {
          "<leader>/s",
          function() require("flash").treesitter_search() end,
          desc = "Flash Treesitter Search",
          mode = { "n", "v", "o" },
        },

        -- Buffer navigation
        { "<leader>l", "<cmd>bn<cr>", desc = "Next Buffer" },
        { "<leader>h", "<cmd>bp<cr>", desc = "Prev Buffer" },

        -- Git / Gitsigns
        { "<leader>Gs", ":Gitsigns stage_hunk<CR>", desc = "Stage Hunk", mode = { "n", "v" } },
        { "<leader>Gr", ":Gitsigns reset_hunk<CR>", desc = "Reset Hunk", mode = { "n", "v" } },
        { "<leader>GS", function() require("gitsigns").stage_buffer() end, desc = "Stage Buffer" },
        { "<leader>Gu", function() require("gitsigns").undo_stage_hunk() end, desc = "Undo Stage" },
        { "<leader>GR", function() require("gitsigns").reset_buffer() end, desc = "Reset Buffer" },
        { "<leader>Gp", function() require("gitsigns").preview_hunk() end, desc = "Preview Hunk" },
        { "<leader>Gb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame Line" },
        { "<leader>Gd", function() require("gitsigns").diffthis() end, desc = "Diff This" },
        { "<leader>GD", function() require("gitsigns").diffthis("~") end, desc = "Diff This ~" },

        -- Toggle (NOTE: shares <leader>t with LazyVim's own "Terminal" group)
        { "<leader>tb", function() require("gitsigns").toggle_current_line_blame() end, desc = "Git Blame" },
        { "<leader>td", function() require("gitsigns").toggle_deleted() end, desc = "Git Deleted" },
        { "<leader>tw", "<cmd>set wrap!<cr>", desc = "Word Wrap" },
        { "<leader>tr", "<cmd>set relativenumber!<cr>", desc = "Relative Numbers" },
        { "<leader>tc", "<cmd>set cursorline!<cr>", desc = "Cursor Line" },
        { "<leader>ts", "<cmd>set spell!<cr>", desc = "Spellcheck" },
        { "<leader>th", "<cmd>set hlsearch!<cr>", desc = "Search Highlight" },
        { "<leader>tn", "<cmd>set number!<cr>", desc = "Line Numbers" },

        -- LSP / Code
        { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
        { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
        { "<leader>rn", vim.lsp.buf.rename, desc = "Rename Symbol" },
        { "<leader>D", vim.lsp.buf.type_definition, desc = "Type Definition" },
        { "<leader>f", function() vim.lsp.buf.format({ async = true }) end, desc = "Format Buffer" },

        -- mini.files (keymaps set in plugins/mini.lua)
        { "<leader>e", desc = "Files: Toggle (smart)" },
        { "<leader>E", desc = "Files: Open CWD" },

        -- Surround (keymaps set via mini.surround's own mappings table)
        { "<leader>sa", desc = "Surround Add" },
        { "<leader>sd", desc = "Surround Delete" },
        { "<leader>sf", desc = "Surround Find →" },
        { "<leader>sF", desc = "Surround Find ←" },
        { "<leader>sh", desc = "Surround Highlight" },
        { "<leader>sr", desc = "Surround Replace" },
        { "<leader>su", desc = "Surround Update n_lines" },
        { "<leader>sv", desc = "Surround Add (Visual)" },
        { "<leader>sN", desc = "Surround suffix_last" },
        { "<leader>sn", desc = "Surround suffix_next" },

        -- Markdown
        { "<leader>msc", "<cmd>MDCharacter<cr>", desc = "Insert Character Template" },

        -- AI / Claude
        { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
        { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },

        -- Notifications
        { "<leader>Nh", function() Snacks.notifier.show_history() end, desc = "Show History" },
        { "<leader>Nd", function() Snacks.notifier.hide() end, desc = "Dismiss All" },
      },
    },
  },
}
