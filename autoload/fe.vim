" ============================================================================
" FileName: fe.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

" FindEverything
function! s:Handle_String(string)
  let l:str = a:string
  "trim
  let l:str = substitute(l:str, '^[[:blank:]]*\|[[:blank:]]*$', '', 'g')
  "if there is any space in file name, enclosed by double quotation
  if len(matchstr(l:str, " "))
    "don't add backslash before any white-space
    let l:str = substitute(l:str, '\\[[:blank:]]\+', " ", "g")
    let l:str = '"'.l:str.'"'
  endif
  return l:str
endfunction

" Filter_Everything_Result
function! s:Filter_Everything_Result(result)
  let filter_ext = g:fe_result_filter
  let l:filter_result = ""
  for filename in split(a:result, '\n')
    let file_ext = fnamemodify(filename, ":e")
    if has_key(filter_ext, file_ext)
      let l:filter_result = l:filter_result . filename . "\n"
    endif
  endfor
  return l:filter_result
endfunction

function! fe#StartSearch(pattern, filter)
  if !executable(g:fe_es_exe)
    call fe#util#show_msg('g:fe_es_exe 路径错误!', 'error')
    return
  endif
  let cmd = s:Handle_String(g:fe_es_exe)

  if !empty(a:pattern)
    let pattern = a:pattern
  else
    let pattern = input("Input pattern: ")
  endif
  " let pattern = s:Handle_String(pattern)

  if !empty(g:fe_default_loc)
    let dir = g:fe_default_loc
  else
    let dir = input("Search in the location: ", "", "dir")
    if empty(dir)
      return
    endif
  endif
  let dir = s:Handle_String(g:fe_default_loc)

  let cmd = printf('%s %s %s %s', cmd, g:fe_es_options, dir, pattern)
  let s:cache = ''

  if exists('*job_start')
    call job_start(cmd, #{
      \ out_cb: function('s:On_Out_Or_Exit', [a:filter, 'out']),
      \ exit_cb: function('s:On_Out_Or_Exit', [a:filter, 'exit']),
      \ })
  else
    let res = system(cmd)
    call s:On_Out_Or_Exit(a:filter, res)
  endif
endfunction

let s:cache = ''

function! s:On_Out_Or_Exit(filter, ...) abort
  if a:0 == 1
    let s:cache = a:1
  elseif a:0 == 3
    if a:1 == 'out'
      let s:cache .= a:3
      let s:cache .= "\n"
      return
    elseif a:1 == 'exit'
    endif
  else
    return
  endif

  " HACK!!!
  let cp = libcallnr('kernel32.dll', 'GetACP', 0)
  let s:cache = iconv(s:cache, printf('cp%d', cp), &encoding)
  if empty(s:cache)
    call fe#util#show_msg('No files found!', 'error')
    return
  endif
  if matchstr(s:cache, 'Everything IPC window not found, IPC unavailable.') != ""
    call fe#util#show_msg('Everything.exe 未运行！', 'error')
    return
  endif

  " Filter the results. But it will be very slow if there are huge number of results.
  if a:filter
    let s:cache = s:Filter_Everything_Result(s:cache)
  endif

  " Show results
  call fe#display#create(s:cache)
endfunction

function! fe#ToggleDisplay()
  call fe#display#toggle(s:cache)
endfunction
