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

"Show_Everything_Result
function! s:Show_Everything_Result(result)
  let bname = '_Everything_Search_Result_'
  " If the window is already open, jump to it
  let winnr = bufwinnr(bname)
  if winnr != -1
    if winnr() != winnr
      " If not already in the window, jump to it
      exe winnr . 'wincmd w'
    endif
    setlocal modifiable
    " Delete the contents of the buffer to the black-hole register
    silent! %delete _
  else
    let bufnum = bufnr(bname)
    if bufnum == -1
      let wcmd = bname
    else
      let wcmd = '+buffer' . bufnum
    endif
    exe 'silent! botright ' . g:fe_window_height . 'split ' . wcmd
  endif
  " Mark the buffer as scratch
  setlocal buftype=nofile
  "setlocal bufhidden=delete
  setlocal noswapfile
  setlocal nowrap
  setlocal nobuflisted
  setlocal winfixheight
  setlocal modifiable
  let winnr = winnr()

  " Create a mapping
  call s:Map_Keys()
  " Display the result
  silent! %delete _
  silent! 0put =a:result

  " Delete the last blank line
  silent! $delete _
  " Move the cursor to the beginning of the file
  normal! gg
  setlocal nomodifiable
endfunction

"Map_Keys
function! s:Map_Keys()
  nnoremap <buffer> <silent> <CR>
    \ :call <SID>Open_Everything_File('filter')<CR>
  nnoremap <buffer> <silent> <2-LeftMouse>
    \ :call <SID>Open_Everything_File('external')<CR>
  nnoremap <buffer> <silent> <C-CR>
    \ :call <SID>Open_Everything_File('internal')<CR>
  nnoremap <buffer> <silent> <ESC> :close<CR>
endfunction

"Open_External
function! s:Open_External(fname)
  let cmd = substitute(a:fname,'/',"\\",'g')
  let cmd = " start \"\" \"" . cmd . "\""
  call system(cmd)
endfunction

"Open_Internal
function! s:Open_Internal(fname)
  let s:esc_fname_chars = ' *?[{`$%#"|!<>();&' . "'\t\n"
  let esc_fname = escape(a:fname, s:esc_fname_chars)
  let winnum = bufwinnr('^' . a:fname . '$')
  if winnum != -1
    " Automatically close the window
    silent! close
    " If the selected file is already open in one of the windows, jump to it
    let winnum = bufwinnr('^' . a:fname . '$')
    if winnum != winnr()
      exe winnum . 'wincmd w'
    endif
  else
    " Automatically close the window
    silent! close
    " Edit the file
    exe 'edit ' . esc_fname
  endif
endfunction

" Open_Filter
function! s:Open_Filter(fname)
  let l:filter = g:fe_openfile_filter
  let current_ext = fnamemodify(a:fname, ":e")
  for ext in l:filter
    if ext == current_ext
      call s:Open_Internal(a:fname)
      return
    endif
  endfor
  call s:Open_External(a:fname)
endfunction

" Open_Everything_File
function! s:Open_Everything_File(mode)
  let fname = getline('.')
  if empty(fname)
    return
  endif

  if a:mode == 'external'
    call s:Open_External(fname)
  elseif a:mode == 'internal'
    call s:Open_Internal(fname)
  elseif a:mode == 'filter'
    call s:Open_Filter(fname)
  endif
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
    if empty(pattern)
      return
    endif
  endif
  let pattern = s:Handle_String(pattern)

  let dir = input("Search in the location: ", "", "dir")
  let dir = s:Handle_String(dir)

  let cmd = printf('%s %s %s %s', cmd, g:fe_es_options, dir, pattern)

  " HACK
  let l:result = iconv(system(cmd), 'cp936', 'utf-8')
  if empty(l:result)
    call fe#util#show_msg('No files found!', 'error')
    return
  endif
  if matchstr(l:result, 'Everything IPC window not found, IPC unavailable.') != ""
    call fe#util#show_msg('Everything.exe 未运行！', 'error')
    return
  endif

  " Filter the results. But it will be very slow if there are huge number of results.
  if a:filter
    let l:result = s:Filter_Everything_Result(l:result)
  endif

  " Show results
  call s:Show_Everything_Result(l:result)
endfunction

function! fe#ToggleResultWindow()
  let bname = '_Everything_Search_Result_'
  let winnum = bufwinnr(bname)
  if winnum != -1
    if winnr() != winnum
      " If not already in the window, jump to it
      exe winnum . 'wincmd w'
      return
    else
      silent! close
      return
    endif
  endif

  let bufnum = bufnr(bname)
  if bufnum == -1
    call fe#util#show_msg('No FE results yet!', 'error')
    let wcmd = bname
  else
    let wcmd = '+buffer' . bufnum
    exe 'silent! botright ' . '15' . 'split ' . wcmd
  endif
endfunction
