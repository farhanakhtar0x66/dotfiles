-- Welcome page, shown when vis starts without a file. A port of the old Neovim
-- (alpha-nvim) dashboard: block-letter banner + the same menu, centred in the window.
--
-- vis 0.9 can't make a buffer read-only, so the page is ordinary text that is wiped
-- the moment you start doing something (open a file, `e` for a new one, insert, ...).
local M = { active = false }

-- "VIS" in the same ANSI Shadow font the old NEOVIM banner used.
local art = {
  '██╗   ██╗██╗███████╗',
  '██║   ██║██║██╔════╝',
  '██║   ██║██║███████╗',
  '╚██╗ ██╔╝██║╚════██║',
  ' ╚████╔╝ ██║███████║',
  '  ╚═══╝  ╚═╝╚══════╝',
}

local menu = {
  { icon = 0xF15B,  text = 'New File',              key = 'e' },
  { icon = 0xE5FE,  text = 'Toggle file explorer',  key = 'SPC ee' },
  { icon = 0xF0C7C, text = 'Find File',             key = 'SPC ff' },
  { icon = 0xF422,  text = 'Find Word',             key = 'SPC fs' },
  { icon = 0xF013,  text = 'Edit config',           key = 'SPC ec' },
  { icon = 0xF057,  text = 'Quit VIS',              key = 'q' },
}

local WIDTH = 52                 -- width of the menu block
local STYLE_ART, STYLE_KEY, STYLE_ICON = 60, 61, 62   -- ids below STYLE_LEXER_MAX (64)
local ranges = {}                -- { {style, first, last}, ... } byte offsets, inclusive

local function len(s) return utf8.len(s) or #s end

local function build(width, height)
  local lines, marks = {}, {}      -- marks[i] = list of {style, byte_from, byte_to} within line i
  local function add(text, mk) lines[#lines + 1] = text; marks[#lines] = mk or {} end

  local pad = string.rep(' ', math.max(0, (width - WIDTH) // 2))
  local artpad = string.rep(' ', (WIDTH - len(art[1])) // 2)

  local total = #art + 2 + #menu * 2 - 1
  for _ = 1, math.max(0, math.floor((height - total) * 0.3)) do add('') end

  for _, row in ipairs(art) do
    local text = pad .. artpad .. row
    add(text, { { STYLE_ART, #pad + #artpad, #text } })
  end
  add(''); add('')
  local cursor_line
  for i, m in ipairs(menu) do
    local icon = utf8.char(m.icon)
    local left = icon .. '  > ' .. m.text
    local gap = string.rep(' ', math.max(1, WIDTH - len(left) - len(m.key)))
    local text = pad .. left .. gap .. m.key
    add(text, {
      { STYLE_ICON, #pad, #pad + #icon },
      { STYLE_KEY, #text - #m.key, #text },
    })
    cursor_line = cursor_line or #lines
    if i < #menu then add('') end
  end

  -- flatten to one string and absolute byte ranges
  local buf, off = {}, 0
  ranges = {}
  local cursor = 0
  for i, text in ipairs(lines) do
    for _, r in ipairs(marks[i]) do ranges[#ranges + 1] = { r[1], off + r[2], off + r[3] - 1 } end
    if i == cursor_line then cursor = off + #pad end
    buf[#buf + 1] = text .. '\n'
    off = off + #text + 1
  end
  return table.concat(buf), cursor
end

-- Wipe the page and restore normal window options (set via M.setup{ restore = fn }).
function M.leave()
  if not M.active then return end
  M.active = false
  local f = M.file
  f:delete(0, f.size)
  if M.restore then M.restore() end
end

function M.setup(opts)
  M.restore = opts.restore
  local N = vis.modes.NORMAL

  local function on_page() return M.active and vis.win and vis.win.file == M.file end

  -- Keys that mean something on the page but are normal motions/commands elsewhere:
  -- on the page they act; anywhere else they forward to vis's own action untouched.
  local function bind(key, action, on_welcome)
    vis:map(N, key, function()
      if on_page() then on_welcome() else vis:feedkeys('<' .. action .. '>') end
      return 0
    end)
  end
  local function start_editing(action) return function() M.leave(); vis:feedkeys('<' .. action .. '>') end end

  bind('e', 'vis-motion-word-end-next', start_editing('vis-mode-insert'))     -- New File
  bind('q', 'vis-macro-record',         function() vis:command('q!') end)     -- Quit
  -- any "start typing" key replaces the page instead of typing into the banner
  bind('i', 'vis-mode-insert',          start_editing('vis-mode-insert'))
  bind('a', 'vis-append-char-next',     start_editing('vis-mode-insert'))
  bind('o', 'vis-open-line-below',      start_editing('vis-mode-insert'))
  bind('O', 'vis-open-line-above',      start_editing('vis-mode-insert'))
  bind('I', 'vis-insert-line-start',    start_editing('vis-mode-insert'))
  bind('A', 'vis-append-line-end',      start_editing('vis-mode-insert'))

  vis.events.subscribe(vis.events.START, function()
    local win = vis.win
    if not win or win.file.name or win.file.size > 0 then return end   -- started with a file / stdin
    local text, cursor = build(win.width, win.height)
    M.active, M.win, M.file = true, win, win.file
    vis:command('set number off')
    vis:command('set relativenumbers off')
    vis:command('set cursorline off')
    win:style_define(STYLE_ART, 'fore:yellow,bold')
    win:style_define(STYLE_KEY, 'fore:magenta,bold')
    win:style_define(STYLE_ICON, 'fore:blue')
    win.file:insert(0, text)
    win.selection.pos = cursor
  end)

  vis.events.subscribe(vis.events.WIN_HIGHLIGHT, function(win)
    if not M.active then return end
    if win.file ~= M.file then            -- the page was replaced (e.g. `:e file`): restore options
      M.active = false
      if M.restore then M.restore() end
      return
    end
    for _, r in ipairs(ranges) do win:style(r[1], r[2], r[3]) end
  end)
end

return M
