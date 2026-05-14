" accessiblity.vim -- Vim accessibility experiment 
" @Author:      luffah
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-29
" @Last Change: 2026-05-14
" @Revision:    2
" @Files
"   ../autoload/colortheme.vim
"   ../autoload/keybindings.vim
"   ../autoload/spelllang.vim
"   ../autoload/selection.vim
"   ../autoload/statusui.vim
"   ../autoload/speak.vim
"
" Bienvenido. Welcome. Bienvenue. Willkommen. Benvenuto.
"
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
if exists("g:loaded_accessibility") || &cp || v:version < 700
  finish
endif
let g:loaded_accessibility = 1

if get(g:,'enable_accessibility_speak', 0)
   call speak#enable(get(g:,'enable_accessibility_speak_keymap', 0))
endif

" @global g:enable_accessibility_colortheme
" Define if colorscheme automatic changes is enabled at startup.
" Default 0.
if get(g:,'enable_accessibility_colortheme', 0)
  call colortheme#enable()
endif
