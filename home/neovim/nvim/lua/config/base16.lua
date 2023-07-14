vim.g.base16colorspace = 256

local group = vim.api.nvim_create_augroup("on_change_colorscheme", {})
vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function(ev)
        -- colorscheme customization
        -- improve readability
        vim.fn.Base16hi("Comment", vim.g.base16_gui04, "", vim.g.base16_cterm04, "", "", "")
        vim.fn.Base16hi("Folded",  vim.g.base16_gui04, vim.g.base16_gui01, vim.g.base16_cterm04, vim.g.base16_cterm01, "", "")

        -- transparent background
        vim.cmd.highlight("Normal", "guibg=NONE", "ctermbg=NONE")

        -- highlight trailing spaces
        vim.fn.Base16hi('ExtraWhitespace', '', vim.g.base16_gui08, '', vim.g.base16_cterm08)
        vim.cmd.match("ExtraWhitespace", '"\\s\\+$"')
    end
})

vim.cmd.colorscheme("base16-monokai")
