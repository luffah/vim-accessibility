if 0 | endif
fu! s:compl(key)
  exe 'call feedkeys("a\<C-x>'.(a:key[0]=='<'?'\':'').a:key.'","n")'
endfu
command! -nargs=1 ComplCmd call s:compl(<q-args>)
KeyMap <sfile>
finish
"
<C-x>    "Completion"         <OneShot=ComplCmd> %  i
l       ":whole line" <C-l> %
n       ":word from current file           " <C-n> %
k       ":word from dictionnary" <C-l> %
<C-t>   ":word from thesaurus    " <C-t> %
i       ":word from current and included file         " <C-i> %
t       ":tags         " <C-]> %
f       ":file names                    " <C-f> %
d       ":definitions and macros  " <C-d> %
v       ":vim command-line         " <C-v> %
u       ":user defened suggestion " <C-u> %
o       ":omni                    " <C-o> %
s       ":spelling completion  " s %

