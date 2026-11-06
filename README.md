# CLOSED CASE

Features are split in these plugins :

* [keybindings](https://github.com/luffah/vim-keybindings) : alias and data format to register complex keybindings
* [autoloader](https://github.com/luffah/vim-autoloader) : for loading vim scripts given file openned
* [colortheme](https://github.com/luffah/vim-colortheme) : for a dynamic colortheme setup (based on hour or filetype)
* [speak](https://github.com/luffah/vim-speak) : minimalist screen reader
* [largefile](https://github.com/luffah/vim-largefile) : for viewing large files without slowing down
* [spelllang](https://github.com/luffah/vim-spelllang) : for automatic setting of spell lang
* [selection](https://github.com/luffah/vim-selection) : lib for easily fetching selection content

# Example installation

```sh
mkdir -p ~/.vim/pack/ui/start/
cd ~/.vim/pack/ui/start
for i in keybindings autoloader spelllang selection largefile; do
    wget https://github.com/luffah/vim-$i/archive/refs/heads/main.zip
    unzip main.zip
done
rm main.zip
```

```vim
# init.vim
packloadall

AutoLoad FileType   html,css,php,javascript,xml  $HOME/.vim/web.vim
call keybindings#Source($HOME . '/.vim/km.vimkm')
```
```vim
# km.vimkm

alias vr vertical resize
alias hr resize

km(i<Esc>,n)   <C-S-Up>   "Del blank line aftr"    m`:+g/\m^\s*$/d<Cr>``:noh<Cr>

km(i<Esc>,n)   <C-S-Down> "Ins blank line aftr"    :set paste<Cr>m`o<Esc>``:set nopaste<Cr>
```

License GPLv3.
