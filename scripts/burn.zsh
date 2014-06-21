#!/usr/bin/env zsh
########################################################################################################################
#SCRIPT:                        burn.zsh
#PLATFORMS:                     GNU/Linux
#AUTHOR(s):                     Larson, MP
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ----------------------------------------------------------------------------------------
#  0.1.0.0  2011.04.20  MPL     Basic functionality complete.
#
########################################################################################################################
#HELP TEXT:
#-  This script automates part of the burning process for large amounts of data.
#-
#-  Usage:
#-    EXE_NAME {-h} {-l} {-n name} {-r signature} {-v} [FILE ...]
#-
#-  Available options:
#-    -h
#-        Displays this help text
#-
#-    -l
#-        Log some output (rather than piping it to /dev/null)
#-
#-    -n name
#-        Sets the volume label (the name of the disk)
#-
#-    -r signature
#-        Sets the signature to use for encryption (defaults to Micah's)
#-
#-    -v
#-        Verbose mode
#-
#-
#-  Examples:
#-    EXE_NAME -ln "poodle hat" file.txt   #burns a disk named "poodle hat" and logs some output
#-
########################################################################################################################
#-
#-NOTES:
#-
#-TODO:
#-  (1) Test on other platforms/hosts
########################################################################################################################

########################################################################################################################
# FUNCTIONS
########################################################################################################################
##
# Remove all temporary files.
#
clean_up() {
  rm ${pipe} ${tar_file} ${(@)parts} ${iso_file} {${(j.,.)parts}}.gpg &> $log_file
}

##
# Check optical drive for medium.
#
# codes:
#   58    no medium
#
check_cd() {
  print -f "%d" $(isoinfo -l dev=${device} |& awk '/Sense Code/ {print $3}')
}

##
# Poll the optical drive until a blank disk is inserted (this needs work)
#
poll_cd() {
  while [[ 58 == "$(check_cd)" ]] {
    eject
    read input\?"Please insert blank CD; press any key to continue..."
  }
}

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
# Split file into burnable parts; prints out parts (pieces).
#
split_file() {
  split -db $3 $1 $2 &> $log_file
  print 'parts: ' ${2}[0-9]* > $log_file
  print ${2}[0-9]*
}

########################################################################################################################
# SETUP
########################################################################################################################
device='2,0,0'
tmp_file_base=${0##*/}_$$

unset verbose
log_file=/dev/null
name="${tmp_file_base}_$(date +%Y-%m+%d)"
signature="Micah Larson <micah.larson@ngc.com>"

########################################################################################################################
# MAIN
########################################################################################################################
trap 'clean_up; exit' EXIT INT KILL TERM

while getopts "hln:r:v" option; do
  case "$option" in
    h) print_help_and_exit "$0";;
    l) log_file=${tmp_file_base}.log;;
    n) name="$OPTARG";;
    r) signature="$OPTARG";;
    v) verbose=1;;
    *) print_help_and_exit "$0"
  esac
done

#check arguments
if [[ -z "$@" ]] {
  print_help_and_exit $0
}

[[ ${+verbose} == 1 ]] && print -f "device: '%s'\n" $device

cmds=(cdrdao cdrecord eject gpg isoinfo mkfifo mkisofs split tar)
#Check for necessary things
for cmd in ${(@)cmds}; {
  if ! which $cmd &> $log_file; then
    print "could not find $cmd in path; aborting"
    exit 1
  fi
}

poll_cd #Repeatedly poll optical drive until a blank disk is inserted

pipe=/tmp/${tmp_file_base}.fifo
mkfifo $pipe
cdrdao disk-info --device $device 1> $pipe 2> $log_file &
#blocks=$(sed -n '/^Total.Capacity/ {s/^.*(//; s/.blocks.*//; p; q}' $pipe)
blocks=$(awk -F"[()]" '/^Total.Capacity/ {print $2}' $pipe | cut -f1 -d' ')
capacity=$(( ${blocks} * ${bytes_per_block:=2048} ))

if [[ ${+verbose} == 1 ]] {
  print 'blocks:' $blocks
  print 'bytes per block:' $bytes_per_block
  print 'capacity (bytes):' $capacity
}

#tar up files
tar_file=~/${tmp_file_base}.tgz
tar czvf $tar_file $@ &> $log_file

if [[ $(stat -c '%s' $tar_file) > capacity ]] {
  parts=( $(split_file $tar_file "${tar_file}.part_" $capacity) )
} else {
  parts=( $tar_file )
}

for part in ${(@)parts}; do
  poll_cd #Repeatedly poll optical drive until a blank disk is inserted
  
  #encrypt part
  gpg -r $signature -e $part &> $log_file
  
  #make iso
  iso_file=~/${tmp_file_base}.iso
  mkisofs -V ${name} -J -r -o ${iso_file} ${part}.gpg &> $log_file
  
  #calculate bytes per block, total bytes
  isoinfo -d -i ${iso_file} 1> $pipe 2> $log_file &
  actual_block_size=$(awk '/Logical.block.size/ {print $NF}' $pipe)
  
  [[ ${+verbose} == 1 ]] && print 'actual block size:' ${actual_block_size}
  if [[ ${actual_block_size} != ${bytes_per_block} ]] {
    print -u 2 "Block size mismatch: ${actual_block_size} != ${bytes_per_block}"
  }
  
  #burn
  cdrecord -v speed=2 dev=${device} ${iso_file} &> $log_file
  
  #clean up
  rm "${part}.gpg" ${iso_file}
  
  #eject
  eject
done

clean_up

