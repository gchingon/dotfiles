-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

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

-- Markdown local options (LazyVim already sets wrap+linebreak for markdown;
-- this adds the custom showbreak arrow on top)
autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.breakindent = true
    vim.opt_local.showbreak = "↪ "
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

require("core.frontmatter").setup()
require("core.checkbox-cycle").setup()
