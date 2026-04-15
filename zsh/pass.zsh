# pass() {
#     git -C ~/.password-store pull --quiet --rebase 2>/dev/null
#     command pass "$@"
# }

alias p='pass'
alias pc='pass show --clip'
alias pg='pass generate'
alias pe='pass edit'
alias psync='pass git pull && pass git push'
