#!/usr/bin/env zsh

########################################################################################################################
#SCRIPT:                        wpi_diffs.zsh
#PLATFORMS:                     GNU/Linux
#AUTHOR(s):                     Larson, Micah P.
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ----------------------------------------------------------------------------------------
#  0.1.0.0  2012.07.25  MPL     Converted from hack.
#  0.2.0.0  2012.07.25  MPL     Documented.
#  0.2.1.0  2012.08.21  MPL     Added check_path(), removed commented-out code.
#  0.3.0.0  2012.08.27  MPL     Added ClearQuest password workaround.
#  0.3.1.0  2013.03.21  MPL     Added -m switch.
#
########################################################################################################################
#HELP TEXT:
#-  This script uses beyond compare to display the changes for specified DRs.
#-
#-  Usage:
#-    EXE_NAME {-hlmqv} {-p pattern} {-s number} [DR...]
#-
#-  Available options:
#-    -h
#-        Displays this help text.
#-
#-    -l
#-        List files (rather than comparing).
#-
#-    -m
#-        Show commits to .../espn only.
#-
#-    -p [pattern]
#-        Only print or compare files that match the specified regular expression.
#-
#-    -q
#-        Prints the ClearQuest results only (version information).
#-
#-    -s [number]
#-        Skip the first ${number} files. This is useful for resuming a previously interrupted review.
#-
#-    -v
#-        Print verbose explanations.
#-
#-
#-  Examples:
#-    EXE_NAME 464               #compare the changes committed under ESPDB00000464
#-
#-    EXE_NAME -m 464            #compare the changes committed under ESPDB00000464 to /main/espn/
#-
#-    EXE_NAME -p '\.xml@@' 464  #compare the changes committed under ESPDB00000464 matching pattern '\.xml@@'
#-
#-    EXE_NAME 464 465           #compare the changes committed under ESPDB00000464 and ESPDB00000465
#-
########################################################################################################################
#+NOTES:
#+  (1) this script relies on /vobs/scm_tools/clearquest/scripts/changeset.pl for key functionality
#+  (2) this script will fail on files that have been moved after the ClearQuest record has been created
#+
########################################################################################################################

autoload -U colors && colors

##
# Check whether clearquest is assessible; prompt for username/password as necessary.
#
check_clearquest() {
  if [[ ! -e ${CQCC_CACHE_ROOT:=/net/ccview/ccstg/viewstore/cqcc}/$(whoami)/$(hostname) ]]; then
    read 'uname?Enter ClearQuest username: '
    read -s 'passwd?Enter ClearQuest password: '
    print #extra line gives better user feedback
    /vobs/scm_tools/clearquest/scripts/changeset.pl -i 1 <<< "${uname},${passwd}" &> /dev/null
    unset uname passwd
    return 0 #assume it worked (i don't care to error-check what's coming out of that stupid perl script)
  elif [[ ! -d ${CQCC_CACHE_ROOT} ]]; then
    print -u 2 "${CQCC_CACHE_ROOT} not found"
    return 1
  else
    return 0
  fi
}

##
# Check whether necessary executables are on the path.
#
# @return 1 if one or more executables can't be found, 0 otherwise
#
check_path() {
  local -i ret_val=0
  
  for exe in $@; do
    if which $exe &> /dev/null; then
    else
      print -u 2 "${fg[red]}${exe}${reset_color} not found"
      ret_val=$((ret_val + 1))
    fi
  done
  
  return $ret_val
}

##
# Check whether a view is set and alert the user if it isn't.
#
# @return 1 if no view is set, 0 otherwise
#
check_view() {
  if [[ -z "${CLEARCASE_ROOT}" ]]; then
    print -u 2 "${fg[red]}no view set${reset_color}"
    return 1
  fi
  return 0
}

##
# Compare files to their predecessors.
#
# @param 1  the DR number
# @param 2  the starting index
# @param 3+ versioned file(s) (file@@/version)
# @return 1 if no files were specified, 0 otherwise
#
compare_files() {
  local dr_number=$1
  local start_index=$2
  diff_files=( ${@[3,-1]} )
  
  if [[ 0 < "${#diff_files}" ]]; then
    (( ${+verbose} )) && printf "ESPDB%08d: comparing %d files (Ctrl+C to cancel)\n" ${dr_number} ${#diff_files}
  else
    printf "ESPDB%08d: no files to compare\n" ${dr_number} 1>&2 #printf doesn't support -u
    return 1
  fi
  
  typeset -i counter=${start_index}
  typeset -i num_files=$(( ${#diff_files} + ${start_index} ))
  for diff in ${diff_files}; do
    counter=$((counter + 1))
    parts=( ${(s.@@.)diff} )
             file=${parts[ 1]}
    final_version=${parts[-1]}
    if [[ -d $file ]]; then
      (( ${+verbose} )) && printf "${fg[cyan]}%3d/%d${reset_color}: ${fg[blue]}%s${reset_color} (skip)\n" \
          "${counter}" "${num_files}" "${file}"
    elif [[ ! -r ${file} ]]; then
      if (( ${+verbose} )); then
        printf "${fg[cyan]}%3d/%d${reset_color}: ${fg[red]}%s${reset_color} - ${fg_bold[red]}file not found${reset_color}\n" \
            "${counter}" "${num_files}" "${file}@@${final_version}"
      else
        print -u 2 "cannot find ${file}"
      fi
    else
      initial_version=$(cleartool describe -fmt "%PSn\n" ${file}@@${final_version})
      compare_file ${file} ${initial_version} ${final_version} ${counter} ${num_files}
    fi
  done
  return 0
}

compare_file() {
  if (( ${+clearquest} )); then
    payload="${file}@@${initial_version}:${file}@@${final_version}"
    if (( ${+verbose} )); then
      printf "${fg[cyan]}%3d/%d${reset_color}: %-80s ${fg[yellow]}%s${reset_color}\n" \
        "${counter}" "${num_files}" "${payload}"
    else
      print "${payload}"
    fi
  elif [[ 0 == $(stat -c "%s" "${file}@@${initial_version}") ]]; then
    (( ${+verbose} )) && printf "${fg[cyan]}%3d/%d${reset_color}: %-80s ${fg[yellow]}%s${reset_color}\n" \
        "${counter}" "${num_files}" "${file}" "(new file)"
    gvim --nofork ${file}@@${final_version}
  else
    (( ${+verbose} )) && printf "${fg[cyan]}%3d/%d${reset_color}: %-80s ${fg[yellow]}%s${reset_color}\n" \
        "${counter}" "${num_files}" "${file}" "(${initial_version}:current)"
    bcompare -ignoreunimportant ${file}@@${initial_version} ${file}@@${final_version} &> /dev/null
  fi
}

##
# Filter things not on main branch (if -m specified)
#
# @env main_only if set, filter all commits not on main branch
#
match_branch() {
  egrep -e "${${main_only+espn/[0-9]}:-.*}"
}

##
# Filter things not matching pattern (if -p specified)
#
# @env pattern the pattern to match (default: *)
#
match_pattern() {
  egrep -e "${pattern:=.*}"
}

##
# Print help text and exit.
#
# @param 1 the name of the enclosing script
# @param 2 the exit code
# @env verbose prints notes, etc.
#
print_help_and_exit() {
  local executable="$1"
  local exit_code="$2"
  echo -e "${executable##*/}: help"
  
  local pattern="^#[-]${verbose:+|^#[+]}"
  egrep $pattern "$executable" | cut -c3- | sed "s:EXE_NAME:${executable##*/}:"
  exit ${exit_code:=1}
}

########################################################################################################################
# MAIN FUNCTION

unset clearquest list main_only pattern skip verbose

while getopts ":hlmp:qs:v" option; do
  case "$option" in
    h) print_help_and_exit "$0" 0 ;;
    l) list=TRUE                  ;;
    m) main_only=TRUE             ;;
    p) pattern="${OPTARG}"        ;;
    q) clearquest=TRUE            ;;
    s) skip="${OPTARG}"           ;;
    v) verbose=TRUE               ;;
    *) print_help_and_exit "$0" 1
  esac
done

shift $((OPTIND - 1))

if [[ 0 == "$#" ]]; then
  print -u 2 "please specify a DR number, e.g. 25"
  exit 1
fi

check_path cleartool bcompare || exit 1
check_view                    || exit 1
check_clearquest              || exit 1

for dr_number in $@; do
  files_to_compare=( $(/vobs/scm_tools/clearquest/scripts/changeset.pl -i ${dr_number} | match_pattern | match_branch) )
  
  (( ${+skip} )) && files_to_compare=( ${files_to_compare[$((skip+1)),-1]} )
  if (( ${+list} )); then
    print ${(Fu)files_to_compare}
  else
    compare_files ${dr_number} ${skip:=0} ${files_to_compare}
  fi
done

