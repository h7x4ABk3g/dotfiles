
# Initialize p10k if present
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

source ~/.aliases

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  vscode
  vi-mode
  systemd
  npm
  npx
  node
  flutter
  archlinux
  colorize
  docker
  docker-compose
  pip
  python
)

source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh