-- open help in a vertical split window if current window is wide enough

local group = vim.api.nvim_create_augroup("help_smart_split", {})
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(ev)
        if vim.bo.filetype ~= 'help' then
            return
        end
        if not vim.w.created and vim.fn.winwidth(0) >= 80 * 2 then
            vim.cmd.wincmd("L")
        end
        vim.w.created = 1
    end
})
