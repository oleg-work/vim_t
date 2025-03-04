"
" T - wrapper for frequently used term_sendkeys terminal function.
"

if exists("g:t_loaded")
    finish
endif
let g:t_loaded = 1

let s:prev_term_buffer_id = v:null

function! s:GetIntBufferId(str_buffer_id)
  let l:int_buffer_id = str2nr(a:str_buffer_id)
  return l:int_buffer_id != 0 ? l:int_buffer_id : v:null
endfunction

function! s:IsTermBufferId(term_buffer_id)
  if getbufvar(a:term_buffer_id, '&buftype', 'ERROR') ==# 'terminal'
    return v:true
  else
    return v:false
  endif
endfunction

function! s:GetTermBufferId(maybe_term_buffer_id)
  let l:curr_term_buffer_id = s:GetIntBufferId(a:maybe_term_buffer_id)
  let l:term_buffer_id = l:curr_term_buffer_id != v:null
                          \ ? l:curr_term_buffer_id
                          \ : s:prev_term_buffer_id
  if !s:IsTermBufferId(l:term_buffer_id)
    echom "Buffer " . l:term_buffer_id . " isn't terminal buffer."
    return v:null
  endif
  let s:prev_term_buffer_id = l:term_buffer_id
  return l:term_buffer_id
endfunction

function! s:SendCmdToTermBufferId(term_buffer_id, term_command_str)
  " escape special characters
  let l:cmd_str = escape(a:term_command_str, '\')
  let l:cmd_str = escape(l:cmd_str, '"')
  " \r - new line char to force command execution
  execute printf('call term_sendkeys(%d,"%s\r")', a:term_buffer_id, l:cmd_str)
endfunction

function! s:SendVisualModeCmdsToTermBufferId(...) range
  let l:should_join_selected_cmds = get(a:, 1, v:null)
  if l:should_join_selected_cmds == v:null
    echom "Invalid function args."
    return
  endif
  let l:term_buffer_id = s:GetTermBufferId(get(a:, 2, v:null))
  if l:term_buffer_id == v:null
    return
  endif

  let s:temporary_saved_register = @@
  " copy selected text using marks
  silent keepjumps normal! `<v`>y

  " any path will delete new line character at the end,
  " and we will add it later manually
  if l:should_join_selected_cmds == v:true
    let @@ = substitute(@@, '\n', ' ', 'g')
  else
    let @@ = substitute(@@, '\n\+$', '', '')
  endif

  call s:SendCmdToTermBufferId(l:term_buffer_id, @0)

  " restore buffer
  let @@ = s:temporary_saved_register
endfunction

function! s:SendCommandModeCmdToTermBufferId(...) range
  let l:maybe_term_buffer_id = get(a:, 1, v:null)
  let l:term_buffer_id = s:GetTermBufferId(l:maybe_term_buffer_id)
  if l:term_buffer_id == v:null
    return
  endif
  if empty(a:000)
    " send carriage return to terminal buffer
    call s:SendCmdToTermBufferId(l:term_buffer_id, '')
    return
  endif
  let l:term_cmd_parts = a:000
  let l:is_first_arg_buffer_id = (l:term_buffer_id == s:GetIntBufferId(l:maybe_term_buffer_id))
  if l:is_first_arg_buffer_id
    let l:term_cmd_parts = a:000[1:]
  endif
  let l:term_cmd = join(l:term_cmd_parts, ' ')
  call s:SendCmdToTermBufferId(l:term_buffer_id, l:term_cmd)
endfunction

command! -range -nargs=? Ts call s:SendVisualModeCmdsToTermBufferId(v:true, <f-args>)
command! -range -nargs=? Tm call s:SendVisualModeCmdsToTermBufferId(v:false, <f-args>)
command! -nargs=* Tt call s:SendCommandModeCmdToTermBufferId(<f-args>)

" vim: et ts=2 sw=2 sts=2
