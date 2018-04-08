" Based on:
" https://raw.githubusercontent.com/tpope/vim-sensible/2d60332fa5b2b1ea346864245569df426052865a/plugin/sensible.vim
" http://itchyny.hatenablog.com/entry/2014/12/25/090000
" https://raw.githubusercontent.com/Shougo/shougo-s-github/b12435cdded41c7d77822b2a0a97beeab09b8d2c/vim/rc/init.rc.vim
" https://gist.github.com/anonymous/c966c0757f62b451bffa
" http://vim.wikia.com/wiki/Make_views_automatic
" http://vim.wikia.com/wiki/Automatic_session_restore_in_git_directories
" https://github.com/neovim/neovim/blob/ecf851bc60c0b4138e054426b4a062a59c343846/src/nvim/ex_docmd.c
" http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/

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
" don't scan included files when keyword completion (vim default: ".,w,b,u,t,i", neovim default: ".,w,b,u,t")
set complete-=i
" a <Tab> in front of a line inserts blanks according to 'shiftwidth'.
" 'tabstop' or 'softtabstop' is used in other places. A <BS> will delete
" a 'shiftwidth' worth of space at the start of the line.
set smarttab
" don't consider numbers that start with zero to be octal. (vim default:
" "octal,hex", neovim default: "bin,hex")
set nrformats-=octal
" wait 'ttimeoutlen' milliseconds for the terminal to complete a key byte
" sequence. (vim default: off, neovim default: on)
set ttimeout
" The time in milliseconds that is waited for a key code sequence to
" complete. (vim default: -1, neovim default: 50)
set ttimeoutlen=100
" Maximum column in which to search for syntax items.
" set to sane value to avoid slowdown
set synmaxcol=300

" incremental search (vim default: off, neovim default: on)
set incsearch
" highlight all maches of a previous search pattern. (vim default: off, neovim
" default: on)
set hlsearch
" stop highlighting matches when pressing esc twice.
nnoremap <silent> <Esc><Esc> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" a staus line is always shown (vim default: 1, neovim default: 2)
set laststatus=2
" show the line and column number of the cursor position (vim default:
" off, neovim default: on)
set ruler
" enhanced mode command-line completion (vim default: off, neovim default: on)
set wildmenu
" "list:longest" When more than one match, list all matches and
"                complete till longest common string.
" "full"         Complete the next full match.  After the last match,
"                the original string is used and then the first match
"                again.
set wildmode=list:longest,full
" minimal number of screen lines to keep above and below the cursor
" (default: 0)
set scrolloff=1
" hhe minimal number of screen columns to keep to the left and to the
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
set listchars=eol:~,tab:▸-,trail:-,nbsp:+,extends:>,precedes:<
" delete comment character when joining commented lines (vim default: off,
" neovim default: on)
set formatoptions+=j 
" use a tag file in parent directories (vim default: "./tags,./TAGS,tags,TAGS",
" neovim default: "./tags;,tags")
setglobal tags-=./tags tags-=./tags; tags^=./tags;
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

" show line number
set number
" ignore case in search patterns
set ignorecase
" override the ignorecase option if the search pattern contains upper case characters.
set smartcase
" tab width
set shiftwidth=4
set tabstop=4
set softtabstop=4
" use spaces instead of tab
set expandtab

" make CTRL-U and CTRL-W undoable
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>

" make Shift+Y behave like Shift+D
nnoremap Y y$

" when a bracket is inserted, briefly jump to the matching one
set showmatch
set matchtime=1
" smart auto indent
set smartindent
" maximum height of completion menu
set pumheight=10
" cursor wrap conditions
set whichwrap=b,s,h,l,<,>,[,],~
" use x11 clipboard
set clipboard^=unnamedplus
" allow switching buffers when the current buffer isn't saved.
set hidden
" default character encoding
set encoding=utf-8
" file encoding detection order
set fileencodings=ucs-bom,iso-2022-jp-3,utf-8,euc-jp,cp932
" default EOL format.
set fileformat=unix
" automatic recognition of EOL format
set fileformats=unix,dos,mac
" chdir to the directory containing the file which was opened or selected.
set autochdir
" change leader key
let mapleader = " "
let maplocalleader = " "
" highlight the line of the cursor
set cursorline
" highlight the column of the cursor
set cursorcolumn
" allow the cursor to move just past the end of the line
set virtualedit=onemore
" use visual bell instead of beeping
set visualbell
" move cursor by display lines when wrapping
nnoremap j gj
nnoremap k gk
" show (partial) command in status line.
set showcmd

" use backslash as a path separator
if exists('+shellslash')
    set shellslash
endif

" load / save session
let s:sessions_dir = $HOME . "/.local/share/nvim/sessions"

function! s:load_session(...)
    if a:0 > 0
        let l:id = a:1
    else
        let l:id = 0
    end
    exec ':source ' . s:sessions_dir . "/session" . l:id
    echom 'session ' . l:id . ' loaded.'
endfunction

function! s:save_session(...)
    if a:0 > 0
        let l:id = a:1
    else
        let l:id = 0
    end
    call mkdir(s:sessions_dir, "p")
    exec ':mksession!' . s:sessions_dir . "/session" . l:id
    echom 'session ' . l:id . ' saved.'
endfunction

command! -nargs=? LoadSession call s:load_session(<f-args>)
command! -nargs=? SaveSession call s:save_session(<f-args>)
nnoremap <leader>ls :LoadSession
nnoremap <leader>ss :SaveSession

" restore and save the session automatically if vim is started without args and cwd is in git
" repository.
let s:git_sessions_dir = $HOME . "/.local/share/nvim/gitsessions"

function! s:gen_git_session_path()
    let l:toplevel = substitute(system("git rev-parse --show-toplevel"), '\n$', "", "")
    if v:shell_error != 0
        return ""
    endif

    let l:filename = substitute(l:toplevel, "=", "==", "g")
    let l:filename = substitute(l:filename, has('unix') ? "/" : '\', "=+", "g")
    let l:filename = substitute(l:filename, ":", "=-", "g")

    return s:git_sessions_dir . "/" . l:filename
endfunction

function! s:load_git_session()
    if filereadable(s:git_session_path)
        execute 'source ' . s:git_session_path
        echom 'session loaded automatically:' . s:git_session_path
    else
        echom 'session autosaving enabled'
    end
endfunction

function! s:save_git_session()
    call mkdir(s:git_sessions_dir, "p")
    execute 'mksession! ' . s:git_session_path
    echom 'session saved automatically:' . s:git_session_path
endfunction

if argc() == 0
    let s:git_session_path = s:gen_git_session_path()

    if s:git_session_path != ""
        augroup gitsession
            autocmd VimEnter * call s:load_git_session()
            autocmd VimLeave * call s:save_git_session()
        augroup END
    endif
end

" save view state automatically.
augroup autoview
    autocmd BufWritePost *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      mkview
    \|  endif
    autocmd BufRead *
    \   if expand('%') != '' && &buftype !~ 'nofile'
    \|      silent! loadview
    \|  endif
augroup END

" don't save options.
set viewoptions-=options

" useful shortcuts
nnoremap <Leader>o :<CR> "TODO denite
nnoremap <Leader>w :w<CR>

vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

"automatically jump to end of text you pasted
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

" buffer moving keybind
nnoremap <silent> <leader><C-h> :<c-u>bp<cr>
nnoremap <silent> <leader><C-l> :<c-u>bn<cr>

" tab keybind
nnoremap <silent> <leader>tf :<c-u>tabfirst<cr>
nnoremap <silent> <leader>tl :<c-u>tablast<cr>
nnoremap <silent> <leader>tn :<c-u>tabnext<cr>
nnoremap <silent> <leader>tp :<c-u>tabprevious<cr>
nnoremap <silent> <leader>te :<c-u>tabedit<cr>
nnoremap <silent> <leader>tc :<c-u>tabclose<cr>
nnoremap <silent> <leader>to :<c-u>tabonly<cr>
nnoremap <silent> <leader>ts :<c-u>tabs<cr>
" tab jump
for n in range(1, 9)
  execute 'nnoremap <silent> <leader>t'.n  ':<C-u>tabnext'.n.'<CR>'
endfor

" split movement
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
