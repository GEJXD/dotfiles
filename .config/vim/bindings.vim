" vim/bindings.vim
" @author nate zhou
" @since 2023,2024,2025,2026

let mapleader=" "   " set space as leader key

" escape terminal mode with vi mode shell
tnoremap <leader><ESC> <C-\><C-n>
tnoremap <leader>q <C-\><C-n>:quit!<CR>
tnoremap <C-q> <C-\><C-n>:quit!<CR>

" toggle terminal split
nnoremap <silent> <C-CR> :call ToggleTerminalSplit()<CR>
tnoremap <silent> <C-CR> <C-\><C-n>:call ToggleTerminalSplit()<CR>

function! ToggleTerminalSplit()
  let current_buf = bufnr('%')

  if getbufvar(current_buf, '&buftype') == 'terminal'
    hide
    return
  endif

  let term_bufs = []
  for buf in getbufinfo({'buflisted': 1})
    if getbufvar(buf.bufnr, '&buftype') == 'terminal'
      call add(term_bufs, buf.bufnr)
    endif
  endfor

  for buf in term_bufs
    let win = bufwinid(buf)
    if win != -1
      call win_gotoid(win)
      startinsert
      return
    endif
  endfor

  if len(term_bufs) > 0
    execute 'sbuffer ' . term_bufs[0]
    startinsert
  else
    terminal
    startinsert
  endif
endfunction

" new terminal split
nnoremap <silent> <C-S-CR> :call NewTerminalSplit()<CR>

function! NewTerminalSplit()
  terminal
  startinsert
endfunction

nnoremap W :w \|e<Left><Left>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :quitall<CR>

nnoremap <leader>m :marks<CR>
nnoremap <leader>b :buffers<CR>

nnoremap <leader>; :!

" don't yank to clipboard with c
nnoremap c "_c

" completion
inoremap <C-f> <C-x><C-f>
inoremap <expr> <Tab> pumvisible() ? "\<C-y>" : "\<Tab>"

" split
nnoremap <leader>s :split<CR>
nnoremap <leader>v :vsplit<CR>
" movement
nnoremap <C-h> :wincmd h<CR>
nnoremap <C-j> :wincmd j<CR>
nnoremap <C-k> :wincmd k<CR>
nnoremap <C-l> :wincmd l<CR>
" position
nnoremap <C-w>h :wincmd H<CR>
nnoremap <C-w>j :wincmd J<CR>
nnoremap <C-w>k :wincmd K<CR>
nnoremap <C-w>l :wincmd L<CR>
" resize
nnoremap <C-w>y :vertical resize -2<CR>
nnoremap <C-w>u :resize +2<CR>
nnoremap <C-w>i :resize -2<CR>
nnoremap <C-w>o :vertical resize +2<CR>

" tab
nnoremap <leader>O :tabnew<CR>
nnoremap <leader>j :tabprev<CR>
nnoremap <leader>k :tabnext<CR>

" buffer
nnoremap <leader>n :bn<CR>
nnoremap <leader>p :bp<CR>

nnoremap <leader>df :diffthis<CR>

" toggle editor visuals
nnoremap <leader>ts :set spell!<CR>
nnoremap <leader>tw :set wrap!<CR>
nnoremap <leader>tc :set cursorcolumn!<CR>
nnoremap <leader>th :set hlsearch!<CR>
nnoremap <leader>tn :set relativenumber!<CR>

nnoremap <leader>f :FZF<CR>

vnoremap <leader>ds :s/\s\+$//e <Bar> s/^\s\+$//e<CR>
