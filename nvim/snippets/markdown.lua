-- ~/.config/nvim/snippets/markdown.lua
-- LuaSnip snippets for markdown files

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local rep = require("luasnip.extras").rep

-- Snippets
return {
  -- social links for hugo theme
  s({ trig = "socialls", name = "social links shortcode"}, {
    t("{{< social-link url=\"https://"),
    i(1),
    t("\" text=\""),
    i(2),
    t("\" icon=\""),
    i(3),
    t("\" >}}")
  }),

  -- Rated blog post frontmatter
  s({ trig = "rating", name = "rated blog post frontmatter" }, {
    t({ "---", "layout: post", "title: " }),
    i(1, "title"),
    t({ "", "categories: " }),
    i(2, "category"),
    t({ "", "image: assets/" }),
    i(3, "image_name.ext"),
    t({ "", "created: " }),
    f(function() return os.date("%Y-%m-%d_%H:%M:%S-0600") end),
    t({ "", "description: " }),
    i(4, "a paragraph about the post"),
    t({ "", "rating: " }),
    i(5, "zero-3"),
    t({ "", "---", "" }),
    i(0)
  }),

  -- Character template (no frontmatter)
  s({ trig = "character", name = "Character template (no frontmatter)" }, {
    t("# "), i(1), t({ "", "" }),
    t({ "## Aliases", "", "" }), i(0), t({ "", "" }),
    t({ "## Roles and Series", "", "", "", "" }),
    t({ "## Overview", "", "", "", "" }),
    t({ "## First Appearance (file/chapter)", "", "", "", "" }),
    t({ "## Logline (1–2 sentences)", "", "", "", "" }),
    t({ "## Character Arc and Growth Potential", "", "", "", "" }),
    t({ "## Notes", "", "", "", "" }),
    t({ "## Questions for Further Development", "", "", "", "" }),
    t({ "## Purpose and Goals", "", "", "", "" }),
    t({ "## Psychological Profile", "", "", "", "" }),
    t({ "## Personal History", "", "", "", "" }),
    t({ "## Physical Description", "", "", "", "" }),
    t({ "## Unique Voice, Dialogue Patterns, and Mannerisms", "", "", "", "" }),
    t({ "## Special Skills, Knowledge, or Abilities", "", "", "", "" }),
    t({ "## Resources and Capabilities", "", "", "", "" }),
    t({ "## Behavioral Patterns", "", "", "", "" }),
    t({ "## Communities, Organizations ", "", "", "", "" }),
    t({ "## Operations and Methods", "", "", "", "" }),
    t({ "## Historical Context", "", "", "", "" }),
    rep(1), t({ "'s Hobbies", "", "", "", "" }),
    t({ "## Dialogue Examples", "", "", "", "" }),
    t({ "## Story Function and Narrative Purpose", "", "", "", "" }),
    t({ "## Relationship to other Characters", "", "", "" }),
  }),

  -- Featured appearance frontmatter
  s({ trig = "feat", name = "Featured appearance frontmatter" }, {
    t({ "---", "title: \"" }), i(1, "Episode Title or Appearance Name"), t({ "\"", "created: " }),
    f(function() return os.date("%Y-%m-%d_%H:%M:%S-0600") end),
    t({ "", "updated: " }), i(2), t({ "", "draft: " }), c(3, { t("false"), t("true") }),
    t({ "", "", "# Appearance Details", "type: " }), i(4, "podcast"),
    t({ "", "podcastName: \"" }), i(5, "Their Podcast Name"), t({ "\"", "hosts: [\"" }), i(6, "Host Name"), t({ "\"]",
    "guests: [\"" }), i(7, "Other Guest"), t({ "\"]", "externalUrl: \"" }), i(8, "https://spotify..."), t({ "\"", "",
    "# Image & Content", "featuredImage: " }), i(9, "/images/cover.jpg"),
    t({ "", "tags: [\"" }), i(10, "topic1"), t({ "\", \"" }), i(11, "topic2"), t({ "\"]", "summary: \"" }), i(12,
    "Brief one-liner"), t({ "\"", "description: \"" }), i(13, "Longer description of the appearance"), t({ "\"", "",
    "# Overlay Settings (for hero cards on list pages)", "overlayMetadata: " }), c(14, { t("true"), t("false") }),
    t({ "", "overlayPosition: " }), c(15, { t("lower-left"), t("center"), t("lower-center"), t("lower-right") }),
    t({ "", "transparency: " }), c(16, { t("true"), t("false") }),
    t({ "", "transparencyAmount: " }), i(17, "0.7"),
    t({ "", "", "# Display Options", "topicsOn: " }), c(18, { t("true"), t("false") }),
    t({ "", "toc: " }), c(19, { t("false"), t("true") }),
    t({ "", "lightgallery: " }), c(20, { t("true"), t("false") }),
    t({ "", "---", "" }), i(0)
  }),

  -- Episode frontmatter
  s({ trig = "epi", name = "Episode frontmatter" }, {
    t({ "---", "title: \"" }), i(1, "Episode Title"), t({ "\"", "created: " }),
    f(function() return os.date("%Y-%m-%d_%H:%M:%S-0600") end),
    t({ "", "updated: " }), i(2), t({ "", "draft: " }), c(3, { t("false"), t("true") }),
    t({ "", "", "# Episode Details", "episodeNumber: " }), i(4, "42"),
    t({ "", "season: " }), i(5, "2"),
    t({ "", "episodeType: " }), c(6, { t("full"), t("trailer"), t("bonus") }),
    t({ "", "podcast: \"" }), i(7, "Your Podcast Name"), t({ "\"", "host: \"" }), i(8, "Your Name"), t({ "\"",
    "guests: [\"" }), i(9, "Guest Name"), t({ "\", \"" }), i(10, "Guest 2"), t({ "\"]", "", "# Image & Content",
    "featuredImage: " }), i(11, "/images/episode-42.jpg"),
    t({ "", "duration: \"" }), i(12, "45:30"), t({ "\"", "tags: [\"" }), i(13, "topic1"), t({ "\", \"" }), i(14, "topic2"),
    t({ "\"]", "summary: \"" }), i(15, "Brief episode description"), t({ "\"", "description: \"" }), i(16,
    "Detailed episode notes"), t({ "\"", "", "# Embedded Players", "embedPlayers:", "  - type: " }), i(17, "spotify"),
    t({ "", "    id: \"" }), i(18, "episode-id"), t({ "\"", "  - type: " }), i(19, "youtube"),
    t({ "", "    id: \"" }), i(20, "video-id"), t({ "\"", "", "# Overlay Settings (for hero cards on list pages)",
    "overlayMetadata: " }), c(21, { t("true"), t("false") }),
    t({ "", "overlayPosition: " }), c(22, { t("lower-center"), t("center"), t("lower-left"), t("lower-right") }),
    t({ "", "transparency: " }), c(23, { t("true"), t("false") }),
    t({ "", "transparencyAmount: " }), i(24, "0.7"),
    t({ "", "", "# Display Options", "topicsOn: " }), c(25, { t("true"), t("false") }),
    t({ "", "toc: " }), c(26, { t("true"), t("false") }),
    t({ "", "lightgallery: " }), c(27, { t("true"), t("false") }),
    t({ "", "---", "" }), i(0)
  }),

  -- Blog post frontmatter
  s({ trig = "blog", name = "Blog post frontmatter" }, {
    t({ "---", "title: \"" }), i(1, "Blog Post Title"), t({ "\"", "created: " }),
    f(function() return os.date("%Y-%m-%d_%H:%M:%S-0600") end),
    t({ "", "updated: " }), i(2), t({ "", "draft: " }), c(3, { t("false"), t("true") }),
    t({ "", "featuredImage: " }), i(4, "/images/cover.jpg"),
    t({ "", "tags: [\"" }), i(5, "tag1"), t({ "\", \"" }), i(6, "tag2"), t({ "\"]", "summary: \"" }), i(7,
    "Brief summary"), t({ "\"", "description: \"" }), i(8, "Detailed description"), t({ "\"", "toc: " }), c(9,
    { t("true"), t("false") }),
    t({ "", "lightgallery: " }), c(10, { t("true"), t("false") }),
    t({ "", "---", "" }), i(0)
  }),
  -- Podcast Spotify embed
  s({ trig = "pods", name = "Podcast Spotify embed" }, {
    t('{{< podcast-spotify "'),
    f(function()
      local clip = vim.fn.getreg("+")
      return clip or ""
    end),
    t('" >}}'),
  }),

  -- Podcast YouTube embed
  s({ trig = "pody", name = "Podcast YouTube embed" }, {
    t('{{< podcast-youtube "'),
    f(function()
      local clip = vim.fn.getreg("+")
      return clip or ""
    end),
    t('" >}}'),
  }),

  -- bypass_shorts boolean flags
  s({ trig = "bst", name = "bypass_shorts: true" }, {
    t("bypass_shorts: true"),
  }),

  s({ trig = "bsf", name = "bypass_shorts: false" }, {
    t("bypass_shorts: false"),
  }),

  -- Headers (h1-h6)
  s({ trig = "h1", name = "Header 1" }, {
    t("# "), i(0)
  }),
  s({ trig = "h2", name = "Header 2" }, {
    t("## "), i(0)
  }),
  s({ trig = "h3", name = "Header 3" }, {
    t("### "), i(0)
  }),
  s({ trig = "h4", name = "Header 4" }, {
    t("#### "), i(0)
  }),
  s({ trig = "h5", name = "Header 5" }, {
    t("##### "), i(0)
  }),
  s({ trig = "h6", name = "Header 6" }, {
    t("###### "), i(0)
  }),

  -- Text formatting
  s({ trig = "b", name = "Bold text" }, {
    t("**"), i(1), t("**"), i(0)
  }),
  s({ trig = "i", name = "Italic text" }, {
    t("*"), i(1), t("*"), i(0)
  }),
  s({ trig = "bi", name = "Bold and italic" }, {
    t("***"), i(1), t("***"), i(0)
  }),
  s({ trig = "code", name = "Inline code" }, {
    t("`"), i(1), t("`"), i(0)
  }),
  s({ trig = "strikethrough", name = "Strikethrough" }, {
    t("~~"), i(1), t("~~"), i(0)
  }),

  -- Links and URLs
  s({ trig = "l", name = "Link" }, {
    t("["), i(1, "text"), t("]("), i(2, "url"), t(")"), i(0)
  }),
  s({ trig = "link", name = "Link" }, {
    t("["), i(1, "text"), t("]("), i(2, "url"), t(")"), i(0)
  }),
  s({ trig = "u", name = "URL" }, {
    t("<"), i(1), t(">"), i(0)
  }),
  s({ trig = "url", name = "URL" }, {
    t("<"), i(1), t(">"), i(0)
  }),

  -- Images
  s({ trig = "img", name = "Image" }, {
    t("!["), i(1, "alt text"), t("]("), i(2, "path"), t(")"), i(0)
  }),

  -- Lists
  s({ trig = "unordered list", name = "Unordered list" }, {
    t({ "- ", "- ", "- " }), i(0)
  }),
  s({ trig = "ordered list", name = "Ordered list" }, {
    t({ "1. ", "2. ", "3. " }), i(0)
  }),

  -- Code block
  s({ trig = "codeblock", name = "Code block" }, {
    t({ "```", "" }), i(1, "language"), t({ "", "" }), i(0), t({ "", "```" })
  }),

  -- Quote
  s({ trig = "quote", name = "Quote" }, {
    t("> "), i(0)
  }),

  -- Horizontal rule
  s({ trig = "hr", name = "Horizontal rule" }, {
    t("---")
  }),

  -- Task list
  s({ trig = "task", name = "Task" }, {
    t("- [ ] "), i(0)
  }),
  s({ trig = "todo", name = "Todo" }, {
    t("- [ ] "), i(0)
  }),

  -- Tables (basic 3x3)
  s({ trig = "table", name = "Table" }, {
    t({ "| ", "" }), i(1, "Column1"), t({ " | ", "" }), i(2, "Column2"), t({ " | ", "" }), i(3, "Column3"), t({ " |", "" }),
    t({ "| --- | --- | --- |", "" }),
    t({ "| ", "" }), i(4, "Item1"), t({ " | ", "" }), i(5, "Item2"), t({ " | ", "" }), i(6, "Item3"), t({ " |", "" }),
    i(0)
  }),

  -- Admonitions (GitHub-style)
  s({ trig = "note", name = "Note admonition" }, {
    t({ "> [!NOTE]", "> " }), i(0)
  }),
  s({ trig = "n", name = "Note admonition" }, {
    t({ "> [!NOTE]", "> " }), i(0)
  }),
  s({ trig = "tip", name = "Tip admonition" }, {
    t({ "> [!TIP]", "> " }), i(0)
  }),
  s({ trig = "t", name = "Tip admonition" }, {
    t({ "> [!TIP]", "> " }), i(0)
  }),
  s({ trig = "important", name = "Important admonition" }, {
    t({ "> [!IMPORTANT]", "> " }), i(0)
  }),
  s({ trig = "warning", name = "Warning admonition" }, {
    t({ "> [!WARNING]", "> " }), i(0)
  }),
  s({ trig = "w", name = "Warning admonition" }, {
    t({ "> [!WARNING]", "> " }), i(0)
  }),
  s({ trig = "caution", name = "Caution admonition" }, {
    t({ "> [!CAUTION]", "> " }), i(0)
  }),

}
