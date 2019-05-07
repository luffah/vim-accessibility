" accessiblity.vim -- Vim accessible for every human
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
"        +---------------------+            ,-.  ,-.
"        |<C-x><C-V>  bla bla  |    ????   /  | /  | Chupaaka
"        |<C-W>J      bla      |          | 0 .  0 '.    ,. ka ka
"        |________________HELP_|          |   ^     |  .'.'
"        |fu#                  |          `.______.' .'.'
"        |~                    |      ___  / /_ \ \ _____
"        |"file.txt" [New file]|     /JJJJ'-'JJJ'-'JJJJJJ/
"        +---------------------+    /JJJJJJJJJJJJJJJJJJJ/
"              ___/   \___          '------------------'
"
" _(Chupaaka doesn't need Vim, she need a non-hostile environment.)_
"
" @Overview
" 
" This project group usefull scripts to make Vim more accessible.
" The scripts themselves are not the easier to use, but allow to prepare
" a kind user interface.
"
let s:path=expand('<sfile>:p:h:h')
exe 'source '.s:path.'/autoload/KeyMap.vim'
exe 'source '.s:path.'/autoload/spelllang.vim'
exe 'source '.s:path.'/autoload/selection.vim'

" @global g:disable_accessibility_speak
" Define if speak plugin shall not be enabled at startup.
" See |g:disable_accessibility_speak_keymap| too.
" Default 0.

" @global g:disable_accessibility_speak_keymap
" Define if speak shorcuts shall not be enabled at startup.
" The Speak* commands still enabled.
" Default 0.

if !get(g:,'disable_accessibility_speak',0)
   call speak#enable()
endif

" @global g:disable_accessibility_colortheme
" Define if colorscheme automatic changes is not be enabled at startup.
" Default 0.
if !get(g:,'disable_accessibility_colortheme',0)
  call colortheme#enable()
endif

" @command Multitap
" Allow to use keypad as a multitap input (experimental)
command! Multitap call predictive#multitap_mode()

" @global g:remanent_enable
" Define if remanent keys are enabled at startup. See |g:remanent_map|.
" Default 0.
let g:remanent_enable=get(g:,'enable',0)
if g:remanent_enable
  call remanent#enable(1)
endif
