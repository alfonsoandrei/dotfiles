# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export DOTFILES="$HOME/dotfiles"

# ZSH_THEME="zsh2000-node"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git fzf zsh-autosuggestions zsh-syntax-highlighting pass docker aws)

source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS

# Default to vi command mode (not insert)
set -o vi

for env_file in "$DOTFILES/zsh/envs"/*.zsh; do
    [ -f "$env_file" ] && source "$env_file"
done

source "$DOTFILES/zsh/aliases.zsh"

source "$DOTFILES/zsh/integrations.zsh"

if command -v pass &>/dev/null; then
    source "$DOTFILES/zsh/pass.zsh"
fi

source "$DOTFILES/zsh/functions.zsh"

if [ -f "$HOME/.scripts/pass" ]; then
    source "$HOME/.scripts/pass"
fi

if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Obsidian Vault Path
# export VAULT_DIR_NOTES=""
