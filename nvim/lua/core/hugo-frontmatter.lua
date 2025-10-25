-- lua/core/hugo-frontmatter.lua
-- Auto-generate Hugo front matter for markdown files in ~/*/content/ directories

local M = {}

-- ==============================
-- Content type detection
-- ==============================

local CONTENT_TYPES = {
    featured = "featured",
    episodes = "episodes",
    blog = "blog",
}

-- Check if filepath is in a Hugo content directory
local function detect_content_type(filepath)
    if not filepath or filepath == "" then
        return nil
    end

    filepath = vim.fn.fnamemodify(filepath, ":p")
    local home = vim.fn.expand("$HOME")

    -- Check for ~/*/content/{featured,episodes,blog}/ pattern
    for _, ctype in pairs(CONTENT_TYPES) do
        local pattern = home .. "/[^/]+/content/" .. ctype .. "/"
        if filepath:match(vim.pesc(pattern):gsub("%[%^/%]%+", "[^/]+")) then
            return ctype
        end
    end

    return nil
end

-- ==============================
-- Timestamp generation
-- ==============================

local function now_created_str()
    return os.date("%Y-%m-%d_%H:%M:%S-0600")
end

-- ==============================
-- Front matter templates
-- ==============================

local function get_template_fields(content_type)
    if content_type == "featured" then
        return {
            { "title", '""' },
            { "created", nil },  -- will be filled by now_created_str()
            { "updated", '""' },
            { "draft", "false" },
            { "type", '""' },
            { "podcastName", '""' },
            { "hosts", "[]" },
            { "guests", "[]" },
            { "externalUrl", '""' },
            { "featuredImage", '""' },
            { "tags", "[]" },
            { "summary", '""' },
            { "description", '""' },
            { "overlayMetadata", "true" },
            { "overlayPosition", '"lower-left"' },
            { "transparency", "true" },
            { "transparencyAmount", "0.7" },
            { "topicsOn", "true" },
            { "toc", "false" },
            { "lightgallery", "true" },
        }
    elseif content_type == "episodes" then
        return {
            { "title", '""' },
            { "created", nil },
            { "updated", '""' },
            { "draft", "false" },
            { "episodeNumber", '""' },
            { "season", '""' },
            { "episodeType", '"full"' },
            { "podcast", '""' },
            { "host", '""' },
            { "guests", "[]" },
            { "featuredImage", '""' },
            { "duration", '""' },
            { "tags", "[]" },
            { "summary", '""' },
            { "description", '""' },
            { "embedPlayers", "[]" },
            { "overlayMetadata", "true" },
            { "overlayPosition", '"lower-center"' },
            { "transparency", "true" },
            { "transparencyAmount", "0.7" },
            { "topicsOn", "true" },
            { "toc", "true" },
            { "lightgallery", "true" },
        }
    elseif content_type == "blog" then
        return {
            { "title", '""' },
            { "created", nil },
            { "updated", '""' },
            { "draft", "false" },
            { "featuredImage", '""' },
            { "tags", "[]" },
            { "summary", '""' },
            { "description", '""' },
            { "toc", "true" },
            { "lightgallery", "true" },
        }
    end

    return nil
end

-- ==============================
-- Front matter parsing
-- ==============================

-- Parse YAML front matter block
-- Returns map of keys/values and end line index
local function parse_frontmatter(lines)
    if not lines or #lines == 0 or lines[1] ~= "---" then
        return nil, 0
    end

    local fm, end_idx = {}, 0
    for i = 2, #lines do
        local line = lines[i]
        if line == "---" then
            end_idx = i
            break
        end

        -- Parse key: value pairs
        local key, value = line:match("^([%w_%-%[%]]+):%s*(.*)$")
        if key and value then
            fm[key] = vim.trim(value)
        end
    end

    if end_idx == 0 then
        return nil, 0
    end

    return fm, end_idx
end

-- ==============================
-- Front matter merging
-- ==============================

local function merge_frontmatter(existing, content_type)
    local template = get_template_fields(content_type)
    if not template then
        return existing
    end

    local fm = {}

    -- Start with existing values
    for k, v in pairs(existing or {}) do
        fm[k] = v
    end

    -- Helper to check if value is blank
    local function is_blank(v)
        return v == nil or (type(v) == "string" and vim.trim(v) == "")
    end

    -- Merge template fields
    for _, field_def in ipairs(template) do
        local key, default_val = field_def[1], field_def[2]

        -- Special handling for created field
        if key == "created" and is_blank(fm[key]) then
            fm[key] = now_created_str()
        elseif is_blank(fm[key]) and default_val ~= nil then
            -- Only set default if field is missing/blank
            fm[key] = default_val
        end
    end

    return fm
end

-- ==============================
-- Front matter building
-- ==============================

local function build_frontmatter_lines(fm, content_type)
    local template = get_template_fields(content_type)
    if not template then
        return { "---", "---" }
    end

    local out = { "---" }
    local used_keys = {}

    -- Add fields in template order
    for _, field_def in ipairs(template) do
        local key = field_def[1]
        local value = fm[key]

        if value ~= nil then
            table.insert(out, string.format("%s: %s", key, value))
            used_keys[key] = true
        end
    end

    -- Add any extra fields not in template (alphabetically)
    local extras = {}
    for k, v in pairs(fm) do
        if not used_keys[k] then
            table.insert(extras, { k, v })
        end
    end

    table.sort(extras, function(a, b) return a[1] < b[1] end)
    for _, kv in ipairs(extras) do
        table.insert(out, string.format("%s: %s", kv[1], kv[2]))
    end

    table.insert(out, "---")
    return out
end

-- ==============================
-- Main injection logic
-- ==============================

local function inject_or_update_frontmatter(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == "" then
        return
    end

    local content_type = detect_content_type(path)
    if not content_type then
        return
    end

    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local head = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(200, line_count), false)
    local existing, end_idx = parse_frontmatter(head)

    if not existing then
        -- No front matter: create new
        local fm = merge_frontmatter({}, content_type)
        local fm_lines = build_frontmatter_lines(fm, content_type)
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, fm_lines)

        -- Ensure blank line after front matter
        local after = vim.api.nvim_buf_get_lines(bufnr, #fm_lines, #fm_lines + 1, false)[1]
        if after and vim.trim(after) ~= "" then
            vim.api.nvim_buf_set_lines(bufnr, #fm_lines, #fm_lines, false, { "" })
        end
        return
    end

    -- Merge and update existing front matter
    local merged = merge_frontmatter(existing, content_type)
    local fm_lines = build_frontmatter_lines(merged, content_type)
    vim.api.nvim_buf_set_lines(bufnr, 0, end_idx, false, fm_lines)
end

-- ==============================
-- Setup autocmd
-- ==============================

function M.setup()
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("HugoFrontmatterEnsure", { clear = true }),
        pattern = { "*.md", "*.markdown", "*.mdx" },
        callback = function(args)
            if vim.bo[args.buf].filetype ~= "markdown" then
                return
            end
            inject_or_update_frontmatter(args.buf)
        end,
        desc = "Auto-generate Hugo front matter for content/ directories",
    })
end

return M
