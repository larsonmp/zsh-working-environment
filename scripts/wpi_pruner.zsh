#!/usr/bin/env zsh

typeset -A chains
while read line; do 
  key="${${(s.:.)line}[1]}"
  value="${${(s.:.)line}[2]}"
  
  if (( ${#chains[(r)${key}]} )); then
    existing_key="${(k)chains[(r)${key}]}"
    chains[${(k)chains[(r)${key}]}]=${value}
  else
    chains[${key}]=${value}
  fi
done < /dev/stdin

for key in ${(uk)chains}; do
  if (( ${+verbose} )); then
    filepath="${${(s.@@.)key}[1]}"
    initial_version="${key//${filepath}@@/}"
    final_version="${${chains[${key}]}//${filepath}@@/}"
    print "${filepath}: ${initial_version} -> ${final_version}"
  fi
  bcompare ${key} ${chains[${key}]} 2> /dev/null
done

