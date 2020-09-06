" ============================================================================
" FileName: display.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:popup(result) abort
  function! FE_Menu_Filter(id, key)
    return popup_filter_menu(a:id, a:key)
  endfunction

  function! FE_Menu_Handler(result, id, index) abort
    if a:index == -1
      return
    endif
    let fname = a:result[a:index-1]
    call s:Open_Filter(fname)
  endfunction

  let filelist = split(a:result, "\n")
  call popup_menu(filelist, #{
    \ filter: 'FE_Menu_Filter',
    \ callback: function('FE_Menu_Handler', [filelist]),
    \ maxheight: g:fe_window_height,
    \ maxwidth: g:fe_window_width,
    \ minheight: g:fe_window_height,
    \ minwidth: g:fe_window_width,
    \ title: 'Everything Search Result',
    \ drap: v:true,
    \ resize: v:true,
    \ scrollbar: 1,
    \ })
endfunction

"Show_Everything_Result
function! s:split(result)
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
  silent! 0put = a:result

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

function! fe#display#create(result) abort
  if g:fe_window_type == 'popup'
    call s:popup(a:result)
  else
    call s:split(a:result)
  endif
endfunction

function! fe#display#toggle(result) abort
  if g:fe_window_type == 'popup'
    call s:popup(a:result)
  else
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
  endif
endfunction
