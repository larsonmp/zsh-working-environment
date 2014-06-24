#===============================================================================
#FILE:		.gdbinit
#PLATFORMS:	GNU/Linux
#AUTHOR(s):	Larson, Micah P.
#DEPENDENCIES:	None
#===============================================================================
#python
#import sys
#sys.path.insert(0, '/usr/share/gdb/python')
#from libstdcxx.v6.printers import register_libstdcxx_printers
#register_libstdcxx_printers
#end

set history filename ~/.gdb/history
set history save

set print pretty on
set print object on
set print static-members on
set print vtbl on
set print demangle on
set demangle-style gnu-v3
set print sevenbit-strings off

set verbose off

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

#color prompt
set extended-prompt \e[35m[\f]\e[0m >
#set prompt \033[35mgdb\033[0m >

