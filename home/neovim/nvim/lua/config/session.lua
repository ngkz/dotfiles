local sessions_dir = vim.fn.stdpath('state') .. '/sessions'

local function session_path(root)
  local filename = root:gsub('=', '=='):gsub('/', '=+'):gsub(':', '=-')
  return sessions_dir .. '/' .. filename
end

local function load_session(silent)
  if not vim.g.project_root then
    if not silent then
      print('Enable session management with :EnableSession')
    end
    return
  end

  local session = session_path(vim.g.project_root)

  if vim.fn.filereadable(session) == 1 then
    vim.cmd.source(session)
    print('Session loaded. project root: ' .. vim.g.project_root)
  elseif not silent then
    print('Session not found')
  end
end

local function save_session(silent)
  if not vim.g.project_root then
    if not silent then
      print('Enable session management with :EnableSession')
    end
    return
  end

  local session = session_path(vim.g.project_root)

  vim.fn.mkdir(sessions_dir, 'p')
  vim.cmd.mksession { session, bang = true }
  print('Session saved. project root: ' .. vim.g.project_root)
end

local function enable_session(silent)
  local project_root = vim.fn.FindRootDirectory()
  if project_root ~= '' then
    vim.g.project_root = project_root
    print('Session magagement enabled. project root: ' .. vim.g.project_root)
  elseif not silent then
    print('Could not find project root')
  end
end

local function disable_session(silent)
  vim.g.project_root = nil
  if not silent then
    print('Session closed')
  end
end

local function destroy_session()
  if not vim.g.project_root then
    print('Enable session management with :EnableSession')
    return
  end

  vim.fn.delete(session_path(vim.g.project_root))
  disable_session(true)
  vim.cmd('silent bufdo bd')
  print('Session closed and all buffers closed')
end

local group = vim.api.nvim_create_augroup('session', {})
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argc() == 0 then
      enable_session(true)
      load_session(true)
    end
  end
})
vim.api.nvim_create_autocmd('VimLeave', {
  callback = function()
    save_session(true)
  end
})

vim.api.nvim_create_user_command('EnableSession', function() enable_session(false) end, {})
vim.api.nvim_create_user_command('DisableSession', function() disable_session(false) end, {})
vim.api.nvim_create_user_command('LoadSession', function() load_session(false) end, {})
vim.api.nvim_create_user_command('SaveSession', function() save_session(false) end, {})
vim.api.nvim_create_user_command('DestroySession', destroy_session, {})
