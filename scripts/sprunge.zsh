#!/usr/bin/env zsh
 
usage() {
  description | fmt -s 2> /dev/null
}
 
description() {
cat << HERE
 
DESCRIPTION
  Upload data and fetch URL from the pastebin http://sprunge.us
 
USAGE
  $0 filename.txt
  $0 text string
  $0 < filename.txt
  piped_data | $0
 
NOTES
--------------------------------------------------------------------------
* INPUT METHODS *
$0 can accept piped data, STDIN redirection [<filename.txt], text strings following the command as arguments, or filenames as arguments.  Only one of these methods can be used at a time, so please see the note on precedence.  Also, note that using a pipe or STDIN redirection will treat tabs as spaces, or disregard them entirely (if they appear at the beginning of a line).  So I suggest using a filename as an argument if tabs are important either to the function or readability of the code.
 
* PRECEDENCE *
STDIN redirection has precedence, then piped input, then a filename as an argument, and finally text strings as an arguments.
 
  EXAMPLE:
  echo piped | "$0" arguments.txt < stdin_redirection.txt
 
In this example, the contents of file_as_stdin_redirection.txt would be uploaded. Both the piped_text and the file_as_argument.txt are ignored. If there is piped input and arguments, the arguments will be ignored, and the piped input uploaded.
 
* FILENAMES *
If a filename is misspelled or doesn't have the necessary path description, it will NOT generate an error, but will instead treat it as a text string and upload it.
--------------------------------------------------------------------------
 
HERE
exit
}

if [[ -t 0 ]]; then
  if (( $# )); then
    if [[ -f "$@" ]]; then
      curl -F 'sprunge=<-' http://sprunge.us  <  "$@"
    else
      curl -F 'sprunge=<-' http://sprunge.us <<< "$@"
    fi
  else
    usage
  fi
else
  curl -F 'sprunge=<-' http://sprunge.us <& 0
fi
