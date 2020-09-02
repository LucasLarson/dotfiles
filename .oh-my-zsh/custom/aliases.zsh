# aliases.zsh
# for all active aliases, run `alias`

# Atom
# https://github.com/jeefberkey/dotfiles/blob/2ded1c3a813957909687a8ddce8a9befcc6b51d1/.zshrc#L48-L61
alias atom-beta="atom-nightly"
alias apm-beta="apm-nightly"
alias atom="atom-nightly"
alias apm="apm-nightly"

# dotfiles
alias mu="cd ~/Dropbox/Mackup && mackup backup && git fetch --all --verbose && git submodule update --init --recursive --remote && git status"

# Git
alias gc="git commit --verbose --gpg-sign"
alias gcm="git commit --verbose --gpg-sign --message"
alias gfgs="git fetch --all && git status"
alias gmv="git mv --verbose"
alias gtake="git checkout -b"
alias gti="git"
gu () {
  if [ -n "$1" ]; then
    cd ~/Code/"$1" || return
  fi
  git fetch --all --verbose
  git submodule update --init --recursive --remote
  git status
}
gunstage () {
  if [ $# -eq 0 ]; then
    git restore --staged --progress .
  else
    arguments=()
    for index in "$@"; do
      git restore --staged --progress "${index[@]}"
      arguments+=("$index")
    done
  fi
}

# Python
# alias python="python3" # await WebKit, Chromium to call python2 or to use
                         # python3, but even with this disabled, pyenv is set
                         # to use python3 when calling `python`
alias pip="pip3"

# shell
alias cp="cp -i"
alias mv="mv -i" # https://unix.stackexchange.com/a/30950
alias unixtime="date +%s" # via @Naresh https://stackoverflow.com/a/12312982
alias which="which -a"
alias whcih="which"
alias whihc="which"
alias whuch="which"
alias wihch="which"

# Zsh
alias ohmyzsh="~/.oh-my-zsh"
alias zshconfig="edit ~/.zshrc" # see ~/.zshrc for `edit`
alias zshcustom="$ZSH_CUSTOM"
