-- FlyGrep.vim config
vim.keymap.set("n", "<leader>gg", "<cmd>FlyGrep<cr>")
vim.keymap.set("n", "<leader>gp", "<cmd>call flygrep#open({'dir': expand('%:p:h')})<cr>")
vim.keymap.set("x", "<leader>g", 'zy<cmd>call flygrep#open({\'input\': @z})<cr><c-e>')
vim.keymap.set("n", "<leader>gw", '"zyiw<cmd>call flygrep#open({\'input\': @z})<cr><c-e>')
vim.keymap.set("n", "<leader>gW", '"zyiW<cmd>call flygrep#open({\'input\': @z})<cr><c-e>')
