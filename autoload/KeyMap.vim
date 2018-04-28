" KeyMap.vim -- Vim lib complex keybind definitions
" @Author:      luffah (luffah AT runbox com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-26
" @Last Change: 2018-03-29
" @Revision:    1
if exists('g:loaded_accessibility_keymap') || &compatible
    "finish
endif
let g:loaded_accessibility_keymap=1

" Variables Globales, do not set
let g:km_default_layername=" "
let g:layer_status=''

" Initialisation
let g:km_active_layer=g:km_default_layername
let g:km_layer_keymapping={g:km_default_layername:{}}
let g:km_revert_keymapping={}
let g:km_layer_desc={}
let g:km_layer_desc_renderer={}

" 1 -> show explanation for alternatives keys
let g:km_document_alternatives = get(g:, 'km_document_alternatives', 0)

" add layer to the status
let &statusline="%#ModeMsg#%{g:layer_status}%#{}#".&statusline


" All known modes, shall not be set before the plugin is loaded
" to modify or add a mode :
" Example : let g:km_mode_hash['y']=['i','<C-v>','']
let g:km_mode_hash={
      \'n':[],':':['n',':','<Cr>'],
      \'i':[],'I':['i','<C-o>',''],'N':['i','<Esc>',''],
      \'v':[],'V':['v','<Esc>',''],
      \'s':[],'S':['s','<Esc>',''],
      \'x':[],'X':['s','<Esc>',''],
      \'o':[],'O':['o','<Esc>',''],
      \'l':[],'L':['l','<Esc>',''],
      \'c':[],'C':['c','<Esc>',''],
      \'A':['c',"<C-r>=<SID>dyn_alias('<Keybind>','","')<Cr>"],
      \'a':['c',"<C-r>=<SID>dyn_expand('","')<Cr>"],
      \'t':[],'T':['t','<Esc>','']
      \}

" Representation of the mode in the status bar
let g:km_status_substitions={
      \"" : "^",
      \"" : "ŝ"
      \}

" If you change one of these you shall modify g:km_actions_substitutions
let g:km_layer_toggle = "<Layer>"
let g:km_layer_exit = "<ExitLayer>"
let g:km_layer_oneshot = "<OneShot"
let g:km_actions_substitutions={
      \'<OneShot=\(\a\+\)>': "<Esc>:call KeyMap#OneShot('<ActionName>','<Mode>','\\1')<Cr>",
      \'<Layer>' : "<Esc>:call KeyMap#ToggleLayer('<ActionName>')<Cr>",
      \'<ExitLayer>': "<Esc>:call KeyMap#ToggleLayer('<LayerName>')<Cr>"
      \}


" We need to ensure Alt keybindings work in terminal as much in gui
if has("gui_running") || has("nvim")
  fu! s:ensure_keybinding(k)
    return a:k
  endfu
else
  let s:ensured_key={
        \"<A-à>":"à",
        \"<A-é>":"é",
        \"<A-è>":"è"
        \}
  fu! s:ensure_keybinding(k)
    let l:m=match(a:k,'<A-.>')
    let l:n=0
    let l:ret=''
    while l:m > -1
      if l:m > l:n 
        let l:ret.=a:k[l:n:l:m]
      endif
      let l:n=match(a:k,'>',l:m)
      let l:k=strpart(a:k, l:m+3 , l:n-l:m-3)
      let l:altk="<A-".l:k.">"
      if has_key(s:ensured_key,l:altk)
        let l:ret.=s:ensured_key[l:altk]
      else
        execute "set ".l:altk."=\e".l:k
        let s:ensured_key[l:altk]=l:altk
        let l:ret.=l:altk
      endif
      let l:n+=1
      let l:m=match(a:k,'<A-.>',l:n)
    endwhile
    let l:ret.=a:k[l:n:]
    " echo a:k.'->'.l:ret
    return l:ret
  endfu
endif

" Utilities functions

" replace_isubst('%1% %2%', ['a','b'], '%') = 'a b'
fu! s:replace_isubst(strin,replacements,sep)
  let l:strin=a:strin
  let l:i=0
  while l:i < len(a:replacements)
    let l:strin=substitute(l:strin,a:sep.(l:i+1).a:sep,a:replacements[l:i],'g')
    let l:i += 1
  endwhile
  return l:strin
endfu

" do_subst('%1% %2%', {'%1%':'a','%2%':'b'}) = 'a b'
fu! s:do_subst(e,h)
  let l:ret=a:e | for l:i in keys(a:h)
    let l:ret=substitute(l:ret, l:i ,a:h[l:i], 'g')
  endfor
  return l:ret
endfu

" Layer descrition functions
" --------------------------

" # s:LayerStatus() -> a short string to indicate the current layer
fu! s:LayerStatus()
  let l:ret=''
  let l:mode=mode()
  if g:km_active_layer != g:km_default_layername
    let l:ret=s:do_subst(l:mode,g:km_status_substitions)
    if has_key(g:km_layer_keymapping[g:km_active_layer], l:mode)
      let l:ret.='_'.g:km_active_layer.'_'
    else
      let l:ret.='('.g:km_active_layer.')'
    endif
  endif
  return l:ret
endfu

" # s:CloseLayerPrint() -> a short string to indicate the current layer
let s:layer_desc_bufnr=0
let s:prev_size=0
fu! s:CloseLayerPrint()
  if !empty(s:layer_desc_bufnr)
    let l:winnr=bufwinnr(s:layer_desc_bufnr)
    exe l:winnr.'windo bd'
    exe 'resize '.s:prev_size
    let s:layer_desc_bufnr=0
  endif
endfu
"
" Layer Description
fu! KeyMap#PrintLayer(layer)
  call s:CloseLayerPrint()
  let l:prt=[]
  if has_key(g:km_layer_desc,a:layer)
    let l:desc=g:km_layer_desc[g:km_active_layer]
    if has_key(g:km_layer_desc_renderer,a:layer)
      " A renderer shall use l:desc to get the variable
      exe g:km_layer_desc_renderer[a:layer]
    else
      if type(l:desc) == type([])
        let l:prt=l:desc
      else
        let l:prt=[l:desc]
      endif
    endif
  else
    for l:v_mode in keys(g:km_layer_keymapping[a:layer])
      for l:v_key in keys(g:km_layer_keymapping[a:layer][l:v_mode])
        let l:v_desc=g:km_layer_keymapping[a:layer][l:v_mode][l:v_key][0]
        if g:km_document_alternatives || l:v_desc[0] != '~'
          call add(l:prt,
                \ printf("%2s  %-16S  %s", l:v_mode, l:v_key, l:v_desc))
        endif
      endfor
    endfor
  endif
  if !empty(l:prt)
    let l:related=bufnr('%')
    let s:prev_size=winheight(l:related)
    rightbelow split
    enew
    let s:layer_desc_bufnr=bufnr('%')
    set buftype=nowrite
    set ft=keymapping
    exe 'resize '.len(l:prt) 
    call setline(1,l:prt)
    exe winbufnr(l:related).'wincmd w'
  endif
  redraw
  redrawstatus
endfu

fu! KeyMap#PrintCurrentLayer()
  call KeyMap#PrintLayer(g:km_active_layer)
endfu

" Layer activation
" --------------------------
"
" #ToogleLayer -> switch to an other keymap layer
" :layer: the layer name (unique indentifier)
fu! KeyMap#ToggleLayer(layer)
  " # Revert any previous keymapping layer
  for v_mode in keys(g:km_revert_keymapping)
    for v_keys in keys(g:km_revert_keymapping[v_mode])
      exe g:km_revert_keymapping[v_mode][v_keys]
    endfor
  endfor
  let g:km_revert_keymapping={}
  " # If Layer already active, just unset the current layer name 
  if !len(a:layer) || g:km_active_layer==a:layer
    let g:km_active_layer=g:km_default_layername
    call s:CloseLayerPrint()
  else
    " # Set the keymapping
    let g:km_active_layer=a:layer
    let l:layer_km=get(g:km_layer_keymapping,a:layer, 0)
    for v_mode in keys(l:layer_km)
      if !has_key(g:km_revert_keymapping,v_mode)
        let g:km_revert_keymapping[v_mode]={}
      endif
      for v_key in keys(l:layer_km[v_mode])
        " # Map keybind 
        let l:actiontable=l:layer_km[v_mode][v_key]
        let l:action=l:actiontable[1]
        let l:autocmd=l:actiontable[2]
        let l:keybinding_opts=l:actiontable[3]
        let l:mapaction = l:autocmd  . v_mode.'noremap ' .
              \l:keybinding_opts . v_key . ' ' . l:action
        exe l:mapaction
        " # Now, setup the undo
        let l:layer_revert_km=get(g:km_layer_keymapping[g:km_default_layername],v_mode,0)
        let l:actiontable=get(l:layer_revert_km,v_key,0)
        if !empty(l:actiontable)
          let l:action=l:actiontable[1]
          let l:autocmd=l:actiontable[2]
          let l:keybinding_opts=l:actiontable[3]
          let l:mapaction = l:autocmd  . v_mode.'noremap ' .
                \l:keybinding_opts . v_key . ' ' . l:action
          let l:revert_action=l:mapaction
        else
          let l:revert_action=v_mode.'unmap '.v_key
        endif
        let g:km_revert_keymapping[v_mode][v_key]=l:revert_action
      endfor
    endfor
    if ( a:layer[0] != '~' )
      cal KeyMap#PrintCurrentLayer()
    endif
  endif
  let g:layer_status=s:LayerStatus()
  redraw!
  redrawstatus!
endfu
command! -nargs=* -complet=customlist,<SID>LayerNameComplete Layer cal s:ToggleLayer(<q-args>) 
command! -nargs=0 Layers echo keys(g:km_layer_keymapping)
fu! s:LayerNameComplete(A,L,P)
  return keys(g:km_layer_keymapping)
endfunction

"fu! FunComplDir(dir)
"  let l:func_name='ComplFun'.substitute(a:dir,'\A','','g')
"  let l:dir=substitute(a:dir,'[/]*$','/','g')
"  exe "function! ".l:func_name."(A,L,P) \n return map("
"        \." globpath('".l:dir."', a:A.'*', 0, 1), "
"        \." 'strpart(v:val,".len(l:dir).").(isdirectory(v:val)?\"/\":\"\")'"
"        \." )\nendfunction"
"  return l:func_name
"endfu
fu! KeyMap#OneShot(layer,mode,commandkey)
  " !! : only work for one char keybind
  " !! : doesn't allow keymapping advanced option (autocommand)
  let l:layer_km=get(g:km_layer_keymapping,a:layer, 0)
  let l:prev_layer=g:km_active_layer
  let g:km_active_layer=a:layer
  if !empty(l:layer_km)
    cal KeyMap#PrintLayer(a:layer)
  endif
  let l:c=nr2char(getchar())
  let l:action=l:c
  if !empty(l:layer_km)
    if has_key(l:layer_km, a:mode) && has_key(l:layer_km[a:mode],l:c)
      let l:actiontable=l:layer_km[a:mode][l:c]
      let l:action=l:actiontable[1]
      call s:CloseLayerPrint()
      let g:km_active_layer=l:prev_layer
      let g:layer_status=s:LayerStatus()
      try
        exe l:action
      catch
        echo l:action.' "fails'
      endtry
      return
    elseif has_key(l:layer_km['1'],l:c)
      let l:actiontable=l:layer_km['1'][l:c]
      let l:action=l:actiontable[1]
    endif
    call s:CloseLayerPrint()
  endif
  try
    exe a:commandkey.' '.l:action
  catch
    echomsg l:action.' is not a valid key. (mode: '.a:mode', commandkey:'.a:commandkey.')'
  endtry
  let g:km_active_layer=l:prev_layer
  let g:layer_status=s:LayerStatus()
endfu

" Main Mapping function
" --------------------------
let s:last_layer=g:km_default_layername

" function Map (str name, str keybind, str action, [str mode_and_post_action]...)
" Assign keybindings with these arguments
" - name  required for info e.g. 'Save the file', 
" - keybind or keybind list e.g. '<C-s>', ['<C-s>','<C-S'>]
" - action                  e.g. ':w<CR>',
" - list of mode (1st char)
"   and post action         e.g. 'i','Ia','n','v' 
" e.g. 'ia' -> for insert mode do the keybinding a reenter in insert mode with 'a' 
" e.g. 'i<Left>' -> for insert mode do the keybinding and move cursor to left
fu! KeyMap#Map(name, keybind, action, modes,...)
  " correct types
  let l:keybind_alternatives = type(a:keybind) == type([]) ? a:keybind : [a:keybind]
  let l:modes = type(a:modes) == type([]) ? a:modes : [a:modes]
  " 
  let l:is_expr=( match(a:action,")[ ]*?[ ]*.*:") + 1 )
  let l:is_keybind_not_layer=1
  let l:contains_vars=( match(a:action,"%[0-9]%") + 1 )
  let l:keybinding_opts=''
  let l:autocmdopt=join(a:000, '')
  let l:ddotpos=match(a:name, ':')
  let l:is_mappable_at_start=(l:ddotpos<0)
  let l:name=a:name
  if l:is_mappable_at_start
    let l:layer=g:km_default_layername
    if ( match(a:action, g:km_layer_toggle) > -1 )
      let l:action=s:do_subst(a:action, g:km_actions_substitutions)
      let l:is_keybind_not_layer=0
      let s:last_layer=a:name
      if !has_key(g:km_layer_keymapping,a:name)
        let g:km_layer_keymapping[a:name] = {}
      endif
    elseif ( match(a:action, g:km_layer_oneshot) > -1 )
      let l:action=s:do_subst(a:action, g:km_actions_substitutions)
      let l:is_keybind_not_layer=0
      let s:last_layer=a:name
      " # Register in the keybind layer
      if !has_key(g:km_layer_keymapping,a:name)
        let g:km_layer_keymapping[a:name] = {'1':{}}
      endif
    endif
  else
    let l:layer=(l:ddotpos==0 ? s:last_layer : strpart(a:name, 0, l:ddotpos))
    let l:name=strpart(a:name,l:ddotpos+1)
    let s:last_layer=l:layer
    if empty(l:modes)
      " This case occur in shot mode, given we just get char it is useless
      " to specify mode
      let l:i = 0
      while l:i < len(l:keybind_alternatives)
        let l:keybind=s:ensure_keybinding(l:keybind_alternatives[l:i])
        let l:action=substitute(a:action,"<Keybind>",l:keybind,'g')
        let l:action=substitute(l:action,"<ActionName>",l:name,'g')
        let l:action=substitute(l:action,"<LayerName>",l:layer,'g')
        let g:km_layer_keymapping[l:layer]['1'][l:keybind]=
              \[(l:i == 0 ? '':'~').a:name ,l:action,'',l:keybinding_opts]
        let l:i += 1
      endwhile
      return
    endif
  endif
  " for all modes  " 'i' 'n' 'v'
  for l:curr in l:modes
    let l:i = 0
    while l:i < len(l:keybind_alternatives)
      " # Get the keys to bind
      let l:keybind=s:ensure_keybinding(l:keybind_alternatives[l:i])
      " # Get the mode descriptor used to bind the keys
      let l:mode_char=l:curr[0]
      " # Get or compute the action to bind to the key in the mode
      let l:postaction=''
      if l:is_keybind_not_layer
        let l:action=s:do_subst(a:action,g:km_actions_substitutions)
        if has_key(g:km_mode_hash,l:mode_char)
          let l:postaction=l:curr[1:]
          if l:contains_vars
            let l:action=substitute(l:action,'%\d%','','g')
          endif
        elseif l:contains_vars
          " in this case delimiter is first char
          " and is used to seperate the mode and post actions
          " from substitution table
          " e.g.  cal KeyMap#Map('name','k',,'["%1%","%2%"]',['-i-/b/c/'])
          "       -> inoremap k ["b","c"]
          " # get mode/substitutions delimiter position 
          let l:pos=match(l:curr,l:curr[0],1)
          " # get substitution table
          let l:subst=strpart(l:curr,l:pos+1)
          let l:sep=l:subst[0]
          " # get mode and post action
          let l:mode_char=strpart(l:curr,1,1)
          let l:postaction=strpart(l:curr,2,l:pos-2)
          if !( has_key(g:km_mode_hash,l:mode_char) )
            continue
          endif
          let l:action=s:replace_isubst(l:action, split(l:subst,l:sep),'%')
        endif
      endif
      if l:is_expr
        let l:keybinding_opts.='<expr> '
        let l:action=substitute(l:action,'<','\\<','g')
        let l:postaction=substitute(l:postaction,'<','\\<','g')
      endif
      if len(g:km_mode_hash[l:mode_char])
        let l:mode_hash=g:km_mode_hash[l:mode_char]
        let l:mode_char=l:mode_hash[0]
        let l:action=l:mode_hash[1].l:action.l:mode_hash[2]
      endif
      let l:action=l:action.l:postaction
      let l:action=substitute(l:action,"<Mode>",l:mode_char,'g')
      let l:action=substitute(l:action,"<Keybind>",l:keybind,'g')
      let l:action=substitute(l:action,"<ActionName>",l:name,'g')
      let l:action=substitute(l:action,"<LayerName>",l:layer,'g')
      " # Define if and how autocommand shall be used
      let l:autocmd = ''
      if len(l:autocmdopt)
        let l:autocmd = 'autocmd ' . l:autocmdopt . ' '
        let l:keybinding_opts = '<buffer>' . l:keybinding_opts 
      endif 
      " # Map the keybind
      if l:is_mappable_at_start
        let l:mapaction = l:autocmd  . l:mode_char.'noremap ' .
              \l:keybinding_opts . l:keybind . ' ' . l:action
        exe l:mapaction
      endif
      " # Register in the keybind layer
      " if !has_key(g:km_layer_keymapping,l:layer)
        " let g:km_layer_keymapping[l:layer] = {}
      " endif
      if !has_key(g:km_layer_keymapping[l:layer],l:mode_char)
        let g:km_layer_keymapping[l:layer][l:mode_char]={} 
      endif
      " -> Store keymap name, keybinding, action
      let g:km_layer_keymapping[l:layer][l:mode_char][l:keybind]=
            \[(l:i == 0 ? '':'~').l:name ,l:action,l:autocmd,l:keybinding_opts]
      let l:i += 1
    endwhile
  endfor
endfu

" 
" For mapping many keys with same autocmds
fu! KeyMap#AddMapSet(shorcuts, ...)
  let l:autocmdopt=""
  for l:i in a:000
    let l:autocmdopt.=l:i
  endfor
  for nargs in a:shorcuts
    cal KeyMap#Map(nargs[0],nargs[1],nargs[2],nargs[3],l:autocmdopt)
  endfor
endfu

fu! s:dyn_alias(in,out)
 if getcmdtype()==':' && getcmdpos() == 1
   return join(map(split(a:out,' '),'expand(v:val)'),' ')
 else
   return a:in
 endif
endfu

fu! s:dyn_expand(out)
 if getcmdtype()==':'
   return join(map(split(a:out,' '),'expand(v:val)'),' ')
 endif
endfu

function! KeyMap#Alias(alias, cmd, ...)
  let l:autocmdopt=join(a:000, '')
  let l:autocmd=''
  if len(l:autocmdopt)
     let l:autocmd = 'autocmd ' . l:autocmdopt . ' '
  endif
  exe l:autocmd.'cabbrev '.a:alias.
        \ ' <C-r>=(getcmdtype()==":" && getcmdpos() == 1? "'.
        \ escape(a:cmd,'"\').'" : "'.escape(a:alias,'"\').'")<Cr>'
endfu

"<F1> Q   "Cleared keys         " <nop> % n
fu! s:ReadKeyFile(file)
  " echo a:file
  let l:autocmdinfo=''
  let l:skip=0
  let l:skipdone=0
  for l:l in readfile(a:file)
    if len(l:l) && l:l !~ '^"'
      if !skipdone && l:l =~ '^finish\s*$'
        " finish allow to secure keymap file from loading with source %
        " KeyMap % .. to load the file with so %
        " it allows to put vim commands from KeyMap or from if 0
        " Then it allows to do inception
        let l:skip=0
        let l:skipdone=1
        continue
      elseif !l:skip
        if l:l =~ '^\[.*]'
          let l:auend=match(l:l,']',1)
          let l:autocmdinfo=strpart(l:l,1,l:auend-1)
        elseif l:l =~ '^alias'
          cal s:ReadAliasLine(l:l,l:autocmdinfo)
        elseif l:l =~ '\S\+\s\+"[^"]*"\s\+\(\S.\+\)\?%\(\s\+.\+\)\?'
          cal s:ReadKeyLine(l:l,l:autocmdinfo)
        elseif l:l =~ '^\(if 0\|KeyMap \).*'
          let l:skip=1
          continue
        else
          echo 'Syntax Error : '.l:l
        endif
      endif
    endif
  endfor
endfu

command! -nargs=1 KeyMap call s:ReadKeyFile(expand(<q-args>))

fu! s:ReadAliasLine(line,autocmdinfo)
  let l:alias_pos=match(a:line,'\s\S',2)
  let l:command_pos=match(a:line,'\s\S',l:alias_pos+1)
  let l:alias=strpart(a:line,l:alias_pos+1,l:command_pos-l:alias_pos-1)
  let l:cmd=strpart(a:line,l:command_pos+1)
  cal KeyMap#Alias(l:alias, l:cmd,a:autocmdinfo)
endfu

fu! s:ReadKeyLine(line,autocmdinfo)
  " echo a:line
  let l:keys_pos=match(a:line,'[^ ]',0)
  let [l:comment,l:comment_pos,l:comment_end_pos]=matchstrpos(a:line,'".\?\S[^"]*"',l:keys_pos+1)
  let l:modes_pos=match(a:line,' %\( \|$\)',l:comment_end_pos+1)
  let l:action_pos=match(a:line,'[^ ]',l:comment_end_pos+1)
  let l:keys=filter(
        \split(strpart(a:line,l:keys_pos,l:comment_pos-l:keys_pos),' '),
        \'len(v:val)')
  let l:modes=filter(
        \split(strpart(a:line,l:modes_pos+2),' '),
        \'len(v:val)')
  let l:comment=substitute(substitute(l:comment,'"\s*','',''),'\s*"','','')
  let l:action=substitute(strpart(a:line,l:action_pos,l:modes_pos-l:action_pos),'\s*$','','')
  " echo [l:comment, l:keys,l:action,l:modes,a:autocmdinfo]
  cal KeyMap#Map(l:comment, l:keys,l:action,l:modes,a:autocmdinfo)
endfu

fu! KeyMap#FunctionToKeyLine()
  "brute force conversion
silent! s/call\?\s\+KeyMap#Map(\(['"]\)\(.*\)\1\s*,\s*\(['"]\)\(.*\)\3\s*,\s*\(['"]\)\(.*\)\5\s*,\s*\[\(.*\)\]\s*,\s*\(['"]\)\(.*\)\8\s*).*/[\9]\r\4 "\2" \6 % \7/
silent! s/call\?\s\+KeyMap#Map(\(['"]\)\(.*\)\1\s*,\s*\[\(.*\)\]\s*,\s*\(['"]\)\(.*\)\4\s*,\s*\[\(.*\)\]\s*).*/\3 "\2" \5 % \6/
silent! s/call\?\s\+KeyMap#Map(\(['"]\)\(.*\)\1\s*,\s*\(['"]\)\(.*\)\3\s*,\s*\(['"]\)\(.*\)\5\s*,\s*\[\(.*\)\]\s*).*/\4 "\2" \6 % \7/
silent! s/call\?\s\+KeyMap#Alias(\(['"]\)\(.*\)\1\s*,\s*\(['"]\)\(.*\)\3\s*).*/alias \2 \4/
silent! s/% \(.*\)\(['"]\)\(.*\)\2\s*,/% \1 \3/g
silent! s/% \(.*\)\(['"]\)\(.*\)\2\s*,/% \1 \3/g
silent! s/% \(.*\)\(['"]\)\(.*\)\2\s*,/% \1 \3/g
silent! s/% \(.*\)\(['"]\)\(.*\)\2\s*/% \1 \3/
endfu

