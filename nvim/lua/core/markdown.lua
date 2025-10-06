-- core/markdown.lua
-- Markdown snippets and helpers.
-- - Snippets use plain triggers ("fm", "character", "entity", etc.)
-- - Blink handles the leading ";" gate and replacement (per your blink.cmp config)
-- - Exposes actions for which-key, creates :MDCharacter and :MDEntity

local M = {}

-- Always expose actions so which-key can call them safely
M.actions = {
  character = function()
    if vim.fn.exists(":MDCharacter") == 2 then
      vim.cmd("MDCharacter")
    else
      vim.notify("MDCharacter command not available", vim.log.levels.WARN)
    end
  end,
  entity = function()
    if vim.fn.exists(":MDEntity") == 2 then
      vim.cmd("MDEntity")
    else
      vim.notify("MDEntity command not available", vim.log.levels.WARN)
    end
  end,
}

-- Timestamp helper
local function created_timestamp()
  return os.date("%Y-%m-%d_%H:%M:%S") .. "-0600"
end

-- Safe LuaSnip acquire
local function get_ls()
  local ok, ls = pcall(require, "luasnip")
  if not ok then
    vim.notify("LuaSnip not available; markdown snippets disabled", vim.log.levels.WARN)
    return nil
  end
  return ls
end

-- Define Markdown snippets
local function define_markdown_snippets()
  local ls = get_ls()
  if not ls then return end

  local s = ls.s
  local t = ls.text_node
  local i = ls.insert_node
  local rep = require("luasnip.extras").rep

  local fm = s({ trig = "fm", name = "Frontmatter (Obsidian modified extension)" }, {
    t({ "---" }),
    t({ "", "created: " }),
    i(0),
    t({ "", "---" }),
  })

  -- Character template (no frontmatter) - with 3 lines after each h2
  local character = s({ trig = "character", name = "Character template (no frontmatter)" }, {
    t("# "), i(1), t({ "", "" }),
    t("## Aliases"), t({ "", "" }, i(0), t { "", "" }),
    t("## Roles and Series"), t({ "", "", "", "" }),
    t("## Overview"), t({ "", "", "", "" }),
    t("## First Appearance (file/chapter)"), t({ "", "", "", "" }),
    t("## Logline (1–2 sentences)"), t({ "", "", "", "" }),
    t("## Character Arc and Growth Potential"), t({ "", "", "", "" }),
    t("## Notes"), t({ "", "", "", "" }),
    t("## Questions for Further Development"), t({ "", "", "", "" }),
    t("## Purpose and Goals"), t({ "", "", "", "" }),
    t("## Psychological Profile"), t({ "", "", "", "" }),
    t("## Personal History"), t({ "", "", "", "" }),
    t("## Physical Description"), t({ "", "", "", "" }),
    t("## Unique Voice, Dialogue Patterns, and Mannerisms"), t({ "", "", "", "" }),
    t("## Special Skills, Knowledge, or Abilities"), t({ "", "", "", "" }),
    t("## Resources and Capabilities"), t({ "", "", "", "" }),
    t("## Behavioral Patterns"), t({ "", "", "", "" }),
    t("## Communities, Organizations "), t({ "", "", "", "" }),
    t("## Operations and Methods"), t({ "", "", "", "" }),
    t("## Historical Context"), t({ "", "", "", "" }),
    rep(1), t("'s Hobbies"), t({ "", "", "", "" }),
    t("## Dialogue Examples"), t({ "", "", "", "" }),
    t("## Story Function and Narrative Purpose"), t({ "", "", "", "" }),
    t("## Relationship to other Characters"), t({ "", "", "" }),
  })

  -- blog post front matter snippet
  local head = s({ trig = "head", name = "blog post frontmatter" }, {
    t "---",
    t "layout: post",
    t "title: ", i(1, "title"),
    t "categories: ", i(2, "category"),
    t "image: assets/", i(3, "image_name.ext"),
    t "created: ", i(created_timestamp()),
    t "description: ", i(4, "a paragraph about the post"),
    t "---",
    t "",
    i(0)
  })

  -- rated blog post frontmatter
  local rating = s({ trig = "rating", name = "rated blog post frontmatter" }, {
    t "---",
    t "layout: post",
    t "title: ", i(1, "title"),
    t({ "tags: ", "[ ]" }),
    t "image: assets/", i(2, "image_name.ext"),
    t "created: ", i(created_timestamp()),
    t "description: ", i(3, "a paragraph about the post"),
    t "rating: ", i(4, "zero-3"),
    t "---",
    t "",
    i(0)
  })


  ls.add_snippets("markdown", {
    fm,
    character,
    entity,
    head,
    rating,
  })
end

-- Commands: insert templates without typing triggers
local function define_commands()
  local ls = get_ls()
  if not ls then
    vim.api.nvim_create_user_command("MDCharacter", function()
      vim.api.nvim_put({ "character" }, "c", true, true)
    end, { desc = "Insert Character template (no frontmatter)" })
    vim.api.nvim_create_user_command("MDEntity", function()
      vim.api.nvim_put({ "entity" }, "c", true, true)
    end, { desc = "Insert Entity template (no frontmatter)" })
    return
  end

  local function expand_by_trigger(trig)
    local ft = vim.bo.filetype
    -- If not in markdown, temporarily set for lookup/expansion context
    if ft ~= "markdown" then
      -- still attempt a markdown expansion into this buffer
    end
    local snips = ls.get_snippets("markdown") or {}
    local target
    for _, sn in ipairs(snips) do
      if sn.trigger == trig then
        target = sn
        break
      end
    end
    if target then
      ls.snip_expand(target)
    else
      vim.api.nvim_put({ trig }, "c", true, true)
    end
  end

  vim.api.nvim_create_user_command("MDCharacter", function()
    expand_by_trigger("character")
  end, { desc = "Insert Character template (no frontmatter)" })

  vim.api.nvim_create_user_command("MDEntity", function()
    expand_by_trigger("entity")
  end, { desc = "Insert Entity template (no frontmatter)" })
end

function M.setup()
  define_markdown_snippets()
  define_commands()
end

return M
