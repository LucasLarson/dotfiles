set list

" https://vi.stackexchange.com/a/430
set listchars=eol:⏎,tab:␉·,trail:␠,nbsp:⎵

set ignorecase smartcase

" prevent auto indent
filetype indent off

" enable Copilot for more filetypes
" https://github.com/afirth/dotfiles/commit/ae51e78ce3
if has('nvim')
  let g:copilot_filetypes = {
        \ 'gitcommit': v:true,
        \ }
endif

" prevent Neovim from resetting iTerm’s cursor
" https://github.com/neovim/neovim/issues/7130
set guicursor=""
