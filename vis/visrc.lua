-- vis config — a small mirror of the old Neovim setup. Leader = <Space>.
-- lpeg (syntax highlighting) is built by install.sh into ~/.local/lib/lua/5.4.
package.cpath = os.getenv('HOME') .. '/.local/lib/lua/5.4/?.so;' .. package.cpath
require('vis')

local config_dir = (os.getenv('XDG_CONFIG_HOME') or (os.getenv('HOME') .. '/.config')) .. '/vis'
package.path = config_dir .. '/?.lua;' .. package.path
local welcome = require('welcome')

local tmp = os.tmpname()

-- Per-window options (also restored when the welcome page is dismissed).
local function window_options()
  vis:command('set number on')
  vis:command('set relativenumbers on')
  vis:command('set cursorline on')
  vis:command('set tabwidth 2')
  vis:command('set expandtab on')
  vis:command('set showeof off')
end

-- Open a file. Dismisses the welcome page first; replaces an empty unnamed buffer
-- (nothing to lose) without complaining about "unsaved changes".
local function edit(path)
  welcome.leave()
  local f = vis.win.file
  local blank = f.name == nil and f.size == 0
  vis:command((blank and 'e! "' or 'e "') .. path .. '"')
end

-- Run a full-screen picker and return the first line it wrote to `tmp`.
-- fzf draws on /dev/tty, so its stdout can go to the file; yazi needs the
-- terminal for itself and writes its choice via --chooser-file instead.
local function pick(cmd, writes_tmp_itself)
  vis:command('!' .. cmd .. (writes_tmp_itself and '' or (' > ' .. tmp)))
  local f = io.open(tmp)
  local out = f and f:read('*l')
  if f then f:close() end
  vis:redraw()
  return out ~= '' and out or nil
end

local function open_file()
  local file = pick('fd --type f --hidden --exclude .git | fzf --reverse --prompt "file > "')
  if file then edit(file) end
end

local function grep_project()
  local hit = pick('rg --line-number --no-heading --color=never . | fzf --reverse --delimiter=: --prompt "grep > "')
  if not hit then return end
  local file, line = hit:match('^([^:]+):(%d+):')
  if file then
    edit(file)
    vis.win.selection:to(tonumber(line), 1)
  end
end

local function explorer()
  local file = pick('yazi --chooser-file=' .. tmp, true)
  if file then edit(file) end
end

welcome.setup({ restore = window_options })

vis.events.subscribe(vis.events.INIT, function()
  vis:command('set theme zacess')
  vis:command('set escdelay 10')
  vis:command('set autoindent on')
  vis:command('set ignorecase on')

  local n, i, v = vis.modes.NORMAL, vis.modes.INSERT, vis.modes.VISUAL
  vis:map(i, 'jk', '<Escape>')                 -- exit insert mode
  vis:map(n, ' w',  ':w<Enter>')
  vis:map(n, ' q',  ':q<Enter>')
  vis:map(n, ' =',  '<C-a>')                   -- increment / decrement
  vis:map(n, ' -',  '<C-x>')
  vis:map(n, ' sv', ':vsplit<Enter>')          -- splits
  vis:map(n, ' sh', ':split<Enter>')
  vis:map(n, ' sx', ':q<Enter>')
  vis:map(v, ' y',  '"+y')                     -- system clipboard
  vis:map(n, ' p',  '"+p')
  vis:map(n, ' ff', open_file, 'Find file (fzf)')
  vis:map(n, ' fs', grep_project, 'Find string (ripgrep + fzf)')
  vis:map(n, ' ee', explorer, 'File explorer (yazi)')
  vis:map(n, ' ec', function() edit(config_dir .. '/visrc.lua') end, 'Edit this config')
  vis:map(n, ' lg', ':!lazygit<Enter>')
end)

vis.events.subscribe(vis.events.WIN_OPEN, window_options)
