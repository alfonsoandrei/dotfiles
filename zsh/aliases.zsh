alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# LS_COLORS overrides eza's theme.yml, so clear it for eza only.
alias ls='LS_COLORS= eza --icons --group-directories-first'
alias l='LS_COLORS= eza -lahb --icons --git --group-directories-first'
alias lt='LS_COLORS= eza -lahb --tree --level=2 --icons --group-directories-first --ignore-glob "node_modules"'

alias reload='source ~/.zshrc'
alias treload='tmux source-file ~/.tmux.conf'

alias v='NVIM_APPNAME=nvim-lite nvim'
alias lg='NVIM_APPNAME=nvim-lite lazygit'

alias 2fa='~/.scripts/2fa'
alias 2fa-add='~/.scripts/2fa-add'

alias gp='git push'

alias d=docker
alias dc=docker-compose

# alias cat="bat --color=always"
alias top=btop
alias c=clear

# tmux
alias tl='tmux list-sessions'
alias tn='tmux new-session -s'
alias tk='tmux kill-session -t'
alias ta='tmux attach-session -t'
