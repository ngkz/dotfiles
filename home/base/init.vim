" options {{{
" turn off vi compatible mode (vim default: on when a vimrc or gvimrc file
" found, neovim: always on)
set nocompatible

" enable filetype detection, and enable loading the plugin files and loadi
" ng the indent file, for specific file types. (vim default: off, neovim
" default: on)
filetype plugin indent on

" enable syntax highlighting (vim default: off, neovim default: on)
syntax enable

" automatic indentation (vim default: off, neovim default: on)
set autoindent
" allow backspaceing over autoindent, eol, and start (vim default: empty,
" neovim default: "indent,eol,start")
set backspace=indent,eol,start
" don't scan included files when keyword completion (vim default: ".,w,b,u,t,i",
" neovim default: ".,w,b,u,t")
set complete-=i
" a <Tab> in front of a line inserts blanks according to 'shiftwidth'.
" 'tabstop' or 'softtabstop' is used in other places. A <BS> will delete
" a 'shiftwidth' worth of space at the start of the line.
set smarttab
" don't consider numbers that start with zero to be octal. (vim default:
" "bin,octal,hex", neovim default: "bin,hex")
set nrformats-=octal
" wait 'ttimeoutlen' milliseconds for the terminal to complete a key byte
" sequence. (vim default: off, neovim default: on)
set ttimeout
" The time in milliseconds that is waited for a key code sequence to
" complete. (vim default: 100, neovim default: 50)
set ttimeoutlen=100
" Maximum column in which to search for syntax items.
" set to sane value to avoid slowdown
set synmaxcol=300

" incremental search (vim default: off, neovim default: on)
set incsearch
" highlight all maches of a previous search pattern. (vim default: off, neovim
" default: on)
set hlsearch
" don't show a status line (vim default: 1, neovim default: 2)
set laststatus=0
" the content of the status line
set statusline=%{pathshorten(bufname('%'))}\ %h%m%r%=\ %3c,\ %3l/%3L
" show the line and column number of the cursor position (vim default:
" off, neovim default: on)
set ruler
" the content of the ruler
let &rulerformat = '%50(%=' . substitute(&statusline, "%=\ ", " ", "") . '%)'
" enhanced mode command-line completion (vim default: off, neovim default: on)
set wildmenu
" "full"         Complete the next full match.  After the last match,
"                the original string is used and then the first match
"                again.
set wildmode=list:longest,full
" minimal number of screen lines to keep above and below the cursor
" (default: 0)
set scrolloff=1
" the minimal number of screen columns to keep to the left and to the
" right of the cursor if 'nowrap' is set. (default: 0)
set sidescrolloff=5
" change the way text is displayed. (vim default: "", neovim default:
" "statusline")
" display as much as possible of the last line in a window (vim default: off,
" neovim default: on)
set display+=lastline
" make invisible characters visible
" vim default: list=off listchars="eol:$"
" neovim default: list=off listchars="tab:> ,trail:-,nbsp:+"
set list
"set listchars=tab:→\ ,eol:↲,nbsp:␣,extends:⟩,precedes:⟨
set listchars=tab:»-,eol:↲,nbsp:␣,extends:⟩,precedes:⟨
" string to put at the start of lines that have been wrapped. (default: "")
set showbreak=↪\ 
" delete comment character when joining commented lines (vim default: off,
" neovim default: on)
set formatoptions+=j
" use a tag file in parent directories (vim default: "./tags,./TAGS,tags,TAGS",
" neovim default: "./tags;,tags")
if has('path_extra')
    setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif
" when a file has been detected to have been changed outside of Vim and
" it has not been changed inside of Vim, automatically read it again.
" (vim default: off, neovim default: on)
set autoread
" a history of ":" commands, and a history of previous search patterns
" are remembered.  This option decides how many entries may be stored in
" each of these histories.
" (vim default: 20, neovim default: 10000 (maximum))
set history=10000
" maximum number of tab pages to be opened by the |-p| command line
" argument or the ":tab all" command. |tabpage|
" (vim default: 20, neovim default: 50)
set tabpagemax=50
" save and restore global variables that start with an uppercase letter,
" and don't contain a lowercase letter.
" (vim default: off, neovim default: on)
set viminfo^=!
" don't save options when :mksession.
" (vim default: save, neovim default: don't save)
set sessionoptions-=options
" save local options and local keymaps when :mksession.
" (vim default: don't save, neovim default: don't save)
set sessionoptions+=localoptions
" allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
    set t_Co=16
endif
"
if !has('nvim')
    " store swap files in ~/.vim/swapfiles
    let s:swapdir = expand("~/.vim/swapfiles")
    if !isdirectory(s:swapdir)
        mkdir(s:swapdir, "p")
    endif
    let &directory=s:swapdir
endif

" persistent undo
set undofile

if !has('nvim')
    " store undo files in ~/.vim/undofiles
    let s:undodir = expand("~/.vim/undofiles")
    if !isdirectory(s:undodir)
        mkdir(s:undodir, "p")
    endif
    let &undodir=s:undodir
endif

" don't show line number
" set number
" ignore case in search patterns
set ignorecase
" override the ignorecase option if the search pattern contains upper case characters.
set smartcase
" number of spaces to use for each step of (auto)indent.
set shiftwidth=4
" number of spaces that a <Tab> in the file counts for.
set tabstop=4
" number of spaces that a <Tab> counts for while performing editing operations,
set softtabstop=4
" use spaces instead of tab as indent
set expandtab
" when a bracket is inserted, briefly jump to the matching one
set showmatch
set matchtime=1
" smart auto indent
set smartindent
" maximum height of completion menu
set pumheight=10
" cursor wrap conditions
set whichwrap=b,s,h,l,<,>,[,],~
" allow switching buffers when the current buffer isn't saved.
set hidden
" default character encoding
set encoding=utf-8
" file encoding detection order
set fileencodings=ucs-bom,utf-8,iso-2022-jp-3,euc-jp,cp932
" default EOL format.
set fileformat=unix
" automatic recognition of EOL format
set fileformats=unix,dos,mac
" chdir to the directory containing the file which was opened or selected.
"set autochdir
" highlight the line of the cursor
set cursorline
" highlight the column of the cursor
set cursorcolumn
" allow the cursor to move just past the end of the line
"set virtualedit=onemore
" use visual bell instead of beeping
set visualbell
" show (partial) command in status line.
set showcmd
" use backslash as a path separator
if exists('+shellslash')
    set shellslash
endif
" enable the use of the mouse
set mouse=a
" don't save options and local current directory when saving view state.
set viewoptions=folds,cursor,slash,unix
" change leader key
let mapleader = " "
let maplocalleader = " "
" highlight column 81 and 101
set colorcolumn=81,101
" certain operations that would normally fail because of unsaved changes to a buffer, instead raise a dialog asking if you wish to save the current file(s).
set confirm
" avoid intro message
set shortmess+=I
" the screen will not be redrawn while executing macros, registers and other commands that have not been typed.
set lazyredraw
" start diff mode with vetical splits
set diffopt+=vertical
" put a new window  right of the current one.
set splitright
" use SGR-style mouse tracking
if !has('nvim')
    set ttymouse=sgr
endif
" show extra information about the currently selected completion
set completeopt+=preview
" this feature doesn't play well with sphinx-autobuild
set nowritebackup
" set terminal title
set title
" }}}
"
" Load matchit.vim, but only if the user hasn't installed a newer version. {{{
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
    runtime! macros/matchit.vim
endif
" }}}

" set s:data_dir and s:config_dir {{{
" let s:data_dir = (path to data directory)
if has('nvim')
    if has('*stdpath')
        let s:data_dir = stdpath('data')
    else
        if $XDG_DATA_HOME == ''
            let s:data_dir = $HOME . '/.local/share/nvim'
        else
            let s:data_dir = $XDG_DATA_HOME . '/nvim'
        endif
    endif
else
    let s:data_dir = $HOME . '/.vim'
endif

" let s:config_dir = (path to config directory)
if has('nvim')
    if has('*stdpath')
        let s:config_dir = stdpath('config')
    else
        if $XDG_CONFIG_HOME == ''
            let s:config_dir = $HOME . '/.config/nvim'
        else
            let s:config_dir = $XDG_CONFIG_HOME . '/nvim'
        endif
    endif
else
    let s:config_dir = $HOME . '/.vim'
endif
" }}}

function! s:check_exec(exec) "{{{
    if type(a:exec) == type([])
        for item in a:exec
            if executable(item)
                return
            endif
        endfor
        echo "neither" . join(a:exec, " nor ") . ' available'
    elseif !executable(a:exec)
        echo a:exec . ' unavailable'
    endif
endfunction "}}}

" highlight trailing spaces {{{
match ErrorMsg '\s\+$'
" }}}

" colorscheme {{{
set termguicolors
colorscheme base16-monokai
" }}}
"
" sh.vim config {{{
" better shellscript highlighting
let g:is_posix = 1
" }}}

" Nerd Tree config {{{
nnoremap <silent><leader>n :NERDTreeToggle<CR>
" }}}

" fzf.vim config {{{
call s:check_exec('fzf')
call s:check_exec(['fdfind', 'fd'])

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = s:data_dir . '/fzf'

" respect .gitignore
if executable("fdfind")
    let $FZF_DEFAULT_COMMAND='fdfind --type f'
else
    let $FZF_DEFAULT_COMMAND='fd --type f'
endif

" Mapping selecting mappings
nmap <leader><tab> <plug>(fzf-maps-n)
xmap <leader><tab> <plug>(fzf-maps-x)
omap <leader><tab> <plug>(fzf-maps-o)

" Insert mode completion
imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

nnoremap ; :Buffers<CR>
nnoremap <leader><leader> :Files<CR>
nnoremap <leader>fp :call fzf#vim#files(expand('%:p:h'))<cr>
nnoremap <leader>fo :History<CR>
nnoremap <leader>f: :History:<CR>
nnoremap <leader>ft :Filetypes<CR>
nnoremap <leader>fl :Lines<CR>
nnoremap <leader>fL :BLines<CR>
nnoremap <leader>fh :Helptags<CR>
" }}}

" smart split help {{{
augroup HelpSmartSplit
    autocmd!
    autocmd FileType help if winwidth(0) >= 80 * 2 | wincmd L | endif
augroup END
" }}}

" smart split terminal {{{
function! s:smart_split_term(cmd)
    if winwidth(0) >= 80 * 2
        vsplit
    else
        split
    endif
    execute 'terminal ' . a:cmd
    normal i
endfunction

function! s:quickrun(runner)
    let tmpfile = tempname()
    call writefile(getline(1, '$'), tmpfile)
    echom tmpfile
    call s:smart_split_term(a:runner . ' ' . shellescape(tmpfile) . '; rm -f ' . shellescape(tmpfile))
endfunction
" }}}

" rust.vim config {{{
let g:rust_fold = 1 "Braced blocks are folded. All folds are open by default.
let g:rustfmt_autosave = 1
let g:rustfmt_fail_silently = 1
" }}}

" auto-pairs config {{{
let g:AutoPairsFlyMode = 0
let g:AutoPairsMapSpace = 0
let g:AutoPairsShortcutBackInsert = ''
" }}}

" FlyGrep.vim config {{{
call s:check_exec('rg')

nnoremap <leader>gg :FlyGrep<cr>
nnoremap <leader>gp :call FlyGrep#open({'dir': expand('%:p:h')})<cr>
xnoremap <leader>g "zy:call FlyGrep#open({'input': @z})<cr><c-e>
nnoremap <leader>gw "zyiw:call FlyGrep#open({'input': @z})<cr><c-e>
nnoremap <leader>gW "zyiW:call FlyGrep#open({'input': @z})<cr><c-e>

" }}}

" folding {{{
" don't close any folds by default
set foldlevel=99
" default foldcolumn
set foldcolumn=1

" custom foldtext
function! s:net_winwidth() "{{{
    redir =>signlist_str
    execute 'silent sign place buffer=' . bufnr('') 
    redir end
    let signlist = split(signlist_str, '\n')
    return winwidth(0) - ((&number || &relativenumber) ? &numberwidth : 0)
                \ - &foldcolumn - (len(signlist) > 2 ? 2: 0)
endfunction "}}}

function! MyFoldText() " {{{
    let line = ''

    " find first non-empty line in the fold.
    let nblnum = nextnonblank(v:foldstart)
    if nblnum != 0 && nblnum <= v:foldend
        let line = getline(nblnum)
    endif

    " remove marker
    let start_marker = split(&foldmarker, ',')[0]
    let commentstring_start = substitute(split(&commentstring, "%s")[0],
                \ '^\s*\(.*\)\s*$', '\1', '')
    let line = substitute(line, '\V\s\*' . escape(commentstring_start, '.\') .
                \ '\s\*' . escape(start_marker, '/\') . '\d\*', '', 'g')
    let line = substitute(line, '\V\s\*' . escape(start_marker, '/\') . '\d\*',
                \ '', 'g')

    " line count
    let linecountstr = printf("%d lines", v:foldend - v:foldstart + 1)
    let foldlevelstr = repeat(" +", v:foldlevel)
    let net_winwidth = s:net_winwidth()
    let line .= ' '
    let line .= repeat(' ', net_winwidth - strdisplaywidth(line)
                \ - strdisplaywidth(linecountstr) - strdisplaywidth(foldlevelstr)
                \ - 1)
    let line .= linecountstr
    let line .= foldlevelstr
    let line .= ' '

    " automatic foldcolumn adjusting
    if v:foldlevel > &l:foldcolumn - 1
        let &l:foldcolumn = v:foldlevel + 1
    endif

    return line
endfunction " }}}

set foldtext=MyFoldText()

augroup Folding
    autocmd!
    autocmd FileType c,cpp,objc,objcpp setlocal foldmethod=syntax
augroup END
" }}}

" braceless.vim config {{{
autocmd FileType python BracelessEnable +indent +fold
" }}}

" indentLine config {{{
let g:indentLine_concealcursor = ''
" }}}

" vim-rooter config {{{
let g:rooter_change_directory_for_non_project_files = 'current'
let g:rooter_cd_cmd = 'lcd'
let g:rooter_patterns = ['.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/', 'Cargo.toml', 'setup.py', 'env/', 'Gemfile']
" }}}

" keymap {{{

" make CTRL-U and CTRL-W undoable
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

" make Shift-Y behave like Shift-D
nnoremap Y y$

" move cursor by display lines by default
onoremap j gj
onoremap k gk
"onoremap 0 g0
"onoremap ^ g^
"onoremap $ g$
nnoremap j gj
nnoremap k gk
"nnoremap 0 g0
"nnoremap ^ g^
"nnoremap $ g$
vnoremap j gj
vnoremap k gk
"vnoremap 0 g0
"vnoremap ^ g^
"vnoremap $ g$
vnoremap j gj

onoremap gj j
onoremap gk k
"onoremap g0 0
"onoremap g^ ^
"onoremap g$ $
nnoremap gj j
nnoremap gk k
"nnoremap g0 0
"nnoremap g^ ^
"nnoremap g$ $
vnoremap gj j
vnoremap gk k
"vnoremap g0 0
"vnoremap g^ ^
"vnoremap g$ $
vnoremap gj j

" stop highlighting matches when pressing esc twice.
nnoremap <silent> <Esc><Esc> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" useful shortcuts
nnoremap <leader>w :<c-u>update<cr>

" quick clipboard copy and paste
nmap <Leader>y "+y
nmap <Leader>d "+d
vmap <Leader>y "+y
vmap <Leader>d "+d

nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

nmap <Leader>D "+D
nmap <Leader>Y "+Y

"automatically jump to end of text you pasted
"vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

"delete character without yanking
nnoremap x "_x
nnoremap s "_s

" quickly select text you just pasted
noremap gV `[v`]

" tab control keybind
nnoremap <silent> [t :<c-u>tabprevious<cr>
nnoremap <silent> ]t :<c-u>tabnext<cr>
nnoremap <silent> <leader>te :<c-u>tabedit<cr>:e<space>
nnoremap <silent> <leader>tE :<c-u>tabedit<cr>
nnoremap <silent> <leader>tc :<c-u>tabclose<cr>

" buffer control
nnoremap <silent> [b :<c-u>bprevious<cr>
nnoremap <silent> ]b :<c-u>bnext<cr>
nnoremap <silent> <leader>bd :<c-u>bdelete<cr>
nnoremap <silent> <leader>bc :<c-u>Bclose<cr>
nnoremap <silent> <leader>bk :<c-u>bdelete!<cr>

" exiting
nnoremap <leader>qq :q<CR>
nnoremap <leader>qw :wq<CR>

" vp doesn't replace paste buffer
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:replace_paste()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>replace_paste()

" replace selected text
xnoremap <leader>r "zy:let @z = escape(@z, '/\')<cr>:s/\V<c-r>z//gc<left><left><left>
nnoremap <leader>r "zyiw:let @z = escape(@z, '/\')<cr>:%s/\V<c-r>z//gc<left><left><left>
nnoremap <leader>R "zyiW:let @z = escape(@z, '/\')<cr>:%s/\V<c-r>z//gc<left><left><left>
" search for selected text
xnoremap <leader>/ "zy:execute '/\V' . escape(@z, '/\')<cr>
xnoremap <leader>? "zy:execute '?\V' . escape(@z, '/\')<cr>
" search for the word under the cursor
nnoremap <leader>/ g*
nnoremap <leader>? g#

nnoremap <Leader>cd :lcd %:p:h<CR>:pwd<CR>

" move window
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" tab complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" underline current line
nnoremap <leader>u- "zyy"zp<c-v>$r-
nnoremap <leader>u= "zyy"zp<c-v>$r=
nnoremap <leader>U- o<home><ESC>80i-<ESC>
nnoremap <leader>U= o<home><ESC>80i=<ESC>

" close all folds except one which the cursor is located.
nnoremap z_ zMzv
" insert fold marker
nnoremap  z[     :<C-u>call <SID>put_foldmarker(0)<CR>
nnoremap  z]     :<C-u>call <SID>put_foldmarker(1)<CR>
function! s:put_foldmarker(foldclose_p) "{{{
    let crrstr = getline('.')
    let padding = crrstr=='' ? '' : crrstr=~'\s$' ? '' : ' '
    let [cms_start, cms_end] = ['', '']
    let outside_a_comment_p = synIDattr(synID(line('.'), col('$')-1, 1), 'name') !~? 'comment'
    if outside_a_comment_p
        let cms_start = matchstr(&cms,'\V\s\*\zs\.\+\ze%s')
        let cms_end = matchstr(&cms,'\V%s\zs\.\+')
    endif
    let fmr = split(&fmr, ',')[a:foldclose_p]. (v:count ? v:count : '')
    exe 'norm! A'. padding. cms_start. fmr. cms_end
endfunction
"}}}

" easy edit of files in the same directory
cabbr <expr> %% expand('%:p:h')
nnoremap <Leader>e :e <C-R>=expand('%:p:h') . '/'<CR>
" }}}

" vim: fdm=marker
