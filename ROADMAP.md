# Roadmap: "Neovim RC From Scratch" tools → compliant-vim

Source: ThePrimeagen, *0 to LSP: Neovim RC From Scratch* (transcript in `context.txt`).

Constraints (from README): offline, no plugin manager, no downloads, no `eval`,
no network, no `:python`/`:lua`, pasteable into `~/.vimrc`, works on Vim 8+.
Every plugin below is open source, so each is **re-implemented from scratch in
plain Vimscript** (behavior replicated, no code copied). Target: Vim 8.1+; use
`has()` guards and `silent!` for anything newer.

## Status (Vim 8.0 target, decided)

Implemented in the new optional file `tools.vim` (paste below `vimrc`). `vimrc`
keeps its "colors only" banner; its only change is a one-line theme hook.

| Milestone | State | Notes |
|---|---|---|
| M1 settings, leader, transparent knob | Done | `s:transparent` knob at top of `tools.vim` |
| M2 remaps | Done | `:Keys` lists them |
| M3 fuzzy finder | Done | Own subsequence scorer (no `matchfuzzy` in 8.0). In-memory 30 s cache instead of a disk cache |
| M4 pins + undo tree | Done | Pins default to `Space 1-4` (Ctrl-h/t/n/s clash with terminal keys). Undo tree has no diff preview |
| M5 syntax | Done (scoped) | Theme hook separates groups, `foo(` colored in code files, `:SynInfo`. No AST, by design |
| M6 git | Done | Status buffer, `:Gdiff :Gblame :Glog`. `:Glog` opens a scratch buffer, not quickfix |
| M7 tags/completion | Done | `:Tags` needs universal/exuberant ctags; the macOS BSD `ctags` is detected and refused. `gd` falls back to Vim's own `gd` |
| M8 LSP client | Not started | Would break the "no background processes" rule; separate file if ever |
| M9 tmux sessions | Not started | `bashrc.sh` and `tmux.conf` promise "colors only"; needs your call on relaxing that |

Tested headless on Vim 9.1 (macOS). **Not tested on a real Vim 8.0 binary**; the code
avoids newer features (no `matchfuzzy`, popups, `trim()`, list-form `system()`),
but `:cfdo` (used by rename) should be confirmed on 8.0.

## 1. Inventory: everything in the video

| # | Tool in video | What it does | Compliant-vim answer | Feasible offline? |
|---|---|---|---|---|
| 1 | `init.lua` + `lua/<name>/` module layout | Config entry point, requireable modules | Not needed. Single pasteable `vimrc`, sectioned by banner comments | Done (by design) |
| 2 | `vim.g.mapleader = " "` | Space leader | `let mapleader = " "` | Yes |
| 3 | netrw remap `<leader>pv` → `:Ex` | Open file explorer | Built-in netrw; add `<leader>pv` | Yes |
| 4 | **packer.nvim** | Plugin manager | **Intentionally dropped.** Nothing to manage | N/A |
| 5 | **telescope.nvim** | Fuzzy finder: git files (`C-p`), all files (`<leader>pf`), live grep (`<leader>ps`) | `:Ff` / `:Gr` / git-files finder with a command-line fuzzy picker (see M3) | Yes |
| 6 | **rose-pine** colorscheme + transparent `Normal`/`NormalFloat` | Theme, no background | Five themes already exist. Add a `transparent` knob (M1) | Yes |
| 7 | **nvim-treesitter** (+ playground) | Incremental parsing: highlighting, indent, AST view | **Not replicable in full.** Substitute: regex syntax + tuned `syntax` groups + `indentexpr`/`cindent` (M5) | Partial |
| 8 | **harpoon** | Pin up to N files, jump with `C-h/t/n/s`, quick menu | Pinned-file list: `<leader>a`, `C-e` menu, 4 jump keys (M4) | Yes |
| 9 | **undotree** | Visualize undo branches | Use built-in `:undolist` + `g-`/`g+` + `:earlier`/`:later`; build a small tree viewer buffer (M4) | Yes |
| 10 | **vim-fugitive** (`:Git`) | Git status/commit/diff in editor | `<leader>gs` status buffer with stage/unstage/commit/diff via `system('git …')` (M6) | Yes (needs `git`) |
| 11 | **lsp-zero + nvim-lspconfig + Mason + nvim-cmp** (tsserver, eslint, lua-ls, rust-analyzer) | Language servers, completion, go-to-def, rename, diagnostics, auto-install | **Not replicable offline in full.** Substitute: `ctags`, built-in `omnifunc`/`complete`, `:vimgrep` references, `gd`-style jumps (M7). Optional: speak LSP over `job_start` if a server is already installed (M8) | Partial |
| 12 | **nvim-cmp keymaps** (`C-p`/`C-n`, `C-y`, `C-Space`) | Completion menu keys | Built-in `ins-completion` with matching keys | Yes |
| 13 | **Mason** | Server installer | **Dropped** (network/package manager) | No |
| 14 | `set` block (relnum, 4-space, no wrap, undofile, incsearch, scrolloff, etc.) | Editor defaults | Straight port (M1) | Yes |
| 15 | Fat cursor (`guicursor=""`) | Block cursor in insert | Terminal cursor-shape escapes, opt-in (M1) | Yes |
| 16 | Remaps: visual `J`/`K` move lines | Move selection with reindent | Port (M2) | Yes |
| 17 | Remaps: `J` keeps cursor | `mzJ\`z` | Port (M2) | Yes |
| 18 | Remaps: `C-d`/`C-u` + `zz`; `n`/`N` + `zzzv` | Centered scrolling/search | Port (M2) | Yes |
| 19 | `<leader>p` (paste over selection, keep register) | `"_dP` | Port (M2) | Yes |
| 20 | `<leader>y` / `<leader>Y` system clipboard | `"+y` | Port, plus `has('clipboard')` fallback (M2) | Yes |
| 21 | `<leader>d` delete to void | `"_d` | Port (M2) | Yes |
| 22 | `C-c` = `Esc` | Exit visual-block cleanly | Port (M2) | Yes |
| 23 | `Q` → `<nop>` | Disable Ex mode | Port (M2) | Yes |
| 24 | `C-f` → tmux-sessionizer | Switch project via tmux | Shell function `sess` in `bashrc.sh` + tmux bind (M9) | Yes |
| 25 | `C-k/j`, `<leader>k/j` quickfix/loclist nav | Quickfix navigation | Port; `]q`/`[q` style (M2) | Yes |
| 26 | `<leader>s` rename word under cursor | `:%s/\<word\>/word/gI` prompt | Port (M2) | Yes |
| 27 | `<leader>x` `chmod +x %` | Make file executable | Port via `system('chmod +x')` (M2) | Yes |
| 28 | `:so %` / `:so` re-source | Reload config | `<leader><leader>` is already "last file" in README; use `<leader>R` for reload (M1) | Yes |

Out of scope by definition: packer, Mason, tree-sitter parser downloads, and
automatic LSP server install (all require network or a package manager).

## 2. Milestones

Ordered by value per line of code. Each milestone is independently shippable and
keeps the file pasteable. Use the existing `grep` security check from the README
after every milestone; the only new "expected hits" should be `systemlist(`/`system(`
calls for `find`, `grep`, `git`, `ctags`, `chmod`.

### M1: Editor settings and leader (small, ~30 lines)
- `mapleader`, `<leader>pv` → `:Ex`, `<leader>R` → re-source `$MYVIMRC`.
- `set`: `nowrap`, `tabstop/shiftwidth/softtabstop=4`, `expandtab`, `smartindent`,
  `noswapfile nobackup`, `undofile` + `undodir=~/.vim/undo` (0700, created like swap dir),
  `incsearch nohlsearch`, `scrolloff=8`, `signcolumn=yes`, `updatetime=50`, `isfname+=@-@`.
- `colorcolumn` already exists.
- New knob `s:transparent` (default 0): after `s:Apply`, set `Normal`/`NormalFloat`/
  `SignColumn` background to `NONE`. Maps to the video's transparent-background step.
- Optional `s:block_cursor` knob using `t_SI/t_SR/t_EI` escapes.
- **Done when:** `vim -u vimrc` loads clean; `:set undofile?` is on; undo survives restart.

### M2: The "best remaps" pack (~40 lines)
All ports are one-liners in `nnoremap`/`xnoremap`:
`J`/`K` visual move (`:m '>+1<CR>gv=gv`), `J` cursor-stay, `C-d`/`C-u` + `zz`,
`n`/`N` + `zzzv`, `<leader>p` (`"_dP`), `<leader>y/Y`, `<leader>d`, `C-c`→`Esc`,
`Q`→`<nop>`, `<leader>s` rename, `<leader>x` chmod, quickfix/loclist nav
(`C-k`, `C-j`, `<leader>k`, `<leader>j`).
- Check collisions with existing README bindings (`Space Space`, `Space b/o/f/g/m/=/*`).
  The video's `<leader>pf`, `<leader>ps` do not collide; `<leader>y` and `<leader>d` are free.
- Add every new key to the `:Keys` cheat sheet in the same commit.
- **Done when:** each key manually verified in a scratch buffer; `:Keys` lists them.

### M3: Fuzzy finder (replaces telescope) (~120 lines)
Telescope's three behaviors, rebuilt on what exists (`:Ff`, `:Gr`, `find`, `grep`):
1. `C-p` git files: `git ls-files` (falls back to `find` when not in a repo).
2. `<leader>pf` all files: existing `find`, excluding `.git`, `node_modules`, build dirs.
3. `<leader>ps` project grep with an `input()` prompt → quickfix.
4. **Fuzzy matching:** Vim 8.1+ has `matchfuzzy()` / `matchfuzzypos()`. Implement a
   prompt loop (`getchar()` in a `while`) that filters the cached file list on every
   keystroke and shows results in a scratch window; Enter opens, `C-n`/`C-p` move, Esc exits.
   Fallback for older Vim: substring/subsequence filter written in Vimscript.
5. Cache the file list in `~/.cache/compliant-vim/` (already used by `ff`).
- **Done when:** typing `rdme` finds `README.md`; works in a 50k-file tree without lag
  (list cached, filter capped at ~200 visible rows).

### M4: Navigation and history (harpoon + undotree) (~150 lines)
**Harpoon clone** (`:Mark`, `:Marks`):
- List of up to 4–9 absolute paths stored in `~/.cache/compliant-vim/marks-<hash of cwd>`.
- `<leader>a` add current file; `C-e` toggles an editable scratch buffer showing the list
  (reorder/delete lines, `:w` or leaving the buffer saves it); `C-h/t/n/s` jump to slot 1–4
  (note: `C-h`/`C-n` conflict with defaults; make the slot keys a knob and document it).
- Persist per project (cwd), not globally.

**Undo tree viewer** (`<leader>u`):
- Parse `undotree()` (built-in, returns the full structure in `entries`/`alt`) and render an
  ASCII tree in a left vertical split, one line per `seq` with time and save marker.
- `<CR>` runs `:undo N`; `p` previews the diff against current text; `q` closes.
- Uses the `undofile` from M1, so history is persistent.
- **Done when:** make an edit, undo, make a different edit, and the viewer shows two
  branches and `<CR>` on the older branch restores its text.

### M5: Syntax and indent (treesitter substitute) (~100 lines, scoped)
Treesitter cannot be reproduced from scratch in a pasteable vimrc (it needs a
C runtime plus compiled grammars). Realistic goal: **the visible win, richer colors**.
- Extend each theme with distinct groups for functions, types, constants, operators,
  parameters, and comments, linked from Vim's built-in `syntax` groups (`Function`, `Type`,
  `Constant`, `Special`, `PreProc`, `Identifier`, …). The video's "only strings are colored"
  problem is a theme-coverage problem, not necessarily a parser problem.
- Turn on `syntax enable`, `filetype plugin indent on`; add `cindent` options tuned for C++
  (already a use case in the README).
- Add small `matchadd()` rules for things stock syntax files miss (function-call names:
  `\w\+\ze(`; numbers; TODO/FIXME).
- A tiny `:SynInfo` command (show highlight group under cursor via `synstack()`/`synIDattr()`)
  as the offline stand-in for TS Playground.
- **Explicitly not doing:** AST, incremental parsing, text objects from the tree.
- **Done when:** a C++ and a shell file show ≥6 distinct colors in every theme, and `hc`
  stays high-contrast.

### M6: Git integration (fugitive substitute) (~120 lines)
- `<leader>gs`: scratch buffer from `git status --short --branch`.
  Keys in it: `s` stage, `u` unstage, `=` inline diff, `cc` commit (opens a message buffer;
  `:w` commits via `git commit -F`), `dd` discard (with confirm), `q` close, `<CR>` open file.
- `:Gdiff` (vertical split against `git show :%`), `:Gblame` (`git blame` in a scrollbound split),
  `:Glog` (quickfix of `git log --oneline -- %`).
- Always shell out with `shellescape()`; never build commands from unescaped buffer text.
  Prompt reads `.git/HEAD` directly today for safety; keep that approach for the statusline
  and use `git` only on explicit commands.
- **Done when:** stage a hunk-less file, commit, and see it in `git log`, all without leaving Vim.

### M7: Code navigation and completion without LSP (~100 lines)
What a language server gives, and the offline equivalent:

| LSP feature | Substitute |
|---|---|
| go to definition (`gd`) | `ctags` (`:tag`, `C-]`) if installed; else `:vimgrep` for `\<word\>` definition patterns by filetype |
| references | `<leader>*` grep already exists; add quickfix of whole-word matches |
| rename | M2 `<leader>s` (project-wide variant: `:cdo s//…/ | update` over quickfix) |
| completion | `omnifunc` / `complete=.,w,b,u,t,i` with `C-p`/`C-n`/`C-y`, `completeopt=menu,menuone,noselect` |
| hover/signature | `K` → `man`/`keywordprg` (built in) |
| diagnostics | `:make` + quickfix (already the `mk`/`qf` workflow), `errorformat` per filetype |
| format | existing `:Fmt` (clang-format or cindent) |

- `:Tags` command: run `ctags -R` (only if present) into the cache dir, set `tags=` accordingly.
- Remaps from the video: `gd`, `gr`, `<leader>vrn`, `[d`/`]d` mapped to the above.
- **Done when:** in a C++ project with ctags installed, `gd` lands on the definition and `C-t` returns.

### M8 (stretch): Minimal LSP client over `job_start`
Only if a language server binary is **already installed on the target machine**
(clangd, rust-analyzer, typescript-language-server, etc.).
- Needs Vim 8.1+ with `+job` and `+channel`, plus a JSON-RPC framer (`Content-Length:` headers
  over `ch_open`/`job_start` in `raw` mode) and `json_encode`/`json_decode`.
- Scope: `initialize`, `textDocument/didOpen|didChange|didSave`, `definition`, `hover`,
  `publishDiagnostics` → loclist, `completion` → `completefunc`.
- **Security note:** this is the first feature that spawns a long-running process. It
  violates the README's "no background processes" line, so keep it **off by default**, behind
  an explicit `:LspStart` command, in a separate clearly-labeled section, and document the new
  exception in the README banner.
- ~400+ lines; likely better as an optional second file (`lsp.vim`) than part of the main paste.

### M9: tmux / shell parity
- `sess` function in `bashrc.sh`: list directories under a configurable root list, pick one
  with a numbered prompt (same style as `ff`), `tmux new-session -A -s <name> -c <dir>`.
- `tmux.conf`: `bind -r f run-shell …` (or `bind f` with `display-popup`/`command-prompt`)
  calling `sess`; `C-a L` equivalent to `switch-client -l` (previous session).
- Vim-side: `C-f` mapping that shells out to `tmux` only when `$TMUX` is set.
- No network; only touches tmux sessions.

## 3. Suggested order and size

| Order | Milestone | Approx. lines | Risk |
|---|---|---|---|
| 1 | M1 settings + leader + transparent | 30 | Low |
| 2 | M2 remaps | 40 | Low (check key collisions) |
| 3 | M3 fuzzy finder | 120 | Medium (UI loop, perf) |
| 4 | M4 marks + undo tree | 150 | Medium |
| 5 | M6 git | 120 | Medium (shell-escaping) |
| 6 | M5 syntax/theme coverage | 100 | Low-medium (theme work × 5) |
| 7 | M7 tags/completion | 100 | Low |
| 8 | M9 tmux sessions | 40 | Low |
| 9 | M8 LSP client | 400+ | High, optional, separate file |

Total for M1–M7 + M9 ≈ 600 lines, which would take `vimrc` from ~250 to ~850 lines.
That's past the README's "paste in two minutes" ethos. Recommend splitting once it
passes ~600 lines: keep `vimrc` as the core (M1, M2, M5, M7) and ship the
heavier pieces (M3, M4, M6) as optional paste-in sections with their own banners.

## 4. Cross-cutting rules for every milestone
1. Banner comment states what the section does and does not do.
2. No `system()` with unescaped input. Use `shellescape()` and list-form `systemlist([...])` where Vim 8.1+ allows.
3. New files only under `~/.vim/` or `~/.cache/compliant-vim/`, mode 0700.
4. Guard anything newer than Vim 8.0 with `has('patch-…')`/`exists('*fn')`.
5. Update `:Keys`, the README table, and the "expected hits" security grep in the same change.
6. Test on Vim 9.1 (available here) and, if possible, a Vim 8.x binary before claiming 8 support.

## 5. Open questions
- Is **Vim 8.2+** safe to assume on the target machines? (`matchfuzzy` needs 8.1.2114+; popup windows need 8.2.)
- Is `git` always present? (M3/M6 degrade gracefully either way.)
- Is `ctags` present on the target machines? (Determines how good M7 is.)
- Are you OK with a second optional file for M3/M4/M6/M8, or must everything stay in three files?
