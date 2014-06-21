#!/usr/bin/env zsh

########################################################################################################################
#SCRIPT:                        efind.zsh
#PLATFORMS:                     GNU/Linux
#AUTHOR(s):                     Larson, Micah P.
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ----------------------------------------------------------------------------------------
#  0.1.0.0  2011-08-29  MPL     Basic functionality complete.
#  0.1.1.0  2011-08-30  MPL     Added -f option.
#  0.1.2.0  2012-05-17  MPL     Added -L and -p options.
#
########################################################################################################################
#HELP TEXT:
#-  This script wraps a find/grep/less pipeline for convenience. Ingores .svn directories.
#-  
#-  Usage:
#-    EXE_NAME {-Lbhilpw} {-d directory} {-e error_log} {-f find_pattern} [grep_pattern]
#-  
#-  Available options:
#-    -L
#-        Follow symbolic links.
#-    
#-    -b
#-        Show binary matches.
#-    
#-    -d [directory]
#-        The root directory to search (default is .).
#-    
#-    -e
#-        The log file for stdout of grep command (default is /dev/null); stderr
#-          of script itself is unaffected by this option.
#-    
#-    -f [find_pattern]
#-        The pattern to match against file basenames (the path with the leading
#-          directories removed).  The metacharacters (‘*’, ‘?’, and ‘[]’) match
#-          a ‘.’ at the start of the base name.  Braces, {}, are not recognised
#-          as being special, despite the fact that some shells imbue them with
#-          a special meaning in shell patterns.
#-        Don’t forget to enclose the pattern in quotes in order to protect it
#-          from expansion by the shell.
#-        The default pattern is '*'.
#-    
#-    -h
#-        Display this help text.
#-  
#-    -i
#-        Ignore case when matching.
#-    
#-    -l
#-        List matching files rather than matching lines.
#-  
#-    -p
#-        Print to standard out (don't use pager).
#-    
#-    -w
#-        Show whole-word matches only.
#-    
#-  
#-  Examples:
#-    EXE_NAME -d ../.. "bob"      #search for "bob" from 2 dirs up the tree
#-    
#-    EXE_NAME -f "*.zsh" "^$"     #search for blank lines in zsh scripts
#-    
########################################################################################################################

##
# Wraps (find | xargs grep); usage: search [grep_pattern] [search_path (dir)] [search_pattern]
#
# @param 1 the pattern for grep
# @param 2 the root dir for find
# @param 3 the pattern for find
# @env BINARY_FLAG ignore binary files if set to -I
# @env ERROR_LOG where stderr of grep is redirected
# @env IGNORE_CASE_FLAG enable case insensitive matching
# @env LINK_FLAG follow symbolic links
# @env LIST_FLAG list filenames rather than lines matched
# @env WHOLE_WORD_FLAG ignore partial-word matches
#
search() {
  local f_flags="${LINK_FLAG}"
  local g_flags="${BINARY_FLAG}${WHOLE_WORD_FLAG}${LIST_FLAG}${IGNORE_CASE_FLAG}"
  find ${f_flags:+-$f_flags} ${2} -path '*/.svn*' -prune -type f -name ${3} -o -print0 | xargs -0 grep ${g_flags:+-$g_flags} ${1} --color=force 2> ${ERROR_LOG}
}

##
# Print help text and exit.
#
# @param 1 the name of the enclosing script
#
print_help_and_exit() {
  echo -e "${1##*/}: help"
  grep "^#-" "$1" | cut -c3- | sed "s:EXE_NAME:${1##*/}:"
  exit 0
}

########################################################################################################################
# MAIN FUNCTION
unset grep_pattern find_pattern WHOLE_WORD_FLAG LIST_FLAG IGNORE_CASE_FLAG LINK_FLAG
root_dir=.
ERROR_LOG=/dev/null
BINARY_FLAG='I' #ignore binary files by default
use_less=TRUE

while getopts "Lbd:e:f:hilpw" option; do
  case "$option" in
    L) LINK_FLAG=L;;
    b) unset BINARY_FLAG;;
    d) root_dir="$OPTARG";;
    e) ERROR_LOG="$OPTARG";;
    f) find_pattern="$OPTARG";;
    h) print_help_and_exit "$0";;
    i) IGNORE_CASE_FLAG='i';;
    l) LIST_FLAG='l';;
    p) unset use_less;;
    w) WHOLE_WORD_FLAG='w';;
    *) print_help_and_exit "$0"
  esac
done

shift $((OPTIND - 1))
grep_pattern=$1

if [[ ! -d ${root_dir} ]] {
  print -u 2 "path must be a directory (you supplied ${root_dir}): defaulting to ."
  root_dir=.
}

if [[ -e "${ERROR_LOG}" && "${ERROR_LOG}" != '/dev/null' ]] {
  print -u 2 "error log file already exists; defaulting to /dev/null"
  ERROR_LOG=/dev/null
} else {
  touch "${ERROR_LOG}"
}

if (( ${+use_less} )) {
  search ${grep_pattern} ${root_dir} ${find_pattern:=*} | less -FR
} else {
  search ${grep_pattern} ${root_dir} ${find_pattern:=*}
}

