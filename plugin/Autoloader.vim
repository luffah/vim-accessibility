let g:loaded_files=[]

fu! s:F_init_load_file(path,dyn,discharge)
  if index(g:loaded_files, a:path) < 0
    silent echo "$< ".a:path
    exe 'source ' . a:path
    call add(g:loaded_files, a:path)
    exe a:discharge
  endif
endfu

fu! s:AutoSource(required,...)
  " Sourcefiles in ... args on autocmd"
  let l:aucmd='au '.a:000[0].' '.a:000[1].' '
  let l:aucmdrm='au! AutoLoadSet '.a:000[0].' '.a:000[1]
  for l:f in a:000[2:]
    let l:f=expand(l:f)
    if ( index(g:loaded_files,l:f) < 0 ) && 
          \ ( a:required || filereadable(l:f) )
      let l:aucmd.='call s:F_init_load_file("'.l:f.'",1, "'.l:aucmdrm.'")'
      exe l:aucmd
    endif
  endfor
endfu

command! -nargs=* AutoLoad call s:AutoSource(0,<f-args>)
