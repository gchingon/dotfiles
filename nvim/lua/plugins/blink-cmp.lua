-- ~/.config/nvim/lua/plugins/blink-cmp.lua
-- Blink completion with a semicolon gate for snippets.
-- Shows snippets only when ";" immediately precedes the word (e.g., ";fm"),
-- and replaces that exact typed region with the snippet expansion.

local ok, blink = pcall(require, "blink.cmp")
if not ok then
    vim.notify("blink.cmp not found", vim.log.levels.WARN)
    return
end

local trigger_text = ";" -- gate character before snippet triggers

blink.setup({
    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
    },
    keymap = {
        preset = "default",
        ["<Tab>"]   = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },

        ["<Up>"]    = { "select_prev", "fallback" },
        ["<Down>"]  = { "select_next", "fallback" },
        ["<C-p>"]   = { "select_prev", "fallback" },
        ["<C-n>"]   = { "select_next", "fallback" },

        ["<S-k>"]   = { "scroll_documentation_up", "fallback" },
        ["<S-j>"]   = { "scroll_documentation_down", "fallback" },

        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"]     = { "hide", "fallback" },

        -- Accept completion with <C-y> (removes semicolon for snippets)
        ["<C-y>"] = {
            function(cmp)
                local selected = cmp.get_selected_item()
                local is_snippet = selected and selected.kind == require('blink.cmp.types').CompletionItemKind.Snippet

                -- Capture current state before accepting
                local line = vim.api.nvim_get_current_line()
                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                local before_cursor = line:sub(1, col)
                local semi_pos = before_cursor:find(";[_%w%-]+$")

                -- Accept the completion first
                local result = cmp.select_and_accept()

                -- Then schedule semicolon removal after completion machinery finishes
                if is_snippet and semi_pos then
                    vim.schedule(function()
                        local current_line = vim.api.nvim_get_current_line()
                        -- Find and remove the semicolon that was left behind
                        local updated_line = current_line:gsub(";", "", 1)
                        if updated_line ~= current_line then
                            vim.api.nvim_set_current_line(updated_line)
                        end
                    end)
                end

                return result
            end,
            "fallback",
        },

        -- LuaSnip choice node navigation
        ["<C-l>"] = {
            function()
                local ls = require("luasnip")
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end,
        },
    },
    sources = {
        default = { "lsp", "path", "snippets", "buffer", "dictionary", "emoji" },
        providers = {
            lsp = {
                name = "lsp",
                enabled = true,
                module = "blink.cmp.sources.lsp",
                min_keyword_length = 1,
                score_offset = 90,
            },
            path = {
                name = "Path",
                module = "blink.cmp.sources.path",
                score_offset = 25,
                fallbacks = { "snippets", "buffer" },
                opts = {
                    trailing_slash = false,
                    label_trailing_slash = true,
                    get_cwd = function(context)
                        return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
                    end,
                    show_hidden_files_by_default = true,
                },
            },
            buffer = {
                name = "Buffer",
                enabled = true,
                max_items = 3,
                module = "blink.cmp.sources.buffer",
                min_keyword_length = 2,
                score_offset = 15,
            },
            snippets = {
                name = "snippets",
                enabled = true,
                max_items = 15,
                min_keyword_length = 2,
                module = "blink.cmp.sources.snippets",
                score_offset = 85,

                -- Only show snippets if there's a ";" immediately before the trigger word
                should_show_items = function()
                    local line = vim.api.nvim_get_current_line()
                    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                    local before_cursor = line:sub(1, col)
                    return before_cursor:match(";[_%w%-]+$") ~= nil
                end,
            },
            emoji = {
                module = "blink-emoji",
                name = "Emoji",
                score_offset = 93,
                min_keyword_length = 2,
                opts = { insert = true },
            },

            dictionary = {
                module = "blink-cmp-dictionary",
                name = "Dict",
                enabled = true,
                max_items = 8,
                min_keyword_length = 3,
                score_offset = 20,
                opts = {
                    dictionary_directories = {},
                    dictionary_files = {
                        vim.fn.expand("~/.config/nvim/dictionary/words.txt"),
                    },
                },
            },
        },
    },
    completion = {
        menu = { border = "single" },
        documentation = {
            auto_show = true,
            window = { border = "single" },
        },
    },
    cmdline = { enabled = true },
    snippets = { preset = "luasnip" },
})

