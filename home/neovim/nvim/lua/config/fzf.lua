-- Enable per-command history.
-- CTRL-N and CTRL-P will be automatically bound to next-history and
-- previous-history instead of down and up. If you don't like the change,
-- explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
vim.g.fzf_history_dir = vim.fn.stdpath("state") .. '/fzf'

-- respect .gitignore
vim.env.FZF_DEFAULT_COMMAND = 'fd --type f'

-- Mapping selecting mappings
vim.keymap.set("n", "<leader><tab>", "<Plug>(fzf-map-n)")
vim.keymap.set("x", "<leader><tab>", "<Plug>(fzf-map-x)")
vim.keymap.set("o", "<leader><tab>", "<Plug>(fzf-map-o)")

-- Insert mode completion
vim.keymap.set("i", "<c-x><c-k>", "<Plug>(fzf-complete-word)")
vim.keymap.set("i", "<c-x><c-f>", "<Plug>(fzf-complete-path)")
vim.keymap.set("i", "<c-x><c-l>", "<Plug>(fzf-complete-line)")

vim.keymap.set("n", "<leader>;", "<cmd>Buffers<CR>")
vim.keymap.set("n", "<leader><leader>", "<cmd>Files<CR>")
vim.keymap.set("n", "<leader>fp" ,"<cmd>call fzf#vim#files(expand('%:p:h'))<CR>")
vim.keymap.set("n", "<leader>fo", "<cmd>History<CR>")
vim.keymap.set("n", "<leader>f:", "<cmd>History:<CR>")
vim.keymap.set("n", "<leader>ft", "<cmd>Filetypes<CR>")
vim.keymap.set("n", "<leader>fl", "<cmd>Lines<CR>")
vim.keymap.set("n", "<leader>fL", "<cmd>BLines<CR>")
vim.keymap.set("n", "<leader>fh", "<cmd>Helptags<CR>")
