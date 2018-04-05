" KeyMap.vim -- Vim lib for automatic spell lang definition
" @Author:      luffah (luffah AT runbox com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-29
" @Last Change: 2018-03-29
" @Revision:    1
if exists('g:loaded_accessibility_lang')
    finish
endif

let s:syslang=strpart(expand("$LANG"),0,2)

" most people have one of this
let s:langs=['ca', 'cs', 'de', 'en', 'es', 'fr', 'it', 'ja', 'ko', 'pt', 'ru', 'zh']

" locally known locales
call extend(s:langs, map(
      \split(globpath(&rtp, "spell/*\.spl"),"\n"),
      \{i, v -> substitute(v,'\(.*/\)\(\l\{2}\)\..*','\2','')}))

let s:langs=uniq(sort(s:langs))

fu! s:GetSpellLang(filename)
  let l:lang=''
  let l:path=split(
        \( match(a:filename,'/') == -1 ? getcwd().'/' : '' ). a:filename,'/')
  let l:file=remove(l:path,-1)
  let l:nblp=len(l:path) - 1
  let l:localepos=match(l:path,'locale.\?')
  let l:langpos=match(l:path,'^\l\{2}$',l:localepos+1)
  if l:langpos > -1 && l:langpos <= l:nblp && l:langpos > l:nblp - 2
    let l:lang=l:path[l:langpos]
  else
    let l:parts=split(l:file,'\.')
    if len(l:parts) > 1
      let l:lang=l:parts[-2]
    endif
  endif
  if l:lang =~ '^\l\{2}\(_\u\{2}\)\?$' && match(s:langs,'^'.l:lang)
    return l:lang
  else
    return ''
  endif
endfu

fu! s:SetSpellLang(filename,...)
  let l:defaultlang=len(a:000)>0?a:000[0]:''
  let l:lang = s:GetSpellLang(a:filename)
  if len(l:lang)
    exe 'setlocal spelllang='.l:lang
    exe 'setlocal spell'
  elseif len(l:defaultlang)
    exe 'setlocal spelllang='.l:lang
    exe 'setlocal spell'
  endif
endfu

augroup SpellLang
au BufRead *.po call <SID>SetSpellLang(expand("<afile>"))
au BufRead *.md call <SID>SetSpellLang(expand("<afile>"))
au BufRead *.rst call <SID>SetSpellLang(expand("<afile>"))
au BufRead  Readme* call <SID>SetSpellLang(expand("<afile>"))
au Filetype text call <SID>SetSpellLang(expand("<afile>"))
au Filetype zim call <SID>SetSpellLang(expand("<afile>"),s:syslang)
augroup END
let g:loaded_accessibility_lang=1
