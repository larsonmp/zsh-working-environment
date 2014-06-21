#!/usr/bin/env zsh

########################################################################################################################
#SCRIPT:                        ex.zsh
#PLATFORMS:                     GNU/Linux
#AUTHOR(s):                     Larson, Micah P.
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ----------------------------------------------------------------------------------------
#  0.1.0.0  2011-08-29  MPL     Converted from zsh function.
#
########################################################################################################################
#HELP TEXT:
#-  This script extracts an archive file.
#-  
#-  Usage:
#-    EXE_NAME {-h} {-v} [file ...]
#-  
#-  Available options:
#-    -h
#-        Display this help text.
#-  
#-    -v
#-        Print the name of each file as it is extracted.
#-  
#-  Examples:
#-    EXE_NAME -v ./downloads/neat_stuff.zip   #extract the zip file, with verbose output
#-    
########################################################################################################################
# Extract a file based on its extension
extract() {
  if [[ -f "$1" ]] {
    case "${1}" in
      *.tar)              tar xf     $1 ${VERBOSE_FLAG:+-v};;
      *.tar.bz2 | *.tbz2) tar xjf    $1 ${VERBOSE_FLAG:+-v};;
      *.tar.gz | *.tgz)   tar xzf    $1 ${VERBOSE_FLAG:+-v};;
      *.bz2)              bunzip2       ${VERBOSE_FLAG:+-v} $1;;
      *.gz)               gunzip        ${VERBOSE_FLAG:+-v} $1;;
      *.zip)              unzip         ${VERBOSE_FLAG--qq} $1;;
      *.rar)              unrar x                           $1;;
      *.Z)                uncompress                        $1;;
      *.7z)               7z x                              $1;;
      *) print "${1} cannot be extracted"
    esac
  } else {
    print "\"${1}\" is not a valid file"
  }
}

##
# Print help text and exit.
#
# @param 1 the name of the enclosing script
#
print_help_and_exit() {
  print "${1##*/}: help"
  grep "^#-" "$1" | cut -c3- | sed "s:EXE_NAME:${1##*/}:"
  exit 0
}

########################################################################################################################
# MAIN FUNCTION
unset VERBOSE_FLAG

while getopts "hv" option; do
  case "$option" in
    h) print_help_and_exit "$0";;
    v) typeset -r VERBOSE_FLAG;;
    *) print_help_and_exit "$0"
  esac
done

shift $((OPTIND - 1))

for file in "$@"; do
  extract "$file"
done

