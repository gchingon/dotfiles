-- ---
-- obsidian.nvim
-- ---
-- Helper function for safe plugin loading
local function setup_plugin(name, config_func)
  local ok, plugin = pcall(require, name)
  if ok then
    config_func(plugin)
  else
    vim.notify("Plugin not found: " .. name, vim.log.levels.WARN)
  end
end

local ulid_from_created_or_now = require("core.ulid").ulid_from_created_or_now

setup_plugin("obsidian", function(obsidian)
  obsidian.setup({
    workspaces = {
      {
        name = "notes",
        path = "$HOME/Documents/notes",
      },
      {
        name = "novel",
        path = "$HOME/Documents/widows-club",
      },
      {
        name = "no-vault",
        path = function()
          return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
        end,
        overrides = {
          notes_subdir = vim.NIL,
          new_notes_location = "current_dir",
          templates = { folder = vim.NIL },
          disable_frontmatter = false,
        },
      },
    },
    completion = { blink = true, min_chars = 2 },
    new_notes_location = "current_dir",
    legacy_commands = false,

    -- ULID for note IDs; backdated by strict created if present
    -- Simple ID generation - frontmatter function handles persistence
    note_id_func = function(title)
      return ulid_from_created_or_now()
    end,

    note_frontmatter_func = function(note)
      local out = {}
      out.aliases = note.aliases or {}
      out.tags = note.tags or {}

      local function is_blank(val)
        return val == nil or (type(val) == "string" and vim.trim(val) == "")
      end

      -- Helper function to read existing frontmatter from the buffer
      local function get_existing_frontmatter()
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 100, false)
        
        local frontmatter = {}
        local in_frontmatter = false
        local frontmatter_start = false
        
        for i, line in ipairs(lines) do
          if i == 1 and line == "---" then
            in_frontmatter = true
            frontmatter_start = true
          elseif in_frontmatter and line == "---" then
            break
          elseif in_frontmatter then
            -- Parse key: value pairs
            local key, value = line:match("^([%w_]+):%s*(.*)$")
            if key and value then
              frontmatter[key] = vim.trim(value)
            end
          end
        end
        
        return frontmatter_start and frontmatter or {}
      end
      
      -- Read existing frontmatter from the file
      local existing_fm = get_existing_frontmatter()

      -- Use existing ID if present, otherwise generate new one
      if not is_blank(existing_fm.id) then
        out.id = existing_fm.id
        vim.notify("Using EXISTING ID: " .. out.id, vim.log.levels.INFO)
      else
        out.id = ulid_from_created_or_now(existing_fm.created)
        vim.notify("Generated NEW ID: " .. out.id, vim.log.levels.WARN)
      end

      -- Use existing author if present
      if not is_blank(existing_fm.author) then
        out.author = existing_fm.author
      else
        out.author = "Gallo Chingon"
      end

      -- Use existing created date if present
      if not is_blank(existing_fm.created) then
        out.created = existing_fm.created
      else
        out.created = os.date("%Y-%m-%d_%H:%M:%S-0600")
      end

      -- Merge any other existing frontmatter fields
      for k, v in pairs(existing_fm) do
        if out[k] == nil then
          out[k] = v
        end
      end

      -- Then merge note.metadata (which might be incomplete)
      for k, v in pairs(note.metadata or {}) do
        if out[k] == nil then
          out[k] = v
        end
      end

      return out
    end,
  })
end)