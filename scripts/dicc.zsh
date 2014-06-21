#!/usr/bin/env zsh

########################################################################################################################
#SCRIPT:                        dicc.zsh
#PLATFORMS:                     GNU/Linux
#AUTHOR(s):                     Larson, Micah P.
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ----------------------------------------------------------------------------------------
#  0.1.0.0  2012.06.18  MPL     Initial creation.
#
########################################################################################################################
#HELP TEXT:
#-  This script uses beyond compare to diff clearcase files.
#-
#-  Usage:
#-    EXE_NAME {-hil} [file...]
#-
#-  Available options:
#-    -i
#-        Interactive: for each file, prompt with available versions before comparison.
#-
#-    -l
#-        List all versions of file(s).
#-
#-    -h
#-        Displays this help text
#-
#-
#-  Examples:
#-    EXE_NAME ./build.xml        #Compare build.xml with previous version.
#-
########################################################################################################################
#+NOTES:
#+  (1) this script is still work in progress
#+
#+TODO:
#+  (1) add -v option to print "comparing <version> with current" for each file, a la wpi_diffs.zsh
#+
########################################################################################################################

print_versions() {
  cleartool lshistory -s "$1" 2> /dev/null | awk -F@ '{print $NF}' | grep -v "^$"
}

print_predecessor() {
  cleartool describe -pred -s $1 2> /dev/null
}

print_help_and_exit() {
  local executable="$1"
  local exit_code="$2"
  echo -e "${executable##*/}: help"
  
  local pattern="^#[-]${verbose:+|^#[+]}"
  egrep $pattern "$executable" | cut -c3- | sed "s:EXE_NAME:${executable##*/}:"
  exit ${exit_code:=1}
}

unset LIST_FLAG INTERACTIVE_FLAG

################################################################################
# MAIN FUNCTION
while getopts "hil" option; do
  case "$option" in
    h) print_help_and_exit "$0" 0 ;;
    i) INTERACTIVE_FLAG=TRUE      ;;
    l) LIST_FLAG=TRUE             ;;
    *) print_help_and_exit "$0" 1
  esac
done

shift $((OPTIND - 1))

if (( $# < 1 )); then
  print -u 2 "usage: ${0##*/} [file]"
  exit 1
fi

for file in $@; do
  local version
  if (( ${+LIST_FLAG} )); then
    print_versions "$file"
    continue
  elif (( ${+INTERACTIVE_FLAG} )); then
    versions=( $(print_versions $file) ) || exit 1
    print "Select a version for comparison:"
    PS3='Selection (number): '
    select v in $versions; do
      version=$v
      break
    done
    unset PS3
  else
    version=$(print_predecessor $file)
  fi
  bcompare ${file}@@${version} $file &
  sleep 0.5
done

