# --- .NET Tools path ---

export PATH="$PATH:$HOME/.dotnet"
export PATH="$PATH:$HOME/.dotnet/tools"


# --- Rust Cargo Path ---

export PATH="$PATH:$HOME/.cargo/bin"


# --- OpenJDK ---

export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"

# For compilers to find OpenJDK
export CPPFLAGS="-I/opt/homebrew/opt/openjdk@11/include"


# --- Android SDK Command Line Tools ---

export ANDROID_HOME=$HOME/.android/
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"


# --- Flutter SDK ---

export PATH="$PATH:$HOME/Library/Flutter/sdk/bin"


# --- Homebrew ---

eval "$(/opt/homebrew/bin/brew shellenv)"


# --- Bun ---

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias updatebun="bun upgrade"


# --- pnpm ---

export PNPM_HOME="/Users/parker/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

alias updatepnpm="npm install -g pnpm@9"


# --- NVM ---

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# --- RVM ---

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"


# --- Pyenv ---

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PATH:$PYENV_ROOT/bin"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"


# --- Poetry ---

export PATH="$PATH:$HOME/.local/bin"


# --- GNU getopt ---

export PATH="$PATH:$(brew --prefix gnu-getopt)/bin"
export FLAGS_GETOPT_CMD="$(brew --prefix gnu-getopt)/bin/getopt"


# --- Aliases ---

alias brewup="brew update && brew upgrade"
alias startpg="brew services start postgresql@14"
alias stoppg="brew services stop postgresql@14"
alias dockerpurge="docker system prune -a -f --volumes"
alias pn="pnpm $@"
alias ll="ls -la" # Preferred "ll" implementation
alias reloadzsh="source ~/.zshrc"
alias editzsh="nano ~/.oh-my-zsh/custom/config.zsh"

# Go back 1 directory level (for typos)
alias cd..='cd ../'
alias ..='cd ../'
alias ...='cd ../../'

# Preferred 'cp' implementation
alias cp='cp -iv'

# Preferred 'mv' implementation
alias mv='mv -iv'

# Go Home
alias ~="cd ~"

# Go Home
alias home="cd ~"

# Go to Code directory
alias codedir="cd ~/code"

# Clear terminal display
alias c='clear'

# Run 'git pull' on all subdirectories
alias gitall="ls | xargs -I{} git -C {} pull"

# Delete .DS_Store files from current directory and all subdirectories
alias cleanupDS="sudo find . -type f -name '*.DS_Store' -ls -delete"

# Disables the laptop from sleeping entirely, including when lid is closed
alias disablesleep="sudo pmset -a disablesleep 1"
alias enablesleep="sudo pmset -a disablesleep 0"


# --- Miscellaneous ---

findport() { sudo lsof -i -P | grep LISTEN | grep "$1"; }
autoload findport

# List all files upon changing directories
cd() { builtin cd "$@"; ll; }

# Delete all local git branches that match the provided pattern
gitdel() { git branch | grep "$@" | xargs git branch -D; }

set_win_title() { echo -ne "\033]0; $(print -rD $PWD) \007"; }
precmd_functions+=(set_win_title)