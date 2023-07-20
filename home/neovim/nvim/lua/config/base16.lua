vim.g.base16colorspace = 256

local function add_match()
    -- highlight trailing spaces
    vim.cmd.match("ExtraWhitespace", '"\\s\\+$"')
end

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
        add_match()
    end
})

vim.api.nvim_create_autocmd({"WinEnter", "SessionLoadPost"}, {
    group = group,
    callback = add_match
})

vim.cmd.colorscheme("base16-monokai")
