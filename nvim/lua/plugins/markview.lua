return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    config = function()
      -- Start treesitter for markdown buffers if available
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          pcall(vim.treesitter.start, 0, "markdown")
          pcall(vim.treesitter.start, 0, "markdown_inline")
        end,
      })

      local mv = require("markview")
      local heading_presets = require("markview.presets").headings
      local heading_line_ns = vim.api.nvim_create_namespace("schingon_markview_heading_lines")

      -- Only ATX headers (# Heading) — avoids false positives with horizontal rules
      local function heading_level(lines, row)
        local hashes = lines[row + 1] and lines[row + 1]:match("^(#+)%s+")
        if hashes then return #hashes end
        return nil
      end

      local function refresh_heading_line_highlights(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then return end
        if vim.bo[bufnr].buftype ~= "" then return end
        if vim.bo[bufnr].filetype ~= "markdown" and vim.bo[bufnr].filetype ~= "markdown.mdx" then return end

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        vim.api.nvim_buf_clear_namespace(bufnr, heading_line_ns, 0, -1)

        for row = 0, #lines - 1 do
          local level = heading_level(lines, row)
          if level then
            vim.api.nvim_buf_set_extmark(bufnr, heading_line_ns, row, 0, {
              hl_eol = true,
              line_hl_group = "MarkviewHeading" .. level,
              priority = 5,
            })
          end
        end
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("schingon_markview_heading_lines", { clear = true }),
        pattern = { "*.md", "*.mdx", "*.markdown" },
        callback = function(args)
          vim.schedule(function()
            refresh_heading_line_highlights(args.buf)
          end)
        end,
      })

      mv.setup({
        preview = {
          filetypes = { "markdown", "markdown.mdx" },
          modes = { "n", "no", "c" },
          hybrid_modes = {},
          linewise_hybrid_mode = false,
        },

        markdown = {
          headings = heading_presets.glow,
          horizontal_rules = { enable = true },
          tables = { enable = true, block_decorator = true },
          list_items = {
            enable = true,
            wrap = true,
            shift_width = 4,
            marker_minus = {
              add_padding = true,
              conceal_on_checkboxes = true,
              text = "•",
              hl = "MarkviewListItemMinus",
            },
            marker_plus = {
              add_padding = true,
              conceal_on_checkboxes = true,
              text = "◦",
              hl = "MarkviewListItemPlus",
            },
            marker_star = {
              add_padding = true,
              conceal_on_checkboxes = true,
              text = "▪",
              hl = "MarkviewListItemStar",
            },
            marker_dot = {
              text = function(_, item) return string.format("%d.", item.n) end,
              hl = "@markup.list.markdown",
              add_padding = true,
              conceal_on_checkboxes = true,
            },
            marker_parenthesis = {
              text = function(_, item) return string.format("%d)", item.n) end,
              hl = "@markup.list.markdown",
              add_padding = true,
              conceal_on_checkboxes = true,
            },
          },
          block_quotes = { enable = true },
          inline_codes = { enable = true },
        },

        markdown_inline = {
          checkboxes = {
            enable = true,
            checked = { text = "", hl = "MarkviewCheckboxChecked" },
            unchecked = { text = "", hl = "MarkviewCheckboxUnchecked" },
            ["/"] = { text = "", hl = "MarkviewCheckboxPending" },
            ["-"] = { text = "󰍶", hl = "MarkviewCheckboxCancelled" },
          },
        },

        throttle = 20,
      })
    end,
  },
}
