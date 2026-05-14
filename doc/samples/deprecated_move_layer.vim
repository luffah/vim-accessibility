" This file can be loaded with :source %
"
" Here, is an alternative way to use keybindings library.
" Changing layer for moving cursor is usually uncomfortable.
" That's why this layer is deprecated.
"
" Use arrows, remap l/j to <up>/<down>,
" and learn to use word and char moves (b e t f /)
" if you are not satisfied with hjkl.
"
" ---------------------------------------- "
" Alternatives moves, using a keybindings layer "
" ---------------------------------------- "

"let s:arrows='jkil' "azerty / qwerty
let s:arrows='tsdr' "bépo
let s:arrows=get(g:, 'arrows', s:arrows)
let s:orig_arrows=['<Left>', '<Down>', '<Up>', '<Right>']
let s:layer_mode=['n', 'v', 'o']
let g:km_layer_desc['move']=["","",
\"            ↑               This is the 'move' layer.",
\"          .---.             Usable as an alternative ",
\"          : ".s:arrows[2]." :             to 'hjkl'.",
\"      .---.---.---          ",
\"    ← : ".s:arrows[0]." : ".
\s:arrows[1]." : ".
\s:arrows[3]." : →       Commands " . s:arrows . " still available" ,
\"      '---'---'---'         by using " . toupper(s:arrows)  ,
\"            ↓               Modes: " . join(s:layer_mode,', '),
\""]

cal keybindings#Map('move'   , '<C-n>', "<Layer>" , ['n','vgv'] )
for i in range(0,len(s:arrows)-1)
  cal keybindings#Map(':-', s:arrows[i] , s:orig_arrows[i], s:layer_mode)
  cal keybindings#Map(':-', toupper(s:arrows[i]) , s:arrows[i] , s:layer_mode)
endfor
