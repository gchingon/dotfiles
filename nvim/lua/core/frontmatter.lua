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

-- Does this segment look like a domain? e.g. "tokyo.dev", "gallochingon.com"
local function is_domain(segment)
    return segment:match("^[%w][%w%-]*%.[%a][%a]%a?%a?$") ~= nil
end

-- Hugo subtype: look for content/{featured,episodes,blog} in full path
local HUGO_SUBTYPES = { featured = true, episodes = true, blog = true }

local function detect_hugo_subtype(forward_segs)
    for i = 1, #forward_segs - 1 do
        if forward_segs[i] == "content" and HUGO_SUBTYPES[forward_segs[i + 1]] then
            return forward_segs[i + 1]
        end
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

    for i = 1, depth do
        local seg = ancestors[i]

        -- Domain-bearing dir → Hugo site
        if is_domain(seg) then
            return "hugo", detect_hugo_subtype(forward_segs)
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
}

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

local function parse_frontmatter(lines)
    if not lines or #lines == 0 or lines[1] ~= "---" then
        return nil, 0
    end
    local fm, end_idx = {}, 0
    for i = 2, #lines do
        if lines[i] == "---" then
            end_idx = i
            break
        end
        local key, value = lines[i]:match("^([%w_%-%[%]]+):%s*(.*)$")
        if key and value then
            fm[key] = vim.trim(value)
        end
    end
    if end_idx == 0 then return nil, 0 end
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
    for k, v in pairs(existing or {}) do fm[k] = v end

    -- Whether this template uses an id field
    local needs_id = (context == "notes" or context == "podcast")

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

local function build_frontmatter_lines(fm, context, subtype)
    local key = template_key(context, subtype)
    local tpl = TEMPLATES[key]
    if not tpl then return { "---", "---" } end

    local out = { "---" }
    local used = {}

    -- Template-ordered keys first
    for _, field in ipairs(tpl) do
        local fname = field[1]
        if fm[fname] ~= nil then
            table.insert(out, string.format("%s: %s", fname, fm[fname]))
            used[fname] = true
        end
    end

    -- Extras alphabetically
    local extras = {}
    for k, v in pairs(fm) do
        if not used[k] then
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
