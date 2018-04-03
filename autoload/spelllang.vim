" KeyMap.vim -- Vim lib for automatic spell lang definition
" @Author:      luffah (luffah AT runbox com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-29
" @Last Change: 2018-03-29
" @Revision:    1
if exists('g:loaded_accessibility_lang') || &compatible
    finish
endif

let s:deflang='en'

fu! s:GetSpellLang(filename,defaultlang)
  let l:lang=''
  let l:path=split(a:filename,'/')
  let l:lpos=match(l:path,'locale.\?')
  if l:lpos > -1
    let l:lang=l:path[l:lpos+2]
  else
    let l:parts=split(l:path[-1],'\.')
    if len(l:parts) > 1
      let l:lang=l:parts[-2]
    endif
  endif
  if l:lang !~ '^\l\{2}\(_\u\{2}\)\?$'
    let l:lang=a:defaultlang
  endif
  return l:lang
endfu

augroup SpellLang
au BufRead *.po exe 'setlocal spelllang='.<SID>GetSpellLang(expand("<afile>"), s:deflang)
      \.' | setlocal spell'
au BufRead *.md exe 'setlocal spelllang='.<SID>GetSpellLang(expand("<afile>"), s:deflang)
      \.' | setlocal spell'
au BufRead *.rst exe 'setlocal spelllang='.<SID>GetSpellLang(expand("<afile>"),s:deflang)
      \.' | setlocal spell'
au Filetype text exe 'setlocal spelllang='.<SID>GetSpellLang(expand("<afile>"),s:deflang)
      \.' | setlocal spell'
au BufRead  Readme* exe 'setlocal spelllang='.<SID>GetSpellLang(expand("<afile>"),s:deflang)
      \.' | setlocal spell'
au Filetype zim exe 'setlocal spelllang='.<SID>GetSpellLang(expand("<afile>"),strpart(expand("$LANG"),0,2))
      \.' | setlocal spell'
augroup END
let g:loaded_accessibility_lang=1
