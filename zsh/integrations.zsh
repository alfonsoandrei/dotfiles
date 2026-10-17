if [ -n "$GHOSTTY_RESOURCES_DIR" ] && [ -z "$TMUX" ]; then
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

export KEYTIMEOUT=1

# Vi mode - yank to system clipboard
vi-yank-clipboard() {
  zle vi-yank
  echo -n "$CUTBUFFER" | "$HOME/.local/bin/clipboard-copy"
}
zle -N vi-yank-clipboard
bindkey -M vicmd 'y' vi-yank-clipboard

vi-paste-clipboard() {
  LBUFFER+=$("$HOME/.local/bin/clipboard-paste")
}
zle -N vi-paste-clipboard
bindkey -M vicmd 'p' vi-paste-clipboard

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^V' edit-command-line

