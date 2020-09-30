#!/usr/bin/env zsh

# aliases.zsh
# for all active aliases, run `alias`


# Atom
# https://github.com/jeefberkey/dotfiles/blob/2ded1c3a813957909687a8ddce8a9befcc6b51d1/.zshrc#L48-L61
alias atom-beta="atom-nightly"
alias apm-beta="apm-nightly"
alias atom="atom-nightly"
alias apm="apm-nightly"


# dotfiles
alias mu="cd ${DOTFILES:-$HOME/Dropbox/Mackup} && mackup backup --root && git fetch --all --verbose && git submodule update --init --recursive && git status"
alias mux="cd ${DOTFILES:-$HOME/Dropbox/Mackup} && find . -type f -iname '.DS_Store' -delete && mackup backup --root --verbose && git fetch --all --verbose && git submodule update --init --recursive --remote && git status --verbose"


# Git

# git add --patch
# `gap` overrides `git apply` ohmyzsh/ohmyzsh@ed85147
alias gap="git add --patch --verbose"
# `gapa` warning beginning 2020-09 but not worth keeping forever
alias gapa="printf '\xe2\x9a\xa0\xef\xb8\x8f  using \x60gap\x60\n\n' && gap"

alias gc="git commit --verbose --gpg-sign"
alias gcm="git commit --verbose --gpg-sign --message"
alias gco="git checkout --progress"
alias gfgs="git fetch --all --verbose && git status"
alias ggc="git fetch --prune --prune-tags --verbose && git gc --aggressive --prune=now"
alias gmv="git mv --verbose"
if command -v gpg2 > /dev/null 2>&1; then
  alias gpg="gpg2"
fi
alias gtake="git checkout -b"
alias gti="git"
gu () {
  if [ -n "$1" ]; then
    cd ~/Code/"$1" || cd .
  fi

  # https://stackoverflow.com/a/53809163
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    git fetch --all --verbose

    # `git submodule update` with `--remote` appears to slow Git to a crawl
    # https://docs.google.com/spreadsheets/d/14W8w71DK0YpsePbgtDkyFFpFY1NVrCmVMaw06QY64eU
    git submodule update --init --recursive

    git status
  fi
}

# https://github.com/tarunsk/dotfiles/blob/5b31fd648bcfe4de54e27388a1e1e733fca80ab9/.always_forget.txt#L1957
alias gvc="git verify-commit HEAD"


# Python
alias python="python3"
alias pip="pip3"


# shell
alias cp="cp -r -i"
alias mv="mv -v -i" # https://unix.stackexchange.com/a/30950
alias unixtime="date +%s" # via @Naresh https://stackoverflow.com/a/12312982
alias which="which -a"
alias whcih="which"
alias whihc="which"
alias whuch="which"
alias wihch="which"


# Zsh
alias aliases="edit $ZSH_CUSTOM/aliases.zsh; source ~/.zshrc && exec zsh"
alias zshaliases="aliases"
alias zshalias="zshaliases"
alias ohmyzsh="cd ${ZSH:-$HOME/.oh-my-zsh}"
alias zshconfig="edit ~/.zshrc; source ~/.zshrc && exec zsh" # see ~/.zshrc for `edit`
alias zshrc="zshconfig"
