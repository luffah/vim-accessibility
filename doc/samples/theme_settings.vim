fu! CustInitCursor()
  hi MatchParen gui=bold guifg=#f500e9 guibg=#000666 cterm=bold ctermfg=Magenta ctermbg=darkred
  hi CursorVisual guibg=#00d0cd guifg=#000666 ctermbg=DarkCyan ctermfg=blue
  hi Cursor guibg=#000000 guifg=#f500e9 ctermbg=LightMagenta ctermfg=black
  set guicursor=i:ver35-CursorVisual,v:hor35-CursorVisual,n-c:block-blinkon0-Cursor
endfu
let g:scheduled_colorscheme_plan={
      \'gui':{'*':['default/light','default/dark','desert']},
      \'gui-post':'call CustInitCursor()',
      \'term':{'*':['desert/dark','default/dark','desert/light']},
      \'term-post':'call CustInitCursor()',
      \}

" personnal recommendation
" let g:scheduled_colorscheme_plan={
"       \'gui':{'*':['gruvbox/dark','gruvbox/light','gruvbox/light','gruvbox/light','gruvbox/dark','gruvbox/dark']},
"       \'gui-post':'call CustInitCursor()',
"       \'term':{'*':['gruvbox/dark','gruvbox/dark','eldar']},
"       \'term-post':'call CustInitCursor()',
"       \}
" let g:gruvbox_contrast_light="hard"

if exists(':HourColorScheme')
  HourColorScheme
endif
