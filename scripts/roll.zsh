#!/usr/bin/env zsh
################################################################################
#SCRIPT:                        roll.zsh
#PLATFORMS:                     GNU/Linux
#AUTHOR(s):                     Larson, MP
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ------------------------------------------------
#  0.1.0.0  2011.04.25  MPL     Basic functionality complete.
#
################################################################################
#HELP TEXT:
#-  This script automates decision-making.
#-
#-  Usage:
#-    EXE_NAME {-v} {[COUNT]d[TYPE]}
#-
#-  Available options:
#-    -h
#-        Prints this help
#-
#-    -v
#-        Verbose mode
#-
#-  Optional Argument:
#-    [COUNT]d[TYPE]
#-        The number and type of dice to roll (default is 1d6).
#-
#-
#-  Examples:
#-    EXE_NAME 1d3   #Rolls 1 3-sided die
#-
################################################################################
#NOTES:
#
################################################################################

################################################################################
# FUNCTIONS
################################################################################
##
# Print usage/help text.
#
# @param exe_name the name of the enclosing script
#
usage() {
  print "${1##*/}: help"
  grep "^#-" "$1" | cut -c3- | sed "s:EXE_NAME:${1##*/}:"
}

################################################################################
# SETUP
################################################################################
unset verbose
results=()

################################################################################
# MAIN
################################################################################
while getopts "hv" option; do
  case "$option" in
    h) usage "$0"; exit 0;;
    v) verbose=1;;
    *) usage "$0"; exit 1;;
  esac
done

shift $((OPTIND - 1))

arguments=( ${(s:d:)${1:=1d6}} )
n=${arguments[1]}
s=${arguments[2]}

print -f "%dd%d:${verbose:+\n}" $n $s

for cast in {1..$n}; {
  results+="$[${RANDOM}%${s}+1]"
  (( ${+verbose} )) && print -f "%3d\n" ${results[${cast}]}
}

print -f "${verbose:+---\n}%3d\n" $(( ${(j.+.)results} ))

exit 0

