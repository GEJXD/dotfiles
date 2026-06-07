-- vim:ft=lua
-- nvim/lua/config/functions.lua
-- @author nate zhou
-- @since 2026

local M = {}

function M.toggle_terminal_split()
  local current_buf = vim.api.nvim_get_current_buf()

  if vim.bo[current_buf].buftype == 'terminal' then
    vim.cmd('hide')
    return
  end

  local term_bufs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == 'terminal' then
      table.insert(term_bufs, buf)
    end
  end

  for _, buf in ipairs(term_bufs) do
    local win = vim.fn.bufwinid(buf)
    if win ~= -1 then
      vim.api.nvim_set_current_win(win)
      vim.cmd('startinsert')
      return
    end
  end

  local height = math.floor(vim.o.lines / 3)

  if #term_bufs > 0 then
    vim.cmd('botright ' .. height .. 'split')
    vim.api.nvim_win_set_buf(0, term_bufs[1])
    vim.cmd('startinsert')
  else
    vim.cmd('botright ' .. height .. 'split | terminal')
    vim.cmd('startinsert')
  end
end

function M.new_terminal_split()
  local height = math.floor(vim.o.lines / 3)
  vim.cmd('botright ' .. height .. 'split | terminal')
  vim.cmd('startinsert')
end

return M
