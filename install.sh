#!/usr/bin/env bash
# compliant-vim installer. Run from any directory, as often as you like
# (for example after every `git pull`).
#
#   ./install.sh               ~/.vimrc <- vimrc + tools.vim,  ~/.bashrc <- bashrc.sh
#                              ~/.zshrc <- zshrc.sh (only if zsh is your shell or ~/.zshrc exists)
#   ./install.sh --all         also:      ~/.tmux.conf <- tmux.conf
#   ./install.sh --no-tools    leave out tools.vim (colors only)
#   ./install.sh --uninstall   remove the managed blocks from those files
#   ./install.sh --dry-run     show what would change, write nothing
#
# How it works: the repo's files are copied into a marked block inside each
# target. Everything outside the block is left alone. Running again replaces
# the block with the current repo content. If a target changes, the old
# version is saved next to it as <file>.bak. No network, no sudo.

set -u

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd) || exit 1
DEST=${HOME:?HOME is not set}

all=0; tools=1; uninstall=0; dry=0
for a in "$@"; do
  case $a in
    --all)       all=1 ;;
    --no-tools)  tools=0 ;;
    --uninstall) uninstall=1 ;;
    --dry-run)   dry=1 ;;
    -h|--help)   sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $a (try --help)" >&2; exit 2 ;;
  esac
done

# install_block TARGET COMMENT_PREFIX SOURCE_FILE...
install_block() {
  local target=$1 c=$2; shift 2
  local begin="$c >>> compliant-vim >>> managed by install.sh: edits inside this block are overwritten"
  local end="$c <<< compliant-vim <<<"
  local tmp f
  tmp=$(mktemp "${TMPDIR:-/tmp}/cvim.XXXXXX") || return 1

  # existing file minus any previous block
  if [ -f "$target" ]; then
    awk -v b="$begin" -v e="$end" '
      $0 == b { skip = 1; next }
      $0 == e { skip = 0; next }
      !skip   { print }' "$target" > "$tmp"
    # drop trailing blank lines left behind by a removed block
    while [ -s "$tmp" ] && [ -z "$(tail -n 1 "$tmp")" ]; do
      sed '$d' "$tmp" > "$tmp.2" && mv "$tmp.2" "$tmp"
    done
  fi

  if [ "$uninstall" -eq 0 ]; then
    for f in "$@"; do
      [ -f "$f" ] || { echo "missing source file: $f" >&2; rm -f "$tmp"; return 1; }
    done
    { [ -s "$tmp" ] && echo
      echo "$begin"
      for f in "$@"; do cat "$f"; echo; done
      echo "$end"; } >> "$tmp"
  fi

  if [ -f "$target" ] && cmp -s "$tmp" "$target"; then
    echo "unchanged  $target"
  elif [ "$dry" -eq 1 ]; then
    echo "would update $target"
  else
    [ -f "$target" ] && cp "$target" "$target.bak"
    cat "$tmp" > "$target"          # cat, not mv: keeps symlinks and permissions
    echo "$([ "$uninstall" -eq 1 ] && echo removed || echo updated)    $target"
  fi
  rm -f "$tmp"
}

vim_files=("$REPO/vimrc")
[ "$tools" -eq 1 ] && vim_files+=("$REPO/tools.vim")

install_block "$DEST/.vimrc"   '"' "${vim_files[@]}" || exit 1
install_block "$DEST/.bashrc"  '#' "$REPO/bashrc.sh" || exit 1
if [ -f "$DEST/.zshrc" ] || [ "${SHELL##*/}" = zsh ]; then
  install_block "$DEST/.zshrc"   '#' "$REPO/zshrc.sh" || exit 1
fi
if [ "$all" -eq 1 ]; then
  install_block "$DEST/.tmux.conf" '#' "$REPO/tmux.conf" || exit 1
fi

if [ "$uninstall" -eq 0 ] && [ "$dry" -eq 0 ]; then
  echo
  echo "done. Open a new vim and type :Keys."
  echo "shell: run  source ~/.bashrc  (bash)  or  source ~/.zshrc  (zsh)"
  [ "$all" -eq 1 ] && echo "tmux: tmux source-file ~/.tmux.conf"
fi
