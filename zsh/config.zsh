# --- Foundational Modifications ---

export LANG=en_US.UTF-8

# Terminal color variables
export CLICOLOR=1
export GREP_COLOR='1;32'
export GREP_OPTIONS='--color=auto'
export LSCOLORS=ExFxCxDxBxegedabagacad
export TERM=xterm-color

export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_BROWN='\e[0;33m'
export COLOR_CYAN='\e[0;36m'
export COLOR_GRAY='\e[1;30m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_LIGHT_GRAY='\e[0;37m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_RED='\e[0;31m'
export COLOR_RESET='\e[0m' # No Color
export COLOR_WHITE='\e[1;37m'
export COLOR_YELLOW='\e[1;33m'
# End terminal color variables


alias ls="command ls -G -F -oh" # Preferred "ls" implementation
alias ll="command ls -G -F -oha" # Preferred "ll" implementation

# Modify the `cd` command to run `ll` when changing directories
cd() { builtin cd "$@"; ll; }


# --- Helper Methods ---

exists() {
  command -v "$1" >/dev/null 2>&1
}

if_exists() {
  if exists $1; then
    $@
  else
    echo "${COLOR_LIGHT_RED}command \"$1\" not found${COLOR_RESET}"
  fi
}


# --- Homebrew ---

eval "$(/opt/homebrew/bin/brew shellenv)"


# --- GNU Find ---

export PATH="$(brew --prefix findutils)/libexec/gnubin:$PATH"


# --- .NET Tools ---

export PATH="$PATH:$HOME/.dotnet"
export PATH="$PATH:$HOME/.dotnet/tools"


# --- Rust / Cargo ---

export PATH="$PATH:$HOME/.cargo/bin"


# --- OpenJDK ---

export PATH="$(brew --prefix openjdk@21)/bin:$PATH"

# alias java11="sudo ln -sfn $(brew --prefix openjdk@11)/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk"
# alias java17="sudo ln -sfn $(brew --prefix openjdk@17)/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk"
# alias java21="sudo ln -sfn $(brew --prefix openjdk@21)/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk"


# --- Android SDK Command Line Tools ---

export ANDROID_BUILD_TOOLS_VERSION="36.0.0-rc5"
export ANDROID_HOME="$HOME/.android/"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$HOME/Library/Android/sdk/build-tools/$ANDROID_BUILD_TOOLS_VERSION"
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"


# --- Flutter SDK ---

export PATH="$PATH:$HOME/Library/Flutter/sdk/bin"


# --- Bun ---

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
[ -s "$HOME/.bun/_bun" ] && export BUN_INSTALL="$HOME/.bun"
[ -s "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"

alias bunup="if_exists bun upgrade"
alias updatebun="bunup"


# --- pnpm ---

# Prevent corepack from auto-setting the `packageManager` attribute in `package.json` files
export COREPACK_ENABLE_AUTO_PIN=0

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

alias pnpmup="if_exists pnpm self-update 10"
alias pnup="pnpmup"
alias updatepnpm="pnpmup"
if exists pnpm; then
  source "$HOME/.oh-my-zsh/custom/pnpm-tab-completion.zsh"
fi


# --- NVM ---

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # Load nvm bash_completion


# --- Pyenv ---

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PATH:$PYENV_ROOT/bin"
if exists pyenv; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi


# --- AWS CLI ---

export AWS_PROFILE="personal"

loginaws() {
  if_exists aws sso login --profile $(echo $AWS_PROFILE)
}

if exists aws; then
  source "$HOMEBREW_PREFIX/share/zsh/site-functions/aws_zsh_completer.sh" # Load auto-completion for the AWS CLI
fi


# --- Poetry ---

export PATH="$PATH:$HOME/.local/bin"


# --- PhantomJS ---

export PATH="$PATH:/opt/phantomjs/bin"


# --- GNU getopt ---

if exists brew; then
  export PATH="$PATH:$(brew --prefix gnu-getopt)/bin"
  export FLAGS_GETOPT_CMD="$(brew --prefix gnu-getopt)/bin/getopt"
fi


# --- direnv ---

# Set up the `direnv` hooks
if exists direnv; then
  _direnv_hook() {
    trap -- '' SIGINT
    eval "$(direnv export zsh)"
    trap - SIGINT
  }
  typeset -ag precmd_functions
  if (( ! ${precmd_functions[(I)_direnv_hook]} )); then
    precmd_functions=(_direnv_hook $precmd_functions)
  fi
  typeset -ag chpwd_functions
  if (( ! ${chpwd_functions[(I)_direnv_hook]} )); then
    chpwd_functions=(_direnv_hook $chpwd_functions)
  fi
fi


# --- OpenSSL@1.1 ---

# Likely needs to be first in PATH for building / installing Rubies
export PATH="$(brew --prefix openssl@1.1)/bin:$PATH"


# --- RVM ---

# Add RVM to PATH for scripting.
# "Make sure this is the last PATH entry" (will try, can't guarantee)
export PATH="$PATH:$HOME/.rvm/bin"

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"


# --- yt-dlp ---

export PATH="$PATH:/opt/yt-dlp"
function ytdl() {
  if [ -n "$1" ]; then
    if ! exists yt-dlp; then
      echo "${COLOR_LIGHT_RED}command \"yt-dlp\" not found${COLOR_RESET}" >&2
      return 0
    elif ! exists magick; then
      echo "${COLOR_LIGHT_RED}command \"magick\" not found${COLOR_RESET}" >&2
      return 0
    elif ! exists ffmpeg; then
      echo "${COLOR_LIGHT_RED}command \"ffmpeg\" not found${COLOR_RESET}" >&2
      return 0
    fi

    local outputdir="$HOME/Desktop"

    echo "${COLOR_LIGHT_PURPLE}----------------"
    echo '[GRABBING VIDEO]'
    echo "----------------${COLOR_RESET}"
    local output=$(yt-dlp --console-title --progress --no-cache-dir --no-keep-fragments --no-mark-watched --no-overwrites --write-thumbnail --cookies-from-browser firefox --restrict-filenames --windows-filenames --progress --extractor-args 'youtube:max_comments=0,0,0,0;skip=translated_subs' -f 'bv*+ba/b' --merge-output-format mp4 --paths 'tmp:/tmp' --paths "home:$outputdir" --output '%(title)s_prethumb.%(ext)s' $1 | grep 'Merging formats into')

    local trim1=$(echo $output | sed -e 's/\([ ]*\)\[Merger\] Merging formats into\([ ]*\)//g')
    local trim2=$(echo $trim1 | sed -e "s/\"//g")
    local trim3=$(echo $trim2 | sed -e "s#$outputdir/##")
    local name=$(echo $trim3 | sed -e "s/\.mp4//g")
    local finalname=$(echo $name | sed -e "s/_prethumb//g")

    echo "\n${COLOR_LIGHT_PURPLE}----------------------"
    echo '[CONVERTING THUMBNAIL]'
    echo "----------------------${COLOR_RESET}"
    magick "$outputdir/$name.webp" -clamp -despeckle -enhance "$outputdir/$name.jpg"

    echo "\n${COLOR_LIGHT_PURPLE}---------------------------"
    echo '[ADDING THUMBNAIL TO VIDEO]'
    echo "---------------------------${COLOR_RESET}"
    ffmpeg -i "$outputdir/$name.mp4" -i "$outputdir/$name.jpg" -map 1 -map 0 -c copy -disposition:0 attached_pic "$outputdir/$finalname.mp4"

    echo "\n${COLOR_LIGHT_PURPLE}------------------------"
    echo '[CLEANING UP FILE PARTS]'
    echo "------------------------${COLOR_RESET}"
    rm "$outputdir/$name.webp" "$outputdir/$name.jpg" "$outputdir/$name.mp4"
  else
    echo "YouTube video URL required"
  fi
}
autoload ytdl

# --- Additional PATH Exports ---

export PATH="$PATH:$HOME/Downloads/tone"
export PATH="$(brew --prefix postgresql@16)/bin:$PATH"


# --- Environment Exports ---

export CPPFLAGS="-I$(brew --prefix openjdk@11)/include"

export LDFLAGS="-L$(brew --prefix openssl@1.1)/lib"
export CPPFLAGS="$CPPFLAGS -I$(brew --prefix openssl@1.1)/include"
export PKG_CONFIG_PATH="$(brew --prefix openssl@1.1)/lib/pkgconfig"

export LDFLAGS="$LDFLAGS -L$(brew --prefix postgresql@16)/lib"
export CPPFLAGS="$CPPFLAGS -I$(brew --prefix postgresql@16)/include"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH $(brew --prefix postgresql@16)/lib/pkgconfig"


# --- Command Aliases ---

function editomz() {
  local cfg_file="$HOME/.oh-my-zsh/custom/config.zsh"
  if [ -n "$1" ]
  then
    eval "if_exists $@ '$cfg_file'"
  else
    if_exists code "$cfg_file"
  fi
}
autoload editomz

function editzsh() {
  local cfg_file="$HOME/.zshrc"
  if [ -n "$1" ]
  then
    eval "if_exists $@ '$cfg_file'"
  else
    if_exists code "$cfg_file"
  fi
}
autoload editzsh

# Fetch newest Homebrew and formulae versions, then upgrade outdated casks and formulae
alias brewup="if_exists brew update && if_exists brew upgrade && if_exists brew cleanup"
alias dockerpurge="if_exists docker system prune -a -f --volumes"
alias iterm2="if_exists /usr/local/bin/iterm2.sh $@"
alias shell="iterm2 $@"
alias pn="if_exists pnpm $@"
alias reload="source '$HOME/.zshrc'"
alias startpg="if_exists brew services start postgresql@16"
alias stoppg="if_exists brew services stop postgresql@16"

alias cd..="cd ../" # Typo guard
alias ..="cd ../"
alias ...="cd ../../"

alias cp="cp -iv" # Preferred 'cp' implementation
alias mv="mv -iv" # Preferred 'mv' implementation

# Easy home accessors
alias ~="cd '$HOME'"
alias home="cd '$HOME'"

# Clear terminal display
alias c="clear"

# Delete .DS_Store files from current directory, recursively
alias cleanupDS="sudo find . -type f -name '*.DS_Store' -ls -delete"

# Go to Code directory
alias codedir="cd '$HOME/code'"

# Run 'git pull' on all subdirectories
alias gitall="ls | xargs -I{} git -C {} pull"

# Disables the laptop from sleeping entirely, including when lid is closed
alias disablesleep="sudo pmset -a disablesleep 1"
alias enablesleep="sudo pmset -a disablesleep 0"


# --- Miscellaneous ---

findport() { sudo lsof -i -P | grep LISTEN | grep "$1"; }
autoload findport

# Delete all local git branches that match the provided pattern
gitdel() { git branch | grep "$@" | xargs git branch -D; }

set_win_title() { echo -ne "\033]0; $(print -rD $PWD) \007"; }
precmd_functions+=(set_win_title)
