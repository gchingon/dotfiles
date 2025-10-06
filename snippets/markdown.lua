-- ~/.config/snippets/markdown.lua
-- LuaSnip snippets for markdown files

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

-- Helper function to get current date
local function get_date()
  return os.date("%Y-%m-%d_%H:%M:%S-0600")
end

-- Snippets
return {
  s("head", {
    t "---",
    t "layout: post",
    t "title: ", i(1, "title"),
    t "categories: ", i(2, "category"),
    t "image: assets/", i(3, "image_name.ext"),
    t "created: ", i( get_date()),
    t "description: ", i(4, "a paragraph about the post"),
    t "---",
    t "",
    i(0)
  }),

  s("rating", {
    t "---",
    t "layout: post",
    t "title: ", i(1, "title"),
    t "categories: ", i(2, "category"),
    t "image: assets/", i(3, "image_name.ext"),
    t "created: ", i( get_date()),
    t "description: ", i(4, "a paragraph about the post"),
    t "rating: ", i(5, "zero-3"),
    t "---",
    t "",
    i(0)
  }),
}
