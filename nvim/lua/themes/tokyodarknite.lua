-- ~/.config/nvim/lua/themes/tokyonight.lua
local M = {}

function M.build(palette)
  local base = palette.base
  local extras = palette.extras

  return {
    base_palette = {
      Normal = { fg = base.fg, bg = base.bg0 },
      NormalNC = { fg = base.fg, bg = base.bg0 },
      NormalFloat = { fg = base.fg, bg = base.bg1 },
      FloatBorder = { fg = base.blue, bg = base.bg1 },
      FloatTitle = { fg = base.blue, bg = base.bg1, bold = true },
      
      -- Cursor and Visual
      Cursor = { fg = base.bg0, bg = base.cursor },
      CursorLine = { bg = base.bg1 },
      CursorColumn = { bg = base.bg1 },
      Visual = { bg = base.bg2 },
      VisualNOS = { bg = base.bg2 },
      
      -- Line Numbers
      LineNr = { fg = base.gray },
      CursorLineNr = { fg = base.blue, bold = true },
      
      -- Search
      Search = { fg = base.bg0, bg = base.yellow },
      IncSearch = { fg = base.bg0, bg = base.yellow },
      CurSearch = { fg = base.bg0, bg = base.yellow },
      
      -- Statusline
      StatusLine = { fg = base.fg, bg = base.bg2 },
      StatusLineNC = { fg = base.gray, bg = base.bg1 },
      
      -- Tabline
      TabLine = { fg = base.gray, bg = base.bg1 },
      TabLineFill = { bg = base.bg0 },
      TabLineSel = { fg = base.fg, bg = base.blue },
      
      -- Window separators
      WinSeparator = { fg = base.bg3 },
      VertSplit = { fg = base.bg3 },
      
      -- Sign column
      SignColumn = { fg = base.gray, bg = base.bg0 },
      
      -- Folding
      Folded = { fg = base.gray, bg = base.bg2 },
      FoldColumn = { fg = base.gray, bg = base.bg0 },
      
      -- Messages
      ErrorMsg = { fg = base.red, bold = true },
      WarningMsg = { fg = base.yellow, bold = true },
      MsgArea = { fg = base.fg, bg = base.bg0 },
      
      -- Popup menu
      Pmenu = { fg = base.fg, bg = base.bg2 },
      PmenuSel = { fg = base.bg0, bg = base.blue },
      PmenuSbar = { bg = base.bg3 },
      PmenuThumb = { bg = base.gray },
      
      -- Wild menu
      WildMenu = { fg = base.bg0, bg = base.blue },
      
      -- Diff
      DiffAdd = { bg = base.green, fg = base.bg0 },
      DiffChange = { bg = base.yellow, fg = base.bg0 },
      DiffDelete = { bg = base.red, fg = base.bg0 },
      DiffText = { bg = base.blue, fg = base.bg0 },
      
      -- Spelling
      SpellBad = { sp = base.red, undercurl = true },
      SpellCap = { sp = base.yellow, undercurl = true },
      SpellLocal = { sp = base.cyan, undercurl = true },
      SpellRare = { sp = base.magenta, undercurl = true },
    },

    syntax_highlighting = {
      -- Basic syntax
      Comment = { fg = base.gray, italic = true },
      
      Constant = { fg = base.magenta },
      String = { fg = base.green },
      Character = { fg = base.green },
      Number = { fg = base.magenta },
      Boolean = { fg = base.magenta },
      Float = { fg = base.magenta },
      
      Identifier = { fg = base.cyan },
      Function = { fg = base.blue },
      
      Statement = { fg = base.red },
      Conditional = { fg = base.red },
      Repeat = { fg = base.red },
      Label = { fg = base.red },
      Operator = { fg = base.red },
      Keyword = { fg = base.red },
      Exception = { fg = base.red },
      
      PreProc = { fg = base.cyan },
      Include = { fg = base.cyan },
      Define = { fg = base.cyan },
      Macro = { fg = base.cyan },
      PreCondit = { fg = base.cyan },
      
      Type = { fg = base.blue },
      StorageClass = { fg = base.blue },
      Structure = { fg = base.blue },
      Typedef = { fg = base.blue },
      
      Special = { fg = base.yellow },
      SpecialChar = { fg = base.yellow },
      Tag = { fg = base.red },
      Delimiter = { fg = base.fg },
      SpecialComment = { fg = base.gray },
      Debug = { fg = base.red },
      
      Underlined = { fg = base.blue, underline = true },
      Bold = { bold = true },
      Italic = { italic = true },
      
      Error = { fg = base.red },
      Todo = { fg = base.bg0, bg = base.yellow, bold = true },
    },

    ui_elements = {
      -- Directory and file browser
      Directory = { fg = base.blue },
      
      -- Various UI elements
      Title = { fg = base.blue, bold = true },
      SpecialKey = { fg = base.gray },
      NonText = { fg = base.gray },
      MatchParen = { fg = base.yellow, bold = true },
      
      -- Question and more prompt
      Question = { fg = base.green, bold = true },
      MoreMsg = { fg = base.green, bold = true },
      ModeMsg = { fg = base.fg, bold = true },
      
      -- Conceal
      Conceal = { fg = base.gray },
    },

    diagnostic_colors = {
      DiagnosticError = { fg = base.red },
      DiagnosticWarn = { fg = base.yellow },
      DiagnosticInfo = { fg = base.blue },
      DiagnosticHint = { fg = base.cyan },
      DiagnosticOk = { fg = base.green },
      
      DiagnosticSignError = { fg = base.red, bg = base.bg0 },
      DiagnosticSignWarn = { fg = base.yellow, bg = base.bg0 },
      DiagnosticSignInfo = { fg = base.blue, bg = base.bg0 },
      DiagnosticSignHint = { fg = base.cyan, bg = base.bg0 },
      DiagnosticSignOk = { fg = base.green, bg = base.bg0 },
      
      DiagnosticUnderlineError = { sp = base.red, undercurl = true },
      DiagnosticUnderlineWarn = { sp = base.yellow, undercurl = true },
      DiagnosticUnderlineInfo = { sp = base.blue, undercurl = true },
      DiagnosticUnderlineHint = { sp = base.cyan, undercurl = true },
      DiagnosticUnderlineOk = { sp = base.green, undercurl = true },
    },

    plugin_specific = {
      -- Git signs
      GitSignsAdd = { fg = base.green, bg = base.bg0 },
      GitSignsChange = { fg = base.yellow, bg = base.bg0 },
      GitSignsDelete = { fg = base.red, bg = base.bg0 },
      GitSignsTopdelete = { fg = base.red, bg = base.bg0 },
      GitSignsChangedelete = { fg = base.yellow, bg = base.bg0 },
      
      -- Telescope
      TelescopeNormal = { fg = base.fg, bg = base.bg1 },
      TelescopeBorder = { fg = base.blue, bg = base.bg1 },
      TelescopePromptNormal = { fg = base.fg, bg = base.bg2 },
      TelescopePromptBorder = { fg = base.blue, bg = base.bg2 },
      TelescopePromptTitle = { fg = base.bg0, bg = base.blue },
      TelescopePreviewTitle = { fg = base.bg0, bg = base.green },
      TelescopeResultsTitle = { fg = base.bg0, bg = base.cyan },
      TelescopeSelection = { fg = base.fg, bg = base.bg3 },
      TelescopeSelectionCaret = { fg = base.blue },
      
      -- Which Key
      WhichKey = { fg = base.blue },
      WhichKeyGroup = { fg = base.cyan },
      WhichKeyDesc = { fg = base.fg },
      WhichKeySeperator = { fg = base.gray },
      WhichKeyFloat = { bg = base.bg1 },
      WhichKeyBorder = { fg = base.blue, bg = base.bg1 },
      
      -- Flash
      FlashBackdrop = { fg = base.gray },
      FlashMatch = { fg = base.yellow, bg = base.bg0 },
      FlashCurrent = { fg = base.bg0, bg = base.yellow },
      FlashLabel = { fg = base.bg0, bg = base.red, bold = true },
      
      -- Mini.nvim
      MiniCursorword = { bg = base.bg2 },
      MiniCursorwordCurrent = { bg = base.bg2 },
      MiniIndentscopeSymbol = { fg = base.blue },
      MiniJump = { fg = base.bg0, bg = base.yellow },
      MiniJump2dSpot = { fg = base.bg0, bg = base.red, bold = true },
      MiniStarterCurrent = { fg = base.blue },
      MiniStarterFooter = { fg = base.gray, italic = true },
      MiniStarterHeader = { fg = base.blue },
      MiniStarterInactive = { fg = base.gray },
      MiniStarterItem = { fg = base.fg },
      MiniStarterItemBullet = { fg = base.cyan },
      MiniStarterItemPrefix = { fg = base.yellow },
      MiniStarterSection = { fg = base.magenta },
      MiniStarterQuery = { fg = base.green },
      MiniStatuslineDevinfo = { fg = base.fg, bg = base.bg2 },
      MiniStatuslineFileinfo = { fg = base.fg, bg = base.bg2 },
      MiniStatuslineFilename = { fg = base.fg, bg = base.bg1 },
      MiniStatuslineInactive = { fg = base.gray, bg = base.bg1 },
      MiniStatuslineModeCommand = { fg = base.bg0, bg = base.yellow, bold = true },
      MiniStatuslineModeInsert = { fg = base.bg0, bg = base.green, bold = true },
      MiniStatuslineModeNormal = { fg = base.bg0, bg = base.blue, bold = true },
      MiniStatuslineModeOther = { fg = base.bg0, bg = base.cyan, bold = true },
      MiniStatuslineModeReplace = { fg = base.bg0, bg = base.red, bold = true },
      MiniStatuslineModeVisual = { fg = base.bg0, bg = base.magenta, bold = true },
      MiniTablineCurrent = { fg = base.fg, bg = base.bg2, bold = true },
      MiniTablineFill = { bg = base.bg0 },
      MiniTablineHidden = { fg = base.gray, bg = base.bg1 },
      MiniTablineModifiedCurrent = { fg = base.yellow, bg = base.bg2 },
      MiniTablineModifiedHidden = { fg = base.yellow, bg = base.bg1 },
      MiniTablineModifiedVisible = { fg = base.yellow, bg = base.bg1 },
      MiniTablineTabpagesection = { fg = base.bg0, bg = base.blue },
      MiniTablineVisible = { fg = base.fg, bg = base.bg1 },
    },

    treesitter_groups = {
      -- Identifiers
      ["@variable"] = { fg = base.fg },
      ["@variable.builtin"] = { fg = base.red },
      ["@variable.parameter"] = { fg = base.yellow },
      ["@variable.member"] = { fg = base.cyan },
      
      -- Constants
      ["@constant"] = { fg = base.magenta },
      ["@constant.builtin"] = { fg = base.magenta },
      ["@constant.macro"] = { fg = base.cyan },
      
      -- Modules
      ["@module"] = { fg = base.cyan },
      ["@module.builtin"] = { fg = base.cyan },
      
      -- Keywords
      ["@keyword"] = { fg = base.red },
      ["@keyword.function"] = { fg = base.red },
      ["@keyword.operator"] = { fg = base.red },
      ["@keyword.import"] = { fg = base.cyan },
      ["@keyword.type"] = { fg = base.blue },
      ["@keyword.modifier"] = { fg = base.red },
      ["@keyword.repeat"] = { fg = base.red },
      ["@keyword.return"] = { fg = base.red },
      ["@keyword.debug"] = { fg = base.red },
      ["@keyword.exception"] = { fg = base.red },
      ["@keyword.conditional"] = { fg = base.red },
      ["@keyword.directive"] = { fg = base.cyan },
      ["@keyword.directive.define"] = { fg = base.cyan },
      
      -- Functions
      ["@function"] = { fg = base.blue },
      ["@function.builtin"] = { fg = base.blue },
      ["@function.call"] = { fg = base.blue },
      ["@function.macro"] = { fg = base.cyan },
      ["@function.method"] = { fg = base.blue },
      ["@function.method.call"] = { fg = base.blue },
      ["@constructor"] = { fg = base.blue },
      
      -- Operators
      ["@operator"] = { fg = base.red },
      
      -- Punctuation
      ["@punctuation.delimiter"] = { fg = base.fg },
      ["@punctuation.bracket"] = { fg = base.fg },
      ["@punctuation.special"] = { fg = base.red },
      
      -- Literals
      ["@string"] = { fg = base.green },
      ["@string.documentation"] = { fg = base.yellow },
      ["@string.regexp"] = { fg = base.cyan },
      ["@string.escape"] = { fg = base.magenta },
      ["@string.special"] = { fg = base.magenta },
      ["@string.special.symbol"] = { fg = base.cyan },
      ["@string.special.url"] = { fg = base.cyan },
      ["@string.special.path"] = { fg = base.green },
      
      ["@character"] = { fg = base.green },
      ["@character.special"] = { fg = base.magenta },
      
      ["@boolean"] = { fg = base.magenta },
      ["@number"] = { fg = base.magenta },
      ["@number.float"] = { fg = base.magenta },
      
      -- Types
      ["@type"] = { fg = base.blue },
      ["@type.builtin"] = { fg = base.blue },
      ["@type.definition"] = { fg = base.blue },
      ["@type.qualifier"] = { fg = base.red },
      
      ["@attribute"] = { fg = base.cyan },
      ["@property"] = { fg = base.cyan },
      
      -- Tags
      ["@tag"] = { fg = base.red },
      ["@tag.attribute"] = { fg = base.yellow },
      ["@tag.delimiter"] = { fg = base.fg },
      
      -- Comments
      ["@comment"] = { fg = base.gray, italic = true },
      ["@comment.documentation"] = { fg = base.gray },
      
      -- Misc
      ["@error"] = { fg = base.red },
      ["@none"] = { fg = base.fg },
      ["@preproc"] = { fg = base.cyan },
      ["@define"] = { fg = base.cyan },
      ["@include"] = { fg = base.cyan },
    },

    lsp_semantic_tokens = {
      ["@lsp.type.class"] = { fg = base.blue },
      ["@lsp.type.decorator"] = { fg = base.cyan },
      ["@lsp.type.enum"] = { fg = base.blue },
      ["@lsp.type.enumMember"] = { fg = base.cyan },
      ["@lsp.type.function"] = { fg = base.blue },
      ["@lsp.type.interface"] = { fg = base.blue },
      ["@lsp.type.macro"] = { fg = base.cyan },
      ["@lsp.type.method"] = { fg = base.blue },
      ["@lsp.type.namespace"] = { fg = base.cyan },
      ["@lsp.type.parameter"] = { fg = base.yellow },
      ["@lsp.type.property"] = { fg = base.cyan },
      ["@lsp.type.struct"] = { fg = base.blue },
      ["@lsp.type.type"] = { fg = base.blue },
      ["@lsp.type.typeParameter"] = { fg = base.blue },
      ["@lsp.type.variable"] = { fg = base.fg },
      
      ["@lsp.mod.readonly"] = { italic = true },
      ["@lsp.mod.deprecated"] = { strikethrough = true },
    },

    markdown_groups = {
      ["@markup.heading"] = { fg = base.blue, bold = true },
      ["@markup.heading.1"] = { fg = base.red, bold = true },
      ["@markup.heading.2"] = { fg = base.yellow, bold = true },
      ["@markup.heading.3"] = { fg = base.green, bold = true },
      ["@markup.heading.4"] = { fg = base.cyan, bold = true },
      ["@markup.heading.5"] = { fg = base.blue, bold = true },
      ["@markup.heading.6"] = { fg = base.magenta, bold = true },
      
      ["@markup.list"] = { fg = base.red },
      ["@markup.list.checked"] = { fg = base.green },
      ["@markup.list.unchecked"] = { fg = base.red },
      
      ["@markup.link"] = { fg = base.cyan },
      ["@markup.link.label"] = { fg = base.blue },
      ["@markup.link.url"] = { fg = base.cyan, underline = true },
      
      ["@markup.raw"] = { fg = base.green },
      ["@markup.raw.block"] = { fg = base.green },
      
      ["@markup.quote"] = { fg = base.gray, italic = true },
      
      ["@markup.math"] = { fg = base.blue },
      
      ["@markup.environment"] = { fg = base.cyan },
      ["@markup.environment.name"] = { fg = base.yellow },
      
      ["@markup.strikethrough"] = { strikethrough = true },
      ["@markup.strong"] = { bold = true },
      ["@markup.italic"] = { italic = true },
      ["@markup.underline"] = { underline = true },
    },
  }
end

return M