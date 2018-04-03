
<a rel="license" href="https://creativecommons.org/licenses/by-sa/4.0/">
<img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png"></a>
<a rel="license" href="./LICENSE"><img src="https://www.gnu.org/graphics/gplv3-88x31.png" alt="License GPLv3"></a>

# Vim accessible for every human
_(Cats doesn't need Vim, they only need a non-hostile environment.)_

This project group all the things needed to make Vim more accessible for people.
* Remanent keys : for keeping your pinkies safe<br>
  ```vim
    " Map `<Space>` to be the remanent key for Shift, and `<Space><Space>` to be the remanent key for Ctrl.
    " ['n'] is for normal mode
     let g:sticky_map = {
      \'shift': { '<Space>':['n'] },
      \'ctrl': { '<Space><Space>':['n'] },
      \})
  ```
* Documented keymapping : to force yourself to document your keybind and allow to create tutorials<br>
    In short, it can be written like that :<br>
    ```vim
    " Here 8 simples mapping in 2 lines
    " Keys     ''Description ''        Vim action                      % modes
    <C-l> <A-l> "Enter command line"   :                               % I n v
    <A-Right>   "Compl. filename " pumvisible()?"<Cr>":"%1%<C-x><C-f>" % i -n-%i%
    
    " Want more ? you forgot your shortcuts ? do you want to see the list.
    " You can ':call KeyMap#PrintCurrentLayer()',
    " But why not grouping shortcuts by categories ?
    " -> a tutorial mode for <C-w>
    <C-w>       "C-w"                  <OneShot=wincmd>                %  n
    T           ":Move to a new tab"   T                               %
    " -> an emacs like layer
    <C-x>       "~Emacs C-x"           <Layer>                         % n
    <C-f>       ":Search file"         <ExitLayer>:e! %:p:h/*          % n
    ```
    <details>
    <summary>See the details about keymapping</summary>
    Every lines above are a short format the following lines:<br>

    ```vim
    " <C-l> enter in command line mode from insert, normal, and visual mode
    " cal ..Map('Description', keys, action, modes_and_things_related_to_the_mode)
    cal KeyMap#Map('Enter command line' , ['<C-l>','<A-l>']   , ':' , ['I','n','v'])
    " I is for insert mode, to use a one-shot normal mode key. (equivalent to '<C-o>:')
    
    " <A-Right> complete filename in insert and normal mode
    " 'i' is for insert mode 
    " '-n-%i%'  is for normal mode; but force the use of <C-x><C-f> in insert mode
    "           another way to say it : '%1%<C-x><C-f>' is replaced by 'i<C-x><C-f>'
    cal KeyMap#Map('Complete filename' , '<A-Right>' , 'pumvisible()? "<Cr>":"%1%<C-x><C-f>"'   , ['i' , '-n-%i%'])
    
    " Following example is usefull for re-discovering keys
    " When you hit <C-w>, a window with 'T -> Move to a new tab' is shown
    " If you hit 'T' then ':wincmd T' is applied
    " Too, if you hit 'w' then ':wincmd w' is applied (no need to document everything)
    cal KeyMap#Map('C-w'            , '<C-w>' , "<OneShot=wincmd>"  , ['n'])
    cal KeyMap#Map(':Move to a new tab' , 'T'       , "T" , [])

    " Here a way to have a thousand of keybinds
    " It define a new keybind temporary layer,
    " '~' just say to not show the window which shows activated keybinds
    cal KeyMap#Map('~Emacs C-x'    , '<C-x>' , '<Layer>' , ['n'])
    cal KeyMap#Map(':Search file'    , '<C-f>' , '<ExitLayer>:e! %:p:h/*' , ['n'])
    ```
   </details><br>

* Text to Speech dispatcher : keybinds and commands to make Vim speak<br>
    (require speech-dispatcher on linux - if you use Orca it shall be already installed)
    ```vim
    "let g:speak_lang = "fr" " automatically set  by detecting the spell lang
    "let g:speak_voice_type = "female1" " default
    ```
    `:SpeakLine` speak (send text at) the current line (to speech-dispatcher).<br>
    `:SpeakWORD` speak the following word in the text; intended to be followed by W in order to read text word by word.<br>
    <br>
    Anyway, in a GVim just hit `<C-s>` (Ctrl + s) to toggle a screen reader mode.

# Installation
Get the repository.
```sh
# 'ui' is abitrary chosen for 'user interface'
mkdir -p ~/.vim/pack/ui/start
git clone https://github.com/luffah/vim-accessibility.git ~/.vim/pack/ui/start/accessibility
```
```vim
packloadall

" Examples
let mapleader=","
KeyMap $VIMPLUGINS/vim-accessibility/doc/samples/common.vimkm
KeyMap $VIMPLUGINS/vim-accessibility/doc/samples/bepo.vimkm
```

<details>
<summary>My Vim doesn't support +packages</summary>
If you have an old version of Vim (< 8), it is useless to create `~/.vim/pack/`. Just use the path where you install your plugins.

```vim

" let $VIMPLUGINS = <Path to directory containing your plugins>
"
" [Optional]
" This allows to access to documentation and some syntax sugar.
" Add to runtime path
set rtp+=$VIMPLUGINS/vim-accessibility
" Activate plugins
filetype indent plugin on

" [Required]
" Given plugins commands are only usable after initialization
" Sourcing the files, ensure KeyMap is known.
so $VIMPLUGINS/vim-accessibility/loader.vim
" Examples
let mapleader=","
KeyMap $VIMPLUGINS/vim-accessibility/doc/samples/common.vimkm
KeyMap $VIMPLUGINS/vim-accessibility/doc/samples/bepo.vimkm
```
</details><br>

# License
[Vim](https://www.vim.org/) is distributed under [GPL-compatible Charityware License](https://www.gnu.org/licenses/vim-license.txt).<br>
The content of this project itself is licensed under the [Creative Commons Attribution-ShareAlike 4.0](https://creativecommons.org/licenses/by-sa/4.0/) license,<br>
and source code contained in this repository is licensed under the [GPLv3 license](./LICENSE).
