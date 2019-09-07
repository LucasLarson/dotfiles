
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"



# gem update
eval "$(rbenv init -)" # https://github.com/rbenv/rbenv/issues/938#issuecomment-285342541
export PATH="$HOME/.rbenv/bin:$PATH"


# npm without sudo
# https://github.com/sindresorhus/guides/blob/285270f06e117c7e0a6b6e51eca6e488d9d7c44d/npm-global-without-sudo.md#3-ensure-npm-will-find-installed-binaries-and-man-pages
NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$NPM_PACKAGES/bin:$PATH"
unset MANPATH # delete if you already modified MANPATH elsewhere
export MANPATH="$NPM_PACKAGES/share/man:$(manpath)"


#######################
# Alias and Functions # via https://github.com/jeefberkey/dotfiles/blob/2ded1c3a813957909687a8ddce8a9befcc6b51d1/.zshrc#L48-L61
#######################
alias gti  = "git"
alias atom = "atom-beta"
alias apm  = "apm-beta"
