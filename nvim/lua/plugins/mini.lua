-- ~/.config/nvim/lua/plugins/mini.lua

-- Helper function for safe plugin loading
local function setup_plugin(name, config_func)
    local ok, plugin = pcall(require, name)
    if ok then
        config_func(plugin)
    else
        vim.notify("Plugin not found: " .. name, vim.log.levels.WARN)
    end
end

-- mini.basics
setup_plugin("mini.basics", function(p)
    p.setup()
end)

-- mini.trailspace
setup_plugin("mini.trailspace", function(p)
    p.setup()
end)

-- mini.pairs
setup_plugin("mini.pairs", function(p)
    p.setup({})
end)

-- mini.files (fixed)
setup_plugin("mini.files", function(p)
    p.setup({
        windows = {
            preview = true,
            width_focus = 40,
            width_nofocus = 25,
            width_preview = 60,
        },
        -- In-buffer mappings used inside MiniFiles window
        mappings = {
            go_in = "l",
            go_in_plus = "L",
            go_out = "h",
            go_out_plus = "H",
            close = "q",
            reset = "<BS>",
            reveal_cwd = "@",
            show_help = "g?",
            synchronize = "s", -- added: sync with current working directory
        },
        options = {
            use_as_default_explorer = false,
        },
    })

    local MiniFiles = require("mini.files")

    -- Smart open helper
    local function open_mini_files_smart()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local dir_name = (buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":p:h")) or nil

        if buf_name ~= "" and vim.fn.filereadable(buf_name) == 1 then
            -- Open directory with the file focused
            MiniFiles.open(buf_name, true)
        elseif dir_name and vim.fn.isdirectory(dir_name) == 1 then
            MiniFiles.open(dir_name, true)
        else
            MiniFiles.open(vim.uv.cwd(), true)
        end
    end

    -- Toggle: close if already open in this tab, otherwise smart-open
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

    -- Global mappings to open/toggle
    vim.keymap.set("n", "<leader>e", toggle_mini_files, {
        desc = "MiniFiles: Toggle (smart open)",
        silent = true,
    })
    vim.keymap.set("n", "<leader>E", open_cwd, {
        desc = "MiniFiles: Open CWD",
        silent = true,
    })

    -- Optional: pin target window when opening files from the list
    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionOpen",
        callback = function(ev)
            if ev.data and ev.data.from == "files" then
                MiniFiles.set_target_window("current")
            end
        end,
    })
end)

-- mini.ai
setup_plugin("mini.ai", function(p)
    p.setup({ n_lines = 500 })
end)

-- mini.surround
setup_plugin("mini.surround", function(p)
    p.setup({
        mappings = {
            add = "<leader>ga",
            delete = "<leader>gd",
            find = "<leader>gf",
            find_left = "<leader>gF",
            highlight = "<leader>gh",
            replace = "<leader>gr",
            update_n_lines = "<leader>gn",
            add_visual = "<leader>gs",
            suffix_last = "<leader>gl",
            suffix_next = "<leader>gn",
        },
        n_lines = 50,
        respect_selection_type = true,
        search_method = "cover",
    })
end)

-- mini.tabline
setup_plugin("mini.tabline", function(p)
    p.setup({ show_icons = true })
end)

-- mini.statusline
setup_plugin("mini.statusline", function(p)
    p.setup()
end)

-- mini.hipatterns with callout highlighting
setup_plugin("mini.hipatterns", function(hipatterns)
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

    for word, group in pairs(callout_map) do
        table.insert(highlighters, { pattern = wpat(word), group = group })
    end

    hipatterns.setup({ highlighters = highlighters })
end)
