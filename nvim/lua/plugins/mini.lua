return {
  {
    "nvim-mini/mini.nvim",
    lazy = false,
    config = function()
      require("mini.basics").setup()
      require("mini.trailspace").setup()
      require("mini.pairs").setup({})

      require("mini.files").setup({
        windows = {
          preview = true,
          width_focus = 40,
          width_nofocus = 25,
          width_preview = 60,
        },
        mappings = {
          go_in = "l",
          go_in_plus = "L",
          go_out = "h",
          go_out_plus = "H",
          close = "q",
          reset = "<BS>",
          reveal_cwd = "@",
          show_help = "g?",
          synchronize = "s",
        },
        options = {
          use_as_default_explorer = false,
        },
      })

      local MiniFiles = require("mini.files")

      local function open_mini_files_smart()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local dir_name = (buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":p:h")) or nil

        if buf_name ~= "" and vim.fn.filereadable(buf_name) == 1 then
          MiniFiles.open(buf_name, true)
        elseif dir_name and vim.fn.isdirectory(dir_name) == 1 then
          MiniFiles.open(dir_name, true)
        else
          MiniFiles.open(vim.uv.cwd(), true)
        end
      end

      local function toggle_mini_files()
        for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(winid)
          if vim.bo[buf].filetype == "minifiles" then
            MiniFiles.close()
            return
          end
        end
        open_mini_files_smart()
      end

      local function open_cwd()
        MiniFiles.open(vim.uv.cwd(), true)
      end

      -- NOTE: overrides LazyVim's default <leader>e file-explorer binding
      -- intentionally — mini.files replaces it here.
      vim.keymap.set("n", "<leader>e", toggle_mini_files, { desc = "Files: Toggle (smart)", silent = true })
      vim.keymap.set("n", "<leader>E", open_cwd, { desc = "Files: Open CWD", silent = true })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionOpen",
        callback = function(ev)
          if ev.data and ev.data.from == "files" then
            MiniFiles.set_target_window("current")
          end
        end,
      })

      require("mini.ai").setup({ n_lines = 500 })

      require("mini.surround").setup({
        mappings = {
          add = "<leader>sa",
          delete = "<leader>sd",
          find = "<leader>sf",
          find_left = "<leader>sF",
          highlight = "<leader>sh",
          replace = "<leader>sr",
          update_n_lines = "<leader>su",
          add_visual = "<leader>sv",
          suffix_last = "<leader>sN",
          suffix_next = "<leader>sn",
        },
        n_lines = 50,
        respect_selection_type = true,
        search_method = "cover",
      })

      require("mini.tabline").setup({ show_icons = true })
      require("mini.statusline").setup()

      -- mini.hipatterns — callout word highlighting
      local hipatterns = require("mini.hipatterns")

      local function wpat(word)
        return string.format("%%f[%%w]()%s()%%f[%%W]", vim.pesc(word))
      end

      local callout_map = {
        ABSTRACT = "MiniStatuslineModeOther",
        ATTENTION = "MiniStatuslineModeReplace",
        BUG = "MiniStatuslineModeVisual",
        CAUTION = "DiffDelete",
        CHECK = "MiniStatuslineModeInsert",
        CITE = "MiniStatuslineModeCommand",
        DANGER = "DiffDelete",
        DONE = "MiniStatuslineModeInsert",
        ERROR = "DiffDelete",
        FAIL = "DiffDelete",
        FAQ = "MiniStatuslineModeReplace",
        FIX = "MiniStatuslineModeVisual",
        HELP = "MiniStatuslineModeCommand",
        INFO = "MiniStatuslineModeNormal",
        NOTE = "MiniStatuslineModeNormal",
        QUESTION = "MiniStatuslineModeCommand",
        SUMMARY = "MiniStatuslineModeNormal",
        TIP = "MiniStatuslineModeInsert",
        TLDR = "MiniStatuslineModeNormal",
        TODO = "MiniStatuslineModeVisual",
        WARNING = "MiniStatuslineModeCommand",
      }

      local highlighters = {}
      highlighters.hex_color = hipatterns.gen_highlighter.hex_color({ style = "bg" })
      for word, group in pairs(callout_map) do
        table.insert(highlighters, { pattern = wpat(word), group = group })
      end

      hipatterns.setup({ highlighters = highlighters })
    end,
  },
}
