################################################################################
#FILE:         .zshenv
#PLATFORMS:    GNU/Linux
#AUTHOR(s):    Larson, Micah P.
#              Kotiaho, Markku P. (LC_COLLATE)
#DEPENDENCIES: None
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ------------------------------------------------
#  0.1.0.0  2011.02.18  MPL     Basic functionality complete.
#  1.0.0.0  2011.03.30  MPL     Documentation updated.
#  1.0.0.1  2011.04.26  MPL     Removed $ARCH in favor of $CPUTYPE (set by ZSH).
#  1.0.1.0  2011.11.05  MPL     Removed obsolete environment variables.
#
#===============================================================================
#NOTES:
#
################################################################################

export Z_HOME=~/.zsh #path to additional config files (sourced by .zshrc)

autoload -U colors && colors

#==============================================================================
# Functions
#==============================================================================
# Return 1 if ($1) is in classpath, 0 otherwise
is_in_classpath() {
  local re="${1/%\//}/?" #regex (re) for path, with or without trailing slash
  if [[ -z $(egrep "^${re}$|^${re}:|:${re}:|:${re}$" <<< ${CLASSPATH}) ]] {
    return 0 #not in classpath
  } else {
    return 1 #in classpath
  }
}

# Append arg ($1) to classpath if it isn't already in classpath
append_to_classpath() {
  if (( ${+CLASSPATH} )) {
     is_in_classpath "$1" || export CLASSPATH="${CLASSPATH}:${1/\/$//}"
  } else {
    export CLASSPATH="${1/\/$//}"
  }
}

#==============================================================================
# ZSH variables
#==============================================================================
export HISTFILE=${Z_HOME}/.history # location for history file
export HISTSIZE=5000               # number of cmds saved in history
export SAVEHIST=${HISTSIZE}        # number of cmds saved in history file

# @author makotia
export LC_COLLATE="POSIX"          #sort by ASCII code

#report timing statistics for commands that took longer than 60 seconds
export REPORTTIME=60
export TIMEFMT="${fg[magenta]}%J${reset_color}: %*E"

#configure information printed when log builting is invoked
watch=()
export LOGCHECK=30
export WATCHFMT="%S%B[%D %t]%b%s ${fg[yellow]}%n${reset_color}%(M:@${fg[yellow]}%U%M%u${reset_color}:) has %a to %l"

#===============================================================================
# File sets (configuration files grouped logically)
#===============================================================================
typeset -Ua z_files
z_files=(
  ~/.zshrc
  ~/.zprofile
  ~/.zshenv
  ${Z_HOME}/.alias
  ${Z_HOME}/.bindings
  ${Z_HOME}/.completion
  ${Z_HOME}/.functions
  ${Z_HOME}/.options
  ${Z_HOME}/.path
  ${Z_HOME}/network/.*
)

typeset -Ua func_files
func_files=(
  ${Z_HOME}/functions/*(.)
)

typeset -Ua dot_files
dot_files=(
  ~/.vimrc
  ~/.gdbinit
  ${PYTHONSTARTUP}
  ${Z_HOME}/.cm
  ${Z_HOME}/.dircolors
  ~/.Xresources
)

#===============================================================================
# Miscellany
#===============================================================================
export LOG_DIR=~/log

# set pagers and editors
export   PAGER='less'
export  EDITOR='vim'
export XEDITOR='gvim'
export  VISUAL='gvim -f' #crontab, clearcase

[[ -n ${TZ:='America/Denver'} ]] && export TZ

# set variables for reference in display scripts
export ADDR="$(hostname -I)"
export OS="$(uname -o)"
export KERNEL="$(uname -r)"
export GROUPS="$(groups)"
export DISTRO="$(egrep -o '^\w*' /etc/issue)"
[[ -r /etc/debian_version ]] && export DISTRO_VERSION="$(cat /etc/debian_version)"

export XTFONT='-misc-fixed-medium-r-normal--20-200-75-75-c-100-iso10646-1'

# variables for external applications
export GREP_OPTIONS='--color=auto' # make grep print in color by default
#GREP_COLOR='1;32'

# path for python library modules
[[ -r ${PYTHONPATH:=~/lib/python} ]] && export PYTHONPATH

# python startup file
[[ -r ${PYTHONSTARTUP:=~/.pyrc} ]] && export PYTHONSTARTUP

# Enthought Python Distribution
#export EPD_HOME=/opt/epd

#CScope
#export CSCOPE_DB=~/.cscope/cscope.db

# java
export JAVA_HOME=/usr/java/latest

# jms
export ACTIVEMQ_HOME=~/programs/apache-activemq/default

# log4j
#export LOG4J_HOME=/nas_media/Central_Library_Repo/apache-log4j-1.2.16
#append_to_classpath "${LOG4J_HOME}/log4j-1.2.16.jar"

# ant
export ANT_HOME=/usr/share/ant
export ANT_LOGGER='org.apache.tools.ant.listener.AnsiColorLogger'
export ANT_LOGGER_CFG=~/etc/ant.properties
export ANT_ARGS="-logger ${ANT_LOGGER}"
export ANT_OPTS="-Dant.logger.defaults=${ANT_LOGGER_CFG}"

# maven
export MAVEN_HOME=/opt/apache/maven-3.0.4
export MAVEN_OPTS="-Xms256m -Xmx512m"

# derby
export DERBY_HOME=/opt/apache/derby-10.9.1.0
append_to_classpath ${DERBY_HOME}/lib/derby.jar
append_to_classpath ${DERBY_HOME}/lib/derbytools.jar
#export DERBY_OPTS=-Dderby.system.home=/path/to/home

# geronimo
export GERONIMO_OPTS=-XX:-UseSplitVerifier

# tomcat
#export CATALINA_HOME=~/programs/apache-tomcat/default

# postgresql
export PGDATA=/var/tmp/larsonmp/pgsql/data
export PGLOG=${LOG_DIR}/postgresql.log

# virtual environment (for python devleopment)
export VENV=~/sanbox/env

#===============================================================================
# Import network-specific settings
#===============================================================================
[[ -r ${Z_HOME}/network/.zshenv ]] && source ${Z_HOME}/network/.zshenv

