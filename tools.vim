"##############################################################################
"  COMPLIANT-VIM  |  tools.vim  |  OPTIONAL SECOND FILE  |  OFFLINE  |  VIM 8.0+
"
"  WHAT THIS FILE IS
"    Editing tools written from scratch in plain Vimscript: settings, remaps,
"    a fuzzy file/grep picker, pinned files, an undo-tree viewer, a small git
"    status buffer, tags navigation. Paste it BELOW vimrc (same ~/.vimrc), or
"    save it and add   source /path/to/tools.vim   after the vimrc content.
"    vimrc works without it. Type :Keys for the cheat sheet.
"
"  WHAT THIS FILE DOES (security reviewers: grep to confirm)
"    - Runs these external programs, only on an explicit key/command, always
"      with shellescape()d arguments:  find  grep  git  ctags  chmod
"      (grep -nE 'system\(|systemlist\(' tools.vim)
"    - Creates files only under ~/.vim/undo and ~/.cache/compliant-vim (0700):
"      undo history, pinned-file lists, tags. Delete them any time.
"    - Changes key mappings and editing settings. Listed in :Keys.
"
"  WHAT THIS FILE DOES NOT DO
"    - NO network, NO plugins, NO :python/:lua/:ruby, NO eval, NO background
"      processes (no job_start), NO sudo, NO package manager, NO downloads.
"    - Nothing runs on startup except settings and mapping definitions.
"
"  Each section replicates the BEHAVIOR of a well-known open source tool by
"  describing it in Vimscript. No third-party code is included.
"##############################################################################

" ---- knobs -----------------------------------------------------------------
let s:transparent  = 0      " 1 = no background color (terminal's own shows through)
let s:block_cursor = 0      " 1 = block cursor in insert mode too
let s:mark_slots   = 4      " pinned files, jump with the keys below
let s:mark_keys    = ['<leader>1', '<leader>2', '<leader>3', '<leader>4']
                            " Ctrl-h/t/n/s clash with Backspace/Tab/Enter/XOFF in
                            " terminals, so leader+digit is the default
let s:find_skip    = ['.git', 'node_modules', 'build', 'dist', 'target', '.cache']
let s:src_ft       = ['c', 'cpp', 'java', 'javascript', 'typescript', 'rust', 'go',
  \ 'python', 'sh', 'lua', 'cs', 'php', 'swift', 'kotlin', 'scala']
" -----------------------------------------------------------------------------

let s:self = expand('<sfile>:p')

" ===========================================================================
"  small helpers
" ===========================================================================
function! s:Err(msg) abort
  echohl ErrorMsg | echom a:msg | echohl None
endfunction

function! s:CacheDir() abort
  let l:d = expand('~/.cache/compliant-vim')
  if !isdirectory(l:d) | call mkdir(l:d, 'p', 0700) | endif
  return l:d
endfunction

" a dir for the current buffer's file, else the cwd
function! s:Dir() abort
  let l:d = expand('%:p:h')
  return (&buftype ==# '' && l:d !=# '' && isdirectory(l:d)) ? l:d : getcwd()
endfunction

" open a throwaway buffer: s:Scratch('name', lines, 'filetype')
function! s:Scratch(name, lines, ft) abort
  botright new
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap
  setlocal nonumber norelativenumber nolist colorcolumn= foldcolumn=0
  silent! execute 'file ' . fnameescape(a:name)
  call setline(1, a:lines)
  if a:ft !=# '' | let &l:filetype = a:ft | endif
  setlocal nomodifiable
  nnoremap <silent> <buffer> q :close<CR>
endfunction

" ===========================================================================
"  1. SETTINGS  (the video's `set.lua`)
" ===========================================================================
let mapleader = ' '
set hidden nowrap
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smartindent
set nobackup nowritebackup noswapfile
set incsearch nohlsearch
set scrolloff=8 updatetime=50
set isfname+=@-@
set backspace=indent,eol,start wildmenu
if exists('+signcolumn') | set signcolumn=yes | endif

" persistent undo, so the undo tree survives restarts (the video drops backups for this)
if has('persistent_undo')
  let s:undodir = expand('~/.vim/undo')
  if !isdirectory(s:undodir) | silent! call mkdir(s:undodir, 'p', 0700) | endif
  if isdirectory(s:undodir)
    let &undodir = s:undodir
    set undofile
  endif
endif

if s:block_cursor && &term !~# 'linux'
  let &t_SI = "\<Esc>[2 q"
  let &t_SR = "\<Esc>[2 q"
endif

" transparent background (the video's `ColorMyPencils`). vimrc calls this
" after every :Theme change.
function! CvAfterTheme(p, H) abort
  " --- syntax coverage: separate the groups stock themes lump together
  call a:H('Conditional',  a:p.stmt,  '', 'bold')
  call a:H('Repeat',       a:p.stmt,  '', 'bold')
  call a:H('Exception',    a:p.stmt,  '', 'bold')
  call a:H('Keyword',      a:p.stmt,  '', '')
  call a:H('Label',        a:p.spec,  '', '')
  call a:H('Structure',    a:p.type,  '', 'bold')
  call a:H('StorageClass', a:p.type,  '', '')
  call a:H('Typedef',      a:p.type,  '', 'bold')
  call a:H('Define',       a:p.pre,   '', '')
  call a:H('Include',      a:p.pre,   '', 'bold')
  call a:H('Macro',        a:p.pre,   '', 'bold')
  call a:H('SpecialChar',  a:p.spec,  '', 'bold')
  call a:H('Tag',          a:p.spec,  '', '')
  call a:H('CvFunc',       a:p.func,  '', '')
  if s:transparent
    for l:g in ['Normal', 'NormalFloat', 'SignColumn', 'LineNr', 'EndOfBuffer', 'NonText']
      silent! execute 'hi ' . l:g . ' guibg=NONE ctermbg=NONE'
    endfor
  endif
endfunction
if exists('g:cvim_theme') && exists('*CvAfterTheme')
  " vimrc already applied a theme before we existed: re-run it so the hook fires
  silent! execute 'Theme ' . g:cvim_theme
endif

nnoremap <silent> <leader>pv :Ex<CR>
execute 'nnoremap <silent> <leader>R :source ' . fnameescape(s:self) . '<CR>'

" ===========================================================================
"  2. REMAPS  (the video's "best remaps of your lifetime")
" ===========================================================================
" move the selected lines, re-indenting as they go
xnoremap <silent> J :m '>+1<CR>gv=gv
xnoremap <silent> K :m '<-2<CR>gv=gv
" J joins lines but the cursor stays put
nnoremap J mzJ`z
" half-page jumps and search hits keep the cursor centered
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap n nzzzv
nnoremap N Nzzzv
" paste over a selection without losing what you yanked
xnoremap <leader>p "_dP
" yank to the system clipboard (plain y stays inside vim); falls back to
" the unnamed register when this vim has no clipboard support
let s:cb = has('clipboard') ? '"+' : '"'
execute 'nnoremap <leader>y ' . s:cb . 'y'
execute 'xnoremap <leader>y ' . s:cb . 'y'
execute 'nnoremap <leader>Y ' . s:cb . 'Y'
" delete into the black hole register
nnoremap <leader>d "_d
xnoremap <leader>d "_d
" Ctrl-C leaves insert mode like Esc (also ends visual-block inserts cleanly)
inoremap <C-c> <Esc>
" Ex mode is never what you wanted
nnoremap Q <nop>
" quickfix / location list walking
nnoremap <silent> <C-k> :cnext<CR>zz
nnoremap <silent> <C-j> :cprev<CR>zz
nnoremap <silent> <leader>k :lnext<CR>zz
nnoremap <silent> <leader>j :lprev<CR>zz
" substitute the word under the cursor across the file
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

function! s:Chmod() abort
  let l:f = expand('%:p')
  if &buftype !=# '' || l:f ==# '' || !filereadable(l:f)
    call s:Err('save the file first') | return
  endif
  call system('chmod +x ' . shellescape(l:f))
  echo 'chmod +x ' . fnamemodify(l:f, ':~')
endfunction
nnoremap <silent> <leader>x :call <SID>Chmod()<CR>

" ===========================================================================
"  3. FUZZY PICKER  (replaces telescope: git files, all files, grep)
"     Ctrl-p git files | Space pf all files | Space ps grep prompt -> quickfix
"     In the picker: type to filter, Ctrl-n/Ctrl-p or Down/Up move, Enter opens,
"     Esc cancels. Vim 8.0 has no matchfuzzy(), so matching is done here.
" ===========================================================================
let s:cache = {}

function! s:Fresh(key) abort
  return has_key(s:cache, a:key) && localtime() - s:cache[a:key].t < 30
endfunction

function! s:FindFiles() abort
  let l:key = 'find|' . getcwd()
  if !s:Fresh(l:key)
    let l:cmd = 'find . -type f'
    for l:s in s:find_skip
      let l:cmd .= ' -not -path ' . shellescape('*/' . l:s . '/*')
    endfor
    let l:out = systemlist(l:cmd . ' 2>/dev/null | head -n 100000')
    let s:cache[l:key] = {'t': localtime(), 'l': map(l:out, 'v:val[2:]')}
  endif
  return s:cache[l:key].l
endfunction

function! s:GitFiles() abort
  let l:key = 'git|' . getcwd()
  if !s:Fresh(l:key)
    let l:out = systemlist('git ls-files -co --exclude-standard 2>/dev/null')
    if v:shell_error | return s:FindFiles() | endif
    let s:cache[l:key] = {'t': localtime(), 'l': l:out}
  endif
  return s:cache[l:key].l
endfunction

" subsequence score: consecutive runs, word starts and basename hits win
function! s:Score(s, pat) abort
  let l:s = tolower(a:s)
  let l:sc = 0 | let l:si = 0 | let l:prev = -2
  for l:c in split(a:pat, '\zs')
    let l:i = stridx(l:s, l:c, l:si)
    if l:i < 0 | return -1 | endif
    let l:sc += 1
    if l:i == l:prev + 1 | let l:sc += 5 | endif
    if l:i == 0 || l:s[l:i - 1] =~# '[/_.\- ]' | let l:sc += 3 | endif
    let l:prev = l:i | let l:si = l:i + 1
  endfor
  if stridx(l:s, a:pat, strridx(l:s, '/') + 1) >= 0 | let l:sc += 10 | endif
  return l:sc * 10 - strlen(l:s)
endfunction

function! s:ByScore(a, b) abort
  return a:a[0] == a:b[0] ? 0 : (a:a[0] > a:b[0] ? -1 : 1)
endfunction

function! s:Filter(items, q) abort
  let l:pat = tolower(substitute(a:q, '\s', '', 'g'))
  if l:pat ==# '' | return a:items[:199] | endif
  let l:re = join(map(split(l:pat, '\zs'), 'escape(v:val, "\\.*$^~[]")'), '.\{-}')
  let l:m = filter(copy(a:items), 'v:val =~? l:re')[:1999]
  let l:pairs = map(l:m, '[s:Score(v:val, l:pat), v:val]')
  call sort(l:pairs, function('s:ByScore'))
  return map(l:pairs[:199], 'v:val[1]')
endfunction

function! s:Fuzzy(items, title) abort
  if empty(a:items) | call s:Err('nothing to pick from') | return | endif
  let l:back = win_getid()
  botright 12new
  let l:buf = bufnr('%')
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap
  setlocal nonumber norelativenumber nolist cursorline colorcolumn= signcolumn=no
  let &l:statusline = ' ' . a:title . '  (' . len(a:items) . ')'
  let l:q = '' | let l:sel = 0 | let l:res = [] | let l:pick = ''
  try
    while 1
      let l:res = s:Filter(a:items, l:q)
      let l:sel = max([0, min([l:sel, len(l:res) - 1])])
      setlocal modifiable
      silent %delete _
      call setline(1, empty(l:res) ? ['  (no match)'] : l:res)
      setlocal nomodifiable
      call cursor(l:sel + 1, 1)
      redraw
      echo '> ' . l:q
      try
        let l:c = getchar()
      catch /^Vim:Interrupt$/
        break
      endtry
      let l:k = type(l:c) == 0 ? nr2char(l:c) : l:c
      if l:k ==# "\<Esc>" || l:k ==# "\<C-c>"
        break
      elseif l:k ==# "\<CR>"
        if !empty(l:res) | let l:pick = l:res[l:sel] | endif
        break
      elseif l:k ==# "\<BS>" || l:k ==# "\<C-h>" || l:k ==# "\x7f"
        let l:q = substitute(l:q, '.$', '', '') | let l:sel = 0
      elseif l:k ==# "\<C-u>"
        let l:q = '' | let l:sel = 0
      elseif l:k ==# "\<C-n>" || l:k ==# "\<Down>" || l:k ==# "\<C-j>"
        let l:sel += 1
      elseif l:k ==# "\<C-p>" || l:k ==# "\<Up>" || l:k ==# "\<C-k>"
        let l:sel -= 1
      elseif type(l:c) == 0 && l:c >= 32
        let l:q .= l:k | let l:sel = 0
      endif
    endwhile
  finally
    silent! execute 'bwipeout! ' . l:buf
    call win_gotoid(l:back)
    redraw | echo ''
  endtry
  if l:pick !=# '' | execute 'edit ' . fnameescape(l:pick) | endif
endfunction

function! s:Grep(term) abort
  if a:term ==# '' | return | endif
  let l:cmd = 'grep -rnI'
  for l:s in s:find_skip
    let l:cmd .= ' --exclude-dir=' . shellescape(l:s)
  endfor
  let l:out = systemlist(l:cmd . ' -e ' . shellescape(a:term) . ' . 2>/dev/null | head -n 5000')
  if empty(l:out) | echo 'no matches for: ' . a:term | return | endif
  cgetexpr l:out
  copen
endfunction

command! Ff call s:Fuzzy(s:FindFiles(), 'files')
command! Gf call s:Fuzzy(s:GitFiles(), 'git files')
command! -nargs=? Gr call s:Grep(<q-args> !=# '' ? <q-args> : input('grep> '))
nnoremap <silent> <C-p>      :Gf<CR>
nnoremap <silent> <leader>pf :Ff<CR>
nnoremap <silent> <leader>ps :Gr<CR>

" ===========================================================================
"  4a. PINNED FILES  (harpoon: a short list of files you jump between)
"      Space a pin this file | Ctrl-e edit the list | Space 1-4 jump
"      The list is per project (cwd) and saved in ~/.cache/compliant-vim.
" ===========================================================================
function! s:MarkFile() abort
  return s:CacheDir() . '/marks-' . substitute(getcwd(), '[^A-Za-z0-9]', '_', 'g')[-120:]
endfunction

function! s:MarksLoad() abort
  let l:f = s:MarkFile()
  return filereadable(l:f) ? readfile(l:f)[: s:mark_slots - 1] : []
endfunction

function! s:MarksSave(list) abort
  call writefile(a:list[: s:mark_slots - 1], s:MarkFile())
endfunction

function! s:MarkAdd() abort
  let l:f = expand('%:p')
  if &buftype !=# '' || l:f ==# '' | call s:Err('not a file') | return | endif
  let l:list = s:MarksLoad()
  if index(l:list, l:f) >= 0 | echo 'already pinned' | return | endif
  if len(l:list) >= s:mark_slots | call s:Err('pin list full: edit it with Ctrl-e') | return | endif
  call s:MarksSave(l:list + [l:f])
  echo 'pinned ' . (len(l:list) + 1) . ': ' . fnamemodify(l:f, ':~:.')
endfunction

function! s:MarkGo(n) abort
  let l:list = s:MarksLoad()
  if a:n > len(l:list) | call s:Err('nothing pinned in slot ' . a:n) | return | endif
  execute 'edit ' . fnameescape(l:list[a:n - 1])
endfunction

function! s:MarkMenuSave() abort
  let l:lines = filter(map(getline(1, '$'), 'fnamemodify(v:val, ":p")'), 'v:val !=# "" && v:val !~# "/$"')
  let l:seen = []
  for l:f in l:lines
    if index(l:seen, l:f) < 0 | call add(l:seen, l:f) | endif
  endfor
  call s:MarksSave(l:seen)
endfunction

function! s:MarkMenu() abort
  let l:w = bufwinnr('^cvim-pins$')
  if l:w > 0 | execute l:w . 'wincmd w' | close | return | endif
  let l:cwd = getcwd()
  botright new
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap
  setlocal nonumber norelativenumber nolist colorcolumn=
  silent file cvim-pins
  call setline(1, map(s:MarksLoad(), 'fnamemodify(v:val, ":~:.")'))
  let &l:statusline = ' pins: edit/reorder/delete lines, Enter opens, q saves+closes'
  execute 'lcd ' . fnameescape(l:cwd)
  nnoremap <silent> <buffer> q :close<CR>
  nnoremap <silent> <buffer> <C-e> :close<CR>
  nnoremap <silent> <buffer> <CR> :call <SID>MarkMenuOpen()<CR>
  autocmd BufWinLeave <buffer> call s:MarkMenuSave()
endfunction

function! s:MarkMenuOpen() abort
  let l:f = fnamemodify(getline('.'), ':p')
  close
  if l:f !=# '' | execute 'edit ' . fnameescape(l:f) | endif
endfunction

nnoremap <silent> <leader>a :call <SID>MarkAdd()<CR>
nnoremap <silent> <C-e> :call <SID>MarkMenu()<CR>
for s:i in range(min([s:mark_slots, len(s:mark_keys)]))
  execute 'nnoremap <silent> ' . s:mark_keys[s:i] . ' :call <SID>MarkGo(' . (s:i + 1) . ')<CR>'
endfor
command! Pin call s:MarkAdd()
command! Pins call s:MarkMenu()

" ===========================================================================
"  4b. UNDO TREE  (undotree: see and jump between undo branches)  Space u
"      Enter = go to that state, q = close. Uses vim's own undotree().
" ===========================================================================
function! s:UtWalk(entries, depth, out, seqs, cur) abort
  for l:e in a:entries
    if has_key(l:e, 'alt') | call s:UtWalk(l:e.alt, a:depth + 1, a:out, a:seqs, a:cur) | endif
    let l:sv = has_key(l:e, 'save') ? '  [saved ' . l:e.save . ']' : ''
    call add(a:out, (l:e.seq == a:cur ? '>' : ' ') . repeat('| ', a:depth) . '* '
      \ . l:e.seq . '  ' . strftime('%H:%M:%S', l:e.time) . l:sv)
    call add(a:seqs, l:e.seq)
  endfor
endfunction

function! s:UtRender() abort
  let l:me = win_getid()
  if !win_gotoid(b:ut_src) | call s:Err('source window is gone') | return | endif
  let l:ut = undotree()
  call win_gotoid(l:me)
  let l:out = [(l:ut.seq_cur == 0 ? '>' : ' ') . '* 0  (original text)']
  let l:seqs = [0]
  call s:UtWalk(l:ut.entries, 0, l:out, l:seqs, l:ut.seq_cur)
  let b:ut_seqs = l:seqs
  setlocal modifiable
  silent %delete _
  call setline(1, l:out)
  setlocal nomodifiable
  let l:at = index(l:seqs, l:ut.seq_cur)
  call cursor(l:at < 0 ? 1 : l:at + 1, 1)
endfunction

function! s:UtGo() abort
  let l:seq = b:ut_seqs[line('.') - 1]
  let l:me = win_getid()
  if !win_gotoid(b:ut_src) | return | endif
  execute 'undo ' . l:seq
  call win_gotoid(l:me)
  call s:UtRender()
endfunction

function! s:UndoTree() abort
  if &buftype !=# '' | call s:Err('open a file first') | return | endif
  if !has('persistent_undo') && !&undofile | echo 'note: history is session-only' | endif
  let l:src = win_getid()
  vertical topleft 38new
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap winfixwidth
  setlocal nonumber norelativenumber nolist colorcolumn= cursorline
  silent file cvim-undotree
  let &l:statusline = ' undo tree  Enter=go q=close'
  let b:ut_src = l:src
  nnoremap <silent> <buffer> <CR> :call <SID>UtGo()<CR>
  nnoremap <silent> <buffer> q :close<CR>
  call s:UtRender()
endfunction
nnoremap <silent> <leader>u :call <SID>UndoTree()<CR>
command! UndoTree call s:UndoTree()

" ===========================================================================
"  5. SYNTAX HELP  (what's achievable without a parser; no treesitter)
"     Calls like  foo(  get the Function color in code files, and the theme
"     hook above separates keywords, types, macros and literals.
"     :SynInfo shows which highlight group is under the cursor.
" ===========================================================================
" (no `syntax enable` here: vimrc already ran `syntax on`, and calling it again
" after a theme is set makes vim look for a colorscheme file by that name)
filetype plugin indent on

function! s:FuncMatch() abort
  if exists('w:cv_fn') | silent! call matchdelete(w:cv_fn) | unlet w:cv_fn | endif
  if &buftype ==# '' && index(s:src_ft, &filetype) >= 0
    let w:cv_fn = matchadd('CvFunc',
      \ '\<\%(\%(if\|for\|while\|switch\|return\|sizeof\|catch\|elif\|else\|and\|or\|not\|in\)\>\)\@!\h\w*\ze\s*(', 5)
  endif
endfunction

function! s:SynInfo() abort
  let l:st = synstack(line('.'), col('.'))
  let l:names = map(copy(l:st), 'synIDattr(v:val, "name")')
  echo (empty(l:names) ? 'none' : join(l:names, ' > '))
    \ . ' => ' . synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
endfunction
command! SynInfo call s:SynInfo()

augroup cvim_tools
  autocmd!
  autocmd BufWinEnter,WinEnter,FileType * call s:FuncMatch()
augroup END

" ===========================================================================
"  6. GIT  (fugitive-style: status buffer, diff, blame, log, commit)
"     Space gs status | :Gdiff :Gblame :Glog
"     In the status buffer: s stage, u unstage, = diff, cc commit,
"     dd discard changes (asks first), Enter open, q close
" ===========================================================================
function! s:GitRoot(dir) abort
  let l:r = systemlist('git -C ' . shellescape(a:dir) . ' rev-parse --show-toplevel 2>/dev/null')
  return (v:shell_error || empty(l:r)) ? '' : l:r[0]
endfunction

function! s:G(root, args) abort
  return systemlist('git -C ' . shellescape(a:root) . ' ' . a:args . ' 2>&1')
endfunction

function! s:GsPath() abort
  let l:l = getline('.')
  if line('.') == 1 || strlen(l:l) < 4 | return '' | endif
  let l:p = l:l[3:]
  if l:p =~# ' -> ' | let l:p = split(l:p, ' -> ')[-1] | endif
  return substitute(l:p, '^"\(.*\)"$', '\1', '')
endfunction

function! s:GsRender() abort
  let l:pos = line('.')
  setlocal modifiable
  silent %delete _
  call setline(1, s:G(b:git_root, 'status --short --branch'))
  setlocal nomodifiable
  call cursor(min([l:pos, line('$')]), 1)
endfunction

function! s:GsDo(args) abort
  let l:p = s:GsPath()
  if l:p ==# '' | return | endif
  let l:out = s:G(b:git_root, a:args . ' -- ' . shellescape(l:p))
  if v:shell_error | call s:Err(join(l:out, ' ')) | endif
  call s:GsRender()
endfunction

function! s:GsDiff() abort
  let l:p = s:GsPath()
  if l:p ==# '' | return | endif
  let l:staged = getline('.')[0] !~# '[ ?]'
  let l:out = s:G(b:git_root, 'diff ' . (l:staged ? '--cached ' : '') . '-- ' . shellescape(l:p))
  call s:Scratch('cvim-diff', empty(l:out) ? ['(no diff)'] : l:out, 'diff')
endfunction

function! s:GsDiscard() abort
  let l:p = s:GsPath()
  if l:p ==# '' | return | endif
  if getline('.')[1] !~# '[MD]' | echo 'only unstaged changes to tracked files can be discarded' | return | endif
  if confirm('Discard unstaged changes to ' . l:p . '?', "&Yes\n&No", 2) == 1
    call s:GsDo('checkout')
  endif
endfunction

function! s:GsOpen() abort
  let l:p = s:GsPath()
  if l:p ==# '' | return | endif
  let l:f = b:git_root . '/' . l:p
  close
  execute 'edit ' . fnameescape(l:f)
endfunction

function! s:GitCommit(root) abort
  botright 10new
  setlocal buftype=acwrite bufhidden=wipe noswapfile nobuflisted
  silent file cvim-commit
  call setline(1, ['', '# Type the message above. :w commits, :q! aborts. Lines starting # are dropped.'])
  let b:git_root = a:root
  autocmd BufWriteCmd <buffer> call s:DoCommit()
  call cursor(1, 1) | startinsert
endfunction

function! s:DoCommit() abort
  let l:msg = join(filter(getline(1, '$'), 'v:val !~# "^#"'), "\n")
  if substitute(l:msg, '\s', '', 'g') ==# '' | call s:Err('empty commit message') | return | endif
  let l:out = system('git -C ' . shellescape(b:git_root) . ' commit -F - 2>&1', l:msg . "\n")
  if v:shell_error | call s:Err(substitute(l:out, '\n', ' ', 'g')) | return | endif
  setlocal nomodified
  close
  echo split(l:out, "\n")[0]
  if bufwinnr('cvim-gitstatus') > 0
    execute bufwinnr('cvim-gitstatus') . 'wincmd w'
    call s:GsRender()
  endif
endfunction

function! s:GitStatus() abort
  let l:root = s:GitRoot(s:Dir())
  if l:root ==# '' | call s:Err('not a git repository') | return | endif
  let l:w = bufwinnr('cvim-gitstatus')
  if l:w > 0
    execute l:w . 'wincmd w'
  else
    botright 14new
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap
    setlocal nonumber norelativenumber nolist colorcolumn= cursorline
    silent file cvim-gitstatus
    let &l:statusline = ' git  s stage  u unstage  = diff  cc commit  dd discard  q close'
    nnoremap <silent> <buffer> s  :call <SID>GsDo('add')<CR>
    nnoremap <silent> <buffer> u  :call <SID>GsDo('reset -q HEAD')<CR>
    nnoremap <silent> <buffer> =  :call <SID>GsDiff()<CR>
    nnoremap <silent> <buffer> dd :call <SID>GsDiscard()<CR>
    nnoremap <silent> <buffer> cc :call <SID>GitCommit(b:git_root)<CR>
    nnoremap <silent> <buffer> <CR> :call <SID>GsOpen()<CR>
    nnoremap <silent> <buffer> q  :close<CR>
  endif
  let b:git_root = l:root
  call s:GsRender()
endfunction

" file shown side by side with the staged (else committed) version
function! s:Gdiff() abort
  let l:dir = expand('%:p:h') | let l:name = expand('%:t')
  if &buftype !=# '' || s:GitRoot(l:dir) ==# '' | call s:Err('not a tracked file in a git repo') | return | endif
  let l:old = s:G(l:dir, 'show ' . shellescape(':./' . l:name))
  if v:shell_error | let l:old = s:G(l:dir, 'show ' . shellescape('HEAD:./' . l:name)) | endif
  if v:shell_error | call s:Err('no committed version of ' . l:name) | return | endif
  let l:ft = &filetype
  diffthis
  leftabove vnew
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  call setline(1, l:old)
  let &l:filetype = l:ft
  setlocal nomodifiable
  silent file cvim-committed
  diffthis
  nnoremap <silent> <buffer> q :diffoff!<Bar>close<CR>
endfunction

function! s:Gblame() abort
  let l:dir = expand('%:p:h') | let l:name = expand('%:t')
  if &buftype !=# '' || s:GitRoot(l:dir) ==# '' | call s:Err('not a tracked file in a git repo') | return | endif
  let l:out = s:G(l:dir, 'blame --date=short -- ' . shellescape(l:name))
  if v:shell_error | call s:Err(join(l:out, ' ')) | return | endif
  let l:top = line('w0') | let l:cur = line('.')
  setlocal scrollbind cursorbind
  leftabove vnew
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nowrap nonumber norelativenumber nolist colorcolumn=
  call setline(1, map(l:out, 'substitute(v:val, ")\\s.*$", ")", "")'))
  setlocal nomodifiable scrollbind cursorbind
  execute 'vertical resize ' . (max(map(copy(l:out), 'strlen(v:val)')) + 1)
  silent file cvim-blame
  nnoremap <silent> <buffer> q :windo setlocal noscrollbind nocursorbind<Bar>close<CR>
  execute l:top | normal! zt
  execute l:cur
  syncbind
endfunction

function! s:Glog() abort
  let l:dir = expand('%:p:h') | let l:name = expand('%:t')
  if s:GitRoot(l:dir) ==# '' | call s:Err('not a git repository') | return | endif
  let l:out = s:G(l:dir, 'log --oneline --decorate -n 200' . (&buftype ==# '' && l:name !=# '' ? ' -- ' . shellescape(l:name) : ''))
  call s:Scratch('cvim-gitlog', empty(l:out) ? ['(no commits)'] : l:out, '')
endfunction

nnoremap <silent> <leader>gs :call <SID>GitStatus()<CR>
command! Gstatus call s:GitStatus()
command! Gdiff   call s:Gdiff()
command! Gblame  call s:Gblame()
command! Glog    call s:Glog()

" ===========================================================================
"  7. CODE NAVIGATION WITHOUT A LANGUAGE SERVER
"     gd definition (tags, else vim's own search) | gr references -> quickfix
"     Space vrn project-wide rename (asks first) | :Tags builds a tags file
"     Ctrl-t returns from a jump | Ctrl-n/Ctrl-p/Ctrl-y complete in insert
"     Ctrl-Space completes (omni if the filetype has it)
" ===========================================================================
set completeopt=menu,menuone,noselect
set complete=.,w,b,u,t,i

function! s:GoDef() abort
  let l:w = expand('<cword>')
  if l:w ==# '' | return | endif
  try
    execute 'tjump ' . l:w
  catch /^Vim\%((\a\+)\)\=:E\%(426\|433\|257\)/
    try
      normal! gd
    catch
      call s:Err('no definition found for ' . l:w)
    endtry
  endtry
endfunction

function! s:Refs() abort
  let l:w = expand('<cword>')
  if l:w ==# '' | return | endif
  let l:cmd = 'grep -rnIw'
  for l:s in s:find_skip
    let l:cmd .= ' --exclude-dir=' . shellescape(l:s)
  endfor
  let l:out = systemlist(l:cmd . ' -e ' . shellescape(l:w) . ' . 2>/dev/null | head -n 5000')
  if empty(l:out) | echo 'no references' | return | endif
  cgetexpr l:out
  copen
endfunction

function! s:Rename() abort
  let l:w = expand('<cword>')
  if l:w !~# '^\w\+$' | echo 'cursor is not on a plain identifier' | return | endif
  let l:to = input('rename ' . l:w . ' to: ')
  if l:to ==# '' || l:to !~# '^\w\+$' | echo ' cancelled (new name must be one word)' | return | endif
  call s:Refs()
  if getqflist() == [] | return | endif
  if confirm(len(getqflist()) . ' places in ' . len(uniq(sort(map(getqflist(), 'bufnr(v:val.bufnr)')))) . ' files. Rename?', "&Yes\n&No", 2) != 1
    return
  endif
  execute 'cfdo %s/\<' . l:w . '\>/' . l:to . '/ge | update'
endfunction

" universal-ctags / exuberant-ctags needed for -R (macOS's BSD ctags lacks it)
function! s:Tags() abort
  if !executable('ctags') | call s:Err('ctags not installed') | return | endif
  if system('ctags --version 2>&1') !~# 'Universal\|Exuberant'
    call s:Err('this ctags cannot recurse (BSD ctags). Install universal-ctags, or use gr/gd fallbacks.')
    return
  endif
  let l:f = s:CacheDir() . '/tags-' . substitute(getcwd(), '[^A-Za-z0-9]', '_', 'g')[-120:]
  call system('ctags -R -f ' . shellescape(l:f) . ' ' . join(map(copy(s:find_skip), '"--exclude=" . shellescape(v:val)'), ' ') . ' . 2>&1')
  if v:shell_error | call s:Err('ctags failed') | return | endif
  let &tags = './tags,tags,' . substitute(l:f, '[ ,]', '\\&', 'g')
  echo 'tags written: ' . fnamemodify(l:f, ':~')
endfunction

nnoremap <silent> gd :call <SID>GoDef()<CR>
nnoremap <silent> gr :call <SID>Refs()<CR>
nnoremap <silent> <leader>vrn :call <SID>Rename()<CR>
inoremap <expr> <C-Space> (&omnifunc ==# '' ? "\<C-n>" : "\<C-x>\<C-o>")
inoremap <expr> <Nul>     (&omnifunc ==# '' ? "\<C-n>" : "\<C-x>\<C-o>")
command! Tags call s:Tags()

" ===========================================================================
"  :btt  back to terminal, in the netrw directory
"    Vim cannot change its parent shell's directory, so this writes the path
"    to ~/.cache/compliant-vim/cwd and suspends vim (like Ctrl-z). The shell
"    hook in bashrc.sh (or the zsh line in README) cds there at the next
"    prompt. Type  fg  to come back to the same vim session.
" ===========================================================================
function! s:BackToTerm() abort
  let l:d = exists('b:netrw_curdir') ? b:netrw_curdir : s:Dir()
  if !isdirectory(l:d) | return s:Err('btt: not a directory: ' . l:d) | endif
  call writefile([fnamemodify(l:d, ':p')], s:CacheDir() . '/cwd')
  echo 'btt: ' . fnamemodify(l:d, ':~')
  suspend
endfunction
command! BTT call s:BackToTerm()
cnoreabbrev <expr> btt (getcmdtype() ==# ':' && getcmdline() ==# 'btt') ? 'BTT' : 'btt'

" ===========================================================================
"  :Keys  cheat sheet (leader = Space)
" ===========================================================================
function! s:Keys() abort
  call s:Scratch('cvim-keys', [
    \ 'SETTINGS   4-space indent, nowrap, relative numbers, persistent undo, scrolloff 8',
    \ '',
    \ 'FILES      Space pv       file explorer (netrw)',
    \ '           :btt           suspend vim, shell cds to netrw dir (fg returns)',
    \ '           Ctrl-p         fuzzy: git files        Space pf  fuzzy: all files',
    \ '           Space ps       grep prompt -> quickfix (Ctrl-k/Ctrl-j next/prev, Space k/j for loclist)',
    \ '           :Ff :Gf :Gr    same, as commands',
    \ '           in picker      type, Ctrl-n/p or Up/Down, Enter open, Esc cancel',
    \ '',
    \ 'PINS        Space a        pin this file           Ctrl-e   edit pin list',
    \ '           Space 1..4     jump to pinned file     :Pin :Pins',
    \ '',
    \ 'UNDO        Space u        undo tree (Enter go to state, q close)',
    \ '',
    \ 'GIT         Space gs       status: s stage, u unstage, = diff, cc commit, dd discard, Enter open',
    \ '           :Gdiff :Gblame :Glog',
    \ '',
    \ 'CODE        gd definition  gr references   Space vrn rename everywhere (asks first)',
    \ '           :Tags build tags (universal-ctags)   Ctrl-t jump back',
    \ '           insert: Ctrl-n/p choose, Ctrl-y accept, Ctrl-Space complete',
    \ '           :SynInfo       highlight group under cursor',
    \ '',
    \ 'EDITING     J/K (visual)   move selected lines     J  join, cursor stays',
    \ '           Ctrl-d/u, n/N  keep cursor centered     Space p (visual) paste, keep register',
    \ '           Space y/Y      yank to system clipboard Space d  delete to black hole',
    \ '           Space s        replace word in file     Space x  chmod +x this file',
    \ '           Ctrl-c         = Esc in insert          Q        disabled',
    \ '           Space R        re-source this file',
    \ ], '')
endfunction
command! Keys call s:Keys()
