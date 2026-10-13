# Initialize Node Version Manager (NVM)
# Omarchy uses mise; avoid shadowing it on Linux hosts.
if [ "$(uname -s)" = "Linux" ] && command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
  return
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
