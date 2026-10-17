# pass() {
#     git -C ~/.password-store pull --quiet --rebase 2>/dev/null
#     command pass "$@"
# }

alias psync='pass git pull && pass git push'

# Any entry works as a decrypt probe.
_pass_probe() {
    find "${PASSWORD_STORE_DIR:-$HOME/.password-store}" -name '*.gpg' -print -quit 2>/dev/null
}

# True if pass can decrypt without prompting. Guards exports so shell startup never blocks.
pass_unlocked() {
    gpg --quiet --batch --pinentry-mode error -d "$(_pass_probe)" >/dev/null 2>&1
}

# Print the hint on the first prompt, not during init (would trip p10k instant prompt).
_pass_locked_notice() {
    print -P "%F{yellow}🔒 pass locked: API keys not loaded. Unlock it and run 'secrets'.%f"
    add-zsh-hook -d precmd _pass_locked_notice
}
pass_locked_hint() {
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _pass_locked_notice
}

# Unlock pass and re-run the guarded exports in ~/.zshrc.local.
secrets() {
    gpg --quiet -d "$(_pass_probe)" >/dev/null && source "$HOME/.zshrc.local"
}
