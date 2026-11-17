"##############################################################################
"  COMPLIANT-VIM  |  vimrc  |  ONE FILE  |  OFFLINE  |  NO PLUGINS
"
"  WHAT THIS FILE IS
"    Colors, editor settings and a few small search/format helpers, written
"    in plain Vim script. Paste it into ~/.vimrc. Nothing else is needed.
"
"  WHAT THIS FILE DOES NOT DO   (security reviewers: grep to confirm)
"    - NO network access of any kind. No git, curl, wget, ssh, scp, http.
"    - NO plugin manager, NO downloads, NO packages, NO third-party code.
"    - NO python/lua/ruby/perl/tcl interface calls.
"    - NO changes outside Vim: colors only change how YOUR terminal draws
"      text inside this Vim window. They do not touch the system, other
"      programs, other users, or any file contents.
"    - NO reading of other users' files or system configuration.
"
"  EXTERNAL PROGRAMS IT CAN RUN (all local, all standard, all optional)
"    find, grep      used by :Ff and :Gr (file / text search into quickfix)
"    clang-format    used by :Fmt ONLY IF already installed; else built-in
"    That is the complete list. Search this file for system( / systemlist(.
"
"  FILES IT MAY CREATE
"    ~/.vim/swap/    swap files (mode 0700) so they stop littering project
"                    directories. Set s:swap_mode = 'off' below for none.
"    ~/.viminfo      Vim's normal history file, with register contents
"                    DISABLED so yanked text is never written to disk.
"
"  Use :Keys inside Vim for the cheat sheet.   Leader key = <Space>
"##############################################################################

set nocompatible
let mapleader = ' '

" ---- knobs you may want to change -----------------------------------------
let s:default_theme = 'night'   " night | warm | frost | hc | paper
let s:swap_mode     = 'central' " 'central' = ~/.vim/swap | 'off' = no swap | 'default'
let s:shiftwidth    = 4
let s:expandtab     = 1         " 1 = spaces, 0 = tabs
let s:colorcolumn   = 100       " 0 = no guide line
" ----------------------------------------------------------------------------

" ---- hardening ------------------------------------------------------------
set nomodeline modelines=0      " never obey settings embedded in files
set noexrc secure               " never load .vimrc/.exrc from the cwd
set viminfo='200,<0,s0,:200,/100,h   " history yes, register contents NEVER saved
set noundofile                  " no persistent-undo copies of file contents
set nobackup writebackup

if s:swap_mode ==# 'off'
  set noswapfile
elseif s:swap_mode ==# 'central'
  let s:swapdir = expand('~/.vim/swap')
  if !isdirectory(s:swapdir)
    silent! call mkdir(s:swapdir, 'p', 0700)
  endif
  if isdirectory(s:swapdir)
    let &directory = s:swapdir . '//'   " // = full-path names, no collisions
  endif
endif

" ---- core behaviour -------------------------------------------------------
syntax on
filetype plugin indent on
set encoding=utf-8 fileformats=unix,dos
set hidden                      " switch buffers without saving first
set autoread
set backspace=indent,eol,start
set history=1000
set updatetime=1000 ttimeout ttimeoutlen=10
set mouse=a
silent! set ttymouse=sgr
set splitright splitbelow
set scrolloff=8 sidescrolloff=8
set nowrap nofoldenable
set display+=lastline
set nrformats-=octal
set incsearch hlsearch ignorecase smartcase
set wildmenu wildmode=longest:full,full
silent! set wildoptions=pum,fuzzy
set wildignore+=*.o,*.obj,*.a,*.so,*.d,*.swp,*~,*/.git/*,*/node_modules/*
set path+=**                    " :find foo<Tab> searches below the cwd
set tags=./tags;,tags
set autoindent
let &shiftwidth  = s:shiftwidth
let &softtabstop = s:shiftwidth
let &tabstop     = s:shiftwidth
let &expandtab   = s:expandtab
if s:colorcolumn > 0 | let &colorcolumn = s:colorcolumn | endif
set number relativenumber cursorline
set showcmd ruler laststatus=2
set list listchars=tab:>-,nbsp:+   " tabs show as >--- ; spots mixed indent
packadd! matchit                " ships with Vim: % jumps #if/#endif etc.

" Cursor shape per mode (bar in insert, block in normal): easy to see.
" Only escape codes sent to the terminal; harmless if unsupported.
if &term !~# 'linux'
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[4 q"
  let &t_EI = "\<Esc>[2 q"
  let &t_te = "\<Esc>[0 q" . &t_te
endif

" ---- C / C++ --------------------------------------------------------------
augroup cvim_ft
  autocmd!
  autocmd BufRead,BufNewFile *.tpp,*.ipp,*.inl setfiletype cpp
  autocmd FileType c,cpp setlocal cindent cinoptions=:0,l1,g0,N-s,E-s,t0,(0,W4,j1,J1
  autocmd FileType * setlocal formatoptions-=o formatoptions+=j
  autocmd QuickFixCmdPost make,grep,cgetexpr cwindow
  autocmd FileType qf nnoremap <buffer> <silent> <LeftMouse> <LeftMouse><CR>
augroup END
let g:c_syntax_for_h = 0

" ---- netrw (built in file explorer) ---------------------------------------
let g:netrw_banner       = 0
let g:netrw_liststyle    = 3
let g:netrw_winsize      = 25
let g:netrw_altv         = 1
let g:netrw_hide         = 1
let g:netrw_list_hide    = '\.swp$,\.swo$,\.o$,\.obj$,\.d$,\~$,^\.git/$'
let g:netrw_nogx         = 1    " do not hand files/URLs to external openers

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

function! s:Cycle(dir) abort
  let l:i = index(s:order, get(g:, 'cvim_theme', s:default_theme))
  let l:i = (l:i + a:dir + len(s:order)) % len(s:order)
  call s:Apply(s:order[l:i])
  echo 'theme: ' . g:cvim_theme . '   (F5 next, F6 previous, :Theme name)'
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
nnoremap <silent> <F5> :call <SID>Cycle(1)<CR>
nnoremap <silent> <F6> :call <SID>Cycle(-1)<CR>

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

" ===========================================================================
"  WORKFLOW HELPERS
" ===========================================================================

" :Ff name   find files by (part of) name, below the cwd -> quickfix list
function! s:FindFiles(pat) abort
  let l:cmd = 'find . \( -name .git -o -name .svn -o -name .hg -o -name node_modules \) -prune -o -type f -iname '
    \ . shellescape('*' . a:pat . '*') . ' -print'
  let l:files = systemlist(l:cmd)
  if v:shell_error || empty(l:files)
    echo 'no files match: ' . a:pat | return
  endif
  if len(l:files) == 1
    execute 'edit ' . fnameescape(l:files[0]) | return
  endif
  let l:save = &errorformat
  set errorformat=%f
  cgetexpr sort(l:files)[:999]
  let &errorformat = l:save
  copen
endfunction

" :Gr text   grep below the cwd -> quickfix. Smartcase. Empty = word under cursor.
function! s:Grep(pat) abort
  let l:p = a:pat ==# '' ? expand('<cword>') : a:pat
  let l:ic = l:p =~# '[A-Z]' ? '' : ' -i'
  let l:cmd = 'grep -rnIH' . l:ic
    \ . ' --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --exclude-dir=node_modules --exclude=tags'
    \ . ' -e ' . shellescape(l:p) . ' .'
  let l:out = systemlist(l:cmd)
  if empty(l:out)
    echo 'no matches: ' . l:p | return
  endif
  let l:save = &errorformat
  set errorformat=%f:%l:%m
  cgetexpr l:out[:2999]
  let &errorformat = l:save
  copen
endfunction

command! -nargs=1 Ff call s:FindFiles(<q-args>)
command! -nargs=? Gr call s:Grep(<q-args>)

" :Fmt   format the buffer: clang-format if installed, else Vim's own cindent
function! s:Fmt() abort
  let l:view = winsaveview()
  if &filetype =~# '^\(c\|cpp\|cuda\|objc\|objcpp\)$' && executable('clang-format')
    let l:out = systemlist('clang-format --assume-filename=' . shellescape(expand('%:p')), getline(1, '$'))
    if v:shell_error == 0 && !empty(l:out)
      silent keepjumps call setline(1, l:out)
      if line('$') > len(l:out)
        silent keepjumps execute (len(l:out) + 1) . ',$delete _'
      endif
      echo 'formatted with clang-format (honours .clang-format)'
    else
      echohl ErrorMsg | echo 'clang-format failed; buffer left untouched' | echohl None
    endif
  else
    silent keepjumps normal! gg=G
    echo 'formatted with built-in cindent (clang-format not found)'
  endif
  call winrestview(l:view)
endfunction
command! Fmt call s:Fmt()

" :Trim  strip trailing whitespace
command! Trim let s:v = winsaveview() | silent keepjumps %s/\s\+$//e | call winrestview(s:v)

" :LastBuild  load the log written by `mk` (bashrc.sh) into quickfix
function! s:LastBuild() abort
  let l:log = (empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME) . '/compliant-vim/build.log'
  if !filereadable(l:log) | echo 'no build log yet: run  mk make  in the shell' | return | endif
  execute 'cfile ' . fnameescape(l:log)
  cwindow
endfunction
command! LastBuild call s:LastBuild()

" Recent-buffer list (most recently used first). Own bookkeeping so it works
" on any Vim 8.x: no dependence on newer :ls flags.
let s:mru = []
function! s:Track() abort
  let l:n = bufnr('%')
  if !buflisted(l:n) || &buftype !=# '' | return | endif
  call filter(s:mru, 'v:val != ' . l:n)
  call insert(s:mru, l:n)
endfunction
augroup cvim_mru
  autocmd!
  autocmd BufEnter * call s:Track()
augroup END

function! s:Buffers() abort
  call filter(s:mru, 'bufexists(v:val) && buflisted(v:val)')
  if len(s:mru) < 2
    echo 'only one buffer open' | return
  endif
  let l:i = 0
  for l:b in s:mru
    let l:i += 1
    let l:name = bufname(l:b) ==# '' ? '[No Name]' : bufname(l:b)
    echo printf('%3d  %s%s%s', l:i, l:b == bufnr('%') ? '%' : ' ', getbufvar(l:b, '&modified') ? '+' : ' ', ' ' . l:name)
  endfor
  let l:c = input('go to # (Enter cancels): ')
  redraw
  if l:c =~# '^\d\+$' && l:c >= 1 && l:c <= len(s:mru)
    execute 'buffer ' . s:mru[l:c - 1]
  endif
endfunction

" ---- keys -----------------------------------------------------------------
nnoremap Y y$
nnoremap n nzzzv
nnoremap N Nzzzv
vnoremap < <gv
vnoremap > >gv
nnoremap <silent> <leader>n :nohlsearch<CR>

" files and buffers
nnoremap <leader><leader> <C-^>
nnoremap <silent> <leader>b :call <SID>Buffers()<CR>
nnoremap <leader>o :browse oldfiles<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> <leader>d :bdelete<CR>
nnoremap <silent> <leader>e :Lexplore<CR>
nnoremap <silent> - :Explore<CR>

" search and build
nnoremap <leader>f :Ff<Space>
nnoremap <leader>g :Gr<Space>
nnoremap <silent> <leader>* :Gr<CR>
nnoremap <silent> <leader>m :make<CR>
nnoremap <silent> <leader>= :Fmt<CR>
nnoremap <silent> <leader>q :if empty(filter(getwininfo(), 'v:val.quickfix'))<Bar>copen<Bar>else<Bar>cclose<Bar>endif<CR>
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [q :cprevious<CR>

" windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ---- :Keys cheat sheet ----------------------------------------------------
function! s:Keys() abort
  let l:t = [
    \ 'COMPLIANT-VIM KEYS          (leader = <Space>)       q or :q closes this',
    \ '',
    \ 'THEMES   F5 next   F6 previous   :Theme <name>   (night warm frost hc paper)',
    \ 'FILES    <Space><Space>  previous file (toggle)     <Space>b   buffers, recent first, then type number',
    \ '         <Space>o  recently opened files (all sessions)   ]b [b  next/prev buffer',
    \ '         -  netrw for current dir   <Space>e  toggle netrw sidebar   <Space>d  close buffer',
    \ 'SEARCH   <Space>f name  find files -> list     <Space>g text  grep -> list     <Space>*  grep word under cursor',
    \ '         list window: Enter / mouse click jumps   ]q [q next/prev result   <Space>q toggle list',
    \ 'BUILD    <Space>m  :make        :LastBuild  load errors from shell `mk`',
    \ 'FORMAT   <Space>=  :Fmt (clang-format or cindent)   :Trim  strip trailing space   =G  reindent file',
    \ 'WINDOWS  Ctrl-h/j/k/l move   :split  :vsplit   Ctrl-w o  only this one',
    \ 'MISC     <Space>n  clear search highlight   Y  yank to end of line   %  jump matching bracket/#if',
    \ ]
  new
  setlocal buftype=nofile bufhidden=wipe noswapfile nonumber norelativenumber nolist
  call setline(1, l:t)
  setlocal nomodifiable
  nnoremap <buffer> <silent> q :close<CR>
endfunction
command! Keys call s:Keys()
