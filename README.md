# Set of scripts attempting to implement accessibility features

NOTE: new version : dropped the old format

This project group things intended to make Vim more accessible for people.<br>

* Text to Speech dispatcher : keybinds and commands to make Vim speak<br>
    (require speech-dispatcher on linux - if you use Orca it shall be already installed)
    ```vim
    " (can setup lang and voice with  g:speak_lang and g:speak_voice_type
    "  else use spd-say default)
    ```
    `:SpeakLine` speak (send text at) the current line (to speech-dispatcher).<br>
    `:SpeakWORD` speak the following word in the text; intended to be followed by W in order to read text word by word.<br>
    <br>
    Anyway, in a GVim just hit `<C-s>` (Ctrl + s) to toggle a screen reader mode.<br>
    This probably needs to be improved (Emacs-speak users suggestions are welcome).

* Easy-to-use alias feature which are equivalent of cabbrev including expansion condition<br> 
    In short, it can be written like that (vimkm format):<br>
    ```vim
    alias qa           confirm qa
    alias tnc          tabnew $VIMPWD/<C-d>
    alias tn/   <cmap> tabnew  /<C-d>
    alias tn.   <cmap> tabnew ./<C-d>
    ```

* Documented keymapping : to force yourself to document your keybind and allow to create tutorials<br>
    In short, it can be written like that (vimkm format) :<br>
    ```vim
    " Here 8 mapping in 2 lines
    "Modes are separated by ','; first char is mode; next chars are some action to prepend
    "Modes         " Keys     ''Description ''        Vim action
    km(i<c-o>,n,v) <C-l> <A-l> "Enter command line"   :
    km(i,ni)       <A-Right>   "Compl. filename "     <expr> pumvisible()?"<Cr>":"<C-x><C-f>"
    
    " ':call keybindings#PrintCurrentLayer()' to see the list of key binding
    " to group shortcuts by categories :
    " example 1 : a tutorial mode for <C-w>
    km(n)      <C-w>       "C-w"                  <OneShot=wincmd>
    km()       T           ":Move to a new tab"   T
    " example 2 : emacs-like behavior 
    km(n)     <C-x>       "~Emacs C-x"           <Layer>
    km()      <C-f>       ":Search file"         <ExitLayer>:e! %:p:h/*
    ```
    <details>
    <summary>See the details about keymapping</summary>
    Every lines above are a short format the following lines (vim script):<br>

    ```vim
    " <C-l> enter in command line mode from insert, normal, and visual mode
    " cal ..Map('Description', keys, action, modes_and_things_related_to_the_mode)
    cal keybindings#Map('Enter command line' , ['<C-l>','<A-l>']   , ':' , ['i<c-o>','n','v'])
    
    " <A-Right> complete filename in insert and normal mode
    " 'i' is for insert mode 
    " 'ni'  is for normal mode; but force the use of <C-x><C-f> in insert mode
    cal keybindings#Map('Complete filename' , '<A-Right>' , '<expr> pumvisible()? "<Cr>":"<C-x><C-f>"'   , ['i' , 'ni'])
    
    " Following example is usefull for re-discovering keys
    " When you hit <C-w>, a window with 'T -> Move to a new tab' is shown
    " If you hit 'T' then ':wincmd T' is applied
    " Too, if you hit 'w' then ':wincmd w' is applied (no need to document everything)
    cal keybindings#Map('C-w'            , '<C-w>' , "<OneShot=wincmd>"  , ['n'])
    cal keybindings#Map(':Move to a new tab' , 'T'       , "T" , [])

    " Here a way to have a thousand of keybinds
    " It define a new keybind temporary layer,
    " '~' just say to not show the window which shows activated keybinds
    cal keybindings#Map('~Emacs C-x'    , '<C-x>' , '<Layer>' , ['n'])
    cal keybindings#Map(':Search file'    , '<C-f>' , '<ExitLayer>:e! %:p:h/*' , ['n'])
    ```
   </details><br>

* Limitation and security : alias and keybindings do not use recursive mapping by default

# Installation
Get the repository.
```sh
# 'ui' is abitrary chosen for 'user interface'
mkdir -p ~/.vim/pack/ui/start
git clone https://github.com/luffah/vim-accessibility.git ~/.vim/pack/ui/start/accessibility
```
```vim
packloadall

" Example
call keybindings#Source('$VIMPLUGINS/vim-accessibility/doc/samples/common.vimkm')
```

<details>
<summary>My Vim doesn't support +packages</summary>
If you have an old version of Vim (< 8), it is useless to create `~/.vim/pack/`. Just use the path where you install your plugins.

```vim
" let $VIMPLUGINS = <Path to directory containing your plugins>
"
" [Optional]
" This allows to access to documentation.
" Add to runtime path
set rtp+=$VIMPLUGINS/vim-accessibility
" Activate plugins
filetype indent plugin on

" [Required]
so $VIMPLUGINS/vim-accessibility/loader.vim
" Example
call keybindings#Source('$VIMPLUGINS/vim-accessibility/doc/samples/common.vimkm')
```
</details><br>

# License
[Vim](https://www.vim.org/) is distributed under [GPL-compatible Charityware License](https://www.gnu.org/licenses/vim-license.txt).<br>
The content of this project itself is licensed under the [Creative Commons Attribution-ShareAlike 4.0](https://creativecommons.org/licenses/by-sa/4.0/) license,<br>
and source code contained in this repository is licensed under the [GPLv3 license](./LICENSE).
