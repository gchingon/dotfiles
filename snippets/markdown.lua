-- ~/.config/snippets/markdown.lua
-- LuaSnip snippets for markdown files

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node

-- Helper function to get current date
local function get_date()
  return os.date("%Y-%m-%d")
end

-- Snippets
return {
  s("head", {
    t "---",
    t "layout: post",
    t "title: ", i(1, "title"),
    t "date: ", i(2, get_date()),
    t "author: Gallo Chingon",
    t "categories: ", i(3, "category"),
    t "image: assets/", i(4, "image_name.ext"),
    t "tags: [", i(5, "tag1"), t ", ", i(6, "tag2"), t "]",
    t "created: ", i(7, get_date()),
    t "updated: ", i(8, get_date()),
    t "description: ", i(9, "a paragraph about the post"),
    t "---",
    i(0)
  }),

  s("rating", {
    t "---",
    t "layout: post",
    t "title: ", i(1, "title"),
    t "date: ", i(2, get_date()),
    t "author: Gallo Chingon",
    t "categories: ", i(3, "category"),
    t "image: assets/", i(4, "image_name.ext"),
    t "tags: [", i(5, "tag1"), t ", ", i(6, "tag2"), t "]",
    t "created: ", i(7, get_date()),
    t "updated: ", i(8, get_date()),
    t "description: ", i(9, "a paragraph about the post"),
    t "rating: ", i(10, "zero-3"),
    t "---",
    i(0)
  }),
}