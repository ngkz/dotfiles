local group = vim.api.nvim_create_augroup("undo", {})
vim.api.nvim_create_autocmd("BufWritePre", {
    group = group,
    pattern = {
        "/tmp/*",
        "/var/tmp/*",
        vim.fn.resolve("/var/tmp") .. "/*", -- tmpfs-as-root
        "*/COMMIT_EDITMSG"
    },
    command = "setlocal noundofile"
})
