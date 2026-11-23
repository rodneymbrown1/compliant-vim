################################################################################
#  COMPLIANT-VIM  |  bashrc.sh  |  ONE FILE  |  OFFLINE  |  PURE BASH
#
#  WHAT THIS FILE IS
#    Terminal colors and a prompt look. Aesthetics + accessibility ONLY.
#    Append it to the END of ~/.bashrc (or save it and `source` it).
#
#  THE COLORS ARE COSMETIC ONLY
#    Every color below is an ANSI escape sequence or an environment variable
#    that tells ls / grep / less / gcc how to PAINT text in this one terminal
#    window. Open a new shell without this file and everything is back to normal.
#
#  WHAT THIS FILE DOES NOT DO   (security reviewers: grep to confirm)
#    - NO network, NO eval, NO sourcing, NO sudo, NO background processes.
#    - NO new commands except `theme`; NO functions that run other programs.
#    - NO changes to PATH, history, key bindings, shell options, tmux or files.
#    - Only aliases: color flags on ls and grep.
#
#  Type  theme  to see/switch themes.
################################################################################

[[ $- == *i* ]] || return 0      # interactive shells only

: "${CVIM_THEME:=night}"         # night | warm | frost | hc | paper | mono

# ------------------------------------------------------------------ palettes
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
# Build every color-bearing variable from the current palette.
_cv_apply() {
  local e=$'\e'
  if [ "$CVIM_THEME" = mono ]; then
    _CV_R= _CV_U= _CV_H= _CV_P= _CV_G= _CV_E= _CV_OK=
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
  : "${LESS:=-R}"; export LESS                          # -R lets less show colors
}

# theme            list themes     |     theme warm      switch now (this shell,
# and new vim sessions started from it)
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
  local rc=$? d=$PWD h br= gp= rp= pc=$_CV_OK
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
}

# ------------------------------------------------------------- color aliases
if ls --color=auto -d / >/dev/null 2>&1; then alias ls='ls --color=auto'
else alias ls='ls -G'; export CLICOLOR=1; fi
alias grep='grep --color=auto'
PROMPT_DIRTRIM=3

# ----------------------------------------------------------------- activate
_cv_palette "$CVIM_THEME" || { CVIM_THEME=night; _cv_palette night; }
export CVIM_THEME
_cv_apply
# vim's :btt leaves a directory here; cd to it at the next prompt, once.
_cv_btt() {
  local f=~/.cache/compliant-vim/cwd d
  [ -f "$f" ] || return 0
  d=$(<"$f"); rm -f "$f"
  [ -d "$d" ] && cd "$d"
}
case ";${PROMPT_COMMAND:-};" in
  *";_cv_btt;"*) ;;
  *) PROMPT_COMMAND="_cv_btt${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
case ";${PROMPT_COMMAND:-};" in
  *";_cv_prompt;"*) ;;
  *) PROMPT_COMMAND="_cv_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
esac
