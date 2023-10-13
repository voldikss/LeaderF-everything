" ============================================================================
" FileName: Everything.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

if exists('g:lf_everything_loaded')
  finish
endif
let g:lf_everything_loaded = 1

if !has("win32") && !has("win64")
  finish
endif

" Define es.exe executable path
let g:Lf_EverythingEsPath = get(g:, 'Lf_EverythingEsPath', 'es.exe')

" Define which file type should be opened with vim when press enter.
let g:Lf_EverythingOpenfileFilter = get(g:, 'Lf_EverythingOpenfileFilter', ['txt', 'vim'])

" Define es.exe option.
let g:Lf_EverythingEsOptions = get(g:, 'Lf_EverythingEsOptions', '')

" Define default search location, e.g., `D:\`
let g:Lf_EverythingDefaultDir = get(g:, 'Lf_EverythingDefaultDir', '')

if !exists('g:Lf_Extensions')
    let g:Lf_Extensions = {}
endif

let g:Lf_Extensions.everything = {
  \   "source": 'Everything#StartSearch',
  \   "arguments": [
  \       { "name": ["pattern"], "nargs": '*' },
  \   ],
  \   "accept": "Everything#Accept",
  \   "preview": "Everything#Preview",
  \   "supports_name_only": 1,
  \   "get_digest": "Everything#Get_digest",
  \   "highlights_def": {
  \       "Lf_hl_grep_file": '^.\{-}\ze\t',
  \       "Lf_hl_grep_line": '\t|\zs\d\+\ze|\t',
  \   },
  \   "highlights_cmd": [
  \       "hi Lf_hl_grep_file guifg=red ctermfg=196",
  \       "hi Lf_hl_grep_line guifg=green ctermfg=120",
  \   ],
  \   "highlight": "Everything#Highlight",
  \   "after_enter": "",
  \   "before_exit": "",
  \   "supports_multi": 0,
  \ }

let g:Lf_SelfContent = get(g:,'Lf_SelfContent', {})
command! -bar -nargs=0 LeaderfEverything Leaderf everything 
let g:Lf_SelfContent.LeaderfEverything = "Everything"
