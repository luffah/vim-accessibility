if exists("g:loaded_accessibility_autoload") || &cp || v:version < 700
  finish
endif

let g:loaded_accessibility_autoload = 1

let g:autoloader_loaded_files=[]

fu! s:resetAutoLoader()
  augroup Autoloader
    autocmd!
  augroup END
endfu

fu! s:F_init_load_file(path,dyn,discharge)
  if index(g:autoloader_loaded_files, a:path) < 0
    silent echo "$< ".a:path
    exe 'source ' . a:path
    call add(g:autoloader_loaded_files, a:path)
    exe a:discharge
  endif
endfu

fu! s:AutoSource(required,...)
  " Sourcefiles in ... args on autocmd"
  augroup Autoloader
  let l:aucmd='au '.a:000[0].' '.a:000[1].' '
  let l:aucmdrm='au! Autoloader '.a:000[0].' '.a:000[1]
  for l:f in a:000[2:]
    let l:f=expand(l:f)
    if ( index(g:autoloader_loaded_files,l:f) < 0 ) && 
          \ ( a:required || filereadable(l:f) )
      exe l:aucmd.'call s:F_init_load_file("'.l:f.'",1, "'.l:aucmdrm.'")'
    endif
  endfor
  augroup END
endfu

command! -nargs=* AutoLoad call s:AutoSource(0,<f-args>)
command! -nargs=* AutoLoadReset call s:resetAutoLoader(0,<f-args>)

fu! s:reopft(ft)
  let l:name = expand('%')
  let l:c =''
  let l:chr = s:default_cmd_char
  if l:name =~ l:chr
    let l:dropbuf=bufnr()
    let l:f = trim(substitute(l:name, l:chr.'.*$', '', ''))
    let l:c = trim(substitute(l:name, '^.*'.l:chr, '', ''))
    exe 'e '.l:f
    exe l:dropbuf.'bd'
  endif
  if len(a:ft) && expand('%:e') == ''
    let l:dropbuf=bufnr()
    let l:f = expand('%:r').'.'.a:ft 
    exe 'e '.l:f
    exe l:dropbuf.'bd'
  endif
  if len(l:c)
    " redraw!
    " exe 'au BufEnter '.expand('%:t').' ++once '.l:c
    exe 'au BufEnter <buffer> ++once '.l:c
  endif
endfu

fu! s:setupDefaultFileExtForDirectory(ft, ...)
  augroup Autoloader
    for l:a in a:000
      exe 'au BufNewFile '.substitute(l:a, '/$', '', '').'/* ++nested call s:reopft("'.a:ft.'")'
    endfor
  augroup END
endfu
command! -nargs=* -complete=dir AutoLoadDefaultExt call s:setupDefaultFileExtForDirectory(<f-args>)

let s:default_cmd_char=':'
fu! s:setupDefaultFileUseCommandChar(chr)
  let s:default_cmd_char=a:chr
  augroup Autoloader
    exe "au BufNewFile *".a:chr."* ++nested call s:reopft('')"
  augroup END
endfu
command! -nargs=* -complete=dir AutoLoadUseCommandChar call s:setupDefaultFileUseCommandChar(<f-args>)
