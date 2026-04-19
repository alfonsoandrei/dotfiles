if [ -n "$GHOSTTY_RESOURCES_DIR" ] && [ -z "$TMUX" ]; then
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

export KEYTIMEOUT=1

# Vi mode - yank to system clipboard
vi-yank-pbcopy() {
  zle vi-yank
  echo -n "$CUTBUFFER" | pbcopy
}
zle -N vi-yank-pbcopy
bindkey -M vicmd 'y' vi-yank-pbcopy

vi-paste-pbpaste() {
  LBUFFER+=$(pbpaste)
}
zle -N vi-paste-pbpaste
bindkey -M vicmd 'p' vi-paste-pbpaste

eval "$(zoxide init --cmd cd zsh)"
