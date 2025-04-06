# Available colors
# red, blue, green, cyan, yellow, magenta, black, white
 
PROMPT='%{$fg[green]%}________________________________________________________________________________'$'\n'
PROMPT+="%(?:⎜:%{$fg_bold[red]%}⎜)"
PROMPT+=' %{$fg_bold[yellow]%}%~%{$reset_color%} $(git_prompt_info)'
 
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[cyan]%}[%{$fg_bold[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$reset_color%}%{$fg[cyan]%}] %{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}%{$fg[cyan]%}] %{$fg_bold[green]%}✓"
