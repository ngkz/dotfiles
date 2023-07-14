-- don't close any folds by default
vim.opt.foldlevel = 99
-- default foldcolumn
vim.opt.foldcolumn = "auto:9"
-- custom foldtext
local function net_winwidth()
    -- vim.cmd.redir('=>signlist_str')
    -- vim.cmd('silent sign place buffer=' .. vim.fn.bufnr(''))
    -- vim.cmd.redir('END')
    -- local signlist = vim.split(vim.g.signlist_str, '\n')
    -- return vim.api.nvim_win_get_width(0) - ((vim.o.number or vim.o.relativenumber) and vim.o.numberwidth or 0)
    --     - vim.o.foldcolumn - (#signlist > 2 and 2 or 0)
    local info = vim.fn.getwininfo(vim.fn.win_getid())[1]
    return info.width - info.textoff
end

local function escape(str)
    return str:gsub('[%(%)%.%%%+%-%*%?%[%^%$%]]', '%%%1')
end

function custom_fold_text()
    local left = ''

    -- find first non-empty line in the fold.
    local nblnum = vim.fn.nextnonblank(vim.v.foldstart)
    if nblnum ~= 0 and nblnum <= vim.v.foldend then
        left = vim.fn.getline(nblnum)
    end

    -- remove marker
    local marker_start = vim.split(vim.o.foldmarker, ',')[1]
    local marker_start_pat = escape(marker_start) .. "%d*"
    local marker_start_comment_pat = escape(vim.o.commentstring):gsub('%s*' .. escape(escape('%s')) .. '%s*', escape('%s*' .. marker_start_pat .. '%s*'))

    left = left:gsub(marker_start_comment_pat, '')
    left = left:gsub(marker_start_pat, '')

    local linecountstr = string.format("%d lines", vim.v.foldend - vim.v.foldstart + 1)
    local foldlevelstr = string.rep("+", vim.v.foldlevel)
    local right = linecountstr .. ' ' .. foldlevelstr

    -- pad
    local pad = string.rep(' ', net_winwidth() - vim.fn.strdisplaywidth(left) - vim.fn.strdisplaywidth(right))
    local line = left .. pad .. right

    return line
end
vim.opt.foldtext = 'v:lua.custom_fold_text()'

local group = vim.api.nvim_create_augroup("folding", {})
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = {"c", "cpp", "objc", "objcpp"},
    command = "setlocal foldmethod=syntax"
})
