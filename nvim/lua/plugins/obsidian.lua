-- obsidian.nvim — note navigation, link following, search inside vault.
-- frontmatter is disabled here: core/frontmatter.lua is the source of truth.
--
-- Vaults are discovered dynamically so this config works across machines
-- with different directory layouts (e.g. ~/Documents/notes,
-- ~/Documents/repos/notes, ~/Documents/2mepo/notes).
return {
  {
    "obsidian-nvim/obsidian.nvim",
    lazy = false,
    config = function()
      -- ── Dynamic vault discovery ─────────────────────────────────────────
      -- Scan ~/Documents (up to 3 levels) for dirs containing .obsidian/.
      local function find_vaults()
        local base = vim.fn.expand("~/Documents")
        if vim.fn.isdirectory(base) == 0 then return {} end

        local hits = vim.fs.find(".obsidian", {
          path = base,
          limit = 10,
          type = "directory",
        })

        local vaults = {}
        for _, hit in ipairs(hits) do
          local vault_path = vim.fn.fnamemodify(hit, ":h")
          local name = vim.fn.fnamemodify(vault_path, ":t")
          table.insert(vaults, { name = name, path = vault_path })
        end
        return vaults
      end

      local vaults = find_vaults()
      if #vaults == 0 then
        vim.notify("obsidian.nvim: no vaults found under ~/Documents", vim.log.levels.WARN)
        return
      end

      require("obsidian").setup({
        workspaces = vaults,

        -- core/frontmatter.lua (BufWritePre) is the source of truth.
        frontmatter = { enabled = false },

        legacy_commands = false,

        -- nvim-cmp source disabled; we use blink.cmp.
        completion = {
          nvim_cmp = false,
          min_chars = 2,
        },

        new_notes_location = "current_dir",
        note_id_func = function(title)
          if title then
            return title:gsub("%s+", "-"):lower()
          end
          return tostring(os.time())
        end,

        -- markview.nvim handles decorations; avoid double-rendering.
        ui = { enable = false },
      })

      -- ── Buffer-local keymaps (vault files only) ──────────────────────────
      local md_patterns = {}
      for _, v in ipairs(vaults) do
        table.insert(md_patterns, v.path .. "/**/*.md")
      end

      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("ObsidianKeymaps", { clear = true }),
        pattern = md_patterns,
        callback = function(ev)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
          end

          map("n", "<leader>of", "<cmd>Obsidian follow_link<cr>", "Obsidian: Follow link")
          map("n", "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", "Obsidian: Toggle checkbox")
          map("n", "<leader>on", "<cmd>Obsidian quick_switch<cr>", "Obsidian: Quick switch")
          map("n", "<leader>os", "<cmd>Obsidian search<cr>", "Obsidian: Search vault")
          map("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", "Obsidian: Backlinks")
          map("n", "<leader>od", "<cmd>Obsidian today<cr>", "Obsidian: Today's note")
          map("v", "<leader>ol", "<cmd>Obsidian link_new<cr>", "Obsidian: Link → new note")
        end,
      })

      local ok_wk, wk = pcall(require, "which-key")
      if ok_wk then
        wk.add({
          { "<leader>o", group = "Obsidian" },
          { "<leader>of", desc = "Follow link" },
          { "<leader>oc", desc = "Toggle checkbox" },
          { "<leader>on", desc = "Quick switch" },
          { "<leader>os", desc = "Search vault" },
          { "<leader>ob", desc = "Backlinks" },
          { "<leader>od", desc = "Today's note" },
          { "<leader>ol", desc = "Link → new note", mode = "v" },
        })
      end
    end,
  },
}
