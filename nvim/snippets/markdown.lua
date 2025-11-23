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

  -- Blog post frontmatter
  s({ trig = "head", name = "blog post frontmatter" }, {
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
    t({ "", "---", "" }),
    i(0)
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

}
