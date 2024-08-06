local api = vim.api

local M = {}

local function clear_message()
  vim.cmd("echo ''")
end

function M.preview_line()
  local original_pos = api.nvim_win_get_cursor(0)
  local total_lines = api.nvim_buf_line_count(0)
  local input = ""
  local line_num = 0

  while true do
    vim.cmd("redraw")
    print("Enter line number (1-" .. total_lines .. "): " .. input)

    local char = vim.fn.getcharstr()

    if char == "\r" or char == "\n" then -- Enter key
      break
    elseif char == "\27" then -- Escape key
      line_num = 0
      break
    elseif char == vim.api.nvim_replace_termcodes('<BS>', true, false, true) then -- Backspace
      input = input:sub(1, -2) -- Correctly remove last character
    elseif char:match("%d") then -- Numbers 0-9
      input = input .. char
    end

    line_num = tonumber(input) or 0

    if line_num > 0 and line_num <= total_lines then
      api.nvim_win_set_cursor(0, { line_num, 0 })
    else
      api.nvim_win_set_cursor(0, original_pos)
    end
  end

  if line_num > 0 and line_num <= total_lines then
    api.nvim_win_set_cursor(0, { line_num, 0 })
    print("Goto " .. line_num)
    vim.defer_fn(clear_message, 2000)
  else
    api.nvim_win_set_cursor(0, original_pos)
    clear_message()
  end
end

return M
