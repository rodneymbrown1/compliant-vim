# compliant-vim zsh hook: :btt in vim leaves a directory in
# ~/.cache/compliant-vim/cwd; cd to it at the next prompt, once.
_cv_btt() {
  local f=~/.cache/compliant-vim/cwd d
  [[ -f $f ]] || return 0
  d=$(<"$f"); rm -f "$f"
  [[ -d $d ]] && cd "$d"
}
precmd_functions=(${precmd_functions:#_cv_btt} _cv_btt)
