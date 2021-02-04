" KeyMap.vim -- Vim lib complex keybind definitions
" @Author:      luffah (luffah AT runbox com)
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Created:     2018-03-26
" @Last Change: 2018-06-10
" @Revision:    4
if exists('g:loaded_accessibility_keymap') || &compatible
    "finish
endif

let g:KeyMap_print_mode=0
" @fileformat *KeyMap-format*
" Given :
"  * keybind(s) is a list of keybinds (separated by a ' ')
"  * Comment is an human description of the action
"  * Action is a sequence of keys as it was typed
"  * Mode(s)/Post-Action(s) is a list (separated by a ' ') of:
"    * Mode is a mode as defined in |g:km_mode_hash|
"    * Post-Action is a sequence of keys
"
" The short format to define keymaps is the following.```
"  "keybind(s) "Comment"           Action         % mode(s)/post-action(s)
"  <F1>        "Cleared key"        <nop>         % c v
"  <F2> <F3>   "Cleared keys"       <nop>         % c v
"  <A-t>       "Cycle tab"          gt            % n I
"  <A-T>       "Cycle tab"          gT            % n I
"  
"  " Mode variation for an uniq keybind 
"  <A-P>       "Do paste"                         % c<C-r>+ I"+P  n"+P  v"+P
"
"  " Use expressions
"  <A-Up>   "Complete/select"  <expr>pumvisible()?"<KeyBind>":"<C-x><C-i>" % i
"
"  "Simple commands from normal mode
"  <F11> "-" registers %  :
"
"  "Filetype rules
"  [FileType python]
"            "No invisible space" <Space>         %  c i
"  []
"
"  " COMMAND LINE SPECIFIC
"  " Dynamic variable expansion
"  %%        "Local dir"          %:p:h/          % a
"
"  " Aliases
"  tnn       "Show files arround" tabnew %:p:h    % A/<C-d>
"  alias qa confirm qa
"```
" See ./samples/ to get many examples.
"
" @fileformat *keymap-inception* 
" "Keymap inception" is the practice to bind |KeyMap-format| in a vim
" script. In order to use it, the script part shall be at file beginning
" and be surrounded by `if 0 | endif` and `finish`. ```
"      if 0 | endif
"      KeyMap <sfile>
"      finish
"      Q        "Cleared key" <nop> % n
" ```

" @global g:km_file_include_sid
" To set before using |:Keymap| in order to use script local variable
" and function.
let g:km_file_include_sid=0

" @global g:km_file_substs
" To set before using |:Keymap| in order to use to substitute repetitive
" sequence.
" Require |keymap-inception|. ```
"      if 0 | endif
"      let g:km_file_substs=[
"      \ ['pum?', '<expr>pumvisible()?', '']
"      \]
"
"      KeyMap <sfile>
"      finish
"      <A-Up>    "Compl.from file  " pum?"<UP>":"<C-x><C-i>"   %  i
"      finish
"```
let g:km_file_substs=[]

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

" 1 -> show explanation for alternatives keys
let g:km_document_alternatives = get(g:, 'km_document_alternatives', 0)

" @global g:km_mode_hash
" All known modes, shall not be set before the plugin is loaded
" to modify or add a mode. Example : ```
"    " 'I' for one-shot normal mode from insert mode
"    let g:km_mode_hash['I']=['i','<C-o>','']
"```
" A value of this dict is a list : (mode, before_action, after_action)
" Note: after_action is followed by the post-action (see |KeyMap-format|)
"
" Default values (with $A as action, and $P as post-action):
"     n -> in normal mode, do $A$P
"     : ->               , do :$A<Cr>$P
"     i- > in insert mode, do $A$P
"     N ->               , do <Esc>$A$P
"     I ->               , do <C-o>$A$P
"     v -> in select/visual mode, do $A$P
"     V ->                     ", do <Esc>$A$P
"     s -> in select mode, do $A$P
"     S ->               , do <Esc>$A$P
"     x -> in visual mode, do $A$P
"     X ->               , do <Esc>$A$P
"     o -> in operator-pending mode, do $A$P
"     O ->                         , do <Esc>$A$P
"     l -> in insert/command-line/lang-arg mode, do $A$P
"     L ->                                     , do <Esc>$A$P
"     c -> in command-line mode, do $A$P
"     C ->                     , do <Esc>$A$P
"     a ->                     , expand to $A and do $P
"     A ->                     , expand to $A if keybind is the first element
"                                (Equivalent of 'alias keybind $A'
"                                 with dynamic expansion)
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
      \ s:km_layer_oneshot.'=\(\a\+\)\((\(\a\+\))\)\?>': "<Esc>:call KeyMap#OneShot('<ActionName>','<Mode>','\\1', '\\3')<Cr>",
      \ s:km_layer_toggle : "<Esc>:call KeyMap#ToggleLayer('<ActionName>')<Cr>",
      \ s:km_layer_exit : "<Esc>:call KeyMap#ToggleLayer('<LayerName>')<Cr>"
      \}


" We need to ensure Alt keybindings work in terminal as much in gui
if has("gui_running") || has("nvim")
  fu! KeyMap#ensureKeybind(k)
    return escape(a:k,'|')
  endfu
else
  let s:ensured_key={
        \"<A-à>":"à",
        \"<A-é>":"é",
        \"<A-è>":"è",
        \}
  fu! KeyMap#ensureKeybind(k)
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

"
" Layer Description
fu! KeyMap#PrintLayer(layer)
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
  call statusui#HelpWin('Layer '.a:layer,l:prt,'keymapping')
endfu

" @function KeyMap#PrintCurrentLayer()
" Print current keybind layer.
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
      if !has_key(g:km_revert_keymapping,l:mode)
        let g:km_revert_keymapping[l:mode]={}
      endif
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
        let g:km_revert_keymapping[l:mode][l:key]=l:revert_action
      endfor
    endfor
    if ( a:layer[0] != '~' )
      cal KeyMap#PrintCurrentLayer()
    endif
  endif
  let g:km_layer_status=s:LayerStatus()
  redraw!
  redrawstatus!
endfu

" @command :Layer [layer_name]
" Toggle [layer_name].
command! -nargs=* -complet=customlist,<SID>LayerNameComplete Layer cal KeyMap#ToggleLayer(<q-args>) 

" @command :Layers
" List possible values for |:Layer|.
command! -nargs=0 Layers echo keys(g:km_layer_keymapping)
fu! s:LayerNameComplete(A,L,P)
  return keys(g:km_layer_keymapping)
endfunction

fu! KeyMap#OneShot(layer,mode,commandkey,...)
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
    cal KeyMap#PrintLayer(a:layer)
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
    exe a:commandkey.' '.l:action
  catch
    echomsg l:action.' is not a valid key. (mode: '.a:mode', commandkey:'.a:commandkey.')'
  endtry
  " let g:km_active_layer=l:prev_layer
  " let g:km_layer_status=s:LayerStatus()
endfu

" Main Mapping function
" --------------------------
let s:last_layer=g:km_default_layername

" @function KeyMap#Map(name, keybinds, action, modes_and_post_actions)
" Assign keybindings with these arguments
" - name   required for info e.g. 'Save the file', 
" - keybind or keybind list e.g. '<C-s>', ['<C-s>','<C-S'>]
" - action                   e.g. ':w<CR>',
" - list of mode (1st char)
"   and post action         e.g. 'i','Ia','n','v' 
" e.g. 'ia' -> for insert mode do the keybinding a reenter in insert mode with 'a' 
" e.g. 'i<Left>' -> for insert mode do the keybinding and move cursor to left
fu! KeyMap#Map(name, keybind, action, modes,...)
  " correct types
  let l:keybind_alternatives = type(a:keybind) == type([]) ? a:keybind : [a:keybind]
  let l:modes = type(a:modes) == type([]) ? a:modes : [a:modes]
  let l:has_pipe=( match(a:action,"|") + 1 )
  let l:is_keybind_not_layer=1
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
      let l:is_keybind_not_layer=0
      let s:last_layer=a:name
      if !has_key(g:km_layer_keymapping,a:name)
        let g:km_layer_keymapping[a:name] = {}
      endif
    elseif ( match(a:action, s:km_layer_oneshot) > -1 )
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
        let l:keybind=KeyMap#ensureKeybind(l:keybind_alternatives[l:i])
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
    let l:recursive=0
    if l:curr[0] == '~'
      let l:recursive=1
      let l:curr = l:curr[1:]
    endif
    let l:i = 0
    while l:i < len(l:keybind_alternatives)
      " # Get the keys to bind
      let l:keybind=KeyMap#ensureKeybind(l:keybind_alternatives[l:i])
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
      if l:has_pipe
        let l:action=substitute(l:action, '\?|', '|','g')
      endif
      if match(l:action,"<expr>") == 0
        let l:keybinding_opts.='<expr> '
        let l:action=substitute(l:action,'<expr>\s*','','')
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
            " l:i == 0 ? '':'~' avoid to describe keybind alternative
      if l:recursive
         let g:km_layer_keymapping[l:layer][l:mode_char][l:keybind]+=[1]
      endif
      " # Map the keybind
      if l:is_mappable_at_start
        let l:mapaction = l:autocmd  . l:mode_char.(l:recursive?'': 'nore').'map ' .
              \l:keybinding_opts . l:keybind . ' ' . l:action
        exe l:mapaction
      endif
      let l:i += 1
    endwhile
  endfor
endfu

"@function KeyMap#export()
" export for a faster boot and lighter memory usage
" without dependencies
" and to share your keymap
fu! KeyMap#export()
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

" @function Keymap#Source([file])
" Source [file] according to the |KeyMap-format|.
fu! KeyMap#Source(file)
  let l:autocmdinfo=''
  let l:skip=0
  let l:skipdone=0
  let l:substs = g:km_file_substs
  if g:km_file_include_sid
    call add(l:substs, ['<SID>',s:SNR(a:file),'g'])
  endif
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
        for [l:s,l:t,l:o] in l:substs
          let l:l=substitute(l:l,l:s,l:t,l:o)
        endfor
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
  " for security issues, disable at end of each file
  let g:km_file_substs=[]
  let g:km_file_include_sid=0
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

" @command :KeyMap [file]
" Source [file] according to the |KeyMap-format|. Use |Keymap#Source()|.
command! -complete=file -nargs=+ KeyMap call KeyMap#Source(expand(<q-args>))

fu! s:ReadAliasLine(line,autocmdinfo)
  let l:alias_pos=match(a:line,'\s\S',2)
  let l:command_pos=match(a:line,'\s\S',l:alias_pos+1)
  let l:alias=strpart(a:line,l:alias_pos+1,l:command_pos-l:alias_pos-1)
  let l:cmd=strpart(a:line,l:command_pos+1)
  cal KeyMap#Alias(l:alias, l:cmd,a:autocmdinfo)
endfu

fu! s:matchstrpos(line, pattern,start)
  let l:pos=match(a:line,a:pattern,a:start)
  let l:str=matchstr(a:line,a:pattern,a:start)
  let l:endpos=l:pos + len(l:str)
  return [l:str, l:pos, l:endpos]
endfu

fu! s:ReadKeyLine(line,autocmdinfo)
  " echo a:line
  let l:keys_pos=match(a:line,'[^ ]',0)
  let [l:comment,l:comment_pos,l:comment_end_pos]=s:matchstrpos(a:line,'"[^>]\S[^"]*"',l:keys_pos+1)
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

let g:loaded_accessibility_keymap=1
