#!/usr/bin/env zsh

# aliases.zsh
# for all active aliases, run `alias`

# Atom
# https://github.com/jeefberkey/dotfiles/blob/2ded1c3/.zshrc#L48-L61
command -v atom-nightly >/dev/null 2>&1 &&
  alias atom='atom-nightly' &&
  alias atom-beta='atom-nightly'
command -v apm-nightly >/dev/null 2>&1 &&
  alias apm='apm-nightly' &&
  alias apm-beta='apm-nightly'

# dotfiles
# https://stackoverflow.com/q/4210042#comment38334264_4210072
mu() {
  cd "${DOTFILES:=${HOME}/Dropbox/dotfiles}" &&
    command -v cleanup >/dev/null 2>&1 && cleanup "$@" &&
    mackup backup --force --root &&
    git fetch --all --prune &&
    git submodule update --init --recursive &&
    git status
}
mux() {
  cd "${DOTFILES:=${HOME}/Dropbox/dotfiles}" &&
    command -v cleanup >/dev/null 2>&1 && cleanup "$@" &&
    mackup backup --force --root --verbose &&
    git fetch --all --prune --verbose &&
    git submodule update --init --recursive --remote &&
    git submodule sync --recursive &&
    git status
}

# git add
git_add() {
  git add --verbose -- "${@:-.}"
  git status
}
alias ga='git_add'
git_add_patch() {
  git add --patch --verbose -- "${@:-.}"
  git status
}
alias gap='git_add_patch'

# git commit
git_commit() {
  set -eux
  if [ $# -ne 0 ]; then
    git commit --verbose --gpg-sign --message "$@"
  else
    git commit --verbose --gpg-sign
  fi
  git status
  {
    set +eux
  } 2>/dev/null
}
alias gc='git_commit'
alias gcm='git_commit'
alias gca='git commit --verbose --gpg-sign --amend --allow-empty; git status'
alias gcl='git clone --verbose --progress'
alias gco='git checkout --progress'

# `git checkout` the default branch
alias gcom='git checkout --progress "$(git-default-branch)"'

# git cherry-pick
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcpn='git cherry-pick --no-commit'

git_delete_merged_branches() {
  # delete all local Git branches that have been merged
  # https://gist.github.com/8775224
  set -u
  if command git branch --merged | command grep -v '\*'; then
    command git branch --merged | command grep -v '\*' |
      command xargs -n 1 command git branch --delete --verbose
  fi
  { set +u; } 2>/dev/null
}
alias gdmb='git_delete_merged_branches'
alias gDmb='git_delete_merged_branches'
alias git-delete-merged-branches='git_delete_merged_branches'

alias gdm='git diff "$(git-default-branch)" --'
alias gsd='gds'

alias gfgs='git fetch --all --prune --verbose && git status'
git_garbage_collection() {
  command -v cleanup >/dev/null 2>&1 && cleanup "$@"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # see `git gc` and other wrapping commands behind-the-scene mechanics
    # https://github.com/git/git/blob/49eb8d3/contrib/examples/README#L14-L16
    git fetch --prune --prune-tags --verbose
    git prune --verbose --progress --expire now
    git prune-packed
    git gc --aggressive --prune=now
    git maintenance start >/dev/null 2>&1 && git maintenance start
    git status
  else
    return 1
  fi
}
alias ggc='git_garbage_collection'

# git parents
git_find_parent() {
  # return the hash prior to the current commit
  # if an argument is provided, return the commit prior to that commit
  # usage: git_find_parent [commit]
  command git rev-list --max-count=1 "${1:-$(command git rev-parse HEAD)}^"
}
git_find_parents() {
  # return all hashes prior to the current commit
  # if an argument is provided, return all commits prior to that commit
  # usage: git_find_parents [commit]
  command git rev-list "${1:-$(command git rev-parse HEAD)}^"
}
alias git_parent='git_find_parent'
alias git-find-parent='git_find_parent'
alias git-parent='git_find_parent'
alias gfp='git_find_parent'
alias gfc='git_find_parent'
alias git_parents='git_find_parents'
alias git-find-parents='git_find_parents'
alias git-parents='git_find_parents'

# initial commit
# https://stackoverflow.com/q/1006775#comment23686803_1007545
alias gic='git rev-list --topo-order --parents HEAD -- | grep -E "^[a-f0-9]{40}$"'
git_commit_initial_commit() {
  # usage: git_commit_initial_commit [yyyy-mm-dd]
  # create initial commits: one empty root, then the rest
  # https://news.ycombinator.com/item?id=25515963
  git init &&
    if [ $# -eq 1 ]; then
      GIT_TIME="$(date -d @$(($(date --date="$1" +%s) + 43200)) '+%c %z')" GIT_AUTHOR_DATE="${GIT_TIME}" GIT_COMMITTER_DATE="${GIT_AUTHOR_DATE}" git commit --allow-empty --verbose --message "$(printf '\xf0\x9f\x8c\xb3\xc2\xa0 root commit')"
    else
      git commit --allow-empty --verbose --message "$(printf '\xf0\x9f\x8c\xb3\xc2\xa0 root commit')"
    fi

  # if there are non-repository files present, then add them and commit
  if [ -n "$(git ls-files --others)" ]; then
    git add -- . &&
      git commit --verbose --message "$(printf '\xe2\x9c\xa8\xc2\xa0 initial commit')"
  fi

  unset GIT_TIME GIT_AUTHOR_DATE GIT_COMMITTER_DATE
}
alias gcic='git_commit_initial_commit'
alias ginit='git init && git status'

# git last common ancestor
git_last_common_ancestor() {
  # https://stackoverflow.com/a/1549155
  [ $# -eq 2 ] || return 1
  command git merge-base "$1" "$2"
}
alias glca='git_last_common_ancestor'
alias gmrca='git_last_common_ancestor'

# git log
# https://github.com/gggritso/gggritso.com/blob/a07b620/_posts/2015-08-23-human-git-aliases.md#readme
alias glog='git log --graph --branches --remotes --tags --format=format:"%Cgreen%h %Creset• %<(75,trunc)%s (%cN, %cr) %Cred%d" --date-order'

# https://news.ycombinator.com/item?id=5512864
alias gm='GIT_MERGE_VERBOSITY=4 git merge --log --overwrite-ignore --progress --rerere-autoupdate --strategy-option patience'
alias gmc='GIT_MERGE_VERBOSITY=4 git merge --log --continue'

# git merge main
gmm() {
  # set Git merge verbosity environment variable
  # 4 “shows all paths as they are processed” but
  # 5 is “show detailed debugging information”
  # https://github.com/progit/progit2/commit/aea93a7
  GIT_MERGE_VERBOSITY=4 git merge --log --verbose --progress --rerere-autoupdate --strategy-option patience "$(git-default-branch)"
}

alias gmv='git mv --verbose'

# git pull (Oh My Zsh `gupav`)
# https://github.com/ohmyzsh/ohmyzsh/commit/3d2542f
alias gpl='git pull --all --rebase --autostash --prune --verbose && git status'

# git push (Oh My Zsh `gpsup`)
# https://github.com/ohmyzsh/ohmyzsh/commit/ae21102
alias gps='git push --verbose --set-upstream origin "$(git_current_branch)" && git status'

alias gref='git reflog'

alias grmr='git rm -r'
alias grm='grmr'

git_restore() {
  for file in "$@"; do
    git checkout --progress -- "${file}"
  done && git status
}
alias grs='git_restore'
alias gs='git status'

git_submodule_update() {
  git submodule update --init --recursive --remote -- "$@" &&
    git submodule sync --recursive -- "$@" &&
    git status
}
alias gsu='git_submodule_update'
alias gtake='git checkout -b'
alias gti='git'

git_update() {
  command -v cleanup >/dev/null 2>&1 && cleanup "$@"

  # run only from within a git repository
  # https://stackoverflow.com/a/53809163
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git fetch --all --prune --verbose

    # `git submodule update` with `--remote` appears to slow Git to a crawl
    # https://docs.google.com/spreadsheets/d/14W8w71DK0YpsePbgtDkyFFpFY1NVrCmVMaw06QY64eU
    if [ "$1" = --remote ] || [ "$1" = -r ]; then
      remote="--remote"
    fi
    git submodule update --init --recursive ${remote}
    git submodule sync --recursive --
    git status
  fi
}
alias git-update='git_update'
alias gu='git-update'

# https://github.com/tarunsk/dotfiles/blob/5b31fd6/.always_forget.txt#L1957
gvc() {
  # if there is an argument (commit hash), use it
  # otherwise check `HEAD`
  git verify-commit "${1:-HEAD}"
}

atom_packages() {
  # https://web.archive.org/web/0id_/discuss.atom.io/t/15674/2
  {
    command apm-nightly list --installed --bare ||
      command apm-beta list --installed --bare ||
      command apm list --installed --bare
  } >"${1:-${DOTFILES:-${HOME}/Dropbox/dotfiles}/!=Mackup/atom}" 2>/dev/null
}

cd_pwd_P() {
  cd_from=$(pwd)
  cd_to=$(pwd -P)
  if [ "${cd_from}" != "${cd_to}" ]; then
    printf 'moving from \xe2\x80\x98%s\xe2\x80\x99\n' "${cd_from}" &&
      sleep 0.2
    cd "${cd_to}" || (
      printf 'unable to perform this operation\n' && return 1
    )
    printf '       into \xe2\x80\x98%s\xe2\x80\x99\n' "${cd_to}" &&
      sleep 0.2
  else
    printf 'already in unaliased directory '
    printf '\xe2\x80\x98%s\xe2\x80\x99\n' "${cd_from}"
  fi
  unset cd_from cd_to
}
alias cdp='cd_pwd_P'

clang_format() {
  # https://github.com/Originate/guide/blob/880952d/ios/files/clang-format.sh
  (
    program=clang-format

    # if no argument is provided, then set `IndentWidth` to 2
    # https://stackoverflow.com/a/2013573
    IndentWidth=${1:-2}

    # if no second argument is provided, then set `ColumnLimit` to 79
    # https://stackoverflow.com/a/48016407
    ColumnLimit=${2:-79}

    printf '\n%s\n\n' "$("${program}" --version)"
    sleep 1

    printf 'applying %s to all applicable files in %s...\n' "${program}" "${PWD##*/}"
    sleep 1

    printf 'setting \x60IndentWidth\x60 to %d\n' "${IndentWidth}"
    sleep 1

    printf 'setting \x60ColumnLimit\x60 to %d\n\n\n' "${ColumnLimit}"
    sleep 1

    find -- . -type f \
      \( \
      -iname '*.adb' -or \
      -iname '*.ads' -or \
      -iname '*.asm' -or \
      -iname '*.ast' -or \
      -iname '*.c' -or \
      -iname '*.c++' -or \
      -iname '*.c++m' -or \
      -iname '*.cc' -or \
      -iname '*.ccm' -or \
      -iname '*.cl' -or \
      -iname '*.cp' -or \
      -iname '*.cpp' -or \
      -iname '*.cppm' -or \
      -iname '*.cs' -or \
      -iname '*.cu' -or \
      -iname '*.cuh' -or \
      -iname '*.cui' -or \
      -iname '*.cxx' -or \
      -iname '*.cxxm' -or \
      -iname '*.f' -or \
      -iname '*.f90' -or \
      -iname '*.f95' -or \
      -iname '*.for' -or \
      -iname '*.fpp' -or \
      -iname '*.h' -or \
      -iname '*.h++' -or \
      -iname '*.hh' -or \
      -iname '*.hip' -or \
      -iname '*.hp' -or \
      -iname '*.hpp' -or \
      -iname '*.hxx' -or \
      -iname '*.i' -or \
      -iname '*.ifs' -or \
      -iname '*.ii' -or \
      -iname '*.iim' -or \
      -iname '*.inc' -or \
      -iname '*.inl' -or \
      -iname '*.java' -or \
      -iname '*.js' -or \
      -iname '*.ll' -or \
      -iname '*.m' -or \
      -iname '*.mi' -or \
      -iname '*.mii' -or \
      -iname '*.mm' -or \
      -iname '*.pcm' -or \
      -iname '*.proto' -or \
      -iname '*.protodevel' -or \
      -iname '*.rs' -or \
      -iname '*.tcc' -or \
      -iname '*.td' -or \
      -iname '*.theletters' -or \
      -iname '*.tlh' -or \
      -iname '*.tli' -or \
      -iname '*.tpp' -or \
      -iname '*.ts' -or \
      -iname '*.txx' \
      \) -and \
      \( \
      -not -path '*.git/*' -and \
      -not -path '*node_modules/*' \
      \) \
      -exec "${program}" -i --style "{IndentWidth: ${IndentWidth}, ColumnLimit: ${ColumnLimit}}" --verbose --fcolor-diagnostics --print-options {} \+
    printf '\n\n\xe2\x9c\x85 done\x21\n\n'
  )
}

# https://mywiki.wooledge.org/BashPitfalls?rev=524#Filenames_with_leading_dashes
alias cp='cp -r'
cy() {
  (
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
  )
}

cleanup() {
  # if `cleanup -v` or `cleanup --verbose`,
  # then use `-print` during `-delete`
  if [ "$1" = -v ] || [ "$1" = --verbose ]; then
    set -x && shift
  fi

  # refuse to run from `$HOME`
  [ "$(pwd -P)" = "${HOME}" ] && return 1
  # delete thumbnail cache files
  # and hide `find: ‘./com...’: Operation not permitted` with 2>/dev/null
  find -- "${1:-.}" -type f \( \
    -name '.DS_Store' -or \
    -name 'Desktop.ini' -or \
    -name 'desktop.ini' -or \
    -name 'Thumbs.db' -or \
    -name 'thumbs.db' \
    \) \
    -delete 2>/dev/null

  # delete crufty Zsh files
  # if `$ZSH_COMPDUMP` always generates a crufty file then skip
  # https://stackoverflow.com/a/8811800
  if [ "${ZSH_COMPDUMP#*'zcompdump-'}" != "${ZSH_COMPDUMP}" ]; then
    while [ -n "$(
      find -- "${HOME}" \
        -maxdepth 1 \
        -type f \
        -not -name "$(printf "*\n*")" \
        -not -name '.zcompdump' \
        -name '.zcompdump*' -print
    )" ]; do
      find -- "${HOME}" \
        -maxdepth 1 \
        -type f \
        -not -name "$(printf "*\n*")" \
        -not -name '.zcompdump' \
        -name '.zcompdump*' \
        -print \
        -exec rm -- {} \;
    done
  fi

  # delete empty, zero-length files
  # except those within `.git/` directories
  # or with specific names and are writable
  # https://stackoverflow.com/a/64863398
  find -- "${1:-.}" -type f -writable -size 0 \( \
    -not -path '*.git/*' -and \
    -not -path '*/test*' -and \
    -not -name "$(printf 'Icon\x0d\x0a')" -and \
    -not -name '*.plugin.zsh' -and \
    -not -name '*LOCK' -and \
    -not -name '*empty*' -and \
    -not -name '*hushlogin' -and \
    -not -name '*ignore' -and \
    -not -name '*journal' -and \
    -not -name '*lock' -and \
    -not -name '*lockfile' -and \
    -not -name '.dirstamp' -and \
    -not -name '.gitkeep' -and \
    -not -name '.gitmodules' -and \
    -not -name '.keep' -and \
    -not -name '.sudo_as_admin_successful' -and \
    -not -name '.watchmanconfig' -and \
    -not -name '__init__.py' -and \
    -not -name 'favicon.*' \
    \) \
    -delete

  # delete empty directories recursively
  # but skip Git-specific and `/.well-known/` directories
  # https://stackoverflow.com/q/4210042#comment38334264_4210072
  find -- "${1:-.}" -type d -empty \( \
    -not -path '*.git/*' -and \
    -not -name '.well-known' \
    \) \
    -delete
}

# number of files in current directory
# https://web.archive.org/web/200id_/tldp.org/HOWTO/Bash-Prompt-HOWTO/x700.html
count_files() {
  printf '%i\n' "$(command ls -A1 | wc -l)"
}

# define
define() {
  for query in "${@:-$0}"; do

    # hash
    command -v hash >/dev/null 2>&1 &&
      printf 'hash return value:\n%d\n———\n' "$(
        hash "${query}" >/dev/null 2>&1
        printf '%i\n' "$?"
      )"

    # type (System V)
    command -v type >/dev/null 2>&1 &&
      printf 'type:\n%s\n———\n' "$(type "${query}")"

    # whence (KornShell)
    command -v whence >/dev/null 2>&1 &&
      printf 'whence:\n%s\n———\n' "$(whence "${query}")"

    # where
    command -v where >/dev/null 2>&1 &&
      printf 'where:\n%s\n———\n' "$(where "${query}")"

    # whereis
    command -v whereis >/dev/null 2>&1 &&
      printf 'whereis:\n%s\n———\n' "$(whereis "${query}")"

    # locate
    command -v locate >/dev/null 2>&1 &&
      printf 'locate:\n%s\n———\n' "$(locate "${query}")"

    # command -V
    printf 'command -V:\n%s\n———\n' "$(command -V "${query}")"

    # command -v (POSIX)
    printf 'command -v:\n%s\n———\n' "$(command -v "${query}")"

    # which (C shell)
    command -v which >/dev/null 2>&1 &&
      printf 'which -a:\n%s\n' "$(which -a "${query}")"

  done
}

# find duplicate files
# https://linuxjournal.com/content/boost-productivity-bash-tips-and-tricks
fdf() {
  find -- . -not -empty -type f \( -not -path '*.git/*' -and -not -path '*node_modules*' \) -printf '%s\n' | sort --reverse --numeric-sort | uniq -d | xargs -I{} -n1 find -type f -size {}c -print0 | xargs -0 sha256sum | sort | uniq -w32 --all-repeated=separate
}

# find by name
fname() {
  find -- . -iname "*${*}*" 2>/dev/null
}
alias findname='fname'

find_shell_scripts() {
  set -eu
  {
    # all files with extensions `.bash`, `.ksh`, `.mksh`, `.sh`, `.zsh`
    command find -- . -type f \
      ! -path '*.git/*' \
      -iname '*.bash' -o \
      -iname '*.ksh' -o \
      -iname '*.mksh' -o \
      -iname '*.sh' -o \
      -iname '*.zsh' 2>/dev/null

    # files whose first line resembles those of shell scripts
    # https://stackoverflow.com/a/9612232
    command find -- . \
      ! -path '*.git/*' \
      -type f \
      -exec command head -n1 {} \+ 2>/dev/null |
      command grep \
        --binary-files=without-match \
        --exclude-dir='.git' \
        --files-with-matches \
        --recursive \
        '^#!.*bin.*sh' . 2>/dev/null

    # https://github.com/bzz/LangID/blob/37c4960/README.md#collect-the-data
    # https://github.com/stedolan/jq/issues/1735#issuecomment-427863218
    command github-linguist "$(
      command git rev-parse --show-toplevel 2>/dev/null
    )" --json 2>/dev/null |
      command jq --raw-output '.Shell[]' 2>/dev/null |

      # prepend filenames with `./`
      command awk '{print "./" $0}'

  } |
    command sort --unique

  { set +eu; } 2>/dev/null
}
alias find-shell-scripts='find_shell_scripts'

identify() {

  # uname
  command -v uname >/dev/null 2>&1 && uname -a

  # sw_vers
  # https://apple.stackexchange.com/a/368244
  command -v sw_vers >/dev/null 2>&1 && sw_vers

  # lsb_release
  # https://linuxize.com/post/how-to-check-your-debian-version
  command -v lsb_release >/dev/null 2>&1 && lsb_release --all

  # hostnamectl
  # https://linuxize.com/post/how-to-check-your-debian-version
  command -v hostnamectl >/dev/null 2>&1 && hostnamectl

  # /etc/os-release
  # https://linuxize.com/post/how-to-check-your-debian-version
  [ -r /etc/os-release ] && cat -v /etc/os-release

  # /proc/version
  # https://superuser.com/a/773608
  [ -r /proc/version ] && cat -v /proc/version

  # /etc/issue
  # https://linuxize.com/post/how-to-check-your-debian-version
  [ -r /etc/issue ] && cat -v /etc/issue
}

# list files
builtin unalias -- ls 2>/dev/null
builtin unalias -- l 2>/dev/null
if command exa --color=auto >/dev/null 2>&1; then
  alias ls='command exa --color=auto'
  alias l='ls --bytes --classify --git --header --icons --long --no-permissions --no-user --octal-permissions --time-style=long-iso'
elif command gls --color=auto >/dev/null 2>&1; then
  alias ls='command gls --color=auto'
  alias l='ls -AFgo --time-style=+%4Y-%m-%d\ %l:%M:%S\ %P'
elif command ls --color=auto >/dev/null 2>&1; then
  alias ls='command ls --color=auto'
  alias l='ls -AFgo --time-style=+%4Y-%m-%d\ %l:%M:%S\ %P'
elif [ "$(command /bin/ls -G -- "${HOME}" | hexdump)" = "$(command ls -G -- "${HOME}" | hexdump)" ] && [ "$(command ls -G -- "${HOME}" | hexdump)" != "$(command ls --color=auto -- "${HOME}" 2>/dev/null)" ]; then
  alias ls='command ls -G'
  alias l='ls -AFgo'
fi

# https://unix.stackexchange.com/a/30950
alias mv='mv -v -i'

# find files with non-ASCII characters
# https://unix.stackexchange.com/a/109753
non_ascii() {
  LC_ALL=C find -- . -not -path '*.git/*' -name '*[! -~]*'
}
alias non-ascii='non_ascii'

# paste faster
# https://git.io/pasteinit-pastefinish
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert "${OLD_SELF_INSERT}"
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

path_check() {
  # check that each directory in user `$PATH` still exists and is a directory

  # return verbose output if requested
  for argument in "$@"; do
    case ${argument} in
    -v | --verbose)
      set -o xtrace # set -x
      shift
      ;;
    *)
      printf 'usage: %s [-v|--verbose]\n' "$(basename "$0")"
      return 1
      ;;
    esac
  done

  for directory in $(
    # newline-delimited `$PATH` like Zsh `<<<${(F)path}`
    # https://stackoverflow.com/a/33469401
    printf %s "${PATH}" | xargs -d ':' -n 1
  ); do
    if [ -d "${directory}" ]; then
      printf 'is a directory: %s\n' "${directory}"
    else
      printf 'not a directory: %s\n' "${directory}"
    fi
  done

  # silently undo verbose output for everyone
  { set +x; } 2>/dev/null
}

# Python
command -v python3 >/dev/null 2>&1 &&
  alias python='python3' &&
  command -v pip3 >/dev/null 2>&1 &&
  alias pip='pip3'

# $?
question_mark() {
  # https://github.com/mcornella/dotfiles/commit/ff4e527
  printf '%i\n' "$?"
}
alias '?'='question_mark'

# sudo, even for aliases, but not functions
# https://github.com/mathiasbynens/dotfiles/commit/bb8de8b
alias sudo='sudo '

# mkdir && cd
take() {
  mkdir -p -v -- "$@" &&
    # https://github.com/ohmyzsh/ohmyzsh/commit/7cba6bb
    printf 'cd: changed directory to \xe2\x80\x98%s\xe2\x80\x99\n' "${@:$#}" &&
    cd -- "${@:$#}" || return 1
}

# Unix epoch seconds
# https://stackoverflow.com/a/12312982
# date -j +%s # for milliseconds
alias unixtime='date +%s'

# update
update() {
  (
    update=1
    clear && clear

    printf '                 .___       __\n __ ________   __\x7c _\x2f____ _\x2f  \x7c_  ____\n\x7c  \x7c  \x5c____ \x5c \x2f __ \x7c\x5c__  \x5c\x5c   __\x5c\x2f __ \x5c\n\x7c  \x7c  \x2f  \x7c_\x3e \x3e \x2f_\x2f \x7c \x2f __ \x5c\x7c  \x7c \x5c  ___\x2f\n\x7c____\x2f\x7c   __\x2f\x5c____ \x7c\x28____  \x2f__\x7c  \x5c___  \x3e\n      \x7c__\x7c        \x5c\x2f     \x5c\x2f          \x5c\x2f\n a Lucas Larson production\n\n'

    sleep 1.0

    printf '\n\xf0\x9f\x93\xa1 verifying network connectivity'
    sleep 0.5
    for ((i = 0; i < 2 ** 15; i = i + 1)); do
      if (((i / 3) % 2 == 0)); then
        printf '.'
      else
        printf '\b'
      fi
    done && printf '.\n'
    (
      ping -q -i1 -c1 one.one.one.one >/dev/null 2>&1 && ping -q -i1 -c1 8.8.8.8 >/dev/null 2>&1
    ) || (
      printf 'No internet connection was detected.\nAborting update.\n' && return "${update}"
    )

    ### Homebrew
    printf '\xf0\x9f\x8d\xba checking for Homebrew installation...\n'
    if command -v brew >/dev/null 2>&1; then
      printf '\xf0\x9f\x8d\xba checking for Homebrew updates...\n'
      brew update
      brew upgrade
      brew upgrade --cask
    else
      printf 'No Homebrew installation detected...\n'
    fi # brew

    ### Alpine Linux package keeper
    printf 'checking for Alpine Package Keeper installation...\n'
    if command -v apk >/dev/null 2>&1; then
      printf '\xf0\x9f\x8f\x94 apk update...\n'
      apk update --progress --verbose --verbose

      printf '\n\xf0\x9f\x8f\x94 apk upgrade...\n'
      apk upgrade --update-cache --progress --verbose --verbose

      printf '\n\xf0\x9f\x8f\x94 apk fix...\n'
      apk fix --progress --verbose --verbose

      printf '\n\xf0\x9f\x8f\x94 apk verify...\n'
      apk verify --progress --verbose --verbose
      printf '\xf0\x9f\x8f\x94 apk verify complete...\n\n'
    else
      printf 'no Alpine Package Keeper installation detected...\n'
    fi # apk

    ### Xcode
    printf 'checking for Xcode installation...\n'
    if command -v xcrun >/dev/null 2>&1; then
      printf 'removing unavailable device simulators...\n'
      xcrun simctl delete unavailable
    else
      printf 'no Xcode installation detected...\n'
    fi # xcrun

    ### Atom
    printf 'checking for Atom installation...\n'
    if command -v apm >/dev/null 2>&1; then
      printf 'updating Atom packages...\n'
      apm upgrade --no-confirm
    else
      printf 'no Atom installation detected...\n'
    fi # apm

    ### Rust
    printf 'checking for Rust installation...\n'
    if command -v rustup >/dev/null 2>&1; then
      rustup update
    else
      printf 'no Rust installation detected...\n'
    fi # rustup

    ### Node
    if command -v npm >/dev/null 2>&1; then
      printf 'checking this device is can update Node quickly...\n'
      if [ $((COLUMNS * LINES)) -ge $((80 * 24)) ]; then
        npm install npm --global
        npm update --global --verbose
      else
        printf 'skipping Node update...\n\n' && sleep 1
        printf 'to update Node later, run:\n\n'
        printf '    npm install npm --global && \x5c'
        printf '    npm update --global --verbose\x60\n\n\n'
        sleep 3
      fi # columns

    fi # npm

    ### RubyGems
    if command -v gem >/dev/null 2>&1; then
      gem update --system
      gem update
    fi # gem

    ### rbenv
    if command -v rbenv >/dev/null 2>&1; then
      rbenv rehash
    fi # rbenv

    ### Python
    if command -v python >/dev/null 2>&1; then
      printf '\n\xf0\x9f\x90\x8d verifying Python\xe2\x80\x99s packager is up to date...\n'
      python -m pip install --upgrade pip

      ### pip
      printf 'verifying pip installation...\n'
      if command -v pip >/dev/null 2>&1; then
        printf '\n\xf0\x9f\x90\x8d updating outdated Python packages...\n'
        for package in $(pip list --outdated --format freeze); do
          pip install --upgrade --verbose --verbose --verbose "${package%%=*}"
        done
      fi # pip

      ### pyenv
      printf 'checking for pyenv installation...\n'
      if command -v pyenv >/dev/null 2>&1; then
        printf 'rehashing pyenv shims...\n'
        pyenv rehash
      else
        printf 'no pyenv installation detected...\n'
      fi # pyenv

    fi # python

    ### Oh My Zsh
    if command -v omz >/dev/null 2>&1; then

      # because otherwise omz will force this to exit
      omz update >/dev/null 2>&1 &
    fi # omz

    ### ~/.shrc
    # shellcheck source=/dev/null
    if [ -r "${HOME}"/."${SHELL##*[-/]}"rc ]; then
      . "${HOME}"/."${SHELL##*[-/]}"rc
    fi # ~/.shrc

    ### rehash
    if command -v rehash >/dev/null 2>&1; then
      rehash
    fi # rehash
    unset update

    printf '\n\n\xe2%s\x9c\x85 done\x21\n\n' "${update}"
    exec -l ${SHELL##*[-/]}
  )
}

alias all='which -a'

# https://stackoverflow.com/a/1371283
# https://github.com/mathiasbynens/dotfiles/commit/cb8843b
# https://zsh.sourceforge.io/Doc/Release/Shell-Grammar.html#index-exec
alias ','='. -- "${HOME}"/."${SHELL##*[-/]}"rc && exec -l -- ${SHELL##*[-/]}'
alias aliases='${EDITOR:-vi} -- "${ZSH_CUSTOM:=${DOTFILES}/custom}"/aliases."${SHELL##*[-/]}"; . -- "${HOME}"/."${SHELL##*[-/]}"rc && exec -l -- ${SHELL##*[-/]}'
alias ohmyzsh='cd -- "${ZSH:=${HOME}/.oh-my-${SHELL##*[-/]}}" && git status'
alias zshenv='${EDITOR:-vi} -- "${HOME}"/."${SHELL##*[-/]}"env; . -- "${HOME}"/."${SHELL##*[-/]}"rc && exec -l -- ${SHELL##*[-/]}'
alias zshrc='${EDITOR:-vi} -- "${HOME}"/."${SHELL##*[-/]}"rc; . -- "${HOME}"/."${SHELL##*[-/]}"rc && exec -l -- ${SHELL##*[-/]}'
alias zshconfig='zshrc'
