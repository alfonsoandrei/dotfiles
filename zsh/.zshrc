# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="zsh2000-node"

# Which plugins would you like to load?
plugins=(git fzf zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

############################
# FZF
############################
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"

# Interactive git branch switching (unalias gb from git plugin, then redefine)
unalias gb 2>/dev/null
gb() { git branch --all | fzf --preview 'git log --oneline -20 {}' | sed 's|remotes/origin/||' | xargs git checkout; }

# Interactive process kill
fkill() { ps aux | fzf --header-lines=1 | awk '{print $2}' | xargs kill -9; }

############################
# NVM
############################
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

############################
# GPG
############################
# Enable GPG SSH agent support
# https://www.gnupg.org/documentation/manuals/gnupg/Agent-Examples.html
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK
  SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

export GPG_TTY
GPG_TTY="$(tty)"

gpg-connect-agent updatestartuptty /bye 1> /dev/null

############################
# ALIASES
############################

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# VIM
alias v=nvim

# Lazygit
alias lg='lazygit'

# YubiKey
alias 2fa='~/.scripts/2fa'
alias 2fa-add='~/.scripts/2fa-add'

# Git 
nb-feat() { git checkout -b "feature/$1"; }
nb-fix()  { git checkout -b "hotfix/$1"; }

# Yazi — cd into the directory yazi exits to
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Ngrock WIP

# alias tunnel='ngrok http'

############################
# VI MODE
############################
bindkey -v
export KEYTIMEOUT=1

############################
# GHOSTTY
############################
# Shell integration — only active when running inside Ghostty
if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

############################
# LOCAL OVERRIDES
# Machine-specific config: credentials, work functions, work aliases.
# This file is NOT tracked by git — create it on each machine.
# See .zshrc.local.example for a template.
############################
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi

############################
# ZOXIDE
############################
eval "$(zoxide init --cmd cd zsh)"
