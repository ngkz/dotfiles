vim.keymap.set('v', 'v', '<Plug>(expand_region_expand)')
vim.keymap.set('v', '<C-v>', '<Plug>(expand_region_shrink)')

vim.g.expand_region_text_objects = {
    iw     = 0,
    iW     = 0,
    ['i"'] = 1,
    ["i'"] = 1,
    ['i]'] = 1,
    ib     = 1,
    iB     = 1,
    il     = 0,
    ip     = 1,
    ie     = 0
}
