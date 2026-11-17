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
