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
mu () {
  cd "${DOTFILES:-${HOME}/Dropbox/dotfiles}" &&
  (command -v cleanup >/dev/null 2>&1 && cleanup) &&
  mackup backup --force --root &&
  git fetch --all &&
  git submodule update --init --recursive &&
  git status
}
mux () {
  cd "${DOTFILES:-${HOME}/Dropbox/dotfiles}" &&
  (command -v cleanup >/dev/null 2>&1 && cleanup) &&
  mackup backup --force --root --verbose &&
  git fetch --all --verbose &&
  git submodule update --init --recursive --remote &&
  git status
}


# Git
git_add_patch () {
  git add --patch --verbose "$@"
  git status
}
alias gap="git_add_patch"
alias gc="git commit --verbose --gpg-sign"
alias gca="git commit --amend --verbose --gpg-sign"
alias gcl="git clone --verbose --progress --recursive --recurse-submodules"
alias gcm="git commit --verbose --gpg-sign --message"
alias gco="git checkout --progress"

# `git checkout` the default branch
gcom () {
  git checkout --progress "$(git_default_branch)"
}
gdm () {
  git diff "$(git_default_branch)"
}
alias gfgs="git fetch --all --verbose && git status"
ggc () {
  (command -v cleanup >/dev/null 2>&1 && cleanup)
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git fetch --prune --prune-tags --verbose
    git gc --aggressive --prune=now
    git status
  else
    return 1
  fi
}

# initial commit
# https://stackoverflow.com/a/1007545
# https://stackoverflow.com/q/1006775#comment23686803_1007545
alias gic="git rev-list --topo-order --parents HEAD | egrep '^[a-f0-9]{40}$'"
alias gcic="git rev-parse --is-inside-work-tree >/dev/null 2>&1 || git init && git commit --allow-empty --verbose --message $(printf '\x27\xe2\x9c\xa8 initial commit\x27') && git add . && git commit --verbose --message $(printf '\x27\xe2\x9c\xa8 initial commit\x27')"
alias ginit="git init && git status"

# git log
# https://github.com/gggritso/gggritso.com/blob/a07b620/_posts/2015-08-23-human-git-aliases.md#readme
alias glog="git log --graph --branches --remotes --tags --format=format:'%Cgreen%h %Creset• %<(75,trunc)%s (%cN, %cr) %Cred%d' --date-order"

# return the name of the repository’s default branch
# ohmyzsh/ohmyzsh@c99f3c5/plugins/git/git.plugin.zsh#L28-L35
# place the function inside `{()}` to prevent the leaking of variable data
# https://stackoverflow.com/a/37675401
git_default_branch () {(
  # run only from within a git repository
  # https://stackoverflow.com/a/53809163
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then

    # check if there’s a `remote` with a default branch and
    # if so, then use that name for `default_branch`
    # https://stackoverflow.com/a/44750379
    if git symbolic-ref refs/remotes/origin/HEAD >/dev/null 2>&1; then
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
    printf 'this function must be called from within a Git repository\n'
    return 1
  fi
  printf %s "${default_branch}"
)}
alias gdb="git_default_branch"

# https://news.ycombinator.com/item?id=5512864
alias gm="GIT_MERGE_VERBOSITY=4 git merge --strategy-option patience"
alias gmc="GIT_MERGE_VERBOSITY=4 git merge --continue"

# git merge main
gmm () {
  # set Git merge verbosity environment variable
  # 4 “shows all paths as they are processed” but
  # 5 is “show detailed debugging information”
  # https://github.com/progit/progit2/commit/aea93a7
  GIT_MERGE_VERBOSITY=4 git merge --verbose --progress --strategy-option patience "$(git_default_branch)"
}

alias gmv="git mv --verbose"

# git pull after @ohmyzsh `gupav` ohmyzsh/ohmyzsh@3d2542f
alias gpl="git pull --all --rebase --autostash --ff-only --verbose && git status"

# git push after @ohmyzsh `gpsup` ohmyzsh/ohmyzsh@ae21102
alias gps='git push --verbose --set-upstream origin "$(git_current_branch)" && git status'

alias grmr="git rm -r"
alias grm="grmr"

git_restore () {(
  IFS="$(printf '\n\t')"
  files=(
    "${@:-.}"
  )
  for file in "${files[@]}"; do
    git checkout --progress -- "${file}"
  done && git status
)}
alias grs="git_restore"

git_submodule_update () {(
  git submodule update --init --recursive --remote $@ &&
  git status
)}
alias gsu="git_submodule_update"
alias gtake="git checkout -b"
alias gti="git"

gu () {(
  (command -v cleanup >/dev/null 2>&1 && cleanup)

  # run only from within a git repository
  # https://stackoverflow.com/a/53809163
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git fetch --all --verbose

    # `git submodule update` with `--remote` appears to slow Git to a crawl
    # https://docs.google.com/spreadsheets/d/14W8w71DK0YpsePbgtDkyFFpFY1NVrCmVMaw06QY64eU
    if [ "$1" = --remote ] || [ "$1" = -r ]; then
      remote="--remote"
    fi
    git submodule update --init --recursive ${remote}
    git status
  fi
)}

# https://github.com/tarunsk/dotfiles/blob/5b31fd6/.always_forget.txt#L1957
gvc () {(
  # if there is an argument (commit hash), use it
  # otherwise check `HEAD`
  git verify-commit "${1:-HEAD}"
)}


# shell
cd_pwd_-P () {
  cd_from=$(pwd)
  cd_to=$(pwd -P)
  if [ "${cd_from}" != "${cd_to}" ]
  then
    printf 'moving from \xe2\x80\x98%s\xe2\x80\x99\n' "${cd_from}" && \
    sleep 0.5
    cd "${cd_to}" || (
      printf 'unable to perform this operation\n' && return 1
    )
    printf '       into \xe2\x80\x98%s\xe2\x80\x99\n' "${cd_to}" && \
    sleep 0.5
  else
    printf 'already in unaliased directory '
    printf '\xe2\x80\x98%s\xe2\x80\x99\n' "${cd_from}"
  fi
  unset cd_from cd_to
}
alias cdp='cd_pwd_-P'

# http://mywiki.wooledge.org/BashPitfalls?rev=524#Filenames_with_leading_dashes
alias cp="cp -r"
cy () {(
  if [ -r "$1" ]; then
    # if within git repo, then auto-overwrite
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      interactive="-i"
    fi
    if [ -z "$2" ]; then
      # if there is no second argument,
      # then copy to the current directory
      # -r to copy recursively
      # -L to follow symbolic links
      eval cp -r -L "${interactive} -- $1 ${PWD}"
    else
      eval cp -r -L "${interactive} -- $1 $2"
    fi
  elif [ -e "$1" ]; then
    printf '\x60%s\x60 is not readable and cannot be copied\n' "$1"
    return 1
  else
    printf '\x60%s\x60 does not exist and cannot be copied\n' "$1"
    return 2
  fi
)}

cleanup () {(
  # if `cleanup -v` or `cleanup --verbose`,
  # then use `-print` during `-delete`
  if [ "$1" = -v ] || [ "$1" = --verbose ]; then
    verbose=-print
  fi

  # delete thumbnail cache files
  find -- . -type f \( \
    -name '.DS_Store' -or \
    -name 'Desktop.ini' -or \
    -name 'desktop.ini' -or \
    -name 'Thumbs.db' -or \
    -name 'thumbs.db' \
    \) \
    ${verbose} -delete

  # delete empty, zero-length files
  # except those within `.git/` directories
  # or with specific names and are writable
  # https://stackoverflow.com/a/64863398
  find -- . -type f -writable -size 0 \( \
    -not -path '*/.git/*' -and \
    -not -name "$(printf 'Icon\x0d\x0a')" -and \
    -not -name '*.dirstamp' -and \
    -not -name '*.gitkeep' -and \
    -not -name '*.keep' -and \
    -not -name '*LOCK' -and \
    -not -name '*empty*' -and \
    -not -name '*hushlogin' -and \
    -not -name '*ignore' -and \
    -not -name '*journal' -and \
    -not -name '*lock' -and \
    -not -name '*lockfile' -and \
    -not -name '.sudo_as_admin_successful' \
    \) \
    ${verbose} -delete

  # delete empty directories recursively
  # but skip Git-specific and `/.well-known/` directories
  # https://stackoverflow.com/q/4210042#comment38334264_4210072
  find -- . -type d -empty \( \
    -not -path '*/.git/*' -and \
    -not -name '.well-known' \
    \) \
    ${verbose} -delete
)}

# find duplicate files
# https://linuxjournal.com/content/boost-productivity-bash-tips-and-tricks
fdf () {(
  set -Eeuxo pipefail
  find -- . -not -empty -type f -not -path '*/.git/*' -printf '%s\n' | sort --reverse --numeric-sort | uniq -d | xargs -I{} -n1 find -type f -size {}c -print0 | xargs -0 sha256sum | sort | uniq -w32 --all-repeated=separate
)}

alias l='ls -AFgho1 --time-style=+%4Y-%m-%d\ %l:%M:%S\ %P'

# https://unix.stackexchange.com/a/30950
alias mv="mv -v -i"

# take
# https://github.com/ohmyzsh/ohmyzsh/commit/7cba6bb
take () {
  mkdir -p -v -- "$@" &&
  printf 'cd: changed directory to \x27%s\x27\n' "${@:$#}" &&
  cd -- "${@:$#}" || return 1
}

# Unix epoch seconds
# https://stackoverflow.com/a/12312982
# date -j +%s # for milliseconds
alias unixtime="date +%s"

alias all="which -a"

# https://stackoverflow.com/a/1371283
# https://github.com/mathiasbynens/dotfiles/commit/cb8843b
alias ','='. "${HOME}/.${0##*[-/]}rc" && exec "${0##*[-/]}" --login'
alias aliases='"${EDITOR:-vi}" "${ZSH_CUSTOM:-${DOTFILES}/.oh-my-${0##*[-/]}/custom}/aliases.${0##*[-/]}"; . "${HOME}/.${0##*[-/]}rc" && exec "${0##*[-/]}" --login'
alias ohmyzsh='cd "${ZSH:-${HOME}/.oh-my-${0##*[-/]}}"'
alias zshconfig='"${EDITOR:-vi}" "${HOME}/.${0##*[-/]}rc"; . "${HOME}/.${0##*[-/]}rc" && exec "${0##*[-/]}" --login'
alias zshenv='"${EDITOR:-vi}" "${HOME}/.${0##*[-/]}env"; . "${HOME}/.${0##*[-/]}rc" && exec "${0##*[-/]}" --login'
alias zshrc='"${EDITOR:-vi}" "${HOME}/.${0##*[-/]}rc"; . "${HOME}/.${0##*[-/]}rc" && exec "${0##*[-/]}" --login'
