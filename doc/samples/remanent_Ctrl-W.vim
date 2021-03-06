if 0 | endif
" to change the current split direction :
fu! SwapView(direction)
 let l:bu=bufnr('%')
 wincmd c
 exe 'wincmd '.a:direction
 exe 'buffer '.l:bu
 wincmd x
 wincmd W
endfu
KeyMap <sfile>
finish
" Ctrl-W as a remanent key
" this file can be loaded with :KeyMap %
"
<C-w>    "C-w"         <OneShot=wincmd> %  n
r       ":Rotate                    " r %
x       ":(count)Exchange           " x %
<Left>  ":Move (arrow)              " <Left> %
T       ":Move to a new tab         " T %
=       ":Resize equally all windows" = %
+       ":Increase height           " + %
-       ":Decrease height           " - %
< «     ":Decrease Width            " < %
> »     ":Increase Width            " > %
_       ":(count)Set height         " _ %
<bar>   ":(count)Set width          " <bar> %
V       ":Make split vertical       " call SwapView("v") % :
H       ":Make split horizontal     " call SwapView("s") % :
