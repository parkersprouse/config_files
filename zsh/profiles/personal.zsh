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
  export PATH="$PATH:$(brew --prefix gnu-getopt)/bin"
  export FLAGS_GETOPT_CMD="$(brew --prefix gnu-getopt)/bin/getopt"
fi

# Additional PATH Exports
export PATH="$PATH:$HOME/Downloads/tone"
export PATH="$(brew --prefix postgresql@16)/bin:$PATH"

# Environment Exports
export CPPFLAGS="-I$(brew --prefix openjdk@11)/include"

export LDFLAGS="$LDFLAGS -L$(brew --prefix postgresql@16)/lib"
export CPPFLAGS="$CPPFLAGS -I$(brew --prefix postgresql@16)/include"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH $(brew --prefix postgresql@16)/lib/pkgconfig"


#-----------#
# Functions #
#-----------#

# iconvert img.jpg png
iconvert() {
  if [[ $# -eq 2 ]]; then
    if_exists magick mogrify -format $2 $1
  else
    echo 'Usage: iconvert <file> <extension>' >&2
    echo 'Example: iconvert img.jpg png' >&2
    return 1
  fi
}

# -----

# pad_audio file.webm --> file.mp3
# pad_audio file.webm aac -b:a 96K --> file.aac
pad_audio() {
  if [[ -z $1 ]]; then echo 'Usage: pad_audio <file> [extension]' >&2; return 1; fi
  if ! exists ffmpeg || ! exists ffprobe; then echo 'FFmpeg must be installed to run this command' >&2; return 1; fi

  local input_file=$1

  local current_dur=$(ffprobe -hide_banner -loglevel quiet -output_format csv=p=0 -show_entries format=duration $input_file)
  local new_dur=$(ceil $current_dur)
  shift

  local output_ext=$1
  if [[ $output_ext = *"-"* ]]; then
    if [[ $output_ext = "--" ]]; then shift; fi
    output_ext="mp3"
  elif [[ -n $output_ext ]]; then
    output_ext="${output_ext:l}"
    shift
  else
    output_ext="mp3"
  fi

  local output_file="$(echo $input_file | grep -o '^.*\.')$output_ext"
  ffmpeg -hide_banner -loglevel quiet -i $input_file -af "apad=whole_dur=$new_dur" $* $output_file
  echo "Audio padded from ${current_dur}s -> ${new_dur}s"
}

# -----

disks() {
  command diskutil list
}

# -----

unmount() {
  if [[ -n "$1" ]]; then
    command diskutil unmountDisk $1
  else
    echo 'Usage: unmount <device>' >&2
    return 1
  fi
}

# -----

# ExFAT EXT_USB MBRFormat /dev/disk5
erase() {
  local format=$1
  if [[ -z $format ]]; then format="ExFAT"; fi

  local name=$2
  if [[ -z $name ]]; then name="EXT_USB"; fi

  local type=$3
  if [[ -z $type ]]; then format="MBRFormat"; fi

  local device=$4

  if [[ -n "$device" ]]; then
    command diskutil eraseDisk $format $name $type $device
  else
    echo 'Usage: erase <format> <name> [APM[Format] | MBR[Format] | GPT[Format]] <device>' >&2
    return 1
  fi
}

# -----

wipe() {
  if [[ -n "$1" ]]; then
    erase ExFAT EXT_USB MBRFormat $1
  else
    echo 'Usage: wipedisk <device>' >&2
    return 1
  fi
}

# -----

allow() {
  if [[ -n "$1" ]]; then
    command xattr -d com.apple.quarantine "$1"
  else
    echo 'Usage: allow <file>' >&2
    return 1
  fi
}

# -----

weather() {
  local cmd="curl wttr.in"
  if [[ -n "$1" ]]; then
    eval "$cmd/$1"
  else
    eval "$cmd/Chalmette+LA"
  fi
}

# -----

ytdl() {
  if ! exists docker; then echo 'command "docker" not found' >&2; return 1; fi

  if [ -n "$1" ]; then
    if ! exists yt-dlp; then
      echo "command \"yt-dlp\" not found" >&2
      return 1
    elif ! exists magick; then
      echo "command \"magick\" not found" >&2
      return 1
    elif ! exists ffmpeg; then
      echo "command \"ffmpeg\" not found" >&2
      return 1
    fi

    local outputdir="${PWD}"
    # if [[ ! -d "$outputdir" ]]; then mkdir "$outputdir"; fi

    echo "----------------"
    echo '[GRABBING VIDEO]'
    echo "----------------"
    # --extractor-args 'youtube:max_comments=0,0,0,0;skip=translated_subs'
    # --limit-rate 5M \
    # --no-keep-fragments \
    local output=$(yt-dlp \
      --console-title \
      --progress \
      --no-mark-watched \
      --no-cache-dir \
      --no-overwrites \
      --write-thumbnail \
      --cookies-from-browser firefox \
      --restrict-filenames \
      -f 'bv*+ba/b' \
      --merge-output-format mp4 \
      --paths 'tmp:/tmp' \
      --paths "home:$outputdir" \
      --output '%(title)s_prethumb.%(ext)s' \
      $1 | grep 'Merging formats into')

    local trim1=$(echo $output | sed -e 's/\([ ]*\)\[Merger\] Merging formats into\([ ]*\)//g')
    local trim2=$(echo $trim1 | sed -e "s/\"//g")
    local trim3=$(echo $trim2 | sed -e "s#$outputdir/##")
    local name=$(echo $trim3 | sed -e "s/\.mp4//g")
    local finalname=$(echo $name | sed -e "s/_prethumb//g")

    echo "\n----------------------"
    echo '[CONVERTING THUMBNAIL]'
    echo "----------------------"
    magick "$outputdir/$name.webp" -clamp -despeckle -enhance "$outputdir/$name.jpg"

    echo "\n---------------------------"
    echo '[ADDING THUMBNAIL TO VIDEO]'
    echo "---------------------------"
    ffmpeg -hide_banner -i "$outputdir/$name.mp4" -i "$outputdir/$name.jpg" -map 1 -map 0 -c copy -disposition:0 attached_pic "$outputdir/$finalname.mp4"

    echo "\n------------------------"
    echo '[CLEANING UP FILE PARTS]'
    echo "------------------------"
    rm "$outputdir/$name.webp" "$outputdir/$name.jpg" "$outputdir/$name.mp4"
  else
    echo 'Usage: ytdl <url>' >&2
    return 1
  fi
}


#--------------#
# Integrations #
#--------------#


# --[[ AWS CLI ]]--

export AWS_PROFILE=personal


# --[[ Bun ]]--

# bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun" && export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL/bin" ]] && export PATH="$BUN_INSTALL/bin:$PATH"

bun() {
  if ! exists bun; then echo 'command "bun" not found' >&2; return 1; fi

  if [[ "$1" = "up" ]]; then
    bun upgrade
  else
    command bun $@
  fi
}


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

nvm() {
  if ! exists nvm; then echo 'command "nvm" not found' >&2; return 1; fi

  if [[ "$1" = "update" ]]; then
    local nvm_version="v0.40.4"
    # The 'PROFILE=/dev/null' prefix prevents the script from auto-updating any of the shell profile configs
    eval "PROFILE=/dev/null zsh -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh | bash'"
  else
    command nvm $@
  fi
}

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
