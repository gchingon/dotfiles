-- lua/core/frontmatter.lua
-- Unified front matter: detect context from ancestor dirs, apply correct template.

local M = {}

-- =============================
-- Base58 ID
-- =============================
local BASE58 = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

local function to_base58(n, width)
    if n == 0 then
        return string.rep(BASE58:sub(1, 1), width)
    end

    local chars = {}
    while n > 0 do
        local rem = n % 58
        table.insert(chars, 1, BASE58:sub(rem + 1, rem + 1))
        n = math.floor(n / 58)
    end

    while #chars < width do
        table.insert(chars, 1, BASE58:sub(1, 1))
    end

    return table.concat(chars)
end

function M.generate_id(epoch_s)
    local ts = epoch_s or os.time()
    return to_base58(ts, 6)
end

-- =============================
-- Timestamp helpers
-- =============================

local function now_iso()
    return os.date("%Y-%m-%dT%H:%M:%S-0600")
end

local function now_podcast()
    return os.date("%Y-%m-%d_%H:%M:%S")
end

local function now_date()
    return os.date("%Y-%m-%d")
end

function M.get_example_date()
    local now = os.date("*t")
    return string.format(
        "%04d-%02d-%02d_%02d:%02d:%02d",
        now.year, now.month, now.day, now.hour, now.min, now.sec
    )
end

local function parse_created_to_epoch(created)
    if not created or created == "" then return nil end
    local y, mo, d, H, Mi, S = created:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)[T_](%d%d):(%d%d):(%d%d)")
    if not y then
        -- Try date-only: YYYY-MM-DD
        y, mo, d = created:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
        H, Mi, S = "0", "0", "0"
    end
    if not (y and mo and d) then return nil end
    y, mo, d, H, Mi, S = tonumber(y), tonumber(mo), tonumber(d), tonumber(H), tonumber(Mi), tonumber(S)
    if not (y and mo and d and H and Mi and S) then return nil end
    if not (mo >= 1 and mo <= 12 and d >= 1 and d <= 31) then return nil end
    return os.time({ year = y, month = mo, day = d, hour = H, min = Mi, sec = S })
end

function M.id_from_created_or_now(created)
    local ts = parse_created_to_epoch(created)
    if not ts then
        if created and created ~= "" then
            vim.notify(
                string.format('Date improperly formatted. Expected like: "%s"', M.get_example_date()),
                vim.log.levels.ERROR
            )
        end
        ts = os.time()
    end
    return M.generate_id(ts)
end

-- =============================
-- Path classification
-- =============================

-- Returns ancestor dir components from filename upward.
-- e.g. /a/b/c/d/file.md → {"d","c","b","a"}
local function ancestor_parts(filepath)
    filepath = vim.fn.fnamemodify(filepath, ":p")
    local segs = {}
    for s in filepath:gmatch("[^/]+") do
        table.insert(segs, s)
    end
    -- Remove filename, reverse so [1]=parent, [2]=grandparent, etc.
    table.remove(segs) -- drop filename
    local rev = {}
    for i = #segs, 1, -1 do
        table.insert(rev, segs[i])
    end
    return rev, segs
end

local function find_ancestor_index(segs, segment)
    for i, seg in ipairs(segs) do
        if seg == segment then
            return i
        end
    end
    return nil
end

local function has_hugo_config(filepath)
    local dir = vim.fn.fnamemodify(filepath, ":p:h")
    return vim.fn.findfile("hugo.toml", dir .. ";") ~= ""
        or vim.fn.findfile("config.toml", dir .. ";") ~= ""
        or vim.fn.findfile("hugo.yaml", dir .. ";") ~= ""
        or vim.fn.findfile("config.yaml", dir .. ";") ~= ""
        or vim.fn.findfile("hugo.yml", dir .. ";") ~= ""
        or vim.fn.findfile("config.yml", dir .. ";") ~= ""
end

-- Does this segment look like a domain? e.g. "tokyo.dev", "gallochingon.com"
local function is_domain(segment)
    return segment:match("^[%w][%w%-]*%.[%a][%a]%a?%a?$") ~= nil
end

-- Hugo subtype: look for content/{featured,episodes,blog} in full path
local HUGO_SUBTYPES = { featured = true, episodes = true, blog = true }

local function detect_hugo_subtype(forward_segs, filepath)
    local content_idx = find_ancestor_index(forward_segs, "content")
    if not content_idx then
        return "blog"
    end

    local next_seg = forward_segs[content_idx + 1]
    local filename = vim.fn.fnamemodify(filepath or "", ":t")

    if filename == "_index.md" or filename == "_index.markdown" or filename == "_index.mdx" then
        return "index"
    end

    if next_seg and HUGO_SUBTYPES[next_seg] then
        return next_seg
    end
    return "blog" -- sensible default for content/ without recognized subtype
end

--- Classify a filepath into { context, subtype }.
--- Checks up to 4 ancestor dirs (parent → great-great-grandparent).
---
--- Returns:
---   "hugo"    + subtype ("featured"|"episodes"|"blog")
---   "podcast" + nil
---   "notes"   + nil
---   nil       (no match → don't touch the file)
function M.classify(filepath)
    if not filepath or filepath == "" then return nil end
    filepath = vim.fn.fnamemodify(filepath, ":p")

    local ancestors, forward_segs = ancestor_parts(filepath)
    local depth = math.min(4, #ancestors)

    if has_hugo_config(filepath) then
        return "hugo", detect_hugo_subtype(forward_segs, filepath)
    end

    for i = 1, depth do
        local seg = ancestors[i]

        -- Domain-bearing dir → Hugo site
        if is_domain(seg) then
            return "hugo", detect_hugo_subtype(forward_segs, filepath)
        end

        if seg == "podcast" then
            return "podcast", nil
        end
    end

    -- Catch-all known dirs for notes context
    local NOTES_DIRS = {
        notes = true, daily = true, ideas = true,
        content = true, repos = true, Documents = true,
    }
    for i = 1, depth do
        if NOTES_DIRS[ancestors[i]] then
            return "notes", nil
        end
    end

    return nil
end

-- =============================
-- Template definitions
-- =============================
-- Each entry: { key, default_value }
-- default = nil  →  filled dynamically (created, id)
-- default = ""   →  placeholder empty
-- Ordering here IS the output order.

local TEMPLATES = {}

-- ── Notes (simple) ──────────────────────────────────
TEMPLATES.notes = {
    { "id",      nil },
    { "created", nil },
    { "author",  "Gallo Chingon" },
    { "tags",    "[]"},
}

TEMPLATES["hugo:index"] = TEMPLATES.notes

-- ── Podcast ─────────────────────────────────────────
TEMPLATES.podcast = {
    { "id",            nil },
    { "title",         '""' },
    { "created",       nil },
    { "tags",          "[]" },
    { "concepts",      "[]" },
    { "bypass_shorts", "false" },
}

-- ── Hugo: featured ──────────────────────────────────
TEMPLATES["hugo:featured"] = {
    { "title",              '""' },
    { "created",            nil },
    { "updated",            '""' },
    { "draft",              "false" },
    { "type",               '""' },
    { "podcastName",        '""' },
    { "hosts",              "[]" },
    { "guests",             "[]" },
    { "externalUrl",        '""' },
    { "featuredImage",      '""' },
    { "tags",               "[]" },
    { "summary",            '""' },
    { "description",        '""' },
    { "overlayMetadata",    "true" },
    { "overlayPosition",    '"lower-left"' },
    { "transparency",       "true" },
    { "transparencyAmount", "0.7" },
    { "topicsOn",           "true" },
    { "toc",                "false" },
    { "lightgallery",       "true" },
}

-- ── Hugo: episodes ──────────────────────────────────
TEMPLATES["hugo:episodes"] = {
    { "title",              '""' },
    { "created",            nil },
    { "updated",            '""' },
    { "draft",              "false" },
    { "episodeNumber",      '""' },
    { "season",             '""' },
    { "episodeType",        '"full"' },
    { "podcast",            '""' },
    { "host",               '""' },
    { "guests",             "[]" },
    { "featuredImage",      '""' },
    { "duration",           '""' },
    { "tags",               "[]" },
    { "summary",            '""' },
    { "description",        '""' },
    { "embedPlayers",       "[]" },
    { "overlayMetadata",    "true" },
    { "overlayPosition",    '"lower-center"' },
    { "transparency",       "true" },
    { "transparencyAmount", "0.7" },
    { "topicsOn",           "true" },
    { "toc",                "true" },
    { "lightgallery",       "true" },
}

-- ── Hugo: blog ──────────────────────────────────────
TEMPLATES["hugo:blog"] = {
    { "title",         '""' },
    { "created",       nil },
    { "updated",       '""' },
    { "draft",         "false" },
    { "featuredImage",  '""' },
    { "tags",          "[]" },
    { "summary",       '""' },
    { "description",   '""' },
    { "toc",           "true" },
    { "lightgallery",  "true" },
}

-- Resolve the right template key from context + subtype
local function template_key(context, subtype)
    if context == "hugo" and subtype then
        return "hugo:" .. subtype
    end
    return context -- "notes" or "podcast"
end

-- =============================
-- FM parsing (shared)
-- =============================

local function should_use_toml_frontmatter(delimiter, body_lines)
    if delimiter == "+++" then
        return true
    end

    for _, line in ipairs(body_lines or {}) do
        if line:match("^%s*%[.*%]%s*$") or line:match("^[%w_%-]+%s*=") then
            return true
        end
    end

    return false
end

local function parse_frontmatter(lines)
    if not lines or #lines == 0 or (lines[1] ~= "---" and lines[1] ~= "+++") then
        return nil, 0
    end

    local delimiter = lines[1]
    local fm, passthrough, body_lines, end_idx = {}, {}, {}, 0
    for i = 2, #lines do
        if lines[i] == delimiter then
            end_idx = i
            break
        end

        table.insert(body_lines, lines[i])

        local yaml_key, yaml_value = lines[i]:match("^([%w_%-%[%]]+):%s*(.*)$")
        local toml_key, toml_value = lines[i]:match("^([%w_%-]+)%s*=%s*(.*)$")
        if yaml_key and yaml_value then
            fm[yaml_key] = vim.trim(yaml_value)
        elseif toml_key and toml_value then
            fm[toml_key] = vim.trim(toml_value)
        else
            table.insert(passthrough, lines[i])
        end
    end

    if end_idx == 0 then return nil, 0 end
    fm.__passthrough = passthrough
    fm.__delimiter = should_use_toml_frontmatter(delimiter, body_lines) and "+++" or delimiter
    return fm, end_idx
end

-- =============================
-- FM merging (shared)
-- =============================

local function is_blank(v)
    return v == nil or (type(v) == "string" and vim.trim(v) == "")
end

local function merge_frontmatter(existing, context, subtype)
    local key = template_key(context, subtype)
    local tpl = TEMPLATES[key]
    if not tpl then return existing end

    local fm = {}
    for k, v in pairs(existing or {}) do
        if type(k) ~= "string" or k:sub(1, 2) ~= "__" then
            fm[k] = v
        end
    end
    fm.__passthrough = existing and existing.__passthrough or {}
    fm.__delimiter = existing and existing.__delimiter or "---"

    -- Whether this template uses an id field
    local needs_id = false
    for _, field in ipairs(tpl) do
        if field[1] == "id" then
            needs_id = true
            break
        end
    end

    for _, field in ipairs(tpl) do
        local fname, default = field[1], field[2]

        if fname == "created" and is_blank(fm.created) then
            if context == "podcast" then
                fm.created = now_podcast()
            else
                fm.created = now_iso()
            end
        elseif fname == "updated" then
            -- Don't overwrite updated with empty on every save;
            -- only ensure the key exists
            if fm.updated == nil then fm.updated = "" end
        elseif fname == "id" and needs_id and is_blank(fm.id) then
            fm.id = M.id_from_created_or_now(fm.created)
        elseif is_blank(fm[fname]) and default ~= nil then
            fm[fname] = default
        end
    end

    return fm
end

-- =============================
-- FM building (shared)
-- =============================

local function toml_value(value)
    local v = vim.trim(tostring(value or ""))
    if v == "" then
        return '""'
    end
    if v:match('^".*"$') or v:match("^'.*'$") then
        return v
    end
    if v:match("^%[.*%]$") or v:match("^{.*}$") then
        return v
    end
    if v == "true" or v == "false" then
        return v
    end
    if tonumber(v) ~= nil then
        return v
    end
    return string.format("%q", v)
end

local function frontmatter_line(delimiter, key, value)
    if delimiter == "+++" then
        return string.format("%s = %s", key, toml_value(value))
    end
    return string.format("%s: %s", key, value)
end

local function build_frontmatter_lines(fm, context, subtype)
    local key = template_key(context, subtype)
    local tpl = TEMPLATES[key]
    if not tpl then return { "---", "---" } end

    local delimiter = fm.__delimiter or "---"
    local out = { delimiter }
    local used = {}
    local hard_keys = { "id", "created", "author", "tags" }

    -- Hard-set keys first.
    for _, fname in ipairs(hard_keys) do
        if fm[fname] ~= nil then
            table.insert(out, frontmatter_line(delimiter, fname, fm[fname]))
            used[fname] = true
        end
    end

    -- Every other root key alphabetically.
    local extras = {}
    for k, v in pairs(fm) do
        if type(k) ~= "string" or (k:sub(1, 2) ~= "__" and not used[k]) then
            table.insert(extras, { k, v })
        end
    end
    table.sort(extras, function(a, b) return a[1] < b[1] end)
    for _, kv in ipairs(extras) do
        table.insert(out, frontmatter_line(delimiter, kv[1], kv[2]))
    end

    -- Preserve table blocks, arrays of tables, comments, blanks, and other body lines exactly.
    for _, line in ipairs(fm.__passthrough or {}) do
        table.insert(out, line)
    end

    table.insert(out, delimiter)
    return out
end

-- =============================
-- Injection
-- =============================

local function inject_or_update(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == "" then return end

    local context, subtype = M.classify(path)
    if not context then return end

    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local head = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(200, line_count), false)
    local existing, end_idx = parse_frontmatter(head)

    if not existing then
        local fm = merge_frontmatter({}, context, subtype)
        local lines = build_frontmatter_lines(fm, context, subtype)
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)
        local after = vim.api.nvim_buf_get_lines(bufnr, #lines, #lines + 1, false)[1]
        if after and vim.trim(after) ~= "" then
            vim.api.nvim_buf_set_lines(bufnr, #lines, #lines, false, { "" })
        end
        return
    end

    local merged = merge_frontmatter(existing, context, subtype)
    local lines = build_frontmatter_lines(merged, context, subtype)
    vim.api.nvim_buf_set_lines(bufnr, 0, end_idx, false, lines)
end

-- =============================
-- Setup
-- =============================

function M.setup()
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("UnifiedFrontmatter", { clear = true }),
        pattern = { "*.md", "*.markdown", "*.mdx" },
        callback = function(args)
            if vim.bo[args.buf].filetype ~= "markdown" then return end
            inject_or_update(args.buf)
        end,
        desc = "Unified front matter: route by ancestor dir → hugo/podcast/notes template",
    })
end

return M
