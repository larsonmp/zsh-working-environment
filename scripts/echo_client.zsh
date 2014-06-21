#!/usr/bin/env zsh
zmodload -i zsh/net/tcp

ztcp localhost 5150
hostfd=$REPLY
read line <& $hostfd
echo $line

while { true }; do
  echo -n "Enter text: "
  read phrase
  echo "Sending \"${phrase}\" to remote host..."
  print -u $hostfd "${phrase}"
  if [[ "${phrase}" == 'exit' ]]; then
    break
  fi
  read line <& $hostfd
  echo "    Received: $line"
done
ztcp -c $hostfd

