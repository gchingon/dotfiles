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
    },
    sources = {
        default = { "lsp", "path", "snippets", "buffer", "emoji" }, -- enable dictionary later if desired
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
                    -- Check if we have a semicolon followed by word characters at the cursor position
                    return before_cursor:match(";" .. "[_%w%-]*$") ~= nil
                end,

                -- Replace the entire ";trigger" region with the snippet body on accept
                transform_items = function(_, items)
                    local line = vim.api.nvim_get_current_line()
                    local row, col = unpack(vim.api.nvim_win_get_cursor(0)) -- row 1-based, col 0-based
                    local before_cursor = line:sub(1, col)

                    -- Find the semicolon and trigger pattern
                    local semicolon_start = before_cursor:find(";[_%w%-]*$")
                    if not semicolon_start then
                        return items
                    end

                    -- Calculate the range to replace (0-based for LSP)
                    local start_col0 = semicolon_start - 1  -- Convert to 0-based
                    local end_col0 = col  -- Current cursor position is already 0-based

                    for _, item in ipairs(items) do
                        if not item.trigger_text_modified then
                            item.trigger_text_modified = true
                            -- Create a textEdit that replaces the ";trigger" with the snippet content
                            item.textEdit = {
                                newText = item.insertText or item.label,
                                range = {
                                    start = { line = row - 1, character = start_col0 },
                                    ["end"] = { line = row - 1, character = end_col0 },
                                },
                            }
                        end
                    end
                    return items
                end,
            },
            emoji = {
                module = "blink-emoji",
                name = "Emoji",
                score_offset = 93,
                min_keyword_length = 2,
                opts = { insert = true },
            },

            -- Re-enable dictionary later if desired. Requires 'nvim-lua/plenary.nvim'.
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