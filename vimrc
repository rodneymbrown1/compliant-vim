"##############################################################################
"  COMPLIANT-VIM  |  vimrc  |  ONE FILE  |  OFFLINE  |  NO PLUGINS
"
"  WHAT THIS FILE IS
"    Colors and display settings ONLY (aesthetics + accessibility).
"    Paste it into ~/.vimrc. Nothing else is needed.
"
"  WHAT THIS FILE DOES NOT DO   (security reviewers: grep to confirm)
"    - NO key mappings, NO editing behavior changes, NO commands that edit text.
"    - NO external programs (no system / systemlist), NO network, NO plugins.
"    - NO files created, NO swap/backup/undo/viminfo settings touched.
"    - Colors only change how YOUR terminal draws text inside this Vim window.
"
"  Switch theme:  :Theme <name>   (night warm frost hc paper)
"  or start Vim with  CVIM_THEME=<name>  set in the environment.
"##############################################################################

" ---- knobs you may want to change -----------------------------------------
let s:default_theme = 'night'   " night | warm | frost | hc | paper
let s:colorcolumn   = 100       " 0 = no guide line
" ----------------------------------------------------------------------------

" ---- display only ---------------------------------------------------------
syntax on
set number relativenumber cursorline
set laststatus=2
set list listchars=tab:>-,nbsp:+   " tabs show as >--- ; spots mixed indent
if s:colorcolumn > 0 | let &colorcolumn = s:colorcolumn | endif

" Cursor shape per mode (bar in insert, block in normal): easy to see.
" Only escape codes sent to the terminal; harmless if unsupported.
if &term !~# 'linux'
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[4 q"
  let &t_EI = "\<Esc>[2 q"
  let &t_te = "\<Esc>[0 q" . &t_te
endif

" ===========================================================================
"  THEMES   (pure color tables: hex values only, no code is run from them)
"  Original palettes. Inspired by the general feel of popular dark/light
"  schemes, but no third-party scheme code or files are included.
" ===========================================================================
let s:order = ['night', 'warm', 'frost', 'hc', 'paper']
let s:themes = {}
let s:themes.night = {'bgmode': 'dark',
  \ 'bg': '#16181f', 'fg': '#d5d9e8', 'dim': '#7b84a3', 'cmt': '#8b93b3',
  \ 'cl': '#1f2330', 'sel': '#34406b', 'str': '#a6d98a', 'num': '#ffb070',
  \ 'const': '#ffb070', 'ident': '#7fd4f5', 'func': '#82aaff', 'stmt': '#c792ea',
  \ 'type': '#4fd6be', 'pre': '#ff7eb6', 'spec': '#ffc777', 'err': '#ff6b7f',
  \ 'warn': '#ffc777', 'ok': '#a6d98a', 'srch': '#ffd866', 'srchfg': '#16181f',
  \ 'ml': '#262a3b', 'mlfg': '#d5d9e8', 'mlnc': '#1b1e2a', 'ins': '#1f6a40',
  \ 'acc': '#82aaff', 'accfg': '#16181f', 'pm': '#262a3b'}
let s:themes.warm = {'bgmode': 'dark',
  \ 'bg': '#1e1b18', 'fg': '#e8dcc0', 'dim': '#988b78', 'cmt': '#a79b84',
  \ 'cl': '#2a2621', 'sel': '#4a4034', 'str': '#b8c46a', 'num': '#df9fb5',
  \ 'const': '#df9fb5', 'ident': '#8fbfa0', 'func': '#8ec8b0', 'stmt': '#f0735f',
  \ 'type': '#f5c542', 'pre': '#8fc7a1', 'spec': '#f08a4b', 'err': '#ff6a5f',
  \ 'warn': '#f5c542', 'ok': '#b8c46a', 'srch': '#f5c542', 'srchfg': '#1e1b18',
  \ 'ml': '#312c26', 'mlfg': '#e8dcc0', 'mlnc': '#25211d', 'ins': '#4f5a1f',
  \ 'acc': '#f5a742', 'accfg': '#1e1b18', 'pm': '#312c26'}
let s:themes.frost = {'bgmode': 'dark',
  \ 'bg': '#232834', 'fg': '#dfe5ef', 'dim': '#7e8aa3', 'cmt': '#93a3bf',
  \ 'cl': '#2b3140', 'sel': '#3d4a63', 'str': '#a3d49a', 'num': '#d9a6c9',
  \ 'const': '#d9a6c9', 'ident': '#9fd0e6', 'func': '#88c0d0', 'stmt': '#8fb0e0',
  \ 'type': '#8fcfb8', 'pre': '#b9a3e3', 'spec': '#ebcb8b', 'err': '#e88b94',
  \ 'warn': '#ebcb8b', 'ok': '#a3d49a', 'srch': '#ebcb8b', 'srchfg': '#232834',
  \ 'ml': '#2f3648', 'mlfg': '#dfe5ef', 'mlnc': '#282d3b', 'ins': '#2f6a55',
  \ 'acc': '#88c0d0', 'accfg': '#232834', 'pm': '#2f3648'}
" hc = high contrast, for low vision: pure black, saturated colors, bold UI
let s:themes.hc = {'bgmode': 'dark',
  \ 'bg': '#000000', 'fg': '#ffffff', 'dim': '#9a9a9a', 'cmt': '#b8b8b8',
  \ 'cl': '#262626', 'sel': '#0044aa', 'str': '#00ff87', 'num': '#ffaf00',
  \ 'const': '#ffaf00', 'ident': '#ffffff', 'func': '#ffff5f', 'stmt': '#ff87ff',
  \ 'type': '#5fd7ff', 'pre': '#ff875f', 'spec': '#ffd700', 'err': '#ff5f5f',
  \ 'warn': '#ffd700', 'ok': '#5fff5f', 'srch': '#ffff00', 'srchfg': '#000000',
  \ 'ml': '#ffffff', 'mlfg': '#000000', 'mlnc': '#444444', 'ins': '#00d75f',
  \ 'acc': '#ffff00', 'accfg': '#000000', 'pm': '#303030'}
" paper = light theme, high contrast, for bright rooms
let s:themes.paper = {'bgmode': 'light',
  \ 'bg': '#fbf8ef', 'fg': '#1c1c1c', 'dim': '#6b6b6b', 'cmt': '#55626f',
  \ 'cl': '#efe9d6', 'sel': '#cfe0ff', 'str': '#1a6b2e', 'num': '#b3470a',
  \ 'const': '#b3470a', 'ident': '#0b4f8a', 'func': '#7a2ea8', 'stmt': '#a3175a',
  \ 'type': '#0b6e6e', 'pre': '#8a4b00', 'spec': '#9c5a00', 'err': '#c4001a',
  \ 'warn': '#9a6700', 'ok': '#1a6b2e', 'srch': '#ffe066', 'srchfg': '#000000',
  \ 'ml': '#e3dcc4', 'mlfg': '#1c1c1c', 'mlnc': '#efe9d6', 'ins': '#b7e4c0',
  \ 'acc': '#0b4f8a', 'accfg': '#ffffff', 'pm': '#e3dcc4'}

" hex -> nearest xterm-256 index, so themes also work without truecolor
function! s:Near(v) abort
  let l:lv = [0, 95, 135, 175, 215, 255]
  let l:best = 0 | let l:bd = 999
  for l:i in range(6)
    let l:d = abs(a:v - l:lv[l:i])
    if l:d < l:bd | let l:bd = l:d | let l:best = l:i | endif
  endfor
  return l:best
endfunction

function! s:To256(hex) abort
  let l:r = str2nr(a:hex[1:2], 16) | let l:g = str2nr(a:hex[3:4], 16) | let l:b = str2nr(a:hex[5:6], 16)
  let l:lv = [0, 95, 135, 175, 215, 255]
  let l:ri = s:Near(l:r) | let l:gi = s:Near(l:g) | let l:bi = s:Near(l:b)
  let l:cube = 16 + 36 * l:ri + 6 * l:gi + l:bi
  let l:cd = (l:r - l:lv[l:ri]) * (l:r - l:lv[l:ri]) + (l:g - l:lv[l:gi]) * (l:g - l:lv[l:gi]) + (l:b - l:lv[l:bi]) * (l:b - l:lv[l:bi])
  let l:gx = max([0, min([23, ((l:r + l:g + l:b) / 3 - 8) / 10])])
  let l:gv = 8 + 10 * l:gx
  let l:gd = (l:r - l:gv) * (l:r - l:gv) + (l:g - l:gv) * (l:g - l:gv) + (l:b - l:gv) * (l:b - l:gv)
  return l:gd < l:cd ? 232 + l:gx : l:cube
endfunction

function! s:H(grp, fg, bg, attr) abort
  let l:a = a:attr ==# '' ? 'NONE' : a:attr
  execute 'hi ' . a:grp
    \ . ' guifg='   . (a:fg ==# '' ? 'NONE' : a:fg)
    \ . ' guibg='   . (a:bg ==# '' ? 'NONE' : a:bg)
    \ . ' ctermfg=' . (a:fg ==# '' ? 'NONE' : s:To256(a:fg))
    \ . ' ctermbg=' . (a:bg ==# '' ? 'NONE' : s:To256(a:bg))
    \ . ' gui=' . l:a . ' cterm=' . l:a
endfunction

function! s:Apply(name) abort
  if !has_key(s:themes, a:name)
    echohl ErrorMsg | echo 'unknown theme: ' . a:name | echohl None
    return
  endif
  let p = s:themes[a:name]
  unlet! g:colors_name
  execute 'set background=' . p.bgmode
  hi clear
  if exists('syntax_on') | syntax reset | endif
  let g:colors_name = 'compliant-' . a:name
  let g:cvim_theme = a:name

  " editor chrome
  call s:H('Normal',       p.fg,    p.bg, '')
  call s:H('NonText',      p.dim,   '',   '')
  call s:H('SpecialKey',   p.dim,   '',   '')
  call s:H('EndOfBuffer',  p.bg,    '',   '')
  call s:H('LineNr',       p.dim,   '',   '')
  call s:H('CursorLineNr', p.acc,   p.cl, 'bold')
  call s:H('CursorLine',   '',      p.cl, '')
  call s:H('ColorColumn',  '',      p.cl, '')
  call s:H('SignColumn',   p.dim,   '',   '')
  call s:H('Folded',       p.dim,   p.cl, '')
  call s:H('FoldColumn',   p.dim,   '',   '')
  call s:H('VertSplit',    p.dim,   p.bg, '')
  call s:H('WinSeparator', p.dim,   p.bg, '')
  call s:H('StatusLine',   p.mlfg,  p.ml, 'bold')
  call s:H('StatusLineNC', p.dim,   p.mlnc, '')
  call s:H('Visual',       '',      p.sel, '')
  call s:H('VisualNOS',    '',      p.sel, '')
  call s:H('Search',       p.srchfg, p.srch, 'bold')
  call s:H('IncSearch',    p.accfg, p.acc, 'bold,underline')
  silent! hi! link CurSearch IncSearch
  call s:H('MatchParen',   p.warn,  p.sel, 'bold,underline')
  call s:H('Pmenu',        p.fg,    p.pm, '')
  call s:H('PmenuSel',     p.accfg, p.acc, 'bold')
  call s:H('PmenuSbar',    '',      p.sel, '')
  call s:H('PmenuThumb',   '',      p.acc, '')
  call s:H('WildMenu',     p.accfg, p.acc, 'bold')
  call s:H('TabLine',      p.dim,   p.mlnc, '')
  call s:H('TabLineSel',   p.accfg, p.acc, 'bold')
  call s:H('TabLineFill',  '',      p.mlnc, '')
  call s:H('ErrorMsg',     p.err,   '',   'bold,reverse')
  call s:H('WarningMsg',   p.warn,  '',   'bold')
  call s:H('ModeMsg',      p.ok,    '',   'bold')
  call s:H('MoreMsg',      p.ok,    '',   '')
  call s:H('Question',     p.ok,    '',   'bold')
  call s:H('Title',        p.acc,   '',   'bold')
  call s:H('Directory',    p.func,  '',   'bold')
  call s:H('QuickFixLine', '',      p.sel, 'bold')
  call s:H('DiffAdd',      p.ok,    p.cl, 'bold')
  call s:H('DiffChange',   p.warn,  p.cl, '')
  call s:H('DiffDelete',   p.err,   p.cl, '')
  call s:H('DiffText',     p.accfg, p.acc, 'bold')
  call s:H('SpellBad',     p.err,   '',   'underline')
  call s:H('CvTrail',      '',      p.err, '')

  " syntax
  call s:H('Comment',      p.cmt,   '',   '')
  call s:H('Constant',     p.const, '',   '')
  call s:H('String',       p.str,   '',   '')
  call s:H('Character',    p.str,   '',   '')
  call s:H('Number',       p.num,   '',   '')
  call s:H('Boolean',      p.const, '',   'bold')
  call s:H('Float',        p.num,   '',   '')
  call s:H('Identifier',   p.ident, '',   '')
  call s:H('Function',     p.func,  '',   '')
  call s:H('Statement',    p.stmt,  '',   '')
  call s:H('Operator',     p.fg,    '',   '')
  call s:H('PreProc',      p.pre,   '',   '')
  call s:H('Type',         p.type,  '',   '')
  call s:H('Special',      p.spec,  '',   '')
  call s:H('Delimiter',    p.fg,    '',   '')
  call s:H('Underlined',   p.ident, '',   'underline')
  call s:H('Todo',         p.srchfg, p.warn, 'bold')
  call s:H('Error',        p.err,   '',   'bold,reverse')
  call s:H('Conceal',      p.dim,   '',   '')

  call s:StatusIns(0)
  redraw!
endfunction

" statusline turns green-ish in insert mode: a non-color-only cue is the
" cursor shape; this is the color cue.
function! s:StatusIns(ins) abort
  if !exists('g:cvim_theme') | return | endif
  let p = s:themes[g:cvim_theme]
  call s:H('StatusLine', p.mlfg, a:ins ? p.ins : p.ml, 'bold')
endfunction

function! s:ThemeCmd(name) abort
  if a:name ==# ''
    echo 'themes: ' . join(s:order, ' ') . '   current: ' . get(g:, 'cvim_theme', '?')
  else
    call s:Apply(a:name)
  endif
endfunction

function! s:ThemeComplete(A, L, P) abort
  return filter(copy(s:order), 'v:val =~# "^" . a:A')
endfunction

command! -nargs=? -complete=customlist,s:ThemeComplete Theme call s:ThemeCmd(<q-args>)

" truecolor when the terminal says it can, else the 256-color fallback
if has('termguicolors') && $COLORTERM =~# 'truecolor\|24bit'
  if &term =~# '^\(tmux\|screen\)'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  endif
  set termguicolors
endif

augroup cvim_ui
  autocmd!
  autocmd InsertEnter * call s:StatusIns(1) | redrawstatus
  autocmd InsertLeave * call s:StatusIns(0) | redrawstatus
  autocmd BufWinEnter,WinEnter * if &buftype ==# '' | match CvTrail /\s\+\%#\@<!$/ | endif
augroup END

function! CvFt() abort
  return &filetype ==# '' ? 'no ft' : &filetype
endfunction
set statusline=\ %n\ \ %<%f\ %m%r%h%w%=%{CvFt()}\ \|\ %l:%c\ \|\ %p%%\

" the theme: $CVIM_THEME (set by `theme` in bashrc.sh) wins, else the knob above
call s:Apply($CVIM_THEME !=# '' && has_key(s:themes, $CVIM_THEME) ? $CVIM_THEME : s:default_theme)

