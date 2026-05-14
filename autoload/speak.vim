" speak.vim  -- Vim lib for using screen reader (speech-dispatcher)
" @Author:      luffah (luffah AT runbox com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-26
" @Last Change: 2019-05-07
" @Revision:    2
if get(g:, 'loaded_accessibility_speak', 0) ||
  \ ! get(g:,'enable_accessibility_speak', 0) ||
  \ &compatible
  finish
endif
let g:loaded_accessibility_speak=1


" @function speak#enable(bool do_enable_keymap)
" Active speak functionnality
if has('win32')
   fu speak#enable(enkm)
     echomsg "os not supported"
   endfu
else
  if !len(split(system('which spd-say'),"\n"))
    fu speak#enable(enkm)
      if get(g:,'speak_dependencies_alert', 0)
        echomsg "'speech-dispatcher' is required for using the accessibility-speak plugin."
        echomsg "'mbrola' and 'gnome-orca' are recommended."
      endif
    endfu
    finish
  endif
endif


" @global g:speak_layer_key
" Define the key to hit to activate speak keybindings.
" Default <C-s> (Ctrl + S).
let g:speak_layer_key = get(g:,'speak_keymap', '<C-s>')

" @global g:speak_leader_key
" Define the leader key which is the first key in combination
" Default x . 
let g:speak_leader_key = get(g:,'speak_leader', '<Tab>')

" @global g:speak_global_keymap
" Define the keymap not prefixed by leader key (active once speak is enabled)
" Default {}. 
let g:speak_global_keymap = get(g:,'speak_keymap', {})

" @global g:speak_leader_keymap
" Define the keymap prefixed by leader key (active once speak is enabled)
" Default {
"       'k' : ':SpeakClear<Cr>',
"       'a' : ':SpeakLine<Cr><Down>',
"       'b' : ':SpeakLine<Cr>',
"       'n' : ':SpeakMatchesNumber<Cr>',
"       'f' : ':SpeakFileName<Cr>',
"       'p' : ':SpeakYanked<Cr>',
"       'W' : ':SpeakWORDPunc<Cr>',
"       'w' : ':SpeakWORD<Cr>',
"       }
let g:speak_leader_keymap = get(g:,'speak_leader', {
      \ 'k' : ':SpeakClear<Cr>',
      \ 'a' : '<Down>:SpeakLine<Cr>',
      \ 'b' : ':SpeakLine<Cr>',
      \ '<Left>' : ':SpeakPosition<Cr>',
      \ '<Right>' : ':SpeakLinePunc<Cr>',
      \ '<S-Left>' : ':SpeakLinePuncBefore<Cr>',
      \ '<S-Right>' : ':SpeakLinePuncAfter<Cr>',
      \ '<Up>' : '<up>:SpeakLinePunc<Cr>',
      \ '<Down>' : '<Down>:SpeakLinePunc<Cr>',
      \ 'n' : ':SpeakMatchesNumber<Cr>',
      \ 'f' : ':SpeakFileName<Cr>',
      \ 'p' : ':SpeakYanked<Cr>',
      \ 'W' : ':SpeakWORDPunc<Cr>',
      \ 'w' : ':SpeakWORD<Cr>',
      \})

" @global g:speak_layer_keymap
" Define the keymap usable whe the speak layer is enable
" for more, see the content of the variable or call keybindings#PrintLayer('~Speak')
let g:speak_layer_keymap = get(g:,'speak_layer_keymap', {
      \'i' : {
      \   '<S-Cr>' : '<C-o>:SpeakLinePunc<Cr>',
      \   '<Up>' : '<Up><C-o>:SpeakCharI<Cr>',
      \   '<Down>' : '<Down><C-o>:SpeakCharI<Cr>',
      \   '<Left>' : '<Left><C-o>:SpeakChar<Cr>',
      \   '<Right>' : '<Right><C-o>:SpeakCharI<Cr>'
      \},
      \'n' : {
      \   'W' : 'W:SpeakWORDPunc<Cr>',
      \   'w' : 'w:SpeakWord<Cr>',
      \   'm' : ':silent! call speak#("set mark")<Cr>m',
      \   'A' : ':silent! call speak#("append at end of line")<Cr>A',
      \   'I' : ':silent! call speak#("insert at beginning")<Cr>I',
      \   'a' : ':silent! call speak#("append")<Cr>a',
      \   'v' : ':silent! call speak#("select")<Cr>v',
      \   'V' : ':silent! call speak#("select lines")<Cr>V',
      \   '<C-v>' : ':silent! call speak#("select block")<Cr><C-v>',
      \   'i' : ':silent! call speak#("insert")<Cr>i',
      \   'u' : ':silent! call speak#("undo")<Cr>u',
      \   '<C-r>' : ':silent! call speak#("redo")<Cr><C-r>',
      \   '.' : ':silent! call speak#(getreg("."),"-m all")<Cr>.',
      \   'x' : ':silent! call speak#("delete","-m all")<Cr>x',
      \   'X' : ':silent! call speak#("backspace","-m all")<Cr>X',
      \   ':' : ':silent! call speak#(":","-m all")<Cr>:',
      \   '/' : ':silent! call speak#("search forward")<Cr>/',
      \   '?' : ':silent! call speak#("search backward")<Cr>?',
      \   'E' : '"0yEE:silent! call speak#(getreg("0")),"-m all")<Cr>',
      \   'B' : '"0yBB:silent! call speak#(getreg("0")),"-m all")<Cr>',
      \   'e' : 'e:silent! call speak#(WordBefore(getline("."),col("."),"\\W"," "),"-m all")<Cr>',
      \   'b' : 'b:silent! call speak#(WordAfter(getline("."),col("."),"\\W"," "),"-m all")<Cr>',
      \   'G' : 'G:silent! call speak#(line(".")." ".getline("."))<Cr>',
      \   '{' : '{:silent! call speak#(line(".")." ".getline("."))<Cr>',
      \   '}' : '}:silent! call speak#(line(".")." ".getline("."))<Cr>',
      \   '*' : '*:SpeakMatches<Cr>',
      \   'n' : 'n:silent! call speak#(line(".")." ".col(".")." ".expand("<cWORD>"), "-m all")<Cr>',
      \   'N' : 'N:silent! call speak#(line(".")." ".col(".")." ".expand("<cWORD>"), "-m all")<Cr>',
      \   '<Up>' : '<Up>:SpeakChar<Cr>',
      \   '<S-Cr>' : ':SpeakLinePunc<Cr>',
      \   '<Cr>' : '<Down>:SpeakLine<Cr>',
      \   '<Down>' : '<Down>:SpeakChar<Cr>',
      \   '<Left>' : '<Left>:SpeakChar<Cr>',
      \   '<Right>' : '<Right>:SpeakChar<Cr>'
      \   },
      \'v' : {
      \   'W' : '<Esc>:SpeakWORDPunc<Cr>gvW',
      \   'w' : '<Esc>:SpeakWord<Cr>gvw',
      \   ':' : '<Esc>:silent! call speak#(":","-m all")<Cr>gv:',
      \   '/' : '<Esc>:silent! call speak#("search forward")<Cr>gv/',
      \   '?' : '<Esc>:silent! call speak#("search backward")<Cr>gv?',
      \   'E' : '<Esc>"0yEE:silent! call speak#(getreg("0")),"-m all")<Cr>gvB',
      \   'B' : '<Esc>"0yBB:silent! call speak#(getreg("0")),"-m all")<Cr>gvE',
      \   'e' : '<Esc>e:silent! call speak#(WordBefore(getline("."),col("."),"\\W"," "),"-m all")<Cr>gve',
      \   'b' : '<Esc>b:silent! call speak#(WordAfter(getline("."),col("."),"\\W"," "),"-m all")<Cr>gvb',
      \   'G' : '<Esc>G:silent! call speak#(line(".")." ".getline("."))<Cr>gvG',
      \   '{' : '<Esc>{:silent! call speak#(line(".")." ".getline("."))<Cr>gv{',
      \   '}' : '<Esc>}:silent! call speak#(line(".")." ".getline("."))<Cr>gv}',
      \   '<Up>' : '<Esc><Up>:SpeakChar<Cr>gv<Up>',
      \   '<S-Cr>' : '<Esc>:silent! call speak#(selection#getSelectedText(),"-m all")<Cr>gv',
      \   '<Cr>' : '<Esc><Down>:SpeakLine<Cr>gv<Cr>',
      \   '<Down>' : '<Esc><Down>:SpeakChar<Cr>gv<Down>',
      \   '<Left>' : '<Esc><Left>:SpeakChar<Cr>gv<Left>',
      \   '<Right>' : '<Esc><Right>:SpeakChar<Cr>gv<Right>'
      \   },
      \'c': {
      \   '<Up>' : '<C-p><C-r>=speak#(getcmdline(),"-m all")<Cr>',
      \   '<Down>' : '<C-n><C-r>=speak#(getcmdline(),"-m all")<Cr>',
      \   '<S-Cr>' : '<C-r>=speak#(getcmdline(),"-m all")<Cr>'
      \   }
      \})

" @global g:speak_lang
" speech dispatcher lang
let g:speak_lang = get(g:, 'speak_lang', '')

" @global g:speak_voice_type
" speech dispatcher voice type
let g:speak_voice_type = get(g:, 'speak_voice_type', '')

" @function speak#(text [, options, speak_lang])
" speak text with spd-say
function! speak#(txt,...)
    let l:opt=get(a:000, 0, '')
    let l:speak_lang=get(a:000,1, g:speak_lang)
    let l:cmd='spd-say -w '.l:opt

    if len(l:speak_lang)
          let l:cmd.=' -l '.l:speak_lang
    endif
    if len(g:speak_voice_type)
          let l:cmd.=' -t '.g:speak_voice_typ
    endif
    let l:cmd.= " ". shellescape(substitute(a:txt,"\n","\t",'g'),1)." &"
    unsilent echo l:cmd
    
    silent! exe '!'.l:cmd
    return ''
endfunction

" @function WordBefore(line,col,endpattern,finalpattern)
" return the word before cursor
function! WordBefore(line,col,endpattern,finalpattern)
  let l:col=a:col-1
  "firstchar
  let l:char=a:line[l:col]
  let l:ret=l:char
  " the others
  if l:col
    let l:col-=1
    let l:eq=(l:char =~ a:endpattern)? '=' : '!'
    let l:char=a:line[l:col]
    exe 'while l:col>0 && l:char !~ a:finalpattern && l:char '.l:eq.'~ a:endpattern'
    " while l:col>0 && l:char !~ a:endpattern
      let l:ret=l:char.l:ret
      let l:col-=1
      let l:char=a:line[l:col]
    endwhile
  endif
  return l:ret
endfu

" @function WordAfter(line,col,endpattern,finalpattern)
" return the word following cursor
function! WordAfter(line,col,endpattern,finalpattern)
  let l:col=a:col-1
  "firstchar
  let l:char=a:line[l:col]
  let l:len=len(a:line)
  let l:ret=l:char
  " the others
  if l:col < l:len 
    let l:col+=1
    let l:eq=(l:char =~ a:endpattern)? '=' : '!'
    let l:char=a:line[l:col]
    exe 'while l:col<l:len && l:char !~ a:finalpattern && l:char '.l:eq.'~ a:endpattern'
      let l:ret.=l:char
      let l:col+=1
      let l:char=a:line[l:col]
    endwhile
  endif
  endif
  echo l:ret
  return l:ret
endfu


let s:keymap_enabled=0
function!  speak#enable(enablekeymap, ...)
  command! -nargs=? SpeakLine  silent! call speak#(getline('.'),'', <q-args>)
  command! -nargs=? SpeakLinePunc silent! call speak#(getline('.'),'-m all', <q-args>)
  command! SpeakClear silent! exe '!spd-say -S' 
  command! -nargs=1 SpeakExpand silent! call speak#(expand(<q-args>), '-m all')
  command! -nargs=1 SpeakReg silent! call speak#(getreg(<q-args>),  '-m all')
  command! -nargs=* SpeakCmdOutput silent! call speak#(execute(<q-args>), '-m all')
  command! SpeakChar silent! call speak#(matchstr(getline('.'), '\%' . col('.') .  'c.'), '-m all')
  command! SpeakCharI silent! call speak#(matchstr(getline('.'), '\%' . (col('.') - 1) .  'c.'), '-m all')
  command! SpeakSearchWord silent! call speak#(getreg('/'), '-m all')
  command! SpeakMatches silent! call speak#(getreg('/').' '.execute('%s/'.getreg('/').'/&/gn'),'-m all')
  command! SpeakMatchesNumber silent! call speak#(execute('%s/'.getreg('/').'/&/gn'))
  command! SpeakFile silent! call speak#(getreg('%'), '-m all')
  command! SpeakFileName silent! call speak#(getreg('%:t'), '-m all')
  command! SpeakLineNum silent! call speak#(line('.'))
  command! SpeakColNum silent! call speak#(col('.'))
  command! SpeakWORD silent! call speak#(expand("<cWORD>"))
  command! SpeakWORDPunc silent! call speak#(expand("<cWORD>"), '-m all')
  command! SpeakWord silent! call speak#(expand("<cword>"), '-m all')
  command! SpeakYanked silent! call speak#(getreg('"'), '-m all')
  command! SpeakPosition silent! call speak#('l '. line('.').' c '.col('.'), '-m all')
  command! SpeakLinePuncBefore silent! call speak#(getline('.')[0:col('.')-2], '-m all')
  command! SpeakLinePuncAfter silent! call speak#(getline('.')[col('.')-1:], '-m all')

  if a:enablekeymap
    let s:keymap_enabled=1
    call s:loadkeymap()
  endif
endfunction

" @function speak#disable()
" Disable speak functionnality
function!  speak#disable()
  delcommand! SpeakLine
  delcommand! SpeakLinePunc
  delcommand! SpeakClear
  delcommand! SpeakExpand
  delcommand! SpeakReg
  delcommand! SpeakCmdOutput
  delcommand! SpeakChar
  delcommand! SpeakCharI
  delcommand! SpeakSearchWord
  delcommand! SpeakMatches
  delcommand! SpeakMatchesNumber
  delcommand! SpeakFile
  delcommand! SpeakFileName
  delcommand! SpeakLineNum
  delcommand! SpeakColNum
  delcommand! SpeakWORD
  delcommand! SpeakWORDPunc
  delcommand! SpeakWord
  delcommand! SpeakYanked

  if s:keymap_enabled
    call s:unloadkeymap()
    let s:keymap_enabled=0
  endif
endfunction

function! s:unloadkeymap()
  for [l:key,l:action] in items(g:speak_global_keymap)
    exe 'unmap '.l:key
  endfor
  for [l:key,l:action] in items(g:speak_leader_keymap)
    exe 'unmap '.g:speak_leader_key.l:key
  endfor
  if g:km_active_layer = '~Speak'
    call keybindings#ToggleLayer('')
  endif
endfunction

function! s:loadkeymap()
  for [l:key,l:action] in items(g:speak_global_keymap)
    cal keybindings#Map('(speak)'    , l:key , l:action , ['n'])
  endfor
  for [l:key,l:action] in items(g:speak_leader_keymap)
    cal keybindings#Map('(speak)'    , g:speak_leader_key.l:key , l:action , ['n'])
  endfor
  cal keybindings#Map('~Speak'    , g:speak_layer_key , '<Layer>' , ['n'])
  cal keybindings#Map('~Speak:Exit'    , g:speak_layer_key , '<ExitLayer>' , ['n'])
  for [l:mode,l:keymap] in items(g:speak_layer_keymap)
    for [l:key,l:action] in items(l:keymap)
      cal keybindings#Map('~Speak:move'    , l:key , l:action , [l:mode])
    endfor
  endfor
endfunction
