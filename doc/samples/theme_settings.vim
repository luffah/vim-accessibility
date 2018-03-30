fu! CustInitCursor()
  hi MatchParen gui=bold guifg=#f500e9 guibg=#000666 cterm=bold ctermfg=Magenta ctermbg=darkred
  hi Cursor  guibg=#66ffff guifg=#000666 term=reverse ctermbg=Cyan ctermfg=blue
  hi CursorVisual guibg=#66ffff guifg=#000666 ctermbg=Cyan ctermfg=blue
  hi CursorInsert guibg=#00d0cd ctermbg=DarkCyan
  hi CursorNormal guifg=#000000 guibg=#f500e9 ctermbg=LightMagenta ctermfg=black
  set guicursor=i:ver35-CursorInsert,v:hor35-CursorVisual,n-c:block-blinkon0-CursorNormal
endfu
let g:scheduled_colorscheme_plan={
      \'gui':{'*':['default/light','default/dark','eldar']},
      \'gui-post':'call CustInitCursor()',
      \'term':{'*':['desert/dark','default/dark','eldar/light']},
      \'term-post':'call CustInitCursor()',
      \}
