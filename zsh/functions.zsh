nb-feat() { git checkout -b "feature/$1"; }
nb-fix()  { git checkout -b "hotfix/$1"; }

ts() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null \
    | fzf --prompt="session: " --print-query --expect=enter \
    | tail -1)
  [ -z "$session" ] && return
  if ! tmux has-session -t "$session" 2>/dev/null; then
    tmux new-session -ds "$session"
  fi
  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
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
