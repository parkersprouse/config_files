#-----------------#
# General Exports #
#-----------------#

export PATH="$PATH:$HOME/Code/BusPatrol/suite/bin" # Add BP 'suite/bin' to PATH for convenience
# export PATH="/usr/local/opt/libpq/bin:$PATH"
# export PATH="$PATH:/usr/local/git/bin"
# export PATH="$PATH:/sw/bin"
# export PATH="$PATH:/usr/local"
# export PATH="$PATH:/usr/local/sbin"
# export PATH="$PATH:/usr/local/bin/pip"


#--------------#
# Integrations #
#--------------#

# --[[ AWS CLI ]]--

export AWS_DEFAULT_REGION=us-east-1
export AWS_PROFILE=bpa-devops
export EC2_REGION=us-east-1

# loginsso() {
#   if_exists aws sso login --profile $(echo $AWS_PROFILE)
# }

# ecs-shell -p bpa-stg stg-console-server
aws() {
  # Update the AWS CLI
  if [[ "$1" = "update" ]]; then
    command curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" --create-dirs -o "/tmp/AWSCLIV2.pkg" && \
      command sudo installer -pkg "/tmp/AWSCLIV2.pkg" -target / && \
      command rm -f "/tmp/AWSCLIV2.pkg"
  # Login to the AWS CLI through our ecr-login script
  elif [[ "$1" = "login" ]]; then
    if [[ -n "$2" ]]; then
      shift
      if_exists ecr-login $@
    else
      if_exists ecr-login $(echo $AWS_PROFILE)
    fi
  else
    command aws $@
  fi
}


# --[[ GStreamer ]]--

export PATH="$PATH:/Library/Frameworks/GStreamer.framework/Versions/1.0/bin"

# export GI_TYPELIB_PATH="/Library/Frameworks/GStreamer.framework/Versions/1.0/lib/girepository-1.0"
# export LDFLAGS="-L$(brew --prefix libffi)/lib"
# export CPPFLAGS="$CPPFLAGS -I$(brew --prefix libffi)/include"
# export PKG_CONFIG_PATH=$(brew --prefix libffi)/lib/pkgconfig

# libffi is keg-only, which means it was not symlinked into /opt/homebrew,
# because macOS already provides this software and installing another version in
# parallel can cause all kinds of trouble.
#
# For compilers to find libffi you may need to set:
#   export LDFLAGS="-L/opt/homebrew/opt/libffi/lib"
#   export CPPFLAGS="-I/opt/homebrew/opt/libffi/include"
#
# For pkg-config to find libffi you may need to set:
#   export PKG_CONFIG_PATH=$(brew --prefix libffi)/lib/pkgconfig


# --[[ nvm ]]--

# The 'PROFILE=/dev/null' prefix prevents the script from auto-updating any of the shell profile configs
alias updatenvm="PROFILE=/dev/null zsh -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'"

export NVM_DIR="$HOME/.nvm"
[[ -f $NVM_DIR/nvm.sh ]] && source "$NVM_DIR/nvm.sh" # Load nvm
[[ -f $NVM_DIR/bash_completion ]] && source "$NVM_DIR/bash_completion" # Load nvm bash_completion


# --[[ pyenv ]]--

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(if_exists pyenv init - zsh)"


#---------#
# Aliases #
#---------#

# Kill zscaler
alias kz='find /Library/LaunchAgents -name '\''*zscaler*'\'' -exec launchctl unload {} \;;sudo find /Library/LaunchDaemons -name '\''*zscaler*'\'' -exec launchctl unload {} \;'


# --[[ Convenience / Utility aliases ]]--

alias work="codedir && cd ./BusPatrol"
