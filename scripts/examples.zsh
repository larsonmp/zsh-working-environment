#!/usr/bin/env zsh
################################################################################
#SCRIPT:                        examples.zsh
#PLATFORMS:                     GNU/Linux
#AUTHOR(s):                     Larson, MP
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ------------------------------------------------
#  0.1.0.0  2011.08.02  MPL     Basic functionality complete.
#
################################################################################
#HELP TEXT:
#-  This script demonstrates some zsh features.
#-
#-  Usage:
#-    EXE_NAME {demo name}
#-
#-  Examples:
#-    EXE_NAME 
#-
################################################################################
#NOTES:
#  (1) In order for this script to recognize a function as demo-able, the name
#      of the function must match 'demo_[a-z]*_expansion'
#
#TODO:
#  (1) Test on other platforms/hosts
################################################################################

################################################################################
# FUNCTIONS
################################################################################

autoload -U colors && colors

# print a horizontal line of length $2 using pattern $1
print_separator() {
  [[ -n "$1" ]] && local pattern=$1
  [[ -n "$2" ]] && local count=$2
  for i in {1..${count:=80}}; do
    printf '%s' ${pattern:=-}
  done
  print
}

# demonstrate evaluating the state of a variable
demo_tricky_expansion() {
  local var_list="unset_var?empty_var?good_var"
  unset unset_var
  local empty_var=''
  local good_var="..."
  
  for foo in ${(s.?.)var_list}; {
    echo "${foo}:"
    echo "  ${(P)foo:-this variable is empty}"
    echo "  ${(P)foo-this variable is not even set}"
    echo "  ${(P)foo+this variable is set}"
    echo "  ${(P)foo:+this variable is set and not empty}"
  } | egrep -v "^[ ]*$"
}

# demonstrate run-of-the-mill expansions
demo_basic_expansion() {
  local phrase="The quick brown FOX jumped over the lazy dog."
  local re1="[^aeiou]*[aeiou]"
  local re2="[^aeiou][aeiou]*"
  local re3="[aeiou]"
  local oops='booyay'
  
  local -a expansions
  expansions=(
    '${phrase}'
    '${(t)phrase}'
    '${+phrase}'
    '${re1}'
    '${phrase#${~re1}}'
    '${phrase##${~re1}}'
    '${re2}'
    '${phrase%${~re2}}'
    '${phrase%%${~re2}}'
    '${re3}'
    '${phrase/${~re3}/_}'
    '${phrase//${~re3}/_}'
    '${#phrase}'
    '${(w)#phrase}'
    '${#${=phrase}}'
    '${#${(s.e.)phrase}}'
    '${oops}'
    '${(V)oops}'
    'pid:$$'
  )

  pprint_expansion ${(@)expansions}
}

# demonstrate array expansions
demo_array_expansion() {
  local -a array expansions
  
  array=(
    apple
    banana
    CHERRY
    apple
  )

  expansions=(
    '${array}'
    '${#array}'
    '${(t)array}'
    '${(Oa)array}'
    '${(C)array}'
    '${(L)array}'
    '${(U)array}'
    '${(u)array}'
    '${(l:8:)array}'
    '${(r:8:)array}'
    '${+array[(r)apple]}'
    '${+array[(r)mango]}'
  )
  
  pprint_expansion ${(@)expansions}
}

# demonstrate associative array expansions
demo_dict_expansion() {
  local -A dict
  dict=(key value a apple b banana)
  local -a expansions
  expansions=(
    '${(kv)dict}'
    '${(t)dict}'
    '${dict[a]}'
    '${(k)dict}'
    '${(v)dict}'
  )
  
  pprint_expansion ${(@)expansions}
}

# demonstrate multi-line expansions
demo_line_expansion() {
  local lines='line1
line2
line3'

  local -a array expansions
  
  array=(word1 word2 word3)
  expansions=(
    '${array}'
    '${(F)array}'
    '${(j.?.)array}'
    '${lines}'
    '${(f)lines}'
  )
  
  pprint_expansion ${(@)expansions}
}

# demonstrate the prefix-combination behavior
demo_prefix_expansion() {
  local -a array
  array=(one two three)
  local prefix='and-a-'
  echo '${array}                ' ${array}
  echo '${prefix}               ' ${prefix}
  echo '${prefix}${array}       ' ${prefix}${array}
  echo '${prefix}${^array}      ' ${prefix}${^array}
}

# demonstrate expansions as they pertain to file operations
demo_file_expansion() {
  local file=~/temp_$$.tmp
  expansions=(
    '${file}'
    '${file:r}' #root
    '${file:e}' #extension
    '${file:h}' #head
    '${file:t}' #tail
    '${file##*/}'
    '${file:t:r}' #tail+root
    '${file:u}'
    '${file:l}'
    '$(lsd ~/*(/))'
    '$(lsd ~/*(^/))'
    '$(lsd /tmp/**/*(u:${USERNAME}:/))'
  )
  
  touch $file
  pprint_expansion ${(@)expansions}
  rm -rf $file
}

# helper function (forces ls to print colors)
lsd() {
  ls -d --color=always $@
}

# returns 1 (true) if $1 consists solely of numeric characters
is_numeric() {
  [[ "$1" == <-> ]] && return 1
  return 0
}

# execute all functions named 'demo_[a-z]*_expansion' (except this one, of course)
demo_all_expansion() {
  funcs=( $(sed -n 's/^demo_\([a-z]*\)_expansion.*$/\1/p' $1) )
  for func in ${(@)funcs:#all}; do
    if [[ ${+gate} == 1 ]]; then
      print_separator
    else
      local -i gate
    fi
    
    demo_${func}_expansion
  done
}

# print the text of an expansion along with its evaluation
pprint_expansion() {
  for ex in $@; {
    echo ${fg_bold[yellow]}${(r.32.)ex}${reset_color} ${(e)ex}
  }
}

################################################################################
# MAIN
################################################################################
#compile a list of demo-able functions
demos=( $(sed -n 's/^demo_\([a-z]*\)_expansion.*$/\1/p' $0) )

#check args for demo names
if [[ -z "$1" ]]; then
  print -u 2 "missing required args: one of [${(j., .)${(@o)demos}}]"
  exit 1
else
  print_separator '='
  print "attempting to demo ${(j., .)@}:"
fi

#execute specified demos
while [[ -n "$1" ]]; do
  print_separator
  typeset -f demo_${1}_expansion &> /dev/null
  if [[ 0 == $? ]]; then
    demo_${1}_expansion $0
  else
    print -u 2 "$1 is not a valid demo (${(j., .)${(@o)demos}})"
  fi
  shift 1
done
print_separator '='

