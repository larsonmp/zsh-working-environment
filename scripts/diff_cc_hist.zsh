#!/usr/bin/env zsh

########################################################################################################################
#SCRIPT:                        diff_cc_hist.zsh
#PLATFORMS:                     GNU/Linux
#AUTHOR(s):                     Larson, Micah P.
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ----------------------------------------------------------------------------------------
#  0.1.0.0  2012-02-20  MPL     Initial creation.
#  0.2.0.0  2012-02-21  MPL     Cleaned up, documented.
#
########################################################################################################################
#HELP TEXT:
#-  Sequential diff of all files (not directories) changed since a given date.
#-  
#-  Usage:
#-    EXE_NAME {-d date} {-h} [path to cleartool]
#-  
#-  Argument(s):
#-    [path to clearcase]
#-        the full path to dir that contains the cleartool executable; this
#-        argument can be omitted if cleartool is already on the user's path
#-  
#-  Available options:
#-    -d [date]
#-        Set cutoff date (files changed after this date are displayed);
#-        understands any date that GNU date can understand; defaults to
#-        1 week prior.
#-  
#-    -h
#-        Display this help text.
#-  
#-  Examples:
#-    EXE_NAME -d '2 days ago'
#-    
########################################################################################################################
#-NOTES:
#-  (1) To use bcompare for graphic diffs, go to ${CLEARCASE_HOME}/lib/mgrs/ and, for each relevant CC type manager,
#-      change the xcompare link to point to /usr/bin/bcompare (or wherever your bcompare executable is).
#-      
#-      I only changed the links in _html2, _xml2, text_file_delta, and utf8_file_delta.
#-      
#-      cleartool makes a lot of noise at this point, complaining for each diff'd file "cleartool: Error: Type manager
#-      ${manager} failed xcompare operation," but fear not, I sent all of this nonsense straight to /dev/null.
#-
#-TODO:
#-  (1) Compare with version at specified date, rather than with predecessor.
#-
########################################################################################################################
#takes an optional arg, date, that sets the cutoff for diffs; that is, only
#  files that changed after this date are diffed (defaults to a week ago)

##
# Look for cleartool, exit if it can't be found
#
check_env() {
  which cleartool &> /dev/null
  if [[ 0 -ne $? ]]; then
    print -u 2 'no cleartool on path'
    exit 1
  fi
}

##
# Compare each file in $@ to its predecessor
#
# @param list (array) of files to compare
#
compare_versions() {
  local current=0
  for file in $@; do
    current=$(( ${current} + 1 ))
    printf "file %03d/%03d: $file\n" ${current} ${#diffs}
    if [[ -f $file ]]; then
      cleartool diff -g -pre $file 2> /dev/null #sending to /dev/null to hide retarded errors about failing type
                                                #  managers (clearcase is the worst)
    else
      print "skipping directory: $file"
    fi
  done
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
unset DATE

while getopts "d:h" option; do
  case "$option" in
    d) DATE="${OPTARG}";;
    h) print_help_and_exit "$0";;
    *) print_help_and_exit "$0"
  esac
done

shift $((OPTIND - 1))
[[ -n "$1" ]] && path=($path $1)

check_env #look for clearcase

date=$(date --date="${DATE:=1 week ago}" +'%Y-%m-%d')
diffs=( $(cleartool lsh -since ${date} -r -s | awk -F@ '{print $1}' | sort -u ) )

compare_versions ${(@)diffs}

