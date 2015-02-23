################################################################################
#FILE:         .zshenv
#PLATFORMS:    GNU/Linux
#AUTHOR(s):    Larson, Micah P.
#DEPENDENCIES: None
#
#VERSION HISTORY:
#
#  Version  Date        Author  Description
#  -------  ----------  ------  ------------------------------------------------
#  0.1.0.0  2013.04.19  MPL     Split from ${Z_HOME}/network/.zshrc
#  0.2.0.0  2013.04.22  MPL     Printer list converted to associative array
#  0.3.0.0  2013.04.22  MPL     ~/etc/host_colors.zsh assimilated
#
#===============================================================================
#NOTES:
#  (1) This file was created to separate the network-specific settings from the
#      universal logic in .zshrc (and related files) in order to streamline the
#      process of synchronizing the user's environment between networks.
#
################################################################################

#===============================================================================
# Default printers (one for each domain/network)
#===============================================================================
typeset -A printers
printers=(
#  cs.colorado.edu	?
)
(( ${+printers[$(dnsdomainname)]} )) && export PRINTER=${printers[$(dnsdomainname)]}

#===============================================================================
# Host-specific color schemes
#===============================================================================
autoload -U colors && colors

typeset -A network_colors host_colors
network_colors=(
  cs.colorado.edu	${fg[green]}
)

host_colors=(
  squawkbox		${fg[blue]}
  raspberry-pi-01	${fg[cyan]}
  raspberry-pi-02	${fg[cyan]}
  raspberry-pi-xbian	${fg[yellow]}
  moxie			${fg[red]}
)

export NETWORK_COLOR=${network_colors[$(dnsdomainname)]:=${fg_bold[magenta]}}
export HOST_COLOR=${host_colors[${HOST}]:=${fg[white]}}

