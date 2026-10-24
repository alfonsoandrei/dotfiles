nb-feat() { git checkout -b "feature/$1"; }
nb-fix()  { git checkout -b "hotfix/$1"; }

function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# mdfried -w fails on a bare file name, so pass the full path.
unalias md 2>/dev/null
md() { mdfried -w "${1:a}"; }

# File clipboard: fcopy and fcut mark files, fpaste copies or moves them into the current dir.
# The marks live in a file, so a paste works from any shell.
FCLIP="${XDG_STATE_HOME:-$HOME/.local/state}/fclip"

_fclip_mark() {
  local mode=$1 f
  shift
  if (( ! $# )); then
    echo "usage: f$mode <file>..." >&2
    return 1
  fi
  for f in "$@"; do
    if [[ ! -e $f && ! -L $f ]]; then
      echo "f$mode: $f: no such file" >&2
      return 1
    fi
  done
  mkdir -p "${FCLIP:h}"
  print -rl -- "$mode" "${@:a}" > "$FCLIP"
  echo "$mode: $# item(s)"
}

fcopy() { _fclip_mark copy "$@"; }
fcut()  { _fclip_mark cut "$@"; }

fpaste() {
  if [[ ! -s $FCLIP ]]; then
    echo "fpaste: clipboard is empty" >&2
    return 1
  fi
  local -a lines=("${(@f)$(<$FCLIP)}")
  local mode=$lines[1]
  local -a files=("${(@)lines[2,-1]}")
  if [[ $mode == cut ]]; then
    mv -i -- "${files[@]}" .
    # mv -i exits 0 after a declined overwrite, so keep the files that did not move.
    local f
    local -a left=()
    for f in "${files[@]}"; do
      [[ -e $f || -L $f ]] && left+=("$f")
    done
    rm -f -- "$FCLIP"
    if (( ${#left} )); then
      _fclip_mark cut "${left[@]}"
    fi
  else
    cp -Ri -- "${files[@]}" .
  fi
}

fk() { ps aux | fzf --header-lines=1 | awk '{print $2}' | xargs kill -9; }

pk() {
  if [ -z "$1" ]; then
    local pid=$(lsof -i -P -n | grep LISTEN | fzf --header "Select process to kill" --header-lines=1 | awk '{print $2}')
    [ -n "$pid" ] && kill -9 "$pid" && echo "Killed PID $pid"
  else
    local pid=$(lsof -t -i :"$1")
    [ -n "$pid" ] && kill -9 "$pid" && echo "Killed port $1 (PID $pid)" || echo "No process on port $1"
  fi
}

tunnel() {
  ssh -R 80:localhost:$1 localhost.run
}

unalias gb 2>/dev/null
gb() { git branch --all | fzf --preview 'git log --oneline -20 {}' | sed 's|remotes/origin/||' | xargs git checkout; }

_wt_list() {
  local git_dir
  for git_dir in ~/Documents/git/*/.git(N/); do
    git -C "${git_dir:h}" worktree prune
    git -C "${git_dir:h}" worktree list
  done
}

wt() {
  local dir
  dir=$(_wt_list | fzf --prompt="worktree: " --preview 'git -C {1} log --oneline -10' | awk '{print $1}')
  [ -n "$dir" ] && cd "$dir"
}

# `git worktree remove` refuses a tree with changes, so nothing unsaved is lost.
wt-rm() {
  local dir main
  _wt_list | rg '/\.claude/worktrees/|/tmp/' \
    | fzf --multi --prompt="remove worktree: " --preview 'git -C {1} status --short' \
    | awk '{print $1}' \
    | while read -r dir; do
        main=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir)
        git -C "${main:h}" worktree remove "$dir" && echo "removed $dir"
      done
}
