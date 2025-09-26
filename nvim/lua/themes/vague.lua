-- ~/.config/nvim/lua/themes/vague.lua
-- Local theme module for 'vague'

local M = {}

function M.build(palette)
  local p = palette.base
  return {
    base_palette = {
      Normal = { fg = p.fg, bg = p.bg0 },
      Visual = { bg = p.bg2 },
      CursorLine = { bg = p.bg1 },
      -- Add other core highlight groups as needed
    },
    syntax_highlighting = {
      Comment = { fg = p.gray, italic = true },
      Constant = { fg = p.blue },
      String = { fg = p.green },
      Character = { fg = p.green },
      Number = { fg = p.yellow },
      Boolean = { fg = p.yellow },
      Float = { fg = p.yellow },
      Identifier = { fg = p.red },
      Function = { fg = p.blue, bold = true },
      Statement = { fg = p.magenta },
      Conditional = { fg = p.magenta },
      Repeat = { fg = p.magenta },
      Label = { fg = p.magenta },
      Operator = { fg = p.cyan },
      Keyword = { fg = p.magenta },
      Exception = { fg = p.magenta },
      PreProc = { fg = p.yellow },
      Include = { fg = p.blue },
      Define = { fg = p.magenta },
      Macro = { fg = p.magenta },
      PreCondit = { fg = p.yellow },
      Type = { fg = p.cyan },
      StorageClass = { fg = p.yellow },
      Structure = { fg = p.cyan },
      Typedef = { fg = p.yellow },
      Special = { fg = p.blue },
      Underlined = { underline = true },
      Error = { fg = p.red, bg = p.bg1 },
      Todo = { fg = p.magenta, bold = true },
    },
  }
end

return M
