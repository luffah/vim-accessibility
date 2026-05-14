""
" Help Window
"
" @function statusui#CloseHelpWin()
" Close Help Window (openned before)
let s:help_win_bufnr=0
fu! statusui#CloseHelpWin()
  if !empty(s:help_win_bufnr)
    let l:bnr=bufwinnr(s:help_win_bufnr)
    exe l:bnr.'windo bd'
    let s:help_win_bufnr=0
  endif
endfu


" @function statusui#HelpWin([title], [content], [filetype], [[lifetime]])
" Create/open a new Help Window
fu! statusui#HelpWin(title,content,ft,...)
  call statusui#CloseHelpWin()
  if !empty(a:content)
    let l:related=winnr()
    rightbelow vnew
    " au BufEnter <buffer> call statusui#CloseHelpWin()
    let s:help_win_bufnr=bufnr('%')
    set buftype=nowrite bufhidden=wipe
    exe 'setlocal statusline=%#VimTodo#'.escape(a:title,' %<')
    map <buffer> q :call statusui#CloseHelpWin()<Cr>
    exe 'set ft='.a:ft
    exe 'vertical resize '.max(map(copy(a:content), 'len(v:val)'))
    call setline(1,a:content)
     exe l:related.'wincmd w'
  endif
  " redraw
  redrawstatus
  if len(a:000) && a:1 =~ '\d\+m\?'
    exe 'sleep '.a:1
    call statusui#CloseHelpWin()
  endif
endfu
