local M = {}

-- Checkbox states to cycle through
local checkbox_states = {
  "- [ ] ",
  "- [x] ",
  "- [>] ",
  "- [-] ",
}

-- Get the current line content
local function get_current_line()
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  return vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1], line_num
end

-- Set the current line content
local function set_current_line(line_num, content)
  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { content })
end

-- Extract the text after the checkbox
local function get_text_after_checkbox(line)
  for _, checkbox in ipairs(checkbox_states) do
    if vim.startswith(line, checkbox) then
      return line:sub(#checkbox + 1)
    end
  end
  return line
end

-- Check if line starts with any checkbox state
function M.has_checkbox(line)
  for _, checkbox in ipairs(checkbox_states) do
    if vim.startswith(line, checkbox) then
      return true
    end
  end
  return false
end

-- Get current checkbox state index
local function get_checkbox_state_index(line)
  for i, checkbox in ipairs(checkbox_states) do
    if vim.startswith(line, checkbox) then
      return i
    end
  end
  return 0
end

-- Cycle to next checkbox state
function M.cycle_checkbox()
  local line, line_num = get_current_line()
  local text_after = get_text_after_checkbox(line)
  local current_state = get_checkbox_state_index(line)

  if current_state == 0 then
    -- No checkbox, add the first one
    set_current_line(line_num, checkbox_states[1] .. line)
  elseif current_state == #checkbox_states then
    -- Last state, reset (remove checkbox)
    set_current_line(line_num, text_after)
  else
    -- Cycle to next state
    set_current_line(line_num, checkbox_states[current_state + 1] .. text_after)
  end
end

-- Clear checkbox from current line
function M.clear_checkbox()
  local line, line_num = get_current_line()
  if M.has_checkbox(line) then
    local text_after = get_text_after_checkbox(line)
    set_current_line(line_num, text_after)
  end
end

-- Setup function to configure keymaps
function M.setup(opts)
  opts = opts or {}

  -- Create an autocommand group for markdown files
  local group = vim.api.nvim_create_augroup("MarkdownCheckboxCycle", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function()
      -- Map <CR> to cycle through checkboxes in normal mode
      vim.keymap.set("n", "<CR>", function()
        require("core.checkbox-cycle").cycle_checkbox()
      end, { buffer = true, desc = "Cycle markdown checkbox" })

      -- Map <Esc> to clear checkboxes or run cleanup in normal mode
      vim.keymap.set("n", "<Esc>", function()
        local line = vim.api.nvim_get_current_line()
        local checkbox_module = require("core.checkbox-cycle")
        
        if checkbox_module.has_checkbox(line) then
          checkbox_module.clear_checkbox()
        else
          -- Run normal cleanup when not on a checkbox line
          vim.cmd.nohlsearch()
          vim.cmd.echo()
        end
      end, { buffer = true, desc = "Clear checkbox or clean UI" })
    end,
  })
end

return M