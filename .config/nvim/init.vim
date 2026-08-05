set list

" https://vi.stackexchange.com/a/430
set listchars=eol:⏎,tab:␉·,trail:␠,nbsp:⎵

set ignorecase smartcase

" prevent auto indent
filetype indent off

" prevent Neovim from resetting iTerm’s cursor
" https://github.com/neovim/neovim/issues/7130
set guicursor=""

iabbrev 2d 2>/dev/null
iabbrev dn2 >/dev/null 2>&1
iabbrev ifs IFS=''
iabbrev lcl LC_ALL='C' LANG='C'
iabbrev wrf while IFS='' read -r -- file;
