-- core/markdown.lua
-- Markdown snippets and helpers.
-- - Snippets use plain triggers ("fm", "character", "entity", "cb", etc.)
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
    return os.date("%Y-%b-%dT%H:%M:%S") .. "-0600"
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

    -- Front matter extension for Obsidian default frontmatter
    -- Invoke this right after Obsidian generates:
    -- ---
    -- id: unknown
    -- aliases:
    --   - unknown
    -- tags: []
    -- ---
    -- Place cursor on the blank line after 'tags: []' and expand "fm"
    local fm = s({ trig = "fm", name = "Frontmatter (Obsidian modified extension)" }, {
        t({ "", "title: " }),
        i(1, ""),
        t("author: Gallo Chingon"),
        t({ "", "created: " .. created_timestamp() }),
        i(0),
    })

    -- Character template (no frontmatter) - with 3 lines after each h2
    local character = s({ trig = "character", name = "Character template (no frontmatter)" }, {
        t({ "", "" }),
        t("## Psychological Profile"),
        t({ "", "", "", "" }),
        t("## Personal History"),
        t({ "", "", "", "" }),
        t("## Physical Description"),
        t({ "", "", "", "" }),
        t("## Unique Voice, Dialogue Patterns, and Mannerisms"),
        t({ "", "", "", "" }),
        t("## Special Skills, Knowledge, or Abilities"),
        t({ "", "", "", "- " }),
        i(2, "Skill or Ability"),
        t(": "),
        i(3, "short description"),
        t({ "", "- " }),
        i(4, "Skill or Ability"),
        t(": "),
        i(5, "short description"),
        t({ "", "- " }),
        i(6, "Skill or Ability"),
        t(": "),
        i(7, "short description"),
        t({ "", "", "", "" }),
        t("## Behavioral Patterns"),
        t({ "", "", "", "" }),
        t("## Communities, Organizations "),
        i(1),
        t(" belongs to"),
        t({ "", "", "", "" }),
        t("## "),
        rep(1),
        t("'s Hobbies"),
        t({ "", "", "", "" }),
        t("## Dialogue Examples"),
        t({ "", "", "", "" }),
        t("## Story Function and Narrative Purpose"),
        t({ "", "", "", "" }),
        t("## Relationship to other Characters"),
        t({ "", "", "" }),
    })

    -- Entity template (no frontmatter) - with 3 lines after each h2
    local entity = s({ trig = "entity", name = "Entity template (no frontmatter)" }, {
        t("## Overview"),
        t({ "", "", "", "" }),
        t("## Purpose and Goals"),
        t({ "", "", "", "" }),
        t("## Structure and Hierarchy"),
        t({ "", "", "", "" }),
        t("## Key Members or Components"),
        t({ "", "", "", "" }),
        t("## Operations and Methods"),
        t({ "", "", "", "" }),
        t("## Resources and Capabilities"),
        t({ "", "", "", "" }),
        t("## Public vs Private Face"),
        t({ "", "", "", "" }),
        t("## Relationships with Other Entities"),
        t({ "", "", "", "" }),
        t("## Historical Context"),
        t({ "", "", "", "" }),
        t("## Story Function"),
        t({ "", "", "", "" }),
        t("## Relationship to other Characters"),
        t({ "", "", "" }),
    })

    -- Quick helpers
    local cb = s({ trig = "cb", name = "Code block (generic)" }, { t({ "```", "" }), i(0), t({ "", "```" }) })

    -- Optional language-specific code fences
    local function lang_block(lang)
        return s({ trig = lang, name = lang .. " code block" }, {
            t({ "```" .. lang, "" }),
            i(0),
            t({ "", "```" }),
        })
    end

    ls.add_snippets("markdown", {
        fm,
        character,
        entity,
        h2,
        cb,
        lang_block("lua"),
        lang_block("bash"),
        lang_block("zsh"),
        lang_block("nu"),
        lang_block("python"),
        lang_block("toml"),
        lang_block("yaml"),
        lang_block("go"),
        lang_block("json"),
        lang_block("html"),
        lang_block("css"),
        lang_block("sql"),
        lang_block("regex"),
        lang_block("markdown"),
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
