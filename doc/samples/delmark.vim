" Here an example of OneShot to send on char argument to a command
" It allows to update the view of the markers when added and removed

" View generic function
fu! s:show_marks(class,chars)
  let l:stlist = []
  for l:i in split(a:chars,'\zs')
    call add(l:stlist, '\%'."'".l:i)
  endfor
  let s:marks = matchadd(a:class,join(l:stlist,'\|'))
endfu

" View update
fu! s:update_marks()
  if exists('*signature#sign#Refresh')
    call signature#sign#Refresh()
  endif
  call s:show_marks('Error', "'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
endfu

" equivalent of 'm'
fu! s:add_mark(m)
  let l:pos=getpos('.')
  cal setpos("'".a:m, l:pos)
  cal s:update_marks()
endfu

" equivalent of 'dm' (as used in signature plugin for examble)
fu! s:rm_mark(m)
  exe 'delmarks '.a:m
  cal s:update_marks()
endfu

command! -nargs=1 DelMark call s:rm_mark(<q-args>)
command! -nargs=1 Mark call s:add_mark(<q-args>)

cal KeyMap#Map('delmark'   , 'dm', "<OneShot=DelMark>" , ['n'])
cal KeyMap#Map('setmark'   , 'm', "<OneShot=Mark>" , ['n'])
