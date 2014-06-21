#!/usr/bin/env zsh

zmodload -i zsh/net/tcp || return 1

scan() {
  for port in {2..9999}; do
    if ztcp $1 $port &> /dev/null; then
      echo "port ${port} is open"
      ztcp -c $REPLY
    fi
  done
}

scan $1 #hostname

