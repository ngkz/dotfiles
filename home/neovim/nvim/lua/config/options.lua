-- Maximum column in which to search for syntax items.
-- set to sane value to avoid slowdown
vim.opt.synmaxcol = 300
-- the content of the status line
vim.opt.statusline = "%{pathshorten(bufname('%'))} %h%m%r%= %3c, %3l/%3L"
-- hide the command-line to save vertical space
-- vim.opt.cmdheight = 0

-- "full"         Complete the next full match.  After the last match,
--                the original string is used and then the first match
--                again.
-- vim.opt.wildmode = "list:longest,full"

-- minimal number of screen lines to keep above and below the cursor
-- (default: 0)
vim.opt.scrolloff = 1
-- the minimal number of screen columns to keep to the left and t the
-- right of the cursor if 'nowrap' is set. (default: 0)
vim.opt.sidescrolloff = 5
-- show whitespaces
vim.opt.list = true
vim.opt.listchars = "tab:»-,eol:↲,nbsp:␣,extends:⟩,precedes:⟨,trail:-"
-- string to put at the start of lines that have been wrapped. (default: "")
vim.opt.showbreak = "↪ "
-- save local options (includes syntax) and local keymaps when :mksession.
vim.opt.sessionoptions:append("localoptions")
-- persistent undo
vim.opt.undofile = true
-- ignore case in search patterns
vim.opt.ignorecase = true
-- override the ignorecase option if the search pattern contains upper case characters.
vim.opt.smartcase = true
-- number of spaces to use for each step of (auto)indent.
vim.opt.shiftwidth = 4
-- number of spaces that a <Tab> in the file counts for.
vim.opt.tabstop = 4
-- number of spaces that a <Tab> counts for while performing editing operations,
vim.opt.softtabstop = 4
-- use spaces instead of tab as indent
vim.opt.expandtab = true
-- when a bracket is inserted, briefly jump to the matching one
vim.opt.showmatch = true
vim.opt.matchtime = 1
-- smart auto indent
vim.opt.smartindent = true
-- maximum height of completion menu
vim.opt.pumheight = 10
-- cursor wrap conditions
vim.opt.whichwrap = "b,s,h,l,<,>,[,],~"
-- file encoding detection order
vim.opt.fileencodings = "ucs-bom,utf-8,iso-2022-jp-3,euc-jp,cp932"
-- default EOL format.
vim.opt.fileformat = "unix"
-- automatic recognition of EOL format
vim.opt.fileformats = "unix,dos,mac"
-- highlight the column of the cursor
vim.opt.cursorcolumn = true
-- don't save options and local current directory when saving view state.
vim.opt.viewoptions = "folds,cursor,slash,unix"
-- change leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- highlight column 81 and 101
vim.opt.colorcolumn = "81,101"
-- certain operations that would normally fail because of unsaved changes to a buffer, instead raise a dialog asking if you wish to save the current file(s).
vim.opt.confirm = true
-- don't show intro message
vim.opt.shortmess:append("I")
-- the screen will not be redrawn while executing macros, registers and other commands that have not been typed.
vim.opt.lazyredraw = true
-- start diff mode with vetical splits
vim.opt.diffopt:append("vertical")
-- put a new window right of the current one.
vim.opt.splitright = true
-- this feature doesn't play well with sphinx-autobuild
vim.opt.writebackup = false
-- set terminal title
vim.opt.title = true
vim.opt.titlestring = "%t - NVIM"
-- enable 24bit colors in TUI
vim.opt.termguicolors = true
