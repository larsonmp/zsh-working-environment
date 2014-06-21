#!/usr/bin/env zsh

# CREATE ARCHIVE OF PERSONAL FILES #############################################
tar_file=~/personal_archive_$(date +%Y-%m-%d_%H.%M.%S).tar.gz
md5_file=~/personal_archive_$(date +%Y-%m-%d_%H.%M.%S).md5sum
targets=(
  ~/scripts/*
  ~/.fonts/*
  ~/.vim/colors/*
  ~/.face
  ~/.zshrc
  ~/.zshenv
  ~/.zprofile
  ~/.Xresources
  ~/.pyrc
  ~/.screenrc*
  ~/.toprc
  ~/.vimrc
  ~/.zsh/.alias
  ~/.zsh/.bindings
  ~/.zsh/.colors
  ~/.zsh/.completion
  ~/.zsh/.dircolors
  ~/.zsh/.functions
  ~/.zsh/.options
  ~/.zsh/.path
)

md5sum -c ${md5_file} --status        &> /dev/null
if [[ "$?" -ne 0 ]]; then
  md5sum ${targets[@]} 1> ${md5_file} 2> /dev/null
  tar czf ${tar_file} ${targets[@]}   &> /dev/null
  chmod a-w ${tar_file}               &> /dev/null
fi

