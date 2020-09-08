# LeaderF-everything

Use [everything.exe](https://www.voidtools.com/) in (neo)vim.

![](https://user-images.githubusercontent.com/20282795/92454117-bfc59c80-f1f2-11ea-8878-66edfb1a6dcb.png)

# Features

- Windows only(???)
- FAST

# Install

```vim
Plug 'Yggdroot/LeaderF'
Plug 'voldikss/LeaderF-everything'
```

# Usage

### `:Leaderf everything [pattern]`

# Options

```vim
" Define es.exe executable path
let g:Lf_EverythingEsPath = get(g:, 'Lf_EverythingEsPath', 'es.exe')

" Define which file type should be opened with vim when press enter.
let g:Lf_EverythingOpenfileFilter = get(g:, 'Lf_EverythingOpenfileFilter', ['txt', 'vim'])

" Define es.exe option.
let g:Lf_EverythingEsOptions = get(g:, 'Lf_EverythingEsOptions', '')

" Define default search dir, e.g., `D:\`
let g:Lf_EverythingDefaultDir = get(g:, 'Lf_EverythingDefaultDir', '')
```

# To(do|gu)

- `Everything` on the fly, like `:Leaderf rg`

# Credits

- Thank chao wang for developing [FindEverything](https://www.vim.org/scripts/script.php?script_id=3499)
- Thank js79903 for sponsoring
