#!/usr/bin/env zsh

# aliases.zsh
# for all active aliases, run `alias`


# Atom
# https://github.com/jeefberkey/dotfiles/blob/2ded1c3/.zshrc#L48-L61
alias atom-beta="atom-nightly"
alias apm-beta="apm-nightly"
alias atom="atom-nightly"
alias apm="apm-nightly"


# dotfiles
# https://stackoverflow.com/q/4210042#comment38334264_4210072
alias mu=" \
    cd ${DOTFILES:-$HOME/Dropbox/dotfiles} && \
    garbage && \
    mackup backup --force --root && \
    git fetch --all && \
    git submodule update --init --recursive && \
    git status"
alias mux=" \
    cd ${DOTFILES:-$HOME/Dropbox/dotfiles} && \
    garbage --verbose && \
    mackup backup --force --root --verbose && \
    git fetch --all --verbose && \
    git submodule update --init --recursive --remote && \
    git status --verbose"


# Git
alias gap="git add --patch --verbose" # override `git apply` alias
alias gc="git commit --verbose --gpg-sign"
alias gca="git commit --amend --verbose --gpg-sign"
alias gcl="git clone --verbose --progress --recursive --recurse-submodules"
alias gcm="git commit --verbose --gpg-sign --message"
alias gco="git checkout --progress"

# `git checkout` the default branch
# place the function inside `{()}` to prevent the leaking of variable data
# https://stackoverflow.com/a/37675401
gcom () {(
  git checkout --progress "$(git_default_branch)"
)}

alias gfgs="git fetch --all --verbose && git status"

ggc () {(
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    git fetch --prune --prune-tags --verbose
    git gc --aggressive --prune=now
  else
    return 1
  fi
)}

alias ginit="git init"
alias glog="git log"

# return the name of the repository’s default branch
# ohmyzsh/ohmyzsh@c99f3c5/plugins/git/git.plugin.zsh#L28-L35
git_default_branch () {(
  # run only from within a git repository
  # https://stackoverflow.com/a/53809163
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then

    # check if there’s a `remote` with a default branch and
    # if so, then use that name for `default_branch`
    # https://stackoverflow.com/a/44750379
    if git symbolic-ref refs/remotes/origin/HEAD > /dev/null 2>&1; then
      default_branch="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"

    # check for `main`, which, if it exists, is most likely to be default
    elif [ -n "$(git branch --list main)" ]; then
      default_branch=main

    # check for a branch called `master`
    elif [ -n "$(git branch --list master)" ]; then
      default_branch=master
    else
      printf 'unable to detect a \x60main\x60, \x60master\x60, or default '
      printf 'branch in this repository\n'
      return 1
    fi
  else
    printf 'git_default_branch must be called from within a Git repository\n'
    return 1
  fi
  printf '%s' "$default_branch"
)}
alias gdb="git_default_branch"

# git merge main
gmm () {(
  # set Git merge verbosity environment variable
  # 4 “shows all paths as they are processed” but
  # 5 is “show detailed debugging information”
  # https://github.com/progit/progit2/commit/aea93a7
  GIT_MERGE_VERBOSITY=4 git merge --verbose --progress --strategy-option patience "$(git_default_branch)"
)}

alias gmv="git mv --verbose"

# git pull after @ohmyzsh `gupav` ohmyzsh/ohmyzsh@3d2542f
alias gpull="git pull --all --rebase --autostash --verbose && git status"

# git push after @ohmyzsh `gpsup` ohmyzsh/ohmyzsh@ae21102
alias gpv='git push --verbose --set-upstream origin "$(git_current_branch)"'

alias gsu="git submodule update --init --recursive --remote"
alias gtake="git checkout -b"
alias gti="git"

gu () {
  # run only from within a git repository
  # https://stackoverflow.com/a/53809163
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    git fetch --all --verbose

    # `git submodule update` with `--remote` appears to slow Git to a crawl
    # https://docs.google.com/spreadsheets/d/14W8w71DK0YpsePbgtDkyFFpFY1NVrCmVMaw06QY64eU
    git submodule update --init --recursive

    garbage

    git status
  fi
}

# https://github.com/tarunsk/dotfiles/blob/5b31fd6/.always_forget.txt#L1957
alias gvc="git verify-commit HEAD"


# GPG
if command -v gpg2 > /dev/null 2>&1; then
  alias gpg="gpg2"
fi


# Python
alias python="python3"
alias pip="pip3"


# shell
# https://mywiki.wooledge.org/BashPitfalls?rev=524#Filenames_with_leading_dashes
alias cp="cp -r -i --"
cy () {
  if [ -n $2 ]; then
    cp "$1" "$2"
  else
    # if there is no second argument,
    # then copy to the current directory
    cp "$1" "$PWD"
  fi
}

garbage () {(
  # if `garbage -v` or `garbage --verbose`,
  # then use `-print` during `-delete`
  if [ "$1" = -v ] || [ "$1" = --verbose ]; then
    verbose=-print
  fi

  # delete `.DS_Store` files recursively
  find . -type f \
      -name '.DS_Store' \
      $verbose -delete

  # delete empty, zero-length files except those
  # with specific names
  find . -type f -empty \
      -not -path '*.gitkeep' -and \
      -not -path '*.lock' \
      $verbose -delete

  # delete empty directories, except within `.git/`, recursively \
  # https://stackoverflow.com/q/4210042#comment38334264_4210072 \
  find . -type d -empty \
      -not -path './.git/*' -and \
      -not -path './.well-known/*' \
      $verbose -delete
)}

alias mv="mv -v -i" # https://unix.stackexchange.com/a/30950
alias unixtime="date +%s" # https://stackoverflow.com/a/12312982
alias which="which -a"
alias whcih="which"
alias whihc="which"
alias whuch="which"
alias wihch="which"


# Zsh
alias aliases="edit $ZSH_CUSTOM/aliases.zsh; . ~/.zshrc && exec zsh"
alias ohmyzsh="cd ${ZSH:-$HOME/.oh-my-zsh}"
alias zshconfig="edit ~/.zshrc; . ~/.zshrc && exec zsh"
alias zshenv="edit ~/.zshenv; . ~/.zshrc && exec zsh"
alias zshrc="zshconfig"
