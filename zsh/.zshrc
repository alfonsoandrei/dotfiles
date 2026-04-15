export ZSH="$HOME/.oh-my-zsh"
export DOTFILES="$HOME/dotfiles"

ZSH_THEME="zsh2000-node"

plugins=(git fzf zsh-autosuggestions zsh-syntax-highlighting pass docker aws)

source $ZSH/oh-my-zsh.sh

export EDITOR='nvim'

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
