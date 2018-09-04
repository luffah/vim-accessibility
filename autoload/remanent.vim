" KeyMap.vim -- Vim lib for remanent shift and ctrl 
" @Author:      luffah (luffah AT runbox com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-26
" @Last Change: 2018-03-29
" @Revision:    1

if exists('g:loaded_accessibility_remanent') || &compatible
    finish
endif
" remanent shift in bepo keyboard."{{{
let g:remanent_verbose =get(g:,'remanent_verbose',1)

" @global g:remanent_map
" A dictionnary {'_modifier_':{'_key_':['_mode_',..]}} which
" define the remanent keys.
"     _modifier_ -> shift, ctrl, ctrl_shift
"     _key_      -> any key to map
"     _mode_     -> the mode 'i', 'v', 'c', 'o', 's'  (see |mapmode-|)
"                   or 'nr' for replace operation (see |r|)
let g:remanent_map = get(g:, 'remanent_map', {
      \'shift': { 'à':['i'], 'è':['c', 'o', 's','nr'], '<Space>':['n'] },
      \'ctrl': { 'àà':['i'], 'èè':['c', 'o', 's','nr'], '<Space><Space>':['n'] },
      \'ctrl_shift': { 'éè': ['i'] }
      \})

" @function remanent#enable([[silent]])
" Enable remanent keys. (map keybinds)
" If [silent] is not provided or is 0, then |g:remanent_map| is shown.
fu! remanent#enable(...)
  if !get(a:000,0,0)
    call statusui#HelpWin('*Remanent keys activated*',
          \ split(substitute(substitute(execute('echo g:remanent_map'),"'",'"','g'),'},', "},\n",'g'),"\n"),
          \ 'json'
          \ )
  endif
  for r in keys(g:remanent_map)
    for k in keys(g:remanent_map[r])
      for i in g:remanent_map[r][k]
        let p=(len(i)>1 ? i[1:] : '')
        exe i[0].'noremap <expr> '.p.k.' <SID>remanent_'.r.'("'.k.'","'.p.'")'
      endfor
    endfor
  endfor
  let g:remanent_enable=1
endfu

" @function remanent#disable([[silent]])
" Disable remanent keys. (unmap keybinds)
fu! remanent#disable()
  for r in keys(g:remanent_map)
    for k in keys(g:remanent_map[r])
      for i in g:remanent_map[r][k]
        let p=(len(i)>1 ? i[1:] : '')
        silent! exe i[0].'unmap <expr> '.p.k
      endfor
    endfor
  endfor
  if !get(a:000,0,0)
  call statusui#HelpWin('*Remanent keys disabled*',['.'.repeat('-',22).'.'],'json',2)
  endif
  let g:remanent_enable=0
endfu

" @function remanent#reset()
" Disable and enable remanent keys. (remap keybinds)
fu! remanent#reset()
  call remanent#disable(1)
  call remanent#enable(1)
endfu



" @global g:stick_shift_table
" Dictionnary to which translate shift keys.
" Default value is set for bépo keymap.
"
" This value shall be set at startup.
let s:shift_table = get(g:,'stick_shift_table', {
      \ ',' : ';',
      \ '.' : ':', 
      \ 'é' : 'É', 'è' : 'È', 'ê' : 'Ê',
      \ '$' : '#',
      \ "'" : '?',
      \ '^' : '!',
      \ '"' : '1',
      \ '«' : '2',
      \ '»' : '3',
      \ '(' : '4',
      \ ')' : '5',
      \ '@' : '6',
      \ '+' : '7',
      \ '-' : '8',
      \ '/' : '9',
      \ '*' : '0',
      \ '=' : '°',
      \ '%' : '`' })

function! s:getshift(key,default)
  if a:key =~ '\l'
    return toupper(a:key)
  elseif has_key(s:shift_table, a:key)
    return s:shift_table[a:key]
  else
    return a:default
  endif 
endfunction

function! s:remanent_shift(default, prepend)
  if g:remanent_verbose
    echo '(Shift)'
  endif
  " let l:key = ''
  " let l:retry = 2
  " while !l:key && l:retry
    " let l:retry-=1
    let l:key = getchar(0)
    " sleep 50m
    " endwhile
  let l:key = a:prepend.s:getshift(nr2char(l:key), '')
  let l:ret = ''
  if len(l:key)
    exe 'call feedkeys("'.l:key.'")'
  else
    let l:ret=a:default.nr2char(l:key)
  endif
  return l:ret
  " return a:prepend.s:getshift(nr2char(l:key), a:default.nr2char(l:key))
endfunction
"}}}
let s:nochar={
      \ "\<Left>" : "Left",
      \ "\<Right>" : "Right",
      \ "\<Up>" : "Up",
      \ "\<Down>"  :  "Down",
      \ "\<F1>" : "F1",
      \ "\<F2>"  :  "F2",
      \ "\<F3>" : "F3",
      \ "\<F4>" : "F4",
      \ "\<F5>"  :  "F5",
      \ "\<F6>" : "F6",
      \ "\<F7>" : "F7",
      \ "\<F8>" : "F8",
      \ "\<F9>" : "F9",
      \ "\<F10>" : "F10",
      \ "\<F11>" : "F11",
      \ "\<F12>" : "F12",
      \ "\<PageUp>" : "PageUp",
      \ "\<PageDown>" : "PageDown",
      \ "\<Home>" : "Home",
      \ "\<End>" : "End"
      \ }
"command! TrKey echo s:tr_key(getchar())
function! s:tr_key(key)
  let l:ret=''
  if len(a:key)
    let l:ret = get(s:nochar, a:key, nr2char(a:key))
  endif
  return len(l:ret) ? l:ret : ''
endfunction


function! s:remanent_ctrl(default,prepend)
  if g:remanent_verbose
    echo '<C-'
  endif
  let l:key = getchar()
  if len(l:key)
    if g:remanent_verbose
      echo '<C-'.s:tr_key(l:key).'>'
    endif
    exe 'call feedkeys("'.a:prepend.'\<C-'.s:tr_key(l:key).'>")'
  else
    return a:default
  endif 
  echo 
  return ''
endfunction

function! s:remanent_ctrl_shift(default)
  if g:remanent_verbose
    echo '<C-'
  endif
  let l:key = getchar()
  if len(l:key)
    let l:key = s:tr_key(l:key)
    if g:remanent_verbose
      echo '<C-'.s:getshift(l:key, "S-".l:key).'>'
    endif
    exe 'call feedkeys("\<C-'.s:getshift(l:key, "S-".l:key).'>")'
  else
    return a:default
  endif 
  return ''
endfunction

let g:loaded_accessibility_remanent=1
