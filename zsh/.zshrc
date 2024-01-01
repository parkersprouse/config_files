export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="personal"

plugins=(git history universalarchive z zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

# Initialize Starship
eval "$(starship init zsh)"
