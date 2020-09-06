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

" Define which file type should be opened with vim when press enter.
let g:fe_openfile_filter = get(g:, 'fe_openfile_filter', ['txt', 'vim'])

" Define only show these file types when everything return results.
let g:fe_result_filter = get(g:, 'filter_result_ext', {'vim':1, 'txt':1, 'c':1, 'h':1, 'py':1})

" Define es.exe option.
let g:fe_es_options = get(g:, 'fe_es_option', '-s')

" Define result window height
let g:fe_window_height = get(g:, 'fe_winheight', 15)

" Define result window type, either 'split' or 'popup'
let g:fe_window_type = get(g:, 'fe_wintype', 'split')

command! -nargs=1 -bang FE call fe#StartSearch(<q-args>, <bang>0)
command! -nargs=* FET call fe#ToggleResultWindow()
