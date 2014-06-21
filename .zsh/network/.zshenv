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
  nix1.ornge.bouco.ngc	printer50
  nix1.ylw.bouco.ngc	bc03-prt001
  nix1.red.bouco.ngc	bc04-prt002
#  cs.colorado.edu	?
)
(( ${+printers[$(dnsdomainname)]} )) && export PRINTER=${printers[$(dnsdomainname)]}

#===============================================================================
# Host-specific color schemes
#===============================================================================
autoload -U colors && colors

typeset -A main_colors alt_colors
main_colors=(
  nix1.ornge.bouco.ngc	${fg[yellow]}
  nix1.ylw.bouco.ngc	${fg_bold[yellow]}
  nix1.red.bouco.ngc	${fg_bold[red]}
  cs.colorado.edu	${fg[green]}
)
export MAIN_COLOR=${main_colors[$(dnsdomainname)]:=${fg_bold[magenta]}}

alt_colors=(
  squawkbox	${fg[blue]}
  moxie		${fg[yellow]}
)
export ALT_COLOR=${alt_colors[$(hostname)]:=${fg[white]}}

