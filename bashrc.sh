################################################################################
#  COMPLIANT-VIM  |  bashrc.sh  |  ONE FILE  |  OFFLINE  |  PURE BASH
#
#  WHAT THIS FILE IS
#    A prompt, terminal colors, and a few shell helper functions.
#    Append it to the END of ~/.bashrc (or save it and `source` it).
#
#  THE COLORS ARE COSMETIC ONLY
#    Every color below is an ANSI escape sequence or an environment variable
#    that tells ls / grep / less / gcc how to PAINT text in this one terminal
#    window. They change nothing on the system, in any file, or in any other
#    program or user's session. Open a new shell without this file and
#    everything is back to normal.
#
#  WHAT THIS FILE DOES NOT DO   (security reviewers: grep to confirm)
#    - NO network access. No curl, wget, ssh, nc, git clone, package installs.
#    - NO eval, NO sourcing of other files, NO downloaded code, NO sudo.
#    - NO changes to PATH, no new executables, no aliases that replace a
#      command's behavior (only color flags on ls/grep).
#    - NO background processes, NO traps, NO cron, NO startup hooks.
#
#  EXTERNAL PROGRAMS IT MAY RUN (local, standard; each only when YOU call
#  the matching function)
#    find grep awk sed sort head   ff / ft / mk
#    vim                           o / qf
#    tmux                          nt / theme (only when already inside tmux)
#    osascript | gnome-terminal | konsole | xfce4-terminal   nt (new tab)
#    ls                            once at load, to detect --color support
#
#  FILES IT MAY CREATE
#    ~/.cache/compliant-vim/   (mode 0700, created only when you first run
#                               ff / ft / mk). Holds: last search results and
#                               the last build log. Delete it any time.
#
#  Type  cvhelp  for the cheat sheet.     Type  theme  to see/switch themes.
################################################################################

[[ $- == *i* ]] || return 0      # interactive shells only

_cv_dir=${XDG_CACHE_HOME:-$HOME/.cache}/compliant-vim
: "${CVIM_THEME:=night}"         # night | warm | frost | hc | paper | mono
: "${CVIM_OSC7:=1}"              # 1 = tell the terminal our cwd so NEW TABS open here
: "${CVIM_MAX:=200}"             # max results listed by ff / ft

# ------------------------------------------------------------------ palettes
# 256-color numbers. (Vim themes in the vimrc use the same names.)
_cv_palette() {
  C_USER= C_HOST= C_PATH= C_GIT= C_OK= C_ERR= C_DIR= C_LN= C_ACC= C_ACCFG= C_DIM= C_TMBG= C_TMFG= C_BG=
  case $1 in
    night) C_USER=111 C_HOST=141 C_PATH=114 C_GIT=215 C_OK=114 C_ERR=203 C_DIR=111 C_LN=80  C_ACC=111 C_ACCFG=16  C_DIM=245 C_TMBG=235 C_TMFG=250 C_BG='#16181f' ;;
    warm)  C_USER=214 C_HOST=175 C_PATH=143 C_GIT=108 C_OK=143 C_ERR=167 C_DIR=214 C_LN=109 C_ACC=214 C_ACCFG=16  C_DIM=245 C_TMBG=237 C_TMFG=223 C_BG='#1e1b18' ;;
    frost) C_USER=110 C_HOST=139 C_PATH=109 C_GIT=180 C_OK=151 C_ERR=174 C_DIR=110 C_LN=116 C_ACC=110 C_ACCFG=16  C_DIM=245 C_TMBG=236 C_TMFG=253 C_BG='#232834' ;;
    hc)    C_USER=226 C_HOST=51  C_PATH=231 C_GIT=213 C_OK=46  C_ERR=196 C_DIR=51  C_LN=213 C_ACC=226 C_ACCFG=16  C_DIM=248 C_TMBG=16  C_TMFG=231 C_BG='#000000' ;;
    paper) C_USER=25  C_HOST=90  C_PATH=22  C_GIT=130 C_OK=22  C_ERR=124 C_DIR=25  C_LN=30  C_ACC=25  C_ACCFG=231 C_DIM=240 C_TMBG=254 C_TMFG=235 C_BG='#fbf8ef' ;;
    mono)  ;;
    *) return 1 ;;
  esac
}

# Build every color-bearing variable from the current palette.
_cv_apply() {
  local e=$'\e'
  if [ "$CVIM_THEME" = mono ]; then
    _CV_R= _CV_U= _CV_H= _CV_P= _CV_G= _CV_E= _CV_OK=
    _CV_X_NUM= _CV_X_FILE= _CV_X_R=
    LS_COLORS='rs=0' GREP_COLORS='ms=01:mc=01:sl=:cx=:fn=:ln=:bn=:se='
    unset LESS_TERMCAP_md LESS_TERMCAP_us LESS_TERMCAP_so LESS_TERMCAP_me LESS_TERMCAP_ue LESS_TERMCAP_se
  else
    # prompt-form (\[ \] mark zero-width text for readline)
    _CV_R='\[\e[0m\]'
    _CV_U='\[\e[1;38;5;'$C_USER'm\]'
    _CV_H='\[\e[1;38;5;'$C_HOST'm\]'
    [ -n "${SSH_CONNECTION:-}" ] && _CV_H='\[\e[1;7;38;5;'$C_HOST'm\]'   # reverse video = you are REMOTE
    _CV_P='\[\e[1;38;5;'$C_PATH'm\]'
    _CV_G='\[\e[38;5;'$C_GIT'm\]'
    _CV_E='\[\e[1;38;5;'$C_ERR'm\]'
    _CV_OK='\[\e[1;38;5;'$C_OK'm\]'
    # raw-form (for printf in ff / ft / mk)
    _CV_X_NUM=$e'[1;38;5;'$C_ACC'm'
    _CV_X_FILE=$e'[38;5;'$C_USER'm'
    _CV_X_R=$e'[0m'
    local d="1;38;5;$C_DIR" x="38;5;$C_DIM"
    export LS_COLORS="di=$d:ln=38;5;$C_LN:so=38;5;$C_GIT:pi=38;5;$C_GIT:ex=1;38;5;$C_OK:bd=38;5;$C_GIT:cd=38;5;$C_GIT:su=1;38;5;$C_ERR:sg=1;38;5;$C_ERR:tw=$d:ow=$d:st=$d:or=1;38;5;$C_ERR:mi=1;38;5;$C_ERR:*.o=$x:*.a=$x:*.so=$x:*.d=$x:*.swp=$x"
    export GREP_COLORS="ms=1;38;5;$C_ACCFG;48;5;$C_ACC:mc=1;38;5;$C_ACCFG;48;5;$C_ACC:sl=:cx=:fn=1;38;5;$C_USER:ln=38;5;$C_GIT:bn=:se=38;5;$C_DIM"
    # man pages / less: bold -> accent, underline -> green, search -> highlighted
    export LESS_TERMCAP_md=$e'[1;38;5;'$C_ACC'm'
    export LESS_TERMCAP_us=$e'[4;38;5;'$C_OK'm'
    export LESS_TERMCAP_so=$e'[1;38;5;'$C_ACCFG';48;5;'$C_ACC'm'
    export LESS_TERMCAP_me=$e'[0m' LESS_TERMCAP_ue=$e'[0m' LESS_TERMCAP_se=$e'[0m'
    export MANROFFOPT=-c
  fi
  export LS_COLORS GREP_COLORS
  export LSCOLORS=GxfxcxdxCxegedabagacad               # BSD/macOS ls
  export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
  : "${LESS:=-R -i -M}"; export LESS
  # live tmux status colors, only if we are inside tmux
  if [ -n "${TMUX:-}" ] && [ "$CVIM_THEME" != mono ] && command -v tmux >/dev/null 2>&1; then
    tmux set -g status-style "bg=colour$C_TMBG,fg=colour$C_TMFG" \; \
         set -g window-status-current-style "bg=colour$C_ACC,fg=colour$C_ACCFG,bold" \; \
         set -g pane-active-border-style "fg=colour$C_ACC" \; \
         set -g message-style "bg=colour$C_ACC,fg=colour$C_ACCFG,bold" >/dev/null 2>&1
  fi
}

# theme            list themes     |     theme warm      switch now (this shell,
# new vim sessions started from it, and the tmux status bar if inside tmux)
theme() {
  if [ -z "${1:-}" ]; then
    echo "themes: night warm frost hc paper mono     current: $CVIM_THEME"
    echo "usage : theme NAME      (put  CVIM_THEME=NAME  above the source line to make it permanent)"
    return 0
  fi
  _cv_palette "$1" || { echo "unknown theme: $1   (night warm frost hc paper mono)"; return 1; }
  CVIM_THEME=$1; export CVIM_THEME
  _cv_apply
  [ -n "$C_BG" ] && echo "theme $1. For best results set your terminal profile background to $C_BG"
  return 0
}

# ---------------------------------------------------------------- the prompt
#   user@host:dir (git-branch) [exit N]
#   $
# Branch is read straight from .git/HEAD: no `git` process, no slowdown.
# The branch name is whitelisted before use, because a branch called  $(cmd)
# would otherwise be executed by the prompt.
_cv_prompt() {
  local rc=$? d=$PWD h br= gp= rp= pc=$_CV_OK p
  while [ -n "$d" ]; do
    if [ -f "$d/.git/HEAD" ]; then
      read -r h < "$d/.git/HEAD"
      case $h in
        'ref: refs/heads/'*) br=${h#ref: refs/heads/} ;;
        *) br="detached:${h:0:7}" ;;
      esac
      br=${br//[^[:alnum:]._\/+:-]/_}
      break
    fi
    d=${d%/*}
  done
  [ -n "$br" ] && gp=" ${_CV_G}(${br})${_CV_R}"
  if [ $rc -ne 0 ]; then rp=" ${_CV_E}[exit ${rc}]${_CV_R}"; pc=$_CV_E; fi
  PS1='\[\e]0;\u@\h: \w\a\]'"${_CV_U}"'\u'"${_CV_R}@${_CV_H}"'\h'"${_CV_R}:${_CV_P}"'\w'"${_CV_R}${gp}${rp}"'\n'"${pc}"'\$'"${_CV_R} "
  if [ "$CVIM_OSC7" = 1 ] && [ "$TERM" != linux ] && [ "$TERM" != dumb ]; then
    p=${PWD//[![:print:]]/?}; p=${p// /%20}
    printf '\e]7;file://%s%s\a' "${HOSTNAME:-}" "$p"
  fi
}

# ------------------------------------------------------- new terminal tab here
# nt                 new tab, same directory
# nt vim file.cpp    new tab, same directory, running that command
nt() {
  local cmd= sh
  [ $# -gt 0 ] && cmd=$(printf '%q ' "$@")
  if [ -n "${TMUX:-}" ]; then                        # tmux: new window here
    if [ -n "$cmd" ]; then tmux new-window -c "$PWD" "$cmd"; else tmux new-window -c "$PWD"; fi
    return
  fi
  if [ "$(uname -s)" = Darwin ]; then
    sh="cd $(printf '%q' "$PWD")${cmd:+ && $cmd}"
    sh=${sh//\\/\\\\}; sh=${sh//\"/\\\"}
    case ${TERM_PROGRAM:-} in
      iTerm.app)
        osascript <<EOF
tell application "iTerm2"
  tell current window
    create tab with default profile
    tell current session to write text "$sh"
  end tell
end tell
EOF
        ;;
      *)  # Terminal.app: needs a one-time Accessibility OK for the keystroke
        osascript <<EOF
tell application "Terminal" to activate
tell application "System Events" to keystroke "t" using command down
delay 0.3
tell application "Terminal" to do script "$sh" in front window
EOF
        ;;
    esac
    return
  fi
  if command -v gnome-terminal >/dev/null 2>&1; then
    if [ -n "$cmd" ]; then gnome-terminal --tab --working-directory="$PWD" -- bash -c "$cmd"
    else gnome-terminal --tab --working-directory="$PWD"; fi
  elif command -v konsole >/dev/null 2>&1; then
    if [ -n "$cmd" ]; then konsole --new-tab --workdir "$PWD" -e bash -c "$cmd"
    else konsole --new-tab --workdir "$PWD"; fi
  elif command -v xfce4-terminal >/dev/null 2>&1; then
    if [ -n "$cmd" ]; then xfce4-terminal --tab --working-directory="$PWD" -x bash -c "$cmd"
    else xfce4-terminal --tab --working-directory="$PWD"; fi
  else
    echo "nt: no supported terminal found. Inside tmux use prefix+c; most terminals: Ctrl-Shift-T."
    return 1
  fi
}

# ----------------------------------------------- find / grep with numbered hits
_cv_init() { [ -d "$_cv_dir" ] || (umask 077; mkdir -p "$_cv_dir") || return 1; }

_cv_ask() {   # offer to open a result right away (only on a real terminal)
  local ans
  if [ -t 0 ] && [ -t 1 ]; then
    printf 'open # (N = here, Nt = new tab, Enter = skip): '
    read -r ans
    [ -n "$ans" ] && o "$ans"
  fi
}

# ff NAME [DIR]    find files/dirs whose NAME contains text (case-insensitive)
ff() {
  [ -n "${1:-}" ] || { echo 'usage: ff NAME [DIR]    e.g.  ff parser'; return 2; }
  _cv_init || return 1
  local pat=$1 dir=${2:-.} n=0 f abs esc
  local -a D=()
  : > "$_cv_dir/results"; : > "$_cv_dir/results.txt"
  while IFS= read -r f; do
    [ "$f" = "$dir" ] && continue
    case $f in /*) abs=$f ;; *) abs=$PWD/${f#./} ;; esac
    n=$((n+1)); D[$n]=$f
    [ -d "$f" ] && f=$f/
    printf '%s\t\n' "$abs" >> "$_cv_dir/results"
    printf '%s\n' "$f" >> "$_cv_dir/results.txt"
  done < <(find "$dir" \( -name .git -o -name .svn -o -name .hg -o -name node_modules \) -prune -o -iname "*$pat*" -print 2>/dev/null | sort | head -n "$CVIM_MAX")
  [ $n -gt 0 ] || { echo "no files match: $pat"; return 1; }
  esc=$(printf '%s' "$pat" | sed 's/[][\.*^$]/\\&/g')
  local i=0 line
  while IFS= read -r line; do
    i=$((i+1))
    printf '%s%3d%s  %s\n' "$_CV_X_NUM" "$i" "$_CV_X_R" "$line"
  done < <(grep --color=always -i -e "$esc" -e '^' "$_cv_dir/results.txt")
  [ $n -ge "$CVIM_MAX" ] && echo "(showing first $CVIM_MAX; narrow the name or raise CVIM_MAX)"
  _cv_ask
}

# ft TEXT [DIR]    search inside files (plain grep syntax; smartcase)
ft() {
  [ -n "${1:-}" ] || { echo 'usage: ft TEXT [DIR]    e.g.  ft "ParseHeader("'; return 2; }
  _cv_init || return 1
  local pat=$1 dir=${2:-.} ic=-i n=0 line f l t abs
  local -a D=()
  case $pat in *[A-Z]*) ic= ;; esac
  : > "$_cv_dir/results"; : > "$_cv_dir/results.txt"
  while IFS= read -r line; do
    f=${line%%:*}; t=${line#*:}; l=${t%%:*}; t=${t#*:}
    case $l in ''|*[!0-9]*) continue ;; esac
    case $f in /*) abs=$f ;; *) abs=$PWD/${f#./} ;; esac
    t=${t#"${t%%[![:space:]]*}"}; t=${t:0:200}
    n=$((n+1)); D[$n]="${f#./}:$l"
    printf '%s\t%s\n' "$abs" "$l" >> "$_cv_dir/results"
    printf '%s\n' "$t" >> "$_cv_dir/results.txt"
    [ $n -ge "$CVIM_MAX" ] && break
  done < <(grep -rnIH $ic --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --exclude-dir=node_modules --exclude=tags -e "$pat" "$dir" 2>/dev/null)
  [ $n -gt 0 ] || { echo "no matches: $pat"; return 1; }
  local i=0 ctext
  while IFS= read -r ctext; do
    i=$((i+1))
    printf '%s%3d%s  %s%s%s  %s\n' "$_CV_X_NUM" "$i" "$_CV_X_R" "$_CV_X_FILE" "${D[$i]}" "$_CV_X_R" "$ctext"
  done < <(grep --color=always $ic -e "$pat" -e '^' "$_cv_dir/results.txt")
  [ $n -ge "$CVIM_MAX" ] && echo "(showing first $CVIM_MAX; narrow the search or raise CVIM_MAX)"
  _cv_ask
}

# o N     open result N from the last ff/ft in vim (a directory opens in netrw)
# o Nt    same, but in a NEW terminal tab at this location
o() {
  local arg=${1:-} n tab=0 row f l
  case $arg in *t) tab=1; n=${arg%t} ;; *) n=$arg ;; esac
  case $n in ''|*[!0-9]*) echo 'usage: o N   |   o Nt   (numbers come from ff / ft)'; return 2 ;; esac
  row=$(sed -n "${n}p" "$_cv_dir/results" 2>/dev/null)
  [ -n "$row" ] || { echo "no result number $n (run ff or ft first)"; return 1; }
  f=${row%%$'\t'*}; l=${row#*$'\t'}
  if [ -d "$f" ] || [ -z "$l" ]; then set -- vim "$f"; else set -- vim "+$l" "$f"; fi
  if [ $tab = 1 ]; then nt "$@"; else "$@"; fi
}

# ------------------------------------------------ builds you can actually read
# mk make -j8          run any build; errors/warnings pop, noise fades
# mk cmake --build build
# Exit status is the build's own status. A copy of the output is saved so
# `qf` can open the errors in vim (jump to each one).
_cv_awk() {
  awk -v lf="$1" '
  BEGIN {
    ESC = sprintf("%c", 27); R = ESC "[0m"
    ERV = ESC "[1;97;41m"; RED = ESC "[1;91m"
    YRV = ESC "[1;30;103m"; YEL = ESC "[93m"
    CYN = ESC "[96m"; GRN = ESC "[1;92m"; MAG = ESC "[95m"; DIM = ESC "[90m"; LOC = ESC "[1;97m"
    ansi = ESC "\\[[0-9;?]*[A-Za-z]"
  }
  {
    line = $0
    gsub(ansi, "", line)
    if (lf != "") print line > lf
    out = line
    if (match(line, /^[^ \t:][^ \t]*:[0-9]+(:[0-9]+)?:/)) {
      loc = substr(line, 1, RLENGTH); rest = substr(line, RLENGTH + 1)
      if (rest ~ /^[ \t]*(fatal )?error/) { nerr++; sub(/error/, ERV " ERROR " R RED, rest); out = LOC loc R RED rest R }
      else if (rest ~ /\*\*\*/)           { nerr++; out = LOC loc R RED rest R }
      else if (rest ~ /^[ \t]*warning/)   { nwarn++; sub(/warning/, YRV " WARNING " R YEL, rest); out = LOC loc R YEL rest R }
      else if (rest ~ /^[ \t]*note/)      { out = LOC loc R CYN rest R }
      else if (rest ~ /required from|in expansion of|in instantiation/) { out = LOC loc R MAG rest R }
      else                                { out = LOC loc R rest }
    }
    else if (line ~ /error:|undefined reference|ld returned|collect2:|^make(\[[0-9]+\])?: \*\*\*|Error [0-9]+$|FAILED|Segmentation fault|core dumped|Assertion .* failed|terminate called|multiple definition|cannot find -l|No such file or directory|No rule to make target|fatal:|(^|\/)ld: /) {
      if (line ~ /error:|undefined reference|multiple definition|FAILED/) nerr++
      out = ERV " ERROR " R " " RED line R
    }
    else if (line ~ /warning:|Warning:|WARNING/) { nwarn++; out = YEL line R }
    else if (line ~ /: In (function|member function|constructor|destructor|instantiation|static member)|^In (file included|member function|function|constructor|destructor)|At global scope|^[ \t]+(required|inlined) from|^[ \t]+from [^ ]+:[0-9]+/) { out = MAG line R }
    else if (line ~ /^[ \t]*([0-9]*[ \t]*\|)?[ \t]*[~^][~^ ]*$/) { out = GRN line R }
    else if (line ~ /\[ +OK +\]|\[ +PASSED +\]|tests passed|^PASS|Build succeeded|BUILD SUCCESSFUL/) { out = GRN line R }
    else if (line ~ /^\[ *[0-9]+%\]|^make(\[[0-9]+\])?: (Entering|Leaving)|^[ \t]*(\/[^ ]*\/)?(g\+\+|gcc|c\+\+|cc|clang|clang\+\+|ar|ranlib|ld)[ \t]/) { out = DIM line R }
    print out
    fflush()
  }
  END {
    if (nerr > 0)       printf "%s %d error(s), %d warning(s) %s\n", ERV, nerr, nwarn + 0, R
    else if (nwarn > 0) printf "%s %d warning(s), no errors %s\n", YRV, nwarn, R
  }'
}

mk() {
  [ $# -gt 0 ] || { echo 'usage: mk COMMAND...    e.g.  mk make -j8   |   mk cmake --build build'; return 2; }
  if [ ! -t 1 ]; then "$@"; return; fi              # piped/redirected: do not touch output
  _cv_init || return 1
  local log=$_cv_dir/build.log rc dt t0=$SECONDS
  "$@" 2>&1 | _cv_awk "$log"
  rc=${PIPESTATUS[0]}
  dt=$((SECONDS - t0))
  if [ $rc -eq 0 ]; then printf '\e[1;92m[mk] ok\e[0m in %ss\n' "$dt"
  else printf '\e[1;91m[mk] FAILED (exit %s)\e[0m in %ss   ->  type  qf  to jump through the errors in vim\n' "$rc" "$dt"; fi
  [ $dt -ge 10 ] && printf '\a'                      # bell: lights the tmux tab when a long build ends
  return $rc
}

# qf   open the last `mk` build's errors in vim's quickfix list
qf() {
  [ -s "$_cv_dir/build.log" ] || { echo 'no build log yet: run  mk make  first'; return 1; }
  vim -q "$_cv_dir/build.log" -c 'cwindow'
}

# ----------------------------------------------------- small quality of life
if ls --color=auto -d / >/dev/null 2>&1; then alias ls='ls --color=auto'
else alias ls='ls -G'; export CLICOLOR=1; fi
alias grep='grep --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'
alias ..='cd ..'
alias ...='cd ../..'
alias v='vim'
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

HISTSIZE=50000 HISTFILESIZE=50000 HISTCONTROL=ignoreboth:erasedups
shopt -s histappend checkwinsize cdspell 2>/dev/null
PROMPT_DIRTRIM=3
# type a few letters, press Up: cycles only through history starting with them
bind '"\e[A": history-search-backward' 2>/dev/null
bind '"\e[B": history-search-forward' 2>/dev/null
bind 'set completion-ignore-case on' 2>/dev/null
bind 'set show-all-if-ambiguous on' 2>/dev/null
bind 'set colored-stats on' 2>/dev/null

cvhelp() {
  cat <<'EOF'
COMPLIANT-VIM shell commands
  theme [name]     list / switch color theme (night warm frost hc paper mono)
  ff NAME [DIR]    find files + dirs by name, numbered     -> type N to open in vim
  ft TEXT [DIR]    search inside files, numbered           -> type N to open at that line
                   at the prompt:  3 = open here    3t = open in a new terminal tab
  o N | o Nt       reopen result N of the last ff/ft (here / new tab)
  nt [cmd...]      new terminal tab (tmux window) in this directory
  mk make -j8      build with errors/warnings highlighted; log saved
  qf               open last build's errors in vim (jump with :cnext / :cprev)
  mkcd DIR         mkdir -p + cd        v = vim     ll / la = listings
  Up / Down        history search by what you already typed
EOF
}

# ----------------------------------------------------------------- activate
_cv_palette "$CVIM_THEME" || { CVIM_THEME=night; _cv_palette night; }
export CVIM_THEME
_cv_apply
case ";${PROMPT_COMMAND:-};" in
  *";_cv_prompt;"*) ;;
  *) PROMPT_COMMAND="_cv_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
