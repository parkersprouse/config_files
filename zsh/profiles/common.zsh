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

if [[ -d /Applications/ForkLift.app ]]; then
  alias fl="open $@"
  alias forklift="fl $@"
fi

# Modify the title of the window to only show the current directory's path
precmd_functions+=(set_win_title)


#---------#
# Helpers #
#---------#

alias reload="source $HOME/.zshrc"


#-----------------#
# General Exports #
#-----------------#

export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:$HOME/.local/bin"

# Homebrew shellenv
eval "$(/opt/homebrew/bin/brew shellenv)"


#--------------#
# Integrations #
#--------------#

# --[[ AI Skills / MCP Utils ]]--

# skill add https://github.com/addyosmani/agent-skills performance-optimization
alias skills="skill"


# --[[ AWS CLI ]]--

if exists aws_completer; then
  # Load autocomplete for the AWS CLI
  complete -C "$(which aws_completer)" aws
fi


# --[[ GPG ]]--

# Exports the TTY to make available for GPG
export GPG_TTY=$(tty)


# --[[ GitHub CLI ]]--

export GH_TELEMETRY=false
export DO_NOT_TRACK=true

# Used by the GitHub MCP server
export GITHUB_PERSONAL_ACCESS_TOKEN=$(security find-generic-password -a "$USER" -s "github-claude-mcp-pat" -w)


# --[[ OpenSSL ]]--

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
fi


#---------#
# Aliases #
#---------#

alias editconfig="editomz $@"
alias viewconfig="viewomz $@"

alias term="shell $@"
alias warp="shell $@"

alias genkey="keygen $@"
alias gensecret="keygen $@"
alias randkey="keygen $@"
alias secretgen="keygen $@"

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
