#!/usr/bin/env zsh

print_help_screen() {
  print 'Screen keybindings:'
  grep "#-" ~/.screenrc | sed 's/.*#-//g'
}

print_help_zsh() {
  print 'ZSH keybindings:'
  grep "#-" ${Z_HOME}/.bindings | sed 's/.*#-//g'
}

print_help_screen
print_help_zsh

