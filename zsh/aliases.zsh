alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

alias ls='eza --icons --group-directories-first'
alias l='eza -lahb --icons --git --group-directories-first'
alias lt='eza --tree --level=2 --icons --group-directories-first'

alias reload='source ~/.zshrc'
alias treload='tmux source-file ~/.tmux.conf'

alias v=nvim
alias lg='lazygit'

alias 2fa='~/.scripts/2fa'
alias 2fa-add='~/.scripts/2fa-add'

alias gp='git push'

alias d=docker
alias dc=docker-compose

alias cat="bat --color=always"
alias top=btop
alias c=clear

# tmux
alias tl='tmux list-sessions'
alias tn='tmux new-session -s'
alias tk='tmux kill-session -t'
alias ta='tmux attach-session -t'
