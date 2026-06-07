" vim:ft=vim
" .config/vim/functions.vim
" @author nate zhou
" @since 2026

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
      execute 'resize ' . (&lines / 3)
      startinsert
      return
    endif
  endfor

  if len(term_bufs) > 0
    execute 'botright sbuffer ' . term_bufs[0]
  else
    botright terminal
  endif

  execute 'resize ' . (&lines / 3)
  startinsert
endfunction

function! NewTerminalSplit()
  botright terminal
  execute 'resize ' . (&lines / 3)
  startinsert
endfunction
