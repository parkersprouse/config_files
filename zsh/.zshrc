### Oh My Zsh Configuration ###

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="custom"
plugins=(git history z zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh


### User Configuration ###

# Aliases
alias c="clear"
alias home="cd ~"
alias ll="ls -la"
alias la="ls -la"
alias open="explorer.exe ."
alias startpg="sudo service postgresql start"
alias stoppg="sudo service postgresql stop"
alias restartpg="stoppg && startpg"
alias pn="pnpm"
alias updatepnpm="npm install -g pnpm@8"
alias dockerpurge="docker system prune -a -f --volumes"

# Functions
cd() { builtin cd "$@"; la; }
cd ~/code

gitdel () { git branch | grep "$@" | xargs git branch -D ; }

function make() {
  if [ "$1" = "nuke" ]
  then
    command make clean && make init && make start
  elif [ "$1" = "nukes" ]
  then
    command make clean && make init && make start && make shell
  elif [ "$1" = "nukel" ]
  then
    command make clean && make init && make start && make logstail
  elif [ "$1" = "restart" ]
  then
    command make stop && make start
  else
    command make "$@"
  fi
}
autoload make


# Docker Configuration
DOCKER_DISTRO="Debian"
DOCKER_DIR=/mnt/wsl/shared-docker
DOCKER_SOCK="$DOCKER_DIR/docker.sock"
export DOCKER_HOST="unix://$DOCKER_SOCK"
if [ ! -S "$DOCKER_SOCK" ]; then
    mkdir -pm o=,ug=rwx "$DOCKER_DIR"
    chgrp docker "$DOCKER_DIR"
    /mnt/c/Windows/System32/wsl.exe -d $DOCKER_DISTRO sh -c "nohup sudo -b dockerd < /dev/null > $DOCKER_DIR/dockerd.log 2>&1"
fi


# Environment Configuration
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PYENV_ROOT="$HOME/.pyenv"
export NVM_DIR="$HOME/.nvm"
export PATH="$PATH:/usr/local/cuda-12.2/bin"
export PATH="$PATH:$PYENV_ROOT/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.rvm/bin" # Make sure RVM is the last PATH variable change.
export GPG_TTY=$(tty)

eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Android Studio CLI
export PATH="$PATH:$HOME/.android_cli/bin"

# Starship initialization
eval "$(starship init zsh)"