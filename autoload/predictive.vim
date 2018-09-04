let s:mapalias={
      \ ' ': '<Space>',
      \ }

if get(g:,'predictive_keypad_nums',1)
  call extend(s:mapalias,{
        \ '7': "<k7>",
        \ '8': "<k8>",
        \ '9': "<k9>",
        \ '4': "<k4>",
        \ '5': "<k5>",
        \ '6': "<k6>",
        \ '1': "<k1>",
        \ '2': "<k2>",
        \ '3': "<k3>",
        \ '0': "<k0>",
        \ '/': "<kDivide>",
        \ '+': "<kPlus>",
        \ '*': "<kMultiply>",
        \ '-': "<kMinus>",
        \ '.': "<kPoint>",
        \ "\<kEnter>": '<kEnter>'
        \})
  " Note : Kpoint is not supported on some Asus keypad
endif
let s:feedalias={}
for s:i in keys(s:mapalias)
  exe 'let s:feedalias[s:i]="\'.s:mapalias[s:i].'"'
endfor
let g:predictive_shift_key="\<Right>"
let g:predictive_second_key="\<Cr>"

fu! s:echo_write_state(ch,retidx)
  let l:ret=s:predictive_multitap_km[a:ch][a:retidx]
  let l:w=win_getid()
  call win_gotoid(s:predictive_memento_winid)
  call clearmatches()
  call matchadd('Cursor',escape(l:ret,'.*\['))
  redraw
  call win_gotoid(l:w)
  redraw
  return l:ret
endfu

fu! s:echo_write_state_final(ret)
  let l:w=win_getid()
  call win_gotoid(s:predictive_memento_winid)
  let w:is_written.=a:ret
  setlocal statusline=\%{w:is_written}
  redrawstatus
  call clearmatches()
  redraw
  call win_gotoid(l:w)
  redraw
endfu

fu! s:multitap_mode_get(ch)
  let l:timebase=250
  let l:charbuffer=[]
  let l:ret=s:echo_write_state(a:ch,0)
  let l:feed=''
  let l:c=0
  let l:retries=3
  while l:c < l:retries
     let l:nchar=getchar(0)
     if !empty(l:nchar)
       let l:c=0
       if l:nchar == g:predictive_shift_key
         let l:ret=toupper(l:ret)
         break
       endif
       let l:char=nr2char(l:nchar)
       call add(l:charbuffer, l:char)
       if l:char == a:ch 
         let l:ret=s:echo_write_state(a:ch,len(l:charbuffer)%len(s:predictive_multitap_km[a:ch]))
       else 
         let l:feed=l:char
         break
       endif 
     else
       let l:c+=1
       exe 'sleep '.l:timebase.'m'
     endif
  endwhile

  call s:echo_write_state_final(l:ret)
  if len(l:feed) 
    call feedkeys(get(s:feedalias,l:char,l:char),'t')
  endif
  redraw
  return l:ret
endfu

fu! s:clean_interface()
  let l:w=win_getid()
  if exists('s:predictive_memento_winid') && s:predictive_memento_winid
    call win_gotoid(s:predictive_memento_winid)
    bwipe
    let s:predictive_memento_winid=0
  endif
  if exists('s:predictive_memento_void') && s:predictive_memento_void
    call win_gotoid(s:predictive_memento_void)
    bwipe
    let s:predictive_memento_void=0
  endif
  call win_gotoid(l:w)
endfu

call s:clean_interface()
let s:predictive_memento_winid=0
let s:predictive_memento_void=0

fu! s:init_new(lines)
  call s:clean_interface()
  let l:w=win_getid()
  au! CursorMovedI <buffer> let w=win_getid() | if s:predictive_memento_winid | call win_gotoid(s:predictive_memento_winid) | let w:is_written='' | endif  | call win_gotoid(w)
  vnew
  setlocal statusline=%#StatusLineNC# 
  let s:predictive_memento_void=win_getid()
  leftabove new 
  let w:is_written='' | setlocal statusline=%#StatusLineNC#\%{w:is_written}
  let s:predictive_memento_winid=win_getid()
  setlocal undolevels=0 buftype=nofile
  setlocal wrap nocursorline nonu nobuflisted noswapfile nocursorcolumn norelativenumber
  call setline(1,a:lines)
  exe 'vertical resize '.max(map(copy(a:lines),'len(split(v:val,''\zs''))'))
  exe 'resize '.len(a:lines)
  call win_gotoid(l:w)
endfu

"" Experiment 1 : multitap like old cell phone
let g:abc_km={
      \ '7': "?!@|&", '8': "abc", '9': "def", '+': " ',;.:", '/': '([<{', '*': ')]>}','-': "-'\"#",
      \ '4': "ghi", '5': "jkl", '6': "mno",
      \ '1': "pqrs", '2': "tuv", '3': "wxyz","\<kEnter>": '/*$_',
      \ '0': " |&`",
      \}
let g:abc_km_memento=[
      \ "┌ ─ ─┬────┬────┬────┐",
      \ " ░░░░│([<{│)]>}│-'\"#│",
      \ "├────┼────┼────┼────┤",
      \ "│?!@░│abc░│def░│ ,.:│",
      \ "├────┼────┼────┤░░░░│",
      \ "│ghi░│jkl░│mno░│░░░░│",
      \ "├────┼────┼────┼────┤",
      \ "│pqrs│tuv░│wxyz│/*$_│",
      \ "├────┼────┼────┤░░░░│",
      \ "│░░░░│ |&`│.░░░│░░░░│",
      \ "└────┴────┴────┴────┘",
      \]

" Bigrammes et trigrammes les plus fréquents:
" http://www.nymphomath.ch/crypto/stat/francais.html
" ES DE LE EN RE NT ON ER TE EL AN SE ET LA AI IT ME OU EM IE
" ENT LES EDE DES QUE AIT LLE SDE ION EME ELA RES MEN ESE DEL ANT TIO PAR ESD TDE
let g:predictive_multitap_km=get(g:,'predictive_multitap_km',{
      \ '7': "avj",
      \ '8': "lféè",
      \ '9': "ipw",
      \ '+': " ',;.:|&%`",
      \ '/': '([<{',
      \ '*': ')]>}',
      \ '-': "-'\"#$",
      \ '4': "eog",
      \ '5': "nmx",
      \ '6': "tcz",
      \ '3': "suky",
      \ "\<kEnter>": '_/\\*+=',
      \ '1': "dbà",
      \ '2': "rqh",
      \ '0': " ?!@",
      \ '.': ',;.:',
      \})
let g:predictive_multitap_km_memento=get(g:,'predictive_multitap_km_memento',[
      \ "┌ ─ ─┬────┬────┬────┐",
      \ " ░░░░│([<{│)]>}│-'\"#$",
      \ "├────┼────┼────┼────┤",
      \ "│avj░│lféè│ipw░│ ,.:│",
      \ "├────┼────┼────┤|&%`│",
      \ "│eog░│nmx░│tcz░│░░░░│",
      \ "├────┼────┼────┼────┤",
      \ "│dbà░│rqh░│suyk│_/\\*│",
      \ "├────┼────┼────┤+=░░│",
      \ "│░░░░│ ?!@│.░░░│░░░░│",
      \ "└────┴────┴────┴────┘",
      \])

fu! predictive#multitap_mode()
  let s:predictive_multitap_km={}
  for l:k in keys(g:predictive_multitap_km)
    let s:predictive_multitap_km[l:k]=split(g:predictive_multitap_km[l:k],'\zs')
  endfor
  let l:lines=get(g:,'predictive_multitap_km_memento',map(keys(g:predictive_multitap_km),'v:val." ".g:predictive_multitap_km[v:val]'))
  call s:init_new(l:lines)
  for l:i in keys(g:predictive_multitap_km)
    exe 'inoremap <buffer> <expr> '.get(s:mapalias,l:i,l:i).' <SID>multitap_mode_get("'.l:i.'")'
  endfor
  " command! -buffer DisableMultitap silent! call execute(join(map(keys(g:predictive_multitap_km),'"iunmap <buffer> ".get(s:mapalias,v:val,v:val)')," | ")) | delc DisableMultitap
  command! -buffer DisableMultitap imapclear <buffer> | delc DisableMultitap  | call s:clean_interface()
endfu

" Experiment 2 : digraph tap . 7978 -> la => cabbrev <k7><k9> l ...
" deleted because of the evident hand effort

" Experiment 3 : chord tap like frogpad
let g:predictive_chord_km=get(g:,'predictive_chord_km',{
      \ "<kDivide>": ["p","j"],
      \ '<kMultiply>': ["d","v"],
      \ '<kMinus>':["y","x"],
      \ '<k7>':   ["w","m"],
      \ '<k8>':   ["t","c"],
      \ '<k9>':   ["s","g"],
      \ '<kPlus>':["<Space>","."],
      \ '<k4>':   ["r","b"],
      \ '<k5>':   ["l","h"],
      \ '<k6>':   ["n","k"],
      \ '<k1>':   ["a","'"],
      \ '<k2>':   ["e","z"],
      \ '<k3>':   ["i","<BackSpace>"],
      \ "<Right>":["f","<Tab>"],
      \ '<k0>':   ["o","q"],
      \ '.':["u","<Delete>"],
      \ '<kEnter>':["(",")"],
      \ '<Down>':["<Space>","<Space>"],
      \})
      "\ '<kPoint>':["u","<Delete>"],
let g:predictive_chord_keys_lvl= { "<Down>": 1 }
let g:predictive_chord_km_memento=get(g:,'predictive_chord_km_memento',[
      \ "        ┌───┬───┬───┐",
      \ "        │pj │dv │yx │",
      \ "    ┌───┼───┼───┼───┤",
      \ "    │wm │tc │sg │ .░│",
      \ "    ├───┼───┼───┤░░░│",
      \ "    │rb │hl │nk │░░░│",
      \ "    ├───┼───┼───┼───┤",
      \ "    │a' │ez │i B│()░│",
      \ "┌───┼───┼───┼───┤░░░│",
      \ "│███│f T│oq │u D│░░░│",
      \ "└───┴───┴───┴───┴───┘",
      \])
fu! predictive#chord_mode()
  call s:init_new(g:predictive_chord_km_memento)
  for l:i in keys(g:predictive_chord_km)
    exe 'inoremap <buffer> '.l:i.' '.g:predictive_chord_km[l:i][0]
  endfor
  for l:j in keys(g:predictive_chord_keys_lvl)
    let l:lvl = g:predictive_chord_keys_lvl[l:j]
    for l:i in keys(g:predictive_chord_km)
      exe 'inoremap <buffer> '.l:j.l:i.' '.g:predictive_chord_km[l:i][l:lvl]
    endfor
  endfor
  command! -buffer DisableChordMode imapclear <buffer> | delc DisableChordMode  | call s:clean_interface()
endfu
