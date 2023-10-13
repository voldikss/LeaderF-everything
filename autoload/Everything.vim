" ============================================================================
" FileName: Everything.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

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

function! Everything#StartSearch(args)
  if has_key(a:args, 'pattern')
    let pattern = join(a:args['pattern'])
  else
    let pattern = input("Input pattern: ")
  endif
  if empty(pattern)
    return []
  endif

  if !executable(g:Lf_EverythingEsPath)
    call Everything#util#show_msg('g:Lf_EverythingEsPath 路径错误!', 'error')
    return ['']
  endif
  let cmd = s:Handle_String(g:Lf_EverythingEsPath)

  if !empty(g:Lf_EverythingDefaultDir)
    let dir = g:Lf_EverythingDefaultDir
  else
    let dir = input("Search in the location: ", "", "dir")
    if empty(dir)
      return
    endif
  endif
  let dir_arg = printf('-path "%s"', dir)

  let cmd = printf('%s %s %s %s', cmd, g:Lf_EverythingEsOptions, dir_arg, pattern)
  let s:cache = ''

  let res = system(cmd)
  let cp = libcallnr('kernel32.dll', 'GetACP', 0)
  let res = iconv(res, printf('cp%d', cp), &encoding)
  if empty(res)
    call Everything#util#show_msg('No files found!', 'error')
    return ['']
  endif
  if matchstr(s:cache, 'Everything IPC window not found, IPC unavailable.') != ""
    call Everything#util#show_msg('Everything.exe 未运行！', 'error')
    return ['']
  endif
  return split(res, "\n")
endfunction

function! Everything#Accept(line, args)
  call s:Open_Filter(a:line)
  norm! zz
  setlocal cursorline!
  redraw
  sleep 100m
  setlocal cursorline!
endfunction

function! Everything#Preview(orig_buf_nr, orig_cursor, line, args)
  let file = a:line
  let buf_number = bufadd(file)
  let line_num = 0
  return [buf_number, line_num, ""]
endfunction

function! Everything#Highlight(args)
  highlight ES_Pattern guifg=Black guibg=lightgreen ctermfg=16 ctermbg=120

  " suppose that pattern is not a regex
  if has_key(a:args, "-w")
    let pattern = '\<' . get(a:args, "pattern", [""])[0] . '\>'
  else
    let pattern = get(a:args, "pattern", [""])[0]
  endif

  if has_key(a:args, "--ignore-case")
    let pattern = '\c' . pattern
  endif

  let ids = []
  call add(ids, matchadd("ES_Pattern", pattern, 20))
  return ids
endfunction

function! Everything#Get_digest(line, mode)
  " full path, i.e, the whole line
  if a:mode == 0
    return [a:line, 0]
    " name only, i.e, the part of file name
  elseif a:mode == 1
    return [split(a:line)[0], 0]
    " directory, i.e, the part of greped line
  else
    let items = split(a:line, '\t')
    return [items[2], len(a:line) - len(items[2])]
  endif
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
  let l:filter = g:Lf_EverythingOpenfileFilter
  let current_ext = fnamemodify(a:fname, ":e")
  for ext in l:filter
    if ext == current_ext
      call s:Open_Internal(a:fname)
      return
    endif
  endfor
  call s:Open_External(a:fname)
endfunction
