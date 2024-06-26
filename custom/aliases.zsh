#!/usr/bin/env sh
#                           │
#       ╭╮                  │
#       ││                  │
#    ╭──┤│╭┬──┬──┬──┬──╮    │
#    │╭╮││├┤╭╮│ ─┤│─┤ ─┤    │
#    │╭╮│╰┤│╭╮├─ ││─┼─ │    │
#    ╰╯╰┴─┴┴╯╰┴──┴──┴──╯    │
#          and functions    │
#                           │
#  curator: Lucas Larson    │
#                           │
# ──────────────────────────╯
#
# https://github.com/mathiasbynens/dotfiles/commit/cb8843b
alias ,='. "${HOME%/}"/."${SHELL##*[-./]}"rc && exec -l -- "${SHELL##*[-./]}"'
aliases() {
  command "${EDITOR:-vi}" -- "${DOTFILES-}/custom/aliases.${SHELL##*[-./]}" &&
    command -v -- shfmt >/dev/null 2>&1 &&
    command shfmt --simplify --write --indent 2 -- "${DOTFILES-}/custom/aliases.${SHELL##*[-./]}"
  # shellcheck disable=SC1090
  . "${DOTFILES-}/custom/aliases.${SHELL##*[-./]}"
}

bash_major_version() {
  # confirm Bash version is at least any given version (default: at least Bash 4)
  if test "$(command bash -c 'printf -- "%d" "${BASH_VERSINFO[0]}"')" -lt "${1:-4}"; then
    printf -- 'You will need to upgrade to version %d for full functionality.\n' "${1:-4}" >&2
    return 1
  fi
}
alias bash_version='bash_major_version'

bash_pretty() {
  # use this script to remove comments from shell scripts
  # and potentially find duplicate content

  for file in "$@"; do

    # if `bash --pretty-print` fails on the file, skip it
    if command bash --pretty-print -- "${file-}" 2>/dev/null; then
      # first Bash
      {
        # add the shell directive
        printf -- '#!/usr/bin/env bash\n'

        # add `bash --pretty-print` content
        command bash --pretty-print -- "${file-}"

        # save `$file`'s interpolated content into a file called `$file.bash`
      } >"${file-}"'.bash'

      # next nominally POSIX shell
      {
        # add the shell directive
        printf -- '#!/usr/bin/env sh\n'

        # add `bash --pretty-print --posix` content
        command bash --pretty-print --posix -- "${file-}"
      } >"${file-}"'.sh'
    fi
  done
  unset -v -- file
}

brewfile() {
  command brew bundle dump \
    --all \
    --cask \
    --describe \
    --file=- \
    --force \
    --formula \
    --mas \
    --tap \
    --verbose \
    --whalebrew \
    "$@" |
    # move each package name onto the comment line above it, if any
    command sed \
      -e '$!N' \
      -e '/^#.*\n[^#]/s/\n/\t/' \
      -e 'P' \
      -e 'D' |
    # swap the package and the comment
    command awk -F '\t' -- '{print $2 $1}' |
    # prepend each category with a number for sorting
    command sed \
      -e 's/^\(tap\)/1\1/' \
      -e 's/^\(brew\)/2\1/' \
      -e 's/^\(cask\)/3\1/' |
    LC_ALL='C' command sort -f | {
    printf -- '#!/usr/bin/env ruby\n'
    # remove the prepended numbers and then
    # restore each comment to a line above its package
    command sed \
      -e 's/^[[:digit:]]//' \
      -e 's/\([^#]*\)\(#.*\)/\2\n\1/'
  } >"${HOME%/}"'/.Brewfile'
}

# prefer `bat` without line numbers for easier copying
alias bat='command bat --decorations=never --paging=never'

alias 1='cd -- "${OLDPWD:--}"' -='cd -- "${OLDPWD:--}"'
alias 2='cd -- -2'
alias 3='cd -- -3'
alias 4='cd -- -4'
alias ...='cd -- ../..'
alias ....='cd -- ../../..'
alias .....='cd -- ../../../..'

cdp() {
  cd_to="$(command pwd -P)"
  if test "${PWD-}" != "${cd_to-}"; then
    printf -- 'moving from \342\200\230%s\342\200\231\n' "${PWD-}"
    cd -- "${cd_to-}" || {
      printf -- 'unable to perform this operation\n'
      return 1
    }
    printf -- '       into \342\200\230%s\342\200\231\n' "${cd_to-}"
  else
    printf -- 'already in unaliased directory '
    printf -- '\342\200\230%s\342\200\231\n' "${PWD-}"
    return 1
  fi
  unset -v -- cd_to
}

# cheat
cheat() {
  command curl --show-error --silent --url 'https://cheat.sh/'"$(
    printf -- '%s' "$*" | command sed -e 'y/ /+/'
  )"
}

alias chmod='chmod -v'

clang_format() {

  command clang-format --version 2>/dev/null ||
    return 2
  command sleep 1

  # permit arguments in any order
  # https://salsa.debian.org/debian/debianutils/blob/c2a1c435ef/savelog
  while getopts i:w: opt; do
    case "${opt-}" in
    i)
      IndentWidth="${OPTARG-}"
      ;;
    w)
      ColumnLimit="${OPTARG-}"
      ;;
    *)
      printf -- 'only \140-i <indent width>\140 and \140-w <number of columns>\140 are supported\n'
      return 1
      ;;
    esac
  done

  # permit `find` to have a narrower scope by parsing the rest of the arguments
  shift "$((OPTIND - 1))"

  command sleep 1
  printf -- 'applying clang-format to all applicable files in %s...\n' "${PWD##*/}"
  command sleep 1

  # eligible filename extensions:
  # https://github.com/llvm/llvm-project/blob/92df59c83d/clang/lib/Driver/Types.cpp#L295-L355
  # https://github.com/llvm/llvm-project/blob/81f0f5a0e5/clang/lib/Frontend/FrontendOptions.cpp#L17-L35
  # https://github.com/llvm/llvm-project/blob/e20a1e486e/clang/tools/clang-format-vs/ClangFormat/ClangFormatPackage.cs#L41-L42
  # https://github.com/llvm/llvm-project/blob/cea81e95b0/clang/tools/clang-format/git-clang-format#L78-L90
  # https://github.com/llvm/llvm-project/blob/cea81e95b0/clang/tools/clang-format/clang-format-diff.py#L50-L51

  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/t' -prune -o \
    -path '*/Test' -prune -o \
    -path '*/test' -prune -o \
    -path '*vscode' -prune -o \
    '(' \
    -name '*.adb' -o \
    -name '*.ads' -o \
    -name '*.asm' -o \
    -name '*.ast' -o \
    -name '*.bc' -o \
    -name '*.C' -o \
    -name '*.c' -o \
    -name '*.C++' -o \
    -name '*.c++' -o \
    -name '*.c++m' -o \
    -name '*.CC' -o \
    -name '*.cc' -o \
    -name '*.ccm' -o \
    -name '*.cl' -o \
    -name '*.clcpp' -o \
    -name '*.cp' -o \
    -name '*.CPP' -o \
    -name '*.cpp' -o \
    -name '*.cppm' -o \
    -name '*.cs' -o \
    -name '*.cu' -o \
    -name '*.cuh' -o \
    -name '*.cui' -o \
    -name '*.CXX' -o \
    -name '*.cxx' -o \
    -name '*.cxxm' -o \
    -name '*.F' -o \
    -name '*.f' -o \
    -name '*.F90' -o \
    -name '*.f90' -o \
    -name '*.F95' -o \
    -name '*.f95' -o \
    -name '*.FOR' -o \
    -name '*.for' -o \
    -name '*.FPP' -o \
    -name '*.fpp' -o \
    -name '*.gch' -o \
    -name '*.H' -o \
    -name '*.h' -o \
    -name '*.h++' -o \
    -name '*.hh' -o \
    -name '*.hip' -o \
    -name '*.hlsl' -o \
    -name '*.hp' -o \
    -name '*.hpp' -o \
    -name '*.hxx' -o \
    -name '*.i' -o \
    -name '*.ifs' -o \
    -name '*.ii' -o \
    -name '*.iih' -o \
    -name '*.iim' -o \
    -name '*.inc' -o \
    -name '*.inl' -o \
    -name '*.java' -o \
    -name '*.lib' -o \
    -name '*.ll' -o \
    -name '*.M' -o \
    -name '*.m' -o \
    -name '*.mi' -o \
    -name '*.mii' -o \
    -name '*.mm' -o \
    -name '*.pch' -o \
    -name '*.pcm' -o \
    -name '*.proto' -o \
    -name '*.protodevel' -o \
    -name '*.S' -o \
    -name '*.s' -o \
    -name '*.tcc' -o \
    -name '*.td' -o \
    -name '*.tlh' -o \
    -name '*.tli' -o \
    -name '*.tpp' -o \
    -name '*.ts' -o \
    -name '*.txx' -o \
    -name '*.xbm' \
    ')' \
    -type f \
    -exec sh -u -v -c "command git ls-files --error-unmatch -- '{}' >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command clang-format -i --style '{IndentWidth: ${IndentWidth:-2}, ColumnLimit: ${ColumnLimit:-79}}' --verbose -- '{}' 2>&1
" ';' |
    command sed -e 's/\[1\/1\]//'
  unset -v -- IndentWidth
  unset -v -- ColumnLimit
  printf -- '\n'
  printf -- '\342\234\205  done\041\n'
}

cleanup() {
  case "${1-}" in

  -v | --verbose)
    set -o verbose
    set -o xtrace
    shift
    ;;

  *)
    # refuse to run from `/`
    test "$(command pwd -P)" = '/' ||
      # or from `$HOME`
      test "$(command pwd -P)" = "${HOME%/}" ||
      # or from any titlecase-named directory just below `$HOME`
      # such the closed set of macOS standard directories:
      # `Applications`, `Desktop`, `Documents`, `Downloads`, `Library`, `Movies`, `Music`, `Pictures`, `Public`, and `Sites`
      # https://web.archive.org/web/0id_/developer.apple.com/library/mac/documentation/FileManagement/Conceptual/FileSystemProgrammingGUide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW9
      test "${PWD%/*}" = "${HOME%/}" &&
      case "$(command pwd -P | command sed -e 's/.*\/[[:space:]]*//')" in
      [A-Z])
        printf -- '\n\n'
        printf -- '\342\233\224\357\270\217 aborting: refusing to run from a macOS standard directory\n'
        printf -- '\n\n'
        return 77
        ;;
      *)
        # permit running from non-titlecase-named directories in `$HOME`
        ;;
      esac

    # delete thumbnail cache files
    # and hide `find: ‘./com...’: Operation not permitted` with `2>/dev/null`
    command find -- . \
      '(' \
      -name '.DS_Store' -o \
      -name 'Desktop.ini' -o \
      -name 'desktop.ini' -o \
      -name 'Thumbs.db' -o \
      -name 'thumbs.db' \
      ')' \
      -type f \
      -delete 2>/dev/null

    # delete crufty Zsh files
    # if `$ZSH_COMPDUMP` always generates a crufty file then skip
    # https://stackoverflow.com/a/8811800
    if test "${ZSH_COMPDUMP-}" != '' &&
      test ! "${ZSH_COMPDUMP-}" != "${ZSH_COMPDUMP#*'zcompdump-'}" &&
      test ! "${ZSH_COMPDUMP-}" != "${ZSH_COMPDUMP#*'zcompdump.'}"; then
      while test "$(
        command find -- "${HOME%/}" \
          -maxdepth 1 \
          ! -name "$(printf -- '*\n*')" \
          ! -name '.zcompdump' \
          -name '.zcompdump*' \
          -type f \
          -print
      )" != ''; do
        command find -- "${HOME%/}" \
          -maxdepth 1 \
          ! -name "$(printf -- '*\n*')" \
          ! -name '.zcompdump' \
          -name '.zcompdump*' \
          -type f \
          -delete 2>/dev/null
      done
    fi

    # delete empty files except
    # those with specific names and
    # those that belong to a repository
    command find -- . \
      -size 0 \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*/t' -prune -o \
      -path '*/Test*' -prune -o \
      -path '*/test*' -prune -o \
      -path '*vscode*' -prune -o \
      ! -name "$(printf -- 'Icon\015\012')" \
      ! -name '*.plugin.zsh' \
      ! -name '*empty*' \
      ! -name '*ignore' \
      ! -name '*journal' \
      ! -name '*lck' \
      ! -name '*LOCK' \
      ! -name '*lock' \
      ! -name '*lockfile' \
      ! -name '*rc' \
      ! -name '. ' \
      ! -name '.. ' \
      ! -name '.dirstamp' \
      ! -name '.do_not_remove' \
      ! -name '.gitkeep' \
      ! -name '.gitmodules' \
      ! -name '.hushlogin' \
      ! -name '.keep' \
      ! -name '.keepme' \
      ! -name '.nojekyll' \
      ! -name '.sudo_as_admin_successful' \
      ! -name '.watchmanconfig' \
      ! -name '__init__.py' \
      ! -name 'favicon.*' \
      -type f \
      -exec sh -v -c 'command git ls-files --error-unmatch -- "{}" >/dev/null 2>&1 ||
! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
command rm -- "{}"' ';'

    # delete empty directories recursively
    # but skip Git-specific and `/.well-known/` directories
    command find -- . \
      -depth \
      -links 2 \
      ! -path '*/.git/*' \
      ! -path '*/.well-known' \
      -type d \
      -delete 2>/dev/null

    # swap each tab for two spaces each in `.git/config` and `$HOME/.gitconfig`
    command find -- . \
      -path '*/.git/*' \
      -name 'config' \
      -type f \
      -exec sed -i -e 's/\t/  /g' {} ';'
    command sed -i -e 's/\t/  /g' "${HOME%/}"'/.gitconfig'

    # remove Git sample hooks
    command find -- . \
      -path '*/.git/*' \
      -path '*/hooks/*.sample' \
      -type f \
      -delete 2>/dev/null

    ;;
  esac
  {
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}

# copy
# -R recursive
alias cp='cp -R'

alias cpplint_r='command cpplint --counting=detailed --verbose=0 --filter=-legal/copyright --recursive -- .'

cy() {
  test "${DOTFILES-}" != '' &&
    test "${TEMPLATE-}" != '' ||
    return 1

  target="$(command git rev-parse --show-toplevel 2>/dev/null || command pwd -L)" ||
    return 1

  for file in \
    "${DOTFILES-}"'/.github' \
    "${TEMPLATE-}"'/.github' \
    "${TEMPLATE-}"'/.gitlab-ci.yml' \
    "${TEMPLATE-}"'/.imgbotconfig' \
    "${TEMPLATE-}"'/.whitesource' \
    "${TEMPLATE-}"'/citation.cff' \
    "${TEMPLATE-}"'/renovate.json'; do
    test -r "${file-}" &&
      # -R to copy recursively
      # -L to follow symbolic links
      command cp -R -L -- "${file-}" "${target-}"
  done
  unset -v -- file
  unset -v -- target
}

# number of files
# this directory and below
count_files() {
  # https://unix.stackexchange.com/a/1126
  command find -- .//. \
    -path '*/.git' -prune -o \
    ! -name '.' \
    ! -name '.DS_Store' \
    -type f \
    -print |
    command grep -c -e //
}

count_files_and_directories() {
  command find -- .//. \
    -path '*/.git' -prune -o \
    ! -name '.' \
    ! -name '.DS_Store' \
    -print |
    command grep -c -e //
}

count_files_by_extension() {
  # files with extensions
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    '(' \
    -type f -o \
    -type l \
    ')' \
    '(' \
    -name '.*' -o \
    -name '*.*' \
    ')' \
    -print 2>/dev/null |
    command sed -e 's/.*\.//' |
    LC_ALL='C' command sort |
    command uniq -c |
    LC_ALL='C' command sort

  # files with no extension
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    '(' \
    -type f -o \
    -type l \
    ')' \
    ! -name '*.*' \
    -print 2>/dev/null |
    LC_ALL='C' command sort -u |
    command uniq -c |
    LC_ALL='C' command awk -- '{print $1}' |
    command uniq -c |
    command sed -e 's/.$/[no extension]/'
}
alias cfx='count_files_by_extension'

# number of files
# in current directory
count_files_in_this_directory() {
  case "$@" in
  # count files as well as directories
  -d | --directory | --directories)
    command find -- . \
      -path './*/*' -prune -o \
      ! -name '.DS_Store' \
      -print |
      command grep -c -e /
    ;;

  # count only regular, non-directory files
  *)
    # https://unix.stackexchange.com/a/1126
    command find -- . \
      -path './*/*' -prune -o \
      ! -name '.DS_Store' \
      ! -type d \
      -print |
      command grep -c -e /
    ;;
  esac
}

# define
define() {
  for query in "${@:-"$0"}"; do

    # `hash` (POSIX)
    command -v -- hash >/dev/null 2>&1 &&
      printf -- 'hash return value:\n%d\n———\n' "$(
        hash "${query-}" >/dev/null 2>&1
        printf -- '%d\n' "$?"
      )"

    # `type` (System V; POSIX)
    command -v -- type >/dev/null 2>&1 &&
      printf -- 'type:\n%s\n———\n' "$(type "${query-}")"

    # `whence` (KornShell)
    command -v -- whence >/dev/null 2>&1 &&
      printf -- 'whence:\n%s\n———\n' "$(whence "${query-}")"

    # `where`
    command -v -- where >/dev/null 2>&1 &&
      printf -- 'where:\n%s\n———\n' "$(where "${query-}")"

    # `whereis`
    command -v -- whereis >/dev/null 2>&1 &&
      printf -- 'whereis:\n%s\n———\n' "$(whereis "${query-}")"

    # `command -V` (POSIX)
    printf -- 'command -V:\n%s\n———\n' "$(command -V -- "${query-}")"

    # `command -v` (POSIX)
    printf -- 'command -v:\n%s\n———\n' "$(command -v -- "${query-}")"

    # `which` (C shell)
    command -v -- which >/dev/null 2>&1 &&
      printf -- 'which -a:\n%s\n' "$(command which -a "${query-}")"

    # `functions | shfmt` (Zsh)
    if builtin functions -- "${query-}" 2>/dev/null | command shfmt --simplify --indent 2 >/dev/null 2>&1; then
      builtin functions -- "${query-}" | command shfmt --simplify --indent 2

    # `functions` (Zsh)
    elif builtin functions -- "${query-}" >/dev/null 2>&1; then
      builtin functions -x 2 -- "${query-}"
    fi
  done
  unset -v -- query
}
alias d='define'

alias diff='command git diff --color-words --no-index'

dictionary() {
  # sort as you’d expect to find in a dictionary
  LC_ALL='C' command sort -u "${1:---}" |
    LC_ALL='C' command sort -f
}

domain_name_from_url() {
  for url in "$@"; do
    # remove `user@` if any (ultra rare)
    url="${url##*@}"
    # remove `https://` or `http://`
    url="${url##*//}"
    # remove leading `www.`
    url="${url#*www.}"
    # remove ports like `:80`, `:443` (rare) and trailing slash and beyond
    url="${url%%[:/]*}"
    printf -- '%s' "${url-}" &&
      printf -- '\n'
  done
  unset -v -- url
}

du() {
  command dust "${@:--Fsx}" 2>/dev/null ||
    command -p -- du -h -s -- "${1:-.}"
}

epoch_seconds() {
  # return seconds since the epoch, 1969-12-31 19:00:00 EST
  # https://stackoverflow.com/a/41324810
  # `srand([expr])` will “Set the seed value for `rand` to `expr` or
  # use the time of day if `expr` is omitted.”
  # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/awk.html#tag_20_06_13_12
  command awk -- 'BEGIN {srand(); print srand()}'
}
epoch_to_date_time() {
  if command date -d '@0' >/dev/null 2>&1; then
    command date -d '@'"${1:-0}"
  else
    command date -r "${1:-0}"
  fi
}

filename_spaces_to_underscores() {
  command find -- . \
    -depth \
    -name '*'"${1:- }"'*' |
    while IFS='' read -r -- filename; do
      command mv -i -- "${filename-}" "${filename%/*}"/"$(
        printf -- '%s' "${filename##*/}" |
          command tr "${1:-[[:space:]]}" "${2:-_}"
      )"
    done
  unset -v -- filename
}

file_closes_with_newline() {
  test "$(command tail -c 1 -- "${1-}" | command wc -l)" -eq 0 &&
    return 1
}

command -v -- fd >/dev/null 2>&1 &&
  alias fd='command fd --hidden'

find_binary_files() {
  LC_ALL='C' command -p -- find -- . \
    -path '*/.git' -prune -o \
    -exec file -- {} + |
    command -p -- sed \
      -e '/:.*directory/ d' \
      -e '/:.*empty/ d' \
      -e '/:.*JSON/ d' \
      -e '/:.*text/ d' \
      -e '/:.*very long lines/ d' \
      -e '# finally, remove file utility descriptions' \
      -e 's/:.*//'
}

# find broken symlinks
find_broken_symlinks() {
  command find -- . \
    -type l \
    -exec test ! -e {} ';' \
    -print 2>/dev/null
}

# find duplicate files
find_duplicate_files() {
  # https://linuxjournal.com/content/boost-productivity-bash-tips-and-tricks
  command find -- . \
    ! -size 0 \
    ! -type l \
    -type f \
    -print 2>/dev/null |
    LC_ALL='C' command sort -n -r |
    command uniq -d |
    command xargs -I '{}' -n 1 find \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*/t' -prune -o \
      -path '*/Test*' -prune -o \
      -path '*/test*' -prune -o \
      -path '*vscode*' -prune -o \
      ! -type l \
      -type f \
      -size {}c \
      -print 2>/dev/null |
    command sed \
      -e '# https://web.archive.org/web/0id_/etalabs.net/sh_tricks.html#:~:text=Using%20find%20with%20xargs' \
      -e 's/./\\&/g' |
    command xargs sha1sum 2>/dev/null |
    LC_ALL='C' command sort |
    command uniq -w 32 --all-repeated=separate
}
alias fdf='find_duplicate_files'

find_executable() {
  # POSIX emulatation of GNU `find -executable`
  # printing the names of all files – including directories – whose permissions meet or exceed 700
  command find -- . \
    -perm -700 \
    -print
}

find_files_with_no_extension() {
  command find -- . \
    -path '*/.git' -prune -o \
    ! -name '*.*' \
    -type f \
    -print 2>/dev/null |
    LC_ALL='C' command sort -u
}

find_files_with_the_same_names() {
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -mindepth 1 \
    -type f \
    -print0 |
    command awk -F '/' -- 'BEGIN {RS="\0"} {n=$NF} k[n]==1 {print p[n]} k[n] {print $0} {p[n]=$0; k[n]++}' |
    while IFS='' read -r -- file; do
      printf -- '%s\n' "${file##*/}"
    done |
    LC_ALL='C' command sort -u
}

compdef -- 'find_no_git'='find' 2>/dev/null
find_no_git() {
  command find -- . \
    -path '*/.git' -prune -o \
    -mindepth 1 \
    "$@"
}

find_oldest_file() {
  command find -- . \
    -path '*/.git' -prune -o \
    -type f \
    -exec /bin/ls -o -r -t -- {} + 2>/dev/null |
    command sed -e "${1:-1}"'q'
}

find_shell_scripts() {
  cd -- "$(command git rev-parse --show-toplevel)" ||
    return 1

  {
    # all files with extensions `.bash`, `.dash`, `.ksh`, `.mksh`, `.sh`, `.zsh`
    command find -- . \
      -path '*/.git' -prune -o \
      '(' \
      -name '*.bash' -o \
      -name '*.dash' -o \
      -name '*.ksh' -o \
      -name '*.mksh' -o \
      -name '*.sh' -o \
      -name '*.zsh' \
      ')' \
      -type f \
      -print 2>/dev/null

    # files whose first line resembles those of shell scripts
    # https://stackoverflow.com/a/9612232
    command find -- . \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*/t' -prune -o \
      -path '*/Test*' -prune -o \
      -path '*/test*' -prune -o \
      -path '*vscode*' -prune -o \
      -type f \
      -exec sh -c 'command sed -e "1q" -- "{}" | command grep -l -e "^#\!.*bin.*sh" -- "{}" 2>/dev/null | command sed -e "s/^/.\//"' ';'

    # shfmt also knows how to find shell scripts
    command shfmt --find -- . 2>/dev/null |
      command awk -- '{print "./" $0}'

    # https://github.com/bzz/LangID/blob/37c4960/README.md#collect-the-data
    command github-linguist --breakdown --json -- . 2>/dev/null |

      # https://web.archive.org/web/20210904183309id_/earthly.dev/blog/jq-select/#cb22
      # https://github.com/stedolan/jq/issues/1735#issuecomment-427863218
      command jq --raw-output '.Shell.files[]' 2>/dev/null |

      # prepend filenames with `./`
      command awk -- '{print "./" $0}'

  } |
    LC_ALL='C' command sort -u
}

# Git
unalias -- 'g' 2>/dev/null
compdef g='git' 2>/dev/null
g() {
  case "${1-}" in
  clone | config | help | init | version | -*)
    command git "$@"
    ;;
  *)
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
      return "${?:-1}"
    # if first argument is a file, then perform `git status` on it
    if test -e "${1-}"; then
      command git status -- "$@"
    else
      command git "${@:-status}"
    fi
    ;;
  esac
}
alias g.='command git -c color.status=always -c core.quotePath=false status .'
alias gs='command git -c color.status=always -c core.quotePath=false status --short --untracked-files=no'
guo() {
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command sed -e '$d'
}

# git add
git_add() {
  case "${1-}" in
  -p | --patch)
    shift
    command git add --verbose --patch "${@:-.}"
    ;;
  -A | --all)
    command git add --verbose "$@" &&
      shift
    ;;
  -D | --deleted)
    # https://gist.github.com/8775224
    command git ls-files -z --deleted |
      command sed \
        -e '# https://web.archive.org/web/0id_/etalabs.net/sh_tricks.html#:~:text=Using%20find%20with%20xargs' \
        -e 's/./\\&/g' |
      command xargs git add --verbose 2>/dev/null &&
      shift
    ;;
  -m | --modified)
    command git add --update --verbose -- .
    shift
    ;;
  -o | --others | --untracked)
    while test "$(command git ls-files --others --exclude-standard)" != ''; do
      command git ls-files -z --others --exclude-standard |
        command sed \
          -e '# https://web.archive.org/web/0id_/etalabs.net/sh_tricks.html#:~:text=Using%20find%20with%20xargs' \
          -e 's/./\\&/g' |
        command xargs git add --verbose 2>/dev/null
    done &&
      shift
    ;;
  *)
    # default to everything in the current directory and below
    command git add --verbose "${@:-.}"
    ;;
  esac &&
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command sed -e '$d'
}
alias ga='git_add'
alias gaa='git_add --all'
alias gap='git_add --patch'
alias git_add_deleted='git_add --deleted'
alias git_add_others='git_add --others'
alias git_add_patch='git_add --patch'
alias git_add_untracked='git_add --others'

git_all_files_ever() {
  # list all files that ever existed in the repository
  # inspiration: https://gist.github.com/8775224
  case "${1-}" in
  -D | --deleted)
    # list only files that have been deleted
    command git log --pretty= --name-only --all --diff-filter=D |
      LC_ALL='C' command sort -u |
      command awk -- '{print "./" $0}'
    ;;
  *)
    # list all files ever
    command git log --pretty= --name-only --all |
      LC_ALL='C' command sort -u |
      command awk -- '{print "./" $0}'
    ;;
  esac
}

alias gba='command git branch --all'
alias gbd='command git branch --delete'
alias gbD='command git branch --delete --force'

alias gco='command git checkout --progress'

# `git checkout` the default branch
alias gcom='command git checkout --progress "$(git-default-branch)"'

# git cherry-pick
alias gcp='command git cherry-pick'
alias gcpa='command git cherry-pick --abort'
alias gcpc='command git cherry-pick --continue'
alias gcpn='command git cherry-pick --no-commit'

# git clone
git_clone() {
  case "${1-}" in
  -h | --help)
    printf -- 'Usage: %s <git_url> [<dir_name>]\n' "${0##*/}" >&2
    ;;
  -1 | --shallow)
    shift
    command mkdir "${2:-$(command basename -- "$1" .git || return 123)}" >/dev/null 2>&1
    cd -- "${2:-$(command basename -- "$1" .git || return 122)}" >/dev/null 2>&1 || return 5
    command git clone --verbose --progress --depth 1 --shallow-submodules "$1" . || return 6
    ;;
  *)
    command mkdir "${2:-$(command basename -- "$1" .git || return 126)}" >/dev/null 2>&1
    cd -- "${2:-$(command basename -- "$1" .git || return 125)}" >/dev/null 2>&1 || return 3
    command git clone --verbose --progress --recursive -- "$1" . || return 4
    ;;
  esac
}
alias gcl='git_clone'
alias gcl1='git_clone -1'

# git commit
git_commit() {
  case "${1-}" in
  --amend | '')
    command git commit --signoff --verbose "$@" ||
      return 1
    ;;
  *)
    command git commit --signoff --verbose -m "$@" ||
      return 1
    ;;
  esac
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command sed -e '$d'
}
alias gc='git_commit'
alias gca='git_commit --amend'

git_config_file_locations() {
  for scope in global system local worktree; do
    # do not return `.git/config` if called from outside a git repository
    test "$(command git config --list --show-scope --"${scope-}" 2>/dev/null)" = '' ||
      printf -- '%-10s%s\n' "${scope-}" "$(
        command git config --list --show-origin --"${scope-}" |
          command sed \
            -e 's|file:||' \
            -e 's|\t.*||' \
            -e 's|^\.|./.|' \
            -e 's|'"${HOME%/}"'|~|' |
          LC_ALL='C' command sort -u
      )"
  done
  unset -v -- scope
}

unalias -- 'gd' 2>/dev/null
gd() {
  if test "$(command git diff "$@" 2>/dev/null)" != ''; then
    command git diff "$@"
  else
    command git diff --cached "$@"
  fi
}
unalias -- 'gds' 2>/dev/null
gds() {
  if test "$(command git diff --cached "$@" 2>/dev/null)" != ''; then
    command git diff --cached "$@"
  else
    command git diff "$@"
  fi
}

alias gdm='command git diff "$(git-default-branch)" --'
gdom() {
  command git diff origin/"$(git-default-branch)" ||
    command git diff upstream/"$(git-default-branch)"
}

alias gf='git fetch --keep --multiple --progress --prune --verbose'
gfgs() {
  command git fetch --all --prune --verbose &&
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command sed -e '$d'
}

# git parents, git child
git_find_child() {
  # return the commit hash that occurred after the given one (default current)
  # usage: git_find_child [<commit>]
  command git rev-list --ancestry-path "${1:-HEAD}".."$(git default-branch)" |
    command tail -n 1
}
git_find_parent() {
  # return the hash prior to the current commit
  # if an argument is provided, return the commit prior to that commit
  # usage: git_find_parent [<commit>]
  command git rev-list --max-count=1 "${1:-"$(command git rev-parse HEAD)"}^" --
}
git_find_parents() {
  # return all hashes prior to the current commit
  # if an argument is provided, return all commits prior to that commit
  # usage: git_find_parents [<commit>]
  command git rev-list "${1:-"$(command git rev-parse HEAD)"}^" --
}
alias git_parent='git_find_parent'
alias gfp='git_find_parent'
alias gfc='git_find_child'
alias git_parents='git_find_parents'

git_garbage_collection() {
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    command -v -- cleanup >/dev/null 2>&1 &&
      cleanup "$@"
    # see `git gc` and other wrapping commands behind-the-scene mechanics
    # https://github.com/git/git/blob/49eb8d3/contrib/examples/README#L14-L16
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git fetch --prune --prune-tags --verbose
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git prune --verbose --progress --expire now
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git prune-packed
    command git maintenance start >/dev/null 2>&1 &&
      GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git maintenance start
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git gc --aggressive --prune=now
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git repack -a -d -f -F --window=4095 --depth=4095
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
      command sed -e '$d'
  else
    return 1
  fi
}
alias ggc='git_garbage_collection'

# find initial commit
git_find_initial_commit() {
  command git rev-list --max-parents=0 HEAD --
}
alias gic='git_find_initial_commit'

# commit initial commit
git_commit_initial_commit() {
  # usage: git_commit_initial_commit [yyyy-mm-dd]
  # create initial commits: one empty root, then the rest
  # https://news.ycombinator.com/item?id=25515963
  command git init &&
    if test "$#" -eq 1; then
      # add 12 hours (43,200 seconds) so it occurs around midday
      git_time="$(command date -d '@'"$(($(command date -d "${1:-$(command date -- '+%Y-%m-%d')}" -- '+%s') + 12 * 60 * 60))" -- '+%c %z')"
      export GIT_AUTHOR_DATE="${git_time-}"
      export GIT_COMMITTER_DATE="${git_time-}"
    fi
  command git commit --allow-empty --signoff --verbose --message="$(printf -- '\360\237\214\263\302\240 root commit')"
  # if there are non-repository files present, then add them and commit
  if test "$(command git ls-files --others --exclude-standard)" != ''; then
    command git add --verbose -- . &&
      command git commit --signoff --verbose --message="$(printf -- '\342\234\250\302\240 initial commit')"
  fi
  unset -v -- git_time
  unset -v -- GIT_AUTHOR_DATE
  unset -v -- GIT_COMMITTER_DATE
}
alias gcic='git_commit_initial_commit'
alias ginit='command git init && command git status'

# git log
# https://github.com/gggritso/gggritso.com/blob/a07b620/_posts/2015-08-23-human-git-aliases.md#readme
alias glog='command git log --graph --branches --remotes --tags --format=format:"%Cgreen%h %Creset• %<(75,trunc)%s (%cN, %cr) %Cred%d" --date-order'

# git merge
unalias -- 'gm' 2>/dev/null
gm() {
  # https://news.ycombinator.com/item?id=5512864
  command git merge --log --overwrite-ignore --progress --rerere-autoupdate --strategy-option patience
}
alias gma='command git merge --abort'
gmc() {
  command git merge --log --continue
}

# git merge with default branch
gmm() {
  command git merge --log --verbose --progress --rerere-autoupdate --strategy-option patience "$(git-default-branch)"
}

# git move
git_move() {
  {
    command git mv --verbose --force "$@" ||
      command mv -i "$@" ||
      return 1
  } &&
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command sed -e '$d'
}
alias gmv='git_move'

command -v -- git-open >/dev/null 2>&1 &&
  alias gopen='command git open 2>/dev/null'

# git pull
git_pull() {
  # https://github.com/ohmyzsh/ohmyzsh/commit/3d2542f
  command git pull --all --rebase --autostash --prune --verbose "$@" || {
    command git rebase --abort
    command git rebase --strategy-option=theirs
  }
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command sed -e '$d'
}
alias gp='git_pull'

gdr() {
  {
    command git config --get --worktree checkout.defaultRemote ||
      command git config --get --local checkout.defaultRemote ||
      command git config --get --system checkout.defaultRemote ||
      command git config --get --global checkout.defaultRemote ||
      command git config --get branch."$(command git symbolic-ref --quiet --short HEAD -- 2>/dev/null)".remote
  } 2>/dev/null ||
    printf -- 'origin\n'
}
alias git-default-remote='gdr'
alias git-default-origin='gdr'

# git push
git_push() {
  command git push --verbose --progress origin "$(command git symbolic-ref --quiet --short HEAD -- 2>/dev/null)" &&
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command sed -e '$d'
}
alias gps='git_push'

alias grba='command git rebase --abort'
alias grbi='command git rebase --interactive'
alias grbc='command git rebase --continue'
alias gref='command git reflog'

alias grmr='command git rm -r'
alias grm='grmr'

git_remote_verbose() {
  # print `git remote -v` into columns
  command git remote --verbose |
    command awk -- '{printf "%-16s %s\n", $1, $2}' |
    command uniq
}
alias grv='git_remote_verbose'

git_restore() {
  for file in "$@"; do
    command git checkout --progress -- "${file-}"
  done &&
    command git status
  unset -v -- file
}
alias grs='git_restore'

git_search() {
  # search all repository content since its creation
  command git rev-list --all |
    while IFS='' read -r -- commit; do
      command git grep --color=always --extended-regexp --ignore-case --line-number -e "$@" "${commit-}" --
    done
  unset -v -- commit
}
alias gsearch='git_search'

git_shallow() {
  # Shallow .gitmodules submodule installations
  # Mauricio Scheffer https://stackoverflow.com/a/2169914
  command git submodule init
  command git submodule |
    command awk -- '{print $2}' |
    while IFS='' read -r -- submodule; do
      command git clone --depth 1 --shallow-submodules -- \
        "$(command git config --file .gitmodules --get submodule."${submodule-}".url)" \
        "$(command git config --file .gitmodules --get submodule."${submodule-}".path)"
    done
  command git submodule update
  unset -v -- submodule
  unset -v -- submodule_path
  unset -v -- submodule_url
}

alias gsh='command git show'

git_stash_save_all() {
  # https://github.com/ohmyzsh/ohmyzsh/commit/69ba6e4359
  command git stash push -m "$@" 2>/dev/null ||
    command git stash push
}
alias gstall='git_stash_save_all'
alias gstc='command git stash clear'

git_submodule_update() {
  command git submodule update --init --remote "$@" &&
    command git submodule sync "$@" &&
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command sed -e '$d'
}
alias gsu='git_submodule_update'
alias gtake='git checkout -b'

git_undo() {
  command git reset HEAD@'{'"${1:-1}"'}'
}
alias gundo='git_undo'

git_update() {
  # run only from within a Git repository
  # https://stackoverflow.com/a/53809163
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then

    command -v -- cleanup >/dev/null 2>&1 &&
      cleanup "$@"

    command git fetch --all --prune --verbose

    # `git submodule update` with `--remote` appears to slow Git to a crawl
    # https://docs.google.com/spreadsheets/d/14W8w71DK0YpsePbgtDkyFFpFY1NVrCmVMaw06QY64eU
    case "${1-}" in
    -r | --remote)
      command git submodule update --init --recursive --remote "$@"
      ;;
    *)
      command git submodule update --init --recursive "$@"
      ;;
    esac
    command git submodule sync --recursive "$@"
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
      command sed -e '$d'
  fi
}
alias gu='git_update'

# https://github.com/tarunsk/dotfiles/blob/5b31fd6/.always_forget.txt#L1957
gvc() {
  # if there is an argument (commit hash), use it
  # otherwise check `HEAD`
  command git verify-commit "${1:-HEAD}"
}

command -v -- gh >/dev/null 2>&1 &&
  alias ghs='command gh status'

gitlab_create_repository() {
  command git push --set-upstream git@gitlab.com:"${GITLAB_USERNAME:-${LOGNAME:-${USER-}}}"/"$(
    command git rev-parse --show-toplevel |
      command xargs basename --
  )".git "$(
    command git rev-parse --abbrev-ref HEAD
  )"
}

gravatar() {
  # return the URL of a Gravatar image for the given email address
  command printf -- 'https://gravatar.com/avatar/%.32s?s=%d\n' "$(
    command printf -- %s "${1:-$(command git config --get user.email)}" |
      LC_ALL='C' command tr -d '[:space:]' |
      LC_ALL='C' command tr '[:upper:]' '[:lower:]' |
      {
        command md5sum ||
          command md5
      } 2>/dev/null
  )" "${2:-9999}"
}

hash_abbreviate() {
  # abbreviate commit hash and copy to clipboard
  # usage: hash_abbreviate [-l <length>] <hash> [<hash> ...]
  while getopts l: opt; do
    case "${opt-}" in
    l)
      length="${OPTARG-}"
      ;;
    *)
      printf -- 'usage: %s [-l <length>] <hash> [<hash> ...]\n' "${0##*/}" >&2
      ;;
    esac
  done
  shift "$((OPTIND - 1))"
  for hash in "$@"; do
    if printf -- '%s' "${hash-}" | command grep -E -w -e '^[[:xdigit:]]{4,40}$' >/dev/null 2>&1; then
      printf -- '%s\n' "${hash-}" | command cut -c 1-"${length:-"$(command git config --get core.abbrev 2>/dev/null || printf -- '7')"}"
      # prevent copying trailing newline with `tr` and
      # hide clipboard errors because `pbcopy` is not common
      printf -- '%s' "${hash-}" | command cut -c 1-"${length:-"$(command git config --get core.abbrev 2>/dev/null || printf -- '7')"}" | command tr -d '[:space:]' | command pbcopy 2>/dev/null
    else
      return 1
    fi
  done
  unset -v -- hash
  unset -v -- length
}
alias h7='hash_abbreviate'

hashlookup() {
  test -f "${1-}" ||
    return 66
  command curl \
    --show-error \
    --silent \
    --header 'accept: application/json' \
    --url 'https://hashlookup.circl.lu/lookup/sha256/'"$(
      command sha256sum -- "${1-}" |
        command awk -- '{print $1}'
    )" |
    command jq --raw-output '.parents[]' 2>/dev/null
}

h1() {
  for file in "$@"; do
    command sed -e '1q' "${file-}"
  done
  unset -v -- file
}

history_stats() {
  fc -l 1 |
    command awk -- '{CMD[$2]++; count++;}; END {for (a in CMD) print CMD[a] " " CMD[a] * 100 / count "% " a;}' |
    command grep -v -e './' |
    LC_ALL='C' command sort -n -r |
    command sed -e "${1:-"$((LINES - 5))"}"'q' |
    command column -c 3 -s ' ' -t |
    command nl
}
alias zsh_stats='history_stats'

identify() {
  # identify the current machine
  command uname -m
  command uname -n
  command uname -r
  command uname -s
  command uname -v
  {
    command sw_vers
    command lsb_release --all
    command hostnamectl
    command cat -- /etc/os-release ||
      command cat -- /usr/lib/os-release
    command cat -- /proc/version
    command cat -- /etc/issue
  } 2>/dev/null
}

jsonlint_r() {
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/Library' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/t' -prune -o \
    -path '*/Test*' -prune -o \
    -path '*/test*' -prune -o \
    -path '*/tst*' -prune -o \
    -path '*copilot*' -prune -o \
    -path '*dummy*' -prune -o \
    -path '*vscode*' -prune -o \
    '(' \
    -name '*.json' -o \
    -name '*.4DForm' -o \
    -name '*.4DProject' -o \
    -name '*.avsc' -o \
    -name '*.babelrc*' -o \
    -name '*.cjs.map' -o \
    -name '*.code-workspace' -o \
    -name '*.css.map' -o \
    -name '*.cy' -o \
    -name '*.geojson' -o \
    -name '*.gltf' -o \
    -name '*.har' -o \
    -name '*.ice' -o \
    -name '*.js.map' -o \
    -name '*.JSON' -o \
    -name '*.JSON-tmLanguage' -o \
    -name '*.JSON5' -o \
    -name '*.json5' -o \
    -name '*.jsonl' -o \
    -name '*.jsonld' -o \
    -name '*.maxhelp' -o \
    -name '*.maxpat' -o \
    -name '*.maxproj' -o \
    -name '*.mcmeta' -o \
    -name '*.mxt' -o \
    -name '*.nmf' -o \
    -name '*.rcprojectdata' -o \
    -name '*.sarif' -o \
    -name '*.stats' -o \
    -name '*.stringsdata' -o \
    -name '*.sublime-build' -o \
    -name '*.sublime-color-scheme' -o \
    -name '*.sublime-commands' -o \
    -name '*.sublime-completions' -o \
    -name '*.sublime-keymap' -o \
    -name '*.sublime-macro' -o \
    -name '*.sublime-menu' -o \
    -name '*.sublime-mousemap' -o \
    -name '*.sublime-project' -o \
    -name '*.sublime-settings' -o \
    -name '*.tern-project' -o \
    -name '*.tfstate' -o \
    -name '*.tfstate.backup' -o \
    -name '*.topojson' -o \
    -name '*.ts.map' -o \
    -name '*.tsbuildinfo' -o \
    -name '*.webapp' -o \
    -name '*.webmanifest' -o \
    -name '*.XamlStyler' -o \
    -name '*.xamlstyler' -o \
    -name '*.xcscmblueprint' -o \
    -name '*.xctestplan' -o \
    -name '*.ytdl' -o \
    -name '*.yy' -o \
    -name '*.yyp' -o \
    -name '*app-site-association' -o \
    -name '.all-contributorsrc' -o \
    -name '.arcconfig' -o \
    -name '.auto-changelog' -o \
    -name '.bowerrc' -o \
    -name '.c8rc' -o \
    -name '.cardinalrc' -o \
    -name '.couchapprc' -o \
    -name '.dccache' -o \
    -name '.dockercfg' -o \
    -name '.eslintcache' -o \
    -name '.eslintrc' -o \
    -name '.flutter' -o \
    -name '.flutter_tool_state' -o \
    -name '.ftpconfig' -o \
    -name '.gutter-theme' -o \
    -name '.htmlhintrc' -o \
    -name '.imgbotconfig' -o \
    -name '.jrnl_config' -o \
    -name '.jscsrc' -o \
    -name '.jshintrc' -o \
    -name '.nycrc' -o \
    -name '.prettierrc' -o \
    -name '.remarkrc' -o \
    -name '.stylelintrc' -o \
    -name '.tern-config' -o \
    -name '.tern-project' -o \
    -name '.textlintrc' -o \
    -name '.vs-liveshare-keychain' -o \
    -name '.vsconfig' -o \
    -name '.watchmanconfig' -o \
    -name '.whitesource' -o \
    -name '.yarn-integrity' -o \
    -name 'composer.lock' -o \
    -name 'deno.lock' -o \
    -name 'eslintrc' -o \
    -name 'flake.lock' -o \
    -name 'mcmod.info' -o \
    -name 'Package.resolved' -o \
    -name 'Pipfile.lock' -o \
    -name 'proselintrc' -o \
    -name 'tldrrc' \
    ')' \
    -type f \
    -exec sh -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command npm exec -- @prantlf/jsonlint --in-place --trailing-newline --trim-trailing-commas -- "${1-}"
' _ {} ';'
}

# list files
unalias -- 'ls' 2>/dev/null
unalias -- 'l' 2>/dev/null
if command eza --color=auto >/dev/null 2>&1; then
  alias ls='command eza --color=auto'
  alias l='command eza --color=auto --bytes --classify --git --header --icons --long --no-permissions --no-user --octal-permissions --time-style=long-iso'
elif command gls --color=auto >/dev/null 2>&1; then
  alias ls='command gls --color=auto'
  alias l='command gls --color=auto -AFgo --time-style=+%4Y-%m-%d\ %l:%M:%S\ %P'
elif command ls --color=auto >/dev/null 2>&1; then
  alias ls='command ls --color=auto'
  alias l='command ls --color=auto -AFgo --time-style=+%4Y-%m-%d\ %l:%M:%S\ %P'
elif test "$(command /bin/ls -G -- "${HOME%/}" | command od)" = "$(command ls -G -- "${HOME%/}" | command od)" &&
  test "$(command ls -G -- "${HOME%/}" | command od)" != "$(command ls --color=auto -- "${HOME%/}" 2>/dev/null)"; then
  alias ls='command ls -G'
  alias l='command ls -A -F -G -g -o'
fi

# list --others
lso() {
  command git ls-files --others --exclude-standard "$@" |
    command awk -- '{print "./" $0}'
}

# dotfiles
mu() {
  cd -- "${DOTFILES-}" ||
    return 1
  command -v -- cleanup >/dev/null 2>&1 &&
    cleanup "$@"
  case "${1-}" in
  -s | --short)
    command mackup backup --force --root
    command git fetch --all --prune
    command git submodule update --init
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
      command sed -e '$d'
    ;;
  *)
    command mackup backup --force --root --verbose
    command git fetch --all --prune --verbose
    command git submodule update --init --recursive
    command git submodule sync --recursive
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
      command sed -e '$d'
    ;;
  esac
}

## find `-maxdepth` and `-mindepth`
# generate a POSIX-compliant equivalent
maxdepth() {
  # instead of `find . -maxdepth 2 -print`, use `find . -path './*/*/*' -prune -o -print`
  path_argument='./*'
  depth="${1:-0}"
  while command -p -- test "${depth-}" -gt 0; do
    path_argument="${path_argument-}"'/*' &&
      depth="$((depth - 1))"
  done
  command -p -- printf -- '#!/usr/bin/env sh\ncommand -p -- find -- . -path \047%s\047 -prune -o -print\n' "${path_argument-}"
  unset -v -- path_argument 2>/dev/null || path_argument=''
  unset -v -- depth 2>/dev/null || depth=''
}
mindepth() {
  # instead of `find . -mindepth 2 -print`, use `find . -path './*/*' -print`
  path_argument='.'
  depth="${1:-0}"
  while command -p -- test "${depth-}" -gt 0; do
    path_argument="${path_argument-}"'/*' &&
      depth="$((depth - 1))"
  done
  command -p -- printf -- '#!/usr/bin/env sh\ncommand -p -- find -- . -path \047%s\047 -print\n' "${path_argument-}"
  unset -v -- path_argument 2>/dev/null || path_argument=''
  unset -v -- depth 2>/dev/null || depth=''
}

# https://unix.stackexchange.com/a/30950
alias mv='command mv -v -i'

# find files with non-ASCII characters
non_ascii() {
  LC_ALL='C' command find -- . \
    -path '*/.git' -prune -o \
    -name '*[! -~]*'
}

odb() {
  # odb: convert hexadecimal escapes to octal escapes
  # usage: `odb <string>` or `echo <string> | odb`
  # test for standard input or if not, then use arguments
  { { command test "${#}" -eq 0 && command cat -- -; } || command printf -- '%s' "${*-}"; } |
    # `-A n` hide the address base
    # `-t o1` convert to octal
    command od \
      -A n \
      -t o1 |
    command sed \
      -n \
      -e '# move the results onto one line' \
      -e 'H' \
      -e '$ {' \
      -e 'x' \
      -e '# remove trailing final spaces, tabs, and newlines' \
      -e 's/[[:space:]]*$//' \
      -e '# replace all remaining strings of spaces, tabs, or newlines with a single backslash "\"' \
      -e 's/[[:space:]][[:space:]]*/\\/gp' \
      -e '}'
}

command -v -- ocrmypdf >/dev/null 2>&1 &&
  ocr() {
    for file in "$@"; do
      test "${file-}" = "${file%.pdf}" &&
        return "${?:-1}"
      command ocrmypdf \
        --deskew \
        --language eng \
        --optimize 0 \
        --pdfa-image-compression lossless \
        --rotate-pages \
        --skip-text \
        -- \
        "${file-}" "${file-}".ocr.pdf
    done
    unset -v -- file
  }

# open current directory if no argument is given
open() {
  if test "$#" -eq 0; then
    command open -- .
  else
    case "${1-}" in
    p | posix_utilities)
      { command test "${2-}" != '' &&
        command open -- 'https://pubs.opengroup.org/onlinepubs/9699919799/utilities/'"${2-}"'.html'; } ||
        command open -- 'https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html'
      ;;
    b | pb | posix_builtins)
      { command test "${2-}" != '' &&
        command open -- 'https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#'"${2-}"; } ||
        command open -- 'https://pubs.opengroup.org/onlinepubs/9699919799/idx/sbi.html'
      ;;
    sc*)
      command open -- 'https://shellcheck.net/wiki/SC'"${1#sc}"
      ;;
    SC*)
      command open -- 'https://shellcheck.net/wiki/'"${1-}"
      ;;
    so*)
      # like cheat.sh’s `so/q/33041363`
      command open -- 'https://stackoverflow.com/'"${1#so/}"
      ;;
    *)
      command open "$@"
      ;;
    esac
  fi
}
# if there is no `xdg-open`, then alias it to `open`
command -v -- xdg-open >/dev/null 2>&1 ||
  alias xdg-open='open'

path_check() {
  # check that each directory in user `$PATH` still exists and is a directory

  for argument in "$@"; do
    case "${argument-}" in

    # return verbose output if requested
    -v | --verbose)
      set -o xtrace
      shift
      ;;

    *)
      printf -- 'usage: %s [-v|--verbose]\n' "${0##*/}" >&2
      return 1
      ;;
    esac
  done

  printf -- '%s\n' "${PATH-}" |
    command sed -e 'y/:/\n/' |
    while IFS='' read -r -- directory; do
      if test -d "${directory-}"; then
        printf -- 'is a directory: %s\n' "${directory-}"
      else
        printf -- 'not a directory: %s\n' "${directory-}"
      fi
    done
  unset -v -- argument
  unset -v -- directory
  {
    set +o xtrace
  } 2>/dev/null
}

permissions() {
  # restore default file and directory permissions
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    return "${?:-1}"
  command find -- . -path '*/.*' -prune -o -type d -exec /bin/chmod -- 755 {} +
  command find -- . -path '*/.*' -prune -o -type f -exec /bin/chmod -- 644 {} +
}

# pip
command -v -- pip3 >/dev/null 2>&1 &&
  alias pip='command pip3'

# .plist
plist_r() {
  command -v -- plutil >/dev/null 2>&1 ||
    return 127
  case "$(command pwd -P)" in
  "${HOME%/}" | "${DOTFILES-}"/* | */trash)
    printf -- 'permission error\n' >&2
    printf -- 'do not run command \140%s\140 ' "${0##*/}" >&2
    printf -- 'from directory \140%s/\140\n' "${PWD##*/}" >&2
    return 77
    ;;
  *)
    command find -- . \
      -path '*/Library' -prune -o \
      '(' \
      -name '*.plist' -o \
      -name '*.caar' -o \
      -name '*.entitlements' -o \
      -name '*.fileloc' -o \
      -name '*.glyphs' -o \
      -name '*.loctable' -o \
      -name '*.mobileconfig' -o \
      -name '*.mom' -o \
      -name '*.scriptSuite' -o \
      -name '*.stringsdict' -o \
      -name '*.textClipping' -o \
      -name '*.waveform' -o \
      -name '*.webloc' \
      ')' \
      -type f \
      -print \
      -exec plutil -convert xml1 -- {} ';' \
      -exec sed -i -e 's/\t/  /g' {} ';' \
      -exec sed -E -i -e 's/^(  |<\/?dict)/  &/' {} ';'
    ;;
  esac
}

# PlistBuddy
test -x '/usr/libexec/PlistBuddy' &&
  # https://apple.stackexchange.com/a/414774
  alias plistbuddy='command /usr/libexec/PlistBuddy'

# Python
command -v -- python3 >/dev/null 2>&1 &&
  alias python='command python3'

# $?
question_mark() {
  printf -- '%d\n' "$?"
}
alias '?'='question_mark'

# QuickLook
ql() {
  command -v -- qlmanage >/dev/null 2>&1 ||
    return 127
  while test "$#" -ne 0; do
    command qlmanage -p -- "$1" >/dev/null 2>&1 &&
      shift
  done
}

# Rectangle
# set ⌘⌥F to maximize the focused window
alias rectangle_shortcut='command defaults write com.knollsoft.Rectangle maximize -dict-add keyCode -float 3 modifierFlags -float 1572864 2>/dev/null'

# remove
rm() {
  if command -v -- trash >/dev/null 2>&1; then
    utility='trash'
  else
    utility='rm'
  fi
  case "${1-}" in
  -o | --others)
    command git ls-files -z --others --exclude-standard |
      command sed \
        -e '# https://web.archive.org/web/0id_/etalabs.net/sh_tricks.html#:~:text=Using%20find%20with%20xargs' \
        -e 's/./\\&/g' |
      command xargs "${utility-}"
    ;;
  *)
    command "${utility-}" "$@"
    ;;
  esac
  unset -v -- utility
}
alias rmo='rm --others'

sca() {
  while getopts s: opt; do
    case "${opt-}" in
    s)
      shell="${OPTARG:-sh}"
      ;;
    *)
      printf -- 'usage: %s [-s [bash|dash|ksh|sh]] [--] [file]\n' "${0##*/}" >&2
      ;;
    esac
  done
  shift "$((OPTIND - 1))"
  for file in "${@:-"${DOTFILES-}"/custom/aliases."${SHELL##*[-./]}"}"; do
    case "${file-}" in
    --)
      shift 1
      ;;
    *)
      printf -- '%s...\n' "${file##*/}"
      for test in \
        'shellcheck --color=always --enable=all --exclude=SC1071,SC1091,SC2123,SC2312,SC3040 --external-sources --format=gcc --source-path=/dev/null --shell='"${shell:-sh}" \
        'zsh         -C    -e    -n -u    -o pipefail -o noglob' \
        'ash         -C    -e -f -n -u -x' \
        'bash        -C    -e -f -n -u -x -o pipefail -o functrace' \
        'dash        -C    -e -f -n -u -x' \
        'ksh         -C -b -e -f -n -u -x -o pipefail' \
        'ksh93       -C -b -e -f -n -u -x -o pipefail -o posix' \
        'ksh2020     -C -b -e -f -n -u -x -o pipefail' \
        'mksh        -C -b -e -f -n -u -x -o pipefail -o posix' \
        'mksh-static -C -b -e -f -n -u -x -o pipefail -o posix' \
        'oksh        -C -b -e -f -n -u -x -o pipefail -o posix' \
        'pdksh       -C -b -e -f -n -u -x -o pipefail -o posix' \
        'pfksh       -C -b -e -f -n -u -x -o pipefail -o posix' \
        'posh        -C    -e -f -n -u -x' \
        'psh         -C    -e -f -n -u -x' \
        'rbash       -C    -e -f -n -u -x -o pipefail -o functrace' \
        'rksh        -C -b -e -f -n -u -x -o pipefail' \
        'rksh93      -C -b -e -f -n -u -x -o pipefail -o posix' \
        'rksh2020    -C -b -e -f -n -u -x -o pipefail' \
        'scsh        -C    -e -f -n -u -x' \
        'yash        -C    -e -f -n -u -x -o pipefail -o posixly-correct' \
        'sh          -C    -e -f -n -u -x -o pipefail -o posix' \
        'zsh         -C    -e    -n -u    -o pipefail -o noglob -o posix_aliases -o posix_arg_zero -o posix_builtins -o posix_cd -o posix_identifiers -o posix_jobs -o posix_strings -o posix_traps'; do
        if command -v -- "${test%% *}" >/dev/null 2>&1; then
          eval " command ${test-} -- '${file-}'" 2>&1 |
            # paths in descending specificity:
            command sed \
              -e 's|'"${custom-}"'|$\custom|' \
              -e 's|'"${DOTFILES-}"'|$\DOTFILES|' \
              -e 's|'"${XDG_CONFIG_HOME-}"'|$\XDG_CONFIG_HOME|' \
              -e 's|'"${HOME%/}"'|~|' &&
            {
              printf -- '  passed %s\n' "${test%% *}"
            } 2>/dev/null ||
            printf -- '    failed %s\n' "${test%% *}"
        fi
      done
      ;;
    esac
  done
  unset -v -- file
  unset -v -- test
  unset -v -- opt
}

# take: mkdir && cd
take() {
  for directory in "$@"; do
    if test ! -d "${directory-}"; then
      command mkdir -p -- "${directory-}"
      test -d "${directory-}" &&
        printf -- 'creating directory \342\200\230%s\342\200\231...\n' "${directory-}" ||
        return 1
    else
      printf -- 'directory \342\200\230%s\342\200\231 exists...\n' "${directory-}"
    fi
  done
  unset -v -- directory

  # POSIX-compliant `${@:$#}`-style and `${@: -1}`-style string indexing (SC3057)
  # https://stackoverflow.com/a/1853993
  for directory in "$@"; do
    :
  done
  if test -d "${directory-}"; then
    cd -- "${directory-}" >/dev/null 2>&1 &&
      printf -- 'moving into \342\200\230%s\342\200\231\n' "${directory-}"
  else
    # it’s not a directory
    return 1
  fi
  unset -v -- directory
}

transfer() {
  for file in "$@"; do
    {
      command curl --silent --upload-file "${file-}" --url 'https://temp.sh/'"${file##*/}" ||
        command wget --method=PUT --output-document=- --quiet --body-file="${file-}" 'https://temp.sh/'"${file##*/}"
    } 2>/dev/null &&
      printf -- '\n'
  done
  unset -v -- file 2>/dev/null || file=''
}

# Unix epoch seconds
alias unixtime='command awk -- '\''BEGIN {srand(); print srand()}'\'''

user() {
  printf -- '%s' "${LOGNAME:-${USER-}}" &&
    printf -- '\n'
}

alias all='which -a'

yamllint_r() {
  command -v -- yamllint >/dev/null 2>&1 ||
    return 1
  command find -- . \
    -path "${DOTFILES-}"'/Library' -prune -o \
    -path "${HOME%/}"'/Library' -prune -o \
    -path '*/.git' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/copilot.vim' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/t' -prune -o \
    -path '*/Test*' -prune -o \
    -path '*/test*' -prune -o \
    -path '*vscode*' -prune -o \
    '(' \
    -name '*.yml' -o \
    -name '*.CFF' -o \
    -name '*.cff' -o \
    -name '*.mir' -o \
    -name '*.reek' -o \
    -name '*.rviz' -o \
    -name '*.sublime-syntax' -o \
    -name '*.syntax' -o \
    -name '*.YAML' -o \
    -name '*.yaml' -o \
    -name '*.yaml-tmlanguage' -o \
    -name '*.yaml.sed' -o \
    -name '*.YML' -o \
    -name '*.yml.mysql' -o \
    -name '.clang-format' -o \
    -name '.clang-tidy' -o \
    -name '.gemrc' \
    ')' \
    -type f \
    -print \
    -exec sh -c 'command git ls-files --error-unmatch -- "{}" >/dev/null 2>&1 ||
! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command yamllint --format colored --strict -- "{}" |
  command grep -v -e "(truthy)"' ';'
}

# zero
# https://github.com/zdharma-continuum/Zsh-100-Commits-Club/blob/1f880d03ec/Zsh-Plugin-Standard.adoc#zero-handling
zero() {
  printf -- '0=\044{ZERO:-\044{\044{0:#\044ZSH_ARGZERO}:-\044{(\045):-\045N}}}'
  printf -- '\n'
  printf -- '0=\044{\044{(M)0:#/*}:-\044{PWD}/\0440}'
  printf -- '\n'
}

ohmyzsh() {
  cd -- "${ZSH-}" &&
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command sed -e '$d'
}
alias zshenv='command "${EDITOR:-vi}" -- "${HOME%/}/.${SHELL##*[-./]}env"; . "${HOME%/}/.${SHELL##*[-./]}rc" && exec -l -- "${SHELL##*[-./]}"'
alias zshrc='command "${EDITOR:-vi}" -- "${HOME%/}/.${SHELL##*[-./]}rc"; . "${HOME%/}/.${SHELL##*[-./]}rc" && exec -l -- "${SHELL##*[-./]}"'
