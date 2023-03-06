" T - wrapper for frequently used term_sendkeys terminal function.
" oleg-work@icloud.com

if exists("g:loaded_t")
    finish
endif
let g:loaded_t = 1

let s:previous_int_buffer_id = 0

function! s:SendSelectedToTermBufferId(...) range
  " check for invalid buffer id
  let l:str_buffer_id = get(a:, 1, 0)
  let l:int_buffer_id = str2nr(l:str_buffer_id)
  if l:int_buffer_id == 0 && s:previous_int_buffer_id == 0
    echom "Invalid buffer id"
    return
  endif

  " check that buffer is a terminal
  if l:int_buffer_id == 0
    let l:int_buffer_id = s:previous_int_buffer_id
  elseif getbufvar(l:int_buffer_id, '&buftype', 'ERROR') ==# 'terminal'
    let s:previous_int_buffer_id = l:int_buffer_id
  else
    echom "Buffer isn't a terminal."
    return
  endif

  let s:saved_register = @@
  " copy selected text using marks
  keepjumps normal! `<v`>y
  " delete new line character at the end
  let @@ = substitute(@@, '\n', '', '')
  " escape special characters
  let @@ = escape(@@, '\')
  let @@ = escape(@@, '"')

  execute printf('call term_sendkeys(%d,"%s\r")', l:int_buffer_id, @0)

  " restore buffer
  let @@ = s:saved_register
endfunction

" Accepting range and 0 or 1 argument
command! -range -nargs=? T call s:SendSelectedToTermBufferId(<f-args>)
