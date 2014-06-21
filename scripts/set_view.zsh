#!/usr/bin/env zsh

########################################################################################################################
#SCRIPT:                        set_view.zsh
#PLATFORMS:                     GNU/Linux
#AUTHOR(s):                     Larson, Micah P.
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ----------------------------------------------------------------------------------------
#  0.1.0.0  2011.06.02  MPL     Documented.
#
########################################################################################################################
#HELP TEXT:
#-  This script displays views matching a specified pattern, and allows the user to set one as the current view.
#-
#-  Usage:
#-    EXE_NAME {-a} {-h} [PATTERN]
#-
#-  Available options:
#-    -a
#-        List all views
#-
#-    -h
#-        Displays this help text
#-
#-
#-  Examples:
#-    EXE_NAME bob                #list views with "bob" in their name
#-
#-    EXE_NAME '[jtk]im'          #list views with "jim" or "tim" or "kim" in their name
#-
#-    EXE_NAME                    #list views with "USER_NAME" in their name
#-
########################################################################################################################
#-
#-NOTES:
#-
#-TODO:
#-  (1) Test on other platforms/hosts
########################################################################################################################

##
# Print help text and exit.
#
# @param exe_name the name of the enclosing script
#
print_help_and_exit() {
  print "${1##*/}: help"
  grep "^#-" "$1" | cut -c3- | sed -e "s:EXE_NAME:${1##*/}:" -e "s:USER_NAME:${USERNAME}:"
  exit 0
}

##
# Return 1 if cleartool was found in path, 0 otherwise
#
check_for_cleartool() {
  if ! type cleartool &> /dev/null; then
    print -u 2 "Unable to find ClearCase client; exiting..."
    return 0
  fi
  return 1
}

unset ALL_FLAG LIST_FLAG

while getopts "ahl" option; do
  case "$option" in
    a) ALL_FLAG=TRUE            ;;
    h) print_help_and_exit "$0" ;;
    l) LIST_FLAG=TRUE           ;;
    *) print_help_and_exit "$0" ;;
  esac
done

shift $((OPTIND - 1)) #trim off tagged arguments (should leave path)

check_for_cleartool && exit 1

if (( ${+ALL_FLAG} )); then
  KW=('.*')
elif [[ "$#" > 0 ]]; then
  KW=("$@")
else
  KW=( $(whoami) )
fi

views=( $(cleartool lsview | awk "/${(j.|.)KW}/"' {print $(NF-1)}' | sort ) )

if (( ${+LIST_FLAG} )); then
  print ${(F)views}
  exit 0
fi

[[ 1 == ${#views} ]] && exec cleartool setview "${views[1]}"

PS3='Selection (number): '
select selection in "${(@)views}" exit; do
  case "$selection" in
    exit|quit) echo "Exiting...";                   break;;
    *)         exec cleartool setview "$selection"; break;;
  esac
done

unset PS3
exit 0

