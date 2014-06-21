#===============================================================================
#FILE:		.gdbinit
#PLATFORMS:	GNU/Linux
#AUTHOR(s):	Larson, Micah P.
#DEPENDENCIES:	None
#===============================================================================
set history filename ~/.gdb/.history
set history save

set verbose off

#color prompt
set extended-prompt \e[35m[\f]\e[0m > 

#signal handling (ignored signals)
handle SIGPWR nostop noprint
handle SIGXCPU nostop noprint
handle SIG33 nostop noprint

define boe
  catch syscall exit
  catch syscall exit_group
end
document boe
  Break-on-exit
end
