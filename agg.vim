function! s:cmdname()
  for i in reverse(range(1, getpos('.')[1]))
    let x = get(matchlist(getline(i), '^-- \$ \(\w\+\)'), 1)
    if type(x) == 1
      return {'just': x}
    endif
  endfo
  return {'nothing': 1}
endfunction

function! s:reset_filetype()
  let maybe = s:cmdname()
  if has_key(maybe, 'just') && &filetype != maybe.just
    let &filetype = maybe.just
  endif
endfunction

" command! -nargs=0 Cmdname echo <SID>cmdname()
command! -nargs=0 AggResetFiletype call <SID>reset_filetype()

"nnoremap <buffer> j j:AggResetFiletype<Cr>
"nnoremap <buffer> k k:AggResetFiletype<Cr>
