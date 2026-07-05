#-----------------#
# General Exports #
#-----------------#

# export VIRTUAL_ENV_DISABLE_PROMPT=1 # unsure if still needed - possibly for pyenv?

export PATH="$PATH:$HOME/.cargo/env"
export PATH="$PATH:$HOME/.rvm/bin"
# export PATH="/usr/local/opt/libfqi/bin:$PATH"
# export PATH="$PATH:/usr/local/git/bin"
# export PATH="$PATH:/sw/bin"
# export PATH="$PATH:/usr/local"
# export PATH="$PATH:/usr/local/sbin"
# export PATH="$PATH:/usr/local/bin/pip"

# GNU Find
export PATH="$(brew --prefix findutils)/libexec/gnubin:$PATH"

# .NET Tools
export PATH="$PATH:$HOME/.dotnet"
export PATH="$PATH:$HOME/.dotnet/tools"

# OpenJDK
export PATH="$(brew --prefix openjdk@21)/bin:$PATH"

# Android SDK Command Line Tools
export ANDROID_BUILD_TOOLS_VERSION="36.0.0-rc5"
export ANDROID_HOME="$HOME/.android/"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$HOME/Library/Android/sdk/build-tools/$ANDROID_BUILD_TOOLS_VERSION"
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

# Flutter SDK
export PATH="$PATH:$HOME/Library/Flutter/sdk/bin"

# PhantomJS
export PATH="$PATH:/opt/phantomjs/bin"

# GNU getopt
if exists brew; then
  local gnu_getopt_prefix="$(brew --prefix gnu-getopt)"
  export PATH="$PATH:$gnu_getopt_prefix/bin"
  export FLAGS_GETOPT_CMD="$gnu_getopt_prefix/bin/getopt"
fi

# Additional PATH Exports
export PATH="$PATH:$HOME/Downloads/tone"
local postgresql_prefix="$(brew --prefix postgresql@16)"
export PATH="$postgresql_prefix/bin:$PATH"

# Environment Exports
export CPPFLAGS="-I$(brew --prefix openjdk@11)/include"

export LDFLAGS="$LDFLAGS -L$postgresql_prefix/lib"
export CPPFLAGS="$CPPFLAGS -I$postgresql_prefix/include"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH $postgresql_prefix/lib/pkgconfig"


#--------------#
# Integrations #
#--------------#


# --[[ AWS CLI ]]--

export AWS_PROFILE=personal


# --[[ Bun ]]--

# bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun" && export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL/bin" ]] && export PATH="$BUN_INSTALL/bin:$PATH"


# --- [[ Caddy ]] ---

# When running the provided service, caddy's data dir will be set as
#   `/opt/homebrew/var/lib`
#   instead of the default location found at https://caddyserver.com/docs/conventions#data-directory
# To start caddy now and restart at login:
#   brew services start caddy
# Or, if you don't want/need a background service you can just run:
#   XDG_DATA_HOME="/opt/homebrew/var/lib" HOME="/opt/homebrew/var/lib" /opt/homebrew/opt/caddy/bin/caddy run --config /opt/homebrew/etc/Caddyfile


# --- [[ direnv ]] ---

# Set up the `direnv` hooks
if exists direnv; then
  typeset -ag precmd_functions
  if (( ! ${precmd_functions[(I)_direnv_hook]} )); then
    precmd_functions=(_direnv_hook $precmd_functions)
  fi
  typeset -ag chpwd_functions
  if (( ! ${chpwd_functions[(I)_direnv_hook]} )); then
    chpwd_functions=(_direnv_hook $chpwd_functions)
  fi
fi


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

export NVM_DIR="$HOME/.nvm"
[[ -f $NVM_DIR/nvm.sh ]] && source "$NVM_DIR/nvm.sh" # Load nvm
[[ -f $NVM_DIR/bash_completion ]] && source "$NVM_DIR/bash_completion" # Load nvm bash_completion


# --[[ pyenv ]]-- (has been replaced by uv)

# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# if exists pyenv; then
#   eval "$(pyenv init -)"
#   eval "$(pyenv virtualenv-init -)"
# fi


#---------#
# Aliases #
#---------#

alias startpg="if_exists brew services start postgresql@16"
alias stoppg="if_exists brew services stop postgresql@16"
