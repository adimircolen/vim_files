"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

"runtime! autoload/pathogen.vim
filetype off
call pathogen#runtime_append_all_bundles()
call pathogen#helptags()

set nobackup                    "without backup of files
set noswapfile                  "without swap of files

set backspace=indent,eol,start  "allow backspacing over everything in insert mode
set history=1000                "store lots of :cmdline history
set undolevels=1000             "use many muchos levels of undo
set incsearch                   "find the next match as we type the search
set hlsearch                    "hilight searches by default
set nowrap                      "dont wrap lines
set linebreak                   "wrap lines at convenient points

"indent and tab settings
"http://version7x.wordpress.com/2010/03/07/was-that-a-tab-or-a-series-of-spaces/
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set smarttab

set list                  "display tabs and trailing spaces
"set listchars=tab:▷⋅,trail:⋅,nbsp:⋅
"set listchars=tab:\ \ ,extends:>,precedes:<
set listchars=tab:>-,trail:.
set number                "turn on line numberingr
"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

set showcmd               "show incomplete cmds down the bottom
set showmode              "show current mode down the bottom

filetype plugin indent on " Automatically detect file types.
syntax on                 "turn on syntax highlighting
set visualbell t_vb=      "disable sound bell
set hidden                "hidden a buffers, when open a others

let g:syntastic_enable_signs = 1
let g:syntastic_auto_loc_list = 1

"statusline setup
set statusline=%f "tail of the filename
"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*
"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*
"
set statusline+=%h "help file flag
set statusline+=%y "filetype
set statusline+=%r "read only flag
set statusline+=%m "modified flag
"
set statusline+=%{fugitive#statusline()}
"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*
"
set statusline+=%{StatuslineTrailingSpaceWarning()}
"
set statusline+=%{StatuslineLongLineWarning()}
"
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*
"
set statusline+=%= "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%c, "cursor column
set statusline+=%l/%L "cursor line/total lines
set statusline+=\ %P "percent through file
set laststatus=2

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction


"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction

if has("gui_running")
    "tell the term has 256 colors
    set t_Co=256
    if has("gui_gnome")
"        set term=gnome-256color
        colorscheme desert
    else
        "colorscheme vibrantink
        set guitablabel=%M%t
        set lines=40
        set columns=115
    endif
    if has("gui_mac") || has("gui_macvim")
        set guioptions-=T " remove the toolbar
        set transparency=5
        set guifont=Monaco:h12
        set cursorline
        "color vibrantink
    endif
    if has("gui_win32") || has("gui_win32s")
        set guifont=Consolas:h12
        set enc=utf-8
    endif
else
    "dont load csapprox if we no gui support - silences an annoying warning
    let g:CSApprox_loaded = 1
endif



let mapleader = ','   "The default leader is '\', but many people prefer ','
nnoremap ; :
nmap <silent> <Leader>p :NERDTreeToggle<CR>
nmap ,/ :nohlsearch<CR>
"CheckSyntax
noremap <Leader><F5> :CheckSyntax<cr>
"let g:checksyntax_auto = 1
" let g:tcommentMapLeaderOp2 "define modifier of TComand such as <Leader>

"mark syntax errors with :signs
"let g:syntastic_enable_signs=1
