-- vim:ft=lua
-- nvim/lua/config/commands.lua
-- @author nate zhou
-- @since 2026

local fn = require('config.functions')

vim.api.nvim_create_user_command('TermToggle', fn.toggle_terminal_split, {})
vim.api.nvim_create_user_command('TermNew', fn.new_terminal_split, {})
