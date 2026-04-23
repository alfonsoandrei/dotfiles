# pass() {
#     git -C ~/.password-store pull --quiet --rebase 2>/dev/null
#     command pass "$@"
# }

alias psync='pass git pull && pass git push'
