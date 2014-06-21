#!/usr/bin/env zsh
zmodload -i zsh/net/tcp

ztcp -l 5150
fd=$REPLY

echo "Waiting for client connection..."
ztcp -a $fd
clientfd=$REPLY
echo "client connected"
print -u $clientfd "Welcome to my server (send 'exit' to disconnect)"

while read line; do
  if [[ $line = "exit" ]]; then
    break
  else
    echo Received: $line
    echo $line >& $clientfd
  fi
done <& $clientfd

echo "client disconnected"
ztcp -c $fd
ztcp -c $clientfd

