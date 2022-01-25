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

atom_packages() {
  # https://web.archive.org/web/0id_/discuss.atom.io/t/15674/2
  command apm-nightly list --installed --bare ||
    command apm-beta list --installed --bare ||
    command apm list --installed --bare
  { set +euvx; } 2>/dev/null
}

# dotfiles
# https://stackoverflow.com/q/4210042#comment38334264_4210072
mu() {
  cd "${DOTFILES-}" &&
    command -v cleanup >/dev/null 2>&1 && cleanup "$@" &&
    mackup backup --force --root &&
    command git fetch --all --prune &&
    command git submodule update --init --recursive &&
    command git status
}
mux() {
  cd "${DOTFILES-}" &&
    command -v cleanup >/dev/null 2>&1 && cleanup "$@" &&
    mackup backup --force --root --verbose &&
    command git fetch --all --prune --verbose &&
    command git submodule update --init --recursive --remote &&
    command git submodule sync --recursive &&
    command git status
}

# Git
unalias -- g 2>/dev/null
compdef g='git' 2>/dev/null
g() {
  {
    test "$#" -eq '0' &&
      command git status
  } ||
    command git "$@" || command git status .
}
alias g.='command git status .'
alias guo='command git status --untracked-files=no'

# git add
git_add() {
  command git add --verbose "${@:-.}"
  command git status
}
alias ga='git_add'

git_add_deleted() {
  # https://gist.github.com/8775224
  command git ls-files -z --deleted | command xargs -0 git add --verbose -- 2>/dev/null
}

git_add_patch() {
  command git add --patch --verbose "${@:-.}"
  command git status
}
alias gap='git_add_patch'

git_add_untracked() {
  while test -n "$(command git ls-files --others --exclude-standard)"; do
    command git ls-files -z --others --exclude-standard | command xargs -0 git add --verbose -- 2>/dev/null
  done
  command git status
}
alias git_add_others='git_add_untracked'

# git commit
git_commit() {
  set -u
  if test "$#" -eq '0'; then
    command git commit --verbose || return 1
  elif test "$1" = '--amend'; then
    command git commit --verbose --amend || return 1
  else
    command git commit --verbose --message "$@" || return 1
  fi
  command git status
  { set +euvx; } 2>/dev/null
}
alias gc='git_commit'
alias gcm='git_commit'
alias gca='git_commit --amend'

alias gcl='command git clone --verbose --progress'
alias gco='command git checkout --progress'

# `git checkout` the default branch
alias gcom='command git checkout --progress "$(git-default-branch)"'

# git cherry-pick
alias gcp='command git cherry-pick'
alias gcpa='command git cherry-pick --abort'
alias gcpc='command git cherry-pick --continue'
alias gcpn='command git cherry-pick --no-commit'

git_delete_merged_branches() {
  # delete all local Git branches that have been merged
  # https://gist.github.com/8775224
  set -u
  if command git branch --merged | command grep -v '\*'; then
    command git branch --merged | command grep -v '\*' |
      command xargs -n 1 git branch --delete --verbose
  fi
  { set +euvx; } 2>/dev/null
}
alias gdmb='git_delete_merged_branches'
alias gDmb='git_delete_merged_branches'

alias gdm='command git diff "$(git-default-branch)" --'
alias gdom='command git diff "$(git-default-branch)" origin/"$(git-default-branch)" || command git diff "$(git-default-branch)" upstream/"$(git-default-branch)"'
alias gdw='command git diff --word-diff=color'
alias gsd='gds'

alias gfgs='command git fetch --all --prune --verbose && command git status'
git_garbage_collection() {
  command -v cleanup >/dev/null 2>&1 && cleanup "$@"
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # see `git gc` and other wrapping commands behind-the-scene mechanics
    # https://github.com/git/git/blob/49eb8d3/contrib/examples/README#L14-L16
    GIT_TRACE=true GIT_TRACE_PACK_ACCESS=true GIT_TRACE_PACKET=true GIT_TRACE_PERFORMANCE=true GIT_TRACE_SETUP=true command git fetch --prune --prune-tags --verbose 2>/dev/null
    GIT_TRACE=true GIT_TRACE_PACK_ACCESS=true GIT_TRACE_PACKET=true GIT_TRACE_PERFORMANCE=true GIT_TRACE_SETUP=true command git prune --verbose --progress --expire=now 2>/dev/null
    GIT_TRACE=true GIT_TRACE_PACK_ACCESS=true GIT_TRACE_PACKET=true GIT_TRACE_PERFORMANCE=true GIT_TRACE_SETUP=true command git prune-packed
    GIT_TRACE=true GIT_TRACE_PACK_ACCESS=true GIT_TRACE_PACKET=true GIT_TRACE_PERFORMANCE=true GIT_TRACE_SETUP=true command git gc --aggressive --prune=now
    GIT_TRACE=true GIT_TRACE_PACK_ACCESS=true GIT_TRACE_PACKET=true GIT_TRACE_PERFORMANCE=true GIT_TRACE_SETUP=true command git repack -a -d -f -F --window=4095 --depth=4095
    GIT_TRACE=true GIT_TRACE_PACK_ACCESS=true GIT_TRACE_PACKET=true GIT_TRACE_PERFORMANCE=true GIT_TRACE_SETUP=true command git status
    unset GIT_TRACE GIT_TRACE_PACK_ACCESS GIT_TRACE_PACKET GIT_TRACE_PERFORMANCE GIT_TRACE_SETUP
  else
    return 1
  fi
}
alias ggc='git_garbage_collection'

# git parents, git child
git_find_child() {
  set -e
  set -u
  commit="${1:-"$(command git rev-parse HEAD)"}"
  # %H: commit hash
  # %P: parent commit
  command git log --pretty='%H %P' |
    command grep " ${commit-}" |
    command cut -c 1-40
  { set +euvx; } 2>/dev/null
}
git_find_parent() {
  # return the hash prior to the current commit
  # if an argument is provided, return the commit prior to that commit
  # usage: git_find_parent <commit>
  command git rev-list --max-count=1 "${1:-$(command git rev-parse HEAD)}^"
}
git_find_parents() {
  # return all hashes prior to the current commit
  # if an argument is provided, return all commits prior to that commit
  # usage: git_find_parents <commit>
  command git rev-list "${1:-$(command git rev-parse HEAD)}^"
}
alias git_parent='git_find_parent'
alias gfp='git_find_parent'
alias gfc='git_find_child'
alias git_parents='git_find_parents'

# find initial commit
git_find_initial_commit() {
  # https://stackoverflow.com/q/1006775#comment23686803_1007545
  command git rev-list --topo-order --parents HEAD -- |
    command grep -E '^[a-f0-9]{40}$'
}
alias gic='git_find_initial_commit'

# commit initial commit
git_commit_initial_commit() {
  # usage: git_commit_initial_commit [yyyy-mm-dd]
  # create initial commits: one empty root, then the rest
  # https://news.ycombinator.com/item?id=25515963
  command git init &&
    if test "$#" -eq '1'; then

      # add 12 hours (43,200 seconds) so it occurs around midday
      git_time="$(command date -d @$(($(command date -d "${1:-$(command date '+%Y-%m-%d')}" '+%s') + 43200)) '+%c %z')"
      export GIT_AUTHOR_DATE="${git_time-}"
      export GIT_COMMITTER_DATE="${git_time-}"
    fi
  command git commit --allow-empty --verbose --message="$(printf '\360\237\214\263\302\240 root commit')"

  # if there are non-repository files present, then add them and commit
  if test -n "$(command git ls-files --others --exclude-standard)"; then
    command git add --verbose -- . &&
      command git commit --verbose --message="$(printf '\342\234\250\302\240 initial commit')"
  fi
  unset git_time GIT_AUTHOR_DATE GIT_COMMITTER_DATE
}
alias gcic='git_commit_initial_commit'
alias ginit='command git init && command git status'

# git last common ancestor
git_last_common_ancestor() {
  # https://stackoverflow.com/a/1549155
  test "$#" -eq '2' || return 1
  command git merge-base "$1" "$2"
}
alias glca='git_last_common_ancestor'
alias gmrca='git_last_common_ancestor'

# git log
# https://github.com/gggritso/gggritso.com/blob/a07b620/_posts/2015-08-23-human-git-aliases.md#readme
alias glog='command git log --graph --branches --remotes --tags --format=format:"%Cgreen%h %Creset• %<(75,trunc)%s (%cN, %cr) %Cred%d" --date-order'

# git merge
unalias -- gm 2>/dev/null
gm() {
  # https://news.ycombinator.com/item?id=5512864
  GIT_MERGE_VERBOSITY=4 command git merge --log --overwrite-ignore --progress --rerere-autoupdate --strategy-option patience
}
gmc() {
  GIT_MERGE_VERBOSITY=4 command git merge --log --continue
}

# git merge with default branch
gmm() {
  # set Git merge verbosity environment variable
  # 4 “shows all paths as they are processed” but
  # 5 is “show detailed debugging information”
  # https://github.com/progit/progit2/commit/aea93a7
  GIT_MERGE_VERBOSITY=4 command git merge --log --verbose --progress --rerere-autoupdate --strategy-option patience "$(git-default-branch)"
}

alias gmv='command git mv --verbose'
alias gmvf='command git mv --verbose --force'

# git pull
git_pull() {
  # https://github.com/ohmyzsh/ohmyzsh/commit/3d2542f
  command git pull --all --rebase --autostash --prune --verbose "${@-}" || {
    command git rebase --abort
    command git rebase --strategy-option=theirs
  }
  command git status
}
alias gpl='git_pull'
alias gp='git_pull'

# git push
git_push() {
  # https://github.com/ohmyzsh/ohmyzsh/commit/ae21102
  command git push --verbose --progress --set-upstream origin "$(git_current_branch)" &&
    command git status
}
alias gps='git_push'

alias gref='command git reflog'

alias grmr='command git rm -r'
alias grm='grmr'

git_restore() {
  for file in "$@"; do
    command git checkout --progress -- "${file-}"
  done && command git status
  unset file
}
alias grs='git_restore'

git_shallow() {
  # Shallow .gitmodules submodule installations
  # Mauricio Scheffer https://stackoverflow.com/a/2169914

  command git submodule init
  for submodule in $(command git submodule | command sed -e 's/.* //'); do
    submodule_path="$(command git config --file .gitmodules --get submodule."${submodule-}".path)"
    submodule_url="$(command git config --file .gitmodules --get submodule."${submodule-}".url)"
    command git clone --depth=1 --shallow-submodules "${submodule_url-}" "${submodule_path-}"
  done
  command git submodule update

  unset submodule submodule_path submodule_url
}

# https://github.com/ohmyzsh/ohmyzsh/commit/69ba6e4
alias gstall='command git stash save --all'

alias gs='command git status'

git_submodule_update() {
  command git submodule update --init --remote "$@" &&
    command git submodule sync "$@" &&
    command git status
}
alias gsu='git_submodule_update'
alias gtake='git checkout -b'

git_update() {
  command -v cleanup >/dev/null 2>&1 && cleanup "$@"

  # run only from within a Git repository
  # https://stackoverflow.com/a/53809163
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    command git fetch --all --prune --verbose

    # `git submodule update` with `--remote` appears to slow Git to a crawl
    # https://docs.google.com/spreadsheets/d/14W8w71DK0YpsePbgtDkyFFpFY1NVrCmVMaw06QY64eU
    case "$1" in
    -r | --remote)
      command git submodule update --init --recursive --remote "$@"
      ;;
    *)
      command git submodule update --init --recursive "$@"
      ;;
    esac
    command git submodule sync --recursive "$@"
    command git status
  fi
}
alias gu='git_update'

# https://github.com/tarunsk/dotfiles/blob/5b31fd6/.always_forget.txt#L1957
gvc() {
  # if there is an argument (commit hash), use it
  # otherwise check `HEAD`
  command git verify-commit "${1:-HEAD}"
}

bash_major_version() {
  # confirm Bash version is at least any given version (default: at least Bash 4)
  if test "$(command bash --version | command head -n 1 | command awk '{ print $4 }' | command cut -d . -f 1)" -lt "${1:-4}"; then
    printf 'You will need to upgrade to version %s for full functionality.\n' "${1:-4}" >&2
    return 1
  fi
}
alias bash_version='bash_major_version'

cd_pwd_P() {
  cd_from="$(command pwd -L)"
  cd_to="$(command pwd -P)"
  if test "${cd_from-}" != "${cd_to-}"; then
    printf 'moving from \342\200\230%s\342\200\231\n' "${cd_from-}"
    sleep 0.2
    cd "${cd_to-}" || {
      printf 'unable to perform this operation\n'
      return 1
    }
    printf '       into \342\200\230%s\342\200\231\n' "${cd_to-}"
    sleep 0.2
  else
    printf 'already in unaliased directory '
    printf '\342\200\230%s\342\200\231\n' "${cd_from-}"
  fi
  unset cd_from cd_to
}
alias cdp='cd_pwd_P'

clang_format() {
  # https://github.com/Originate/guide/blob/880952d/ios/files/clang-format.sh

  # if no argument is provided, then set `IndentWidth` to 2
  # https://stackoverflow.com/a/2013573
  IndentWidth="${1:-2}"

  # if no second argument is provided, then set `ColumnLimit` to 79
  # https://stackoverflow.com/a/48016407
  ColumnLimit="${2:-79}"

  command clang-format --version 2>/dev/null || return 2
  sleep 1

  printf 'applying clang-format to all applicable files in %s...\n' "${PWD##*/}"
  sleep 1

  printf 'setting \140IndentWidth\140 to %d\n' "${IndentWidth-}"
  sleep 1

  printf 'setting \140ColumnLimit\140 to %d\n\n\n' "${ColumnLimit-}"
  sleep 1

  find -- . -type f \
    \( \
    -iname '*.adb' -o \
    -iname '*.ads' -o \
    -iname '*.asm' -o \
    -iname '*.ast' -o \
    -iname '*.c' -o \
    -iname '*.c++' -o \
    -iname '*.c++m' -o \
    -iname '*.cc' -o \
    -iname '*.ccm' -o \
    -iname '*.cl' -o \
    -iname '*.cp' -o \
    -iname '*.cpp' -o \
    -iname '*.cppm' -o \
    -iname '*.cs' -o \
    -iname '*.cu' -o \
    -iname '*.cuh' -o \
    -iname '*.cui' -o \
    -iname '*.cxx' -o \
    -iname '*.cxxm' -o \
    -iname '*.f' -o \
    -iname '*.f90' -o \
    -iname '*.f95' -o \
    -iname '*.for' -o \
    -iname '*.fpp' -o \
    -iname '*.h' -o \
    -iname '*.h++' -o \
    -iname '*.hh' -o \
    -iname '*.hip' -o \
    -iname '*.hp' -o \
    -iname '*.hpp' -o \
    -iname '*.hxx' -o \
    -iname '*.i' -o \
    -iname '*.ifs' -o \
    -iname '*.ii' -o \
    -iname '*.iim' -o \
    -iname '*.inc' -o \
    -iname '*.inl' -o \
    -iname '*.java' -o \
    -iname '*.ll' -o \
    -iname '*.m' -o \
    -iname '*.mi' -o \
    -iname '*.mii' -o \
    -iname '*.mm' -o \
    -iname '*.pcm' -o \
    -iname '*.proto' -o \
    -iname '*.protodevel' -o \
    -iname '*.rs' -o \
    -iname '*.tcc' -o \
    -iname '*.td' -o \
    -iname '*.theletters' -o \
    -iname '*.tlh' -o \
    -iname '*.tli' -o \
    -iname '*.tpp' -o \
    -iname '*.ts' -o \
    -iname '*.txx' \
    \) -a \
    \( \
    ! -path '*.git/*' \
    ! -path '*.vscode/*' \
    ! -path '*/test*' \
    ! -path '*node_modules/*' \
    \) \
    -exec clang-format -i --style "{IndentWidth: ${IndentWidth-}, ColumnLimit: ${ColumnLimit-}}" --verbose --fcolor-diagnostics --print-options {} \+
  printf '\n\n\342\234\205 done\041\n\n'

  unset IndentWidth ColumnLimit
}

# https://mywiki.wooledge.org/BashPitfalls?rev=524#Filenames_with_leading_dashes
alias cp='cp -R'
cy() {
  if test -r "$1"; then
    # if within git repo, then auto-overwrite
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      interactive='-i'
    fi
    if test -z "$2"; then
      # if there is no second argument,
      # then copy to the current directory
      # -r to copy recursively
      # -L to follow symbolic links
      eval cp -r -L "${interactive-} -- $1 ${PWD-}"
    else
      eval cp -r -L "${interactive-} -- $1 $2"
    fi
  elif test -e "$1"; then
    printf '\140%s\140 is not readable and cannot be copied\n' "$1"
    exit 1
  else
    printf '\140%s\140 does not exist and cannot be copied\n' "$1"
    exit 3
  fi
  unset interactive
}

cleanup() {
  case "$1" in
  # if `cleanup -v` or `cleanup --verbose`,
  # then use `-print` during `-delete`
  -v | --verbose)
    set -v
    set -x
    shift
    ;;
  esac

  # refuse to run from `$HOME`
  test "$(pwd -P)" = "${HOME-}" && return 1
  # delete thumbnail cache files
  # and hide `find: ‘./com...’: Operation not permitted` with 2>/dev/null
  find -- "${1:-.}" -type f \( \
    -name '.DS_Store' -o \
    -name 'Desktop.ini' -o \
    -name 'desktop.ini' -o \
    -name 'Thumbs.db' -o \
    -name 'thumbs.db' \
    \) \
    -delete 2>/dev/null

  # delete crufty Zsh files
  # if `$ZSH_COMPDUMP` always generates a crufty file then skip
  # https://stackoverflow.com/a/8811800
  if test -n "${ZSH_COMPDUMP-}" && test "${ZSH_COMPDUMP#*'zcompdump-'}" != "${ZSH_COMPDUMP-}"; then
    while test -n "$(
      find -- "${HOME-}" \
        -maxdepth 1 \
        -type f \
        ! -name "$(printf "*\n*")" \
        ! -name '.zcompdump' \
        -name '.zcompdump*' -print
    )"; do
      find -- "${HOME-}" \
        -maxdepth 1 \
        -type f \
        ! -name "$(printf "*\n*")" \
        ! -name '.zcompdump' \
        -name '.zcompdump*' \
        -print \
        -delete -- {} \;
    done
  fi

  # delete empty, writable, zero-length files
  # except those within `.git/` directories
  # and except those with specific names
  # https://stackoverflow.com/a/64863398
  find -- "${1:-.}" -type f -writable -size 0 \( \
    ! -path '*.git/*' \
    ! -path '*/test*' \
    ! -name "$(printf 'Icon\015\012')" \
    ! -name '*.plugin.zsh' \
    ! -name '*LOCK' \
    ! -name '*empty*' \
    ! -name '*hushlogin' \
    ! -name '*ignore' \
    ! -name '*journal' \
    ! -name '*lock' \
    ! -name '*lockfile' \
    ! -name '.dirstamp' \
    ! -name '.gitkeep' \
    ! -name '.gitmodules' \
    ! -name '.keep' \
    ! -name '.nojekyll' \
    ! -name '.sudo_as_admin_successful' \
    ! -name '.watchmanconfig' \
    ! -name '__init__.py' \
    ! -name 'favicon.*' \
    \) \
    -delete

  # delete empty directories recursively
  # but skip Git-specific and `/.well-known/` directories
  # https://stackoverflow.com/q/4210042#comment38334264_4210072
  find -- "${1:-.}" -type d -empty \( \
    ! -path '*.git/*' \
    ! -name '.well-known' \
    \) \
    -delete
}

# number of files in current directory
# https://web.archive.org/web/200id_/tldp.org/HOWTO/Bash-Prompt-HOWTO/x700.html
count_files() {
  # https://unix.stackexchange.com/a/1126
  command find -- .//. ! -path '*.git/*' ! -name '.' -print |
    command grep -c //
}

# number of files
# in current directory
count_files_in_this_directory() {
  case "$@" in
  # count files as well as directories
  -d | --directory | --directories)
    command find -- . ! -path '*.git/*' ! -name '.' -prune -print |
      command grep -c /
    ;;

    # count only regular, non-directory files
  *)
    # https://unix.stackexchange.com/a/1126
    command find -- . -type f ! -path '*.git/*' ! -name '.' -prune -print |
      command grep -c /
    ;;
  esac
}

count_files_by_extension() {
  # files with no extension
  printf ' %i files without extensions\n' "$(
    command find -- . ! -path '*.git/*' -type f ! -name '*.*' -exec basename -a -- {} \+ 2>/dev/null |
      command grep -c -v '\.'
  )"

  # files with extensions
  command find -- . ! -path '*.git/*' -type f -exec basename -a -- {} \+ 2>/dev/null |

    # https://2daygeek.com/how-to-count-files-by-extension-in-linux
    command sed -n -- 's/..*\.//p' |
    command sort |
    command uniq -c |
    command sort -r
}

# define
define() {
  for query in "${@:-$0}"; do

    # hash
    command -v hash >/dev/null 2>&1 &&
      printf 'hash return value:\n%d\n———\n' "$(
        hash "${query-}" >/dev/null 2>&1
        printf '%i\n' "$?"
      )"

    # type (System V)
    command -v type >/dev/null 2>&1 &&
      printf 'type:\n%s\n———\n' "$(type "${query-}")"

    # whence (KornShell)
    command -v whence >/dev/null 2>&1 &&
      printf 'whence:\n%s\n———\n' "$(whence "${query-}")"

    # where
    command -v where >/dev/null 2>&1 &&
      printf 'where:\n%s\n———\n' "$(where "${query-}")"

    # whereis
    command -v whereis >/dev/null 2>&1 &&
      printf 'whereis:\n%s\n———\n' "$(whereis "${query-}")"

    # locate
    command -v locate >/dev/null 2>&1 &&
      printf 'locate:\n%s\n———\n' "$(locate "${query-}")"

    # command -V
    printf 'command -V:\n%s\n———\n' "$(command -V "${query-}")"

    # command -v (POSIX)
    printf 'command -v:\n%s\n———\n' "$(command -v "${query-}")"

    # which (C shell)
    command -v which >/dev/null 2>&1 &&
      printf 'which -a:\n%s\n' "$(which -a "${query-}")"

  done
  unset query
}

# find broken symlinks
find_broken_symlinks() {
  set -u
  # https://unix.stackexchange.com/a/49470
  command find -- . ! -path '*.git/*' -type l -exec test ! -e {} \; -print 2>/dev/null
  { set +euvx; } 2>/dev/null
}

# find duplicate files
# https://linuxjournal.com/content/boost-productivity-bash-tips-and-tricks
fdf() {
  command find -- "${1:-.}" \
    ! -path '*.git/*' \
    ! -path '*.vscode/*' \
    ! -path '*/test*' \
    ! -path '*node_modules/*' \
    ! -empty \
    ! -type l \
    -type f \
    -printf '%s\n' 2>/dev/null |
    command sort -r -n |
    command uniq -d |
    command xargs -I{} -n 1 find -type f -size {}c -print0 2>/dev/null |
    command xargs -0 sha1sum 2>/dev/null |
    command sort |
    command uniq -w 32 --all-repeated=separate
}

# find by name
fname() {
  find -- . \
    ! -path '*.git/*' \
    ! -path '*.vscode/*' \
    ! -path '*/test*' \
    ! -path '*Application Support*' \
    ! -path '*Archive*' \
    ! -path '*archive*' \
    ! -path '*custom/plugins*' \
    ! -path '*custom/themes*' \
    ! -path '*node_modules/*' \
    -iname "*${*}*" 2>/dev/null | sort -u
}
alias findname='fname'

find_shell_scripts() {
  set -e
  set -u
  {
    # all files with extensions `.bash`, `.dash`, `.ksh`, `.mksh`, `.sh`, `.zsh`
    command find -- . -type f \
      ! -path '*.git/*' \
      -iname '*.bash' -o \
      -iname '*.dash' -o \
      -iname '*.ksh' -o \
      -iname '*.mksh' -o \
      -iname '*.sh' -o \
      -iname '*.zsh' 2>/dev/null

    # files whose first line resembles those of shell scripts
    # https://stackoverflow.com/a/9612232
    command find -- . \
      ! -path '*.git/*' \
      ! -path '*.vscode/*' \
      ! -path '*/test*' \
      ! -path '*node_modules/*' \
      -type f \
      -exec head -n1 {} \+ 2>/dev/null |
      command grep \
        -I \
        -l \
        -r \
        --exclude-dir='.git' \
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
    command sort -u

  { set +euvx; } 2>/dev/null
}

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
  test -r /etc/os-release && cat -v /etc/os-release

  # /proc/version
  # https://superuser.com/a/773608
  test -r /proc/version && cat -v /proc/version

  # /etc/issue
  # https://linuxize.com/post/how-to-check-your-debian-version
  test -r /etc/issue && cat -v /etc/issue
}

# list files
unalias -- ls 2>/dev/null
unalias -- l 2>/dev/null
if command exa --color=auto >/dev/null 2>&1; then
  alias ls='command exa --color=auto'
  alias l='command exa --color=auto --bytes --classify --git --header --icons --long --no-permissions --no-user --octal-permissions --time-style=long-iso'
elif command gls --color=auto >/dev/null 2>&1; then
  alias ls='command gls --color=auto'
  alias l='command gls --color=auto -AFgo --time-style=+%4Y-%m-%d\ %l:%M:%S\ %P'
elif command ls --color=auto >/dev/null 2>&1; then
  alias ls='command ls --color=auto'
  alias l='command ls --color=auto -AFgo --time-style=+%4Y-%m-%d\ %l:%M:%S\ %P'
elif test "$(command /bin/ls -G -- "${HOME-}" | hexdump)" = "$(command ls -G -- "${HOME-}" | hexdump)" && test "$(command ls -G -- "${HOME-}" | hexdump)" != "$(command ls --color=auto -- "${HOME-}" 2>/dev/null)"; then
  alias ls='command ls -G'
  alias l='command ls -G -AFgo'
fi

# https://unix.stackexchange.com/a/30950
alias mv='mv -v -i'

# find files with non-ASCII characters
non_ascii() {
  LC_ALL=C find -- . ! -path '*.git/*' -name '*[! -~]*'
}

# paste faster
# https://git.io/pasteinit-pastefinish
pasteinit() {
  OLD_SELF_INSERT="${"${(s.:.)widgets[self-insert]}"[2,3]}"
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert "${OLD_SELF_INSERT-}"
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

path_check() {
  # check that each directory in user `$PATH` still exists and is a directory

  # return verbose output if requested
  for argument in "$@"; do
    case ${argument-} in

    # return verbose output if requested
    -v | --verbose)
      set -x
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
    printf %s "${PATH-}" | xargs -d ':' -n 1
  ); do
    if test -d "${directory-}"; then
      printf 'is a directory: %s\n' "${directory-}"
    else
      printf 'not a directory: %s\n' "${directory-}"
    fi
  done

  # silently undo verbose output for everyone
  { set +euvx; } 2>/dev/null

  unset argument directory
}

# PlistBuddy
if test -x /usr/libexec/PlistBuddy; then
  # https://apple.stackexchange.com/a/414774
  alias PlistBuddy='/usr/libexec/PlistBuddy'
  alias plistbuddy='PlistBuddy'
fi

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

# remove
rm() {
  if command -v trash >/dev/null 2>&1; then
    utility='trash'
  else
    utility='rm'
  fi
  case "$1" in
  -o | --others)
    command git ls-files -z --others --exclude-standard |
      command xargs -0 "${utility-}"
    ;;
  *)
    command "${utility-}" "$@"
    ;;
  esac
  { set +euvx; } 2>/dev/null
  unset utility
}
alias rmo='rm --others'

# sudo, even for aliases, but not functions
# https://github.com/mathiasbynens/dotfiles/commit/bb8de8b
alias sudo='sudo '

# mkdir && cd
take() {
  mkdir -p -v -- "$@" &&
    # https://github.com/ohmyzsh/ohmyzsh/commit/7cba6bb
    printf 'cd: changed directory to \342\200\230%s\342\200\231\n' "${@:$#}" &&
    cd -- "${@:$#}" || return 1
}

# Unix epoch seconds
# https://stackoverflow.com/a/12312982
# date -j '+%s' # for milliseconds
unixtime() {
  command date '+%s' "$@"
}

alias all='which -a'

# https://stackoverflow.com/a/1371283
# https://github.com/mathiasbynens/dotfiles/commit/cb8843b
# https://zsh.sourceforge.io/Doc/Release/Shell-Grammar.html#index-exec
alias ','='. -- "${HOME-}"/."${SHELL##*[-./]}"rc && exec -l -- "${SHELL##*[-./]}"'
aliases() {
  ${EDITOR:-vi} -- "${ZSH_CUSTOM:=${DOTFILES-}/custom}"/aliases."${SHELL##*[-./]}"
  . "${ZSH_CUSTOM-}"/aliases."${SHELL##*[-./]}"
}
alias ohmyzsh='cd -- "${ZSH-}" && command git status'
alias zshenv='${EDITOR:-vi} -- "${HOME-}/.${SHELL##*[-./]}env"; . -- "${HOME-}/.${SHELL##*[-./]}rc" && exec -l -- "${SHELL##*[-./]}"'
alias zshrc='${EDITOR:-vi} -- "${HOME-}/.${SHELL##*[-./]}rc"; . -- "${HOME-}/.${SHELL##*[-./]}rc" && exec -l -- "${SHELL##*[-./]}"'
alias zshconfig='zshrc'
