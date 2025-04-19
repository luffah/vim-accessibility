" accessiblity.vim -- Vim accessibility experiment 
" @Author:      luffah
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-29
" @Last Change: 2019-05-07
" @Revision:    2
" @Files
"   ../autoload/remanent.vim
"   ../autoload/colortheme.vim
"   ../autoload/KeyMap.vim
"   ../autoload/spelllang.vim
"   ../autoload/selection.vim
"   #../autoload/speak.vim
"   #../autoload/statusui.vim
" @AsciiArt
"             ,/,/,/,/
" V   ? ? ? ,/       ,/  ? ?
" I         | 0 .  0 '|)
" M         |   ^    '|
"       ww, `.______.'   ,ww 
"        \\_______\ \_____||
"       ,,,,,,,,,,,,,,,,,,,,
"      /ooo oooooo    ooooo/
"     /ooo ooooooooooooooo/
"    /ooo ooooooooooooooo/
"    ''''''''''''''''''''
" @Overview
" Set of scripts attempting to implement accessibility features with Vim.
"
" @global g:enable_accessibility_speak
" Define if speak plugin shall be enabled at startup.
" See |g:enable_accessibility_speak_keymap| too.
" Default 0.

" @global g:enable_accessibility_speak_keymap
" Define if speak shorcuts shall be enabled at startup.
" The Speak* commands still enabled.
" Default 0.

if get(g:,'enable_accessibility_speak', 0)
   call speak#enable(get(g:,'enable_accessibility_speak_keymap', 0))
endif

" @global g:enable_accessibility_colortheme
" Define if colorscheme automatic changes is enabled at startup.
" Default 0.
if get(g:,'enable_accessibility_colortheme', 0)
  call colortheme#enable()
endif

" @global g:enable_accessibily_remanent
" Define if remanent keys are enabled at startup. See |g:remanent_map|.
" Default 0.
if get(g:,'enable_accessibility_remanent',0)
  call remanent#enable(1)
endif
