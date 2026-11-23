# compliant-vim

Offline, dependency-free Vim + Bash + tmux setup, built to be **copy-pasted**
into locked-down environments. A personal project. Nothing here is cloned,
downloaded, or installed.

| File | Paste into | Lines |
|---|---|---|
| `vimrc` | `~/.vimrc` | ~510 |
| `bashrc.sh` | end of `~/.bashrc` | ~390 |
| `tmux.conf` | `~/.tmux.conf` | ~70 |

Three files, no directories, no plugin manager. Works on Vim 8+ and bash 3.2+.
Needs a 256-color terminal (`echo $TERM` should say `xterm-256color` or similar).

## Install (about two minutes)

    # 1. paste each file's contents into the destination above, then:
    source ~/.bashrc
    tmux source-file ~/.tmux.conf     # only if tmux is already running
    # 2. open vim. Type :Keys for the cheat sheet.

## `:btt` (back to terminal)

In netrw, `:btt` suspends vim and your shell `cd`s to the directory you were browsing. Type `fg` to return to the same vim. Bash gets the hook from `bashrc.sh`. For zsh, add this to `~/.zshrc`:

    _cv_btt() { local f=~/.cache/compliant-vim/cwd; [[ -f $f ]] || return; local d=$(<$f); rm -f $f; [[ -d $d ]] && cd $d }
    precmd_functions+=(_cv_btt)

## For the security reviewer

Every file opens with a banner stating what it does and does not do. To verify
independently:

    # network / eval / privilege / package manager / scripting-language hooks
    grep -nE '\b(curl|wget|ssh|scp|nc|telnet|ftp|sudo|eval|pip|npm|apt|yum)\b|https?://|\bsystem\(|:python|:lua|:ruby|:perl|run-shell' vimrc bashrc.sh tmux.conf

Expected hits: only banner comments, tmux reloading its own config, and three
`systemlist(` calls in `vimrc` (`find`, `grep`, and `clang-format` if installed).

* **Colors are cosmetic.** They are ANSI escape codes and standard variables
  (`LS_COLORS`, `GREP_COLORS`, `LESS_TERMCAP_*`, `GCC_COLORS`) that control how
  this terminal window paints text. They change nothing on the system.
* **No network, no downloads, no `eval`, no `source` of other files, no sudo,
  no background processes, no traps.**
* **Files created:** `~/.vim/swap/` (mode 0700), `~/.cache/compliant-vim/`
  (mode 0700, only after first use of `ff`/`ft`/`mk`). Both can be deleted any time.
* **Hardening that Vim and tmux get by default here:** `nomodeline`, `noexrc`,
  `secure`; yanked text is never written to `~/.viminfo`; tmux clipboard
  escape codes are off.
* The shell prompt reads `.git/HEAD` directly (no `git` process) and
  whitelists the branch name, because a branch named `$(cmd)` would otherwise
  be executed by the prompt. Tested.

## Themes

`night` (default, cool dark) · `warm` · `frost` · `hc` (**high contrast**: pure
black, saturated colors, inverted status bar, built for low vision) · `paper`
(light, high contrast). Original palettes inspired by the general feel of
popular schemes; no third-party scheme code.

| Where | How |
|---|---|
| Vim | `F5` next, `F6` previous, `:Theme hc` |
| Shell + ls/grep/less/man + tmux bar | `theme hc` |
| Make it permanent | Put `CVIM_THEME=hc` above the `source` line, or at the top of `bashrc.sh`. Vim reads that variable at startup, so one setting themes both |

Vim paints its own background. The shell can't, so `theme` prints the hex
background to set in your terminal profile for the shell to match.

## Your workflow list, answered

**Previously visited files.** `Space Space` flips to the last file.
`Space b` lists open buffers most-recent-first and takes a number.
`Space o` lists recently opened files across sessions. `]b` / `[b` cycle.
`hidden` is set, so switching never forces a save.

**Find / grep, then open.**
In the shell, `ff name` and `ft text` print **numbered** hits with the match
highlighted, then ask `open #`. Type `3` to open here at that line, or `3t` to
open in a **new terminal tab** (a directory result opens in netrw). `o 3` /
`o 3t` re-open from the last search. Inside Vim, `Space f` / `Space g` fill the
quickfix list; **mouse click or Enter** jumps. `Space *` greps the word under
the cursor. Plain terminal text can't be clicked by a shell script; this
numbered prompt is the offline equivalent, and Vim's quickfix window is the
real click target.

**New tab at the current location.**
tmux: `prefix c` (bound to keep your directory) and splits do the same.
Plain terminal: `nt` opens a tab here (works in tmux, iTerm2, Terminal.app,
gnome-terminal, konsole, xfce4-terminal). The prompt also announces the
directory (OSC 7), so `Ctrl-Shift-T` in VTE-based terminals and Cmd-T in
iTerm2/Terminal.app usually open in the same place with no command at all.

**Build output you can read.** `mk make -j8` (or `mk cmake --build build`):
errors get a reverse-video **ERROR** label (not color alone) with the whole line
bold red, warnings a **WARNING** label in yellow, notes cyan, `file:line:col`
bold white, caret lines green, `In function…`/`required from` magenta, and the
`[ 42%] Building…` and compiler-command noise is dimmed. A summary line reports counts, the
exit status is the real one, and a bell rings if the build took 10+ seconds
(lights up that tmux tab). `qf` then opens vim with every error as a jump
target (`]q` / `[q`). From inside Vim, `Space m` runs `:make` and `:LastBuild`
loads the log. For always-on, add `alias make='mk make'` to your bashrc.

**C++ formatting.** `Space =` / `:Fmt` runs `clang-format` if installed
(honouring your `.clang-format`), else Vim's built-in `cindent`. Tabs show as
`>---` and trailing whitespace is highlighted, so mixed-indent problems are
visible. Indent width and tabs/spaces are knobs at the top of `vimrc`.
Nothing auto-formats on save, so you won't pollute diffs.

**Swap files.** Not strictly necessary: they exist for crash recovery and
for warning you when two Vim sessions edit one file. `:split` of the same file
shares one buffer and one swap file; what you likely saw was the `.swp` sitting
*beside* the source in netrw. Default here: swap files go to `~/.vim/swap/`
(0700), so nothing appears in project directories, and crash recovery is
kept. Prefer none? Set `s:swap_mode = 'off'` at the top of `vimrc`. netrw also
hides `.swp` by default (`gh` toggles).

## Tested / not tested

Tested here (Vim 9.1, bash 3.2, tmux 3.x, macOS): vimrc loads with no errors, all five themes
apply, `:Ff`, `:Gr`, `:Fmt` (cindent path), `:Trim`, `:Keys`, buffer picker,
swap redirect and permissions; bash syntax, prompt, branch-name injection
guard, `ff`, `ft`, `o`, `mk` (colors, exit code, log, Vim parses the log); tmux
config loads and `theme` re-colors a live tmux bar.

**Not tested:** Vim 8 itself (only 9.1 was available; I avoided Vim 9-only
features and wrapped the few optional ones in `silent!`), the `clang-format`
path (not installed here), and the GUI branches of `nt` (iTerm2, Terminal.app,
gnome-terminal, konsole). Treat those as best-effort and report what breaks.

## Optional: `tools.vim` (editing tools)

A second, separate file: paste it **below** `vimrc` in `~/.vimrc`. Unlike the
three files above it *does* change key mappings and runs `find`, `grep`, `git`,
`ctags`, `chmod` when you ask (all arguments `shellescape()`d). Fuzzy picker,
pinned files, undo tree, git status/diff/blame, tags navigation, and the
remaps from the "Neovim RC From Scratch" video. Targets Vim 8.0+. Type `:Keys`.
Audit it with:

    grep -nE 'system\(|systemlist\(' tools.vim

Files it creates: `~/.vim/undo/`, `~/.cache/compliant-vim/` (mode 0700).
See `ROADMAP.md` for what was built and what was left out. Note: the sections
above this one describe features (`ff`, `ft`, `mk`, `Space b/o`) that are no
longer in the trimmed files.

## tools.vim reference

`<leader>` is Space. Everything below is defined in `tools.vim`; nothing in it
runs at startup except settings and mapping definitions.

### Settings

| Setting | Value |
|---|---|
| Indent | 4 spaces, spaces not tabs (`tabstop`, `softtabstop`, `shiftwidth` = 4, `expandtab`, `smartindent`) |
| Wrapping | off (`nowrap`) |
| Buffers | `hidden` on, so you can switch buffers with unsaved changes |
| Backups and swap | `nobackup`, `nowritebackup`, `noswapfile` |
| Undo | `undofile` on, stored in `~/.vim/undo` (created 0700), so undo history survives closing Vim |
| Search | `incsearch` on, `nohlsearch` |
| Scrolling | `scrolloff=8`: the cursor stays at least 8 lines from the top/bottom edge |
| `updatetime` | 50 ms |
| Sign column | always shown |
| Completion | `completeopt=menu,menuone,noselect`, `complete=.,w,b,u,t,i` |
| `isfname` | adds `@` and `-` so `gf` works on more paths |
| Leader | Space |

### Knobs (top of the file)

| Name | Default | Effect |
|---|---|---|
| `s:transparent` | 0 | 1 removes the background color so the terminal's own background shows |
| `s:block_cursor` | 0 | 1 keeps a block cursor in insert mode (vimrc's bar cursor otherwise) |
| `s:mark_slots` | 4 | number of pinned-file slots |
| `s:mark_keys` | `<leader>1`..`4` | keys that jump to pinned slots |
| `s:find_skip` | `.git node_modules build dist target .cache` | directories ignored by file finding, grep, references, tags |
| `s:src_ft` | c, cpp, java, javascript, typescript, rust, go, python, sh, lua, cs, php, swift, kotlin, scala | filetypes where `name(` is highlighted as a function |

### Key mappings

| Keys | Mode | Action |
|---|---|---|
| `J` / `K` | visual | move the selected lines down / up and re-indent them |
| `J` | normal | join the next line to this one; cursor stays where it was |
| `Ctrl-d` / `Ctrl-u` | normal | half-page down / up, then center the cursor line |
| `n` / `N` | normal | next / previous search match, centered, folds opened |
| `Space p` | visual | replace the selection with the unnamed register without overwriting that register |
| `Space y`, `Space Y` | normal, visual | yank to the system clipboard (`"+`); if this Vim has no clipboard support, yank to the unnamed register |
| `Space d` | normal, visual | delete into the black-hole register (nothing is saved to any register) |
| `Ctrl-c` | insert | same as Esc |
| `Q` | normal | does nothing (Ex mode is disabled) |
| `Ctrl-k` / `Ctrl-j` | normal | quickfix list: next / previous entry, centered |
| `Space k` / `Space j` | normal | location list: next / previous entry, centered |
| `Space s` | normal | start a whole-file `:%s` replacing the word under the cursor; you type the replacement |
| `Space x` | normal | `chmod +x` on the current file (must be saved to disk) |
| `Space pv` | normal | open netrw, the built-in file explorer |
| `Space R` | normal | re-source `tools.vim` |

### Fuzzy picker

Finds files by typing letters that appear in the path in order (`rdme` matches
`README.md`). Opens as a 12-line split at the bottom.

| Keys / command | Action |
|---|---|
| `Ctrl-p`, `:Gf` | pick from `git ls-files` (tracked plus untracked-not-ignored); outside a repo, behaves like `:Ff` |
| `Space pf`, `:Ff` | pick from all files under the current directory (`find`, skipping `s:find_skip`, max 100,000 files) |
| `Space ps`, `:Gr [text]` | prompt for text, run `grep -rnI` from the current directory, put matches in the quickfix list and open it (max 5,000 lines) |

In the picker: type to filter; Backspace deletes a character; `Ctrl-u` clears the
query; `Ctrl-n`, Down, `Ctrl-j` move down; `Ctrl-p`, Up, `Ctrl-k` move up; Enter
opens the highlighted file; Esc or `Ctrl-c` cancels.

Ranking: every typed letter must appear in order. Higher score for letters that
are adjacent, letters that start a path segment or word, and the query appearing
inside the file name; ties go to the shorter path. At most 200 results are
shown. File lists are cached for 30 seconds per directory.

### Pinned files

A short list of files per project (per current directory), stored in
`~/.cache/compliant-vim/marks-<directory>`.

| Keys / command | Action |
|---|---|
| `Space a`, `:Pin` | add the current file to the list (refuses duplicates or a full list) |
| `Ctrl-e`, `:Pins` | open the list as an editable buffer; press again to close |
| `Space 1`..`4` | open the file in that slot |

In the list buffer: edit, reorder or delete lines freely; Enter opens the file
on that line; `q` or `Ctrl-e` closes. The list is saved when the buffer closes,
with duplicates and blank lines removed.

### Undo tree

`Space u` or `:UndoTree` opens a 38-column split listing every undo state of
the current file as `* <number>  <time>`. Branches (made by undoing, then
editing) are drawn indented with `|`. `>` marks the current state; `[saved N]`
marks a write. Enter jumps to the state under the cursor (`:undo N`); `q`
closes. State 0 is the original text. History persists across sessions
because of `undofile`.

### Git

Requires `git`. All commands run `git -C <repo>` on the file's repository.

| Keys / command | Action |
|---|---|
| `Space gs`, `:Gstatus` | bottom split showing `git status --short --branch` |
| in status: `s` | `git add` the file on the cursor line |
| in status: `u` | `git reset -q HEAD` for that file (unstage) |
| in status: `=` | show that file's diff (staged diff if it is staged) in a split |
| in status: `cc` | open a commit-message buffer; `:w` runs `git commit -F -`, `:q!` aborts; lines starting `#` are dropped; empty messages are refused |
| in status: `dd` | `git checkout --` the file after a Yes/No prompt; only for unstaged changes to tracked files |
| in status: Enter | open the file |
| in status: `q` | close |
| `:Gdiff` | split showing the staged (else last-committed) version of the current file, side by side in diff mode; `q` in the left window ends diff mode |
| `:Gblame` | scroll-locked left column of `git blame --date=short` for the current file; `q` closes |
| `:Glog` | scratch buffer of `git log --oneline --decorate` (200 max) for the current file, or the whole repo if the buffer is not a file |

### Syntax

| Item | Behavior |
|---|---|
| `filetype plugin indent on`, `syntax enable` | turned on |
| Theme hook | after every `:Theme`, assigns separate colors/bold to Conditional, Repeat, Exception, Keyword, Label, Structure, StorageClass, Typedef, Define, Include, Macro, SpecialChar, Tag from the active theme's palette |
| Function calls | in the filetypes in `s:src_ft`, a word directly followed by `(` is colored as a function, except `if for while switch return sizeof catch elif else and or not in` |
| `:SynInfo` | prints the syntax group stack under the cursor and the group its color comes from |

This is regex-based highlighting. It does not parse code and has no syntax tree.

### Code navigation (no language server)

| Keys / command | Action |
|---|---|
| `gd` | `:tjump` to the tag for the word under the cursor; if there are no tags, falls back to Vim's built-in `gd` |
| `gr` | `grep -rnIw` for the word under the cursor, results in the quickfix list |
| `Space vrn` | prompt for a new name, list all whole-word matches in quickfix, ask Yes/No, then substitute in every matching file and save them; only works when the cursor is on a plain identifier and the new name is one word |
| `:Tags` | run `ctags -R` on the current directory into `~/.cache/compliant-vim/tags-<directory>` and add it to `tags`; needs universal-ctags or exuberant-ctags (BSD ctags is detected and refused) |
| `Ctrl-t` | Vim built-in: jump back after `gd` |
| insert: `Ctrl-n` / `Ctrl-p` | Vim built-in: next / previous completion candidate |
| insert: `Ctrl-y` | Vim built-in: accept the highlighted candidate |
| insert: `Ctrl-Space` | start completion: omni completion if the filetype has it, else keyword completion |

### Other commands

| Command | Action |
|---|---|
| `:Keys` | show a key cheat sheet in a split |

### External programs and files

Programs called, only when you use the matching feature: `find`, `grep`, `git`,
`ctags`, `chmod`. Files created: `~/.vim/undo/`, `~/.cache/compliant-vim/`
(pin lists, tags). No network access, no background processes, no plugins.
