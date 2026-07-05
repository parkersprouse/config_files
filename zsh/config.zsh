# - () { ... } is zsh's anonymous-function syntax - define and immediately invoke, no name registered anywhere afterward.
#   It's the standard "I want a real local scope right here, but I don't want a named function cluttering the namespace forever."
#
# - The reason source-ing from inside an anonymous function wrapper still works correctly is a subtlety of zsh scoping:
#   a bare assignment (no local) inside a function only becomes function-scoped if that name was already declared local
#   by an enclosing scope. Since none of these loaded files declare `local FOO` for their exports/functions, everything
#   they set (`export PATH=...`, `alias`, `function` definitions, `precmd_functions+=(...)`) still lands in global scope -
#   only the variables explicitly set as scoped get scoped.
#
# - On that note, `fpath` itself is a pre-existing global special array, so reassigning it from inside the function still
#   mutates the real global `fpath` - scoping in zsh applies to new bindings, not to reassignment of something that
#   already exists globally.

() {
  # define "profile_funcs" as an array
  local -a profile_funcs

  # Configuration, functions, and aliases common to all environments
  fpath=("$ZSH/custom/profiles/common" $fpath)
  profile_funcs=("$ZSH/custom/profiles/common"/*(N:t))
  # verify that function files actually exist before attempting to autoload them - otherwise zsh will fallback to
  #   loading *all* functions (including built-in / stdlib ones)
  (( ${#profile_funcs} )) && autoload -Uz $profile_funcs
  [[ -f "$ZSH/custom/profiles/common.zsh" ]] && source "$ZSH/custom/profiles/common.zsh"

  if [[ -f "$ZSH/custom/work_env" ]]; then
    # Configuration, functions, and aliases specific to my work environment
    fpath=("$ZSH/custom/profiles/work" $fpath)
    profile_funcs=("$ZSH/custom/profiles/work"/*(N:t))
    (( ${#profile_funcs} )) && autoload -Uz $profile_funcs
    [[ -f "$ZSH/custom/profiles/work.zsh" ]] && source "$ZSH/custom/profiles/work.zsh"
  else
    # Configuration, functions, and aliases specific to my personal environment
    fpath=("$ZSH/custom/profiles/personal" $fpath)
    profile_funcs=("$ZSH/custom/profiles/personal"/*(N:t))
    (( ${#profile_funcs} )) && autoload -Uz $profile_funcs
    [[ -f "$ZSH/custom/profiles/personal.zsh" ]] && source "$ZSH/custom/profiles/personal.zsh"
  fi
}
