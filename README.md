
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
    ```vim
    " <C-l> enter in command line mode from insert, normal, and visual mode
    " I is for insert mode, to use a one-shot normal mode key. (equivalent to '<C-o>:')
    cal Map('Enter command line' , '<C-l>'   , ':' , ['I','n','v'])
    
    " <A-Right> complete filename in insert and normal mode
    " 'i' is for insert mode 
    " '-n-%i%'  is for normal mode; but force the use of <C-x><C-f> in insert mode
    "           another way to say it : '%1%<C-x><C-f>' is replaced by 'i<C-x><C-f>'
    cal Map('Complete filename' , '<A-Right>' , 'pumvisible()? "<Cr>":"%1%<C-x><C-f>"'   , ['i' , '-n-%i%'])
    
    " Following example is usefull for re-discovering keys
    " When you hit <C-w>, a window with 'T -> Move to a new tab' is shown
    " If you hit 'T' then ':wincmd T' is applied
    " Too, if you hit 'w' then ':wincmd w' is applied (no need to document everything)
    cal Map('C-w'            , '<C-w>' , "<OneShot=wincmd>"  , ['n'])
    cal Map(':Move to a new tab' , 'T'       , "T" , ['n'])

    " Here a way to have a thousand of keybinds
    " It define a new keybind temporary layer,
    " '~' just say to not show the window which shows activated keybinds
    cal Map('~Emacs C-x'    , '<C-x>' , '<Layer>' , ['n'])
    cal Map(':Search file'    , '<C-f>' , '<ExitLayer>:e! %:p:h/*' , ['n'])
    ```
* Text to Speech dispatcher : keybinds and commands to make Vim speak<br>
    (require speech-dispatcher on linux - if you use Orca it shall be already installed)
    ```vim
    let g:speak_lang = "fr"
    let g:speak_voice_type = "female1"
    :SpeakLine " speak (send text at) the current line (to speech-dispatcher)
    :SpeakWORD " speak the following word in the text; intended to be followed by W
               "   to read text word by word
    ```

# License
[Vim](https://www.vim.org/) is distributed under [GPL-compatible Charityware License](https://www.gnu.org/licenses/vim-license.txt).
The content of this project itself is licensed under the [Creative Commons Attribution-ShareAlike 4.0](https://creativecommons.org/licenses/by-sa/4.0/) license,
and source code contained in this repository is licensed under the [GPLv3 license](./LICENSE).
