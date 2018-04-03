" selection.vim  -- Vim lib to get selected text -- part of accessibility/speak
" @Author:      luffah (luffah AT runbox com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-30
" @Last Change: 2018-03-30
" @Revision:    1
fu! s:getTextInLines(lstart,lend)
  if (a:lstart < a:lend)
    let l:la=a:lstart
    let l:lz=a:lend
  else
    let l:la=a:lend
    let l:lz=a:lstart
  endif

  let l:ret=getline(l:la)
  let l:la+=1
  while  l:la <= l:lz
    let l:ret.="\n".getline(l:la)
    let l:la+=1
  endwhile
  return l:ret
endfu

fu! s:getTextInBlock(lstart,cstart,lend,cend)
  if (a:lstart < a:lend)
    let l:la=a:lstart
    let l:lz=a:lend
  else
    let l:la=a:lend
    let l:lz=a:lstart
  endif
  if (a:cstart < a:cend)
    let l:ca=a:cstart
    let l:cz=a:cend
  else
    let l:ca=a:cend
    let l:cz=a:cstart
  endif

  let l:len=l:cz-l:ca+1
  let l:ret=strpart(getline(l:la),l:ca-1,l:len)
  let l:la+=1
  while  l:la <= l:lz
    let l:ret.="\n".strpart(getline(l:la),l:ca-1,l:len)
    let l:la+=1
  endwhile
  return l:ret
endfu

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

  let l:ret=strpart(getline(l:la),l:ca-1)
  let l:i=(l:la+1)
  while  l:i < l:lz
    let l:ret.="\n".getline(l:i)
    let l:i+=1
  endwhile
  let l:ret.="\n".strpart(getline(l:i),0,l:cz)
  return l:ret
endfu

fu! selection#vgetSelectedText()
  let l:ret=''
  let l:mode=mode()
  let l:lv=line('v')
  let l:li=line('.')
  let l:cv=col('v')
  let l:ci=col('.')
  if (l:mode==#"V")
    let l:ret=s:getTextInLines(l:lv,l:li)
  elseif (l:li == l:lv) || (l:mode==?"")
    let l:ret=s:getTextInBlock(l:lv,l:cv,l:li,l:ci)
  elseif (l:mode==#'v')
    let l:ret=s:getTextInRange(l:lv,l:cv,l:li,l:ci)
  endif
  return l:ret
endfu

fu! selection#getSelectedText()
  let l:ret=''
  norm gv
  let l:ret=selection#vgetSelectedText()
  norm 
  return l:ret
endfu

fu! selection#Status()
  let l:mode=mode()
  let l:ret=''
  if (l:mode!='i')
    if (l:mode!='n')
      let l:lv=line('v')
      let l:li=line('.')
      let l:cv=col('v')
      let l:ci=col('.')
      if (l:mode==?"")
        let l:ret=' ['.(abs(l:ci-l:cv)+1).','.(abs(l:li-l:lv)+1).']'
      elseif (l:mode==#"V")
        let l:ret=' ['.(col('$')-1).','.(abs(l:li-l:lv)+1).']'
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
