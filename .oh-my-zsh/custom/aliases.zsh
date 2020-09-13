# aliases.zsh
# for all active aliases, run `alias`

# Atom
# https://github.com/jeefberkey/dotfiles/blob/2ded1c3a813957909687a8ddce8a9befcc6b51d1/.zshrc#L48-L61
alias atom-beta="atom-nightly"
alias apm-beta="apm-nightly"
alias atom="atom-nightly"
alias apm="apm-nightly"

# dotfiles
alias mu="cd ~/Dropbox/Mackup && mackup backup && git fetch --all --verbose && git submodule update --init --recursive && git status"

# Git
alias gc="git commit --verbose --gpg-sign"
alias gcm="git commit --verbose --gpg-sign --message"
alias gfgs="git fetch --all && git status"
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
    git submodule update --init --recursive
    git status
  fi
}

# Python
# alias python="python3" # await WebKit, Chromium to call python2 or to use
                         # python3, but even with this disabled, pyenv is set
                         # to use python3 when calling `python`
alias pip="pip3"

# shell
alias cp="cp -r -i"
alias mv="mv -i" # https://unix.stackexchange.com/a/30950
alias unixtime="date +%s" # via @Naresh https://stackoverflow.com/a/12312982
alias which="which -a"
alias whcih="which"
alias whihc="which"
alias whuch="which"
alias wihch="which"

# Zsh
alias ohmyzsh="cd $ZSH || cd ~/.oh-my-zsh"
alias zshconfig="edit ~/.zshrc; source ~/.zshrc && exec zsh" # see ~/.zshrc for `edit`
