" KeyMap.vim -- Vim lib for automatic theme change given hour
" @Author:      luffah (luffah AT runbox com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-26
" @Last Change: 2018-03-29
" @Revision:    1
"""
" BEGINNING TIPS 
"""
" Ensure this script is loaded after "syntax on" instruction"
"
" Modify following line to setup a custom colorscheme plan 

"" Post theme customisation model
" fu! InitCursor()
" hi MatchParen gui=bold guifg=#f500e9 guibg=#000666 cterm=bold ctermfg=Magenta ctermbg=darkred
" hi CursorVisual guibg=#00d0cd guifg=#000666 ctermbg=DarkCyan ctermfg=blue
" hi Cursor guibg=#000000 guifg=#f500e9 ctermbg=LightMagenta ctermfg=black
" set guicursor=i:ver35-CursorVisual,v:hor35-CursorVisual,n-c:block-blinkon0-Cursor
" endfu

"" File and Time-relative based colorscheme 
" let g:scheduled_colorscheme_plan={
"   'gui':{'*':['molokai','molokai','gruvbox','gruvbox/dark','molokai']}
"   'gui-post-proc':'call InitCursor()',
"   'term':{'*':['molokai-term','molokai-term','gruvbox/dark','gruvbox/dark','molokai-term']}
"   'term-post-proc':'call InitCursor()'}
" let g:scheduled_colorscheme_secure_change=1
" let g:scheduled_colorscheme_auto=1

"" Scheduled changement of colorscheme.
"" Hours are implicits given the number of elements
"" 2 :   0h-12h , 12h-0h
"" 3 :   0h-8h  , 8h-16h ,  16h-0h
"" 4 :   0h-6h  , 6h-12h ,  12h-18h , 18h-0h
"" 5 :   1h-5h  , 5h-10h ,  10h-15h , 15h-20h  ,  20h-1h
"" 6 :   0h-4h  , 4h-8h  ,  8h-12h  , 12h-14h  ,  14h-18h , 18h-20h , 20h-0h

"""
" BEGINNING CODE
"""
if (v:version < 700 || &cp)
  finish
endif

if !exists('g:scheduled_colorscheme_plan')
  finish
endif

let s:default_term_post='"Taking the colorscheme as is'
let s:default_gui_post=s:default_term_post

let g:scheduled_colorscheme_plan=get(g:,'scheduled_colorscheme_plan', {})
if has('gui_running')
  let s:scheduled_colorscheme=get(g:scheduled_colorscheme_plan,'gui',{})
  let s:scheduled_colorscheme_post_proc=get(g:scheduled_colorscheme_plan,'gui-post',s:default_gui_post) 
else 
  set t_Co=256
  let s:scheduled_colorscheme=get(g:scheduled_colorscheme_plan,'term',{})
  let s:scheduled_colorscheme_post_proc=get(g:scheduled_colorscheme_plan,'term-post',s:default_term_post)
endif

if !exists('g:loaded_accessibility_colortheme')
  " Colorscheme switching
  let s:last_colorsheme_index=0
  fu! s:NextColor(offset)
    let s:colors = map(
          \split(globpath(&runtimepath, 'colors/*.vim'), "\n")
          \, 'fnamemodify(v:val, ":t:r")')
    let s:last_colorsheme_index = ( s:last_colorsheme_index + a:offset )% len(s:colors)
    call s:SetColorScheme(s:colors[s:last_colorsheme_index])
    return g:colors_name
  endfu

  fu! s:SetColorScheme(colorscheme)
    try
      " 1 to force default theme before loading a new theme (for partial themes)
      if get(g:,'scheduled_colorscheme_secure_change',0)
        if exists('g:scheduled_colorscheme_secure_change_theme')
          colorscheme g:scheduled_colorscheme_secure_change_theme
        else
          colorscheme default
        endif
      endif
      let l:colorscheme_and_bg=split(a:colorscheme,"/")
      let l:cmd=""
      exe 'colorscheme '.l:colorscheme_and_bg[0]
      if len(l:colorscheme_and_bg) > 1
        exe 'set background='.l:colorscheme_and_bg[1]
      endif
      if len(s:scheduled_colorscheme_post_proc)
        exe s:scheduled_colorscheme_post_proc
      endif
    catch /E185:/
      echo 'Error: colorscheme not found:' a:colorscheme
    endtry
    " redraw
  endfu

  fu! s:HourColor(ft)
    let l:currft=( has_key(s:scheduled_colorscheme,a:ft) ? a:ft : '*' )
    if has_key(s:scheduled_colorscheme, l:currft)
      let l:l=len(s:scheduled_colorscheme[l:currft])
      if l:l
        let l:n=(24.0/l:l)
        let l:i=float2nr(trunc(str2nr(strftime('%H'))/l:n))
        call s:SetColorScheme(s:scheduled_colorscheme[l:currft][l:i])
      endif
    endif
  endfu

  command! -nargs=1 SetColorScheme call s:SetColorScheme(<q-args>)
  command! HourColorScheme call s:HourColor(&ft)
  command! -bar NextColorScheme echomsg "Before : ".g:colors_name
        \| echomsg "[Current : ".s:NextColor(1)."]"
        \| if ((s:last_colorsheme_index + 1) < len(s:colors))
          \| echomsg "Next : ".s:colors[s:last_colorsheme_index+1]
          \| endif
  command! -bar PrevColorScheme echomsg "Before : ".g:colors_name
        \| echomsg "[Current : ".s:NextColor(-1)."]" 
        \| if (s:last_colorsheme_index > 0)
          \| echomsg "Prev : ".s:colors[s:last_colorsheme_index-1]
          \| endif

  " 1 to change theme during a vim session instead of waiting to restart it
  if get(g:,'scheduled_colorscheme_change_during_session',0)
    augroup AutoTheme
      au!
      au BufEnter,BufRead,TabEnter * call <SID>HourColor(&ft)
    augroup END
  endif

  let g:loaded_accessibility_colortheme=1
endif

call s:HourColor(&ft)
"""
" ENDING CODE
"""
