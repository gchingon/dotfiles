-- ~/.config/nvim/lua/core/autocmds.lua
-- Defines autocommands for custom editor behavior.

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight text on yank
local yank_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Ensure undo directory exists
autocmd("VimEnter", {
  pattern = "*",
  callback = function()
    local undodir = vim.fn.stdpath("cache") .. "/undo"
    if vim.fn.isdirectory(undodir) == 0 then
      vim.fn.mkdir(undodir, "p")
    end
    vim.opt.undodir = undodir
  end,
})

-- Set .kbd files to lisp filetype
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.kbd",
  callback = function()
    vim.bo.filetype = "lisp"
  end,
})

-- Create markdown snippet expansion commands
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    local ok, ls = pcall(require, "luasnip")
    if not ok then return end

    local function expand_snippet(trigger)
      local snips = ls.get_snippets("markdown") or {}
      for _, sn in ipairs(snips) do
        if sn.trigger == trigger then
          ls.snip_expand(sn)
          return
        end
      end
      vim.notify("Snippet '" .. trigger .. "' not found", vim.log.levels.WARN)
    end

    vim.api.nvim_buf_create_user_command(0, "MDCharacter", function()
      expand_snippet("character")
    end, { desc = "Insert Character template" })
  end,
})
