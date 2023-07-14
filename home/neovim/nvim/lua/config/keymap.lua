-- make CTRL-U and CTRL-W undoable
vim.keymap.set('i', '<C-U>', '<C-G>u<C-U>')
vim.keymap.set('i', '<C-W>', '<C-G>u<C-W>')

-- make Shift-Y behave like Shift-D
vim.keymap.set('n', 'Y', 'y$')

-- move cursor by display lines by default
vim.keymap.set({'o', 'n', 'v'}, 'j', 'gj')
vim.keymap.set({'o', 'n', 'v'}, 'k', 'gk')
--vim.keymap.set({'o', 'n', 'v'}, '0', 'g0')
--vim.keymap.set({'o', 'n', 'v'}, '^', 'g^')
--vim.keymap.set({'o', 'n', 'v'}, '$', 'g$')

vim.keymap.set({'o', 'n', 'v'}, 'gj', 'j')
vim.keymap.set({'o', 'n', 'v'}, 'gk', 'k')
--vim.keymap.set({'o', 'n', 'v'}, 'g0', '0')
--vim.keymap.set({'o', 'n', 'v'}, 'g^', '^')
--vim.keymap.set({'o', 'n', 'v'}, 'g$', '$')

-- stop highlighting matches when pressing esc twice.
vim.keymap.set('n', '<Esc><Esc>', '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal!<C-L><CR>', { silent = true })

-- useful shortcuts
vim.keymap.set('n', '<leader>w', ':<c-u>update<cr>')

-- quick clipboard copy and paste
vim.keymap.set({'n', 'v'}, '<Leader>y', '"+y')
vim.keymap.set({'n', 'v'}, '<Leader>d', '"+d')

vim.keymap.set({'n', 'v'}, '<Leader>p', '"+p')
vim.keymap.set({'n', 'v'}, '<Leader>P', '"+P')

vim.keymap.set('n', '<Leader>D', '"+D')
vim.keymap.set('n', '<Leader>Y', '"+y$')

--automatically jump to end of text you pasted
--vim.keymap.set('v', 'y', 'y`]', { silent = true })
vim.keymap.set('v', 'p', 'p`]', { silent = true })
vim.keymap.set('n', 'p', 'p`]', { silent = true })

--delete character without yanking
vim.keymap.set('n', 'x', '"_x')
vim.keymap.set('n', 's', '"_s')

-- quickly select text you just pasted
vim.keymap.set('n', 'gV', '`[v`]')

-- tab control keybind
vim.keymap.set('n', '[t', ':<c-u>tabprevious<cr>', { silent = true })
vim.keymap.set('n', ']t', ':<c-u>tabnext<cr>', { silent = true })
vim.keymap.set('n', '<leader>te', ':<c-u>tabedit<cr>:e<space>', { silent = true })
vim.keymap.set('n', '<leader>tE', ':<c-u>tabedit<cr>', { silent = true })
vim.keymap.set('n', '<leader>tc', ':<c-u>tabclose<cr>', { silent = true })

-- buffer control
vim.keymap.set('n', '[b', ':<c-u>bprevious<cr>', { silent = true })
vim.keymap.set('n', ']b', ':<c-u>bnext<cr>', { silent = true })
vim.keymap.set('n', '<leader>bd', ':<c-u>bdelete<cr>', { silent = true })
vim.keymap.set('n', '<leader>bc', ':<c-u>Bclose<cr>', { silent = true })
vim.keymap.set('n', '<leader>bk', ':<c-u>bdelete!<cr>', { silent = true })

-- replace selected text/word
-- TODO
-- local function text_between_marks(mark_a, mark_b)
--   local pos_a = vim.fn.getpos(mark_a)
--   local pos_b = vim.fn.getpos(mark_b)

--   local start_line = pos_a[2]
--   local end_line = pos_b[2]
--   local start_col = pos_a[3]
--   local end_col = pos_b[3]

--   local lines = vim.fn.getline(start_line, end_line)
--   lines[#lines] = lines[#lines]:sub(1, end_col)
--   lines[1] = lines[1]:sub(start_col)
--   local extracted = table.concat(lines, "\n")

--   return extracted
-- end

-- local function escape_vim_regex(text)
--   return vim.fn.escape(text, '^$.*?/\\[]~')
-- end

-- function ReplaceOperator(type)
--   if type == nil then
--       vim.opt.operatorfunc = "v:lua.ReplaceOperator"
--       return 'g@'
--   end

--   local cr = vim.api.nvim_replace_termcodes('<C-V><C-M>', true, false, true)
--   local left = vim.api.nvim_replace_termcodes('<Left>', true, false, true)
--   vim.api.nvim_feedkeys(':%s/' .. escape_vim_regex(text_between_marks("'[", "']")):gsub('\n', cr) .. '//gc' .. left .. left .. left, 'n', true)
-- end
-- vim.keymap.set({'n', 'x'}, '<leader>r', ReplaceOperator, { expr = true })

vim.keymap.set('x', '<leader>r', '"zy:let @z = escape(@z, \'/\\\')<cr>:s/\\V<c-r>z//gc<left><left><left>')
vim.keymap.set('n', '<leader>r', '"zyiw:let @z = escape(@z, \'/\\\')<cr>:%s/\\V<c-r>z//gc<left><left><left>')
vim.keymap.set('n', '<leader>R', '"zyiW:let @z = escape(@z, \'/\\\')<cr>:%s/\\V<c-r>z//gc<left><left><left>')
--
-- search for selected text
vim.keymap.set('x', '<leader>/', '"zy:execute \'/\\V\' . escape(@z, \'/\\\')<cr>')
vim.keymap.set('x', '<leader>?', '"zy:execute \'?\\V\' . escape(@z, \'/\\\')<cr>')
-- search for the word under the cursor
vim.keymap.set('n', '<leader>/', 'g*')
vim.keymap.set('n', '<leader>?', 'g#')

vim.keymap.set('n', '<Leader>cd', ':lcd %:p:h<CR>:pwd<CR>')

-- move window
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- tab complete
vim.keymap.set('i', '<tab>', 'pumvisible() ? "\\<c-n>" : "\\<tab>"', { expr = true })

-- underline current line
vim.keymap.set('n', '<leader>u=', '"zyy"zp<c-v>$r=')
vim.keymap.set('n', '<leader>u-', '"zyy"zp<c-v>$r-')
vim.keymap.set('n', '<leader>u^', '"zyy"zp<c-v>$r^')

-- close all folds except one which the cursor is located.
vim.keymap.set('n', 'z_', 'zMzv')

-- easy edit of files in the same directory
vim.cmd.cabbrev('<expr>', '%%', 'expand("%:p:h")')
vim.keymap.set('n', '<Leader>e', ':e <C-R>=expand("%:p:h") . "/"<CR>')
