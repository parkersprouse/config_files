if ! command -v bashcompinit >/dev/null; then
  autoload bashcompinit && bashcompinit
fi

if ! command -v compinit >/dev/null; then
  autoload -Uz compinit && compinit
fi


#----------------------------#
# Foundational Modifications #
#----------------------------#

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

alias ll='command ls -G -F -oah'
# alias ls='command ls -G -F -oh' # Preferred "ls" implementation - have to be careful, can break dependent scripts
alias cp='cp -iv' # Preferred 'cp' implementation
alias mv='mv -iv' # Preferred 'mv' implementation

# Modify the `open` command to use ForkLift instead of Finder
if [[ -d /Applications/ForkLift.app ]]; then
  open() { command open -a ForkLift $@; }
  alias fl="open $@"
  alias forklift="fl $@"
fi

# Modify the `cd` command to run `ll` when changing directories
cd() { builtin cd "$@"; ll; }

# Modify the title of the window to only show the current directory's path
set_win_title() { echo -ne "\033]0; $(print -rD $PWD) \007"; }
precmd_functions+=(set_win_title)


#---------#
# Helpers #
#---------#

alias reload="source $HOME/.zshrc"

is_empty() {
  (( $(ls "$1" | wc -l) < 1 ))
}

if_empty() {
  if [[ -d "$1" ]]; then
    if is_empty $1; then
      $@
    else
      echo "\"$1\" is not empty" >&2
      return 1
    fi
  else
    echo "\"$1\" is not a directory" >&2
    return 1
  fi
}

exists() {
  command -v "$1" >/dev/null 2>&1
}

if_exists() {
  if exists $1; then
    $@
  else
    echo "command \"$1\" not found" >&2
    return 1
  fi
}


#-----------------#
# General Exports #
#-----------------#

export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$HOME/.local/bin"

# Homebrew shellenv
eval "$(/opt/homebrew/bin/brew shellenv)"


#-----------#
# Functions #
#-----------#

# Math.ceil(x) implementation -- ceil 0.7 -> 1
ceil() {
  if [[ -n $1 ]]; then
    echo "define ceil (x) {if (x<0) {return x/1} \
          else {if (scale(x)==0) {return x} \
          else {return x/1 + 1 }}} ; ceil($1)" | bc
  else
    echo 'Usage: ceil <number>' >&2
    return 1
  fi
}

# -----

docker() {
  if ! exists docker; then echo 'command "docker" not found' >&2; return 1; fi

  if [[ "$1" = "purge" ]] || [[ "$1" = "nuke" ]]; then
    command docker system prune -a -f --volumes
  else
    command docker $@
  fi
}

# -----

viewomz() {
  local cfg_file="$HOME/.oh-my-zsh/custom/config.zsh"
  if [[ -n "$1" ]] && exists $1; then
    eval "if_exists $@ '$cfg_file'"
  else
    command cat "$cfg_file"
  fi
}
alias viewconfig="viewomz $@"

# -----

editomz() {
  local cfg_file="$HOME/.oh-my-zsh/custom/config.zsh"
  if [[ -n "$1" ]] && exists $1; then
    eval "if_exists $@ '$cfg_file'"
  else
    if_exists code "$cfg_file"
  fi
}
alias editconfig="editomz $@"

# -----

viewzsh() {
  local cfg_file="$HOME/.zshrc"
  if [[ -n "$1" ]] && exists $1; then
    eval "if_exists $@ '$cfg_file'"
  else
    if_exists cat "$cfg_file"
  fi
}

# -----

editzsh() {
  local cfg_file="$HOME/.zshrc"
  if [[ -n "$1" ]] && exists $1; then
    eval "if_exists $@ '$cfg_file'"
  else
    if_exists code "$cfg_file"
  fi
}

# -----

emptytrash() {
  if ! is_empty ~/.Trash; then
    osascript -e 'tell app "Finder" to empty'
  else
    echo 'Trash is already empty'
  fi
}

# -----

git() {
  if ! exists git; then echo 'command "git" not found' >&2; return 1; fi

  # Run 'git pull' on all subdirectories
  if [[ "$1" = "all" ]]; then
    command ls | xargs -I{} git -C {} pull
  # Delete all git branches that contain the provided text
  elif [[ "$1" = "del" ]]; then
    shift
    command git branch | grep "$@" | xargs git branch -D
  # Look through all local & remote branches in a repo for a provided string
  elif [[ "$1" = "find" ]] || [[ "$1" = "search" ]]; then
    shift
    command git grep --line-number --break --heading --recursive --full-name $@ $(git branch --list --all --format='%(refname)')
  else
    command git $@
  fi
}

# -----

shell() {
  if [[ -d /Applications/Warp.app ]]; then
    command open -a Warp $@
  else
    command open -a Terminal $@
  fi
}
alias warp="shell $@"
alias term="shell $@"

# -----

make() {
  if ! exists make; then echo 'command "make" not found' >&2; return 1; fi

  if [[ "$1" = "purge" ]] || [[ "$1" = "nuke" ]]; then
    command make stop && command make clean && docker purge
  elif [[ "$1" = "restart" ]]; then
    command make stop && command make start
  elif [[ "$1" = "refresh" ]]; then
    command make stop && command make init && command make build && command make start
  elif [[ "$1" = "reset" ]]; then
    command make stop && command make clean && command make init && command make build && command make start
  else
    command make $@
  fi

  # elif [[ "$1" = "nukes" ]]; then
  #   command make clean && command make init && command make start && command make shell
  # elif [[ "$1" = "nukel" ]]; then
  #   command make clean && command make init && command make start && command make logstail
}

# -----

godir() {
  if [[ -n "$1" ]]; then
    if [[ -d "$1" ]]; then
      echo "Directory \"$1\" already exists" >&2
      return 1
    else
      command mkdir "$1" && cd "$1"
    fi
  else
    echo 'Usage: godir <name>' >&2
    return 1
  fi
}

# -----

rmdir() {
  if [[ -n "$1" ]]; then
    if [[ -d "$1" ]]; then
      command rm -rf "$1"
    else
      echo "\"$1\" is not a directory" >&2
      return 1
    fi
  else
    echo 'Usage: rmdir <name>' >&2
    return 1
  fi
}

# -----

keygen() {
  if ! exists openssl; then echo 'command "openssl" not found' >&2; return 1; fi

  local use_defaults=false
  if (( $# > 2 )); then echo 'too many arguments provided. using default values (32, hex)' >&2; use_defaults=true; fi

  local size=32
  local encoding='hex'

  if [[ $use_defaults = false ]]; then
    for arg in $@; do
      case "$arg" in
        # Look for an argument that's solely numeric to use as size
        [0-9]*) size=$arg ;;
        # And look to see if an acceptable encoding was provided
        (base64|hex)) encoding=$arg ;;
      esac
    done
  fi

  openssl rand -$encoding $size;
}
alias genkey="keygen $@"
alias randkey="keygen $@"
alias gensecret="keygen $@"
alias secretgen="keygen $@"

# -----

findport() {
  if [[ -n "$1" ]]; then
    local -A opts
    zparseopts -D -A opts -- \
      p -process-id \
      q -quiet

    local rows=$(lsof -i -P | grep LISTEN | grep $1)

    if [[ -z "$rows" ]]; then
      if [[ -z ${opts[(i)-q]} && -z ${opts[(i)--quiet]} ]]; then
        echo "No processes found running on port $1" >&2
      fi
      return 0
    fi

    local lines=("${(@f)rows}")
    for row in $lines; do
      local pid=$(echo "$row" | awk '{print $2}')
      if [[ -n ${opts[(i)-p]} || -n ${opts[(i)--process-id]} ]]; then
        echo "$pid"
      else
        local row_with_app="$(ps -ef | grep " $pid " | grep -v grep)"
        echo "$row_with_app" | awk '{for(i=8;i<=NF;i++) printf "%s%s",$i,(i<NF?OFS:"\n")}'
      fi
    done
  else
    echo 'Usage: findport <port>' >&2
    return 1
  fi
}

# -----

killport() {
  if [[ -n "$1" ]]; then
    local pids="$(findport -p -q $1)"

    if [[ -z "$pids" ]]; then
      echo "No processes found running on port $1" >&2
      return 1
    fi

    local lines=("${(@f)pids}")
    for pid in $pids; do
      kill $pid
      echo "Successfully killed process with PID $pid running on port $1" >&2
    done
  else
    echo 'Usage: killport <port>' >&2
    return 1
  fi
}


#--------------#
# Integrations #
#--------------#

# --[[ AI Skills / MCP Utils ]]--

# skill add https://github.com/addyosmani/agent-skills performance-optimization
skill() {
  if ! exists npx; then echo 'command "npx" not found' >&2; return 1; fi

  if [[ "$1" = "add" ]]; then
    shift
    command npx skills add $1 --global --agent universal claude-code --yes --skill $2
  elif [[ "$1" = "remove" ]]; then
    shift
    command npx skills remove $1
  else
    shift
    command npx skills $@
  fi
}
alias skills="skill"


# --[[ AWS CLI ]]--

if exists aws_completer; then
  # Load autocomplete for the AWS CLI
  complete -C "'$(echo $(which aws_completer))'" aws
fi

aws() {
  if ! exists aws; then echo 'command "aws" not found' >&2; return 1; fi

  # Update the AWS CLI
  if [[ "$1" = "update" ]]; then
    command curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" --create-dirs -o "/tmp/AWSCLIV2.pkg" && \
      command sudo installer -pkg "/tmp/AWSCLIV2.pkg" -target / && \
      command rm -f "/tmp/AWSCLIV2.pkg"
  elif [[ "$1" = "login" ]]; then
    if [[ -n "$2" ]]; then
      shift
      aws sso login --profile $@
    else
      aws sso login --profile $(echo $AWS_PROFILE)
    fi
  else
    command aws $@
  fi
}


# --[[ GPG ]]--

# Exports the TTY to make available for GPG
export GPG_TTY=$(tty)


# --[[ GitHub CLI ]]--

export GH_TELEMETRY=false
export DO_NOT_TRACK=true

# Used by the GitHub MCP server
export GITHUB_PERSONAL_ACCESS_TOKEN=$(security find-generic-password -a "$USER" -s "github-claude-mcp-pat" -w)


# --[[ Homebrew ]]--

brew() {
  if ! exists brew; then echo 'command "brew" not found' >&2; return 1; fi

  # Fetch newest Homebrew and formulae versions, then upgrade outdated casks and formulae
  if [[ "$1" = "up" ]]; then
    command brew update && command brew upgrade && command brew cleanup
  elif [[ "$1" = "ui" ]] || [[ "$1" = "tui" ]]; then
    command taproom $@
  else
    command brew $@
  fi
}


# --[[ OpenSSL ]]--

set_openssl_base_path() {
  if ! exists openssl; then echo 'command "openssl" not found' >&2; return 1; fi

  local openssl_path=$(which openssl)
  local resolved_symlink=$(readlink $openssl_path)
  local abs_prefix="/opt/homebrew"
  local base_path=${resolved_symlink/../$abs_prefix}

  # Likely needs to be first in PATH for building / installing Rubies
  export PATH="$base_path/bin:$PATH"

  export LDFLAGS="-L$base_path/lib"
  export CPPFLAGS="$CPPFLAGS -I$base_path/include"
  export PKG_CONFIG_PATH="$base_path/lib/pkgconfig"

  reload
}

# Switch to OpenSSL 1.1 (required for building Ruby < 3.1 and Node 10)
alias ssl1="brew unlink openssl@3 && brew link openssl@1.1 && set_openssl_base_path"
# Switch to OpenSSL 3
alias ssl3="brew unlink openssl@1.1 && brew link openssl@3 && set_openssl_base_path"


# --[[ OrbStack ]]--

source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null || :


# --[[ pnpm ]]--

# In case corepack ever gets used, prevent it from auto-setting the `packageManager` attribute in `package.json` files
export COREPACK_ENABLE_AUTO_PIN=0

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Source pnpm tab completion if available (from either location)
[[ -s "$HOME/.pnpm/pnpm-tab-completion.zsh" ]] && source "$HOME/.pnpm/pnpm-tab-completion.zsh"

pnpm() {
  if ! exists pnpm; then echo 'command "pnpm" not found' >&2; return 1; fi

  # Update pnpm
  if [[ "$1" = "upgrade" ]] || [[ "$1" = "up" ]]; then
    if [[ -n "$2" ]]; then
      pnpm self-update $2
    else
      pnpm self-update
    fi
  elif [[ "$1" = "clean" ]]; then
    pnpx rimraf -I -g "**/node_modules"
  elif [[ "$1" = "refresh" ]]; then
    pnpm clean && pnpm install
  else
    command pnpm $@
  fi
}

alias pn="pnpm $@"


# --[[ RVM ]]--

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*


# --[[ Rust / Cargo ]]--

source "$HOME/.cargo/env"


# --[[ uv ]]--

# When running `uv python install`, pass the `--default` flag to make the chosen version the global Python version.
# This will install it at `~/.local/bin/python`
if exists uv; then
  # ensure we always use the version of Python managed by `uv`
  export UV_MANAGED_PYTHON=1

  # ensure the Python binary gets added to our `PATH`
  local PYTHON_DIR="$(dirname "$(uv python find --no-project)")"
  [[ -d $PYTHON_DIR ]] && export PATH="$PATH:$PYTHON_DIR"

  uv() {
    if [[ "$1" = "python" ]]; then
      shift
      if [[ "$1" = "global" ]]; then
        shift
        command uv python install --preview-features python-install-default --default $@
      else
        command uv python $@
      fi
    else
      command uv $@
    fi
  }
fi


#---------#
# Aliases #
#---------#

alias copy="pbcopy"
alias paste="pbpaste"

# --[[ Convenience / Utility aliases ]]--

alias cleanDS="find . -type f -name '*.DS_Store' -ls -delete"
alias cleanupDS="cleanDS"
alias removeDS="cleanDS"

alias codedir="cd ~/Code"

alias c='clear'   # Clear terminal display
alias home="cd ~" # Go Home
alias ~="home"    # ^

alias cd..='cd ../'   # Go back 1 directory level - catch typos
alias ..='cd ../'     # Go back 1 directory level
alias ...='cd ../../' # Go back 2 directory levels

# Disables the laptop from sleeping entirely, including when lid is closed
alias disablesleep="sudo pmset -a disablesleep 1"
alias enablesleep="sudo pmset -a disablesleep 0"

# Disable Spotlight Indexing
alias disable_spotlight_indexing="sudo mdutil -a -i off"
alias disablespotlightindexing="disable_spotlight_indexing"
alias disableslidx="disable_spotlight_indexing"
# Enable Spotlight Indexing
alias enable_spotlight_indexing="sudo mdutil -a -i on"
alias enablespotlightindexing="enable_spotlight_indexing"
alias enableslidx="enable_spotlight_indexing"

alias lockdock="defaults write com.apple.dock size-immutable -bool true; killall Dock"
alias unlockdock="defaults delete com.apple.dock size-immutable; killall Dock"
# also an option for unlocking if the above gives trouble:
# alias unlockdock="defaults write com.apple.dock size-immutable -bool false; killall Dock"
