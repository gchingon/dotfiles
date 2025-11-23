-- lua/core/ulid.lua
-- ULID generator + Markdown front matter ensure/merge on first save.

local M = {}

-- ================
-- ULID primitives
-- ================

-- Crockford Base32 alphabet (no I, L, O, U)
local BASE32_CHARS = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

-- Helper to avoid 32-bit bitop by using math
local function extract_bits(value, shift, mask)
    return math.floor(value / (2 ^ shift)) % mask
end

-- Encode timestamp (48 bits) to 10 Base32 characters
local function encode_timestamp(timestamp_ms)
    local chars = {}
    for i = 9, 0, -1 do
        local shift = i * 5
        local index = extract_bits(timestamp_ms, shift, 32) -- 32 = 2^5
        table.insert(chars, BASE32_CHARS:sub(index + 1, index + 1))
    end
    return table.concat(chars)
end

-- Encode randomness (80 bits) to 16 Base32 characters
local function encode_random(random_bytes)
    local chars, value, bits = {}, 0, 0
    for i = 1, #random_bytes do
        value = value * 256 + random_bytes:byte(i)
        bits = bits + 8
        while bits >= 5 do
            bits = bits - 5
            local index = extract_bits(value, bits, 32)
            table.insert(chars, BASE32_CHARS:sub(index + 1, index + 1))
        end
    end
    return table.concat(chars)
end

function M.generate_ulid(timestamp_ms)
    local ts = timestamp_ms or (os.time() * 1000)
    local MAX_TIMESTAMP = 281474976710655
    if ts > MAX_TIMESTAMP then ts = MAX_TIMESTAMP end
    if ts < 0 then ts = 0 end
    local rand_bytes = {}
    for _ = 1, 10 do
        table.insert(rand_bytes, string.char(math.random(0, 255)))
    end
    return encode_timestamp(ts) .. encode_random(table.concat(rand_bytes))
end

-- =====================
-- created parsing + fmt
-- =====================

function M.get_example_date()
    local now = os.date("*t")
    return string.format(
        "%04d-%02d-%02d_%02d:%02d:%02d-0600",
        now.year, now.month, now.day, now.hour, now.min, now.sec
    )
end

-- Parse only:
-- - YYYY-MM-DD_TT:MM:SS[-0600]
-- - YYYY-MM-DD_TT:MM:SS
-- - YYYY-MM-DD_TT:MM:SS-zzzz (ignored, we assume US Central)
-- - Same with underscore instead of 'T': YYYY-MM-DD_HH:MM:SS[-0600]
-- If parsing fails, returns nil.
local function parse_created_to_epoch_ms(created)
    if not created or created == "" then return nil end

    -- Accept either 'T' or '_' delimiter; optional timezone suffix.
    local y, m, d, H, M, S = created:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)[T_](%d%d):(%d%d):(%d%d)")
    if not (y and m and d and H and M and S) then
        return nil
    end

    y, m, d, H, M, S = tonumber(y), tonumber(m), tonumber(d), tonumber(H), tonumber(M), tonumber(S)
    if not (y and m and d and H and M and S) then
        return nil
    end
    if not (m >= 1 and m <= 12 and d >= 1 and d <= 31 and H >= 0 and H <= 23 and M >= 0 and M <= 59 and S >= 0 and S <= 59) then
        return nil
    end

    -- We assume local time already matches US Central; if you want strict CST/CDT, adjust here.
    local t = os.time({ year = y, month = m, day = d, hour = H, min = M, sec = S })
    if not t then return nil end

    -- Add a bit of ms randomness to keep ULIDs unique when saving quickly
    local ms = math.random(0, 999)
    return t * 1000 + ms
end

-- Use 'created' to derive ULID timestamp; fallback to now when missing/invalid.
function M.ulid_from_created_or_now(created)
    local ts_ms = parse_created_to_epoch_ms(created)
    if not ts_ms then
        -- Show a single helpful notification when supplied but invalid
        if created and created ~= "" then
            vim.notify(
                string.format('Date improperly formatted. Expected like: "%s"', M.get_example_date()),
                vim.log.levels.ERROR
            )
        end
        ts_ms = os.time() * 1000
    end
    return M.generate_ulid(ts_ms)
end

-- ==============================
-- Front matter ensure/merge logic
-- ==============================

-- Set to nil to apply to all markdown files. To scope, uncomment and add paths like:
-- local vaults = {
--     vim.fn.expand("$HOME/path/to/markdown/dir"),
--     -- vim.fn.expand("$HOME/another/path"),
-- }
local vaults = {
    vim.fn.expand("$HOME/Documents/notes/content"),
    vim.fn.expand("$HOME/Documents/notes/daily")
}

local function in_vault(filepath)
    if not vaults then return true end
    filepath = vim.fn.fnamemodify(filepath, ":p")
    for _, v in ipairs(vaults) do
        v = vim.fn.fnamemodify(v, ":p")
        if vim.startswith(filepath, v) then
            return true
        end
    end
    return false
end

local function now_created_str()
    return os.date("%Y-%m-%dT%H:%M:%S-0600")
end

-- Parse a simple YAML front matter block of "key: value" lines.
-- Returns map and end index of block (line number of closing ---).
local function parse_frontmatter(lines)
    if lines[1] ~= "---" then
        return nil, 0
    end
    local fm, end_idx = {}, 0
    for i = 2, #lines do
        local line = lines[i]
        if line == "---" then
            end_idx = i
            break
        end
        local key, value = line:match("^([%w_%-%[%]]+):%s*(.*)$")
        if key and value then
            -- Keep tags: [] literally if present; otherwise store as string
            fm[key] = vim.trim(value)
        end
    end
    if end_idx == 0 then
        return nil, 0
    end
    return fm, end_idx
end

-- Merge rules:
-- - id: if missing/blank => generate via ULID(created)
-- - created: if missing/blank => now in YYYY-MM-DD_HH:MM:SS-0600
-- - author: if missing/blank => "Gallo Chingon"
-- - source/status/topic/type: ensure keys exist (empty value if missing)
-- - tags: ensure exists; if missing => "[]"
local function merge_frontmatter(existing)
    local fm = {}
    for k, v in pairs(existing or {}) do
        fm[k] = v
    end

    -- Normalize empties
    local function is_blank(v)
        return v == nil or (type(v) == "string" and vim.trim(v) == "")
    end

    if is_blank(fm.created) then
        fm.created = now_created_str()
    end

    if is_blank(fm.id) then
        fm.id = M.ulid_from_created_or_now(fm.created)
    end

    if is_blank(fm.author) then
        fm.author = "Gallo Chingon"
    end

    if fm.tags == nil or is_blank(fm.tags) then
        fm.tags = "[]"
    end

    if is_blank(fm.source) then fm.source = "" end
    if is_blank(fm.status) then fm.status = "" end
    if is_blank(fm.topic)  then fm.topic  = "" end
    if is_blank(fm.type)   then fm.type   = "" end

    return fm
end

-- Build FM lines with fixed order first, then extras alphabetically.
local FIXED_ORDER = { "id", "created", "author", "source", "status", "tags", "topic", "type" }

local function build_frontmatter_lines(fm)
    local out = { "---" }

    -- Fixed ordered keys
    for _, key in ipairs(FIXED_ORDER) do
        local v = fm[key]
        if v ~= nil then
            table.insert(out, string.format("%s: %s", key, v))
        end
    end

    -- Extras (deterministic)
    local extras = {}
    for k, v in pairs(fm) do
        local fixed = false
        for _, fk in ipairs(FIXED_ORDER) do
            if k == fk then fixed = true; break end
        end
        if not fixed then
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

local function inject_or_update_frontmatter(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == "" or not in_vault(path) then
        return
    end

    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local head = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(200, line_count), false)
    local existing, end_idx = parse_frontmatter(head)

    if not existing then
        -- No FM: create new ordered block
        local fm = merge_frontmatter({})
        local fm_lines = build_frontmatter_lines(fm)
        vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, fm_lines)
        -- Ensure a blank line after front matter if content starts immediately
        local after = vim.api.nvim_buf_get_lines(bufnr, #fm_lines, #fm_lines + 1, false)[1]
        if after and vim.trim(after) ~= "" then
            vim.api.nvim_buf_set_lines(bufnr, #fm_lines, #fm_lines, false, { "" })
        end
        return
    end

    -- Merge and rewrite, preserving extras and reordering to fixed order first
    local merged = merge_frontmatter(existing)
    local fm_lines = build_frontmatter_lines(merged)
    vim.api.nvim_buf_set_lines(bufnr, 0, end_idx, false, fm_lines)
end

-- Public: set up BufWritePre hook for Markdown files
function M.setup()
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("ULIDFrontmatterEnsure", { clear = true }),
        pattern = { "*.md", "*.markdown", "*.mdx" },
        callback = function(args)
            if vim.bo[args.buf].filetype ~= "markdown" then
                return
            end
            inject_or_update_frontmatter(args.buf)
        end,
        desc = "Ensure and order YAML front matter; generate ULID from created",
    })
end

return M
