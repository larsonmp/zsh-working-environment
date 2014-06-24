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
for f in ${Z_HOME}/.{options,alias,path,functions,bindings,completion}; {
  [[ -f $f ]] && source $f
}

#===============================================================================
# Configure configuration management settings (clearcase, subversion, etc.)
#===============================================================================
[[ -f ${Z_HOME}/.cm ]] && source ${Z_HOME}/.cm

#===============================================================================
# Import network-specific settings
#===============================================================================
[[ -r ${Z_HOME}/network/.zshrc ]] && source ${Z_HOME}/network/.zshrc

#===============================================================================
# Load builtins, etc.
#===============================================================================
autoload -U colors && colors
autoload -U zmv

#===============================================================================
# Configure the prompt
#===============================================================================
# Display a path prompt (with main colors)
export PS1="${CC_TAG}%{${NETWORK_COLOR}%}%d%{${reset_color}%} %B>%b "

# Display a secondary prompt (for for-loops, etc.)
export PS2="%{${NETWORK_COLOR}%}[...]%{${reset_color}%} > "

# Display a timestamp, shell level, job count, and history count, on the right
export RPS1="%{${HOST_COLOR}%}[%*][${SHLVL}][%j][%!]%{${reset_color}%}"

# Display a secondary prompt with current command and line, on the right
export RPS2=" < %{${HOST_COLOR}%}[%_: %i]%{${reset_color}%}"

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
ulimit -c unlimited   # don't limit the size of core files
ulimit -s unlimited   # don't limit the size of the stack
umask 002             # create files with ug+rw by default

# Display welcome information (ignore if not login shell)
(( ${+ZSHRC_COMPLETE} )) || (clear; show-info -c welcome)

export ZSHRC_COMPLETE=1

chpwd() {
  [[ -t 1 ]] && configure_title
}
configure_title

