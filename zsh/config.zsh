# fpath=($fpath "$ZSH/custom/profiles")
# autoload -Uz common.zsh
source "$ZSH/custom/profiles/common.zsh"

[[ -f "$ZSH/custom/profiles/personal.zsh" ]] && source "$ZSH/custom/profiles/personal.zsh"

# potential way to check if on a work laptop?
# system_profiler SPConfigurationProfileDataType | grep -i buspatrol
