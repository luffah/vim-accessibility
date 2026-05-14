if 0 | endif
fu! s:compl(key)
  exe 'call feedkeys("a\<C-x>'.(a:key[0]=='<'?'\':'').a:key.'","n")'
endfu
command! -nargs=1 ComplCmd call s:compl(<q-args>)
call keybindings#Source(expand('<sfile>'))
finish
"
km(i) <C-x>    "Completion"                          <OneShot=ComplCmd>
km()  l       ":whole line"                          <C-l>
km()  n       ":word from current file"              <C-n>
km()  k       ":word from dictionnary"               <C-l>
km()  <C-t>   ":word from thesaurus"                 <C-t>
km()  i       ":word from current and included file" <C-i>
km()  t       ":tags"                                <C-]>
km()  f       ":file names"                          <C-f>
km()  d       ":definitions and macros"              <C-d>
km()  v       ":vim command-line"                    <C-v>
km()  u       ":user defened suggestion"             <C-u>
km()  o       ":omni"                                <C-o>
km()  s       ":spelling completion"                 s

