################################################################################
#FILE:         .zshrc
#PLATFORMS:    GNU/Linux
#AUTHOR(s):    Larson, Micah P.
#              Kotiaho, Markku P. (ZSHRC_COMPLETE paradigm)
#DEPENDENCIES: .alias; .completion; .functions; .options; .path
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ----------------------------------------
#  0.1.0.0  2010.03.26  MPL     Basic functionality complete.
#  0.2.0.0  2010.03.29  MPL     Completion added.
#  0.3.0.0  2010.03.30  MPL     Completion improved.
#  0.4.0.0  2011.02.18  MPL     Moved files around.
#  1.0.0.0  2011.03.30  MPL     Documentation updated.
#  1.1.0.0  2011.06.10  MPL     Added RPS2.
#  1.2.0.0  2012.04.11  MPL     Removed network-specific items.
#  1.3.0.0  2012.05.07  MPL     Switched to builtin colors for portability.
#  1.3.1.0  2013.03.05  MPL     Added TRAPINT().
#
#===============================================================================
#NOTES:
#
#
################################################################################

# Print a notice if this is a subshell
# @author makotia
(( ${+ZSHRC_COMPLETE} )) && print ".zshrc: SHLVL = ${SHLVL}"

#===============================================================================
# Import universal settings
#===============================================================================
for f in ${Z_HOME}/.{options,path,alias,functions,bindings,completion}; {
  [[ -f $f ]] && source $f
}

#===============================================================================
# Load builtins, etc.
#===============================================================================
autoload -U colors && colors
autoload -U zmv

#===============================================================================
# Configure the prompt
#===============================================================================
autoload -Uz vcs_info

setopt prompt_subst
zstyle ':vcs_info:*' stagedstr 'S' 
zstyle ':vcs_info:*' unstagedstr 'M' 
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' actionformats ' %F{5}[%F{4}%b%F{3}|%F{1}%a%F{5}]%f'
zstyle ':vcs_info:*' formats ' %F{5}[%F{4}%b%F{5}][%F{2}%c%F{1}%u%F{5}]%f'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
zstyle ':vcs_info:*' enable git

+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
      [[ $(git ls-files --other --directory --exclude-standard | sed q | wc -l | tr -d ' ') == 1 ]] ; then
    hook_com[unstaged]+='%F{1}U%f'
  fi
}

precmd () { vcs_info }

# Display a path prompt (with main colors)
export PS1='%F{5}%m%f:%F{15}%~%f${vcs_info_msg_0_} %B>%b '
#export PS1='%F{1}1%f%F{2}2%f%F{3}3%f%F{4}4%f%F{5}5%f%F{6}6%f%F{7}7%f%F{8}8%f%F{9}9%f%F{10}A%f%F{11}B%f%F{12}C%f%F{13}D%f%F{14}E%f%F{15}F%f %B>%b '

# Display a secondary prompt (for for-loops, etc.)
export PS2="%F{13}[...]%f > "

# Display a timestamp, shell level, job count, and history count, on the right
export RPS1="%F{5}[%*][${SHLVL}][%j][%!]%f"

# Display a secondary prompt with current command and line, on the right
export RPS2=" < %F{13}[%_: %i]%f"

if [[ /proc/$PPID/exe -ef /usr/bin/mc ]]; then
  unset PS1 PS2 PS3 RPS1 RPS2
fi

#===============================================================================
# Signal handling
#===============================================================================
TRAPINT() {
  print -nu 2 "\n${fg_bold[yellow]}\*interrupted\*${reset_color}"
  return $((128 + $1))
}

#===============================================================================
# Perform login operations
#===============================================================================
ulimit -c unlimited	# don't limit the size of core files
#ulimit -s unlimited	# don't limit the size of the stack
umask 002		# create files with ug+rw by default

# Display welcome information (ignore if not login shell)
(( ${+ZSHRC_COMPLETE} )) || (clear; show-info -c welcome)

export ZSHRC_COMPLETE=1

