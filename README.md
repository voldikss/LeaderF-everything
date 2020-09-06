# vim-find-everything

Use [everything](https://www.voidtools.com/) in vim.

# Features

- Windows only(?)
- Asynchronous searching
- Vim8's popup support

# Options

```vim
" Define which file type should be opened with vim when press enter.
let g:fe_openfile_filter = get(g:, 'fe_openfile_filter', ['txt', 'vim'])

" Define only show these file types when everything return results.
let g:fe_result_filter = get(g:, 'fe_result_filter', {'vim':1, 'txt':1, 'c':1, 'h':1, 'py':1})

" Define es.exe option.
let g:fe_es_options = get(g:, 'fe_es_option', '-s')

" Define result window width
let g:fe_window_width = get(g:, 'fe_window_width', 85)

" Define result window height
let g:fe_window_height = get(g:, 'fe_window_height', 15)

" Define result window type, either 'split' or 'popup'
let g:fe_window_type = get(g:, 'fe_window_type', 'split')
```

# Commands

- `:FE [pattern]`

- `:FET`

# Demos



# Credits

- Thank chao wang for developing [FindEverything](https://www.vim.org/scripts/script.php?script_id=3499)
- Thank js79903 for sponsoring
