" ============================================================================
" FileName: fe.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

if exists('g:everything_loaded')
  finish
endif
let g:everything_loaded = 1

if !has("win32") && !has("win64")
  finish
endif

" Define es.exe executable path
let g:fe_es_exe = get(g:, 'fe_es_exe', 'es.exe')

" Define which file type should be opened with vim when press enter.
let g:fe_openfile_filter = get(g:, 'fe_openfile_filter', ['txt', 'vim'])

" Define only show these file types when everything return results.
let g:fe_result_filter = get(g:, 'fe_result_filter', {'vim':1, 'txt':1, 'c':1, 'h':1, 'py':1})

" Define es.exe option.
let g:fe_es_options = get(g:, 'fe_es_options', '')

" Define result window width
let g:fe_window_width = get(g:, 'fe_window_width', 85)

" Define result window height
let g:fe_window_height = get(g:, 'fe_window_height', 15)

" Define result window type, either 'split' or 'popup'
let g:fe_window_type = get(g:, 'fe_window_type', 'split')

let g:fe_default_loc = get(g:, 'fe_default_loc', '')

command! -nargs=1 -bang FE  call fe#StartSearch(<q-args>, <bang>0)
command! -nargs=0       FET call fe#ToggleDisplay()
