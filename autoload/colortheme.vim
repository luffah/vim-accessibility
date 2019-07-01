" colortheme.vim -- Vim lib for automatic theme change given hour
" @Author:      luffah (luffah AT runbox com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-26
" @Last Change: 2018-03-29
" @Revision:    1
"
" @Customize |:HourColorScheme| *colorscheme-plan*
" Add following lines in your .vimrc to setup your own colorscheme plan: ```
"    " Post theme customisation model
"     fu! InitCursor()
"     hi MatchParen gui=bold guifg=#f500e9 guibg=#000666 cterm=bold ctermfg=Magenta ctermbg=darkred
"     hi CursorVisual guibg=#00d0cd guifg=#000666 ctermbg=DarkCyan ctermfg=blue
"     hi Cursor guibg=#000000 guifg=#f500e9 ctermbg=LightMagenta ctermfg=black
"     set guicursor=i:ver35-CursorVisual,v:hor35-CursorVisual,n-c:block-blinkon0-Cursor
"     endfu
"    
"    " File and Time-relative based colorscheme 
"     let g:scheduled_colorscheme_plan={
"       'gui':{'*':['molokai','molokai','gruvbox','gruvbox/dark','molokai']}
"       'gui-post-proc':'call InitCursor()',
"       'term':{'*':['molokai-term','molokai-term','gruvbox/dark','gruvbox/dark','molokai-term']}
"       'term-post-proc':'call InitCursor()'}
"     let g:scheduled_colorscheme_secure_change=1
"     
"    " Scheduled changement of colorscheme.
"    " Hours are implicits given the number of elements
"    " 2 :   0h-12h , 12h-0h
"    " 3 :   0h-8h  , 8h-16h ,  16h-0h
"    " 4 :   0h-6h  , 6h-12h ,  12h-18h , 18h-0h
"    " 5 :   1h-5h  , 5h-10h ,  10h-15h , 15h-20h  ,  20h-1h
"    " 6 :   0h-4h  , 4h-8h  ,  8h-12h  , 12h-14h  ,  14h-18h , 18h-20h , 20h-0h
"```

"""
" BEGINNING CODE
"""
if (v:version < 700 || &cp)
  finish
endif

if !exists('g:scheduled_colorscheme_plan')
  finish
endif

" Ensure this script is loaded after "syntax on" instruction.
if &syntax == 'OFF' || &syntax == ''
  syntax on
endif


let s:default_term_post='"Taking the colorscheme as is'
let s:default_gui_post=s:default_term_post

" @global g:scheduled_colorscheme_plan
"Dictionnary to configure the colorscheme changes raised by |HourColorScheme|.
"It contains lists of colorscheme that partition the day.
" (e.g. : ['am-colorscheme','pm-colorscheme'])
"Keys for defining the list of colorscheme (linked to version of Vim )
" are 'gui' (GVim...), 'term' (vim, nvim-qt..) and 'gui-post-proc',
" 'term-post-proc' to customize the theme.
let g:scheduled_colorscheme_plan=get(g:,'scheduled_colorscheme_plan', {})
if has('gui_running')
  let s:scheduled_colorscheme=get(g:scheduled_colorscheme_plan,'gui',{})
  let s:scheduled_colorscheme_post_proc=get(g:scheduled_colorscheme_plan,'gui-post',s:default_gui_post) 
else 
  set t_Co=256
  let s:scheduled_colorscheme=get(g:scheduled_colorscheme_plan,'term',{})
  let s:scheduled_colorscheme_post_proc=get(g:scheduled_colorscheme_plan,'term-post',s:default_term_post)
endif


" @global g:background
"Usefull for special weather cases, like heat waves to use 'dark' or 'light'
"background used by |HourColorScheme|.

" @global g:colortheme_hour
"Usefull for special weather cases, like heat waves to lock hour (0-23) used
"by |HourColorScheme|.

let s:all_colorschemes=map(
      \split(globpath(&rtp, 'colors/*.vim'),"\n"),
      \"split(v:val,'/')[-1][0:-5]")

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
  let l:curr=split(execute("colorscheme"),'\n')[0]
  let l:colorscheme_and_bg=split(a:colorscheme,"/")
  let l:bg_mode = ''
  if l:colorscheme_and_bg[0] == l:curr
    if len(l:colorscheme_and_bg) > 1 && l:colorscheme_and_bg[1] != &background
      exe 'set background='.l:colorscheme_and_bg[1]
    endif
  elseif match(s:all_colorschemes,l:colorscheme_and_bg[0]) > -1
    try
      " 1 to force default theme before loading a new theme (for partial themes)
      if get(g:,'scheduled_colorscheme_secure_change',0)
        if exists('g:scheduled_colorscheme_secure_change_theme')
          colorscheme g:scheduled_colorscheme_secure_change_theme
        else
          colorscheme default
        endif
      endif
      let l:cmd=""
      exe 'colorscheme '.l:colorscheme_and_bg[0]
      let l:bg_mode = l:colorscheme_and_bg[1]
    catch /E185:/
      echo 'Error: colorscheme not found:' a:colorscheme
    endtry
    if len(s:scheduled_colorscheme_post_proc)
      exe s:scheduled_colorscheme_post_proc
    endif
  endif
  if exists('g:background')
    let l:bg_mode=g:background
  endif
  if len(l:bg_mode) > 1
    exe 'set background='.l:bg_mode
  endif
endfu

fu! s:HourColor(ft)
  let l:currft=( has_key(s:scheduled_colorscheme,a:ft) ? a:ft : '*' )
  if has_key(s:scheduled_colorscheme, l:currft)
    let l:l=len(s:scheduled_colorscheme[l:currft])
    if l:l
      let l:n=(24.0/l:l)
      if exists('g:colortheme_hour')
        let l:i=float2nr(trunc(str2nr(g:colortheme_hour)/l:n))
      else
        let l:i=float2nr(trunc(str2nr(strftime('%H'))/l:n))
      endif
      call s:SetColorScheme(s:scheduled_colorscheme[l:currft][l:i])
    endif
  endif
endfu

"@function colortheme#enable()
" Enable |SetColorScheme|, |HourColorScheme|,
"        |NextColorScheme|, |PrevColorScheme|.
" Enable automatic theme change.
" See |g:scheduled_colorscheme_plan|.
fu! colortheme#enable()

" @command :SetColorScheme [colorscheme]
" Activate colorscheme
" and call -post-proc from |g:scheduled_colorscheme_plan|.
" See also |g:scheduled_colorscheme_secure_change|.
  command! -nargs=1 -complete=color SetColorScheme call s:SetColorScheme(<q-args>)

" @command :HourColorScheme
" Activate colorscheme corresponding
" to the hour and the type of the current file,
" then  call -post-proc
" See |g:scheduled_colorscheme_plan|.
  command! HourColorScheme call s:HourColor(&ft)

" @command :NextColorScheme
" Shows colorschemes one by one.
  command! -bar NextColorScheme echomsg "Before : ".g:colors_name
        \| echomsg "[Current : ".s:NextColor(1)."]"
        \| if ((s:last_colorsheme_index + 1) < len(s:colors))
          \| echomsg "Next : ".s:colors[s:last_colorsheme_index+1]
          \| endif

" @command :PrevColorScheme
" Shows colorschemes one by one (reversed).
  command! -bar PrevColorScheme echomsg "Before : ".g:colors_name
        \| echomsg "[Current : ".s:NextColor(-1)."]" 
        \| if (s:last_colorsheme_index > 0)
          \| echomsg "Prev : ".s:colors[s:last_colorsheme_index-1]
          \| endif

  " 1 to change theme during a vim session instead of waiting to restart it
  augroup ColorTheme
    au!
    if get(g:,'scheduled_colorscheme_change_during_session',0)
      au TabEnter * call <SID>HourColor(&ft)
    endif
    au SourceCmd  init.vim call <SID>HourColor(&ft) |  exe s:scheduled_colorscheme_post_proc
    au SourceCmd  .vimrc call <SID>HourColor(&ft) |  exe s:scheduled_colorscheme_post_proc
    au ColorScheme  * exe s:scheduled_colorscheme_post_proc
    
    " Hardcore ugly secure cursor preservation
    au BufEnter * exe s:scheduled_colorscheme_post_proc
  augroup END
  call s:HourColor(&ft)
endfu

"""
" ENDING CODE
"""
