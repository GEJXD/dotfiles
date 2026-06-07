-- vim:ft=lua
-- nvim/lua/config/options.lua
-- @author nate zhou
-- @since 2025,2026

vim.g.mapleader = ' '

local function map(mode, keys, value)
	vim.keymap.set(mode, keys, value, { noremap = true })
end

-- escape terminal mode with vi mode shell
map('t', '<leader><ESC>', '<C-\\><C-n>')
map('t', '<leader>q', '<C-\\><C-n> | :quit!<CR>')
map('t', '<C-q>', '<C-\\><C-n> | :quit!<CR>')

-- toggle terminal split
vim.keymap.set('n', '<C-CR>', function()
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

  if #term_bufs > 0 then
    vim.cmd('split')
    vim.api.nvim_win_set_buf(0, term_bufs[1])
    vim.cmd('startinsert')
  else
    vim.cmd('split | terminal')
    vim.cmd('startinsert')
  end
end, { silent = true })

-- new terminal split
vim.keymap.set('n', '<C-S-CR>', function()
  vim.cmd('split | terminal')
  vim.cmd('startinsert')
end, { silent = true })


map('t', '<C-CR>', '<C-\\><C-n>:hide<CR>')

map('t', '<C-S-CR>', '<C-\\><C-n>:split | terminal<CR>i')

map('n', 'W', ':w |e<Left><Left>')
map('n', '<leader>q', ':q<CR>')
map('n', '<leader>Q', ':quitall<CR>')

map('n', '<leader>m', ':marks<CR>')
map('n', '<leader>b', ':buffers<CR>')

map('n', '<leader>;', ':!') -- run shell commands

map('n', 'c', '"_c') -- Don't copy to clipboard with `c*`

-- completion
map('i', '<C-f>', '<C-x><C-f>') -- start pathname suggestion
vim.cmd [[ inoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>" ]]

-- split
map('n', '<leader>s', ':split<CR>')
map('n', '<leader>v', ':vsplit<CR>')
-- movement
map('n', '<C-h>', ':wincmd h<CR>')
map('n', '<C-j>', ':wincmd j<CR>')
map('n', '<C-k>', ':wincmd k<CR>')
map('n', '<C-l>', ':wincmd l<CR>')
-- position
map('n', '<C-w>h', ':wincmd H<CR>')
map('n', '<C-w>j', ':wincmd J<CR>')
map('n', '<C-w>k', ':wincmd K<CR>')
map('n', '<C-w>l', ':wincmd L<CR>')
-- resize
map('n', '<C-w>y', ':vertical resize -2<CR>')
map('n', '<C-w>u', ':resize +2<CR>')
map('n', '<C-w>i', ':resize -2<CR>')
map('n', '<C-w>o', ':vertical resize +2<CR>')

-- tab
map('n', '<leader>O', ':tabnew<CR>')
map('n', '<leader>j', ':tabnext<CR>')
map('n', '<leader>k', ':tabprev<CR>')


-- buffer
map('n', '<leader>n' ,':bn<CR>')
map('n', '<leader>p' ,':bp<CR>')

map('n', '<leader>df', ':diffthis<CR>')

-- toggle editor visuals
map('n', '<leader>ts', ':set spell!<CR>')
map('n', '<leader>tw', ':set wrap!<CR>')
map('n', '<leader>tc', ':set cursorcolumn!<CR>')
map('n', '<leader>th', ':set hlsearch!<CR>')
map('n', '<leader>tn', ':set relativenumber!<CR>')

map('n', '<leader>f', ':FZF<CR>')

map('v', '<leader>ds', [[:s/\s\+$//e | s/^\s\+$//e<CR>]])

-- plugins
-- nvim-colorizer
map('n', '<leader>tC', ':ColorizerToggle<CR>')
map('n', '<leader>rC', ':ColorizerReloadAllBuffers<CR>')
-- nvim-treesitter
map('n', '<leader>tH', ':TSToggle highlight<CR>')
-- nvim-treesitter-context
map('n', '<leader>tx', ':TSContext toggle<CR>')
-- indent-blankline
map('n', '<leader>tI', ':IBLToggle<CR>')
-- render-markdown
map('n', '<leader>tM', ':RenderMarkdown toggle<CR>')
map('n', '<leader>M', ':RenderMarkdown preview<CR>')
-- vim-fugitive
map('n', '<leader>gg', ':G<CR>')
map('n', '<leader>gds', ':Gdiffsplit<CR>')
map('n', '<leader>gdv', ':Gvdiffsplit<CR>')
map('n', '<leader>gl', ':Git log --graph --pretty=format:\'%Cred%h%Creset%C(yellow)%d%Creset %s%Cgreen(%cr)\'<CR><CR>')
-- lf
map('n', '<leader>o', ':LfNewTab<CR>')

-- coc floating window scrolling
vim.keymap.set('i', '<C-j>', function()
  if vim.fn['coc#float#has_scroll']() == 1 then
    return '<c-r>=coc#float#scroll(1)<cr>'
  else
    return '<Right>'
  end
end, { expr = true, nowait = true, silent = true })

vim.keymap.set('i', '<C-k>', function()
  if vim.fn['coc#float#has_scroll']() == 1 then
    return '<c-r>=coc#float#scroll(0)<cr>'
  else
    return '<Left>'
  end
end, { expr = true, nowait = true, silent = true })

-- coc Fix
vim.keymap.set('n', '<C-b>f', '<Plug>(coc-codeaction-cursor)', { silent = true })
vim.keymap.set('n', '<C-b>F', '<Plug>(coc-codeaction-line)', { silent = true })

-- coc Hover
vim.keymap.set('n', '<C-b>h', ':call CocActionAsync("doHover")<CR>', { silent = true })

-- coc floating definition
vim.keymap.set('n', '<C-b>d', '<Plug>(coc-definition)', { silent = true })

-- coc open Reference file
vim.keymap.set('n', '<C-b>r', '<Plug>(coc-references)', { silent = true })
