"===============================================================================
"FILE:		.vimrc
"PLATFORMS:	GNU/Linux
"AUTHOR(s):	Larson, Micah P.
"		Kotiaho, Markku P. (original author)
"DEPENDENCIES:	None
"===============================================================================

" Set general options ----------------------------------------------------------
set ruler         "show cursor position
set number        "show line numbers
set incsearch     "incremental searching
set tabpagemax=25 "max tabs
set autochdir

" Set keyboard shortcuts -------------------------------------------------------
if has("gui_running")
  nmap <c-t> :tabnew<cr>
  imap <c-t> <esc>:tabnew<cr>i
  
  "note: use 'q' rather than 'tabclose', since tabclose doesn't work on last tab
  nmap <c-w> :q<cr>
  imap <c-w> <esc>:q<cr>i
  
  nmap <c-s> :w<cr>
  imap <c-s> <esc>:w<cr>i
  
  nmap <silent> <s-insert> "+p
  imap <silent> <s-insert> <esc>"+p
endif

" Set font and color scheme ----------------------------------------------------
colorscheme lucius
LuciusDark
set guifont=Inconsolata\ 14

" Remove unneeded toolbar buttons ----------------------------------------------
aunmenu ToolBar.Print
aunmenu ToolBar.-sep7-
aunmenu ToolBar.Help
aunmenu ToolBar.FindHelp

" Set syntax highlighting rules for non-standard file extensions ---------------
au BufReadPost           *.jy   set syntax=python
au BufReadPost           *.pyrc set syntax=python
au BufReadPost .dircolors       set syntax=dircolors
au BufReadPost .screenrc.*      set syntax=screen

" zshrc support files
au BufReadPost ${Z_HOME}/*           set syntax=zsh
au BufReadPost ${Z_HOME}/functions/* set syntax=zsh
au BufReadPost ${Z_HOME}/network/*   set syntax=zsh

" Set pydiction options --------------------------------------------------------
"filetype plugin on
"let g:pydiction_location = '~/.vim/pydiction/complete-dict'
"let g:pydiction_menu_height = 20

" Set HTML options -------------------------------------------------------------
let html_use_css = 1       " use stylesheet instead of inline style
"let html_number_lines = 0 " don't show line numbers
"let html_no_pre = 1       " don't wrap lines in <pre></pre>

" Set path-related options -----------------------------------------------------
set path=.,/usr/include

" Backup and swap file stuff ---------------------------------------------------
set backup              "backup files on edit
"set bex=.bak           "extension to use for backup files
set bdir=~/.vim/backup/ "directory for backup files
set dir=~/.vim/swap/     "directory for swap files

" Load the man page viewer plugin ----------------------------------------------
runtime! ftplugin/man.vim
