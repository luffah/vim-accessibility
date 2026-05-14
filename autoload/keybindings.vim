" keybindings.vim -- Vim lib complex keybind definitions
" @Author:      luffah (luffah AT runbox com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-26
" @Last Change: 2026-05-17
" @Revision:    5
if v:version < 700 || &cp || get(g:, 'loaded_accessibility_keymap', 0)
    finish
endif

let g:keybindings_print_mode=0
" @fileformat *keybindings-format*
" Note: For readability, post-actions and modes from hash no more exists.
" Given :
"  * keybind(s) is a list of keybinds (separated by a ' ', use '<space>' for a space)
"    [keyinds are as defined for *:map* {rhs}]
"  * Comment is an human description of the action
"  * Action is a sequence of keys as it was typed [as defined for *:map* {rhs}]
"  * Mode(s) is a list (separated by a ',') of:
"    * Mode is an explicit *map-modes* in n,v,s,x,o,i,l,c,t (all except map and map!)
"      followed by additionnal keys to be hitted to access some editing state.
"      Some examples here :
"       * the keybind is defined for normal mode but you want it to be useable
"       in insert mode,
"         use km(i<C-o>,n) [<C-o> go to normal mode and return to insert mode]
"          or km(i<Esc>,n) [<Esc> leave insert mode for normal mode]
"  * keywords you can use (at the start of the line) are:
"    * km(..)         for keybinding definition
"    * km:for name in [v_1, v_2]
"    * km:for [name1, name2] in [[v_1_1, v_1_2], ..]
"    * km:for [..] in function_call(..)
"                     to loop over definition with variants
"    * km:endfor      to end the loop context
"    * alias          for (command line) alias
"    * alias:if       to add condition on alias
"    * alias:endif    to end the conditional context
"
" The short format to define keymaps is the following.```
"  "mode(s)       keybind(s)  "Comment"        Action
"  km(c,v)      <F1>       "Cleared key"       <nop>
"  km(c,v)      <F2> <F3>  "Cleared keys"      <nop>
"  km(i)        <A-Up>     "Complete/select"   <expr>pumvisible()?"<KeyBind>":"<C-x><C-i>"
"  km(n,i<C-o>) <A-t>      "Cycle tab"         gt
"
"  km:for l:k in ['Up', 'Down', 'Left', 'Right']
"  km(i<c-o>,n) <S-{l:k}>       "Enter Visual"                   v
"  km(v)        <S-{l:k}>       "Visual selection (arrow)"       <{l:k}>
"  km:endfor
"
"  " Filetype rules example
"  autocmd FileType python
"  km(c,i)                 "No invisible space" <Space>
"  autocmd
"
"  " COMMAND LINE SPECIFIC
"  " Aliases abbreviation 
"  alias qa confirm qa
"  alias tnn <cmap> <expand> tabnew %:p:h/<C-d>
"  alias <A-v> <cmap> <inline> \\%V
"  " options shall appear the order it is described below:
"  "
"  "  <?map>      normally <cmap>, to use key binding instead of abbreviation
"  "              (vim specific)
"  "              - abbreviation let you show what you type before resolution
"  "              - keybinding (map) hide characters until the resolution
"  "
"  "  <expand>    use expand() on each word to expand the words (<cword> or %:p)
"  "
"  "  <inline>    instead of resolving the alias at the start of line only
"  "              allow resolution in middle of line (like standard abbrev)
"  "
"  "  <expr>      to use vim functions to fill the content
"
"  " In the right part you can invoke special behavior with
"  "  <C-r>= <cr>  use function register
"  "  <C-d>        **c_CTRL-D** to list names of matching a pattern
"
"  " Expanded abbreviation  (equivalent of alias <expand> <inline>)
"  expand %%  %:p:h/
"
"  " alias and expand can be sourrouned by a condition in order to limit the
"  " impact of the abbreviation
"  alias:if (&ft != 'vim')
"  alias so% echo 'Cannot source '.&ft
"  alias:endif
"
" ```
" See ./samples/ to get many examples.
"
" @fileformat *keymap-inception* 
" You can nest |keybindings-format| in a vim script.
" In order to do that, the script part shall be at file beginning
" and be surrounded by `if 0 | endif` and `finish`. ```
" These to word ensure the script part is ignored while loading the keybindings.
"      if 0 | endif
"      call keybindings#Source(expand('<sfile>'))
"      finish
"      Q        "Cleared key" <nop> % n
" ```
"
" For more advanced use, calling the function is required. ```
"      if 0 | endif
"       function! s:RemovePathComponent()
"           let l:cmdlineBeforeCursor = strpart(getcmdline(), 0, getcmdpos() - 1)
"           let l:cmdlineAfterCursor = strpart(getcmdline(), getcmdpos() - 1)
"
"           let l:cmdlineRoot = fnamemodify(cmdlineBeforeCursor, ':r')
"           let l:result = (l:cmdlineBeforeCursor ==# l:cmdlineRoot ?
"                 \ substitute(l:cmdlineBeforeCursor, '\%(\\ \|[\\/]\@!\f\)\+[\\/]\=$\|.$', '', '')
"                 \ : l:cmdlineRoot)
"           call setcmdpos(strlen(l:result) + 1)
"           return l:result . l:cmdlineAfterCursor
"       endfunction
"      " substitutions to shorten keybinding definition
"      let s:substs=[
"      \ ['pum?', '<expr>pumvisible()?', '']
"      \]
"
"      " include sid is for using the previously defined function
"      let s:include_sid = 1
"
"      call keybindings#Source(expand('<sfile>'), s:substs, s:include_sid)
"      finish
"      km(i) <A-Up>    "Compl.from file    "    pum?"<UP>":"<C-x><C-i>"
"      km(c) <C-h>     "RemovePathComponent"   <C-\>e(<SID>RemovePathComponent())<CR>
"```
let keybindings#substs=[]

" Variables Globales, do not set
let g:km_default_layername=get(g:,'km_default_layername'," ")
" @global g:km_layer_status
" Layer status string.
" If you customize your statusline your could need to add : ```
"   let &statusline="%#ModeMsg#%{g:km_layer_status}%#{}#".&statusline
"```
let g:km_layer_status=get(g:,'km_layer_status','')

" Initialisation
let g:km_active_layer=get(g:,'km_active_layer',g:km_default_layername)
let g:km_layer_keymapping=get(g:,'km_layer_keymapping',{g:km_default_layername:{}})
let g:km_revert_keymapping=get(g:,'km_revert_keymapping',{})
let g:km_layer_desc=get(g:,'km_layer_desc',{})
let g:km_layer_desc_renderer=get(g:,'km_layer_desc_renderer',{})

" @global g:km_status_substitions
" Representation of the mode in the status bar
let g:km_status_substitions={
      \"" : "^",
      \"" : "ŝ"
      \}

" If you change one of these you shall modify g:km_actions_substitutions
let s:km_layer_toggle = "<Layer>"
let s:km_layer_exit = "<ExitLayer>"
let s:km_layer_oneshot = "<OneShot"
let g:km_actions_substitutions={
      \ s:km_layer_oneshot.'=\([^{}>]\+\)\({\(\a\+\)}\)\?\([^{}>]*\)>': "<Esc>:call keybindings#OneShot('<ActionName>','<Mode>',\"\\1 {}\\4\", '\\3')<Cr>",
      \ s:km_layer_toggle : "<Esc>:call keybindings#ToggleLayer('<ActionName>')<Cr>",
      \ s:km_layer_exit : "<Esc>:call keybindings#ToggleLayer('<LayerName>')<Cr>"
      \}


" We need to ensure Alt keybindings work in terminal as much in gui
if has("gui_running") || has("nvim")
    fu! keybindings#ensureKeybind(k)
        return escape(a:k,'|')
    endfu
else
    let s:ensured_key={
                \"<A-à>":"à",
                \"<A-é>":"é",
                \"<A-è>":"è",
                \}
    fu! keybindings#ensureKeybind(k)
        " TODO:solve <A-"> case
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
        return escape(l:ret,'|')
    endfu
endif

" Utilities functions
fu! s:_set_val_rec(val, dict, key, nextkeys)
    if len(a:nextkeys) == 0
        let a:dict[a:key] = a:val
    else
        if !has_key(a:dict, a:key)
            let a:dict[a:key] = {}
        endif
        call s:_set_val_rec(a:val, a:dict[a:key], a:nextkeys[0], a:nextkeys[1:])
    endif
endfu
fu! s:set_val(val, dict, ...)
    call s:_set_val_rec(a:val, a:dict, a:1, a:000[1:])
endfu

" do_subst('%1% %2%', {'%1%':'a','%2%':'b'}) = 'a b'
" do_subst('{1} {2} 3}', {['{1}','a'],['{2}','b']) = 'a b 3}'
fu! s:do_subst(line,repl)
    let l:ret=a:line
    let l:substs = a:repl
    if type(l:substs) == type({}) | let l:substs = items(l:substs) | endif
    call map(l:substs, 'v:val + (len(v:val) == 2 ? ["g"]: [])')
    for [l:s,l:t,l:o] in l:substs
        let l:ret=substitute(l:ret,l:s,l:t,l:o)
    endfor
    return l:ret
endfu

" Layer descrition functions
" --------------------------
fu! s:LayerStatus()
    " return a short string to indicate the current layer
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

" @function keybindings#PrintLayer(layer)
" Shows a formated layer Description
fu! keybindings#PrintLayer(layer)
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
    let l:summary = {}
    if ['1'] == keys(g:km_layer_keymapping[a:layer])
        let l:ptf="%.0s%-16S  %s"
    else
        let l:ptf="%7s  %-16S  %s"
    endif
    let l:prt=[printf(l:ptf, 'Mode(s)', 'Key', 'Description')]
    for l:v_mode in keys(g:km_layer_keymapping[a:layer])
      for l:v_key in keys(g:km_layer_keymapping[a:layer][l:v_mode])
        if l:v_key == '__aliases__'
            continue
        endif
        let l:v_desc=g:km_layer_keymapping[a:layer][l:v_mode][l:v_key][0]
        let l:uniqid = l:v_desc.'__'.l:v_key
        if has_key(l:summary, l:uniqid)
            call add(l:summary[l:uniqid][0], l:v_mode)
        else
            let l:summary[l:uniqid] = [[l:v_mode], l:v_key, l:v_desc]
        endif
      endfor
    endfor
    for l:key in sort(keys(l:summary))
        let [l:v_modes, l:v_key, l:v_desc] = l:summary[l:key]
        call add(l:prt, printf(l:ptf, join(l:v_modes, ''), l:v_key, l:v_desc))
    endfor
  endif
  call statusui#HelpWin('Layer '.a:layer,l:prt,'keymapping')
endfu

" @function keybindings#PrintCurrentLayer()
" Shows current keybind layer.
fu! keybindings#PrintCurrentLayer()
    call keybindings#PrintLayer(g:km_active_layer)
endfu


" Layer activation
" --------------------------
"
" @function keybindings#ToggleLayer
" Switch to an other keymap layer
" :param layer: the layer name (unique indentifier)
fu! keybindings#ToggleLayer(layer)
  " # Revert any previous keymapping layer
  for l:mode in keys(g:km_revert_keymapping)
    for l:keys in keys(g:km_revert_keymapping[l:mode])
      exe g:km_revert_keymapping[l:mode][l:keys]
    endfor
  endfor
  let g:km_revert_keymapping={}
  " # If Layer already active, just unset the current layer name 
  if !len(a:layer) || g:km_active_layer==a:layer
    let g:km_active_layer=g:km_default_layername
    call statusui#CloseHelpWin()
  else
    " # Set the keymapping
    let g:km_active_layer=a:layer
    let l:layer_km=get(g:km_layer_keymapping,a:layer, 0)
    for l:mode in keys(l:layer_km)
      for l:key in keys(l:layer_km[l:mode])
        " # Map keybind 
        let l:actiontable=l:layer_km[l:mode][l:key]
        let l:action=l:actiontable[1]
        let l:autocmd=l:actiontable[2]
        let l:keybinding_opts=l:actiontable[3]
        let l:recursive=len(l:actiontable)>4
        let l:mapaction = l:autocmd  . l:mode.(l:recursive?'': 'nore').'map ' .
              \l:keybinding_opts . l:key . ' ' . l:action
        exe l:mapaction
        " # Now, setup the undo
        let l:layer_revert_km=get(g:km_layer_keymapping[g:km_default_layername],l:mode,0)
        if !empty(l:layer_revert_km)
          let l:actiontable=get(l:layer_revert_km,l:key,0)
        else
          let l:actiontable={}
        endif
        if !empty(l:actiontable)
          let l:action=l:actiontable[1]
          let l:autocmd=l:actiontable[2]
          let l:keybinding_opts=l:actiontable[3]
          let l:recursive=len(l:actiontable)>4
          let l:mapaction = l:autocmd  . l:mode.(l:recursive?'': 'nore').'map ' .
                \l:keybinding_opts . l:key . ' ' . l:action
          let l:revert_action=l:mapaction
        else
          let l:revert_action=l:mode.'unmap '.l:key
        endif
        call s:set_val(l:revert_action, g:km_revert_keymapping, l:mode, l:key)
      endfor
    endfor
    if ( a:layer[0] != '~' )
      cal keybindings#PrintCurrentLayer()
    endif
  endif
  let g:km_layer_status=s:LayerStatus()
  redraw!
  redrawstatus!
endfu

" @command :Layer [layer_name]
" Toggle [layer_name].
command! -nargs=* -complet=customlist,<SID>LayerNameComplete Layer cal keybindings#ToggleLayer(<q-args>) 

" @command :Layers
" List possible values for |:Layer|.
command! -nargs=0 Layers echo keys(g:km_layer_keymapping)
fu! s:LayerNameComplete(A,L,P)
  return keys(g:km_layer_keymapping)
endfunction

fu! keybindings#OneShot(layer,mode,commandkey,...)
  " !! : only work for one char keybind
  " !! : doesn't allow keymapping advanced option (autocommand)
  let l:layer_km=get(g:km_layer_keymapping,a:layer, 0)
  let l:pres_cmd=''
  if len(a:000)
    let l:pres_cmd = a:1
  endif
  " let l:prev_layer=g:km_active_layer
  " let g:km_active_layer=a:layer
  echo a:layer.' ('.a:commandkey.')'
  if len(l:pres_cmd)
    try
      exe l:pres_cmd
    catch
      echo "no proposal found"
      return
    endtry
  endif
  let l:is_selection=!(empty(l:layer_km) || empty(get(l:layer_km, 1, {0:0})))
  if l:is_selection
    cal keybindings#PrintLayer(a:layer)
  endif
  let l:c=nr2char(getchar())
  redraw
  let l:action=l:c
  if l:is_selection
    if has_key(l:layer_km, a:mode) && has_key(l:layer_km[a:mode],l:c)
      let l:actiontable=l:layer_km[a:mode][l:c]
      let l:action=l:actiontable[1]
      call statusui#CloseHelpWin()
      " let g:km_active_layer=l:prev_layer
      " let g:km_layer_status=s:LayerStatus()
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
    call statusui#CloseHelpWin()
  endif
  try
    exe substitute(escape(a:commandkey, '"'), '{}', l:action, 'g')
  catch
    echomsg l:action.' is not a valid key. (mode: '.a:mode', commandkey:'.a:commandkey.')'
  endtry
  " let g:km_active_layer=l:prev_layer
  " let g:km_layer_status=s:LayerStatus()
endfu

" Main Mapping function
" --------------------------
let s:last_layer=g:km_default_layername

" @function keybindings#Map(name, keybinds, action, modes_and_post_actions)
" Assign keybindings with these arguments
" - name   required for info e.g. 'Save the file', 
" - keybind or keybind list e.g. '<C-s>', ['<C-s>','<C-S'>]
" - action                   e.g. ':w<CR>',
" - list of mode (1st char) and action to prepare mode 
" e.g. 'i<Esc>' -> for insert mode going to normal mode
" If action contains one of the following keyword, it will be modified :
"   <Mode>        -> the current mode char ('i', 'v', ...) as defined
"   <Keybind>     -> the keybinding
"   <ActionName>  -> the name of the action
"   <LayerName>   -> the current layer name
" See **g:keybindings#Source** for more substitutions
fu! keybindings#Map(name, keybind, action, modes,...)
    " correct types
    let l:keybinds = type(a:keybind) == type([]) ? a:keybind : [a:keybind]
    let l:modes = type(a:modes) == type([]) ? a:modes : [a:modes]
    let l:has_pipe=( match(a:action,"|") + 1 )
    let l:is_layer=0
    let l:contains_vars=( match(a:action,"%[0-9]%") + 1 )
    let l:keybinding_opts=''
    let l:autocmdopt=join(a:000, '')
    let l:ddotpos=match(a:name, ':')
    let l:is_mappable_at_start=(l:ddotpos<0)
    let l:name=a:name
    if l:is_mappable_at_start
        let l:layer=g:km_default_layername
        if ( match(a:action, s:km_layer_toggle) > -1 )
            let l:action=s:do_subst(a:action, g:km_actions_substitutions)
            let l:is_layer=1
            let s:last_layer=a:name
        elseif ( match(a:action, s:km_layer_oneshot) > -1 )
            let l:action=s:do_subst(a:action, g:km_actions_substitutions)
            let l:is_layer=1
            let s:last_layer=a:name
        endif
    else
        let l:layer=(l:ddotpos==0 ? s:last_layer : strpart(a:name, 0, l:ddotpos))
        let l:name=strpart(a:name,l:ddotpos+1)
        let s:last_layer=l:layer
        if empty(l:modes)
            " This case occur in one-shot mode, given we just get char it is useless
            " to specify mode
            for l:keybind in l:keybinds
                let l:keybind=keybindings#ensureKeybind(l:keybind)
                let l:action=s:do_subst(a:action, {"<Keybind>": l:keybind, "<ActionName>":l:name, "<LayerName>":l:layer})
                call s:set_val(
                            \[a:name ,l:action,'',l:keybinding_opts],
                            \ g:km_layer_keymapping, l:layer, '1', l:keybind)
            endfor
            return
        endif
    endif
    " for all modes  " 'i' 'n' 'v'
    for l:curr in l:modes
        let l:recursive=0   " obsolete ?  recursive mapping is to avoid
        if l:curr[0] == '~'
            let l:recursive=1
            let l:curr = l:curr[1:]
        endif
        " # Get the mode descriptor used to bind the keys
        let l:mode_char=l:curr[0]
        let l:action = a:action
        "
        if match(l:action,"<expr>") == 0
            let l:keybinding_opts.='<expr> '
            let l:action=substitute(l:action,'<expr>\s*','','')
            let l:action=substitute(l:action,'<','\\<','g')
        endif
        if l:layer
            continue
        else
            let l:action=s:do_subst(l:action,g:km_actions_substitutions)
            let l:action=l:curr[1:].l:action
        endif
        let l:action=s:do_subst(l:action, {"<Mode>": l:mode_char, "<ActionName>":l:name, "<LayerName>":l:layer})
        for l:keybind in l:keybinds
            let l:keybind=keybindings#ensureKeybind(l:keybind)
            " # Get or compute the action to bind to the key in the mode
            if l:has_pipe
                let l:action=substitute(l:action, '\?|', '|','g')
            endif
            let l:action=substitute(l:action,"<Keybind>",l:keybind,'g')
            " # Define if and how autocommand shall be used
            let l:autocmd = ''
            if len(l:autocmdopt)
                let l:autocmd = 'autocmd ' . l:autocmdopt . ' '
                let l:keybinding_opts = '<buffer>' . l:keybinding_opts 
            endif 
            " -> Store keymap name, keybinding, action
            call s:set_val(
                        \[l:name ,l:action,l:autocmd,l:keybinding_opts]
                        \, g:km_layer_keymapping, l:layer, l:mode_char, l:keybind)
            if l:recursive
                let g:km_layer_keymapping[l:layer][l:mode_char][l:keybind]+=[1]
            endif
            " # Map the keybind
            if l:is_mappable_at_start
                let l:mapaction = l:autocmd  . l:mode_char .(l:recursive?'': 'nore').'map ' .
                            \l:keybinding_opts . l:keybind . ' ' . l:action
                exe l:mapaction
            endif
        endfor
    endfor
endfu

"@function keybindings#export()
" export for a faster boot and lighter memory usage
" without dependencies
" and to share your keymap
fu! keybindings#export()
    let l:return=[]
    let l:exportsep='-s-e-p-a-r-a-t-o-r-'
    for l:klayer in keys(g:km_layer_keymapping)
        let l:retlayer=[]
        let l:layer=g:km_layer_keymapping[l:klayer]
        for l:mode in keys(l:layer)
            for l:key in keys(l:layer[l:mode])
                let l:actiontable=l:layer[l:mode][l:key]
                let l:desc='" '.l:actiontable[0]
                let l:action=l:actiontable[1]
                let l:autocmd=l:actiontable[2]
                let l:keybinding_opts=l:actiontable[3]
                let l:recursive=len(l:actiontable)>4
                " keep lines joined to sort by l:desc
                call add(l:retlayer,l:desc.l:exportsep.
                            \l:autocmd  . l:mode.(l:recursive?'': 'nore').'map ' .
                            \l:keybinding_opts . l:key . ' ' . l:action)
            endfor 
        endfor 
        call sort(l:retlayer)
        let l:mapping=[]
        let l:prev_desc=''
        " split \n and remove double descriptions
        for l:l in l:retlayer
            let [l:desc,l:km]=split(l:l,l:exportsep)
            if l:prev_desc != l:desc
                call add(l:mapping,l:desc)
            endif
            let l:prev_desc = l:desc
            call add(l:mapping,l:km)
        endfor
        let l:layer_key_name=substitute(l:klayer,'[!?{}[\])(:.\/#^$-]','_','g')
        if l:klayer != g:km_default_layername && len(l:mapping)
            call add(l:return,'fu toggle_'.l:layer_key_name)
            call extend(l:return,map(l:mapping,'"  ".v:val'))
            call add(l:return,'endfu')
        else 
            call extend(l:return,l:mapping)
        endif
    endfor 
    call append(line('.'), l:return)
endfu


" Alias part
" ----------

" @function keybindings#LowercaseAliasesForCommand(...)
" Creation aliases for commands in args.
" If more than one word is provided, then characters '!%/ ' are removed.
" Example: call keybindings#LowercaseAliasesForCommand('Info', 'Info info', 's/first/second/', '!date')
"          will create aliases : info, infoinfo, sfirstsecond, date
function! keybindings#LowercaseAliasesForCommand(...)
    for l:cmd in a:000
        call keybindings#Alias(substitute(tolower(l:cmd), '[!%/ ]*', '', 'g'), l:cmd, {})
    endfor
endfunction

" @function keybindings#Alias(alias, cmd, options = {})
" Creation alias for command. 
" Options opts a dictionnary with possible keys :
" - autocmd     : str default empty : autocmd to define the alias in a specific context
" - if          : str default empty : expression to validate in order to expand
" - append_expr : str default empty : expression to call when expanding
" - append      : str default empty : string to add after expansion
" - keymap_type : char default 'c' : 'c' or 'i'
" - do_expand   : bool default false : if true, try to expands variables in command
" - is_inline   : bool default false : if false, the alias only expand at start of the line
" - is_expr     : bool default false : if true, treat command as vim expression
" - is_keymap   : bool default false : if true, use 'map' insteand of 'abbrev' 
" Example: call keybindings#Alias('help', 'Help info', {})
function! keybindings#Alias(alias, cmd, ...)
    let l:opts = get(a:000, 0, {})
    let l:autocmd=get(l:opts, 'autocmd', '')
    let l:addcond=get(l:opts, 'if', '')
    let l:addfunct=get(l:opts, 'append_expr', '')
    let l:addend=get(l:opts, 'append', '')
    if len(l:addcond)
        let l:addcond=' && ('.l:addcond.')'
    endif
    if len(l:autocmd)
        let l:autocmd = 'autocmd ' . l:autocmd . ' '
    endif
    let l:keymap_type = get(l:opts, 'keymap_type', 'c') 
    let l:cmdmodtest='(mode() == "'.l:keymap_type.'")'
    let l:cmdlineget=''
    if l:keymap_type == 'c'
        let l:cmdmodtest='(getcmdtype()==":")'
        let l:cmdlineget='substitute(getcmdline(), "^'."'<,'>".'", "", "")'
    elseif l:keymap_type == 'i'
        let l:cmdlineget='getline()'
    endif
    let l:condpart = l:cmdmodtest.l:addcond
    let l:qalias = '"'.escape(a:alias,'"\').'"'
    if len(l:cmdlineget) && !get(l:opts, 'is_inline', 0)
        let l:condpart .=  ' && ('.l:cmdlineget.' == '
        let l:condpart .= get(l:opts, 'is_keymap', 0) ? '""' : l:qalias 
        let l:condpart .=  ')'
    endif
    if get(l:opts, 'is_expr', 0)
        let l:def = l:autocmd.l:keymap_type.'abbrev <expr> '.a:alias
                    \ .'( '. l:condpart.' ) ? (' . a:cmd .' ) : (' .l:qalias.' )'
    else
        let l:cmdexpr = '"'.escape(a:cmd,'"\').'"'
        if get(l:opts, 'do_expand', 0)
            let l:cmdexpr = 'expandcmd('.l:cmdexpr.')'
        endif
        if len(l:addfunct)
            let l:addfunct=' . '.l:addfunct
        endif
        if get(l:opts, 'is_keymap', 0)
            let l:cmdexpr = l:cmdexpr.' '.l:addfunct
            if len(l:addend)
                let l:cmdexpr .= ' . strpart(feedkeys("'.l:addend.'"), 0, 0)'
            endif
            let l:def = l:autocmd.l:keymap_type.'noremap '.a:alias
                        \ ." <C-r>=( ".l:condpart." ) ? ( ".
                        \  l:cmdexpr .' ) : ( '.l:qalias.' )<Cr>'
        else
            if len(l:addend)
                let l:cmdexpr .= '.strpart(getchar(0), 0, 0) '.l:addfunct
                let l:cmdexpr .= ' . strpart(feedkeys("'.l:addend.'"), 0, 0)'
            else
                let l:cmdexpr .= ' '.l:addfunct
            endif
            let l:def = l:autocmd.l:keymap_type.'noreabbrev  <expr> '.a:alias .' ( '. l:condpart. ' ) ? ( '
                        \ .l:cmdexpr.' ) : ( '.l:qalias.' )'
        endif
    endif
    call s:set_val(l:def, g:km_layer_keymapping, g:km_default_layername, l:keymap_type, '__aliases__', a:alias)
    exe l:def
endfu


" @function Keymap#Source([file], (opt) [substs], (opt) include_sid)
" Source [file] according to the |keybindings-format|.
"
" Below, an example for substs and to use <SID> keyword in file loaded:
" let s:substs=[
"       \ ['getregid("\([^"]*\)")', 'echo "Register \1?"  | let reg=nr2char(getchar()) | echo reg', 'g'],
"       \ ['pum?', '<expr>pumvisible()?', '']
"       \]
" call keybindings#Source(expand('<sfile>'), s:substs, 1)
fu! keybindings#Source(file, ...)
    let l:autocmdinfo=''
    let l:aliasifcond=''
    let l:skip=0
    let l:skipdone=0
    let l:substs = get(a:000, 0, [])
    let l:include_sid = get(a:000, 1, 0)
    let [l:currentloop_var_names, l:currentloop_var_values] = [[],[]]
    if l:include_sid
        call add(l:substs, ['<SID>',s:SNR(a:file),'g'])
    endif
    for l:l in readfile(a:file)
        if len(l:l) && l:l !~ '^"'
            if !skipdone && l:l =~ '^finish\s*$'
                " finish allow to secure keymap file from loading with source %
                " keybindings % .. to load the file with so %
                " it allows to put vim commands from keybindings or from if 0
                " Then it allows to do inception
                let l:skip=0
                let l:skipdone=1
                continue
            elseif !l:skip
                let l:l = s:do_subst(l:l, l:substs)
                if l:l =~ '^autocmd$'
                    let l:autocmdinfo=''
                elseif l:l =~ '^autocmd '
                    let l:autocmdinfo=strpart(l:l,8)
                elseif l:l =~ '^km:for '
                    let [l:currentloop_var_names, l:currentloop_var_values]=s:extract_km_for_vars(strpart(l:l,3))
                elseif l:l =~ '^km:endfor'
                    let [l:currentloop_var_names, l:currentloop_var_values]=[[],[]]
                elseif l:l =~ '^alias:if '
                    let l:aliasifcond=strpart(l:l,9)
                elseif l:l =~ '^alias:endif'
                    let l:aliasifcond=''
                elseif l:l =~ '^\(alias\|expand\) '
                    cal s:ReadAliasLine(l:l,l:autocmdinfo,l:aliasifcond)
                elseif l:l =~ '^km([^)]*)\s\+\(\S\+\s\+\)\+"[^"]*"\s\+\(\S.\+\s*\)\?'
                    if len(currentloop_var_values)
                        for l:vals in l:currentloop_var_values
                            let l:repl = {}
                            for l:i in range(len(l:vals))
                                let l:repl['{'.l:currentloop_var_names[l:i].'}'] = l:vals[l:i]
                            endfor
                            cal s:ReadKeyLine(s:do_subst(l:l, l:repl),l:autocmdinfo)
                        endfor
                    else
                        cal s:ReadKeyLine(l:l,l:autocmdinfo)
                    endif
                elseif l:l =~ '^\(if 0\|keybindings \).*'
                    let l:skip=1
                    continue
                else
                    echo 'Syntax Error : '.l:l
                endif
            endif
        endif
    endfor
endfu
let s:home=expand('~')
function! s:SNR(file)
    let l:file=substitute(a:file,'^'.s:home,'\\\\\\\~','')
    let l:ret=substitute(
                \ filter(split(execute('scriptnames'), "\n"),'v:val =~ "'.l:file.'"')[0],
                \ '^\s*\(\d\+\).*$','\1',''
                \)
    return '<SNR>'.l:ret.'_' 
endfun


fu! s:_extract(line, pattern, a_offset, b_offset, m_offset, before)
    " return  [bool matched, str extracted, str line_after_extraction]
    "      trimming useless spaces during extraction
    " param regex pattern  is a pattern for match() function
    " param int a_offset is the offset to pattern idx for extracted part
    " param int b_offset is the offset from pattern idx for line after extraction
    "      when a_offset = b:offset you get the full line in 2 parts
    " param int m_offset is used to determined a minimal size of a word when the pattern is \s
    " param bool before is used to
    "         return [bool matched, str line_after_extraction, str extracted]
    " 
    let l:pos=match(a:line, a:pattern, a:m_offset)
    if (l:pos > -1)
        return [1, trim(strpart(a:line, 0, l:pos+a:a_offset), ' ', 1), trim(strpart(a:line, l:pos+a:b_offset), ' ', 1)]
    endif
    return a:before ? [0, a:line, ''] : [0, '', a:line]
endfu

fu! s:ReadAliasLine(l, au, ifcond)
  "typical example : 
  "  alias:if exists('*myconf#get_path')
  "> alias ta tabnew <C-r>=myconf#get_path('/parts/*/addons')<cr>
  "  alias:endif
  let l:O={'autocmd': a:au, 'if': a:ifcond}
  let [l:m, l:O['type'], l:l] = s:_extract(a:l, '\s\S', 0, 1, 2, 0)
  let [l:m, l:A, l:l] = s:_extract(l:l, '\s\S', 0,  1, 1, 0)
  let [l:O['is_keymap'], l:n, l:l] = s:_extract(l:l, '<.map>',  6, 6, 0, 0)
  if l:O['is_keymap']
      let l:O['keymap_type'] = substitute(l:n, '.*<\(.\)map>.*', '\1', '')
  endif
  if l:O['type'] == 'expand'
      let l:O['do_expand'] = 1
      let l:O['is_inline'] = 1
  else
      let [l:O['do_expand'], l:n, l:l] = s:_extract(l:l, '<expand>',  0, 8, 0, 0)
      let [l:O['is_inline'], l:n, l:l] = s:_extract(l:l, '<inline>',  0, 8, 0, 0)
  endif
  let [l:O['is_expr'], l:n, l:l] = s:_extract(l:l, '<expr>',  0, 6, 0, 0)
  let [l:O['consume_char'], l:l, l:O['append']] = s:_extract(l:l, '<C-d>', 0, 0, 0, 1)
  let [l:m, l:l, l:O['append_expr']] = s:_extract(l:l, '<C-r>=.*<cr>', 0, 6, 0, 1)
  let l:O['append_expr'] = substitute(l:O['append_expr'], '<cr>', '', 'g')
  " unsilent echo l:A.'->['.l:l.']'
  " unsilent echo l:O
  cal keybindings#Alias(l:A, l:l, l:O)
endfu

fu! s:ReadKeyLine(l, autocmdinfo)
  "typical example : 
  "km(i<C-o>)   <C-a>  "Example"  :echo example<cr>
  let [l:m, l:w, l:l] = s:_extract(a:l, 'km([^)]*)', 0, 3, 0, 0)
  let [l:m, l:modes, l:l] = s:_extract(l:l, ')\s*', 0, 1, 0, 0)
  let l:modes = map(split(l:modes, ','), 'trim(v:val," ",1)')
  let [l:m, l:w, l:l] = s:_extract(l:l, '[^ ]', 0, 0, 0, 0)
  let [l:m, l:keys_str, l:l] = s:_extract(l:l, '"[^>]\S[^"]*"', 0, 1, 0, 0)
  let [l:m, l:comment, l:l] = s:_extract(l:l, '"', 0, 1, 0, 0)
  let [l:m, l:w, l:action] = s:_extract(l:l, '[^ ]', 0, 0, 0, 0)
  let l:keys=filter(split(l:keys_str,' '),'len(v:val)')
  let l:comment=substitute(substitute(l:comment,'"\s*','',''),'\s*"','','')
  let l:action=substitute(l:action,'\s*$','','')
  cal keybindings#Map(l:comment, l:keys,l:action,l:modes,a:autocmdinfo)
endfu

fu! s:extract_km_for_vars(l)
    let [l:m, l:w, l:l] = s:_extract(a:l, 'for ', 0, 4, 0, 0)
    let [l:m, l:keys, l:l] = s:_extract(l:l, ' in ', 0, 4, 0, 0)
    let l:keys = split(trim(substitute(l:keys,' ','','g'), ' []'), ',')
    let l:values_list = eval(l:l)
    if !len(l:values_list) | return [[], []] | endif
    if type(l:values_list[0]) != type([])
        call map(l:values_list, "[v:val]")
    endif
    " unsilent echo [l:keys, l:values_list]
    return [l:keys, l:values_list]
endfu

let g:loaded_accessibility_keymap=1
