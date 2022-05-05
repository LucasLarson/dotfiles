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
# https://stackoverflow.com/a/1371283
# https://github.com/mathiasbynens/dotfiles/commit/cb8843b
alias ,='. "${HOME-}"/."${SHELL##*[-./]}"rc && exec -l -- "${SHELL##*[-./]}"'
aliases() {
  command "${EDITOR:-vi}" -- "${DOTFILES-}/custom/aliases.${SHELL##*[-./]}" &&
    command -v -- shfmt >/dev/null 2>&1 &&
    command shfmt -s -w -i 2 -- "${DOTFILES-}/custom/aliases.${SHELL##*[-./]}"
  . "${DOTFILES-}/custom/aliases.${SHELL##*[-./]}"
}

# Atom
atom_packages() {
  # https://gist.github.com/a8289eeaba6ede045dd532cf0eaea44f#comments
  command apm-nightly list --installed --bare ||
    command apm-beta list --installed --bare ||
    command apm list --installed --bare
}

bash_major_version() {
  # confirm Bash version is at least any given version (default: at least Bash 4)
  if test "$(command bash --version | command head -n 1 | command awk '{print $4}' | command cut -d '.' -f 1)" -lt "${1:-4}"; then
    printf 'You will need to upgrade to version %d for full functionality.\n' "${1:-4}" >&2
    return 1
  fi
}
alias bash_version='bash_major_version'

bash_pretty() {
  # use this script to remove comments from shell scripts
  # and potentially find duplicate content

  set +o allexport
  set -o noclobber
  set -o nounset
  set -o xtrace
  for file in "$@"; do

    # if `bash --pretty-print` fails on the file, skip it
    if command bash --pretty-print -- "${file}" 2>/dev/null; then
      # first Bash
      {
        # add the shell directive
        printf '#!/usr/bin/env bash\n'

        # add `bash --pretty-print` content
        command bash --pretty-print -- "${file}"

        # save `$file`'s interpolated content into a file called `$file.bash`
        # unless it already exists: `>|` prevents overwriting
      } >|"${file}"'.bash'

      # next nominally POSIX shell
      {
        # add the shell directive
        printf '#!/usr/bin/env sh\n'

        # add `bash --pretty-print --posix` content
        command bash --pretty-print --posix -- "${file-}"
      } >|"${file-}"'.sh'
    fi
  done
  {
    set -o allexport
    set +o noclobber
    set +o nounset
    set +o xtrace
  } 2>/dev/null
  unset file
}

# prefer `bat` to `cat` if available
command -v -- bat >/dev/null 2>&1 &&
  alias cat='command bat --decorations never'

cd_pwd_P() {
  cd_from="$(command pwd -L)"
  cd_to="$(command pwd -P)"
  if test "${cd_from-}" != "${cd_to-}"; then
    printf 'moving from \342\200\230%s\342\200\231\n' "${cd_from-}"
    command sleep 0.2
    cd "${cd_to-}" || {
      printf 'unable to perform this operation\n'
      return 1
    }
    printf '       into \342\200\230%s\342\200\231\n' "${cd_to-}"
    command sleep 0.2
  else
    printf 'already in unaliased directory '
    printf '\342\200\230%s\342\200\231\n' "${cd_from-}"
    return 1
  fi
  unset -- cd_from 2>/dev/null
  unset -- cd_to 2>/dev/null
}
alias cdp='cd_pwd_P'

alias chmod='command chmod -v'

clang_format() {

  command clang-format --version 2>/dev/null ||
    return 2
  command sleep 1

  # https://github.com/Originate/guide/blob/880952d/ios/files/clang-format.sh

  # set `clang-format` `IndentWidth` default to 2
  IndentWidth='2'

  # set `clang-format` `ColumnLimit` default to 79
  ColumnLimit='79'

  printf 'applying clang-format to all applicable files in %s...\n' "${PWD##*/}"
  command sleep 1

  # permit arguments in any order
  # https://salsa.debian.org/debian/debianutils/blob/c2a1c435ef/savelog
  while getopts i:w: opt; do
    case "${opt-}" in
    i)
      IndentWidth="${OPTARG-}"
      printf 'setting \140IndentWidth\140 to %d\n' "${IndentWidth-}"
      command sleep 1
      ;;
    w)
      ColumnLimit="${OPTARG-}"
      printf 'setting \140ColumnLimit\140 to %d\n\n\n' "${ColumnLimit-}"
      command sleep 1
      ;;
    *)
      printf 'only \140-i <indent width>\140 and \140-w <number of columns>\140 are supported\n'
      return 1
      ;;
    esac
  done

  # eligible filename extensions:
  # https://github.com/llvm/llvm-project/blob/d1c8a151df/clang/lib/Driver/Types.cpp#L236-L294
  # https://github.com/llvm/llvm-project/blob/d1c8a151df/clang/lib/Frontend/FrontendOptions.cpp#L17-L35
  # https://github.com/llvm/llvm-project/blob/e20a1e486e/clang/tools/clang-format-vs/ClangFormat/ClangFormatPackage.cs#L41-L42
  # https://github.com/llvm/llvm-project/blob/edbb8a843c/clang/tools/clang-format/git-clang-format#L78-L90
  # https://github.com/llvm/llvm-project/blob/cea81e95b0/clang/tools/clang-format/clang-format-diff.py#L50-L51

  command find -- . \
    -type f \
    ! -path '*/.git/*' \
    ! -path '*/node_modules/*' \
    ! -path '*/t/*' \
    ! -path '*/Test*' \
    ! -path '*/test*' \
    ! -path '*vscode*' \
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
    -name '*.hp' -o \
    -name '*.hpp' -o \
    -name '*.hxx' -o \
    -name '*.i' -o \
    -name '*.ifs' -o \
    -name '*.ii' -o \
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
    -name '*.rs' -o \
    -name '*.S' -o \
    -name '*.s' -o \
    -name '*.tcc' -o \
    -name '*.td' -o \
    -name '*.tlh' -o \
    -name '*.tli' -o \
    -name '*.tpp' -o \
    -name '*.ts' -o \
    -name '*.txx' \
    ')' \
    -exec clang-format -i --style "{IndentWidth: ${IndentWidth-}, ColumnLimit: ${ColumnLimit-}}" --verbose --fcolor-diagnostics --print-options -- '{}' '+'

  unset -- IndentWidth 2>/dev/null
  unset -- ColumnLimit 2>/dev/null

  printf '\n\n'
  printf '\342\234\205  done\041\n'
}

cleanup() {
  case "${1-}" in
  # if `cleanup -v` or `cleanup --verbose`,
  # then use `-print` during `-delete`
  -v | --verbose)
    set -o verbose
    set -o xtrace
    shift
    ;;

  *)
    # refuse to run from `$HOME`
    test "$(command pwd -P)" = "${HOME-}" ||

      # or from any titlecase-named directory just below it
      # assumes any titlecase-named directory in `$HOME` must not be touched
      # even though macOS standard directories are a closed set of:
      # `Applications`, `Desktop`, `Documents`, `Downloads`, `Library`, `Movies`, `Music`, `Pictures`, `Public`, and `Sites`
      # https://web.archive.org/web/0id_/developer.apple.com/library/mac/documentation/FileManagement/Conceptual/FileSystemProgrammingGUide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW9
      test "$(command pwd -P | command xargs -n 1 dirname)" = "${HOME-}" &&
      case "$(command pwd -P | command tr -d '[:space:]' | command xargs basename -- | command cut -c 1)" in
      [A-Z])
        printf '\n\n'
        printf '\342\233\224\357\270\217  aborting: refusing to run from \140\044HOME\140 or macOS standard directory\n'
        printf '\n\n'
        exit 19
        ;;
      *)
        # permit running from non-titlecase-named directories in `$HOME`
        ;;
      esac

    # delete thumbnail cache files
    # and hide `find: ‘./com...’: Operation not permitted` with `2>/dev/null`
    command find -- "${1:-.}" \
      -type f \
      '(' \
      -name '.DS_Store' -o \
      -name 'Desktop.ini' -o \
      -name 'desktop.ini' -o \
      -name 'Thumbs.db' -o \
      -name 'thumbs.db' \
      ')' \
      -print \
      -delete 2>/dev/null

    # delete crufty Zsh files
    # if `$ZSH_COMPDUMP` always generates a crufty file then skip
    # https://stackoverflow.com/a/8811800
    if test -n "${ZSH_COMPDUMP-}" &&
      test ! "${ZSH_COMPDUMP-}" != "${ZSH_COMPDUMP#*'zcompdump-'}" &&
      test ! "${ZSH_COMPDUMP-}" != "${ZSH_COMPDUMP#*'zcompdump.'}"; then
      while test -n "$(
        command find -- "${HOME-}" \
          -maxdepth 1 \
          -type f \
          ! -name "$(printf "*\n*")" \
          ! -name '.zcompdump' \
          -name '.zcompdump*' \
          -print
      )"; do
        command find -- "${HOME-}" \
          -maxdepth 1 \
          -type f \
          ! -name "$(printf "*\n*")" \
          ! -name '.zcompdump' \
          -name '.zcompdump*' \
          -print \
          -delete 2>/dev/null
      done
    fi

    # delete empty, writable, zero-length files
    # except those within `.git/` directories
    # and except those with specific names
    # https://stackoverflow.com/a/64863398
    command find -- "${1:-.}" \
      -type f \
      -writable \
      -size 0 \
      ! -path '*/.git/*' \
      ! -path '*/node_modules/*' \
      ! -path '*/t/*' \
      ! -path '*/Test*' \
      ! -path '*/test*' \
      ! -path '*vscode*' \
      ! -name "$(printf 'Icon\015\012')" \
      ! -name '*.plugin.zsh' \
      ! -name '*empty*' \
      ! -name '*ignore' \
      ! -name '*journal' \
      ! -name '*lck' \
      ! -name '*LOCK' \
      ! -name '*lock' \
      ! -name '*lockfile' \
      ! -name '*rc' \
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
      -print \
      -delete 2>/dev/null

    # delete empty directories recursively
    # but skip Git-specific and `/.well-known/` directories
    command find -- "${1:-.}" \
      -type d \
      -empty \
      ! -path '*/.git/*' \
      ! -name '.well-known' \
      -print \
      -delete 2>/dev/null

    # repair Git case sensitivity
    # https://unix.stackexchange.com/a/112024
    command find -- "${1:-.}" \
      -type f \
      ! -path '*/node_modules/*' \
      ! -path '*/t/*' \
      ! -path '*/Test*' \
      ! -path '*/test*' \
      ! -path '*vscode*' \
      '(' \
      -name '*gitconfig' -o \
      -path '*/.git/*' -a -name 'config' \
      ')' \
      -print \
      -exec sed -E -i -e 's|ignore[Cc]ase =.*|ignoreCase = false|g' -- '{}' '+' \
      -exec sed -E -i -e 's|\t|  |g' -- '{}' '+' 2>/dev/null

    # remove Git sample hooks
    command find -- "${1:-.}" \
      -type f \
      -path '*/.git/*' \
      -path '*/hooks/*.sample' \
      -print \
      -delete 2>/dev/null

    ;;
  esac
  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}

# https://mywiki.wooledge.org/BashPitfalls?rev=524#Filenames_with_leading_dashes
alias cp='cp -R'
cy() {
  test -n "${DOTFILES-}" &&
    test -n "${TEMPLATE-}" ||
    return 1

  target="$(command git rev-parse --show-toplevel 2>/dev/null || command pwd -L)" ||
    return 1

  for file in \
    "${DOTFILES-}"'/.github' \
    "${TEMPLATE-}"'/.github' \
    "${TEMPLATE-}"'/.deepsource.toml' \
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
  {
    unset -- file
    unset -- target
  } 2>/dev/null
}

# number of files
# this directory and below
count_files() {
  # https://unix.stackexchange.com/a/1126
  command find -- .//. \
    ! -path '*/.git/*' \
    ! -name '.' \
    -type f \
    -print |
    command grep -c -e //
}

count_files_and_directories() {
  command find -- .//. \
    ! -path '*/.git/*' \
    ! -name '.' \
    -print |
    command grep -c -e //
}

count_files_by_extension() {
  # files with no extension
  # homemade
  command find -- . \
    ! -path '*/.git/*' \
    ! -path '*/node_modules/*' \
    '(' \
    -type f -o \
    -type l \
    ')' \
    ! -name '*.*' \
    -print 2>/dev/null |
    LC_ALL='C' command sort -u |
    command uniq -c |
    LC_ALL='C' command awk '{print $1}' |
    command uniq -c |
    command sed -E -e 's|.$|[no extension]|g'

  # files with extensions
  command find -- . \
    ! -path '*/.git/*' \
    ! -path '*/node_modules/*' \
    '(' \
    -type f -o \
    -type l \
    ')' \
    -exec basename -a -- '{}' '+' 2>/dev/null |

    # https://2daygeek.com/how-to-count-files-by-extension-in-linux
    command sed -n -e 's|..*\.||p' |
    LC_ALL='C' command sort |
    command uniq -c |
    LC_ALL='C' command sort -r
}

# number of files
# in current directory
count_files_in_this_directory() {
  case "$@" in
  # count files as well as directories
  -d | --directory | --directories)
    command find -- . \
      ! -path '*/.git/*' \
      ! -name '.' \
      -prune \
      -print |
      command grep -c -e /
    ;;

    # count only regular, non-directory files
  *)
    # https://unix.stackexchange.com/a/1126
    command find -- . \
      -type f \
      ! -path '*/.git/*' \
      ! -name '.' \
      -prune \
      -print |
      command grep -c -e /
    ;;
  esac
}

alias diff='command diff --color'

# define
define() {
  for query in "${@:-"$0"}"; do

    # `hash`
    command -v -- hash >/dev/null 2>&1 &&
      printf 'hash return value:\n%d\n———\n' "$(
        hash "${query-}" >/dev/null 2>&1
        printf '%d\n' "$?"
      )"

    # `type` (System V)
    command -v -- type >/dev/null 2>&1 &&
      printf 'type:\n%s\n———\n' "$(type "${query-}")"

    # `whence` (KornShell)
    command -v -- whence >/dev/null 2>&1 &&
      printf 'whence:\n%s\n———\n' "$(whence "${query-}")"

    # `where`
    command -v -- where >/dev/null 2>&1 &&
      printf 'where:\n%s\n———\n' "$(where "${query-}")"

    # `whereis`
    command -v -- whereis >/dev/null 2>&1 &&
      printf 'whereis:\n%s\n———\n' "$(whereis "${query-}")"

    # `locate`
    command -v -- locate >/dev/null 2>&1 &&
      printf 'locate:\n%s\n———\n' "$(locate "${query-}")"

    # `command -V`
    printf 'command -V:\n%s\n———\n' "$(command -V -- "${query-}")"

    # `command -v` (POSIX)
    printf 'command -v:\n%s\n———\n' "$(command -v -- "${query-}")"

    # `which` (C shell)
    command -v -- which >/dev/null 2>&1 &&
      printf 'which -a:\n%s\n' "$(command which -a "${query-}")"

    # `functions | shfmt`
    if builtin functions -- "${query-}" 2>/dev/null | command shfmt -s -i 2 >/dev/null 2>&1; then
      printf '%s\n' "$(builtin functions -- "${query-}" | command shfmt -s -i 2)"

    # `functions`
    elif builtin functions -- "${query-}" >/dev/null 2>&1; then
      printf '%s\n' "$(builtin functions -x 2 -- "${query-}")"
    fi
  done
  unset -- query 2>/dev/null
}
alias d='define'

dictionary() {
  # sort as you’d expect to find in a dictionary
  LC_ALL='C' command sort -u "${1:---}" |
    LC_ALL='C' command sort -f
}

epoch_seconds() {
  # return seconds since the epoch, 1969-12-31 19:00:00 EST
  # https://stackoverflow.com/a/41324810
  # `srand([expr])` will “Set the seed value for `rand` to `expr` or
  # use the time of day if `expr` is omitted.”
  # https://opengroup.org/onlinepubs/9699919799/utilities/awk.html#tag_20_06_13_12
  command awk 'BEGIN {srand(); print srand()}'
}

filename_spaces_to_underscores() {
  (
    from="${1:- }"
    to="${2:-_}"
    command find -- . \
      -depth \
      -name '*'"${from-}"'*' |
      while IFS='' read -r filename; do
        command mv -i "${filename-}" "$(command dirname -- "${filename-}")"/"$(
          command basename -- "${filename-}" |
            command tr "${from-}" "${to-}"
        )"
      done
  )
}

file_closes_with_newline() {
  set -o nounset
  test "$(command tail -c 1 -- "${1-}" | command wc -l)" -eq '0' &&
    return 1
  set +o nounset
}

command -v -- fd >/dev/null 2>&1 &&
  alias fd='command fd --hidden'

# find broken symlinks
find_broken_symlinks() {
  set -o nounset
  # https://unix.stackexchange.com/a/49470
  command find -- . \
    -type l \
    -exec test ! -e '{}' ';' \
    -print 2>/dev/null
  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}

# find duplicate files
# https://linuxjournal.com/content/boost-productivity-bash-tips-and-tricks
find_duplicate_files() {
  command find -- "${1:-.}" \
    ! -path '*/.git/*' \
    ! -path '*/node_modules/*' \
    ! -path '*/t/*' \
    ! -path '*/Test*' \
    ! -path '*/test*' \
    ! -path '*vscode*' \
    ! -empty \
    ! -type l \
    -type f \
    -printf '%s\n' 2>/dev/null |
    LC_ALL='C' command sort -n -r |
    command uniq -d |
    command xargs -I{} -n 1 find \
      -type f \
      -size {}c \
      -print0 2>/dev/null |
    command xargs -0 sha1sum 2>/dev/null |
    LC_ALL='C' command sort |
    command uniq -w 32 --all-repeated=separate
}
alias fdf='find_duplicate_files'

# find by name
find_by_name() {
  command find -- . \
    ! -path '*/.git/*' \
    ! -path '*/Application Support/*' \
    ! -path '*/Archive*' \
    ! -path '*/archive*' \
    ! -path '*/custom/plugins/*' \
    ! -path '*/custom/themes/*' \
    ! -path '*/node_modules/*' \
    ! -path '*/t/*' \
    ! -path '*/Test*' \
    ! -path '*/test*' \
    ! -path '*vscode*' \
    -iname "*${*}*" \
    -print 2>/dev/null |
    LC_ALL='C' command sort -u
}
alias fname='find_by_name'

compdef -- 'find_no_git'='find' 2>/dev/null
find_no_git() {
  command find -- . \
    -mindepth 1 \
    ! -path '*/.git/*' \
    "$@"
}

find_oldest_file() {
  command find -- . \
    -type f \
    ! -path '*/.git/*' \
    -exec /bin/ls -l -t -r -- '{}' '+' 2>/dev/null |
    command head -n 1
}

find_shell_scripts() {
  set -o nounset
  {
    # all files with extensions `.bash`, `.dash`, `.ksh`, `.mksh`, `.sh`, `.zsh`
    command find -- . \
      ! -path '*/.git/*' \
      -type f \
      -name '*.bash' -o \
      -name '*.dash' -o \
      -name '*.ksh' -o \
      -name '*.mksh' -o \
      -name '*.sh' -o \
      -name '*.zsh' 2>/dev/null

    # files whose first line resembles those of shell scripts
    # https://stackoverflow.com/a/9612232
    command find -- . \
      ! -path '*/.git/*' \
      ! -path '*/node_modules/*' \
      ! -path '*/t/*' \
      ! -path '*/Test*' \
      ! -path '*/test*' \
      ! -path '*vscode*' \
      -type f \
      -exec head -n 1 -- '{}' '+' 2>/dev/null |
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
    LC_ALL='C' command sort -u

  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}

# Git
unalias -- g 2>/dev/null
compdef g='git' 2>/dev/null
g() {
  {
    test "$#" -eq '0' &&
      command git status
  } ||
    command git "$@" ||
    command git status .
}
alias g.='command git status .'
alias guo='command git status --untracked-files=no'

# git add
git_add() {
  (
    unset -- PS4 2>/dev/null
    set +o allexport
    set -o verbose
    set -o xtrace
    case "${1-}" in
    -A | --all)
      command git add --verbose "$@" &&
        shift
      ;;
    -D | --deleted)
      # https://gist.github.com/8775224
      command git ls-files -z --deleted |
        command xargs -0 git add --verbose 2>/dev/null &&
        shift
      ;;
    -m | --modified)
      command git ls-files -z --modified |
        command xargs -0 git add --verbose 2>/dev/null &&
        shift
      ;;
    -o | --others | --untracked)
      while test -n "$(command git ls-files --others --exclude-standard)"; do
        command git ls-files -z --others --exclude-standard |
          command xargs -0 git add --verbose 2>/dev/null
      done &&
        shift
      ;;
    -p | --patch)
      shift
      command git add --verbose --patch "${@:-.}"
      ;;
    *)
      # default to everything in the current directory and below
      command git add --verbose "${@:-.}" &&
        shift
      ;;
    esac &&
      command git status
  )
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
      command awk '{print "./" $0}'
    ;;
  *)
    # list all files ever
    command git log --pretty= --name-only --all |
      LC_ALL='C' command sort -u |
      command awk '{print "./" $0}'
    ;;
  esac
}

alias gba='command git branch --all'
alias gbd='command git branch --delete'
alias gbD='command git branch --delete --force'

# git commit
git_commit() {
  set -o nounset
  if test "$#" -eq '0'; then
    command git commit --signoff --verbose ||
      return 1
  elif test "$1" = '--amend'; then
    command git commit --amend --signoff --verbose ||
      return 1
  else
    command git commit --signoff --verbose --message "$@" ||
      return 1
  fi
  command git status
  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}
alias gc='git_commit'
alias gcm='git_commit'
alias gca='git_commit --amend'

# git clone
git_clone() {
  set -o nounset
  case "${1-}" in
  -h | --help)
    printf 'Usage: %s <git_url> [<dir_name>]\n' "$(command basename -- "$0")" &&
      return 0
    ;;
  -1 | --shallow)
    shift
    command mkdir "${2:-$(command basename -- "$1" .git || return 123)}" >/dev/null 2>&1
    cd "${2:-$(command basename -- "$1" .git || return 122)}" >/dev/null 2>&1 || return 5
    command git clone --verbose --progress --depth=1 --shallow-submodules "$1" . || return 6
    ;;
  *)
    command mkdir "${2:-$(command basename -- "$1" .git || return 126)}" >/dev/null 2>&1
    cd "${2:-$(command basename -- "$1" .git || return 125)}" >/dev/null 2>&1 || return 3
    command git clone --verbose --progress --recursive -- "$1" . || return 4
    ;;
  esac
  set +o nounset
}
alias gcl='git_clone'
alias gcl1='git_clone -1'

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
  set -o nounset
  if command git branch --merged |
    command grep -v -e '\*'; then
    command git branch --merged |
      command grep -v -e '\*' |
      command xargs -n 1 git branch --delete --verbose
  fi
  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}
alias gdmb='git_delete_merged_branches'

unalias -- gd 2>/dev/null
gd() {
  if test -n "$(command git diff "$@" 2>/dev/null)"; then
    command git diff "$@"
  else
    command git diff --staged "$@"
  fi
}
alias gds='command git diff --staged'

alias gdm='command git diff "$(git-default-branch)" --'
alias gdom='command git diff "$(git-default-branch)" origin/"$(git-default-branch)" || command git diff "$(git-default-branch)" upstream/"$(git-default-branch)"'
alias gdw='command git diff --word-diff=color'

alias gfgs='command git fetch --all --prune --verbose && command git status'
git_garbage_collection() {
  command -v -- cleanup >/dev/null 2>&1 &&
    cleanup "$@"
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    set -o nounset
    # see `git gc` and other wrapping commands behind-the-scene mechanics
    # https://github.com/git/git/blob/49eb8d3/contrib/examples/README#L14-L16
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git fetch --prune --prune-tags --verbose 2>/dev/null
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git prune --verbose --progress --expire=now 2>/dev/null
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git prune-packed
    command git maintenance start >/dev/null 2>&1 &&
      GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git maintenance start
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git gc --aggressive --prune=now
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git repack -a -d -f -F --window=4095 --depth=4095
    GIT_TRACE='1' GIT_TRACE_PACK_ACCESS='1' GIT_TRACE_PACKET='1' GIT_TRACE_PERFORMANCE='1' GIT_TRACE_SETUP='1' command git status
    unset -- GIT_TRACE 2>/dev/null
    unset -- GIT_TRACE_PACK_ACCESS 2>/dev/null
    unset -- GIT_TRACE_PACKET 2>/dev/null
    unset -- GIT_TRACE_PERFORMANCE 2>/dev/null
    unset -- GIT_TRACE_SETUP 2>/dev/null
  else
    return 1
  fi
  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}
alias ggc='git_garbage_collection'

# git parents, git child
git_find_child() {
  set -o errexit
  set -o nounset
  commit="${1:-"$(command git rev-parse HEAD)"}"
  # %H: commit hash
  # %P: parent commit
  command git log --pretty='%H %P' |
    command grep -e " ${commit-}" |
    command cut -c 1-40
  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}
git_find_parent() {
  # return the hash prior to the current commit
  # if an argument is provided, return the commit prior to that commit
  # usage: git_find_parent <commit>
  set -o nounset
  command git rev-list --max-count=1 "${1:-$(command git rev-parse HEAD)}^"
  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}
git_find_parents() {
  # return all hashes prior to the current commit
  # if an argument is provided, return all commits prior to that commit
  # usage: git_find_parents <commit>
  set -o nounset
  command git rev-list "${1:-$(command git rev-parse HEAD)}^"
  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}
alias git_parent='git_find_parent'
alias gfp='git_find_parent'
alias gfc='git_find_child'
alias git_parents='git_find_parents'

# find initial commit
git_find_initial_commit() {
  # https://stackoverflow.com/q/1006775#comment23686803_1007545
  command git rev-list --topo-order --parents HEAD -- |
    command grep -E -e '^[a-f0-9]{40}$'
}
alias gic='git_find_initial_commit'

# commit initial commit
git_commit_initial_commit() {
  set -o nounset
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
  command git commit --allow-empty --signoff --verbose --message="$(printf '\360\237\214\263\302\240 root commit')"

  # if there are non-repository files present, then add them and commit
  if test -n "$(command git ls-files --others --exclude-standard)"; then
    command git add --verbose -- . &&
      command git commit --signoff --verbose --message="$(printf '\342\234\250\302\240 initial commit')"
  fi

  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
  unset -- git_time 2>/dev/null
  unset -- GIT_AUTHOR_DATE 2>/dev/null
  unset -- GIT_COMMITTER_DATE 2>/dev/null
}
alias gcic='git_commit_initial_commit'
alias ginit='command git init && command git status'

# git last common ancestor
git_last_common_ancestor() {
  # https://stackoverflow.com/a/1549155
  test "$#" -eq '2' ||
    return 1
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
  GIT_MERGE_VERBOSITY='4' command git merge --log --overwrite-ignore --progress --rerere-autoupdate --strategy-option patience
}
gmc() {
  GIT_MERGE_VERBOSITY='4' command git merge --log --continue
}

# git merge with default branch
gmm() {
  # set Git merge verbosity environment variable
  # 4 “shows all paths as they are processed” but
  # 5 is “show detailed debugging information”
  # https://github.com/progit/progit2/commit/aea93a7
  GIT_MERGE_VERBOSITY='4' command git merge --log --verbose --progress --rerere-autoupdate --strategy-option patience "$(git-default-branch)"
}

# git move
git_move() {
  {
    command git mv --verbose --force "$@" ||
      command mv -i "$@" ||
      return 1
  } &&
    command git status
}
alias gmv='git_move'

command -v -- git open >/dev/null 2>&1 &&
  alias gopen='command git open 2>/dev/null'

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

git_default_remote() {
  {
    command git config --get --worktree checkout.defaultRemote ||
      command git config --get --local checkout.defaultRemote ||
      command git config --get --system checkout.defaultRemote ||
      command git config --get --global checkout.defaultRemote ||
      printf 'origin\n'
  } 2>/dev/null
}

# git push
git_push() {
  # https://github.com/ohmyzsh/ohmyzsh/commit/ae21102
  command git push --verbose --progress --set-upstream origin "$(git_current_branch)" &&
    command git status
}
alias gps='git_push'

alias grbi='command git rebase --interactive'
alias grbc='command git rebase --continue'
alias gref='command git reflog'

alias grmr='command git rm -r'
alias grm='grmr'

git_remote_verbose() {
  # print `git remote -v` into columnized output
  command git remote --verbose |
    command awk -F'[\t ]+' '{printf "%-16s %s\n", $1, $2}' |
    command uniq
}
alias grv='git_remote_verbose'

git_restore() {
  for file in "$@"; do
    command git checkout --progress -- "${file-}"
  done &&
    command git status
  unset -- file 2>/dev/null
}
alias grs='git_restore'

git_shallow() {
  # Shallow .gitmodules submodule installations
  # Mauricio Scheffer https://stackoverflow.com/a/2169914

  set -o nounset
  command git submodule init
  for submodule in $(command git submodule | command sed -e 's|.* ||'); do
    submodule_path="$(command git config --file .gitmodules --get submodule."${submodule-}".path)"
    submodule_url="$(command git config --file .gitmodules --get submodule."${submodule-}".url)"
    command git clone --depth=1 --shallow-submodules "${submodule_url-}" "${submodule_path-}"
  done
  command git submodule update

  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
  unset -- submodule 2>/dev/null
  unset -- submodule_path 2>/dev/null
  unset -- submodule_url 2>/dev/null
}

alias gsh='command git show'

git_stash_save_all() {
  # https://github.com/ohmyzsh/ohmyzsh/commit/69ba6e4359
  command git stash push --all --message "$@" 2>/dev/null ||
    command git stash push --all
}
alias gstall='git_stash_save_all'
alias gstc='command git stash clear'

alias gs='command git status'

git_submodule_update() {
  command git submodule update --init --remote "$@" &&
    command git submodule sync "$@" &&
    command git status
}
alias gsu='git_submodule_update'
alias gtake='git checkout -b'

git_undo() {
  command git reset HEAD@'{'"${1:-1}"'}'
}
alias gundo='git_undo'

git_update() {
  command -v -- cleanup >/dev/null 2>&1 &&
    cleanup "$@"

  # run only from within a Git repository
  # https://stackoverflow.com/a/53809163
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
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

gravatar() {
  # gravatar
  # return the URL of a Gravatar image for the given email address

  set +o allexport
  set -o errexit
  set -o nounset

  # get the email address
  email="${1:-$(command git config --get user.email)}"
  size="${2:-4096}"

  # remove spaces
  email="$(printf '%s' "${email-}" | command tr -d '[:space:]')"

  # change to all lowercase
  email="$(printf '%s' "${email-}" | command tr '[:upper:]' '[:lower:]')"

  # discover md5 utility
  if command -v -- md5sum >/dev/null 2>&1; then
    utility='md5sum'
  else
    utility='md5'
  fi

  # hash the email address
  email="$(printf '%s' "${email-}" | command "${utility-}" | command cut -b 1-32)"

  # return the Gravatar image URL
  printf 'https://gravatar.com/avatar/%s?s=%d\n' "${email-}" "${size-}"

  # cleanup variables
  unset -- email 2>/dev/null
  unset -- size 2>/dev/null
  unset -- utility 2>/dev/null

  {
    set -o allexport
    set +o errexit
    set +o nounset
  } 2>/dev/null
}

alias h1='command head -n 1'

history_stats() {
  fc -l 1 |
    command awk '{CMD[$2]++; count++;}; END {for (a in CMD) print CMD[a] " " CMD[a] * 100 / count "% " a;}' |
    command grep -v -e './' |
    LC_ALL='C' command sort -n -r |
    command head -n "${1:-"$((LINES - 5))"}" |
    command column -c 3 -s ' ' -t |
    command nl
}
alias zsh_stats='history_stats'

identify() {

  # uname
  command uname -a

  # sw_vers
  # https://apple.stackexchange.com/a/368244
  command -v -- sw_vers >/dev/null 2>&1 &&
    command sw_vers

  # lsb_release
  # https://linuxize.com/post/how-to-check-your-debian-version
  command -v -- lsb_release >/dev/null 2>&1 &&
    command lsb_release --all

  # hostnamectl
  # https://linuxize.com/post/how-to-check-your-debian-version
  command -v -- hostnamectl >/dev/null 2>&1 &&
    command hostnamectl

  # /etc/os-release
  # https://linuxize.com/post/how-to-check-your-debian-version
  test -r /etc/os-release &&
    command cat /etc/os-release

  # /proc/version
  # https://superuser.com/a/773608
  test -r /proc/version &&
    command cat /proc/version

  # /etc/issue
  # https://linuxize.com/post/how-to-check-your-debian-version
  test -r /etc/issue &&
    command cat /etc/issue
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
elif test "$(command /bin/ls -G -- "${HOME-}" | command hexdump)" = "$(command ls -G -- "${HOME-}" | command hexdump)" &&
  test "$(command ls -G -- "${HOME-}" | command hexdump)" != "$(command ls --color=auto -- "${HOME-}" 2>/dev/null)"; then
  alias ls='command ls -G'
  alias l='command ls -A -F -G -g -o'
fi

# dotfiles
mu() {
  cd "${DOTFILES-}" ||
    return 1
  command -v -- cleanup >/dev/null 2>&1 &&
    cleanup "$@"
  case "${1-}" in
  -s | --short)
    command mackup backup --force --root
    command git fetch --all --prune
    command git submodule update --init
    command git status
    ;;
  *)
    command mackup backup --force --root --verbose
    command git fetch --all --prune --verbose
    command git submodule update --init --recursive
    command git submodule sync --recursive
    command git status
    ;;
  esac
}

# https://unix.stackexchange.com/a/30950
alias mv='command mv -v -i'

# find files with non-ASCII characters
non_ascii() {
  set -o nounset
  LC_ALL='C' command find -- . \
    ! -path '*/.git/*' \
    -name '*[! -~]*'
  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null
}

# paste faster
# https://github.com/zsh-users/zsh-autosuggestions/issues/238#issuecomment-389324292
pasteinit() {
  old_self_insert="${"${(s.:.)widgets[self-insert]}"[2,3]}"
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert "${old_self_insert-}"
}
zstyle :bracketed-paste-magic paste-init pasteinit 2>/dev/null
zstyle :bracketed-paste-magic paste-finish pastefinish 2>/dev/null

path_check() {
  # check that each directory in user `$PATH` still exists and is a directory

  # return verbose output if requested
  for argument in "$@"; do
    case "${argument-}" in

    # return verbose output if requested
    -v | --verbose)
      set -o xtrace
      shift
      ;;

    *)
      printf 'usage: %s [-v|--verbose]\n' "$(command basename -- "$0")"
      return 1
      ;;
    esac
  done

  for directory in $(
    # newline-delimited `$PATH` like Zsh `<<<${(F)path}`
    # https://stackoverflow.com/a/33469401
    printf %s "${PATH-}" |
      command xargs -d ':' -n 1
  ); do
    if test -d "${directory-}"; then
      printf 'is a directory: %s\n' "${directory-}"
    else
      printf 'not a directory: %s\n' "${directory-}"
    fi
  done

  # silently undo verbose output for everyone
  {
    set -o allexport
    set +o errexit
    set +o noclobber
    set +o nounset
    set +o verbose
    set +o xtrace
  } 2>/dev/null

  unset -- argument 2>/dev/null
  unset -- directory 2>/dev/null
}

# .plist
plist_r() {
  command -v -- plutil >/dev/null 2>&1 ||
    return 127
  case "$(command pwd -P)" in
  "${HOME-}" | "${DOTFILES-}")
    return 77
    ;;
  *)
    command find -- . \
      ! -path "${HOME-}"'/Library' \
      ! -path "${DOTFILES-}"'/Library' \
      ! -type l \
      ! -type d \
      -name '*.plist' \
      -print \
      -exec plutil -convert xml1 -- '{}' ';' \
      -exec sed -i -e 's|\t|  |g' -- '{}' ';' \
      -exec sed -E -i -e 's/^(  |<\/?dict)/  &/' -- '{}' ';'
    ;;
  esac
}

# PlistBuddy
test -x '/usr/libexec/PlistBuddy' &&
  # https://apple.stackexchange.com/a/414774
  alias plistbuddy='command /usr/libexec/PlistBuddy'

# Python
command -v -- python3 >/dev/null 2>&1 &&
  alias python='command python3' &&
  command -v -- pip3 >/dev/null 2>&1 &&
  alias pip='command pip3'

# $?
question_mark() {
  printf '%d\n' "$?"
}
alias '?'='question_mark'

# QuickLook
command -v -- qlmanage >/dev/null 2>&1 &&
  alias ql='command qlmanage -p 2>/dev/null'

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
      command xargs -0 "${utility-}"
    ;;
  *)
    command "${utility-}" "$@"
    ;;
  esac
  unset -- utility 2>/dev/null
}
alias rmo='rm --others'

# take: mkdir && cd
take() {
  # https://github.com/ohmyzsh/ohmyzsh/commit/7cba6bb
  for directory in "$@"; do
    if test ! -d "${directory-}"; then
      command mkdir -p -- "${directory-}"
      test -d "${directory-}" &&
        printf 'creating directory \342\200\230%s\342\200\231...\n' "${directory-}" ||
        return 1
    else
      printf 'directory \342\200\230%s\342\200\231 exists...\n' "${directory-}"
    fi
  done
  unset -- directory 2>/dev/null

  # POSIX-compliant `${@:$#}`-style string indexing (SC3057)
  # https://stackoverflow.com/a/1853993
  for directory in "$@"; do
    :
  done
  unset -- directory 2>/dev/null
}

# Unix epoch seconds
# https://stackoverflow.com/a/12312982
# date -j '+%s' # for milliseconds
unixtime() {
  command date '+%s' "$@"
}

alias all='which -a'

yamllint_r() {
  command -v -- yamllint >/dev/null 2>&1 ||
    return 1
  (
    unset -- PS4 2>/dev/null
    set -o nounset
    case "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" in
    true)
      {
        command git ls-files -z -- ./**/*.CFF
        command git ls-files -z -- ./**/*.YAML
        command git ls-files -z -- ./**/*.YML
        command git ls-files -z -- ./**/*.cff
        command git ls-files -z -- ./**/*.yaml
        command git ls-files -z -- ./**/*.yml
      } 2>/dev/null |
        command xargs -0 yamllint --strict
      ;;

    *)
      command find -- . \
        ! -path '*.git/*' \
        ! -path '*/Test*' \
        ! -path '*/t/*' \
        ! -path '*/test*' \
        ! -path '*node_modules/*' \
        ! -path '*vscode*' \
        '(' \
        -name '*.CFF*' -o \
        -name '*.YAML' -o \
        -name '*.YML' -o \
        -name '*.cff' -o \
        -name '*.yaml' -o \
        -name '*.yml' \
        ')' \
        -exec yamllint --strict -- '{}' '+'
      ;;
    esac
  )
}

# zero
# https://github.com/zdharma-continuum/Zsh-100-Commits-Club/blob/1f880d03ec/Zsh-Plugin-Standard.adoc#zero-handling
zero() {
  printf '0=\044{ZERO:-\044{\044{0:#\044ZSH_ARGZERO}:-\044{(\045):-\045N}}}'
  printf '\n'
  printf '0=\044{\044{(M)0:#/*}:-\044{PWD}/\0440}'
  printf '\n'
}

ohmyzsh() {
  cd -- "${ZSH-}" &&
    command git status
}
alias zshenv='command "${EDITOR:-vi}" -- "${HOME-}/.${SHELL##*[-./]}env"; . "${HOME-}/.${SHELL##*[-./]}rc" && exec -l -- "${SHELL##*[-./]}"'
alias zshrc='command "${EDITOR:-vi}" -- "${HOME-}/.${SHELL##*[-./]}rc"; . "${HOME-}/.${SHELL##*[-./]}rc" && exec -l -- "${SHELL##*[-./]}"'
