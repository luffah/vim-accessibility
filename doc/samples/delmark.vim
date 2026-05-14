" Here an example of OneShot to send on char argument to a command
"
" The example modify the  m  and  dm  keys in order to :
"   - prompt the fact a mark is on setting
"   - show all mark positions on the mark with Error syntax color

" View generic function
fu! s:show_marks(class,chars)
  let l:stlist = [] | for l:i in split(a:chars,'\zs') | call add(l:stlist, '\%'."'".l:i) | endfor
  call matchadd(a:class,join(l:stlist,'\|'))
endfu
fu! s:update_marks()
  if exists('*signature#sign#Refresh') | call signature#sign#Refresh() | endif
  call s:show_marks('Error', "'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
endfu

fu! s:add_mark(m)
  cal setpos("'".a:m, getpos('.'))
  cal s:update_marks()
endfu

fu! s:rm_mark(m)
  exe 'delmarks '.a:m
  cal s:update_marks()
endfu

command! -nargs=1 DelMark call s:rm_mark(<q-args>)
command! -nargs=1 Mark call s:add_mark(<q-args>)

cal keybindings#Map('delmark'   , 'dm', "<OneShot=DelMark>" , ['n'])
cal keybindings#Map('setmark'   , 'm', "<OneShot=Mark>" , ['n'])
