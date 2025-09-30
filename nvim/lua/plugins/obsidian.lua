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

      if is_blank(note.metadata.id) then
        out.id = ulid_from_created_or_now()
      else
        out.id = note.metadata.id
      end

      if is_blank(note.metadata.author) then
        out.author = "Gallo Chingon"
      else
        out.author = note.metadata.author
      end

      if is_blank(note.metadata.created) then
        out.created = os.date("%Y-%m-%d_%H:%M:%S-0600")
      else
        out.created = note.metadata.created
      end

      for k, v in pairs(note.metadata or {}) do
        if out[k] == nil then
          out[k] = v
        end
      end

      return out
    end,
  })
end)
