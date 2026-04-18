if [ -n "$GHOSTTY_RESOURCES_DIR" ]; then
    source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

export KEYTIMEOUT=1

eval "$(zoxide init --cmd cd zsh)"
