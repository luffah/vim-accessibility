" selection.vim  -- Vim lib to get selected text
" @Author:      luffah
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-30
" @Last Change: 2018-06-10
" @Revision:    2
fu! s:sort2num(a,b)
  return (a:a > a:b) ? [a:b, a:a] : [a:a, a:b]
endfu

fu! s:getTextInLines(lstart,lend)
  let [l:la,l:lz]=s:sort2num(a:lstart, a:lend)
  let l:ret=getline(l:la)
  let l:la+=1
  while  l:la <= l:lz
    let l:ret.="\n".getline(l:la)
    let l:la+=1
  endwhile
  return l:ret
endfu

fu! s:getTextInBlock(lstart,cstart,lend,cend)
  let [l:la,l:lz]=s:sort2num(a:lstart, a:lend)
  let [l:ca,l:cz]=s:sort2num(a:cstart, a:cend)
  let l:ret=s:strpart(getline(l:la),l:ca-1,l:cz-1)
  let l:la+=1
  while  l:la <= l:lz
    let l:ret.="\n".s:strpart(getline(l:la),l:ca-1,l:cz-1)
    let l:la+=1
  endwhile
  return l:ret
endfu

fu! s:strpart(l,b,...)
  " usage of this version of strpart support unicode and is slightly different
  " instead of giving lenght as second arg, give the last char position
  " given it begin by 0
  " a simple operation to adapt the code is
  " strpart(l,b,e) is eq to s:strpart(l,b,b+e-1)
  let l:l=split(a:l,'\zs')
  let l:ret=exists('a:1')?l:l[a:b:a:1]:l:l[a:b:]
  return join(l:ret,'')
endfu
"echo   strpart("alpharrrr du centaure",3,5)
"echo s:strpart("alpharrrr du centaure",3,7)
"echo   strpart("alpha½¾¿À du centaure",3,5)
"echo s:strpart("alpha½¾¿À du centaure",3,7)
"finish
fu! s:getTextInRange(lstart,cstart,lend,cend)
  if (a:lstart < a:lend)
    let l:la=a:lstart
    let l:ca=a:cstart
    let l:lz=a:lend
    let l:cz=a:cend
  else
    let l:la=a:lend
    let l:ca=a:cend
    let l:lz=a:lstart
    let l:cz=a:cstart
  endif

  let l:ret=s:strpart(getline(l:la),l:ca-1)
  let l:i=(l:la+1)
  while  l:i < l:lz
    let l:ret.="\n".getline(l:i)
    let l:i+=1
  endwhile
  let l:ret.="\n".s:strpart(getline(l:i),0,l:cz-1)
  return l:ret
endfu

fu! s:get_text_in_sel(mode,y,x,y2,x2)
  let l:ret=''
  if (a:mode==#"V")
    let l:ret=s:getTextInLines(a:y,a:y2)
  elseif (a:y2 == a:y) || (a:mode==?"")
    let l:ret=s:getTextInBlock(a:y,a:x,a:y2,a:x2)
  elseif (a:mode==#'v')
    let l:ret=s:getTextInRange(a:y,a:x,a:y2,a:x2)
  endif
  return l:ret
endfu

" @function selection#vgetSelectedText()
" Return selected text (string) while visual mode is activated.
fu! selection#vgetSelectedText()
  return s:get_text_in_sel(mode(),line('v'),virtcol('v'),line('.'),virtcol('.'))
endfu

" @function selection#getSelectedText()
" Return selected text (string).
fu! selection#getSelectedText()
  return s:get_text_in_sel(visualmode(),line("'<") ,virtcol("'<") ,line("'>") ,virtcol("'>"))
endfu

" @function selection#Status()
" Return a string showing selection size according to its type:
" * if is full line (V), return (line width, selection height)
" * if is square (), return (selection width, selection height)
" * if is per character (v), return the number of characters selected
fu! selection#Status()
  let l:mode=mode()
  let l:ret=''
  if (l:mode!='i')
    if (l:mode!='n')
      let l:lv=line('v')
      let l:li=line('.')
      let l:cv=virtcol('v')
      let l:ci=virtcol('.')
      if (l:mode==?"")
        let l:ret=' ['.(abs(l:ci-l:cv)+1).','.(abs(l:li-l:lv)+1).']'
      elseif (l:mode==#"V")
        let l:ret=' ['.(virtcol('$')-1).','.(abs(l:li-l:lv)+1).']'
      elseif (l:mode==#'v')
        if l:li == l:lv
          let l:ret=' ['.(abs(l:ci-l:cv)+1).'ch]'
        else
          let l:ret=' ['.len(s:getTextInRange(l:lv,l:cv,l:li,l:ci)).'ch]'
        endif
      endif
    endif
  endif
  return l:ret
endfu

" About visual star
" Recommended:
" vnoremap <silent> * :call setreg("/", substitute(selection#getSelectedText(), '\_s\+', '\\_s\\+', 'g'))<Cr>n

" Alternatives:
" Search for selected text, forwards or backwards.
"vnoremap <silent> * :<C-U>
  " \let s:old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  " \gvy/<C-R><C-R>=substitutete(
  " \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  " \gV:call setreg('"', old_reg, old_regtype)<CR>
"vnoremap <silent> # :<C-U>
  " \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  " \gvy?<C-R><C-R>=substitute(
  " \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  " \gV:call setreg('"', old_reg, old_regtype)<CR>

"fu! s:getSelectedText()
"  let l:old_reg = getreg('"')
"  let l:old_regtype = getregtype('"')
"  norm gvy
"  let l:ret = getreg('"')
"  call setreg('"', l:old_reg, l:old_regtype)
"  exe "norm \<Esc>"
"  return l:ret
"endfu
"vnoremap <silent> * :call setreg("/", substitute(<SID>getSelectedText(), '\_s\+', '\\_s\\+', 'g'))<Cr>n
