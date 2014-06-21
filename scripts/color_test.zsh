#!/usr/bin/env zsh

################################################################################
#SCRIPT:	color_test.zsh
#PLATFORMS:	GNU/Linux
#AUTHOR(s):	Larson, MP
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ----------------------------------------
#  0.2.0.0  2010.01.20  MPL     Filtering added.
#  0.1.0.0  2010.01.19  MPL     Basic functionality complete.
#
################################################################################
#HELP TEXT:
#-  This script prints the color scheme.
#-
#-  Usage:
#-    EXE_NAME {-t test_id} {-h}
#-
#-  Available options:
#-    -t [test id]
#-        Prints the color scheme in the specified test layout, 1 to 3 (default: 1)
#-
#-    -h
#-        Displays this help text
#-
#-  Example:
#-    EXE_NAME -t 2		#prints color scheme using layout #2
#-
################################################################################
#NOTES:
#
#TODO:
#  (1) Test on other platforms/hosts
################################################################################

FGNAMES=(' black ' ' red ' ' green ' ' yellow ' ' blue ' ' magenta ' ' cyan ' ' white ')
BGNAMES=('DFT' 'BLK' 'RED' 'GRN' 'YEL' 'BLU' 'MAG' 'CYN' 'WHT')
H_LINE='     +-------------------------------------------------------------------------+'

##
# Print help text and exit.
#
# @param exe_name the name of the enclosing script
#
print_help_and_exit() {
  echo -e "${1##*/}: help"
  grep "^#-" "$1" | cut -c3- | sed "s:EXE_NAME:${1##*/}:"
  exit 0
}

##
# Prints color scheme
#
print_test_1() {
  T='gYw'
  echo -e "\n                 40m     41m     42m     43m     44m     45m     46m     47m"

  for FGs in '    m' '   1m' '  30m' '1;30m' '  31m' '1;31m' '  32m' \
             '1;32m' '  33m' '1;33m' '  34m' '1;34m' '  35m' '1;35m' \
             '  36m' '1;36m' '  37m' '1;37m'; do
    FG=${FGs// /}
    echo -en " $FGs \033[$FG  $T  "
    for BG in '40m' '41m' '42m' '43m' '44m' '45m' '46m' '47m'; do
      echo -en "$EINS \033[$FG\033[$BG  $T  \033[0m"
    done
    echo
  done
  echo
}

##
# Prints color scheme
#
print_test_2() {
  echo -e "$H_LINE"
  for b in {0..8}; do
    ((b > 0)) && bg=$((b + 39))
    
    print_background_line "${BGNAMES[$((b + 1))]}"
    print_background_line "   " bold
    
    ((b < 8)) && echo -e "$H_LINE"
  done
  echo -e "$H_LINE"
}

##
# Prints line with label $1 and style $2
#
print_background_line() {
  echo -en "\033[0m $1 | "
  print_foreground_colors $2
  echo -e "\033[0m |"
}

##
# Prints the colors in a line with style $1
#
print_foreground_colors() {
  [[ "$1" == 'bold' ]] && local bold='1;'
  for f in {1..8}; do
    echo -en "\033[${bg}m\033[${bold}$((f + 29))m ${FGNAMES[$f]} "
  done
}

#===============================================================================
# MAIN FUNCTION
#===============================================================================
unset TEST

while getopts "t:h" option; do
  case "$option" in
    t)
      TEST="$OPTARG";;
    h)
      print_help_and_exit $0;;
    *)
      echo "$option :: $OPTARG"
  esac
done

case "$TEST" in
  2) print_test_2;;
  *) print_test_1
esac


