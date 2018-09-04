let s:type_str=type("str")
let s:type_num=type(0)
let s:type_hash=type({})
let s:type_list=type([])

""
" Help Window
"
" @function statusui#CloseHelpWin()
" Close Help Window (openned before)
let s:help_win_bufnr=0
let s:prev_size=0
fu! statusui#CloseHelpWin()
  if !empty(s:help_win_bufnr)
    let l:winnr=bufwinnr(s:help_win_bufnr)
    exe l:winnr.'windo bd'
    exe 'resize '.s:prev_size
    let s:help_win_bufnr=0
  endif
endfu


" @function statusui#HelpWin([title], [content], [filetype], [[lifetime]])
" Create/open a new Help Window
fu! statusui#HelpWin(title,content,ft,...)
  call statusui#CloseHelpWin()
  if !empty(a:content)
    let l:related=bufnr('%')
    let s:prev_size=winheight(l:related)
    rightbelow split
    enew
    " au BufEnter <buffer> call statusui#CloseHelpWin()
    let s:help_win_bufnr=bufnr('%')
    set buftype=nowrite
    exe 'setlocal statusline=%#VimTodo#'.escape(a:title,' %<')
    map <buffer> q :call statusui#CloseHelpWin()<Cr>
    exe 'set ft='.a:ft
    exe 'resize '.len(a:content) 
    call setline(1,a:content)
    exe winbufnr(l:related).'wincmd w'
  endif
  redraw
  redrawstatus
  if len(a:000) && a:1 =~ '\d\+m\?'
    exe 'sleep '.a:1
    call statusui#CloseHelpWin()
  endif
endfu

""
" Progress bar
fu! s:loaderRelativeStep(cur,total,...) dict
  let self.i=float2nr(self.len*a:cur/a:total)
  let l:text=a:000+['','']
  let l:text_percent=printf("%6d/%-6d",a:cur,a:total).' '.l:text[0]
  let self.l = l:text_percent . strpart(self.l,len(l:text_percent))
  let b:loader_bar_left=strpart(self.l,0,self.i)
  let b:loader_bar_center=l:text[1]
  let b:loader_bar_right=strpart(self.l,self.i+len(l:text[1]))
  redrawstatus
endfu
""
fu! s:loaderSimpleStep(cur,...) dict
  let self.i=a:cur
  let l:text=a:000+['','']
  let self.l=l:text[0].strpart(self.l,len(l:text[0]))
  let b:loader_bar_left=strpart(self.l,0,self.i)
  let b:loader_bar_center=l:text[1]
  let b:loader_bar_right=strpart(self.l,self.i+len(l:text[1]))
  redrawstatus
endfu
" oscillating Progress bar
fu! s:loaderOscillationStep(chr) dict
  if self.osc_idx + len(a:chr) >= self.len
    let self.osc_sens=-1
  elseif self.osc_idx<=0
    let self.osc_sens=1
  endif
  let self.osc_idx+=self.osc_sens
  let b:loader_bar_left=strpart(self.l,0,self.osc_idx-1)
  let b:loader_bar_center=a:chr
  let b:loader_bar_right=strpart(self.l,self.osc_idx+len(a:chr))
  redrawstatus
endfu
fu! s:loaderStop() dict
  setlocal statusline=
endfu

fu! s:loaderReset() dict
  let b:loader_bar_left=''
  let b:loader_bar_center=''
  let b:loader_bar_right=''
  let self.osc_idx=0
  let self.osc_sens=1
endfu
"while 1 | call a.oscillate(a.osc_sens>0?'>':'<') | redrawstatus| sleep 100ms | endwhile

" @function statusui#Loader([[rule]])
"     [rule] is dict to define which highlight to use. ```
"           Default: {
"           \ 'left':'%#VimTodo#',
"           \ 'center':'%#Cursor#',
"           \ 'right':'%#VimTodo#'
"           \ }
"```
" Create a new Loader object based on the statusline
"     Methods:
"           .update_progress([current],[total],[[content]])
"           '-> update loader as a progress bar
"           .oscillate([content])
"           '-> make loader act as an oscillator
"     Properties:
"           .osc_idx  -> column number of the center element
"           .osc_sens -> 1 if left to right, -1 else
"
fu! statusui#Loader(...)
  let l:arglen=0
  let l:rule={
        \ 'left':'%#VimTodo#',
        \ 'center':'%#Cursor#',
        \ 'right':'%#VimTodo#'
        \  }
  if len(a:000)
    if type(a:1) == s:type_num
      let l:arglen=a:1
      let l:len=l:arglen
    elseif type(a:1) == s:type_hash
      for l:i in keys(a:1)
        let l:rule[l:i]=a:1[l:i]
      endfor
    endif
  endif
  if !l:arglen 
     let l:len=winwidth('.')
  endif
  if !has_key(l:rule,'line')
     let l:rule['line']=repeat(' ',l:len)
  endif
  let l:obj={
        \ 'l':l:rule['line'].' ',
        \ 'len':l:len,
        \ 'arglen':l:arglen,
        \ 'i':0,
        \ 'oscillate':function("s:loaderOscillationStep"),
        \ 'update_progress':function("s:loaderRelativeStep"),
        \ 'pointx':function("s:loaderSimpleStep"),
        \ 'stop':function("s:loaderStop"),
        \ 'reset':function("s:loaderReset"),
        \ 'osc_idx':0,
        \ 'osc_sens':1
        \ }
  let b:loader_bar_left=''
  let b:loader_bar_center=''
  let b:loader_bar_right=''
  exe 'setlocal statusline='.l:rule['left'].'%{b:loader_bar_left}'.l:rule['center'].'%{b:loader_bar_center}'.l:rule['right'].'%{b:loader_bar_right}%<'
  return l:obj
endfu

" @function statusui#FollowCursor()
" Toy function that fill status bar in order
" to represent cursor position in the buffer.
" `setlocal statusline=` to disable it.
fu! statusui#FollowCursor(...)
  let l:operation="call b:cursorprogbar.update_progress(line('.'),line('$'))"
  let l:prop={'left':'%#Visual#'}
  if s:delete_follower() && !get(a:000,0,0)
    return
  endif
  if len(a:000)
    if type(a:1) == s:type_num
      call s:create_follower(a:1)
    endif
    if len(a:000)>1
      if a:2==1
        let l:operation="call b:cursorprogbar.pointx(min([virtcol('v'),virtcol('.')])-1,'','_'.repeat('_',abs(virtcol('v')-virtcol('.'))))"
        let l:prop={'left':'%#NONE#','center':'%#Visual#','line':repeat('-',winwidth('.'))}
      endif
    endif
  endif
  let b:cursorprogbar=statusui#Loader(l:prop)
  augroup FollowCursor
    au!
    exe 'au CursorMoved <buffer> '.l:operation
    au BufDelete <buffer> call <SID>delete_follower() 
  augroup END
  try
    exe l:operation
  catch
    call s:delete_follower()
  endtry
endfu
fu! s:create_follower(h)
  let l:curpos=getcurpos()
  let b:followed_winnr=winnr()
  below split
  exe 'resize '.a:h
  let b:following_winnr=winnr()
  call setpos('.',l:curpos)
  set cursorbind
  exe b:followed_winnr.'wincmd w'
  set cursorbind
endfu
fu! s:delete_follower()
  setlocal statusline=
  if exists('b:following_winnr')
    augroup FollowCursor
      au!
    augroup END
    if win_getid(b:following_winnr)
      exe b:following_winnr.'windo q'
    endif
    unlet b:following_winnr
    unlet b:cursorprogbar
    return 1
  else
    return 0
  endif
endfu
