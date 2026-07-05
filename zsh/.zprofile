# ------------------------
# This function exists in here and not with the rest of the `.zshrc` configuration so that it
#   can be available to external tools that invoke zsh commands, like Forklift.
# ------------------------

# # Save all content names to text file [NAME]
# output=$(ls -A1 | sort)
# echo $output > $all_output_fname

# # Save all content names to text file [DATE]
# output=$(find . -mindepth 1 -maxdepth 1 -printf "%T@^%f\n" | sort -k1,1r | cut -d'^' -f2)
# echo $output > $all_output_fname

# # Save file names to text file [NAME]
# output=$(find . -mindepth 1 -maxdepth 1 -type f)
# echo $output > $files_output_fname

# # Save file names to text file [DATE]
# output=$(find . -mindepth 1 -maxdepth 1 -type f -printf "%T@^%f\n" | sort -k1,1r | cut -d'^' -f2)
# echo $output > $files_output_fname

# # Save folder names to text file [NAME]
# output=$(find . -mindepth 1 -maxdepth 1 -type d)
# echo $output > $directories_output_fname

# # Save folder names to text file [DATE]
# output=$(find . -mindepth 1 -maxdepth 1 -type d -printf "%T@^%f\n" | sort -k1,1r | cut -d'^' -f2)
# echo $output > $directories_output_fname

save() {
  ARGS_HELP=("-h" "--help")
  ARGS_SORT_NAME=("-n" "--name")
  ARGS_SORT_TIME=("-t" "--timestamp")
  ARGS_TARGET_DIRS=("-d" "--directories")
  ARGS_TARGET_FILES=("-f" "--files")

  date_str=$(date +'%Y.%m.%d')
  all_output_fname="_content_${date_str}.txt"
  files_output_fname="_files_${date_str}.txt"
  directories_output_fname="_directories_${date_str}.txt"

  output=""
  output_filename=$all_output_fname

  if ! (( $# )); then
    # Save all content names to text file [NAME] by default
    output=$(ls -A1 | sort)
  else
    for arg in $@; do
      if (( $ARGS_TARGET_FILES[(Ie)$arg] )); then
        output_filename=$files_output_fname
      elif (( $ARGS_TARGET_DIRS[(Ie)$arg] )); then
        output_filename=$directories_output_fname
      elif (( $ARGS_SORT_NAME[(Ie)$arg] )); then
        content=""
        if [[ $* = *"-d"* ]]; then
          content=$(find . -mindepth 1 -maxdepth 1 -type d)
        elif [[ $* = *"-f"* ]]; then
          content=$(find . -mindepth 1 -maxdepth 1 -type f)
        else
          content=$(ls -A1 | sort)
        fi
        output=$($content | cut -f 2 -d '/' | sort)
      elif (( $ARGS_SORT_TIME[(Ie)$arg] )); then
        content=""
        if [[ $* = *"-d"* ]]; then
          content=$(find . -mindepth 1 -maxdepth 1 -type d -printf "%T@^%f\n")
        elif [[ $* = *"-f"* ]]; then
          content=$(find . -mindepth 1 -maxdepth 1 -type f -printf "%T@^%f\n")
        else
          content=$(find . -mindepth 1 -maxdepth 1 -printf "%T@^%f\n")
        fi
        output=$($content | sort -k1,1r | cut -d'^' -f2)
      elif (( $ARGS_HELP[(Ie)$arg] )); then
        show_save_help
      else
        return_error "Unexpected argument: '$arg'\nUse '-h' or '--help' for usage"
      fi
    done
  fi

  echo $output > $output_filename
}
autoload save

# Save file names to text file [NAME]
# savefiles() {
#   typeset -l arg1
#   arg1=$1

#   if [ -n $arg1 ] && (( $valid_sorts[(Ie)$arg1] )); then
#     echo "saving files using provided sorting arg [ $arg1 ]"
#   else
#     echo "saving files using default sorting arg [ name ]"
#   fi
# }

# savefolders() {
#   typeset -l arg1
#   arg1=$1

#   if [ -n "$arg1" ] && (( $valid_sorts[(Ie)$arg1] )); then
#     echo "saving folders using provided sorting arg [ $arg1 ]"
#   else
#     echo "saving folders using default sorting arg [ name ]"
#   fi
# }

show_save_help() {
  echo "[Usage]
  save [ -f | --files ] ..... save files
       [ -d | --directories ] save directories
       [ -n | --name ] ...... sort by name
       [ -t | --time ] ...... sort by last updated

[Note]
  Only one argument from each set of [ -f | -d ]
  and [ -n | -t ] can be used at a time."
}
