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
alias -- ,='exec -l -- "${SHELL:-sh}"'       # unnecessary pre-reset run-command reload
alias -- ,='exec -- - "${SHELL:-sh}"'        # Zsh-only           (but this generates `zsh` instead of `-zsh`)
alias -- ,='exec "${SHELL:-sh}" -l'          # any POSIX shell
alias -- ,='exec -l -- "${SHELL:-sh}"'       # Zsh or Bash (but in Zsh this generates `zsh` instead of `-zsh`)
alias -- ,='exec -l - "${${SHELL##*/}:-sh}"' # Zsh-only using `-` precommand modifier to generate `-zsh` instead of `zsh` and the `-l` is not required
alias -- ,='exec - "${${SHELL##*/}:-sh}"'    # Zsh-only using `-` precommand modifier to generate `-zsh` instead of `zsh`
alias -- ,='exec "${SHELL:-sh}"'             # portable
alias -- ,='exec - "${SHELL##*/}"'           # Zsh-only using `-` precommand modifier to generate `-zsh` instead of `zsh`, but POSIX parameter expansion
aliases() {
  set -- "${DOTFILES-}"'/custom/aliases.sh'
  command "${EDITOR:-vi}" -- "${1-}" &&
    command -v -- shfmt >/dev/null 2>&1 &&
    command shfmt --indent 2 --language-dialect bash --simplify --write -- "${1-}"
  # shellcheck disable=SC1090
  . "${1-}"
  command -v -- sc >/dev/null 2>&1 &&
    sc -- "${1-}"
  shift
}

## Adobe Acrobat
acrobat() {
  set \
    -o noclobber \
    -o noglob \
    -o nounset \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command -p -- open -a "$(
        (
          # /Applications/*/*/* instead of
          # /Applications/*/* because it’s possibly inside /Applications/Adobe Acrobat DC
          command -p -- find -- /Applications \
            -path '/Applications/*/*/*' -prune -o \
            -name 'Adobe Acrobat.app' \
            -type d \
            -exec ls -d -1 -t -- {} + 2>/dev/null \
            &
        ) |
          command -p -- sed \
            -n \
            -e '/1/ {' \
            -e '  s/^\/Applications\///' \
            -e '  s/\.app$//' \
            -e '}' \
            -e 'p'
      )" -- "${file-}"
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o nounset \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

awk_pretty() {
  command gawk \
    --no-optimize \
    --posix \
    --pretty-print=- \
    --sandbox \
    --use-lc-numeric \
    "${@-}" |
    command -p -- sed \
      -e ':a' \
      -e 'N' \
      -e '$! b a' \
      -e 's/\n{\n/ {\n/g' \
      -e 's/\t/  /g' \
      -e '/^$/ d' | {
    command bat \
      --language=awk \
      --paging=never \
      --style=plain \
      --wrap=never \
      -- \
      - 2>/dev/null ||
      command -p -- cat \
        -- \
        -
  }
}

base_to_base() {
  # https://stackoverflow.com/a/13280173
  command -p -- printf -- 'ibase=%s; obase=%s; %s\n' "${2:-10}" "${3:-10}" "$(
    command -p -- printf -- '%s' "${1-}" |
      LC_ALL='C' command -p -- tr -- '[:lower:]' '[:upper:]' |
      command -p -- sed -e 's/^0[BODX]//'
  )" | command -p -- bc
}
hexadecimal_to_decimal() {
  base_to_base "${1-}" 16 A
}
alias -- \
  hex2dec='hexadecimal_to_decimal' \
  hex_to_decimal='hexadecimal_to_decimal'
decimal_to_hexadecimal() {
  base_to_base "${1-}" A 16
}
alias -- dec2hex='decimal_to_hexadecimal'
octal_to_decimal() {
  base_to_base "${1-}" 8 A
}
alias -- oct2dec='octal_to_decimal'
decimal_to_octal() {
  base_to_base "${1-}" A 8
}
alias -- dec2oct='decimal_to_octal'
binary_to_decimal() {
  base_to_base "${1-}" 2 A
}
alias -- bin2dec='binary_to_decimal'
decimal_to_binary() {
  base_to_base "${1-}" A 2
}
alias -- dec2bin='decimal_to_binary'

basename_r() {
  for file in "${@-}"; do
    command -p -- printf -- '%s\n' "${file##*/}"
  done
}

bash_major_version() {
  # confirm Bash version is at least any given version (default: at least Bash 6)
  if command -p -- test "$(
    command bash --version |
      command -p -- sed \
        -e 's/^[^[:digit:]]*//' \
        -e 's/[^[:digit:]].*$//' \
        -e 'q'
  )" -lt "${1:-6}"; then
    command -p -- printf -- 'You will need to upgrade to version %d for full functionality.\n' "${1:-6}" >&2
    return 1
  fi
}

bash_pretty() {
  set \
    -o noclobber \
    -o noglob \
    -o nounset \
    -o verbose \
    -o xtrace

  # use this script to remove comments from shell scripts
  # and potentially find duplicate content

  for file in "${@-}"; do

    # ensure it is a non-zero-length file
    command -p -- test -s "${file-}" &&

      # ensure it is not a symlink
      command -p -- test ! -L "${file-}" &&

      # if it does not already have the obvious yet unlikely `.bash` filename extension
      # test 'file-without-bash-extension' = 'file-without-bash-extension' &&
      command -p -- test "${file-}" = "${file%.bash}" &&

      # if `bash --pretty-print` fails on the file, skip it
      # noting that `bash --pretty-print` prints to `stdout`
      # but since this part is a test, send both `stdout` and `stderr` to `/dev/null`
      command bash --pretty-print -- "${file-}" >/dev/null 2>&1 &&
      {
        # add the shell directive then the `bash --pretty-print` content
        command -p -- printf -- '#!/usr/bin/env sh\n\n%s\n' &&
          # add the shell directive then the `bash --pretty-print` content
          command bash --pretty-print -- "${file-}"

        # save `$file`'s interpolated content into a file called `$file.bash`
      } >"${file-}"'.bash' &&
      command -p -- test -x "${file-}" &&
      command -p -- chmod -- 755 "${file-}"'.bash'
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o nounset \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}
bash_pretty_overwrite() {
  LC_ALL='C' \
    IFS='' \
    command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -name '*.bash' \
    -type f \
    -exec sh -C -e -f -u -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command git mv --force --verbose -- "${1-}" "${1%.bash}"
' _ {} ';'
}

bitly() {
  for link in "${@-}"; do
    command curl \
      --data '{"bitlink_id":"bit.ly/'"${link-}"'"}' \
      --header 'Authorization: Bearer '"${BITLY_TOKEN-}" \
      --header 'Content-Type: application/json' \
      --url 'https://api-ssl.bitly.com/v4/expand'
  done
}

black_r() {
  command -v -- black >/dev/null 2>&1 ||
    return 127
  # https://github.com/psf/black/blob/b1d0601016/src/black/const.py
  command find -- . \
    '(' \
    -name '*.py' -o \
    -name '*.py3' -o \
    -name '*.pyi' -o \
    -name '*.ipynb' \
    ')' \
    -type f \
    -exec sh -c 'for file in "${@-}"; do
  command git ls-files --error-unmatch -- "${file-}" >/dev/null 2>&1 ||
    ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
    command black --preview --verbose -- "${file-}"
done' _ {} +
}

## braces
braces() {
  set \
    -o noglob \
    -o xtrace
  while command -p -- test "${#}" -gt 0; do
    command -p -- test -f "${1-}" &&
      command -p -- rm -f -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/'"${1##*/}" &&
      command -p -- cp -f -p -- "${1-}" "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/'"${1##*/}" &&
      # add braces to shell variables but do not even try with `awk` commands
      command sed \
        -e '# do not apply to awk content' \
        -e '/awk /! {' \
        -e '# replace uncommented ＄var/＄var[@] with "＄{var-}"/"＄{var[@]-}"' \
        -e 's/^\([^#]*\)\$\([a-zA-Z0-9_][a-zA-Z0-9_]*\(\[[^]]\{1,\}\]\)\{0,1\}\)/\1\${\2-}/g' \
        -e '# replace dollar-# with "dollar-{#}"' \
        -e '# TO DELETE superseded by next line s/[[:space:]][[:space:]]*"\{0,1\}\(\$\)\#-*"\{0,1\}[[:space:]][[:space:]]*/ "\1{#}" /g' \
        -e 's/[[:space:]][[:space:]]*"\{0,1\}\(\$\)\#-*"\{0,1\}/ "\1{#}"/g' \
        -e '}' \
        "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/'"${1##*/}" \
        >"${1-}" &&
      command -p -- rm -f -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/'"${1##*/}"
    shift
  done
  {
    set \
      +o noglob \
      +o xtrace
  } 2>/dev/null
}

browse() {
  set \
    -o xtrace
  command -p -- open -a "$(
    {
      set \
        +o xtrace
    } 2>/dev/null
    (
      command -p -- find -- /Applications \
        -path '/Applications/*/*' -prune -o \
        -name 'Brave*' \
        -type d \
        -exec ls -d -1 -t -- {} + 2>/dev/null \
        &
    ) |
      command -p -- sed \
        -n \
        -e '/1/ {' \
        -e '  s/^\/Applications\///' \
        -e '  s/\.app$//' \
        -e '}' \
        -e 'p'
  )" -- "${@-}"
  {
    set \
      +o xtrace
  } 2>/dev/null
}

# cargo
cargo_install() {
  # https://forge.rust-lang.org/infra/other-installation-methods.html#rustup
  set -- 'https://sh.rustup.rs' && {
    command curl \
      --fail \
      --show-error \
      --silent \
      --url "${1-}" ||
      command wget \
        --content-on-error \
        --hsts-file=/dev/null \
        --output-document=- \
        --quiet \
        -- \
        "${1-}"
  } |
    command -p -- sh -s -- --no-modify-path
}
alias -- install_cargo='cargo_install'
cargo_list() {
  command cargo install --list 2>/dev/null |
    command -p -- sed \
      -e 's/[[:space:]].*//' \
      -e '/^$/ d'
}

# prefer `bat` without line numbers for easier copying
# this includes `command` otherwise
# `bat` appears unprepared to accept filenames as arguments
alias -- bat >/dev/null 2>&1 &&
  unalias -- bat
command -v -- bat >/dev/null 2>&1 &&
  alias -- bat='command bat --decorations=never --paging=never' &&
  alias -- bats='bat --language=sh' &&
  command -v -- _bat >/dev/null 2>&1 &&
  compdef -- bats='bat'

## cd
# this construction:
# - skips printing the new directory
# - coerces Zsh into creating an alias named `-` without
#   tripping up BusyBox `alias`, which does not support `-`
alias -- 1='cd -- "${OLDPWD:--}"' -='cd -- "${OLDPWD:--}"'
alias -- 2='cd -- -2'
alias -- 3='cd -- -3'
alias -- 4='cd -- -4'
alias -- 5='cd -- -5'
alias -- 6='cd -- -6'
alias -- 7='cd -- -7'
alias -- 8='cd -- -8'
alias -- 9='cd -- -9'
alias -- ...='cd -- ../..'
alias -- ....='cd -- ../../..'
alias -- .....='cd -- ../../../..'
alias -- ......='cd -- ../../../../..'
alias -- .......='cd -- ../../../../../..'
alias -- ........='cd -- ../../../../../../..'
alias -- .........='cd -- ../../../../../../../..'

cdp() {
  cd_to="$(command -p -- pwd -P)"
  if command -p -- test "${PWD-}" != "${cd_to-}"; then
    command -p -- printf -- 'moving from \342\200\230%s\342\200\231\n' "${PWD-}"
    cd -- "${cd_to-}" || {
      command -p -- printf -- 'unable to perform this operation\n'
      return 1
    }
    command -p -- printf -- '       into \342\200\230%s\342\200\231\n' "${cd_to-}"
  else
    command -p -- printf -- 'already in unaliased directory '
    command -p -- printf -- '\342\200\230%s\342\200\231\n' "${PWD-}"
    return 1
  fi
  unset cd_to 2>/dev/null || cd_to=''
}

cdx_to_csv() {
  # https://web.archive.org/cdx/search/cdx?url=popkorn.it/*&output=json
  # https://claude.ai/chat/13791398-d210-48ba-904d-c529be5272c0
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "${file-}" in
      *.[Jj][Ss][Oo][Nn])
        command jq --raw-output '(.[0] | @csv), (.[1:] [] | @csv)' "${file-}" >"${file%.json}"'.csv'
        ;;
      *) ;;
      esac
  done
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

changelog_find_newest() {
  pwd="$(
    command git rev-parse --show-toplevel --path-format=relative | command -p -- sed -e '1 q' ||
      command git rev-parse --show-toplevel ||
      command find -- . -name '.git' -type d -exec dirname -- {} ';'
  )" 2>/dev/null ||
    return "${?:-1}"
  LC_ALL='C' command find -- "${pwd%/}" \
    -path "${pwd%/}"'/[Cc][Hh][Aa][Nn][Gg][Ee]*[Ll][Oo][Gg]*.[Mm]*[Dd]*' \
    -type f \
    -exec sh -c 'command git -P log --max-count=1 --pretty=tformat:'\''%at '\''"${1-}"' _ {} ';' |
    LC_ALL='C' command -p -- sort -n -r |
    command -p -- sed \
      -e 's/.*\///g' \
      -e 'q'
  unset pwd 2>/dev/null || pwd=''
}

# cheat
cheat() {
  command curl --show-error --silent --url 'https://cheat.sh/'"$(
    command -p -- printf -- '%s' "$*" |
      command -p -- sed -e 's/ /+/g'
  )"
}

checkbashisms_r() {
  find_shell_scripts | while IFS='' read -r -- file; do
    command checkbashisms --extra --force --lint --newline --posix "${file-}" 2>&1 |
      command -p -- sed \
        -e '# skip warnings about commands prepended by "command", which POSIX does allow' \
        -e '# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/command.html#tag_20_22_03' \
        -e '/warning.*command.*with option other than -p, -v or -V/ d'
  done
}

clang_r() {
  # https://news.ycombinator.com/item?id=35758898
  cc \
    -g3 \
    -Wall \
    -Wextra \
    -Wconversion \
    -Wdouble-promotion \
    -Wno-unused-parameter \
    -Wno-unused-function \
    -Wno-sign-conversion \
    -fsanitize=undefined \
    -fsanitize-trap \
    -fsanitize=integer \
    "${@-}"
}

clang_format() {

  command clang-format --version >/dev/null 2>&1 ||
    # EX_UNAVAILABLE
    return 69

  # permit arguments in any order
  # https://salsa.debian.org/debian/debianutils/blob/c2a1c435ef/savelog
  while getopts i:s:w: opt; do
    case "${opt-}" in
    i)
      export IndentWidth="${OPTARG-}"
      ;;
    s)
      export SpacesBeforeTrailingComments="${OPTARG-}"
      ;;
    w)
      export ColumnLimit="${OPTARG-}"
      ;;
    *)
      command -p -- printf -- 'only \140-i <indent width>\140, \140-s <spaces before trailing comments>\140, and \140-w <number of columns>\140 are supported\n' >&2
      return 1
      ;;
    esac
  done

  # permit `find` to have a narrower scope by parsing the rest of the arguments
  shift "$((OPTIND - 1))"

  # eligible filename extensions:
  # https://github.com/llvm/llvm-project/blob/92df59c83d/clang/lib/Driver/Types.cpp#L295-L355
  # https://github.com/llvm/llvm-project/blob/81f0f5a0e5/clang/lib/Frontend/FrontendOptions.cpp#L17-L35
  # https://github.com/llvm/llvm-project/blob/e20a1e486e/clang/tools/clang-format-vs/ClangFormat/ClangFormatPackage.cs#L41-L42
  # https://github.com/llvm/llvm-project/blob/cea81e95b0/clang/tools/clang-format/git-clang-format#L78-L90
  # https://github.com/llvm/llvm-project/blob/cea81e95b0/clang/tools/clang-format/clang-format-diff.py#L50-L51

  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.rbenv' -prune -o \
    -path '*/.venv' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/__pycache__' -prune -o \
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
    -name '*.[Aa][Dd][Aa]' -o \
    -name '*.[Aa][Dd][Bb]' -o \
    -name '*.[Aa][Dd][Ss]' -o \
    -name '*.[Aa][Ss][Mm]' -o \
    -name '*.[Aa][Ss][Tt]' -o \
    -name '*.[Bb][Cc]' -o \
    -name '*.[Cc]' -o \
    -name '*.[Cc].[Ii][Nn]' -o \
    -name '*.[Cc][Aa][Kk][Ee]' -o \
    -name '*.[Cc][Aa][Tt][Ss]' -o \
    -name '*.[Cc][Cc]' -o \
    -name '*.[Cc][Cc].[Ii][Nn]' -o \
    -name '*.[Cc][Cc][Mm]' -o \
    -name '*.[Cc][Ll]' -o \
    -name '*.[Cc][Ll][Cc][Pp][Pp]' -o \
    -name '*.[Cc][Pp]' -o \
    -name '*.[Cc][Pp][Pp]' -o \
    -name '*.[Cc][Pp][Pp].[Ii][Nn]' -o \
    -name '*.[Cc][Pp][Pp][Mm]' -o \
    -name '*.[Cc][Ss]' -o \
    -name '*.[Cc][Ss][Xx]' -o \
    -name '*.[Cc][Tt][Ss]' -o \
    -name '*.[Cc][Uu]' -o \
    -name '*.[Cc][Uu][Hh]' -o \
    -name '*.[Cc][Uu][Ii]' -o \
    -name '*.[Cc][Xx][Xx]' -o \
    -name '*.[Cc][Xx][Xx].[Ii][Nn]' -o \
    -name '*.[Cc][Xx][Xx][Mm]' -o \
    -name '*.[Cc]++' -o \
    -name '*.[Cc]++[Mm]' -o \
    -name '*.[Ee][Cc]' -o \
    -name '*.[Ee][Cc][Pp]' -o \
    -name '*.[Ee][Dd][Cc]' -o \
    -name '*.[Ff]' -o \
    -name '*.[Ff][Oo][Rr]' -o \
    -name '*.[Ff][Pp][Pp]' -o \
    -name '*.[Ff]03' -o \
    -name '*.[Ff]08' -o \
    -name '*.[Ff]77' -o \
    -name '*.[Ff]90' -o \
    -name '*.[Ff]95' -o \
    -name '*.[Gg][Cc][Hh]' -o \
    -name '*.[Gg][Mm][Ll]' -o \
    -name '*.[Hh]' -o \
    -name '*.[Hh].[Ii][Nn]' -o \
    -name '*.[Hh][Hh]' -o \
    -name '*.[Hh][Hh].[Ii][Nn]' -o \
    -name '*.[Hh][Ii][Pp]' -o \
    -name '*.[Hh][Ll][Ss][Ll]' -o \
    -name '*.[Hh][Pp]' -o \
    -name '*.[Hh][Pp][Pp]' -o \
    -name '*.[Hh][Pp][Pp].[Ii][Nn]' -o \
    -name '*.[Hh][Xx][Xx]' -o \
    -name '*.[Hh][Xx][Xx].[Ii][Nn]' -o \
    -name '*.[Hh]++' -o \
    -name '*.[Ii]' -o \
    -name '*.[Ii][Dd][Cc]' -o \
    -name '*.[Ii][Ff][Ss]' -o \
    -name '*.[Ii][Ii]' -o \
    -name '*.[Ii][Ii][Hh]' -o \
    -name '*.[Ii][Ii][Mm]' -o \
    -name '*.[Ii][Nn][Cc]' -o \
    -name '*.[Ii][Nn][Ll]' -o \
    -name '*.[Ii][Nn][Oo]' -o \
    -name '*.[Ii][Pp][Pp]' -o \
    -name '*.[Ii][Xx][Xx]' -o \
    -name '*.[Jj][Aa][Vv]' -o \
    -name '*.[Jj][Aa][Vv][Aa]' -o \
    -name '*.[Jj][Ss][Hh]' -o \
    -name '*.[Ll][Ii][Bb]' -o \
    -name '*.[Ll][Ii][Nn][Qq]' -o \
    -name '*.[Ll][Ll]' -o \
    -name '*.[Mm]' -o \
    -name '*.[Mm][Ee][Tt][Aa][Ll]' -o \
    -name '*.[Mm][Ii]' -o \
    -name '*.[Mm][Ii][Ii]' -o \
    -name '*.[Mm][Mm]' -o \
    -name '*.[Mm][Tt][Ss]' -o \
    -name '*.[Nn][Uu][Tt]' -o \
    -name '*.[Pp][Cc][Cc]' -o \
    -name '*.[Pp][Cc][Hh]' -o \
    -name '*.[Pp][Cc][Mm]' -o \
    -name '*.[Pp][Ff][Oo]' -o \
    -name '*.[Pp][Gg][Cc]' -o \
    -name '*.[Pp][Rr][Oo][Tt][Oo][Dd][Ee][Vv][Ee][Ll]' -o \
    -name '*.[Rr][Ee]' -o \
    -name '*.[Ss]' -o \
    -name '*.[Tt][Cc][Cc]' -o \
    -name '*.[Tt][Dd]' -o \
    -name '*.[Tt][Ll][Hh]' -o \
    -name '*.[Tt][Ll][Ii]' -o \
    -name '*.[Tt][Pp][Pp]' -o \
    -name '*.[Tt][Ss]' -o \
    -name '*.[Tt][Ss][Xx]' -o \
    -name '*.[Tt][Xx][Xx]' -o \
    -name '*.[Xx][Bb][Mm]' -o \
    -name '*.[Xx][Pp][Mm]' \
    ')' \
    -type f \
    -exec sh -c 'for file in "${@-}"; do ! command -p -- grep -e '\''^#!.*sh'\'' -e '\''moderni.*sh'\'' -- "${file-}" >/dev/null 2>&1 && command git ls-files --error-unmatch -- "${file-}" >/dev/null 2>&1 || ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 && command clang-format -i --style "{ColumnLimit: ${ColumnLimit:-79}, IndentWidth: ${IndentWidth:-2}, SpacesBeforeTrailingComments: ${SpacesBeforeTrailingComments:-2}}" --verbose -- "${file-}"; done' _ {} + 2>&1 |
    command -p -- sed \
      -e 's/ \[1\/1\]//' >&2
  unset ColumnLimit 2>/dev/null || ColumnLimit=''
  unset IndentWidth 2>/dev/null || IndentWidth=''
  unset SpacesBeforeTrailingComments 2>/dev/null || SpacesBeforeTrailingComments=''
}
alias -- clang_format_r='clang_format -i 2 -s 2 -w "$(command -p -- getconf -- UINT_MAX)"'

cleanup() {
  # this function is POSIX in an obnoxiously pedantic way and must never be used
  set \
    -o xtrace

  if command -p -- test -d "${HOME%/}"'/.Trash'; then
    target="${HOME%/}"'/.Trash'
  elif command -p -- mkdir -p -- "${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash' 2>/dev/null; then
    target="${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash'
  elif command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/.Trash' 2>/dev/null; then
    target="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/.Trash'
  else
    # EX_CANTCREAT
    return 73
  fi
  export target

  # refuse to run from `/`
  command -p -- test "$(command -p -- pwd -P)" = '/' ||
    # or from `$HOME`
    command -p -- test "$(command -p -- pwd -P)" = "${HOME%/}" ||
    # or from any titlecase-named directory just below `$HOME`
    # such the closed set of macOS standard directories:
    # `Applications`, `Desktop`, `Documents`, `Downloads`, `Library`, `Movies`, `Music`, `Pictures`, `Public`, and `Sites`
    # https://web.archive.org/web/0id_/developer.apple.com/library/mac/documentation/FileManagement/Conceptual/FileSystemProgrammingGUide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW9
    command -p -- test "${PWD%/*}" = "${HOME%/}" &&
    case "$(
      command -p -- pwd -P |
        command -p -- sed \
          -e 's/.*\/[[:space:]]*//'
    )" in
    [[:upper:]]*)
      command -p -- printf -- '\n\n' >&2
      command -p -- printf -- '\342\233\224\357\270\217 aborting: refusing to run from a macOS standard directory\n' >&2
      command -p -- printf -- '\n\n' >&2
      set \
        +o verbose
      # EX_NOPERM
      return 77
      ;;
    *)
      # permit running from non-titlecase-named directories in `$HOME`
      ;;
    esac

  set \
    -o xtrace
  now="$(command -p -- date -- '+%Y%m%d%H%M%S')" &&
    export now

  # delete thumbnail cache files
  dss "${@-}"

  # delete crufty Zsh files
  # if `$ZSH_COMPDUMP` always generates a crufty file then skip, but
  # if it’s not set then still perform the check
  # https://stackoverflow.com/a/8811800
  if command -p -- test "${ZSH_COMPDUMP-}" = '' || {
    command -p -- test ! "${ZSH_COMPDUMP-}" != "${ZSH_COMPDUMP#*'zcompdump-'}" &&
      command -p -- test ! "${ZSH_COMPDUMP-}" != "${ZSH_COMPDUMP#*'zcompdump.'}"
  }; then
    # the first prune should mean that the Library line is unnecessary, but that is not the case ¯\_(ツ)_/¯
    # so it appears that all find commands should prune at least both `*/.git` and `*/Library`
    while command -p -- test "$(
      command find -- "${ZDOTDIR:-${HOME%/}}" \
        -xdev \
        -path '*/.git' -prune -o \
        -path '*/Library' -prune -o \
        -path '*/node_modules' -prune -o \
        -path "${ZDOTDIR:-${HOME%/}}"'/*/*' -prune -o \
        -name '.zcompdump' -prune -o \
        -name '.zcompdump*' \
        -type f \
        -print
    )" != ''; do
      command find -- "${ZDOTDIR:-${HOME%/}}" \
        -xdev \
        -path '*/.git' -prune -o \
        -path '*/Library' -prune -o \
        -path '*/node_modules' -prune -o \
        -path "${ZDOTDIR:-${HOME%/}}"'/*/*' -prune -o \
        -name '.zcompdump' -prune -o \
        -name '.zcompdump*' \
        -type f \
        -exec sh -c 'command -p -- rm -f -- "${1-}"' _ {} ';'
    done
  fi

  # delete empty files except
  # those with specific names
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.rbenv' -prune -o \
    -path '*/.venv' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/__pycache__' -prune -o \
    -path '*/Library' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/t' -prune -o \
    -path '*/Test*' -prune -o \
    -path '*/test*' -prune -o \
    -path '*/themes' -prune -o \
    -path '*/tst*' -prune -o \
    -path '*/venv' -prune -o \
    -path '*copilot*' -prune -o \
    -path '*dummy*' -prune -o \
    -path '*invalid*' -prune -o \
    -path '*vscode*' -prune -o \
    ! -name "$(command -p -- printf -- 'Icon\015\012')" \
    ! -name '*.plugin.*sh' \
    ! -name '*Empty*' \
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
    ! -name '.hushlogin' \
    ! -name '.keep' \
    ! -name '.keep_me' \
    ! -name '.keepme' \
    ! -name '.nojekyll' \
    ! -name '.sudo_as_admin_successful' \
    ! -name '.watchmanconfig' \
    ! -name '__init__.py' \
    ! -name 'favicon.*' \
    ! -name 'README*' \
    -size 0 \
    -type f \
    -print \
    -exec sh -C -f -u -x -c 'command -p -- test "$(command git -C "${1%/*}" rev-parse --show-superproject-working-tree)" = '\'''\'' ||
  command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command -p -- mkdir -p -- "${target%/}/${1%/*}_${now-}" &&
  command -p -- mv -v -- "${1-}" "${target%/}/${1%/*}_${now-}/${1##*/}"
' _ {} ';'

  # delete empty directories
  # but skip certain directories
  while LC_ALL='C' IFS='' command -p -- test "$(
    LC_ALL='C' IFS='' command find -- . \
      -path '*/.git' -prune -o \
      -path '*/Library' -prune -o \
      -path '*/node_modules' -prune -o \
      -path './*' \
      -type d \
      -exec sh -c 'for directory in "${@-}"; do command -p -- test "$(command -p -- find -- "${directory-}" -path "${directory-}"'\''/*'\'' -print)" = '\'''\'' && command -p -- printf -- '\''%s\n'\'' "${directory-}"; done' _ {} +
  )" != ''; do
    LC_ALL='C' IFS='' command -p -- find -- . \
      -path '*/.git' -prune -o \
      -path '*/Library' -prune -o \
      -path '*/node_modules' -prune -o \
      -path './*' \
      -type d \
      -links 2 \
      -print \
      -exec rmdir -p -- {} +
  done

  # swap each tab for two spaces each in gitconfig files
  (
    set \
      -o noglob
    ###    command -p -- rm -f -r -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp' &&
    ###    command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp' &&
    {
      command find -- \
        "${XDG_CONFIG_HOME-}"'/git/config' \
        "${HOME%/}"'/.config/git/config' \
        "${DOTFILES-}"'/.config/git/config' \
        "${HOME%/}"'/.gitconfig' \
        "${DOTFILES-}"'/.gitconfig' \
        "${GIT_DIR:-./.git}"'/config' \
        "${GIT_DIR:-./.git}"'/config.worktree' \
        ! -size 0 \
        -type f \
        -print || command -p -- true
    } 2>/dev/null | while IFS='' read -r -- file; do
      # if command -p -- test -s "${file-}" && command -p -- cp -f -p -- "${file-}" "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}"; then
      #   command -p -- sed -e 's/\t/  /g' "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" >"${file-}"
      # fi

      #
      ##
      ###
      ####
      ###     command -p -- test -s "${file-}" &&
      ###     command -p -- test ! -L "${file-}" &&
      ###       command -p -- grep -v -e 'bplist' -- "${file-}" >/dev/null 2>&1 &&
      ###       LC_ALL='C' command -p -- file -- "${file-}" |
      ###       command -p -- grep -v -e 'binary' >/dev/null 2>&1 &&
      command -p -- ed -s -- "${file-}" <<EOF
1,\$ s/	/  /g
w
q
EOF
      ####
      ###
      ##
      #
    done |
      # suppress `ed` question mark-only lines
      command -p -- sed \
        -e '/^?$/ d'
  )

  # remove Git sample hooks and Dropbox pollution from `.git/` directories
  command find -- . \
    -path '*/.git/*' \
    '(' \
    -name '._*' -o \
    -name '* conflicted copy *'because_you_probs_do_want_these_instead_of_Dropbox -o \
    -path '*/hooks/*.sample' \
    ')' \
    -type f \
    -print \
    -delete
  command find -- . \
    -path '*/.git/*' \
    -name 'description' \
    -type f \
    '(' \
    -size '73c' -o \
    -size '88c' \
    ')' \
    -exec sh -x -c 'case "$(command -p -- cksum -- "${1-}" | command -p -- sed -e '\''s/ 73 .*//'\'' -e '\''s/ 88 .*//'\'' )" in 1558055404|76865375) command -p -- printf -- '\''%s\n'\'' "${1-}" && command -p -- rm -- "${1-}" ;; *) ;; esac' _ {} ';'
  command find -- . \
    -path '*/.git/info/*' \
    -name 'exclude' \
    -type f \
    -size '240c' \
    -exec sh -x -c 'command -p -- test "$(command -p -- cksum -- "${1-}" | command -p -- sed -e '\''s/ 240 .*//'\'')" -eq 684386549 && command -p -- printf -- '\''%s\n'\'' "${1-}" && command -p -- rm -- "${1-}"' _ {} ';'
  command find -- . \
    -path '*/.git/*' \
    -path '*.gitstatus.*' \
    -type d \
    -print \
    -exec rmdir -- {} + 2>/dev/null || # `rmdir` does not delete non-empty directories
    command -p -- true

  {
    set \
      +o xtrace
  } 2>/dev/null
  unset file 2>/dev/null || file=''
  unset now 2>/dev/null || now=''
  unset target 2>/dev/null || target=''
}

# codesign
codesign_r() {
  set \
    -o xtrace
  command codesign --deep --force --options runtime --timestamp --verbose --options runtime --sign "$(
    command security find-identity -v -p codesigning |
      command -p -- sed \
        -e 's/.*\([[:xdigit:]]\{40\}\).*/\1/' \
        -e 'q'
  )" "${@-}"
  {
    set \
      +o xtrace
  } 2>/dev/null
}

cpplint_filename_extensions() {
  # valid filename extensions
  # from 2019-12 until at least 2022-05
  {
    # https://github.com/cpplint/cpplint/blob/2cba6ce8df/cpplint.py#L939
    command -p -- printf -- 'h hh hpp hxx h++ cuh\n'
    # https://github.com/cpplint/cpplint/blob/2cba6ce8df/cpplint.py#L945
    command -p -- printf -- 'c cc cpp cxx c++ cu\n'
    # using uppercase filename extensions only where `clang-format` does
    command -p -- printf -- 'C c c++ CC cc CPP cpp cu cuh CXX cxx H h h++ hh hpp hxx\n'
    # https://github.com/BurntSushi/ripgrep/blob/0bc4f0447b/ignore/src/default_types.rs#L37-L40 2023-07
    command -p -- printf -- 'cpp hpp cxx hxx hh inl C.in h.in H.in cpp.in hpp.in cxx.in hxx.in hh.in\n'
  } |
    command -p -- tr -s -- '[:space:]' '\n' |
    LC_ALL='C' command -p -- sort -u |
    LC_ALL='C' command -p -- sort -f
}
cpplint_r() {
  PS4=' ' command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.rbenv' -prune -o \
    -path '*/.venv' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/__pycache__' -prune -o \
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
    -name '*.cpp' -o \
    -name '*.[Aa][Dd][Aa]' -o \
    -name '*.[Aa][Dd][Bb]' -o \
    -name '*.[Aa][Dd][Ss]' -o \
    -name '*.[Aa][Ss][Mm]' -o \
    -name '*.[Aa][Ss][Tt]' -o \
    -name '*.[Bb][Cc]' -o \
    -name '*.[Cc]' -o \
    -name '*.[Cc].[Ii][Nn]' -o \
    -name '*.[Cc][Aa][Kk][Ee]' -o \
    -name '*.[Cc][Aa][Tt][Ss]' -o \
    -name '*.[Cc][Cc]' -o \
    -name '*.[Cc][Cc].[Ii][Nn]' -o \
    -name '*.[Cc][Cc][Mm]' -o \
    -name '*.[Cc][Ll]' -o \
    -name '*.[Cc][Ll][Cc][Pp][Pp]' -o \
    -name '*.[Cc][Pp]' -o \
    -name '*.[Cc][Pp][Pp]' -o \
    -name '*.[Cc][Pp][Pp].[Ii][Nn]' -o \
    -name '*.[Cc][Pp][Pp][Mm]' -o \
    -name '*.[Cc][Ss]' -o \
    -name '*.[Cc][Ss][Xx]' -o \
    -name '*.[Cc][Tt][Ss]' -o \
    -name '*.[Cc][Uu]' -o \
    -name '*.[Cc][Uu][Hh]' -o \
    -name '*.[Cc][Uu][Ii]' -o \
    -name '*.[Cc][Xx][Xx]' -o \
    -name '*.[Cc][Xx][Xx].[Ii][Nn]' -o \
    -name '*.[Cc][Xx][Xx][Mm]' -o \
    -name '*.[Cc]++' -o \
    -name '*.[Cc]++[Mm]' -o \
    -name '*.[Ee][Cc]' -o \
    -name '*.[Ee][Cc][Pp]' -o \
    -name '*.[Ee][Dd][Cc]' -o \
    -name '*.[Ff]' -o \
    -name '*.[Ff][Oo][Rr]' -o \
    -name '*.[Ff][Pp][Pp]' -o \
    -name '*.[Ff]03' -o \
    -name '*.[Ff]08' -o \
    -name '*.[Ff]77' -o \
    -name '*.[Ff]90' -o \
    -name '*.[Ff]95' -o \
    -name '*.[Gg][Cc][Hh]' -o \
    -name '*.[Gg][Mm][Ll]' -o \
    -name '*.[Hh]' -o \
    -name '*.[Hh].[Ii][Nn]' -o \
    -name '*.[Hh][Hh]' -o \
    -name '*.[Hh][Hh].[Ii][Nn]' -o \
    -name '*.[Hh][Ii][Pp]' -o \
    -name '*.[Hh][Ll][Ss][Ll]' -o \
    -name '*.[Hh][Pp]' -o \
    -name '*.[Hh][Pp][Pp]' -o \
    -name '*.[Hh][Pp][Pp].[Ii][Nn]' -o \
    -name '*.[Hh][Xx][Xx]' -o \
    -name '*.[Hh][Xx][Xx].[Ii][Nn]' -o \
    -name '*.[Hh]++' -o \
    -name '*.[Ii]' -o \
    -name '*.[Ii][Dd][Cc]' -o \
    -name '*.[Ii][Ff][Ss]' -o \
    -name '*.[Ii][Ii]' -o \
    -name '*.[Ii][Ii][Hh]' -o \
    -name '*.[Ii][Ii][Mm]' -o \
    -name '*.[Ii][Nn][Cc]' -o \
    -name '*.[Ii][Nn][Ll]' -o \
    -name '*.[Ii][Nn][Oo]' -o \
    -name '*.[Ii][Pp][Pp]' -o \
    -name '*.[Ii][Xx][Xx]' -o \
    -name '*.[Jj][Aa][Vv]' -o \
    -name '*.[Jj][Aa][Vv][Aa]' -o \
    -name '*.[Jj][Ss][Hh]' -o \
    -name '*.[Ll][Ii][Bb]' -o \
    -name '*.[Ll][Ii][Nn][Qq]' -o \
    -name '*.[Ll][Ll]' -o \
    -name '*.[Mm]' -o \
    -name '*.[Mm][Ee][Tt][Aa][Ll]' -o \
    -name '*.[Mm][Ii]' -o \
    -name '*.[Mm][Ii][Ii]' -o \
    -name '*.[Mm][Mm]' -o \
    -name '*.[Mm][Tt][Ss]' -o \
    -name '*.[Nn][Uu][Tt]' -o \
    -name '*.[Pp][Cc][Cc]' -o \
    -name '*.[Pp][Cc][Hh]' -o \
    -name '*.[Pp][Cc][Mm]' -o \
    -name '*.[Pp][Ff][Oo]' -o \
    -name '*.[Pp][Gg][Cc]' -o \
    -name '*.[Pp][Rr][Oo][Tt][Oo][Dd][Ee][Vv][Ee][Ll]' -o \
    -name '*.[Rr][Ee]' -o \
    -name '*.[Ss]' -o \
    -name '*.[Tt][Cc][Cc]' -o \
    -name '*.[Tt][Dd]' -o \
    -name '*.[Tt][Ll][Hh]' -o \
    -name '*.[Tt][Ll][Ii]' -o \
    -name '*.[Tt][Pp][Pp]' -o \
    -name '*.[Tt][Ss]' -o \
    -name '*.[Tt][Ss][Xx]' -o \
    -name '*.[Tt][Xx][Xx]' -o \
    -name '*.[Xx][Bb][Mm]' -o \
    -name '*.[Xx][Pp][Mm]' \
    ')' \
    -type f \
    -exec sh -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command cpplint --counting=detailed --verbose=0 --filter=-legal/copyright -- "${1-}"
' _ {} ';' 2>&1
}

# copy repository boilerplate files
cy() {
  set \
    -o verbose \
    -o xtrace
  command -p -- test -d "${DOTFILES-}" ||
    command -p -- test -d "${TEMPLATE-}" ||
    command -p -- test -d "${_GITHUB-}" ||
    return 1

  target="$(
    command git rev-parse --show-toplevel --path-format=relative 2>/dev/null | command -p -- sed -e '1 q' ||
      command git rev-parse --show-toplevel 2>/dev/null ||
      command -p -- pwd -L
  )" ||
    return 1

  for file in \
    "${DOTFILES-}"'/.github' \
    "${TEMPLATE-}"'/.github' \
    "${_GITHUB-}"'/.github' \
    "${TEMPLATE-}"'/.gitlab-ci.yml' \
    "${TEMPLATE-}"'/.imgbotconfig' \
    "${TEMPLATE-}"'/.whitesource' \
    "${TEMPLATE-}"'/citation.cff' \
    "${TEMPLATE-}"'/renovate.json'; do
    case "${file-}" in
    */funding.yml | */code_of_conduct.md | */this_does_dot_work_because_we_are_requesting_a_directory_then_requesting_this_file)
      shift 1
      ;;
    *)
      command -p -- test -r "${file-}" &&
        # -L to follow symbolic links
        # -R to copy recursively (not `-r`)
        command -p -- cp -L -R -p -- "${file-}" "${target-}"
      ;;
    esac
  done
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
  unset target 2>/dev/null || target=''
}

# number of files
# this directory and below
count_files() {
  # https://unix.stackexchange.com/a/1126
  command find -- .//. \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    ! -name '.DS_Store' \
    ! -type d \
    -print |
    command -p -- grep \
      -c \
      -e '//'
}

count_files_and_directories() {
  # -path './/./*' is POSIX mindepth=1 when searching
  # nonstandard directory `.//.`
  command -p -- find -- .//. \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './/./*' \
    ! -name '.DS_Store' \
    -print |
    command -p -- grep \
      -c \
      -e '//'
}

count_files_by_extension() {
  # files with extensions
  # skip files:
  #   with no extension
  #   with a trailing dot
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    -name '*.*' \
    ! -name '*.' \
    ! -name '.DS_Store' \
    ! -type d \
    -exec sh -c 'for file in "${@-}"; do command -p -- printf -- '\''%s\n'\'' "${file##*.}"; done' _ {} + |
    LC_ALL='C' command -p -- sort |
    command -p -- uniq -c |
    LC_ALL='C' command -p -- sort -n

  # files with no extension
  # - https://github.com/super-linter/super-linter/commit/4faa6433ab
  # - https://github.com/super-linter/super-linter/pull/1640
  # - https://github.com/super-linter/super-linter/pull/1536
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    ! -name '*.*' \
    ! -type d \
    -print 2>/dev/null |
    # these steps ensure the output format conforms with the count of files WITH extensions
    command -p -- awk -- '{print ""}' |
    LC_ALL='C' command -p -- uniq -c |
    command -p -- sed \
      -e 's/.$/ [no extension]/'
}
alias -- cfx='count_files_by_extension'

# number of files
# in current directory
count_files_in_this_directory() {
  case "${1-}" in
  # count files as well as directories
  -d | --directory | --directories)
    command find -- . \
      -path './*/*' -prune -o \
      ! -name '.DS_Store' \
      -print |
      command -p -- grep \
        -c \
        -e '/'
    ;;

  # count only regular, non-directory files
  *)
    # https://unix.stackexchange.com/a/1126
    command find -- . \
      -path './*/*' -prune -o \
      ! -name '.DS_Store' \
      ! -type d \
      -print |
      command -p -- grep \
        -c \
        -e '/'
    ;;
  esac
}

curl_brew() {
  # https://github.com/Homebrew/install/issues/737#issuecomment-1433428464
  command curl \
    --disable \
    --fail \
    --compressed \
    --speed-limit 100 \
    --speed-limit 5 \
    --location \
    --remote-name \
    --url "${@-}"
}

datauri() {
  # create a data URI from a file
  # https://github.com/mathiasbynens/dotfiles/commit/5d76fc286f
  mime_type="$(command file -b --mime-type -- "${1-}")"
  case "${mime_type-}" in
  text/*)
    mime_type="${mime_type-}"'; charset=utf-8'
    ;;
  *) ;;
  esac
  command -p -- uuencode -m -- "${1-}" /dev/stdout |
    command -p -- sed \
      -e '1 d' \
      -e '$ d' |
    command -p -- sed \
      -e ':a' \
      -e 'N' \
      -e '$! b a' \
      -e 's/\n//g' |
    command awk -vmime_type="${mime_type-}" -- '{printf "data:%s;base64,%s\n", mime_type, $0}' -
  unset mime_type 2>/dev/null || mime_type=''
}
alias -- dataurl='datauri'

# define
alias -- d >/dev/null 2>&1 &&
  unalias -- d
command -v -- _which >/dev/null 2>&1 &&
  compdef -- define='which' &&
  compdef -- d='define'
define() {
  for query in "${@:-define}"; do

    case "${query-}" in
    --)
      shift
      ;;

    *)
      # # `hash` (POSIX)
      # command -p -- printf -- 'hash:\n%d\n' "$(
      #   command -p -- hash -- "${query-}" >/dev/null 2>&1
      #   command -p -- printf -- '%d\n' "${?:-1}"
      # )"

      # `type` (System V; POSIX)
      command -p -- test "$(command -p -- type -- "${query-}" 2>/dev/null)" != '' &&
        command -p -- printf -- 'type:\n%s\n' "$(
          command -p -- type -- "${query-}"
        )"

      # `command -V` (POSIX)
      command -p -- test "$(command -V -- "${query-}" 2>/dev/null)" != "$(command -p -- printf -- '%s not found' "${query-}")" &&
        command -p -- printf -- '———\ncommand -V:\n%s\n' "$(
          command -V -- "${query-}"
        )"

      # `command -v` (POSIX)
      command -p -- test "$(command -v -- "${query-}")" != '' &&
        command -p -- printf -- '———\ncommand -v:\n%s\n' "$(
          command -v -- "${query-}"
        )"

      # `which` (C shell)
      command -p -- test "$(command -p -- which -a -- "${query-}" 2>/dev/null)" != '' &&
        command -p -- printf -- '———\nwhich -a:\n%s\n' "$(
          command -p -- which -a -- "${query-}"
        )"

      {
        # shellcheck disable=SC3044
        # `functions | bash | shfmt`
        if builtin declare -f -- "${query-}" >/dev/null 2>&1 &&
          command bash --pretty-print -- "${query-}" >/dev/null 2>&1 &&
          command shfmt -- "${query-}" >/dev/null 2>&1; then
          builtin declare -f -- "${query-}" |
            command bash --pretty-print |
            command -p -- sed \
              -e 's/\&\& /\&\&\n/g' \
              -e 's/\|\| /||\n/g' \
              -e '# these expressions are escaped on the search (that is, ˋs/\&\&...ˋ and ˋs/\|\|...ˋ instead of ˋs/&&...ˋ and ˋs/||...ˋ) so that ˋdefine defineˋ will not insert newlines into the presentation of the sed expressions. For the ampersands, the replacement string requires escaping or will print both the search then the replacement (ˋ&& &&\nˋ instead of ˋ&&\nˋ)' |
            command shfmt --indent 2 --language-dialect bash --simplify -- -

        # `functions | shfmt`
        elif builtin declare -f -- "${query-}" >/dev/null 2>&1 |
          command -p -- sed \
            -e 's/\&\& /\&\&\n/g' \
            -e 's/\|\| /||\n/g' |
          command shfmt >/dev/null 2>&1; then
          builtin declare -f -- "${query-}" |
            command -p -- sed \
              -e 's/\&\& /\&\&\n/g' \
              -e 's/\|\| /||\n/g' \
              -e '# these expressions are escaped on the search (that is, ˋs/\&\&...ˋ and ˋs/\|\|...ˋ instead of ˋs/&&...ˋ and ˋs/||...ˋ) so that ˋdefine defineˋ will not insert newlines into the presentation of the sed expressions. For the ampersands, the replacement string requires escaping or will print both the search then the replacement (ˋ&& &&\nˋ instead of ˋ&&\nˋ)' |
            command shfmt --indent 2 --language-dialect bash --simplify -- -

        # `functions -x2`
        # because in Zsh,
        # `declare -f`     = `functions`, but
        # `declare -f -x` != `functions -x`
        elif builtin functions -x 2 -- "${query-}" >/dev/null 2>&1; then
          builtin functions -x 2 -- "${query-}"

        # `functions`
        elif builtin declare -f -- "${query-}" >/dev/null 2>&1; then
          builtin declare -f -- "${query-}"

        fi

      } |
        command -p -- sed \
          -e '# find single spaces between single quotes, replace with newline and indent' \
          -e 's/'\'' '\''\([[:alnum:]]*sh[^[:space:]]*\)/'\''\n          '\''\1/g' \
          -e '# also move the first shell to be called onto its own indented line' \
          -e 's/" '\''zsh/"\n          '\''zsh/' | {
        command bat \
          --color=auto \
          --decorations=never \
          --language=sh \
          --paging=never \
          - 2>/dev/null ||
          command -p -- cat \
            -- \
            -
      }
      ;;
    esac
  done
}
alias -- d='define'

alias -- diff >/dev/null 2>&1 &&
  unalias -- diff
alias -- diff='command git -c core.quotePath=false diff --color-words --no-index'
diffy() {
  command diff \
    --side-by-side \
    --suppress-common-lines \
    --width="$((COLUMNS / 2 - 1 + COLUMNS / 2 - 1))" \
    "${@-}"
}
compdef -- diffy='diff' 2>/dev/null || command -p -- true
diff_exif() {
  set \
    -o noclobber \
    -o noglob \
    -o nounset \
    -o verbose \
    -o xtrace
  set -- "${1-}" "${2-}" "${XDG_CACHE_HOME:-${HOME%/}/.cache}"'/tmp/diff_exif' &&
    command -p -- mkdir -p -- "${3-}" &&
    command exiftool "${1-}" >"${3-}"'/1' &&
    command exiftool "${2-}" >"${3-}"'/2' &&
    command diff \
      --side-by-side \
      --suppress-common-lines \
      --width="$((COLUMNS / 2 - 1 + COLUMNS / 2 - 1))" \
      -- \
      "${3-}"'/1' \
      "${3-}"'/2'
  {
    set \
      +o noclobber \
      +o noglob \
      +o nounset \
      +o verbose \
      +o xtrace
  } 2>/dev/null
  rm -r -- "${3-}" 2>/dev/null
}

dictionary() {
  # sort as you’d expect to find in a dictionary
  arguments=''
  case "${1-}" in
  --)
    shift
    ;;
  -*)
    arguments="${1##*-}"
    shift
    ;;
  *)
    LC_ALL='C' command -p -- sort -u "${1:--}" |
      LC_ALL='C' command -p -- sort '-f'"${arguments##*-}"
    ;;
  esac
  unset arguments 2>/dev/null || arguments=''
}

dimensions() {
  # print image file dimensions
  # even for SVGs
  # requires Exiftool
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command exiftool \
        -ViewBox \
        -short3 \
        -- \
        "${file-}" |
      command awk -- '{print $3 "x" $4}'
    command exiftool -ImageSize -short3 -- "${file-}" >/dev/null 2>&1 &&
      command exiftool \
        -ImageSize \
        -short3 \
        -- \
        "${file-}"
  done
}

dirname_r() {
  for file in "${@-}"; do
    command -p -- printf -- '%s\n' "${file%/*}"
  done
}

docker_r() {
  # run things like `docker_r --alpine` and `docker_r --ubuntu`
  set \
    -o verbose \
    -o xtrace
  case "${1-}" in
  --arch)
    set -- --archlinux
    ;;
  --latest)
    command docker exec --interactive --tty "$(command docker ps "${1-}" --quiet)" "${2:-/bin/zsh}" ||
      command docker exec --interactive --tty "$(command docker ps "${1-}" --quiet)" "${2:-/usr/bin/zsh}" ||
      command docker exec --interactive --tty "$(command docker ps "${1-}" --quiet)" "${2:-/bin/sh}"
    ;;
  *)
    {
      command docker pull "${1##*--}" &&
        command docker run --interactive --tty "${1##*--}"
    } || {
      command docker pull -- "${1##*--}"
      command docker exec --interactive --tty "$(command docker ps --latest --quiet)"
    }
    ;;
  esac
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

domain_name_from_url() {
  for url in "${@-}"; do
    command -p -- printf -- '%s\n' "${url-}" |
      command -p -- sed \
        -e '# remove user@ if any (ultra rare)' \
        -e 's|^.*@||' \
        -e '# remove https:// or http://' \
        -e 's|^.*//||' \
        -e '# remove leading www. from lines containing 2+ dots' \
        -e '/\..*\./ s/^[^\.]*\.//' \
        -e '# remove ports like :80, :443 (rare) and trailing slash and beyond' \
        -e 's|[:/].*$||'
    #####
    ##### consider adding `npm help install`’s examples
    #####          npm install git+ssh://git@github.com:npm/cli.git#v1.0.27
    ##### npm install git+ssh://git@github.com:npm/cli#pull/273
    ##### npm install git+ssh://git@github.com:npm/cli#semver:^5.0
    ##### npm install git+https://isaacs@github.com/npm/cli.git
    ##### npm install git://github.com/npm/cli.git#v1.0.27
    ##### GIT_SSH_COMMAND='ssh -i ~/.ssh/custom_ident' npm install git+ssh://git@github.com:npm/cli.git
    # # remove `user@` if any (ultra rare)
    # url="${url##*@}"
    # # remove `https://` or `http://`
    # url="${url##*//}"
    # # remove leading `www.`
    # url="${url#*www.}"
    # # remove ports like `:80`, `:443` (rare) and trailing slash and beyond
    # url="${url%%[:/]*}"
    # command -p -- printf -- '%s' "${url-}" &&
    #   command -p -- printf -- '\n'
  done
}

domain_name_tld_list() {
  {
    command curl --location --show-error --silent --url https://www.internic.net/domain/root.zone ||
      command wget --hsts-file=/dev/null --output-document=- --quiet -- https://www.internic.net/domain/root.zone
    command curl --location --show-error --silent --url https://data.iana.org/TLD/tlds-alpha-by-domain.txt ||
      command wget --hsts-file=/dev/null --output-document=- --quiet -- https://data.iana.org/TLD/tlds-alpha-by-domain.txt
  } 2>/dev/null |
    command -p -- sed \
      -e 's/\.[[:space:]].*//' \
      -e 's/.*\.//' \
      -e '/^$/ d' \
      -e '/#/ d' |
    LC_ALL='C' command -p -- tr -- '[:upper:]' '[:lower:]' |
    LC_ALL='C' command -p -- sort -u
}

dotfiles_not_found() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose
  command find -- "${DOTFILES-}" \
    -path "${DOTFILES-}"'/*/*' -prune -o \
    -name '.git*' -prune -o \
    -name '.*' \
    -exec sh -c 'command -p -- test -e "${HOME%/}${1##*"${DOTFILES-}"}" || command -p -- printf -- '\''~%s not found\n'\'' "${1##*"${DOTFILES-}"}" >&2' _ {} ';'
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose
  } 2>/dev/null
}
alias -- find_missing_dotfiles='dotfiles_not_found'

dss() {
  # delete thumbnail cache files
  # does -perm -600 help skip:
  #   find: ‘./Library/CloudStorage/GoogleDrive-lucas.larson@gmail.com/.tmp’: Permission denied
  #   find: ‘./Library/com.apple.internal.ck’: Operation not permitted
  while command -p -- test "$(
    command find -- . \
      '(' \
      -iname '.DS_Store' -o \
      -iname '._.DS_Store' -o \
      -iname 'Desktop.ini' -o \
      -iname 'Thumbs.db' \
      ')' \
      -type f \
      -perm -600 \
      -print
  )" != ''; do
    command find -- . \
      '(' \
      -iname '.DS_Store' -o \
      -iname '._.DS_Store' -o \
      -iname 'Desktop.ini' -o \
      -iname 'Thumbs.db' \
      ')' \
      -type f \
      -perm -600 \
      -exec sh -c 'for file in "${@-}"; do { command -p -- printf -- '\''removing \342\200\230%s\342\200\231... '\'' "${file-}" >&2 && command -p -- rm -f -- "${file-}" && command -p -- printf -- '\''\342\234\223\n'\'' >&2; } || command -p -- printf -- '\''error removing \342\200\230%s\342\200\231\n'\'' "${file-}" >&2;  done' _ {} +
  done
}

du() {
  # # print the human-readable size of a given directory (defaults to current directory)
  # command -p -- du -h -s -- "${1:-.}" 2>/dev/null |
  #   # awaiting Shellcheck's SC2016 repair to return to `awk '{print $1}'`
  #   command -p -- sed -e 's/^[[:space:]]*\([^[:space:]]*\).*/\1/'
  command dust "${@:--Fsx}" 2>/dev/null ||
    command -p -- du -h -s -- "${1:-.}"
}

epoch_seconds() {
  # return seconds since the epoch, 1969-12-31 19:00:00 EST
  # https://stackoverflow.com/a/41324810
  # `srand([expr])` will “Set the seed value for `rand` to `expr` or
  # use the time of day if `expr` is omitted.”
  # https://pubs.opengroup.org/onlinepubs/9699919799.2018edition/utilities/awk.html#tag_20_06_13_12
  command awk -- 'BEGIN {srand(); print srand()}'
}
epoch_to_date_time() {
  if command date -d '@0' >/dev/null 2>&1; then
    command date -d '@'"${1:-0}"
  else
    command date -r "${1:-0}"
  fi
}

## Esperanto
eo_from() {
  # Convert Cx-like esperanto typography into the correct unicode character (Ĉ ĉ Ĝ ĝ Ĥ ĥ Ĵ ĵ Ŝ ŝ Ŭ ŭ)
  # Xx is convert to x
  # https://github.com/Aeredren/txt2eo/blob/47c4e3a5ec/txt2eo
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command -p -- ed -- "${file-}" <<EOF
1,\$ s/Ĉ/Cx/g
1,\$ s/ĉ/cx/g
1,\$ s/Ĝ/Gx/g
1,\$ s/ĝ/gx/g
1,\$ s/Ĥ/Hx/g
1,\$ s/ĥ/hx/g
1,\$ s/Ĵ/Jx/g
1,\$ s/ĵ/jx/g
1,\$ s/Ŝ/Sx/g
1,\$ s/ŝ/sx/g
1,\$ s/Ŭ/Ux/g
1,\$ s/ŭ/ux/g
w
q
EOF
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

eo_to() {
  # Convert Cx-like esperanto typography into the correct unicode character (Ĉ ĉ Ĝ ĝ Ĥ ĥ Ĵ ĵ Ŝ ŝ Ŭ ŭ)
  # Xx is convert to x
  # https://github.com/Aeredren/txt2eo/blob/47c4e3a5ec/txt2eo
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command -p -- ed -- "${file-}" <<EOF
1,\$ s/Cx/Ĉ/g
1,\$ s/cx/ĉ/g
1,\$ s/Gx/Ĝ/g
1,\$ s/gx/ĝ/g
1,\$ s/Hx/Ĥ/g
1,\$ s/hx/ĥ/g
1,\$ s/Jx/Ĵ/g
1,\$ s/jx/ĵ/g
1,\$ s/Sx/Ŝ/g
1,\$ s/sx/ŝ/g
1,\$ s/Ux/Ŭ/g
1,\$ s/ux/ŭ/g
w
q
EOF
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

exif_copy_tags() {
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  command -p -- test -s "${1-}" &&
    command -p -- test -s "${2-}" &&
    command -p -- test ! -L "${2-}" &&
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
    command exiftool \
      -preserve \
      -overwrite_original \
      -ImageDescription="$(command exiftool -ImageDescription "${1-}" | command -p -- sed -e 's/[^:]*: //' -e 's/\./\n/g')" \
      -Caption-Abstract="$(command exiftool -Caption-Abstract "${1-}" | command -p -- sed -e 's/[^:]*: //' -e 's/\./\n/g')" \
      "${2-}" &&
    case "${2-}" in
    *.[Pp][Nn][Gg])
      command exiftool \
        -preserve \
        -overwrite_original \
        -XMP:Description="$(command exiftool -Caption-Abstract "${1-}" | command -p -- sed -e 's/[^:]*: //' -e 's/\./\n/g')" \
        "${2-}"
      ;;
    *) ;;
    esac
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}
alias -- convert_exif='exif_copy_tags'

exif_remove() {
  set \
    -o noclobber \
    -o nounset \
    -o xtrace
  for file in "${@:-.}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command git ls-files --error-unmatch -- "${file-}" >/dev/null 2>&1 &&
      # https://github.com/cirosantilli/dotfiles/blob/60ca745cdc/home/.bashrc#L2838-L2842
      command exiftool \
        -all='' \
        -overwrite_original \
        -progress \
        -v0 \
        -- \
        "${file-}"
  done
  {
    set \
      +o noclobber \
      +o nounset \
      +o xtrace
  } 2>/dev/null
}

exit_codes() {
  # https://github.com/freebsd/freebsd/blob/2321c47418/include/sysexits.h
  # https://sourceware.org/git/?p=glibc.git;hb=6025c399e9;f=misc/sysexits.h
  # https://gist.github.com/235e6a10dad1b122fd147a92b345150e
  # sysexits(3)
  # /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include/sysexits.h
  # /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/sysexits.h
  # https://tldp.org/LDP/abs/html/exitcodes.html

  # output a table of exit codes and their meanings
  command -p -- printf -- ' exit code | meaning\n'
  command -p -- printf -- '-----------+----------\n'
  command -p -- printf -- '         0 | EX_OK OK successful termination\n'
  command -p -- printf -- '         1 | the command was aborted due to a signal that was caught (not an exit status of a shell builtin)\n'
  command -p -- printf -- '         2 | the command was aborted because of a problem with the command-line syntax\n'
  command -p -- printf -- '        64 | EX__BASE base value for error messages\n'
  command -p -- printf -- '        64 | EX_USAGE command line usage error\n'
  command -p -- printf -- '        65 | EX_DATAERR data format error\n'
  command -p -- printf -- '        66 | EX_NOINPUT cannot open input\n'
  command -p -- printf -- '        67 | EX_NOUSER addressee unknown\n'
  command -p -- printf -- '        68 | EX_NOHOST host name unknown\n'
  command -p -- printf -- '        69 | EX_UNAVAILABLE service unavailable\n'
  command -p -- printf -- '        70 | EX_SOFTWARE internal software error\n'
  command -p -- printf -- '        71 | EX_OSERR system error (e.g., unable to fork)\n'
  command -p -- printf -- '        72 | EX_OSFILE critical OS file missing\n'
  command -p -- printf -- '        73 | EX_CANTCREAT unable to create (user) output file\n'
  command -p -- printf -- '        74 | EX_IOERR input/output error\n'
  command -p -- printf -- '        75 | EX_TEMPFAIL temp failure; user is invited to retry\n'
  command -p -- printf -- '        76 | EX_PROTOCOL remote error in protocol\n'
  command -p -- printf -- '        77 | EX_NOPERM permission denied\n'
  command -p -- printf -- '        78 | EX_CONFIG configuration error\n'
  command -p -- printf -- '        78 | EX__MAX maximum listed value\n'
  command -p -- printf -- '       126 | the command was found but not executable\n'
  command -p -- printf -- '       127 | the command was not found\n'
  command -p -- printf -- '       128 | the command was found but not executable\n'
  command -p -- printf -- '       130 | the command was terminated by a signal\n'
  command -p -- printf -- '       255 | the command was terminated by a signal\n'
}

exponent() {
  set \
    -o xtrace
  # return $(( $1 ** $2 ))
  # base ^ exponent
  # defaults to $1¹ or 0¹
  base="${1:-0}"
  exponent="${2:-1}"
  result=1
  while command -p -- test "${exponent-}" -gt 0; do
    result="$((result * base))"
    exponent="$((exponent - 1))"
  done
  command -p -- printf -- '%d\n' "${result-}"
  {
    set \
      +o xtrace
  } 2>/dev/null
  unset base || base=''
  unset exponent || exponent=''
  unset result || result=''
}

export_U() {
  # https://github.com/webpro/dotfiles/blob/d287e6978f/system/.path
  # https://chat.openai.com/share/8f8afb8b-7d87-4be3-a046-8c76bcdb8177
  # Remove duplicates (preserving prepended items)
  # Source: http://unix.stackexchange.com/a/40755
  {
    command -p -- getconf -- PATH 2>/dev/null ||
      command -p -- printf -- '%s\n' "${PATH-}"
  } |
    command -p -- sed \
      -e 's/::*/\n/g' \
      -e 's/^://' \
      -e 's/:$//' |
    command awk -- '! seen[$0]++ {print}' |
    command -p -- sed \
      -e ':a' \
      -e 'N' \
      -e '$! b a' \
      -e 's/\n/:/g'
  PATH=$(
    command -p -- printf -- '%s' "${PATH}" |
      command awk -vRS=':' -- '{ if (! arr[$0]++) {printf "%s%s", ! ln++ ? "" : ":", $0}}'
  )
  export PATH
}
alias -- \
  typeset_U='export_U' \
  export_u='export_U'

extract() {
  until command -p -- test "$(command find -- . -name '*.rpm' -type f -print)" = ''; do
    IFS=' ' command find -- . \
      -name '*.rpm' \
      -type f \
      -exec sh -C -e -f -u -x -c 'command -p -- mkdir -p -- "$(command -p -- basename -- "${1%.*}")" && command rpm2cpio "${1-}" >./"$(command -p -- basename -- "${1%.*}")"'\''/'\''"$(command -p -- basename -- "${1%.*}"'\''.cpio'\'')" && cd -- ./"$(command -p -- basename -- "${1%.*}")" && command -p -- test -s "$(command -p -- basename -- "${1%.*}"'\''.cpio'\'')" && command cpio --extract --make-directories --verbose <"$(command -p -- basename -- "${1%.*}"'\''.cpio'\'')" && command -p -- rm -- "$(command -p -- basename -- "${1%.*}"'\''.cpio'\'')" && cd -- "${OLDPWD:--}" && command -p -- rm -- "${1-}" && shift' _ {} ';'
  done
  command find -- . \
    '(' \
    -name '*.7[Zz]' -o \
    -name '*.[Aa][Aa][Rr]' -o \
    -name '*.[Aa][Pp][Kk]' -o \
    -name '*.[Bb][Rr]' -o \
    -name '*.[Bb][Zz]2' -o \
    -name '*.[Cc][Pp][Ii][Oo]' -o \
    -name '*.[Ee][Aa][Rr]' -o \
    -name '*.[Gg][Zz]' -o \
    -name '*.[Ii][Pp][Aa]' -o \
    -name '*.[Ii][Pp][Ss][Ww]' -o \
    -name '*.[Jj][Aa][Rr]' -o \
    -name '*.[Ll][Zz][Mm][Aa]' -o \
    -name '*.[Rr][Aa][Rr]' -o \
    -name '*.[Rr][Pp][Mm]' -o \
    -name '*.[Tt][Aa][Rr]' -o \
    -name '*.[Tt][Aa][Rr].[Bb][Zz]2' -o \
    -name '*.[Tt][Aa][Rr].[Gg][Zz]' -o \
    -name '*.[Tt][Aa][Rr].[Xx][Zz]' -o \
    -name '*.[Tt][Aa][Rr].[Zz][Mm][Aa]' -o \
    -name '*.[Tt][Aa][Rr].[Zz][Ss][Tt]' -o \
    -name '*.[Tt][Bb][Zz]' -o \
    -name '*.[Tt][Bb][Zz]2' -o \
    -name '*.[Tt][Gg][Zz]' -o \
    -name '*.[Tt][Ll][Zz]' -o \
    -name '*.[Tt][Xx][Zz]' -o \
    -name '*.[Tt][Zz][Ss][Tt]' -o \
    -name '*.[Ww][Aa][Rr]' -o \
    -name '*.[Ww][Hh][Ll]' -o \
    -name '*.[Xx][Pp][Ii]' -o \
    -name '*.[Xx][Zz]' -o \
    -name '*.[Zz]' -o \
    -name '*.[Zz][Ii][Pp]' \
    ')' \
    -type f \
    -print 2>/dev/null
}
alias -- rpm_extract='extract'

filename_extension() {
  for file in "${@-}"; do
    command -p -- printf -- '%s\n' "${file##*.}"
  done
}

filename_without_extension() {
  for file in "${@-}"; do
    # https://stackoverflow.com/a/12152997
    command -p -- basename -- "${file%.*}"
  done
}

filename_spaces_to_underscores() {
  command find -- . \
    -depth \
    -name '*'"${1:-[[:space:]]}"'*' |
    while IFS='' read -r -- file; do
      command -p -- mv -i -- "${file-}" "${file%/*}"/"$(
        command -p -- printf -- '%s' "${file##*/}" |
          command -p -- tr -s -- "${1:-[:space:]}" "${2:-_}"
      )"
    done
}
filename_underscores_to_spaces() {
  command find -- . \
    -depth \
    -name '*_*' |
    while IFS='' read -r -- file; do
      command -p -- mv -i -- "${file-}" "${file%/*}"/"$(
        command -p -- printf -- '%s' "${file##*/}" |
          command -p -- tr -s -- "${1:-_}" "${2:- }"
      )"
    done
}

file_closes_with_newline() {
  while command -p -- test "${#}" -gt 0; do
    command find -- "${1-}" \
      -type f \
      -exec sh -c 'command -p -- test "$(command -p -- tail -c 1 -- "${1-}" | command -p -- wc -l)" -ne 0 || command -p -- printf -- '\''%s does not close with a newline\n'\'' "${1-}" >&2' _ {} ';'
    shift
  done
}
alias -- \
  file_ends_with_newline='file_closes_with_newline' \
  newline_file_closes_with='file_closes_with_newline' \
  linelint='file_closes_with_newline' # name inspiration https://github.com/lra/mackup/commit/28811b7440

file_has_trailing_whitespace() {
  while command -p -- test "${#}" -gt 0; do
    command find -- "${1-}" \
      -type f \
      -exec sh -c 'command -p -- test "$(command -p -- sed -e '\''s/[[:space:]]*$//'\'' <"${1-}" | command -p -- wc -l)" -eq "$(command -p -- sed -e '\''s/[[:space:]]*$//'\'' <"${1-}" | command -p -- wc -l)" || command -p -- printf -- '\''%s has trailing whitespace\n'\'' "${1-}" >&2' _ {} ';'
    shift
  done
}

f() {
  # try using `fd`, if not then `find`
  if command -v -- fd >/dev/null 2>&1 && command -p -- test -x "$(command -v -- fd)"; then
    command fd \
      --follow \
      --hidden \
      "${@-}"
  else
    while command -p -- test "${#}" -gt 0; do
      command find -L -- . \
        -path '*/.git' -prune -o \
        -path '*/node_modules' -prune -o \
        -path './*' \
        '(' \
        -name "$(command -p -- printf -- '%s' "${1-}" | command awk -- '{for (i = 1; i <= length($0); i++) {printf "[%s%s]", toupper(substr($0, i, 1)), tolower(substr($0, i, 1))} printf "\n"}')" \
        ')' \
        -print
      shift
    done
  fi
}

fn() {
  if command -v -- fd >/dev/null 2>&1 && command -p -- test -x "$(command -v -- fd)"; then
    command fd \
      --follow \
      --hidden \
      "${@-}"
  else
    command -p -- find -L -- . \
      -path '*/.*' -prune -o \
      -path '*/.bundle' -prune -o \
      -path '*/.cache' -prune -o \
      -path '*/.cask' -prune -o \
      -path '*/.git' -prune -o \
      -path '*/.hg' -prune -o \
      -path '*/.mypy_cache' -prune -o \
      -path '*/.pytest_cache' -prune -o \
      -path '*/.stack-work' -prune -o \
      -path '*/.svn' -prune -o \
      -path '*/.tox' -prune -o \
      -path '*/.venv' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*/vendor' -prune -o \
      -path './*' \
      -iname "$(command -p -- printf -- '*%s*' "${@-}")" \
      -type f \
      -print 2>/dev/null |
      LC_ALL='C' command -p -- sort -f
  fi
}

find_audio_files() {
  # these are all the extensions of audio files on my device
  # ∴ that’s everything
  # also includes `eza`’s `Icons::AUDIO`
  command -p -- find -- . \
    -path '*/.git' -prune -o \
    -path '*/Library' -prune -o \
    -path '*/node_modules' -prune -o \
    '(' \
    -name '*.[Aa][Aa][Cc]' -o \
    -name '*.[Aa][Cc][Cc]' -o \
    -name '*.[Aa][Ii][Ff]' -o \
    -name '*.[Aa][Ii][Ff][Cc]' -o \
    -name '*.[Aa][Ii][Ff][Ff]' -o \
    -name '*.[Aa][Ll][Aa][Cc]' -o \
    -name '*.[Aa][Mm][Rr]' -o \
    -name '*.[Aa][Pp][Ee]' -o \
    -name '*.[Aa][Uu]' -o \
    -name '*.[Cc][Aa][Ff]' -o \
    -name '*.[Dd][Ss][Ff]' -o \
    -name '*.[Ff][Ll][Aa][Cc]' -o \
    -name '*.[Mm]4[Aa]' -o \
    -name '*.[Mm]4[Pp]' -o \
    -name '*.[Mm]4[Rr]' -o \
    -name '*.[Mm][Kk][Aa]' -o \
    -name '*.[Mm][Oo][Dd]' -o \
    -name '*.[Mm][Pp]2' -o \
    -name '*.[Mm][Pp]3' -o \
    -name '*.[Oo][Gg][Gg]' -o \
    -name '*.[Oo][Pp][Uu][Ss]' -o \
    -name '*.[Pp][Cc][Mm]' -o \
    -name '*.[Vv][Oo][Cc]' -o \
    -name '*.[Ww][Aa][Vv]' -o \
    -name '*.[Ww][Mm][Aa]' -o \
    -name '*.[Ww][Vv]' -o \
    -name '*.[Xx][Mm]' \
    ')' \
    -type f \
    -print 2>/dev/null
}

find_binary_files() {
  LC_ALL='C' IFS='' command -p -- find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
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

find_broken_symlinks() {
  # https://pubs.opengroup.org/onlinepubs/9699919799.2018edition/utilities/find.html#tag_20_47_18
  # https://gitlab.opengroup.org/the-austin-group/sus_html/blob/783a8fc6d3/html/utilities/find.html#L697
  case "${1-}" in
  -d | --delete)
    command find -L -- . \
      -type l \
      -exec sh -c 'command -p -- ls -g -o -- "${1-}" &&
  rm "${1-}" &&
  command git rm -- "${1-}" 2>/dev/null
' _ {} ';'
    ;;
  *)
    command find -L -- . \
      -type l \
      -exec ls -g -o -- {} + 2>/dev/null
    ;;
  esac
}

find_capital_letter_files() {
  case "${1-}" in
  -d | --delete) LC_ALL='C' command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    -name '[[:upper:]]*' \
    -type f \
    -exec sh -c '{ command -p -- printf -- '\''removing \342\200\230%s\342\200\231 '\'' "${1-}" >&2 && command -p -- rm -f -r -- "${1-}" && command -p -- printf -- '\''\342\234\223\n'\'' >&2; } || command -p -- printf -- '\''error removing \342\200\230%s\342\200\231\n'\'' "${1-}" >&2' _ {} ';' ;;
  *) LC_ALL='C' command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    -name '[[:upper:]]*' \
    -type f \
    -print ;;
  esac
}

find_compressed_files() {
  {
    command -p -- find -- . \
      -path '*/.git' -prune -o \
      -path '*/Library' -prune -o \
      -path '*/node_modules' -prune -o \
      '(' \
      -iname '*.7z' -o \
      -iname '*.aar' -o \
      -iname '*.apk' -o \
      -iname '*.br' -o \
      -iname '*.bz2' -o \
      -iname '*.ear' -o \
      -iname '*.gz' -o \
      -iname '*.ipa' -o \
      -iname '*.ipsw' -o \
      -iname '*.jar' -o \
      -iname '*.lzma' -o \
      -iname '*.rar' -o \
      -iname '*.rpm' -o \
      -iname '*.tar' -o \
      -iname '*.tar.bz2' -o \
      -iname '*.tar.gz' -o \
      -iname '*.tar.xz' -o \
      -iname '*.tar.zma' -o \
      -iname '*.tar.zst' -o \
      -iname '*.tbz' -o \
      -iname '*.tbz2' -o \
      -iname '*.tgz' -o \
      -iname '*.tlz' -o \
      -iname '*.txz' -o \
      -iname '*.tzst' -o \
      -iname '*.war' -o \
      -iname '*.whl' -o \
      -iname '*.xpi' -o \
      -iname '*.xz' -o \
      -iname '*.Z' -o \
      -iname '*.z' -o \
      -iname '*.zip' \
      ')' \
      -type f \
      -print 2>/dev/null
    command -p -- find -- . \
      -path '*/.git' -prune -o \
      -path '*/Library' -prune -o \
      -path '*/node_modules' -prune -o \
      -type f \
      -exec file -- '{}' + 2>/dev/null |
      # allow `file` to find .sit `Archive` files by setting `$2` to lowercase before checking its value
      LC_ALL='C' command awk -F':' -- '{if (tolower($2) ~ /archive|compress/) print $1}'

  } |
    LC_ALL='C' command -p -- sort -u |
    LC_ALL='C' command -p -- sort -f
}

find_debug() {
  # @TODO!:
  # `find -- . -name '[A-Z]*'` returns
  # `find -- . -name '*'`
  {
    command -p -- printf -- '# find --debug\n' >&2
    command -p -- printf -- ' command find -D opt -- .\n' >&2
    command -p -- printf -- '  # "\044{arguments-}"\n' >&2
    command -p -- printf -- '  -print 2>&1 | ' >&2
    command -p -- printf -- 'command -p -- sed' >&2
    command -p -- printf -- ' -n' >&2
    command -p -- printf -- ' -e \047/^Optim.*command line:/ {\047' >&2
    command -p -- printf -- ' -e \047n\047' >&2
    command -p -- printf -- ' -e \047p\047' >&2
    command -p -- printf -- ' -e \047}\047' >&2
    command -p -- printf -- ' | ' >&2
    command -p -- printf -- 'command -p -- sed' >&2
    command -p -- printf -- ' -e \047# remove redundant -a operator\047' >&2
    command -p -- printf -- ' -e \047s/[[:space:]]-a[[:space:]]//g\047' >&2
    command -p -- printf -- ' -e \047# remove estimates\047' >&2
    command -p -- printf -- ' -e \047s/\134[[^]]*\134]//g\047' >&2
    command -p -- printf -- ' -e \047# escape parentheses and colons\047' >&2
    command -p -- printf -- ' -e \047s/\134([()\134;]\134)/\047\134\047\047\\1\047\134\047\047/g\047' >&2
    command -p -- printf -- ' -e \047# enclose paths and names with single quotes\047' >&2
    command -p -- printf -- ' -e \047s/\134(-i\134{0,1\134}[np]a[mt][eh]\134)[[:space:]]\134([^[:space:]]*\134)/\\1 \047\134\047\047\\2\047\134\047\047/g\047' >&2
    command -p -- printf -- ' -e \047s/[[:space:]][[:space:]]*/ /g\047' >&2
    command -p -- printf -- ' -e \047s/ *\134(.*\134)/#!\134/usr\134/bin\134/env sh\\ncommand find -- . \\1/g\047 | ' >&2
    command -p -- printf -- 'command shfmt --indent 2 --language-dialect bash --simplify -- - | ' >&2
    command -p -- printf -- '{ command bat --decorations=never --language=sh --paging=never -- - 2>/dev/null || ' >&2
    command -p -- printf -- 'command -p -- cat -- -; }\n' >&2
  } 2>&1 | {
    command bat \
      --decorations=never \
      --language=sh \
      --paging=never \
      -- \
      - 2>/dev/null ||
      command -p -- cat \
        -- \
        -
  }
}

find_dot_files() {
  case "${1-}" in
  -d | --delete)
    command find -- . \
      -depth \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -path './*' \
      -name '.*' \
      ! -name '.gitmodules' \
      -exec sh -c '{ command -p -- printf -- '\''removing \342\200\230%s\342\200\231 '\'' "${1-}" >&2 && command -p -- rm -f -r -- "${1-}" && command -p -- printf -- '\''\342\234\223\n'\'' >&2; } || command -p -- printf -- '\''error removing \342\200\230%s\342\200\231\n'\'' "${1-}" >&2' _ {} ';'
    ;;
  *)
    command find -- . \
      -depth \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -path './*' \
      -name '.*' \
      ! -name '.gitmodules' \
      -print |
      LC_ALL='C' command -p -- sort -f
    ;;
  esac
}

fdupes() {
  command jdupes \
    --ext-filter=nostr:node_modules \
    --no-hidden \
    --one-file-system \
    --quiet \
    --recurse \
    --size \
    "${@:-.}" \
    2>/dev/null |
    command -p -- sed \
      -e '/^No duplicates found\.$/ d'
}
find_duplicate_cksum() {
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    -xdev \
    -type f \
    -exec sh -c 'command -p -- cksum -- "${1-}"' _ {} ';' |
    command -p -- sed -e 's/\([[:digit:]][[:digit:]]*\)[[:space:]]\([[:digit:]][[:digit:]]*\)[[:space:]]\(.*\)/\1 \2/' |
    LC_ALL='C' command -p -- sort -k 1,1n -k 2,2n |
    command -p -- uniq -D -f 1 |
    command -p -- sed -e 's/^[[:digit:]][[:digit:]]*[[:space:]][[:digit:]][[:digit:]]*[[:space:]]//'
  lc_all_temporary="$(
    set |
      command -p -- grep -e '^LC_' |
      command -p -- sed \
        -e 's/\(.*\)/export \1; /' |
      command -p -- sed \
        -e ':a' \
        -e 'N' \
        -e '$! b a' \
        -e 's/\n//g'
  )" &&
    export lc_all_temporary &&
    export LC_ALL='C' &&
    command find -- . \
      -path '*/.git' -prune -o \
      -path '*/.well-known' -prune -o \
      -path '*/Empty' -prune -o \
      -path '*/Library' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*/plugins' -prune -o \
      -path '*/t' -prune -o \
      -path '*/Test*' -prune -o \
      -path '*/test*' -prune -o \
      -path '*/themes' -prune -o \
      -path '*/tst*' -prune -o \
      -path '*copilot*' -prune -o \
      -path '*dummy*' -prune -o \
      -path '*vscode*' -prune -o \
      -path './*' \
      -type f \
      ! -size 0 \
      -xdev \
      -exec sh -c 'command -p -- cksum -- "${1-}"' _ {} ';' |
    command -p -- sed -e 's/\([[:digit:]][[:digit:]]*\)[[:space:]]\([[:digit:]][[:digit:]]*\)[[:space:]]\(.*\)/\1 \2/' |
      command -p -- sort |
      command -p -- uniq -d
  # restore LC_ALL
  eval " ${lc_all_temporary-}"
  unset lc_all_temporary 2>/dev/null || lc_all_temporary=''
}
find_duplicate_files() {
  # https://linuxjournal.com/content/boost-productivity-bash-tips-and-tricks
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/Empty' -prune -o \
    -path '*/Library' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/plugins' -prune -o \
    -path '*/t' -prune -o \
    -path '*/Test*' -prune -o \
    -path '*/test*' -prune -o \
    -path '*/themes' -prune -o \
    -path '*/tst*' -prune -o \
    -path '*copilot*' -prune -o \
    -path '*dummy*' -prune -o \
    -path '*vscode*' -prune -o \
    -xdev \
    -path './*' \
    -type f \
    ! -size 0 \
    -exec sh -c 'for file in "${@-}"; do
  command -p -- wc -c -- <"${file-}"
done
' _ {} + 2>/dev/null |
    LC_ALL='C' command -p -- sort -n -r |
    command -p -- uniq -d |
    command -p -- xargs -I {} -n 1 find -- . \
      -path '*/.git' -prune -o \
      -path '*/.well-known' -prune -o \
      -path '*/Empty' -prune -o \
      -path '*/Library' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*/plugins' -prune -o \
      -path '*/t' -prune -o \
      -path '*/Test*' -prune -o \
      -path '*/test*' -prune -o \
      -path '*/themes' -prune -o \
      -path '*/tst*' -prune -o \
      -path '*copilot*' -prune -o \
      -path '*dummy*' -prune -o \
      -path '*vscode*' -prune -o \
      -xdev \
      -type f \
      -size {}c \
      -print 2>/dev/null |
    command -p -- sed \
      -e '# https://web.archive.org/web/0id_/etalabs.net/sh_tricks.html#:~:text=Using%20find%20with%20xargs' \
      -e 's/./\\&/g' |
    command -p -- xargs sha1sum 2>/dev/null |
    LC_ALL='C' command -p -- sort |
    command uniq -w 32 --all-repeated=separate

  # now begin method 2

  # if command stat -Lf%z -- . >/dev/null 2>&1; then
  #   argument='-Lf%z'
  # else
  #   argument='-Lc%s'
  # fi
  # export argument
  #      -exec sh -c 'command stat "${argument-}" -- "${1-}"' _ {} ';' 2>/dev/null |
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/Empty' -prune -o \
    -path '*/Library' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/plugins' -prune -o \
    -path '*/t' -prune -o \
    -path '*/Test*' -prune -o \
    -path '*/test*' -prune -o \
    -path '*/themes' -prune -o \
    -path '*/tst*' -prune -o \
    -path '*copilot*' -prune -o \
    -path '*dummy*' -prune -o \
    -path '*vscode*' -prune -o \
    -path './*' \
    -xdev \
    ! -size 0 \
    -type f \
    -exec wc -m -- {} + |
    command awk -- '{print $1}' |
    LC_ALL='C' command -p -- sort -n -r |
    command -p -- uniq -d |
    command -p -- xargs -I {} -n 1 find -- . \
      -path '*/.git' -prune -o \
      -path '*/.well-known' -prune -o \
      -path '*/Empty' -prune -o \
      -path '*/Library' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*/plugins' -prune -o \
      -path '*/t' -prune -o \
      -path '*/Test*' -prune -o \
      -path '*/test*' -prune -o \
      -path '*/themes' -prune -o \
      -path '*/tst*' -prune -o \
      -path '*copilot*' -prune -o \
      -path '*dummy*' -prune -o \
      -path '*vscode*' -prune -o \
      -path './*' \
      -xdev \
      -type f \
      -size {}c \
      -print 2>/dev/null |
    command -p -- xargs shasum 2>/dev/null |
    LC_ALL='C' command -p -- sort |
    command uniq -w 32 --all-repeated=separate
}
alias -- fdf='find_duplicate_files'

find_duplicate_images() {
  command findimagedupes \
    --quiet \
    --recurse \
    -- \
    . 2>/dev/null |
    command column -t
}
alias -- fdi='find_duplicate_images'

find_editorconfig() {
  directory="${PWD%/}"
  while command -p -- test "${directory-}" != ''; do
    command -p -- test -r "${directory-}"'/.editorconfig' &&
      command -p -- printf -- '%s/.editorconfig\n' "${directory-}"
    directory="${directory%/*}"
  done
  unset directory 2>/dev/null || directory=''
}
alias -- \
  editorconfig_applicable='editorconfig_find' \
  editorconfig_find='find_editorconfig'

find_empty() {
  case "${1-}" in
  -d | --delete)
    # POSIX- and `find`-compliant `find . -path '*/.git' -prune -o -type d -empty -delete`
    # because `-delete` activates `-depth`, and `-depth` overrides `-prune`, which reverses `-prune logic
    command -p -- printf -- 'are you sure?\n' >&2 &&
      command -p -- sleep 2 &&
      LC_ALL='C' IFS='' command find -- . \
        ! -path '*/.git*' \
        ! -path '*/Library*' \
        -path './*' \
        -type d \
        -exec sh -c 'for directory in "${@-}"; do command -p -- test "$(command -p -- find -- "${directory-}" -path "${directory-}"'\''/*'\'' -print)" = '\'''\'' && command -p -- rmdir -- "${directory-}"; done' _ {} +
    ;;
  *)
    # POSIX-compliant `find . -type d -empty`
    LC_ALL='C' IFS='' command find -- . \
      -path '*/.git' -prune -o \
      -path '*/Library' -prune -o \
      -path '*/node_modules' -prune -o \
      -path './*' \
      -type d \
      -exec sh -C -f -u -c 'for directory in "${@-}"; do command -p -- test "$(command -p -- find -- "${directory-}" -path "${directory-}"'\''/*'\'' -print)" = '\'''\'' && command -p -- printf -- '\''%s\n'\'' "${directory-}"; done' _ {} +
    ### # POSIX-compliant, but non-portable, `find . -type d -empty`
    ### LC_ALL='C' IFS='' command find -- . \
    ###   -path '*/.git' -prune -o \
    ###   -path '*/Library' -prune -o \
    ###   -path '*/node_modules' -prune -o \
    ###   -path './*' \
    ###   -type d \
    ###   -links 2 \
    ###   -print
    ;;
  esac
}

find_executable() {
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/Empty' -prune -o \
    -path '*/Library' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/plugins' -prune -o \
    -path '*/t' -prune -o \
    -path '*/Test*' -prune -o \
    -path '*/test*' -prune -o \
    -path '*/themes' -prune -o \
    -path '*/tst*' -prune -o \
    -path '*copilot*' -prune -o \
    -path '*dummy*' -prune -o \
    -path '*vscode*' -prune -o \
    -path './*' \
    -type f \
    -xdev \
    -exec sh -c 'for file in "${@-}"; do command -p -- test -x "${file-}" && command -p -- printf -- '\''%s\n'\'' "${file-}"; done' {} +
}
find_executable_gnu() {
  # POSIX emulation of GNU `find -executable`
  # printing the names of all files – including directories – whose permissions meet or exceed 700
  command -p -- find -- . \
    -perm -700 \
    -print
}

find_files_with_newline() {
  # https://github.com/yutkat/dotfiles/blob/76e4b7cd02/.zsh/rc/function.zsh#L246
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    ! -name '.DS_Store' \
    -type f \
    -exec sh -c 'command -p -- file -- "${1-}" | command -p -- grep -v -e '\'':.*executable'\'' >/dev/null 2>&1 && command -p -- test "$(command -p -- tail -c 1 -- "${1-}" 2>/dev/null)" = '\'''\'' && command -p -- printf -- '\''%s\n'\'' "${1-}"' _ {} ';'
}

find_files_without_newline() {
  # https://github.com/yutkat/dotfiles/blob/76e4b7cd02/.zsh/rc/function.zsh#L246
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    ! -name '.DS_Store' \
    -type f \
    -exec sh -c 'command -p -- file -- "${1-}" | command -p -- grep -v -e '\'':.*executable'\'' -e '\'':.*image'\'' >/dev/null 2>&1 && command -p -- test "$(command -p -- tail -c 1 -- "${1-}" 2>/dev/null)" != '\'''\'' && command -p -- printf -- '\''%s\n'\'' "${1-}"' _ {} ';'
}

find_files_with_windows_newline() {
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    ! -name '.DS_Store' \
    -type f \
    -exec sh -c 'command -p -- file -- "${1-}" | command -p -- grep -v -e '\'':.*-bit '\'' -e '\'':.*binary'\'' -e '\'':.*executable'\'' -e '\'': GIF image'\'' -e '\'': JPEG image'\'' -e '\'': PNG image'\'' -e '\'': RIFF '\'' >/dev/null 2>&1 && command -p -- grep -l -e "$(command -p -- printf -- '\''\015\012'\'')" -- "${1-}" 2>/dev/null' _ {} ';'
}

# find HTML
find_html_files() {
  command -p -- find -- . \
    -path '*/.bzr' -prune -o \
    -path '*/.CVS' -prune -o \
    -path '*/.cvs' -prune -o \
    -path '*/.git' -prune -o \
    -path '*/.hg' -prune -o \
    -path '*/.idea' -prune -o \
    -path '*/.svn' -prune -o \
    -path '*/.tox' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*copilot*' -prune -o \
    -path '*dummy*' -prune -o \
    -path '*vscode*' -prune -o \
    '(' \
    -name '*.html' -o \
    -name '*.[Hh][Tt][Aa]' -o \
    -name '*.[Hh][Tt][Mm]' -o \
    -name '*.[Hh][Tt][Mm][Ll]' -o \
    -name '*.[Hh][Tt][Mm][Ll].[Hh][Ll]' -o \
    -name '*.[Ii][Nn][Cc]' -o \
    -name '*.[Kk][Ii][Tt]' -o \
    -name '*.[Mm][Tt][Mm][Ll]' -o \
    -name '*.[Xx][Hh][Tt]' -o \
    -name '*.[Xx][Hh][Tt][Mm][Ll]' \
    ')' \
    -type f \
    -print 2>/dev/null
}

# find images
find_image_files() {
  # why of course this is the best way. you’re very welcome, future Lucas!
  # includes `eza`’s `Icons::IMAGE`
  command -p -- find -- . \
    '(' \
    -name '*.[Aa][Ii]' -o \
    -name '*.[Aa][Rr][Ww]' -o \
    -name '*.[Aa][Vv][Ii][Ff]' -o \
    -name '*.[Bb][Mm][Pp]' -o \
    -name '*.[Cc][Aa][Rr]' -o \
    -name '*.[Cc][Bb][Rr]' -o \
    -name '*.[Cc][Bb][Zz]' -o \
    -name '*.[Cc][Rr]2' -o \
    -name '*.[Cc][Uu][Rr]' -o \
    -name '*.[Dd][Dd][Ss]' -o \
    -name '*.[Dd][Vv][Ii]' -o \
    -name '*.[Ee][Pp][Ss]' -o \
    -name '*.[Ee][Xx][Rr]' -o \
    -name '*.[Ff][Ii][Gg]' -o \
    -name '*.[Gg][Ii][Ff]' -o \
    -name '*.[Hh][Ee][Ii][Cc]' -o \
    -name '*.[Hh][Ee][Ii][Ff]' -o \
    -name '*.[Ii][Cc][Nn][Ss]' -o \
    -name '*.[Ii][Cc][Oo]' -o \
    -name '*.[Ii][Tt][Cc] Apple Music.app JPEGs' -o \
    -name '*.[Ii][Tt][Cc]' -o \
    -name '*.[Jj]2[Cc]' -o \
    -name '*.[Jj]2[Kk]' -o \
    -name '*.[Jj][Ff][Ii]' -o \
    -name '*.[Jj][Ff][Ii][Ff]' -o \
    -name '*.[Jj][Ii][Ff]' -o \
    -name '*.[Jj][Pp]2' -o \
    -name '*.[Jj][Pp][Ee]' -o \
    -name '*.[Jj][Pp][Ee][Gg]' -o \
    -name '*.[Jj][Pp][Ff]' -o \
    -name '*.[Jj][Pp][Gg]' -o \
    -name '*.[Jj][Pp][Xx]' -o \
    -name '*.[Jj][Xx][Ll]' -o \
    -name '*.[Nn][Ee][Ff]' -o \
    -name '*.[Oo][Rr][Ff]' -o \
    -name '*.[Pp][Bb][Mm]' -o \
    -name '*.[Pp][Gg][Mm]' -o \
    -name '*.[Pp][Ii][Cc]' -o \
    -name '*.[Pp][Nn][Gg]' -o \
    -name '*.[Pp][Nn][Jj]' -o \
    -name '*.[Pp][Nn][Mm]' -o \
    -name '*.[Pp][Pp][Mm]' -o \
    -name '*.[Pp][Ss][Dd]' -o \
    -name '*.[Pp][Xx][Mm]' -o \
    -name '*.[Rr][Aa][Ww]' -o \
    -name '*.[Rr][Ii][Ff]johnalanwoods/maintained-modern-unix@c43c4b3f29/screenshots/zoxide.riff' -o \
    -name '*.[Rr][Ii][Ff]' -o \
    -name '*.[Rr][Ii][Ff][Ff]' -o \
    -name '*.[Ss][Gg][Ii]' -o \
    -name '*.[Ss][Rr][Ww]' -o \
    -name '*.[Ss][Vv][Gg]' -o \
    -name '*.[Tt][Gg][Aa]' -o \
    -name '*.[Tt][Hh][Mm]' -o \
    -name '*.[Tt][Ii][Ff]' -o \
    -name '*.[Tt][Ii][Ff][Ff]' -o \
    -name '*.[Ww][Ee][Bb][Pp]' -o \
    -name '*.[Xx][Bb][Mm]' -o \
    -name '*.[Xx][Cc][Ff]' -o \
    -name '*.[Xx][Pp][Mm]' \
    ')' \
    -type f \
    -print 2>/dev/null
  {
    # when the following portion is removed, you may also remove `2>/dev/null` from `find_images_with_incorrect_filename_extensions` probably
    command -p -- printf -- '#!/usr/bin/env sh\ncd -- "\044{HOME-}"'\''/c'\'' &&\n  LC_ALL='\''C'\'' IFS='\'''\'' command -p -- find -L -- . -path '\''*/.git'\'' -prune -o -type f -exec file -- '\''{}'\'' + |\n  LC_ALL='\''C'\'' IFS='\'''\'' command -p -- sed \\\n    -n \\\n    -e '\''/: .* image/ {'\'' \\\n    -e '\''  s/^\\([^:]*\\):.*$/\\1/p'\'' \\\n    -e '\''}'\''\n' |
      command bat \
        --decorations=never \
        --language=sh \
        --paging=never \
        -- \
        - >&2 2>/dev/null ||
      command -p -- cat \
        -- \
        -
  } >&2
}
alias fif='find_image_files'

find_images_with_incorrect_filename_extensions() {
  # 2>/dev/null until `find_image_files` removes post-completion helpful hint
  find_image_files 2>/dev/null |
    while IFS='' read -r -- file; do
      # `grep -F` for filenames like `/Users/LucasLarson/c/d/grep.app.command -p -- [^ ]* -- .search.20240430.jpg`
      case "${file-}" in
      *.[Aa][Ii]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': PDF document' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Aa][Vv][Ii][Ff]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': ISO Media, AVIF Image' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Bb][Mm][Pp]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': PC bitmap' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Ee][Pp][Ss]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': DOS EPS Binary File' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Gg][Ii][Ff]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': GIF image' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Ii][Cc][Nn][Ss]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': Mac OS X icon' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Ii][Cc][Oo]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': MS Windows icon' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Jj][Pp][Ee] | *.[Jj][Pp][Ee][Gg] | *.[Jj][Pp][Gg]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': JPEG image' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Pp][Bb][Mm] | *.[Pp][Gg][Mm] | *.[Pp][Pp][Mm]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': Netpbm image' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Pp][Nn][Gg]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': PNG image' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Pp][Ss][Dd]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': Adobe Photoshop Image' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Ss][Vv][Gg]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': SVG Scalable Vector Graphics image' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *.[Tt][Ii][Ff] | *.[Tt][Ii][Ff][Ff]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': TIFF image' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      # `file` calls `.webp` files `RIFF... Web/P`
      *.[Ww][Ee][Bb][Pp]) command -p -- file -- "${file-}" | command -p -- grep -F -e "${file-}"': RIFF' >/dev/null 2>&1 | command -p -- grep -e ' Web/P image' >/dev/null 2>&1 || command -p -- printf -- '%s\n' "${file-}" ;;
      *) command -p -- printf -- '%s: this test does not yet test \140%s\140 files\n' "${file-}" "$(
        command -p -- printf -- '%s\n' "${file##*.}" |
          LC_ALL='C' command -p -- tr -- '[:lower:]' '[:upper:]'
      )" >&2 ;;
      esac
    done
}

find_json_files() {
  command -p -- find -- . \
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
    -name '*.4[Dd][Ff][Oo][Rr][Mm]' -o \
    -name '*.4[Dd][Pp][Rr][Oo][Jj][Ee][Cc][Tt]' -o \
    -name '*.[Aa][Vv][Ss][Cc]' -o \
    -name '*.[Bb][Aa][Bb][Ee][Ll][Rr][Cc]*' -o \
    -name '*.[Cc][Jj][Ss].[Mm][Aa][Pp]' -o \
    -name '*.[Cc][Oo][Dd][Ee]-[Ww][Oo][Rr][Kk][Ss][Pp][Aa][Cc][Ee]' -o \
    -name '*.[Cc][Ss][Ss].[Mm][Aa][Pp]' -o \
    -name '*.[Cc][Yy]' -o \
    -name '*.[Gg][Ee][Oo][Jj][Ss][Oo][Nn]' -o \
    -name '*.[Gg][Ll][Tt][Ff]' -o \
    -name '*.[Hh][Aa][Rr]' -o \
    -name '*.[Ii][Cc][Ee]' -o \
    -name '*.[Jj][Ss].[Mm][Aa][Pp]' -o \
    -name '*.[Jj][Ss][Oo][Nn]' -o \
    -name '*.[Jj][Ss][Oo][Nn]-[Tt][Mm][Ll][Aa][Nn][Gg][Uu][Aa][Gg][Ee]' -o \
    -name '*.[Jj][Ss][Oo][Nn]5' -o \
    -name '*.[Jj][Ss][Oo][Nn][Ll]' -o \
    -name '*.[Jj][Ss][Oo][Nn][Ll][Dd]' -o \
    -name '*.[Mm][Aa][Xx][Hh][Ee][Ll][Pp]' -o \
    -name '*.[Mm][Aa][Xx][Pp][Aa][Tt]' -o \
    -name '*.[Mm][Aa][Xx][Pp][Rr][Oo][Jj]' -o \
    -name '*.[Mm][Cc][Mm][Ee][Tt][Aa]' -o \
    -name '*.[Mm][Xx][Tt]' -o \
    -name '*.[Nn][Mm][Ff]' -o \
    -name '*.[Rr][Cc][Pp][Rr][Oo][Jj][Ee][Cc][Tt][Dd][Aa][Tt][Aa]' -o \
    -name '*.[Ss][Aa][Rr][Ii][Ff]' -o \
    -name '*.[Ss][Tt][Aa][Tt][Ss]' -o \
    -name '*.[Ss][Tt][Rr][Ii][Nn][Gg][Ss][Dd][Aa][Tt][Aa]' -o \
    -name '*.[Ss][Uu][Bb][Ll][Ii][Mm][Ee]-[Bb][Uu][Ii][Ll][Dd]' -o \
    -name '*.[Ss][Uu][Bb][Ll][Ii][Mm][Ee]-[Cc][Oo][Ll][Oo][Rr]-[Ss][Cc][Hh][Ee][Mm][Ee]' -o \
    -name '*.[Ss][Uu][Bb][Ll][Ii][Mm][Ee]-[Cc][Oo][Mm][Mm][Aa][Nn][Dd][Ss]' -o \
    -name '*.[Ss][Uu][Bb][Ll][Ii][Mm][Ee]-[Cc][Oo][Mm][Pp][Ll][Ee][Tt][Ii][Oo][Nn][Ss]' -o \
    -name '*.[Ss][Uu][Bb][Ll][Ii][Mm][Ee]-[Kk][Ee][Yy][Mm][Aa][Pp]' -o \
    -name '*.[Ss][Uu][Bb][Ll][Ii][Mm][Ee]-[Mm][Aa][Cc][Rr][Oo]' -o \
    -name '*.[Ss][Uu][Bb][Ll][Ii][Mm][Ee]-[Mm][Ee][Nn][Uu]' -o \
    -name '*.[Ss][Uu][Bb][Ll][Ii][Mm][Ee]-[Mm][Oo][Uu][Ss][Ee][Mm][Aa][Pp]' -o \
    -name '*.[Ss][Uu][Bb][Ll][Ii][Mm][Ee]-[Pp][Rr][Oo][Jj][Ee][Cc][Tt]' -o \
    -name '*.[Ss][Uu][Bb][Ll][Ii][Mm][Ee]-[Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss]' -o \
    -name '*.[Tt][Ee][Rr][Nn]-[Pp][Rr][Oo][Jj][Ee][Cc][Tt]' -o \
    -name '*.[Tt][Ff][Ss][Tt][Aa][Tt][Ee]' -o \
    -name '*.[Tt][Ff][Ss][Tt][Aa][Tt][Ee].[Bb][Aa][Cc][Kk][Uu][Pp]' -o \
    -name '*.[Tt][Oo][Pp][Oo][Jj][Ss][Oo][Nn]' -o \
    -name '*.[Tt][Ss].[Mm][Aa][Pp]' -o \
    -name '*.[Tt][Ss][Bb][Uu][Ii][Ll][Dd][Ii][Nn][Ff][Oo]' -o \
    -name '*.[Ww][Ee][Bb][Aa][Pp][Pp]' -o \
    -name '*.[Ww][Ee][Bb][Mm][Aa][Nn][Ii][Ff][Ee][Ss][Tt]' -o \
    -name '*.[Xx][Aa][Mm][Ll][Ss][Tt][Yy][Ll][Ee][Rr]' -o \
    -name '*.[Xx][Cc][Ss][Cc][Mm][Bb][Ll][Uu][Ee][Pp][Rr][Ii][Nn][Tt]' -o \
    -name '*.[Xx][Cc][Tt][Ee][Ss][Tt][Pp][Ll][Aa][Nn]' -o \
    -name '*.[Yy][Tt][Dd][Ll]' -o \
    -name '*.[Yy][Yy]' -o \
    -name '*.[Yy][Yy][Pp]' -o \
    -name '*[Aa][Pp][Pp]-[Ss][Ii][Tt][Ee]-[Aa][Ss][Ss][Oo][Cc][Ii][Aa][Tt][Ii][Oo][Nn]' -o \
    -name '.[Aa][Ll][Ll]-[Cc][Oo][Nn][Tt][Rr][Ii][Bb][Uu][Tt][Oo][Rr][Ss][Rr][Cc]' -o \
    -name '.[Aa][Rr][Cc][Cc][Oo][Nn][Ff][Ii][Gg]' -o \
    -name '.[Aa][Uu][Tt][Oo]-[Cc][Hh][Aa][Nn][Gg][Ee][Ll][Oo][Gg]' -o \
    -name '.[Bb][Oo][Ww][Ee][Rr][Rr][Cc]' -o \
    -name '.[Cc]8[Rr][Cc]' -o \
    -name '.[Cc][Aa][Rr][Dd][Ii][Nn][Aa][Ll][Rr][Cc]' -o \
    -name '.[Cc][Oo][Uu][Cc][Hh][Aa][Pp][Pp][Rr][Cc]' -o \
    -name '.[Dd][Cc][Cc][Aa][Cc][Hh][Ee]' -o \
    -name '.[Dd][Oo][Cc][Kk][Ee][Rr][Cc][Ff][Gg]' -o \
    -name '.[Ee][Ss][Ll][Ii][Nn][Tt][Cc][Aa][Cc][Hh][Ee]' -o \
    -name '.[Ee][Ss][Ll][Ii][Nn][Tt][Rr][Cc]' -o \
    -name '.[Ff][Ll][Uu][Tt][Tt][Ee][Rr]' -o \
    -name '.[Ff][Ll][Uu][Tt][Tt][Ee][Rr]_[Tt][Oo][Oo][Ll]_[Ss][Tt][Aa][Tt][Ee]' -o \
    -name '.[Ff][Tt][Pp][Cc][Oo][Nn][Ff][Ii][Gg]' -o \
    -name '.[Gg][Uu][Tt][Tt][Ee][Rr]-[Tt][Hh][Ee][Mm][Ee]' -o \
    -name '.[Hh][Tt][Mm][Ll][Hh][Ii][Nn][Tt][Rr][Cc]' -o \
    -name '.[Ii][Mm][Gg][Bb][Oo][Tt][Cc][Oo][Nn][Ff][Ii][Gg]' -o \
    -name '.[Jj][Rr][Nn][Ll]_[Cc][Oo][Nn][Ff][Ii][Gg]' -o \
    -name '.[Jj][Ss][Cc][Ss][Rr][Cc]' -o \
    -name '.[Jj][Ss][Hh][Ii][Nn][Tt][Rr][Cc]' -o \
    -name '.[Nn][Yy][Cc][Rr][Cc]' -o \
    -name '.[Pp][Rr][Ee][Tt][Tt][Ii][Ee][Rr][Rr][Cc]' -o \
    -name '.[Rr][Ee][Mm][Aa][Rr][Kk][Rr][Cc]' -o \
    -name '.[Ss][Tt][Yy][Ll][Ee][Ll][Ii][Nn][Tt][Rr][Cc]' -o \
    -name '.[Tt][Ee][Rr][Nn]-[Cc][Oo][Nn][Ff][Ii][Gg]' -o \
    -name '.[Tt][Ee][Rr][Nn]-[Pp][Rr][Oo][Jj][Ee][Cc][Tt]' -o \
    -name '.[Tt][Ee][Xx][Tt][Ll][Ii][Nn][Tt][Rr][Cc]' -o \
    -name '.[Vv][Ss]-[Ll][Ii][Vv][Ee][Ss][Hh][Aa][Rr][Ee]-[Kk][Ee][Yy][Cc][Hh][Aa][Ii][Nn]' -o \
    -name '.[Vv][Ss][Cc][Oo][Nn][Ff][Ii][Gg]' -o \
    -name '.[Ww][Aa][Tt][Cc][Hh][Mm][Aa][Nn][Cc][Oo][Nn][Ff][Ii][Gg]' -o \
    -name '.[Ww][Hh][Ii][Tt][Ee][Ss][Oo][Uu][Rr][Cc][Ee]' -o \
    -name '.[Yy][Aa][Rr][Nn]-[Ii][Nn][Tt][Ee][Gg][Rr][Ii][Tt][Yy]' -o \
    -name '[Cc][Oo][Mm][Pp][Oo][Ss][Ee][Rr].[Ll][Oo][Cc][Kk]' -o \
    -name '[Dd][Ee][Nn][Oo].[Ll][Oo][Cc][Kk]' -o \
    -name '[Ee][Ss][Ll][Ii][Nn][Tt][Rr][Cc]' -o \
    -name '[Ff][Ll][Aa][Kk][Ee].[Ll][Oo][Cc][Kk]' -o \
    -name '[Mm][Cc][Mm][Oo][Dd].[Ii][Nn][Ff][Oo]' -o \
    -name '[Pp][Aa][Cc][Kk][Aa][Gg][Ee].[Rr][Ee][Ss][Oo][Ll][Vv][Ee][Dd]' -o \
    -name '[Pp][Ii][Pp][Ff][Ii][Ll][Ee].[Ll][Oo][Cc][Kk]' -o \
    -name '[Pp][Rr][Oo][Ss][Ee][Ll][Ii][Nn][Tt][Rr][Cc]' -o \
    -name '[Tt][Ll][Dd][Rr][Rr][Cc]' -o \
    ')' \
    -type f \
    -print 2>/dev/null
}

find_largest_files() {
  (
    command -p -- find -- . \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*copilot*' -prune -o \
      ! -name '.DS_Store' \
      -type f \
      -exec ls -n -S -- {} + 2>/dev/null &
  ) |
    command -p -- head -n "$((${LINES:-"$(
      command -p -- tput -- lines 2>/dev/null ||
        command -p -- printf -- '10 + 2'
    )"} - 3))" "${@-}"
}

find_markdown_files() {
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    '(' \
    -name '*.md' -o \
    -name '*.[Ll][Ii][Vv][Ee][Mm][Dd]' -o \
    -name '*.[Mm][Aa][Rr][Kk][Dd][Nn]' -o \
    -name '*.[Mm][Aa][Rr][Kk][Dd][Oo][Ww][Nn]' -o \
    -name '*.[Mm][Dd]' -o \
    -name '*.[Mm][Dd][Oo][Ww][Nn]' -o \
    -name '*.[Mm][Dd][Ww][Nn]' -o \
    -name '*.[Mm][Dd][Xx]' -o \
    -name '*.[Mm][Kk][Dd]' -o \
    -name '*.[Mm][Kk][Dd][Nn]' -o \
    -name '*.[Mm][Kk][Dd][Oo][Ww][Nn]' -o \
    -name '*.[Rr][Oo][Nn][Nn]' -o \
    -name '*.[Ss][Cc][Dd]' -o \
    -name '*.[Ww][Oo][Rr][Kk][Bb][Oo][Oo][Kk]' -o \
    -name '[Cc][Oo][Nn][Tt][Ee][Nn][Tt][Ss].[Ll][Rr]' \
    ')' \
    -type f \
    -print 2>/dev/null
}

find_microsoft_files() {
  command -p -- find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    '(' \
    -name '*.[Dd][Oo][Cc]' -o \
    -name '*.[Dd][Oo][Cc][Xx]' -o \
    -name '*.[Pp][Pp][Tt]' -o \
    -name '*.[Pp][Pp][Tt][Xx]' -o \
    -name '*.[Xx][Ll][Ss]' -o \
    -name '*.[Xx][Ll][Ss][Xx]' \
    ')' \
    -type f \
    -print 2>/dev/null
}

find_files_with_no_extension() {
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    ! -name '*.*' \
    ! -type d \
    -print 2>/dev/null
}
alias -- fnx='find_files_with_no_extension'

find_files_with_the_same_names() {
  LC_ALL='C' command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    ! -name '.DS_Store' \
    -type f \
    -exec sh -c 'for file in "${@-}"; do
  # treat all as identical: `file.txt`, `file 1.txt`, `file.text`
  #        was `basename -- "${file%.*}"`
  command -p -- basename "${file%[0-9]*.*}"
done
' _ {} + |
    LC_ALL='C' command -p -- sort |
    LC_ALL='C' command -p -- uniq -d

  LC_ALL='C' command find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    ! -name '.DS_Store' \
    -type f \
    -print |
    LC_ALL='C' command -p -- sed \
      -e '# convert "foo/bar.baz" into "bar"' \
      -e 's/.*\/\([^/]*\)\.[^.]*$/\1/' |
    LC_ALL='C' command -p -- sed \
      -e 's/ 1$//' |
    LC_ALL='C' command -p -- sort |
    LC_ALL='C' command -p -- uniq -d
}

find_files_with_the_same_sizes() {
  set \
    -o noglob
  LC_ALL='C' command -p -- find -- . \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    ! -name '.DS_Store' \
    -type f \
    ! -size 0 \
    -exec cksum -- {} + |
    # cksum prints 3+ columns; we want all but the first
    LC_ALL='C' command -p -- sed \
      -e 's/^[[:space:]]\{0,\}[[:digit:]]\{1,\}[[:space:]]\{1,\}\([[:digit:]]\{1,\}\)[[:space:]]\{1,\}\(.*\)$/\1 \2/' |
    LC_ALL='C' command -p -- sort -n |
    LC_ALL='C' command awk -- '{
  sizes[$1]++
  if (lines[$1]) {
    lines[$1] = lines[$1] RS $0
  } else {
    lines[$1] = $0
  }
}
END {
  for (size in sizes) {
    if (sizes[size] > 1) {
      # print duplicates in groups
      printf "\n%s\n", lines[size]
    }
  }
}'
  {
    set \
      +o noglob
  } 2>/dev/null
}
alias find_duplicate_sizes='find_files_with_the_same_sizes'
alias fds='find_files_with_the_same_sizes'

find_oldest_file() {
  (
    command -p -- find -- . \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -type f \
      -exec ls -o -r -t -- {} + 2>/dev/null &
  ) |
    command -p -- head -n "${1:-10}"
}

find_newest_file() {
  (
    command -p -- find -- . \
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
      ! -name "$(command -p -- printf -- 'Icon\015\012')" \
      ! -name '.DS_Store' \
      ! -name 'Desktop.ini' \
      ! -name 'desktop.ini' \
      ! -name 'Thumbs.db' \
      ! -name 'thumbs.db' \
      -type f \
      -exec ls -o -t -- {} + 2>/dev/null &
  ) |
    command -p -- head -n "${1:-10}"
}
alias -- fnf='find_newest_file'

find_perl_files() {
  # via `find_ruby_files` via `perltidy` 2024-08
  # using 2024-08 `linguist`
  {
    command -p -- find -- . \
      -path '*/.bundle' -prune -o \
      -path '*/.cabal-sandbox' -prune -o \
      -path '*/.cache' -prune -o \
      -path '*/.cask' -prune -o \
      -path '*/.git' -prune -o \
      -path '*/.hg' -prune -o \
      -path '*/.mypy_cache' -prune -o \
      -path '*/.pytest_cache' -prune -o \
      -path '*/.stack-work' -prune -o \
      -path '*/.svn' -prune -o \
      -path '*/.tox' -prune -o \
      -path '*/.venv' -prune -o \
      -path '*/.well-known' -prune -o \
      -path '*/Library' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*/t' -prune -o \
      -path '*/Test*' -prune -o \
      -path '*/test*' -prune -o \
      -path '*/tst*' -prune -o \
      -path '*/vendor' -prune -o \
      -path '*copilot*' -prune -o \
      -path '*dummy*' -prune -o \
      -path '*vscode*' -prune -o \
      -path './*' \
      '(' \
      -iname '*.pl' -o \
      -iname '*.6pl' -o \
      -iname '*.6pm' -o \
      -iname '*.al' -o \
      -iname '*.cgi' -o \
      -iname '*.fcgi' -o \
      -iname '*.nqp' -o \
      -iname '*.p6' -o \
      -iname '*.p6l' -o \
      -iname '*.p6m' -o \
      -iname '*.perl' -o \
      -iname '*.ph' -o \
      -iname '*.pl' -o \
      -iname '*.pl6' -o \
      -iname '*.plx' -o \
      -iname '*.pm' -o \
      -iname '*.pm6' -o \
      -iname '*.pod' -o \
      -iname '*.pod6' -o \
      -iname '*.psgi' -o \
      -iname '*.raku' -o \
      -iname '*.rakumod' -o \
      -iname '*.t' -o \
      -iname '.latexmkrc' -o \
      -iname 'ack' -o \
      -iname 'cpanfile' -o \
      -iname 'latexmkrc' -o \
      -iname 'Makefile.PL' -o \
      -iname 'Rexfile' \
      ')' \
      ! -type d \
      -print \
      2>/dev/null
    {
      utility="$(
        command -v -- github-linguist ||
          command -v -- git-linguist ||
          command -v -- linguist
      )"
      command -v -- "${utility-}" >/dev/null 2>&1 &&
        command "${utility-}" --breakdown -- . 2>/dev/null |
        command -p -- sed \
          -e '# print all lines from Perl: to the last line' \
          -e '1,/^Perl:/ d' \
          -e '# suppress lines after the first blank line' \
          -e '/^$/,$ d' \
          -e '# do not prepend each filename with ./' \
          -e '#        s/^/.\//' &&
        unset utility 2>/dev/null || utility=''
    } |
      command -p -- sed \
        -e '# prepend each line with dot slash without command -p awk upsetting SC2016' \
        -e 's/^/.\//'
  } |
    LC_ALL='C' command -p -- sort -u |
    LC_ALL='C' command -p -- sort -f
}

find_animated_png() {
  command -p -- find -- . \
    -path '*/.git' -prune \
    -o -path './*' \
    -name '*.[Pp][Nn][Gg]' \
    -type f \
    -exec file -- {} + |
    command -p -- sed \
      -n \
      -e '/: *PNG .*animated/ {' \
      -e '  s/:.*//p' \
      -e '}'
}
alias find_png_animated='find_animated_png'

find_powershell_files() {
  command find -- . \
    '(' \
    -name '*.ps1' -o \
    -name '*.[Pp][Ss]1' -o \
    -name '*.[Pp][Ss][Dd]1' -o \
    -name '*.[Pp][Ss][Mm]1' -o \
    -name '*.[Pp][Ss][Rr][Cc]' -o \
    -name '*.[Pp][Ss][Ss][Cc]' \
    ')' \
    ! -type d \
    -print 2>/dev/null
}

find_ruby_files() {
  {
    # https://github.com/github-linguist/linguist/blob/2b40a3acbd/lib/linguist/languages.yml#L6022-L6079
    command find -- . \
      -path '*/.bundle' -prune -o \
      -path '*/.cabal-sandbox' -prune -o \
      -path '*/.cache' -prune -o \
      -path '*/.cask' -prune -o \
      -path '*/.git' -prune -o \
      -path '*/.hg' -prune -o \
      -path '*/.mypy_cache' -prune -o \
      -path '*/.pytest_cache' -prune -o \
      -path '*/.stack-work' -prune -o \
      -path '*/.svn' -prune -o \
      -path '*/.tox' -prune -o \
      -path '*/.venv' -prune -o \
      -path '*/.well-known' -prune -o \
      -path '*/Library' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*/t' -prune -o \
      -path '*/Test*' -prune -o \
      -path '*/test*' -prune -o \
      -path '*/tst*' -prune -o \
      -path '*/vendor' -prune -o \
      -path '*copilot*' -prune -o \
      -path '*dummy*' -prune -o \
      -path '*vscode*' -prune -o \
      -path './*' \
      '(' \
      -name '*.rb' -o \
      -name '.Brewfile' -o \
      -name '.irbrc' -o \
      -name '.pryrc' -o \
      -name '.simplecov' -o \
      -name '*.builder' -o \
      -name '*.eye' -o \
      -name '*.fcgi' -o \
      -name '*.gemspec' -o \
      -name '*.god' -o \
      -name '*.jbuilder' -o \
      -name '*.mspec' -o \
      -name '*.pluginspec' -o \
      -name '*.podspec' -o \
      -name '*.prawn' -o \
      -name '*.rabl' -o \
      -name '*.rake' -o \
      -name '*.rbi' -o \
      -name '*.rbuild' -o \
      -name '*.rbw' -o \
      -name '*.rbx' -o \
      -name '*.ru' -o \
      -name '*.ruby' -o \
      -name '*.spec' -o \
      -name '*.thor' -o \
      -name '*.watchr' -o \
      -name 'Appraisals' -o \
      -name 'Berksfile' -o \
      -name 'Brewfile' -o \
      -name 'buildfile' -o \
      -name 'Buildfile' -o \
      -name 'Capfile' -o \
      -name 'Dangerfile' -o \
      -name 'Deliverfile' -o \
      -name 'Fastfile' -o \
      -name 'Gemfile' -o \
      -name 'Guardfile' -o \
      -name 'Jarfile' -o \
      -name 'Mavenfile' -o \
      -name 'Podfile' -o \
      -name 'Puppetfile' -o \
      -name 'Rakefile' -o \
      -name 'Snapfile' -o \
      -name 'Steepfile' -o \
      -name 'Thorfile' -o \
      -name 'Vagrantfile' \
      ')' \
      ! -type d \
      -print \
      2>/dev/null
    {
      utility="$(
        command -v -- github-linguist ||
          command -v -- git-linguist ||
          command -v -- linguist
      )"
      command -v -- "${utility-}" >/dev/null 2>&1 &&
        command "${utility-}" --breakdown -- . 2>/dev/null |
        command -p -- sed \
          -e '# print all lines from Ruby: to the last line' \
          -e '1,/^Ruby:/ d' \
          -e '# suppress lines after the first blank line' \
          -e '/^$/,$ d' \
          -e '# [do not] prepend each filename with ./' \
          -e '# s/^/.\//' &&
        unset utility 2>/dev/null || utility=''
      command rubocop \
        --list-target-files
    } |
      command awk -- '{print "./" $0}'
  } |
    LC_ALL='C' command -p -- sort -u |
    LC_ALL='C' command -p -- sort -f
}

find_setup_files() {

  # Dries; Lucas
  # ./fresh.sh
  # ./setup/init.sh

  # https://github.com/github/docs/commit/4c19eec5df
  # ./install.sh
  # ./install
  # ./bootstrap.sh
  # ./bootstrap
  # ./script/bootstrap
  # ./setup.sh
  # ./setup
  # ./script/setup

  command find -- "${1:-.}" \
    -name '.git' \
    -print 2>/dev/null | while IFS='' read -r -- git_file; do
    command find -- "${1:-.}" \
      '(' \
      -path "${git_file%/*}"'/install.sh' -o \
      -path "${git_file%/*}"'/install' -o \
      -path "${git_file%/*}"'/bootstrap.sh' -o \
      -path "${git_file%/*}"'/bootstrap' -o \
      -path "${git_file%/*}"'/script/bootstrap' -o \
      -path "${git_file%/*}"'/setup.sh' -o \
      -path "${git_file%/*}"'/setup' -o \
      -path "${git_file%/*}"'/script/setup' \
      ')' \
      ! -type d \
      -print \
      2>/dev/null
  done
}
alias -- find_bootstrap_files='find_setup_files'

find_setup_files_delete_others() {

  # Dries; Lucas
  # ./fresh.sh
  # ./setup/init.sh

  # https://github.com/github/docs/commit/4c19eec5df
  # ./install.sh
  # ./install
  # ./bootstrap.sh
  # ./bootstrap
  # ./script/bootstrap
  # ./setup.sh
  # ./setup
  # ./script/setup

  command find -- "${1:-.}" \
    -name '.git' \
    -print 2>/dev/null | while IFS='' read -r -- git_file; do
    command find -- "${1:-.}" \
      '(' \
      -path "${git_file%/*}"'/install.sh' -o \
      -path "${git_file%/*}"'/install' -o \
      -path "${git_file%/*}"'/bootstrap.sh' -o \
      -path "${git_file%/*}"'/bootstrap' -o \
      -path "${git_file%/*}"'/script/bootstrap' -o \
      -path "${git_file%/*}"'/setup.sh' -o \
      -path "${git_file%/*}"'/setup' -o \
      -path "${git_file%/*}"'/script/setup' \
      ')' \
      ! -type d \
      -print \
      2>/dev/null
  done
}

find_shell_scripts() {
  command git rev-parse >/dev/null 2>&1 || return "${?:-1}"
  cd -- "$(
    command git rev-parse --show-toplevel --path-format=relative |
      command -p -- sed -e '1 q'
  )" 2>/dev/null ||
    cd -- "$(
      command git rev-parse --show-toplevel
    )" ||
    cd -- "${PWD%/}" || # 😬
    return "${?:-1}"
  # @TODO because this appears to work even outside a Git repository
  # exit 1

  {
    # all files with `linguist` Shell filename extensions
    command find -- . \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      '(' \
      -path '*/etc/profile' -o \
      -path '*/bat/config' -o \
      -name '*.ash' -o \
      -name '*.bash' -o \
      -name '*.bash_aliases' -o \
      -name '*.bash_completions' -o \
      -name '*.bash_functions' -o \
      -name '*.bash_history' -o \
      -name '*.bash_login' -o \
      -name '*.bash_logout' -o \
      -name '*.bash_profile' -o \
      -name '*.bash_variables' -o \
      -name '*.bashrc' -o \
      -name '*.bats' -o \
      -name '*.cgi' -o \
      -name '*.command' -o \
      -name '*.cshrc' -o \
      -name '*.dash' -o \
      -name '*.ebuild' -o \
      -name '*.eclass' -o \
      -name '*.env' -o \
      -name '*.env.example' -o \
      -name '*.envrc' -o \
      -name '*.fcgi' -o \
      -name '*.flaskenv' -o \
      -name '*.ksh' -o \
      -name '*.kshrc' -o \
      -name '*.login' -o \
      -name '*.logout' -o \
      -name '*.mksh' -o \
      -name '*.pdksh' -o \
      -name '*.profile' -o \
      -name '*.rc' -o \
      -name '*.sh' -o \
      -name '*.sh.in' -o \
      -name '*.textmate_init' -o \
      -name '*.tmux' -o \
      -name '*.tmux.conf' -o \
      -name '*.tool' -o \
      -name '*.zlogin' -o \
      -name '*.zlogout' -o \
      -name '*.zprofile' -o \
      -name '*.zsh' -o \
      -name '*.zsh-theme' -o \
      -name '*.zshenv' -o \
      -name '*.zshrc' -o \
      -name '9fs' -o \
      -name 'APKBUILD' -o \
      -name 'bash_aliases' -o \
      -name 'bash_functions' -o \
      -name 'bash_login' -o \
      -name 'bash_logout' -o \
      -name 'bash_profile' -o \
      -name 'bashrc' -o \
      -name 'cshrc' -o \
      -name 'ebuild' -o \
      -name 'eclass' -o \
      -name 'envrc' -o \
      -name 'gradlew' -o \
      -name 'kshrc' -o \
      -name 'login' -o \
      -name 'man' -o \
      -name 'os-release' -o \
      -name 'PKGBUILD' -o \
      -name 'profile' -o \
      -name 'tmux.conf' -o \
      -name 'zlogin' -o \
      -name 'zlogout' -o \
      -name 'zprofile' -o \
      -name 'zshenv' -o \
      -name 'zshrc' \
      ')' \
      -type f \
      -print 2>/dev/null

    # files whose first lines resemble those of shell scripts,
    # but whose filenames do not (do not search the first line of scripts named `.sh` for example)
    # https://stackoverflow.com/a/9612232
    # https://stackoverflow.com/q/307015#comment14013364_307154
    # https://unix.stackexchange.com/a/480738
    # https://github.com/super-linter/super-linter/commit/4faa6433ab the `! ( ... )` lines, which are barely faster than normal prune
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
      -path '*/etc/profile' -prune -o \
      -path '*/bat/config' -prune -o \
      -path './*' \
      -type f \
      -exec sh -c 'LC_ALL='\''C'\'' command -p -- sed -e '\''# does the first non-empty line resemble a shell directive?'\'' -e '\''/./,$! d'\'' -e '\''1 q'\'' "${1-}" | command -p -- grep -e '\''^#!.*bin.*[^c]sh'\'' -e '\''^[[:space:]]*\(function[[:space:]]\)\{0,1\}[[:space:]]*[A-Za-z_][-A-Za-z_0-9]*()[[:space:]]*{.*$'\'' -e '\''autoload'\'' -e '\''compdef'\'' -e '\''openrc'\'' >/dev/null 2>&1 && command -p -- printf -- '\''%s\n'\'' "${1-}"' _ {} ';'

    ## combine `shfmt -f` and `linguist --breakdown`:
    # - they both require a prepended `./`
    # - send errors for both to `/dev/null` once
    {
      command shfmt --find -- .

      # https://github.com/bzz/LangID/blob/37c4960/README.md#collect-the-data
      command github-linguist --breakdown -- . | # --json -- . |

        # https://web.archive.org/web/20210904183309id_/earthly.dev/blog/jq-select/#cb22
        # https://github.com/stedolan/jq/issues/1735#issuecomment-427863218
        # command jq --raw-output '.Shell.files[]' # |
        command -p -- sed \
          -e '# print all lines from Shell: to the last line' \
          -e '1,/^Shell:/ d' \
          -e '# suppress lines after the first blank line' \
          -e '/^$/,$ d' \
          -e '# [do not] prepend each filename with ./ because that is done below' \
          -e '# s/^/.\//' \
          -e '# until Linguist learns that Fish is not Shell' \
          -e '/\.fish$/ d'
    } 2>/dev/null |

      # prepend filenames with `./`
      command awk -- '{print "./" $0}'
    # @TODO!: consider alternatively `sed -e 's/^\(\.\/\)\{0,1\}/.\/&/'` to prepend `./` to each line iff it needs it
    # @TODO!consider additionally `grep -v` to hide unwanted results faster

  } |
    command awk -- '! seen[$0]++ {print}'
}

find_smallest_files() {
  (
    command -p -- find -- . \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      ! -name '.DS_Store' \
      -type f \
      -exec ls -n -r -S -- {} + 2>/dev/null &
  ) |
    command -p -- head -n "$((${LINES:-"$(
      command -p -- tput -- lines 2>/dev/null ||
        command -p -- printf -- '10 + 2'
    )"} - 3))" "${@-}"
}

find_symlinks() {
  # find all symlinks to a file
  # https://stackoverflow.com/a/6185052
  # command sudo -- find -L -- / -samefile /usr/local/Cellar/rbenv/1.2.0/completions/rbenv.zsh 2>/dev/null

  set \
    -o verbose \
    -o xtrace
  # GPT
  target="$(command realpath -- "${1-}")"
  export target
  command find -L -- "${2:-.}" \
    -exec sh -c 'command -p -- test "$(command -p -- realpath -- "${1-}")" = "${target-}" && command -p -- printf -- '\''%s\n'\'' "${1-}"' _ {} ';'
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
  unset target 2>/dev/null || target=''

  command -p -- printf -- 'all symlinks to and from files in this directory or its subdirectories\n' >&2
  command find -L -- . \
    -type l \
    -exec find -L -- . -samefile {} ';' \
    -exec printf -- '\n' ';' 2>&1 |
    while IFS='' read -r -- file; do
      command ls -A -F -g -o --color=always -- "${file-}" 2>&1 |
        command -p -- sed -e '/: No such file or directory/d'
    done

  command -p -- test "${#}" -gt 0 ||
    return 0
  command -p -- printf -- 'all symlinks in the current directory or below to the specific file %s\n' "${1-}" >&2
  command find -L -- . -samefile "${1-}" 2>/dev/null

  command -p -- test "${#}" -gt 1 ||
    return 0
  command -p -- printf -- 'all symlinks in all directories to the specific file %s\n' "${2-}" >&2
  command find -L -- / -samefile "${2-}" 2>/dev/null
}

find_text_files() {
  {
    command find -- . \
      -path '*/.git' -prune -o \
      -path '*/.well-known' -prune -o \
      -path '*/Empty*' -prune -o \
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
      -name '*.txt' -o \
      -name '*.crc32' -o \
      -name '*.fr' -o \
      -name '*.md2' -o \
      -name '*.md4' -o \
      -name '*.md5' -o \
      -name '*.nb' -o \
      -name '*.ncl' -o \
      -name '*.no' -o \
      -name '*.sha1' -o \
      -name '*.sha2' -o \
      -name '*.sha224' -o \
      -name '*.sha256' -o \
      -name '*.sha256sum' -o \
      -name '*.sha3' -o \
      -name '*.sha384' -o \
      -name '*.sha512' -o \
      -name 'checksums.txt' -o \
      -name 'CITATION' -o \
      -name 'CITATIONS' -o \
      -name 'cksums' -o \
      -name 'click.me' -o \
      -name 'COPYING' -o \
      -name 'COPYING.regex' -o \
      -name 'COPYRIGHT.regex' -o \
      -name 'delete.me' -o \
      -name 'FONTLOG' -o \
      -name 'INSTALL' -o \
      -name 'INSTALL.mysql' -o \
      -name 'keep.me' -o \
      -name 'LICENSE' -o \
      -name 'LICENSE.mysql' -o \
      -name 'md5sum.txt' -o \
      -name 'MD5SUMS' -o \
      -name 'NEWS' -o \
      -name 'package.mask' -o \
      -name 'package.use.mask' -o \
      -name 'package.use.stable.mask' -o \
      -name 'read.me' -o \
      -name 'readme.1st' -o \
      -name 'README.me' -o \
      -name 'README.mysql' -o \
      -name 'README.nss' -o \
      -name 'SHA1SUMS' -o \
      -name 'SHA256SUMS' -o \
      -name 'SHA256SUMS.txt' -o \
      -name 'SHA512SUMS' -o \
      -name 'test.me' -o \
      -name 'use.mask' -o \
      -name 'use.stable.mask' \
      ')' \
      -type f \
      -print
    # find text files https://stackoverflow.com/a/6419372
    # find one or more spaces without extended regex https://unix.stackexchange.com/a/19016
    command find -- . \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -path './*' \
      -type f \
      -exec file -- {} + |
      command -p -- sed \
        -n \
        -e '/: \{1,\}ASCII text$/ s/: \{1,\}ASCII text$//p'
  } |
    LC_ALL='C' command -p -- sort -u |
    LC_ALL='C' command -p -- sort -f
}

find_video_files() {
  # these are all the extensions of video files supported by Google Drive
  # ∴ that’s everything
  # also includes `eza`’s `Icons::VIDEO`
  command -p -- find -- . \
    -path '*/.git' -prune -o \
    -path '*/Library' -prune -o \
    -path '*/node_modules' -prune -o \
    '(' \
    -name '*.3[Gg][Pp]' -o \
    -name '*.3[Gg][Pp][Pp]' -o \
    -name '*.[Aa][Vv][Ii]' -o \
    -name '*.[Dd][Ii][Vv]' -o \
    -name '*.[Dd][Ii][Vv][Xx]' -o \
    -name '*.[Ff][Ll][Vv]' -o \
    -name '*.[Hh]264' -o \
    -name '*.[Hh][Ee][Ii][Cc][Ss]' -o \
    -name '*.[Mm]2[Tt][Ss]' -o \
    -name '*.[Mm]2[Vv]' -o \
    -name '*.[Mm]4[Pp]' -o \
    -name '*.[Mm]4[Vv]' -o \
    -name '*.[Mm][Kk][Vv]' -o \
    -name '*.[Mm][Oo][Vv]' -o \
    -name '*.[Mm][Pp]4' -o \
    -name '*.[Mm][Pp][Ee]' -o \
    -name '*.[Mm][Pp][Ee][Gg]' -o \
    -name '*.[Mm][Pp][Ee][Gg]4' -o \
    -name '*.[Mm][Pp][Ee][Gg][Pp][Ss]' -o \
    -name '*.[Mm][Pp][Gg]' -o \
    -name '*.[Mm][Pp][Gg]4' -o \
    -name '*.[Mm][Tt][Ss]' -o \
    -name '*.[Oo][Gg][Mm]' -o \
    -name '*.[Oo][Gg][Vv]' -o \
    -name '*.[Rr][Ee][Cc]' -o \
    -name '*.ts will not always be a video file, but if you are already performing that search, then you want exhaustive results' -o \
    -name '*.[Tt][Ss]' -o \
    -name '*.[Vv][Ii][Dd][Ee][Oo]' -o \
    -name '*.[Vv][Oo][Bb]' -o \
    -name '*.[Ww][Ee][Bb][Mm]' -o \
    -name '*.[Ww][Mm][Vv]' \
    ')' \
    -type f \
    -print 2>/dev/null
}

find_xargs() {
  # https://etalabs.net/sh_tricks.html
  {
    command -p -- printf -- '#!/usr/bin/env sh\n' >&2
    command -p -- printf -- '# find | xargs\n' >&2
    command -p -- printf -- '# https://etalabs.net/sh_tricks.html\n' >&2
    command -p -- printf -- ' command -p -- find -- . \\\n' >&2
    command -p -- printf -- '  # "\044{arguments-}"\n' >&2
    command -p -- printf -- '  -print 2>&1 | ' >&2
    command -p -- printf -- 'command -p -- sed' >&2
    command -p -- printf -- ' -e \047s/./\\\\&/g\047' >&2
    command -p -- printf -- ' | ' >&2
    command -p -- printf -- 'command -p -- xargs \\\n' >&2
    command -p -- printf -- '  # "\044{command-}"\n' >&2
  } 2>&1 | {
    command bat \
      --decorations=never \
      --language=sh \
      --paging=never \
      -- \
      - 2>/dev/null ||
      command -p -- cat \
        -- \
        -
  }
}

find_yaml_files() {
  command find -- . \
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
    -name '.clangd' -o \
    -name '.gemrc' -o \
    -name '.yamllint' -o \
    -name 'docker_fish_history' -o \
    -name 'fish_history' -o \
    -name 'glide.lock' -o \
    -name 'pixi.lock' -o \
    -name 'yarn.lock' \
    ')' \
    ! -type d \
    -print \
    2>/dev/null
}

## first
first_word() {
  # print the first word of a string
  # https://unix.stackexchange.com/a/201744
  # much faster than `awk`, `cut`, `sed` (when using the builtin)
  while command -p -- test "${#}" -gt 0; do
    command -p -- printf -- '%s\n' "${1%% *}"
    shift 1
  done
}
first_character() {
  while command -p -- test "${#}" -gt 0; do
    # https://stackoverflow.com/a/27791633
    command -p -- printf -- '%.1s\n' "${1-}"
    shift 1
  done
}

fish_r() {
  PS4=' ' command find -- . \
    -name '*.fish' \
    -type f \
    -exec sh -x -c 'for file in "${@-}"; do
command git ls-files --error-unmatch -- "${file-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command fish_indent --write -- "${file-}"
done' _ {} +
}

flawfinder_install() {
  # https://github.com/awdeorio/dotfiles/commit/a46000d807
  set -- 'git+https://github.com/david-a-wheeler/flawfinder@master'
  command brew install --HEAD --verbose -- "$(command -p -- basename -- "${1%%@*}")" ||
    command python -m pip install --upgrade --verbose -- "${1-}" ||
    command python3 -m pip3 install --upgrade --verbose -- "${1-}"
}
flawfinder_r() {
  command -v -- flawfinder >/dev/null 2>&1 ||
    # EX_UNAVAILABLE
    return 69
  IFS=' ' command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.rbenv' -prune -o \
    -path '*/.venv' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/__pycache__' -prune -o \
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
    -name '*.ada' -o \
    -name '*.adb' -o \
    -name '*.ads' -o \
    -name '*.asm' -o \
    -name '*.ast' -o \
    -name '*.bc' -o \
    -name '*.C' -o \
    -name '*.C.in' -o \
    -name '*.c' -o \
    -name '*.c.in' -o \
    -name '*.C++' -o \
    -name '*.c++' -o \
    -name '*.c++m' -o \
    -name '*.cake' -o \
    -name '*.cats' -o \
    -name '*.CC' -o \
    -name '*.cc' -o \
    -name '*.cc.in' -o \
    -name '*.ccm' -o \
    -name '*.cl' -o \
    -name '*.clcpp' -o \
    -name '*.cp' -o \
    -name '*.CPP' -o \
    -name '*.cpp' -o \
    -name '*.CPP.in' -o \
    -name '*.cpp.in' -o \
    -name '*.cppm' -o \
    -name '*.CS' -o \
    -name '*.cs' -o \
    -name '*.csx' -o \
    -name '*.cu' -o \
    -name '*.cuh' -o \
    -name '*.cui' -o \
    -name '*.CXX' -o \
    -name '*.cxx' -o \
    -name '*.CXX.in' -o \
    -name '*.cxx.in' -o \
    -name '*.cxxm' -o \
    -name '*.ec' -o \
    -name '*.ecp' -o \
    -name '*.edc' -o \
    -name '*.F' -o \
    -name '*.f' -o \
    -name '*.F03' -o \
    -name '*.f03' -o \
    -name '*.F08' -o \
    -name '*.f08' -o \
    -name '*.F77' -o \
    -name '*.f77' -o \
    -name '*.F90' -o \
    -name '*.f90' -o \
    -name '*.F95' -o \
    -name '*.f95' -o \
    -name '*.FOR' -o \
    -name '*.for' -o \
    -name '*.FPP' -o \
    -name '*.fpp' -o \
    -name '*.gch' -o \
    -name '*.gml' -o \
    -name '*.H' -o \
    -name '*.h' -o \
    -name '*.H.in' -o \
    -name '*.h.in' -o \
    -name '*.h++' -o \
    -name '*.hh' -o \
    -name '*.hh.in' -o \
    -name '*.hip' -o \
    -name '*.hlsl' -o \
    -name '*.HP' -o \
    -name '*.hp' -o \
    -name '*.HPP' -o \
    -name '*.hpp' -o \
    -name '*.HPP.in' -o \
    -name '*.hpp.in' -o \
    -name '*.hxx' -o \
    -name '*.hxx.in' -o \
    -name '*.i' -o \
    -name '*.idc' -o \
    -name '*.ifs' -o \
    -name '*.ii' -o \
    -name '*.iih' -o \
    -name '*.iim' -o \
    -name '*.inc' -o \
    -name '*.inl' -o \
    -name '*.ino' -o \
    -name '*.ipp' -o \
    -name '*.ixx' -o \
    -name '*.jav' -o \
    -name '*.java' -o \
    -name '*.jsh' -o \
    -name '*.lib' -o \
    -name '*.linq' -o \
    -name '*.ll' -o \
    -name '*.M' -o \
    -name '*.m' -o \
    -name '*.metal' -o \
    -name '*.mi' -o \
    -name '*.mii' -o \
    -name '*.MM' -o \
    -name '*.mm' -o \
    -name '*.nut' -o \
    -name '*.pcc' -o \
    -name '*.pch' -o \
    -name '*.pcm' -o \
    -name '*.pfo' -o \
    -name '*.pgc' -o \
    -name '*.protodevel' -o \
    -name '*.re' -o \
    -name '*.S' -o \
    -name '*.s' -o \
    -name '*.tcc' -o \
    -name '*.td' -o \
    -name '*.tlh' -o \
    -name '*.tli' -o \
    -name '*.tpp' -o \
    -name '*.ts' -o \
    -name '*.cts' -o \
    -name '*.mts' -o \
    -name '*.tsx' -o \
    -name '*.txx' -o \
    -name '*.xbm' -o \
    -name '*.xpm' \
    ')' \
    -type f \
    -exec sh -C -e -f -u -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command flawfinder --error-level=1 --minlevel=0 -- "${1-}"
' _ {} ';' 2>&1
}

## font
font_bold() {
  { { command -p -- test "${#}" -eq 0 && command -p -- cat -- -; } || command -p -- printf -- '%s' "${*-}"; } |
    IFS='' command -p -- tr \
      -- \
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ' \
      '𝗔𝗕𝗖𝗗𝗘𝗙𝗚𝗛𝗜𝗝𝗞𝗟𝗠𝗡𝗢𝗣𝗤𝗥𝗦𝗧𝗨𝗩𝗪𝗫𝗬𝗭𝗮𝗯𝗰𝗱𝗲𝗳𝗴𝗵𝗶𝗷𝗸𝗹𝗺𝗻𝗼𝗽𝗾𝗿𝘀𝘁𝘂𝘃𝘄𝘅𝘆𝘇 ' &&
    command -p -- printf -- '\n' >&2
}
alias -- bold='font_bold'
font_italic() {
  { { command -p -- test "${#}" -eq 0 && command -p -- cat -- -; } || command -p -- printf -- '%s' "${*-}"; } |
    IFS='' command -p -- tr \
      -- \
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ' \
      '𝘈𝘉𝘊𝘋𝘌𝘍𝘎𝘏𝘐𝘑𝘒𝘓𝘔𝘕𝘖𝘗𝘘𝘙𝘚𝘛𝘜𝘝𝘞𝘟𝘠𝘡𝘢𝘣𝘤𝘥𝘦𝘧𝘨𝘩𝘪𝘫𝘬𝘭𝘮𝘯𝘰𝘱𝘲𝘳𝘴𝘵𝘶𝘷𝘸𝘹𝘺𝘻 ' &&
    command -p -- printf -- '\n' >&2
}
alias -- italic='font_italic'

get_github_stars() {
  while command -p -- test "${#}" -gt 0; do
    set -- 'https://api.github.com/repos/'"${1-}" &&
      {
        command curl --location --show-error --silent --url "${1-}" ||
        command wget --hsts-file=/dev/null --output-document=- --quiet -- "${1-}" ||
          return "${?:-1}"
      } 2>/dev/null |
        command -p -- sed \
          -n \
          -e 's/.*"stargazers_count":[^[:digit:]]*\([[:digit:]][[:digit:]]*\).*/\1/p'
    shift
  done
}

## GIF
to_gif() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command ffmpeg \
      -ss 0 \
      -i "${file-}" \
      -vf 'scale='"$(command exiftool -ImageWidth -short -short -short -- "${file-}")"':-1:flags=lanczos' \
      -loop 0 \
      -- \
      "${file%.*}"'.gif'
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}
gif_webp_r() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command gif2webp \
      -q 100 \
      -m 6 \
      -metadata all \
      -loop_compatibility \
      -mt \
      -v \
      "${file-}" \
      -o \
      "${file-}"'.webp'
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

# Git
alias -- g >/dev/null 2>&1 &&
  unalias -- g
# `#compdef` instead of `compdef`?
# https://github.com/zph/dotfiles/blob/735c49534e/home/dot_zsh.d/git.zsh
command -v -- _git >/dev/null 2>&1 &&
  compdef -- g='git' &&
  #compdef _git gm=git-merge &&
  #compdef _git gd=git-diff &&
  #compdef _git gds=git-diff
  g() {
    case "${1-}" in
    clone | config | help | init | version | -*)
      command git "${@-}"
      ;;
    *)
      command git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
        return "${?:-1}"
      # if first argument is a file, then perform `git status` on it
      if command -p -- test -e "${1-}"; then
        command git status -- "${@-}"
      else
        command git -c color.status=always -c core.quotePath=false "${@:-status}" |
          command -p -- sed \
            -e '$ d'
      fi
      ;;
    esac
  }
alias -- \
  g.='command git -c color.status=auto -c core.quotePath=false status .' \
  gss='command git -c color.status=auto -c core.quotePath=false status --porcelain=v1'
guo() {
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command -p -- sed \
      -e '$ d'
}

# git add
git_add() {
  case "${1-}" in
  -p | --patch)
    shift
    command git add --verbose --patch "${@:-.}"
    ;;
  -A | --all)
    # to prevent data loss as much as possible,
    # first add non-repository files
    git_add --others &&
      # then add modified files
      git_add --modified &&
      shift
    ;;
  -D | --deleted)
    # https://gist.github.com/8775224
    command git ls-files -z --deleted |
      LC_ALL='C' command -p -- tr -- '\0' '\n' |
      while IFS='' read -r -- file; do
        # `git-rm`(1) instead of `git-add`(1) for fewer errors and because
        # there is no risk of losing files that are indexed but already removed
        command git rm -- "${file-}"
      done &&
      shift
    ;;
  -m | --modified | --update)
    shift &&
      command git add --update --verbose -- "${@:-.}"
    ;;
  -o | --others | --untracked)
    while command -p -- test "$(command git ls-files -z --exclude-standard --others)" != ''; do
      command git ls-files -z --exclude-standard --others |
        LC_ALL='C' command -p -- tr -- '\0' '\n' |
        while IFS='' read -r -- file; do
          command git add --verbose -- "${file-}"
        done
    done &&
      shift
    ;;
  '')
    command git add --verbose --patch -- .
    ;;
  *)
    # do not default to everything in the current directory and below
    command git add --verbose "${@-}"
    ;;
  esac &&
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command -p -- sed \
      -e '$ d'
}
alias -- \
  ga='git_add' \
  gaa='git_add --all' \
  gaaa='git_add --all --force' \
  gaf='git_add --force' \
  gao='git_add --others' \
  gap='git_add --patch' \
  gpa='gap' \
  gau='git_add --modified' \
  git_add_deleted='git_add --deleted' \
  git_add_modified='git_add --modified' \
  git_add_others='git_add --others' \
  git_add_patch='git_add --patch' \
  git_add_untracked='git_add --others' \
  git_rm_missing_files='git_add --deleted'

git_all_files_ever() {
  # list all files that ever existed in the repository
  # inspiration: https://gist.github.com/8775224
  # -A: all added
  # -a: all not added
  # -B: all broken
  # -b: all not broken
  # -C: all copied
  # -c: all not copied
  # -D: all deleted
  # -d: all not deleted
  # -M: all modified
  # -m: all not modified
  # -R: all renamed
  # -r: all not renamed
  # -T: all type changed
  # -t: all type not changed
  # -U: all unmerged
  # -u: all not unmerged
  # -X: all unknown
  # -x: all not unknown
  command git -c core.quotePath=false log \
    --all \
    --diff-filter="${1-}" \
    --find-copies \
    --find-renames \
    --format='' \
    --name-only |
    # print only unique, non-blank entries and prepend them with dot-slash
    command awk -- '! seen[$0]++ && $0 != "" {print "./" $0}' |
    LC_ALL='C' command -p -- sort -f
}

git_attic() {
  # git-attic [-M] [PATH] - list deleted files of Git repositories
  # https://web.archive.org/web/0id_/chneukirchen.org/dotfiles/bin/git-attic
  # Use `-M` to hide renamed files, and other git-log(1) options as you like.
  # The output is designed to be copied and pasted: Pass the second field to
  # git show to display the file contents, or just select the hash without ^ to
  # see the commit where removal happened
  command git log --date=short --diff-filter=D --no-renames --raw --format='%h %cd' "${@-}" |
    # note that this will not work for files with spaces nor will it work for
    # deleted files unless they’re prepended with an end-of-options delimiter
    # even with more careful single quotes, which are commented because they
    # only appear to fix the problem, but were complicated to add to the Awk command
    #       awk -- '/^[[:xdigit:]]/ {commit = $1; date = $2} /^:/ && $5 == "D" {print date, commit "'\''^'\'':'\'./'" $6 "'\''"}' |
    command awk -- '/^[[:xdigit:]]/ {commit = $1; date = $2} /^:/ && $5 == "D" {print date, commit "'\''^'\'':./" $6}' |
    LC_ALL='C' command -p -- sort -r -u
}

# git blame
alias -- gblame='command git blame'

alias -- \
  gba='command git branch --all' \
  gbD='command git branch --delete --force'

git_branches_by_date() {
  command git for-each-ref --format='%(committerdate:format:%F) %(refname:short)' refs/heads |
    LC_ALL='C' command -p -- sort -n
  command -p -- printf -- '\n ———\n\n' >&2
  command git for-each-ref --format='%(committerdate:format:%F) %(refname:short)' refs/remotes |
    LC_ALL='C' command -p -- sort -n
}

# git checkout more safely
gco() {
  case "${1-}" in
  '.')
    number_of_changed_files="$(
      command git -c core.ignoreCase=false -c core.quotePath=false status \
        -z \
        --ignore-submodules \
        --porcelain=v2 \
        --untracked-files=no |
        LC_ALL='C' IFS='' command -p -- tr -- '\0' '\n' |
        command -p -- grep \
          -c \
          -e '^1 \.D ' \
          -e '^1 \.M ' \
          -e '^1 \.T '
    )"
    if command -p -- test "${number_of_changed_files:-5}" -ge 5; then
      command -p -- printf -- 'warning: too many modified files; check them out atomically\n' >&2
      unset number_of_changed_files 2>/dev/null || number_of_changed_files=''
      return 1
    elif command -p -- test "${number_of_changed_files:-5}" -ge 0 &&
      command -p -- test "${number_of_changed_files:-5}" -le 5; then
      command git checkout --progress "${@-}"
    else
      unset number_of_changed_files 2>/dev/null || number_of_changed_files=''
      return 65
    fi
    ;;
  *)
    unset number_of_changed_files 2>/dev/null || number_of_changed_files=''
    command git checkout --progress "${@-}"
    ;;
  esac
  unset number_of_changed_files 2>/dev/null || number_of_changed_files=''
}

# `git checkout` the default branch
alias -- gcom='command git checkout --progress "$(git-default-branch)"'

# git cherry-pick
alias -- \
  gcp='command git cherry-pick' \
  gcpa='command git cherry-pick --abort' \
  gcpc='command git cherry-pick --continue' \
  gcpn='command git cherry-pick --no-commit'

# git clone
git_clone() {
  case "${1-}" in
  -h | --help)
    command -p -- printf -- 'Usage: %s <git_url> [<dir_name>]\n' "${0##*/}" >&2
    ;;
  -1 | --shallow)
    shift
    { command -p -- mkdir "${2:-$(command -p -- basename -- "${1-}" .git)}" >/dev/null 2>&1 || return 73; } &&
      command -p -- printf -- 'moving into %s...\n' "${2:-$(command -p -- basename -- "${1-}" .git)}" >&2 &&
      cd -- "${2:-$(command -p -- basename -- "${1-}" .git)}" >/dev/null 2>&1 &&
      # using `--quiet` plus `--progress` to
      # hide the suprising the `Cloning into '.'...`
      command git -c core.ignoreCase=false clone --depth 1 --progress --quiet --shallow-submodules --template='' -- "${1%.git}" "${PWD%/}"
    ;;
  -b | --branches)
    command git branch --remotes |
      command -p -- grep -v -e '*' -e ' -> ' |
      while IFS='' read -r -- remote_branch; do
        command git branch --list |
          command -p -- grep -w -e "${remote_branch##*/}" >/dev/null 2>&1 ||
          command git branch --track "${remote_branch##*/}" "${remote_branch-}"
        unset remote_branch 2>/dev/null || remote_branch=''
      done
    ;;
  *)
    { command -p -- mkdir "${2:-$(command -p -- basename -- "${1-}" .git)}" >/dev/null 2>&1 || return 73; } &&
      command -p -- printf -- 'moving into %s...\n' "${2:-$(command -p -- basename -- "${1-}" .git)}" >&2 &&
      cd -- "${2:-$(command -p -- basename -- "${1-}" .git)}" >/dev/null 2>&1 && {
      # command -p -- test "${3-}" = '' ||
      command git -c core.ignoreCase=false clone --progress --recursive --template='' -- "${1%.git}" "${PWD%/}" # ||
      # command git clone --progress --recursive --branch "${branch-}" -- "${1%.git}" "${PWD%/}"
    }
    unset branch 2>/dev/null || branch=''
    ;;
  esac
}
alias -- \
  gcl='git_clone' \
  gcl1='git_clone -1'

# git commit
git_commit() {
  case "${1-}" in
  --amend | '')
    ### does `--signoff` obviate the need for `--trailer`? 2024-02-02
    ### command git commit ### --signoff ### --verbose \
    command git commit \
      --verbose \
      --trailer='Signed-off-by: '"$(command git config --get -- user.name)"' <'"$(command git config --get -- user.email)"'>' \
      "${@-}" ||
      # ancient git cannot do trailer
      command git commit \
        --signoff \
        --verbose \
        "${@-}" ||
      return 3
    ;;
  --count)
    # https://github.com/unixorn/git-extra-commands/commit/87fc4b2cac
    command git rev-list --all "${@-}" &&
      return
    ;;
  *)
    command git commit \
      --signoff \
      --verbose \
      -m "${@-}" \
      --message="${IFS-}" \
      --message="$(command -p -- printf -- '%s\n' "${IFS-}")" ||
      return 5
    ;;
  esac
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command -p -- sed \
      -e '$ d'
}
alias -- \
  gc='git_commit' \
  gca='git_commit --amend' \
  git_commit_count='git_commit --count'

git_config_file_locations() {
  for scope in system global local worktree command; do
    # do not return `.git/config` if called from outside a git repository
    command -p -- test "$(command git config --list --show-scope --"${scope-}" 2>/dev/null)" = '' ||
      command -p -- printf -- '%-9s%s\n' "${scope-}" "$(
        command git config --list --show-origin --"${scope-}" 2>/dev/null |
          command -p -- sed \
            -e 's|file:||' \
            -e 's|\t.*||' \
            -e 's|^\.|./.|' \
            -e 's|'"${custom-}"'|$\custom|' \
            -e 's|'"${DOTFILES-}"'|$\DOTFILES|' \
            -e 's|'"${XDG_CONFIG_HOME-}"'|$\XDG_CONFIG_HOME|' \
            -e 's|'"${HOME%/}"'|~|' |
          LC_ALL='C' command -p -- sort -u
      )"
  done
}

alias -- gdb >/dev/null 2>&1 &&
  unalias -- gdb
gdb() {
  (
    set \
      -o verbose \
      -o xtrace
    command -p -- printf -- 'main\nmaster\ntrunk\nHEAD\nmainline\ndefault\ndevelopment\n' | while IFS='' read -r -- branch; do
      {
        command -p -- test "$(command git branch --list -- "${branch-}")" != '' &&
          command -p -- printf -- '%s\n' "${branch-}" &&
          return 0
      } || {
        command -p -- printf -- 'error\n' >&2
        return 1
      }
    done
  )
}

alias -- gd >/dev/null 2>&1 &&
  unalias -- gd
gd() {
  if command -p -- test "$(command git diff --shortstat "${@-}" 2>/dev/null)" != ''; then
    command git -c core.quotePath=false diff "${@-}"
  else
    command git -c core.quotePath=false diff --cached "${@-}"
  fi
}
alias -- gds >/dev/null 2>&1 &&
  unalias -- gds
gds() {
  if command -p -- test "$(command git diff --cached --shortstat "${@-}" 2>/dev/null)" != ''; then
    command git -c core.quotePath=false diff --cached "${@-}"
  else
    command git -c core.quotePath=false diff "${@-}"
  fi
}
git_diff_with_filesizes() {
  {
    command -p -- test "$(command git diff --color=auto --stat "${@-}")" != '' &&
      command git -c core.quotePath=false diff --color=auto --stat "${@-}"
  } ||
    command git -c core.quotePath=false diff --cached --color=auto --stat "${@-}"
}
git_diff_staged_with_filesizes() {
  {
    command -p -- test "$(command git diff --cached --color=auto --stat "${@-}")" != '' &&
      command git -c core.quotePath=false diff --cached --color=auto --stat "${@-}"
  } ||
    command git -c core.quotePath=false diff --color=auto --stat "${@-}"
}

alias -- gdm='command git -c core.quotePath=false diff "$(git-default-branch)" --'
gdom() {
  command git -c core.quotePath=false diff "$(command git config --get branch."$(command git symbolic-ref --quiet --short HEAD -- 2>/dev/null)".remote || command git branch --list --remotes | command -p -- sed -n -e 's/^[[:space:]]*\([^[:space:]]*\)\/HEAD -> [^[:space:]]*$/\1/p')"/"$(git-default-branch)" "${@-}"
}
gdmom() {
  command git -c core.quotePath=false diff "$(git-default-branch)" "$(command git config --get branch."$(command git symbolic-ref --quiet --short HEAD -- 2>/dev/null)".remote || command git remote --verbose | command -p -- grep -e ' (push)$' | command awk -- '{print $0}' | command -p -- sed -e '1 q')"/"$(git-default-branch)" "${@:---}"
}

gf() {
  command git fetch \
    --all \
    --keep \
    --multiple \
    --progress \
    --prune \
    --verbose \
    "${@-}"
}
gfgs() {
  command git fetch \
    --all \
    --keep \
    --multiple \
    --progress \
    --prune \
    --verbose \
    "${@-}" &&
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command -p -- sed \
      -e '$ d'
}

# git parents, git child
git_find_child() {
  # return the commit hash that occurred after the given one (default current)
  # usage: git_find_child [<commit>]
  command git rev-list --ancestry-path "${1:-HEAD}".."$(git-default-branch)" |
    command -p -- tail -n 1
}
git_find_parent() {
  # return the hash prior to the current commit
  # if an argument is provided, return the commit prior to that commit
  # usage: git_find_parent [<commit>]
  command git rev-list --max-count=1 "${1:-"$(command git rev-parse HEAD)"}"'^' --
}
git_find_parents() {
  # return all hashes prior to the current commit
  # if an argument is provided, return all commits prior to that commit
  # usage: git_find_parents [<commit>]
  command git rev-list "${1:-"$(command git rev-parse HEAD)"}"'^' --
}
alias -- \
  git_parent='git_find_parent' \
  gfp='git_find_parent' \
  gfc='git_find_child' \
  git_parents='git_find_parents'

git_find_deleted_string() {
  # https://stackoverflow.com/a/12591569
  set \
    -o verbose \
    -o xtrace
  command git log --cc -S"${1:-*}" "${2:-./}" # >&2 # testing avoiding pager ¯\_(ツ)_/¯
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}
alias -- git_find_deleted_text='git_find_deleted_string'

git_garbage_collection() {
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # see `git gc` and other wrapping commands behind-the-scene mechanics
    # https://github.com/git/git/blob/49eb8d3/contrib/examples/README#L14-L16
    GIT_TRACE=1 GIT_TRACE_PACK_ACCESS=1 GIT_TRACE_PACKET=1 GIT_TRACE_PERFORMANCE=1 GIT_TRACE_SETUP=1 \
      command git fetch \
      --prune \
      --verbose
    GIT_TRACE=1 GIT_TRACE_PACK_ACCESS=1 GIT_TRACE_PACKET=1 GIT_TRACE_PERFORMANCE=1 GIT_TRACE_SETUP=1 \
      command git reflog expire \
      --all \
      --expire-unreachable=now
    GIT_TRACE=1 GIT_TRACE_PACK_ACCESS=1 GIT_TRACE_PACKET=1 GIT_TRACE_PERFORMANCE=1 GIT_TRACE_SETUP=1 \
      command git prune \
      --expire=now \
      --progress \
      --verbose
    GIT_TRACE=1 GIT_TRACE_PACK_ACCESS=1 GIT_TRACE_PACKET=1 GIT_TRACE_PERFORMANCE=1 GIT_TRACE_SETUP=1 \
      command git prune-packed
    GIT_TRACE=1 GIT_TRACE_PACK_ACCESS=1 GIT_TRACE_PACKET=1 GIT_TRACE_PERFORMANCE=1 GIT_TRACE_SETUP=1 \
      command git repack \
      -a \
      -d \
      -F \
      -f \
      --depth=4095 \
      --window="${UINT_MAX:-$(command -p -- getconf -- UINT_MAX)}"
    GIT_TRACE=1 GIT_TRACE_PACK_ACCESS=1 GIT_TRACE_PACKET=1 GIT_TRACE_PERFORMANCE=1 GIT_TRACE_SETUP=1 \
      command git gc \
      --aggressive \
      --prune=now
    command git maintenance start >/dev/null 2>&1 &&
      GIT_TRACE=1 GIT_TRACE_PACK_ACCESS=1 GIT_TRACE_PACKET=1 GIT_TRACE_PERFORMANCE=1 GIT_TRACE_SETUP=1 \
        command git maintenance run \
        --task gc \
        --task loose-objects \
        --task incremental-repack \
        --task pack-refs
    command git maintenance unregister --force >/dev/null 2>&1
    set \
      -o verbose \
      -o xtrace
    cleanup "${@-}"
    dss "${@-}"
    {
      set \
        +o verbose \
        +o xtrace
    } 2>/dev/null
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
      command -p -- sed \
        -e '$ d'
  else
    return "${?:-1}"
  fi
}
alias -- ggc='git_garbage_collection'

## initial commits
# find initial commit
git_find_initial_commit() {
  command git rev-list --max-parents=0 HEAD --
}
alias -- gic='git_find_initial_commit'

# commit initial commit
git_commit_initial_commit() {
  # usage: git_commit_initial_commit [yyyy-mm-dd[Thh:mm:ss]]]
  # create initial commits: one empty root, then the rest
  # https://news.ycombinator.com/item?id=25515963
  command git \
    -c init.defaultBranch=main \
    -c core.ignoreCase=false \
    init \
    --template='' &&
    if command -p -- test "${#}" -eq 1; then
      # @TODO!: permit BSD date if GNU fails
      gdate="$(
        command -v -- "${HOMEBREW_PREFIX-}"'/opt/uutils-coreutils/libexec/uubin/date' ||
          command -v -- udate ||
          command -v -- "${HOMEBREW_PREFIX-}"'/opt/coreutils/libexec/gnubin/date' ||
          command -v -- gdate ||
          command -v -- date ||
          command -p -- date
      )"
      export gdate
      git_time="$(gdate -d '@'"$(($(gdate -d "${1:-$(gdate -- '+%Y-%m-%d')}" -- '+%s')))" -- '+%c %z')"
      export GIT_AUTHOR_DATE="${git_time-}"
      export GIT_COMMITTER_DATE="${git_time-}"
    fi
  # create empty root commit
  command git commit --allow-empty --signoff --verbose --message="$(command -p -- printf -- '\360\237\214\263\302\240 root commit')" &&
    # ...and add a signed v0.0.0 tag to it
    command git tag --annotate --sign "${2:-v0.0.0}" --message='' &&
    # ...and if there are files present, then add them...
    command git add --verbose -- . &&
    # ...and commit them
    command git commit --signoff --verbose --message="$(command -p -- printf -- '\342\234\250\302\240 initial commit')" &&
    # ...and add a signed v0.0.1 tag
    command git tag --annotate --sign "${3:-v0.0.1}" --message=''
  unset gdate 2>/dev/null || gdate=''
  unset git_time 2>/dev/null || git_time=''
  # unset GIT_AUTHOR_DATE 2>/dev/null || GIT_AUTHOR_DATE=''
  # unset GIT_COMMITTER_DATE 2>/dev/null || GIT_COMMITTER_DATE=''
}
alias -- \
  gcic='git_commit_initial_commit' \
  ginit='command git -c init.defaultBranch=main init --template='\'''\'' && command git status'

# git ls
alias -- gls >/dev/null 2>&1 &&
  unalias -- gls
gls() {
  {
    if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      command git -c core.quotePath=false ls-files "${@-}" |
        command awk -- '{print "./" $0}'
    elif command -v -- eza >/dev/null 2>&1; then
      command eza \
        --all \
        --classify \
        --color-scale=all \
        --color=always \
        --git \
        --icons \
        --no-permissions \
        --no-user \
        --octal-permissions \
        --oneline \
        --time-style=long-iso \
        "${@-}"
    else
      command -p -- ls -1 "${@-}"
    fi
  } |
    LC_ALL='C' command -p -- sort -u |
    LC_ALL='C' command -p -- sort -f
}

git_ls_modified() {
  command git ls-files --deduplicate | while IFS='' read -r -- file; do
    command git -P log \
      --date=local \
      --max-count=1 \
      --pretty=tformat:'%ai%x09./'"${file-}" \
      -- \
      "${file-}"
  done
  # https://gist.github.com/8775224
  command git ls-tree --name-only HEAD -- . | while IFS='' read -r -- file; do
    command -p -- printf -- '%s\t./%s\n' "$(command git log --format='%ci' --max-count=1 -- "${file-}")" "${file-}"
  done
}

#########
# git log
alias -- \
  glog='command git log --all --decorate --graph --oneline' \
  glod='command git log --all --decorate --graph --oneline --pretty='\''%Cred%h%Creset%C(auto)%d%Creset %s %Cgreen%ad%Creset'\'' --date=short'
glof() {
  for file in "${@-}"; do
    # follow files even in other directories
    command git -C "$(command -p -- realpath -- "$(command -p -- dirname -- "${file-}")")" log --all --decorate --oneline --follow -- "$(command -p -- realpath -- "${file-}")" 2>/dev/null ||
      command git -C "${file%/*}" log --all --decorate --oneline --follow -- "${file-}" 2>/dev/null ||
      command git -C "$(command -p -- dirname -- "${file-}")" log --all --decorate --oneline --follow -- "${file-}"
  done
}
# git log
#########

# git mailmap
git_mailmap() {
  command git log --pretty='%an <%ae>%n%cn <%ce>' |
    LC_ALL='C' command -p -- sort |
    command -p -- uniq -c |
    LC_ALL='C' command -p -- sort -n -r |
    command -p -- sed \
      -e 's/^[[:space:]]*[1-9][[:digit:]]*[[:space:]]*//' \
      -e 's/\[bot\] / /' \
      -e 's/github-actions /GitHub /'
  # overline
  command -p -- printf -- '\342\200\276\342\200\276\342\200\276\342\200\276\342\200\276\n'
  command git shortlog --all --email --numbered --summary |
    command -p -- sed \
      -e 's/^[[:space:]]*[1-9][[:digit:]]*[[:space:]]*//' \
      -e 's/\[bot\] / /' \
      -e 's/github-actions /GitHub /'
  command -p -- printf -- '\342\200\276\342\200\276\342\200\276\342\200\276\342\200\276\n'
  command -p -- printf -- 'https://gist.github.com/fcea3c4301ec5100460ac571a5fe99c4\n'
}

# git make git
git_make_git() {
  command -p -- mkdir -p -- "${HOME%/}"'/c/git'
  cd -- "${HOME%/}"'/c/git' ||
    return "${?:-1}"
  set -- "$(
    set -- 'https://api.github.com/repos/git/git/tags'
    {
      command wget --hsts-file=/dev/null --output-document=- --quiet -- "${1-}" 2>/dev/null ||
        command curl --location --show-error --silent --url "${1-}"
    } |
      command -p -- sed \
        -n \
        -e '/tarball_url/ {' \
        -e '  s/.*: "\(.*\)",/\1/p' \
        -e '  q' \
        -e '}'
  )"
  {
    command wget --hsts-file=/dev/null --output-document=- --quiet -- "${1-}" 2>/dev/null ||
      command curl --location --silent --url "${1-}"
  } |
    command tar -f- -x -z --transform 's/^[^/]*\///'
  (
    set \
      -o verbose \
      -o xtrace
    command -p -- make -- configure &&
      ./configure --prefix="${HOME%/}"'/.local' &&
      NO_TCLTK=1 command -p -- make &&
      NO_TCLTK=1 command -p -- make -- install
  )
}

# git merge
alias -- gm >/dev/null 2>&1 &&
  unalias -- gm
# https://github.com/alexsanford/config/blob/1f917be788/zsh_aliases#L46
gm() {
  # https://news.ycombinator.com/item?id=5512864
  command git merge --no-ff --log --overwrite-ignore --progress --rerere-autoupdate --signoff --strategy-option=patience --verbose "${@-}" ||
    command git merge "${@-}"
}
alias -- \
  gma='command git merge --abort' \
  gmc='command git merge --continue'

# git merge with default branch
gmm() {
  command git merge --no-ff --log --overwrite-ignore --progress --rerere-autoupdate --signoff --strategy-option=patience --verbose "$(git-default-branch)"
}
# git move
git_move() {
  if command git mv --force --verbose "${@-}" 2>/dev/null; then
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
      command -p -- sed \
        -e '$ d'
  elif command -p -- mv -i "${@-}"; then
    return 0
  else
    return 1
  fi
}
alias -- gmv='git_move'

gopen() {
  case "${1-}" in
  --)
    shift
    ;;
  -d | --dependabot)
    url="$(
      command -p -- printf -- '%s/network/updates#dependabot-updates\n' "$(
        command git open --print |
          command -p -- cut -d '/' -f -5
      )"
    )"
    ;;
  -c | --commit | -i | --issue | -s | --suffix | -p | --print)
    command git open "${@-}"
    ;;
  *)
    url="$(command git open --print "${@-}" 2>/dev/null)"
    ;;
  esac
  # https://github.com/travis-ci/travis-build/blob/5f10098/lib/travis/build/bash/travis_setup_env.bash#L22-L38
  case "$(command -p -- uname | command -p -- tr -- '[:upper:]' '[:lower:]')" in
  darwin*)
    # MacOS
    command open -- "${url-}"
    ;;
  msys*)
    # Git-Bash on Windows
    Start-Process "${url-}"
    ;;
  *microsoft*)
    # Windows Subsystem for Linux
    command powershell.exe -c 'Start-Process "'"${url-}"'"' 2>/dev/null ||
      command powershell -c 'Start-Process "'"${url-}"'"' 2>/dev/null ||
      command pwsh.exe -c 'Start-Process "'"${url-}"'"' 2>/dev/null ||
      command pwsh -c 'Start-Process "'"${url-}"'"'
    ;;
  *)
    # fallback to Linux `xdg-open`
    command xdg-open -- "${url-}" 2>/dev/null ||
      command xdg-open "${url-}"
    ;;
  esac
}
alias -- gopend='gopen --dependabot'

# git pull
git_pull() {
  # https://github.com/ohmyzsh/ohmyzsh/commit/3d2542f
  {
    command git pull --all --autostash --ff-only --gpg-sign --log --progress --prune --rebase --signoff --verbose --verify "${@-}"
  } || {
    command git rebase --abort 2>/dev/null
    command git pull --all --autostash --ff --gpg-sign --log --progress --prune --rebase --signoff --verbose --verify "${@-}"
  } || {
    command git rebase --abort 2>/dev/null
    command git pull --all --autostash --gpg-sign --log --progress --prune --rebase --signoff --verbose --verify "${@-}"
  } || {
    command git rebase --abort 2>/dev/null
    command git pull --all --autostash --prune --rebase --verbose "${@-}"
  } || {
    command git rebase --abort 2>/dev/null
    command git pull --autostash --prune --rebase --verbose "${@-}"
  } || {
    command git rebase --abort 2>/dev/null
    command git rebase --strategy-option=theirs --update-refs
  } || {
    command git rebase --abort 2>/dev/null
    command git rebase --strategy-option=theirs
  }
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command -p -- sed \
      -e '$ d'
}
alias -- gp='git_pull'

git_current_remote() {
  git config --get branch."$({ git symbolic-ref --quiet --short HEAD -- || git rev-parse --short HEAD || git rev-parse --abbrev-ref HEAD; } 2>/dev/null)".remote
  # works in $TRASH and in new branches without remotes
  git branch --list --remotes | sed -n -e 's/^[[:space:]]*\([^[:space:]]*\)\/HEAD -> [^[:space:]]*$/\1/p'
  ##### git config --get "$(git config --get-regexp --name-only '^branch\..*\.remote$' | sed -e '1 q')" || git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null | sed -e 's/\/.*//' || git branch --remotes | sed -e '/->/! d' -e 's/  \([^\/ ]*\)\/.*/\1/' -e 'q'
  # 1st is the only that’ll work in a submodule
  # 1st is the only that won’t work if you do
  # `git branch --set-upstream-to=NOT_DEFAULT/"$(git_current_branch)"`
  git branch --remotes |
    sed -n -e 's/.* -> \(.*\)\/.*/\1/p'
  git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' |
    sed -e 's/\(.*\)\/.*/\1/'
  git config --get branch."$(git rev-parse --abbrev-ref HEAD)".remote
  git config --get branch."$({ git symbolic-ref --quiet --short HEAD || git rev-parse --short HEAD; } 2>/dev/null)".remote
  ##### git config --get branch."$(git-default-branch 2>/dev/null)".remote
  git config --get branch."$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || git-default-branch)".remote
  ##### git config --get "$(git config --get-regexp --name-only '^branch\..*\.remote$' | sed -e '1q')"
  git rev-parse --symbolic-full-name '@{upstream}' |
    sed -e 's/^refs\/remotes\/*\(.*\)\/.*/\1/'
  # won't work if the current remote is named a/b/c/d
  # find -- "${GIT_DIR:-./.git}"'/refs/remotes' -name 'HEAD' -type f -exec sh -c 'basename -- "${1%/*}"' _ {} ';'

  # not sure if this works if remote's default branch has a slash in it
  find -- "${GIT_DIR:-./.git}"'/refs/remotes' -name 'HEAD' -type f -exec sed -e 's/ref: refs\/remotes\/\(.*\)\/[^\/]*/\1/' {} ';'
}

gdr() {
  {
    command git config --get --worktree -- checkout.defaultRemote ||
      command git config --get --local -- checkout.defaultRemote ||
      command git config --get --system -- checkout.defaultRemote ||
      command git config --get --global checkout.defaultRemote ||
      command git config --get -- branch."$(command git symbolic-ref --quiet --short HEAD -- 2>/dev/null)".remote
  } 2>/dev/null ||
    command git config --default origin --get -- branch."$(
      command git symbolic-ref --quiet --short HEAD 2>/dev/null ||
        command git rev-parse --short HEAD 2>/dev/null
    )".remote
  # https://gitlab.com/engmark/root/commit/ca5e6f02ca2
  command git config --get --default=origin -- checkout.defaultRemote
}
alias -- \
  git-default-remote='gdr' \
  git-default-origin='gdr'

# git push
git_push() {
  case "${1-}" in
  -r | --all-remotes)
    command git remote show |
      while IFS='' read -r -- remote; do
        command git -c push.autoSetupRemote=true push "${remote-}" "$(
          command git symbolic-ref --quiet --short HEAD -- 2>/dev/null
        )" --atomic --follow-tags --no-thin --progress --prune --recurse-submodules=check --signed=if-asked --tags --verbose --verify
      done
    ;;
  # https://github.com/ohmyzsh/ohmyzsh/commit/ae21102030
  *)
    command git -c push.autoSetupRemote=true push --progress --verbose "${@-}"
    ;;
  esac
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command -p -- sed \
      -e '$ d'
}
alias -- gps='git_push'

alias -- \
  grba='command git rebase --abort' \
  grbi='command git rebase --interactive --update-refs 2>/dev/null || command git rebase --interactive' \
  grbc='command git rebase --continue --update-refs 2>/dev/null || command git rebase --continue' \
  gref='command git reflog'

# git rm
alias -- grm >/dev/null 2>&1 &&
  unalias -- grm
alias -- grm='rm'
git_rm_r() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    return "${?:-1}"
  ps4_temporary="${PS4-}"
  PS4=' '
  set \
    -o xtrace
  command -p -- find -- . -path '*/.git' -prune -o -path './*/*' -prune -o -path './*' -exec rm -r -- {} + &&
    command -p -- find -- . -path '*/.git/hooks/*' -type f -exec rm -r -- {} + &&
    command -p -- find -- . -path '*/.git/hooks' -exec rmdir -- {} + &&
    command -p -- find -- . -path '*/.git/modules' -exec rm -f -r -- {} +
  PS4="${ps4_temporary-}"
  unset ps4_temporary 2>/dev/null || ps4_temporary=''
  {
    set \
      +o xtrace
  } 2>/dev/null
  command -v -- cleanup >/dev/null 2>&1 &&
    cleanup "${@-}"
  command git reset --quiet HEAD -- . &&
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command -p -- sed \
      -e '$ d'
}
alias -- grm.='git_rm_r'

git_remote_verbose() {
  # print `git remote -v` into columns as narrow as possible
  command git remote --verbose |
    command awk -vmax="$(command git remote | command awk -- 'BEGIN {max = 0} {if (length($0) > max) {max = length($0)} } END {print max}' -)" \
      -- \
      '! seen[$2]++ {printf "%-" max "s %s\n", $1, $2}' -
}
alias -- grv='git_remote_verbose'

git_restore() {
  # TODO: allow end-of-options parameter
  case "${1-}" in
  -d | --deleted)
    command git -c core.quotePath=false ls-files -z --deleted |
      command -p -- sed -e 's/./\\&/g' |
      command -p -- xargs git checkout --progress --
    ;;
  *)
    while command -p -- test "${#}" -gt 0; do
      command git checkout --progress -- "${1-}"
      shift
    done
    ;;
  esac
  command git -c color.status=always -c core.quotePath=false "${@:-status}" |
    command -p -- sed -e '$ d'
}
alias -- \
  grs='git_restore' \
  grsd='git_restore --deleted'

git_search() {
  # search all repository content since its creation
  command git rev-list --all |
    while IFS='' read -r -- commit; do
      # H: print filename
      # I: skip binary files
      command git --no-pager grep \
        -H \
        -I \
        --perl-regexp \
        --ignore-case \
        --line-number \
        -e "${@-}" \
        "${commit-}" --
    done
}
alias -- gsearch='git_search'

git_shallow() {
  # Shallow .gitmodules submodule installations
  # Mauricio Scheffer https://stackoverflow.com/a/2169914
  command git submodule init &&
    command git submodule |
    command awk -- '{print $2}' |
      while IFS='' read -r -- submodule; do
        # using `--progress`, `--verbose` and `--no-quiet` because
        # we’re not already in the target directory
        command git -c core.ignoreCase=false \
          clone --depth 1 --progress --shallow-submodules --template='' --verbose -- \
          "$(command git config --file .gitmodules --get -- submodule."${submodule-}".url)" \
          "$(command git config --file .gitmodules --get -- submodule."${submodule-}".path)"
      done
  command git submodule update
}

git_show() {
  case "${1-}" in

  --date)
    shift
    command git log --max-count=1 --format='%ci'
    ;;

  --files)
    # remove `--files` from the argument string
    shift

    # https://stackoverflow.com/a/424142
    command git diff-tree -B -C -M -r --find-copies-harder --name-only --no-commit-id --root --text "${@:-HEAD}" -- |
      LC_ALL='C' command -p -- sort -f |
      command -p -- sed -e 's/^/.\//'
    ;;
  *)
    # if `gsh $(gic)` returns >1 results, then show them all
    # but default to `HEAD` if no arguments are given
    if command -p -- test "${#}" -eq 0; then
      set -- HEAD
    fi
    command git show "${1-}" 2>/dev/null ||
      command git show "${1-}" --
    # shift <- no. because it will allow this to run twice
    ;;
  esac
}
alias -- \
  gsh='git_show' \
  gshd='git_show --date' \
  gshf='git_show --files'

# `git stash`
git_stash_save_all() {
  # https://github.com/ohmyzsh/ohmyzsh/commit/69ba6e4359
  command git stash push -m "${@-}" 2>/dev/null ||
    command git stash push
}
alias -- gstall='git_stash_save_all'
git_stash_save_keep() {
  command git stash push --keep-index -m "${@-}" 2>/dev/null ||
    command git stash push --keep-index
}
alias -- gstk='git_stash_save_keep'
gst_c() {
  command git stash clear &&
    command find -- "${GIT_DIR:-./.git}" \
      -depth \
      -path './*/*' \
      '(' \
      -name '._*' -o \
      -name '.gitstatus.*' -o \
      -name 'index.lock' -o \
      -name 'index.stash.*' \
      ')' \
      -delete
}
git_stash_pop() {
  # https://stackoverflow.com/q/51275777
  command git stash pop || {
    command git stash show --patch |
      command git -c color.status=always -c core.quotePath=false apply --3
  } || {
    command git -c color.status=always -c core.quotePath=false checkout stash -- .
  } || {
    command git -c core.quotePath=false diff "$(git_current_branch)" stash:**/* |
      command git -c color.status=always -c core.quotePath=false apply --3
  } || {
    command git -c color.status=always -c core.quotePath=false diff "$(git_current_branch)" stash:**/*
  } || {
    command git -c core.quotePath=false show stash:**/* >./tmp-"$(command -p -- date -- '+%Y%m%d%H%M%S')"
  }
}
alias -- \
  gsta='command git -c color.status=always -c core.quotePath=false stash apply --index stash@'\''{'\''0'\''}'\''' \
  gstp='git_stash_pop'

git_submodule_cleanup() {
  set \
    -o verbose
  while command -p -- test "$(
    command find -- . \
      '(' \
      -path '*/.git/modules/*index.lock' -o \
      -path '*/.git/modules/*index.stash.*' -o \
      -path '*/.git/modules/*.gitstatus.*' \
      ')' \
      -print 2>/dev/null
  )" != ''; do
    command -p -- printf -- 'deleting %s...\n' "$(
      command find -- . \
        '(' \
        -path '*/.git/modules/*index.lock' -o \
        -path '*/.git/modules/*index.stash.*' -o \
        -path '*/.git/modules/*.gitstatus.*' \
        ')' \
        -print 2>/dev/null
    )" >&2 &&
      command find -- . \
        '(' \
        -path '*/.git/modules/*index.lock' -o \
        -path '*/.git/modules/*index.stash.*' -o \
        -path '*/.git/modules/*.gitstatus.*' \
        ')' \
        -delete
  done
  command git submodule foreach --recursive 'command git reset --hard --recurse-submodules --refresh'
  command git submodule foreach --recursive 'command git stash clear'
  command -v -- git_update >/dev/null 2>&1 &&
    git_update "${@-}"
  set \
    +o verbose
}
alias -- gsc='git_submodule_cleanup'

git_submodule_update() {
  # @TODO!: ensure this harmonizes with `git_update`’s submodule updater below
  command git submodule update --init --remote "${@-}" &&
    command git submodule sync "${@-}" &&
    command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command -p -- sed \
      -e '$ d'
}
alias -- gsu='git_submodule_update'

alias -- gtag='command git --no-pager tag --sort=creatordate'

git_tag_edit() {
  # https://stackoverflow.com/a/14130875
  command git tag "${1-}" "${1-}"'^'{} --annotate --force --sign
}

git_tags_by_date() {
  # https://github.com/crowdbotics-apps/firemeapp-3088/blob/cad844a221/client/app/components/linux/Sourcetree-Beta.app/Contents/Resources/git-tags-by-date.sh
  command git tag --list | while IFS='' read -r -- tag; do
    command -p -- printf -- '%s\t%s\n' "$(command git log --max-count=1 --format='%cd' --date=format:'%F' "${tag-}" --)" "${tag-}"
  done | {
    case "${1-}" in
    -r | --reverse)
      LC_ALL='C' command -p -- sort -n -r
      ;;
    *)
      LC_ALL='C' command -p -- sort -n
      ;;
    esac
  }
}
alias -- gtags_by_date='git_tags_by_date'

git_time() {
  # convert yyyy-mm-dd at the current time to Git’s preferred format
  # show the 2 variables need to be set as what – interactive shell only @TODO!
  # command -p -- printf -- 'GIT_AUTHOR_DATE="%s" GIT_COMMITTER_DATE="%s"'
  # git_time="$(command gdate -d '@'"$(($(command gdate -d "${1:-$(command -p -- date '+%Y-%m-%d')}" '+%s') + 12 * 60 * 60))" -- '+%c %z')"
  case "${1-}" in
  -h | --help)
    command -p -- printf -- 'Usage: git_time [date] [time]\n'
    ;;
  [1-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] | [1-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9])
    shift
    command /usr/local/opt/coreutils/libexec/gnubin/date -d "${1:-+%Y-%m-%d}"'T'"${2:-%H:%M:%S}"'Z' '+%c %z'
    ;;
  [1-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]Z)
    shift
    command /usr/local/opt/coreutils/libexec/gnubin/date -d "${1-}"T"${2-}"Z '+%c %z'
    ;;
  *)
    command -p -- printf -- ' GIT_AUTHOR_DATE=\047%s\047 GIT_COMMITTER_DATE=\047%s\047 \n' "$(command /usr/local/opt/coreutils/libexec/gnubin/date -d '@'"$(command /usr/local/opt/coreutils/libexec/gnubin/date -d "${1:-$(command -p -- date -- '+%Y-%m-%dT%H:%M:%S')}" -- '+%s')" -- '+%c %z')" "$(command /usr/local/opt/coreutils/libexec/gnubin/date -d '@'"$(command /usr/local/opt/coreutils/libexec/gnubin/date -d "${1:-$(command -p -- date -- '+%Y-%m-%dT%H:%M:%S')}" -- '+%s')" -- '+%c %z')"
    command -p -- printf -- ' GIT_AUTHOR_DATE=\047%s\047 GIT_COMMITTER_DATE=\047%s\047 \n' "$(command /usr/local/opt/coreutils/libexec/gnubin/date -d '@'"$(command /usr/local/opt/coreutils/libexec/gnubin/date -d "${1:-$(command -p -- date -- '+%Y-%m-%d %H:%M:%S')}" -- '+%s')" -- '+%c %z')" "$(command /usr/local/opt/coreutils/libexec/gnubin/date -d '@'"$(command /usr/local/opt/coreutils/libexec/gnubin/date -d "${1:-$(command -p -- date -- '+%Y-%m-%d %H:%M:%S')}" -- '+%s')" -- '+%c %z')"
    command -p -- printf -- ' GIT_AUTHOR_DATE=\047%s\047 GIT_COMMITTER_DATE=\047%s\047 \n' "$(command /usr/local/opt/coreutils/libexec/gnubin/date -d '@'$(($(command /usr/local/opt/coreutils/libexec/gnubin/date -d "${1:-$(command -p -- date -- '+%Y-%m-%d %H:%M:%S')}" -- '+%s'))) -- '+%c %z')" "$(command /usr/local/opt/coreutils/libexec/gnubin/date -d '@'$(($(command /usr/local/opt/coreutils/libexec/gnubin/date -d "${1:-$(command -p -- date -- '+%Y-%m-%d %H:%M:%S')}" -- '+%s'))) -- '+%c %z')"
    ;;
  esac
}
alias -- git-date='git_time'

git_undo() {
  command git reset HEAD@'{'"${1:-1}"'}'
}
alias -- gundo='git_undo'

git_update() {
  set \
    -o noclobber \
    -o noglob \
    -o xtrace
  # run only from within a Git repository
  # https://stackoverflow.com/a/53809163
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then

    command -v -- cleanup >/dev/null 2>&1 &&
      set \
        +o noclobber &&
      cleanup "${@-}"
    set \
      -o noclobber

    command git fetch --all --keep --multiple --progress --prune --verbose --update-shallow

    # `git submodule update` with `--remote` appears to slow Git to a crawl
    # https://docs.google.com/spreadsheets/d/14W8w71DK0YpsePbgtDkyFFpFY1NVrCmVMaw06QY64eU
    case "${1-}" in
    -r | --remote)
      shift
      command git submodule update --init --recursive --remote "${@-}"
      ;;
    *)
      command git submodule update --init --recursive "${@-}"
      ;;
    esac
    command git submodule sync --recursive "${@-}"
  fi
  {
    set \
      +o noclobber \
      +o noglob \
      +o xtrace
  } 2>/dev/null
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command -p -- sed \
      -e '$ d'
}
alias -- gu='git_update'

gvc() {
  # https://github.com/tarunsk/dotfiles/blob/5b31fd6/.always_forget.txt#L1957
  # if there is an argument (commit hash), use it
  # otherwise check `HEAD`
  command git verify-commit "${1:-HEAD}"
}

alias -- ghs='command gh status'

github_create_repository() {
  # https://gist.github.com/alexpchin/dc91e723d4db5018fef8?permalink_comment_id=4252359#gistcomment-4252359
  command curl \
    --data '{"name": "'"$(command git rev-parse --show-toplevel | command -p -- tr -d '[:space:]' | command -p -- sed -e 's/./\\&/g' | command -p -- xargs basename --)"'", "private": true, "visibility": "private"}' \
    --fail \
    --header 'Authorization: token '"${GITHUB_API_TOKEN-}" \
    --show-error \
    --silent \
    --url 'https://api.github.com/user/repos' &&
    command git remote add origin "$(
      command curl \
        --fail \
        --header 'Authorization: token '"${GITHUB_API_TOKEN-}" \
        --show-error \
        --silent \
        --url 'https://api.github.com/repos/'"${GITHUB_ORG-}"/"$(
          command git rev-parse --show-toplevel |
            command -p -- tr -d '[:space:]' |
            command -p -- sed -e 's/./\\&/g' |
            command xargs basename --
        )" |
        command -p -- sed \
          -n \
          -e '# emulate jq -r .html_url using prepended jq -r .full_name instead' \
          -e '# parses GitHub json even if minified' \
          -e 's/.*"full_name"[^."]*"\([^"]*\)".*/https:\/\/github.com\/\1/p'
    )"
}
gitlab_create_repository() {
  command git push --set-upstream git@gitlab.com:"${GITLAB_USERNAME:-${LOGNAME:-${USER-}}}"/"$(
    command git rev-parse --show-toplevel |
      command -p -- xargs basename --
  )" "$(
    command git rev-parse --abbrev-ref HEAD
  )" &&
    command git remote add origin git@gitlab.com:"${GITLAB_USERNAME:-${LOGNAME:-${USER-}}}"/"$(
      command git rev-parse --show-toplevel |
        command -p -- xargs basename --
    )"
}

github_keys() {
  command -p -- test "${GITHUB_API_TOKEN-}" != '' ||
    # EX_CONFIG
    return 78
  command curl \
    --fail \
    --header 'Authorization: token '"${GITHUB_API_TOKEN-}" \
    --show-error \
    --silent \
    --url https://api.github.com/meta 2>/dev/null |
    command -p -- sed \
      -e '/[^:[:space:]][[:space:]][^:[:space:]]/! d' \
      -e 's/^[[:space:]]*"\([^[:space:]]*\)[[:space:]][[:space:]]*\([^",]*\)",*/github.com \1 \2/'
}

github_search() {
  set -- 'https://github.com/search?type=code&q='"${*-}"
  command xdg-open -- "${1-}" 2>/dev/null ||
    command open -- "${1-}"
}

gofmt_r() {
  command -v -- gofumpt >/dev/null 2>&1 ||
    # EX_UNAVAILABLE
    return 69
  set \
    -o verbose \
    -o xtrace
  PS4=' ' IFS='' command find -- . \
    -path '*/.git' -prune -o \
    -path '*/Library' -prune -o \
    -path '*/vendor' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/t' -prune -o \
    -path '*/Test*' -prune -o \
    -path '*/test*' -prune -o \
    -path '*/tst*' -prune -o \
    -name '*.go' \
    -type f \
    -exec sh -C -e -f -u -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command gofumpt -extra -w -- "${1-}"
' _ {} ';'
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

google() {
  set -- 'https://www.google.com/search?safe=off&q='"${*-}"
  command xdg-open -- "${1-}" 2>/dev/null ||
    command open -- "${1-}"
}

gravatar() {
  # gravatar
  # return the URL of a Gravatar image for the given email address
  # TODO use getopts
  # TODO add the option of opening the URL in a browser

  # return the Gravatar image URL
  command -p -- printf -- 'https://gravatar.com/avatar/%.32s?s=%d\n' "$(
    command -p -- printf -- %s "${1:-$(command git config --get -- user.email)}" |
      LC_ALL='C' command -p -- tr -d '[:space:]' |
      LC_ALL='C' command -p -- tr -- '[:upper:]' '[:lower:]' |
      {
        command -p -- md5sum ||
          command -p -- md5
      } 2>/dev/null
    # Gravatar: 4096
    # MaxURL:   9999
  )" "${2:-9999}"
}

## GraphicConverter
gcr() {
  command -p -- open -a "$(
    {
      set \
        +o verbose \
        +o xtrace
    } 2>/dev/null
    (
      command -p -- find -- /Applications \
        -path '/Applications/*/*' -prune -o \
        -name 'GraphicConverter*' \
        -type d \
        -exec ls -d -1 -t -- {} + 2>/dev/null \
        &
    ) |
      command -p -- sed \
        -n \
        -e '/1/ {' \
        -e '  s/^\/Applications\///' \
        -e '  s/\.app$//' \
        -e '}' \
        -e 'p'
  )" -- "${@-}"
}

######
# grep

# sed
grep_sed() {
  # print only lines that match regular expression (emulates "grep")
  # macOS `sed`’s `man` page incorrectly claims that `-` is standard input, but when using
  # "${2-}" it finds no file named ‘’ (null), and when using
  # "${2--}" it finds no file named ‘-’
  set -- "$(command -p -- printf -- '%s\n' "${1-}" | command -p -- sed -e 's/\//\\\//g')" "${2-}"
  command -p -- sed -e '#n' -e '/'"${1-}"'/ p'
  command -p -- sed -n -e '/'"${1-}"'/ p'
  command -p -- sed -e '/'"${1-}"'/! d'
  command -p -- sed -e '#n' -e '/'"${1-}"'/ p' "${2-}"
  command -p -- sed -n -e '/'"${1-}"'/ p' "${2-}"
  command -p -- sed -e '/'"${1-}"'/! d' "${2-}"
  command -p -- sed -e '#n' -e '/'"${1-}"'/ p' "${2:--}"
  command -p -- sed -n -e '/'"${1-}"'/ p' "${2:--}"
  command -p -- sed -e '/'"${1-}"'/! d' "${2:--}"
}
alias -- sed_grep='grep_sed'
grep_awk() {
  # print only lines that match regular expression (emulates "grep")
  set -- "$(command -p -- printf -- '%s\n' "${1-}" | command -p -- sed -e 's/\//\\\//g')" "${2-}"
  command gawk --lint --lint-old --no-optimize --posix --sandbox --use-lc-numeric -- '/'"${1-}"'/' "${2:--}"
}
alias -- awk_grep='grep_awk'
grep_sed_v() {
  # print only lines that do NOT match regexp (emulates "grep -v")
  set -- "$(command -p -- printf -- '%s\n' "${1-}" | command -p -- sed -e 's/\//\\\//g')" "${2-}"
  command -p -- sed -e '#n' -e '/'"${1-}"'/! p'
  command -p -- sed -n -e '/'"${1-}"'/! p'
  command -p -- sed -e '/'"${1-}"'/ d'
  command -p -- sed -e '#n' -e '/'"${1-}"'/! p' "${2-}"
  command -p -- sed -n -e '/'"${1-}"'/! p' "${2-}"
  command -p -- sed -e '/'"${1-}"'/ d' "${2-}"
  command -p -- sed -e '#n' -e '/'"${1-}"'/! p' "${2:--}"
  command -p -- sed -n -e '/'"${1-}"'/! p' "${2:--}"
  command -p -- sed -e '/'"${1-}"'/ d' "${2:--}"
}
alias -- \
  sed_grep_v='grep_v_sed' \
  sed_grep_v='grep_sed_v'
grep_awk_v() {
  # print only lines that do NOT match regex (emulates "grep -v")
  set -- "$(command -p -- printf -- '%s\n' "${1-}" | command -p -- sed -e 's/\//\\\//g')" "${2-}"
  command gawk --lint --lint-old --no-optimize --posix --sandbox --use-lc-numeric -- '!/'"${1-}"'/' "${2:--}"
}
alias -- \
  awk_grep_v='grep_v_awk' \
  awk_grep_v='grep_awk_v'

alias -- gr >/dev/null 2>&1 &&
  unalias -- gr
command -v -- _grep >/dev/null 2>&1 &&
  compdef -- gr='grep'
gr() {
  # when I’m feeling better I’ll remember why I’m using `grep` instead of `git grep --no-index`
  case "${1-}" in
  -*)
    arguments="${1-}"'EIinr'
    shift
    ;;
  *)
    arguments='-EIinr'
    ;;
  esac
  # -find -L instead of ! -type d because I want to search inside symlinks 2023-01-29
  command find -L -- "${2:-.}" \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/t' -prune -o \
    -path '*/Test*' -prune -o \
    -path '*/test*' -prune -o \
    -path '*/tst*' -prune -o \
    -path '*copilot*' -prune -o \
    -path '*dummy*' -prune -o \
    -path '*vscode*' -prune -o \
    ! -path 'do not add ! type -l because we actually DO want to search inside symlink targets' \
    ! -type d \
    -exec grep "${arguments:--EIinr}" --color=auto -e "${1-}" {} +
  unset arguments 2>/dev/null || arguments=''
}
grpt() {
  # when I’m feeling better I’ll remember why I’m using `grep` instead of `git grep --no-index`
  case "${1-}" in
  -*)
    arguments="${1-}"'EIinr'
    shift
    ;;
  *)
    arguments='-EIinr'
    ;;
  esac
  # -find -L instead of ! -type d because I want to search inside symlinks 2023-01-29
  command find -L -- "${2:-.}" \
    ! -path '*/.git/*' \
    ! -path '*/node_modules/*' \
    ! -path '*/t/*' \
    ! -path '*/Test*' \
    ! -path '*/plugins/*' \
    ! -path '*/test*' \
    ! -path '*/themes/*' \
    ! -path '*/tst*' \
    ! -path '*copilot*' \
    ! -path '*dummy*' \
    ! -path '*vscode*' \
    ! -path 'do not add ! type -l because we actually DO want to search inside symlink targets' \
    ! -type d \
    ! -path 'it is arguments:--Ein below so there is a fallback when I wanna copy-pase' \
    ! -name '.git' \
    -exec grep "${arguments:--EIinr}" --color=auto -e "${1-}" {} +
  unset arguments 2>/dev/null || arguments=''
}
ggr() {
  # riffing on the above while not feeling great # 2022-09-14
  command git -P grep \
    -H \
    -I \
    --break \
    --color=auto \
    --extended-regexp \
    --ignore-case \
    --line-number \
    --no-index \
    --recurse-submodules \
    --recursive \
    -e "${@-}"
}

command -v -- _rg >/dev/null 2>&1 &&
  compdef -- rga='rg'
# skip searching `.git` and `node_modules` directories
# https://github.com/BurntSushi/ripgrep/issues/839#issuecomment-1006723597
rg() {
  utility="$(
    {
      command -p -- test -x "$(command -v -- rga)" &&
        command -v -- rga
    } || {
      command -p -- test -x "$(command -v -- rg)" &&
        command -v -- rg
    }
  )"
  command -p -- test "${utility-}" = '' &&
    command -p -- grep -E -r -e "${@-}"
  command "${utility-}" \
    --glob '!**.git' \
    --glob '!**node_modules' \
    --glob '!**plugins' \
    --glob '!**themes' \
    --glob '!**copilot*' \
    --glob '!**dummy*' \
    --glob '!**vscode*' \
    --hidden \
    "${@-}" 2>/dev/null
  unset utility 2>/dev/null || utility=''
}
rgv() {
  utility="$(
    {
      command -p -- test -x "$(command -v -- rga)" &&
        command -v -- rga
    } || {
      command -p -- test -x "$(command -v -- rg)" &&
        command -v -- rg
    }
  )"
  command -p -- test "${utility-}" = '' &&
    command -p -- grep -E -r -v -e "${@-}"
  command "${utility-}" \
    -v \
    --glob '!**.git' \
    --glob '!**node_modules' \
    --glob '!**plugins' \
    --glob '!**themes' \
    --glob '!**copilot*' \
    --glob '!**dummy*' \
    --glob '!**vscode*' \
    --hidden \
    "${@-}" 2>/dev/null
  unset utility 2>/dev/null || utility=''
}

grep_but_line() {
  # https://chatgpt.com/share/b7efc291-4902-43c1-b5ff-2efc995eb230
  # https://g.co/gemini/share/213f77a8c93b

  # should NOT work
  command awk -vgood="${1-}" -vbad="${2-}" -- '/good/ && !/bad/ {print}'

  # SHOULD work
  command awk -vgood="${1-}" -vbad="${2-}" -- '$0 ~ good && $0 !~ bad {print}'
}
alias -- \
  grep_but='grep_but_line' \
  grep_but_not_line='grep_but_line'
grep_but_file() {
  # https://web.archive.org/web/0id_/mywiki.wooledge.org/BashFAQ/079?rev=32#line-111
  command gawk --lint --lint-old --no-optimize --posix --sandbox --use-lc-numeric -- '/'"${1-}"'/{good=1} /'"${2-}"'/{good=0;exit} END{exit !good}'
}
alias -- grep_but_not_file='grep_but_file'

alias -- ug='ugrep --hidden'

grep_o() {
  # POSIX-compliant implementation of GNU `grep -o`
  # https://github.com/acmesh-official/acmetest/blob/b00e8f1875/letest.sh#L169
  { { command -p -- test "${#}" -eq 0 && command -p -- cat -- -; } || command -p -- printf -- '%s\n' "${@-}"; } |
    command -p -- sed \
      -n \
      -e 's/.*\('"${1-}"'\).*/\1/p'
}

# grep
######

hash_abbreviate() {
  # abbreviate commit hash and copy to clipboard
  # usage: hash_abbreviate [-l <length>] <hash> [<hash> ...]
  while getopts l: opt; do
    case "${opt-}" in
    l)
      length="${OPTARG-}"
      ;;
    *)
      command -p -- printf -- 'usage: %s [-l <length>] <hash> [<hash> ...]\n' "${0##*/}" >&2
      return
      ;;
    esac
  done
  shift "$((OPTIND - 1))"
  for hash in "${@-}"; do
    if command -p -- printf -- '%s' "${hash-}" | command -p -- grep -E -w -e '^[[:xdigit:]]{4,}$' >/dev/null 2>&1; then
      command -p -- printf -- '%.'"${length:-"$(command git config --get --default=7 -- core.abbrev)"}"'s\n' "${hash-}"
      # prevent copying trailing newline with `tr` and
      # hide clipboard errors because `pbcopy` is not common
      command -p -- printf -- '%.'"${length:-"$(command git config --get --default=7 -- core.abbrev)"}"'s' "${hash-}" |
        command pbcopy 2>/dev/null
    else
      return 1
    fi
  done
  unset length 2>/dev/null || length=''
}
alias -- h7='hash_abbreviate'

hashlookup() {
  command -p -- test -f "${1-}" ||
    # EX_NOINPUT
    return 66
  command curl \
    --header 'Accept: application/json' \
    --show-error \
    --silent \
    --url 'https://hashlookup.circl.lu/lookup/sha1/'"$(
      {
        command sha1sum -- "${1-}" 2>/dev/null ||
          command shasum -- "${1-}"
      } |
        command awk -- '{print $1}'
    )" |
    command jq --raw-output '.parents[]' 2>/dev/null
}

head() {
  case "${1-}" in
  -*)
    command -p -- head "${@-}"
    ;;
  *)
    command -p -- head -n "$((${LINES:-"$(
      command -p -- tput -- lines 2>/dev/null ||
        command -p -- printf -- '10 + 2'
    )"} - 2))" "${@-}"
    ;;
  esac
}
alias -- \
  h1='command -p -- head -n 1' \
  h2='command -p -- head -n 2' \
  h3='command -p -- head -n 3'
head_c() {
  command -p -- test "$(($1 + 0))" -eq "${1-}" ||
    # EX_DATAERR
    return 65
  command -p -- dd bs=1 count="${1-}" <"${2-}" 2>/dev/null ||
    command -p -- test -f "${2-}" ||
    # EX_NOINPUT
    return 66
}

headers() {
  set \
    -o noclobber \
    -o noglob \
    -o nounset \
    -o verbose \
    -o xtrace
  for host in "${@-}"; do
    # https://github.com/wincent/wincent/commit/fb6c4e8713
    command curl \
      --dump-header - \
      --location \
      --output /dev/null \
      --show-error \
      --silent \
      --url "${host-}"
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o nounset \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

hooks_r() {
  command git -C "${HOME%/}"'/c/hooks' rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
    command -p -- test -d "${PWD%/}"'/.git' &&
    command -p -- mkdir -p -- "${PWD%/}"'/.git/hooks' &&
    # cp -p to preserve permissions
    command find -- "${HOME%/}"'/c/hooks' \
      -path "${HOME%/}"'/c/hooks/.*' -prune -o \
      -path "${HOME%/}"'/c/hooks/*/*' -prune -o \
      -path "${HOME%/}"'/c/hooks/*' \
      -type f \
      -exec sh -x -c 'command -p -- test -x "${1-}" && command -p -- cp -p -- "${1-}" ./.git/hooks' _ {} ';' 2>&1 |
    command -p -- sed \
      -e 's|'"${custom-}"'|$\custom|' \
      -e 's|'"${DOTFILES-}"'|$\DOTFILES|' \
      -e 's|'"${XDG_CONFIG_HOME-}"'|$\XDG_CONFIG_HOME|' \
      -e 's|'"${HOME%/}"'|~|' \
      -e 's|[[:space:]][[:space:]]*->[[:space:]][[:space:]]*| → |' \
      -e 's|'\''||g' \
      >&2
}

hw() {
  set \
    -o xtrace
  command -p -- printf -- 'Hello,%sworld!\n' "${IFS-}"
  {
    set \
      +o xtrace
  } 2>/dev/null
}

histfile() {
  ## remove the last entry from `$HISTFILE`
  # temporarily use a copy of `$HISTFILE` until we figure out if this works

  # create a temporary location for the file
  command -p -- mkdir -p -- "${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash'

  # remove the old copy if any
  # `command find` instead of `command -p -- find` for SC2016 which appears because of the `-exec sh "$1"`
  command find -- "${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash' \
    -name "${HISTFILE##*/}" \
    -type f \
    -print \
    -exec sh -f -u -v -x -c 'command -p -- mv -- "${1-}" "${1-}".bak' _ {} +

  # create the copy
  # use the target directory AND target filename for less jarring stderr messages
  command -p -- cp -f -p -- "${HISTFILE-}" "${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash/'"${HISTFILE##*/}" &&
    command -p -- printf -- '\044{HISTFILE-}:\t%s\n' "${HISTFILE-}" &&
    # remove only the second-to-last line (the last line is now this command)
    # https://claude.ai/chat/93b3785b-0342-4f1e-8d0a-6b553832ddd3
    # \$-1d:
    #     \: escapes the following dollar sign
    #     $: refers to the last line of the file
    #    -1: moves the cursor one line up (to the second-to-last line)
    #     d: deletes that line
    command -p -- ed -s -- "${HISTFILE-}" <<EOF
\$-1d
w
q
EOF
  case "${?:-1}" in
  0)
    command -p -- diff -- "${HISTFILE-}" "${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash/'"${HISTFILE##*/}"
    ;;
  *)
    return "${?:-126}"
    ;;
  esac
}
alias -- hundo='histfile'

history_stats() {
  builtin fc -l 1 |
    command awk -- '{
  history[$2]++
  count++
}
END {
  for (command in history) {
    printf "%-4s %-.2f%% %s\n", history[command], history[command] * 100 / count, command
  }
}' |
    command -p -- grep \
      -v \
      -e './' \
      -e '(' |
    LC_ALL='C' command -p -- sort -n -r |
    command -p -- head -n "$((${LINES:-"$(
      command -p -- tput -- lines 2>/dev/null ||
        command -p -- printf -- '10 + 2 + 10 + 2 + 2'
    )"} - 3))" "${@-}"
}
alias -- zsh_stats >/dev/null 2>&1 &&
  unalias -- zsh_stats
alias -- zsh_stats='history_stats'

## .icns files
# convert to .png
icns_to_png() {
  set \
    -o noclobber \
    -o noglob \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "${file-}" in
      *.[Ii][Cc][Nn][Ss])
        # https://web.archive.org/web/0id_/simplehelp.net/?p=4870
        command -v -- sips >/dev/null 2>&1 &&
          command sips \
            --debug \
            --setProperty format png \
            --setProperty formatOptions 100 \
            "${file-}" \
            --addIcon \
            --out "${file%.*}"'.sips.png'
        command -v -- icns2png >/dev/null 2>&1 &&
          # icns2png output Goldilocks:
          #   `--list` increases verbosity
          #   `2>/dev/null` reduces verbosity
          command icns2png \
            --list \
            --extract \
            -- \
            "${file-}" 2>/dev/null
        ;;
      *)
        # EX_DATAERR
        return 65
        ;;
      esac
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o xtrace
  } 2>/dev/null
}

# identify the current machine
identify_os() {
  {
    command -p -- uname -a
    command sw_vers
    command lsb_release --all
    command hostnamectl
    command -p -- cat -- \
      '/etc/os-release' \
      '/usr/lib/os-release' \
      '/proc/version' \
      '/etc/issue'
    # https://github.com/dotnet/vscode-dotnet-runtime/blob/d37513361d/dotnetcore-acquisition-library/scripts/determine-linux-distro.sh
    if command -v -- zypper >/dev/null 2>&1; then
      command -p -- printf -- 'openSUSE\n'
    elif command -v -- apt-get >/dev/null 2>&1; then
      command -p -- printf -- 'Debian\n'
    elif command -v -- yum >/dev/null 2>&1; then
      command -p -- printf -- 'RedHat\n'
    elif command -v -- pacman >/dev/null 2>&1; then
      command -p -- printf -- 'ArchLinux\n'
    elif command -v -- eopkg >/dev/null 2>&1; then
      command -p -- printf -- 'Solus\n'
    elif command -v -- apk >/dev/null 2>&1; then
      command -p -- printf -- 'Alpine\n'
    fi
  } 2>/dev/null
}

install() {
  set \
    -o verbose \
    -o xtrace
  case "${1-}" in
  caveat*)
    shift
    {
      set \
        +o verbose \
        +o xtrace
    } 2>/dev/null
    case "${1-}" in
    environment*)
      command brew list -1 --formula | while IFS='' read -r -- formula; do
        if command brew info --formula -- "${formula-}" |
          command -p -- grep \
            -e 'print the names of formulae where there is a § Caveats' \
            -e ' Caveats' \
            >/dev/null 2>&1; then
          command -p -- printf -- '%s\n' "${formula-}"
        fi
      done
      ;;
    *)
      command brew list -1 --formula | while IFS='' read -r -- formula; do
        if command brew info --formula -- "${formula-}" |
          command -p -- grep \
            -e 'print the names of formulae where environmental-variable modification is suggested' \
            -e '[[:upper:]]=' \
            >/dev/null 2>&1; then
          command -p -- printf -- '%s\n' "${formula-}"
        fi
      done
      ;;
    esac
    ;;
  file*)
    shift
    set \
      -o noclobber \
      -o verbose \
      -o xtrace
    command brew bundle dump \
      --all \
      --cask \
      --debug \
      --describe \
      --file=- \
      --force \
      --formula \
      --mas \
      --no-restart \
      --tap \
      --verbose \
      --vscode \
      --whalebrew \
      "${@-}" |
      # on non-comment lines, replace all double quotes with single quotes
      ##### make up your mind Super-Linter
      ##### command -p -- sed \
      #####   -e '/#/! s/"/'\''/g' |
      # move each package name onto the comment line above it, if any
      command -p -- sed \
        -e '$! N' \
        -e '/^#.*\n[^#]/ s/\n/\t/' \
        -e 'P' \
        -e 'D' |
      # swap the package and the comment
      command -p -- sed \
        -e 's/\(.*\)\t\(.*\)/\2\1/' |
      # prepend each category with a number for sorting
      command -p -- sed \
        -e 's/^\(tap\)/1\1/' \
        -e 's/^\(brew\)/2\1/' \
        -e 's/^\(cask\)/3\1/' |
      # sort output by package name
      LC_ALL='C' command -p -- sort -f | {
      command -p -- printf -- '#!/usr/bin/env ruby\n'
      command -p -- printf -- '# frozen_string_literal: true\n\n'
      command -p -- sed \
        -e '# remove the prepended numbers' \
        -e 's/^[[:digit:]]//' \
        -e '# restore each comment to a line above its package' \
        -e 's/\([^#]*\)\(#.*\)/\2\n\1/'
    } >|"${HOMEBREW_BUNDLE_FILE_GLOBAL:-${HOMEBREW_BUNDLE_FILE:-${HOME%/}/.Brewfile}}" &&
      command -p -- chmod -- 755 "${HOMEBREW_BUNDLE_FILE_GLOBAL:-${HOMEBREW_BUNDLE_FILE:-${HOME%/}/.Brewfile}}"
    {
      set \
        +o noclobber \
        +o verbose \
        +o xtrace
    } 2>/dev/null
    ;;
  HEAD*)
    shift
    {
      set \
        +o verbose \
        +o xtrace
    } 2>/dev/null
    command brew list -1 --formula | while IFS='' read -r -- formula; do
      if command brew info --formula -- "${formula-}" |
        command -p -- grep \
          -e 'print the names of formulae where --HEAD is available' \
          -e '^--HEAD$' \
          >/dev/null 2>&1; then
        command -p -- printf -- '%s\n' "${formula-}"
      fi
    done
    ;;
  search)
    shift
    brewsearch "${@-}"
    ;;
  info)
    command brew "${@-}"
    ;;
  --)
    shift
    ;;
  *)
    # @TODO! this should allow for  install --search  -- 𝑥
    #                               install --info    -- 𝑥
    #                               install           -- 𝑥
    #                  and perhaps  install --install -- 𝑥

    # Homebrew
    if command -v -- brew >/dev/null 2>&1; then
      command brew install "${@-}"
    # search brew search --debug --verbose --desc git; brew search git

    # Alpine Linux
    elif command -v -- apk >/dev/null 2>&1; then
      command apk add "${@-}"

    # Ubuntu, Debian
    elif command -v -- apt >/dev/null 2>&1; then
      command sudo -- apt install "${@-}"
    elif command -v -- apt-get >/dev/null 2>&1; then
      # https://clarkgrubb.com/package-managers#pkg-managers
      command sudo -- apt-get install -y "${@-}"

    # Arch Linux
    elif command -v -- pacman >/dev/null 2>&1; then
      # https://unix.stackexchange.com/a/34607
      # if Arch fails here, try `pacman --sync -yy`
      command pacman --sync -yy "${@-}"
    else
      command -p -- printf -- 'unable to detect system software installer\n'
      command -p -- sleep 1
      command -p -- printf -- 'aborting\n'
      return 1
    fi
    ;;
  esac
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}
alias -- i='install'
brewsearch() {
  while command -p -- test "${#}" -ne 0; do
    command brew search --formula --verbose "${1-}"
    shift
  done
}

interactive() {
  # POSIX-compliant check for interactive shell
  # https://unix.stackexchange.com/a/26827
  case "${--}" in
  *i*)
    # interactive shell
    return 0
    ;;
  *)
    # non-interactive shell
    return 1
    ;;
  esac
}

## invisible
# make files invisible to Finder
# -h apply to symlinks, not targets
# -x stay on current system
# -vv be verbose and print old and new flags
alias -- \
  invisible='command chflags -h -v -v -x hidden' \
  uninvisible='command chflags -h -v -v -x nohidden'

image_color_count() {
  # print the number of unique colors found in the image
  # usage: image_color_count image.jpg
  for file in "${@-}"; do
    case "${file-}" in
    --)
      shift
      ;;
    *)
      command magick "${file-}" txt:- |
        # if column 3 is a hashed hexadecimal color,
        # that has not yet been printed,
        # then print it
        command awk -- '$3 ~ /^#[[:xdigit:]]{6,8}$/ && ! seen[$3]++ {print $3}' |
        LC_ALL='C' command -p -- sort -f |
        LC_ALL='C' command -p -- tr -- '[:upper:]' '[:lower:]' |
        LC_ALL='C' command -p -- nl
      ;;
    esac
  done
}

image_color_frequency() {
  for file in "${@-}"; do
    case "${file-}" in
    --)
      shift
      ;;
    *)
      command magick "${file-}" txt:- |
        command awk -- '$3 ~ /^#[[:xdigit:]]{6,8}$/ {print $3}' |
        LC_ALL='C' command -p -- sort |
        LC_ALL='C' command -p -- uniq -c |
        LC_ALL='C' command -p -- sort -n |
        # %10d allows columnar output iff each frequency occurs fewer than 10^9 times
        command awk -- '{printf "%10d %s\n", $1, $2}' |
        LC_ALL='C' command -p -- tr -- '[:upper:]' '[:lower:]'
      ;;
    esac
  done
}

image_color_list() {
  # print the number of unique colors found in the image
  # usage: image_color_count image.jpg
  for file in "${@-}"; do
    case "${file-}" in
    --)
      shift
      ;;
    *)
      command magick "${file-}" txt:- |
        # if column 3 is a hashed hexadecimal color,
        # that has not yet been printed,
        # then print it
        command awk -- '$3 ~ /^#[[:xdigit:]]{6,8}$/ && ! seen[$3]++ {print $3}' |
        LC_ALL='C' command -p -- sort -f |
        LC_ALL='C' command -p -- tr -- '[:upper:]' '[:lower:]'
      ;;
    esac
  done
}

image_get_pixel() {
  # https://github.com/cirosantilli/dotfiles/blob/60ca745cdc/home/.bashrc#L2829-L2836
  # $ image_get_pixel file.png 10 20
  # to obtain the color of the pixel at x=10, y=20
  command magick -- "${1-}" -crop 1x1'+'"${2:-1}"'+'"${3:-1}" rgba:- |
    command -p -- od -A n -t x1 |
    command -p -- sed \
      -e 's/^[[:space:]]*//' \
      -e 'q'
}

ip() {
  # https://web.archive.org/web/2022/news.ycombinator.com/item?id=29848744
  set -- 'https://ipinfo.io/'"${1-}"'?token='"${IPINFO_TOKEN-}"
  {
    command curl \
      --fail \
      --show-error \
      --silent \
      --url "${1-}" ||
      command wget \
        --content-on-error \
        --hsts-file=/dev/null \
        --output-document=- \
        --quiet \
        -- \
        "${1-}"
  } 2>/dev/null |
    command -p -- sed \
      -n \
      -e '/ipinfo/ d' \
      -e 's/.*"\(.*\)".*/\1/p'
}

## JPEG
to_jpg() {
  set \
    -o noclobber \
    -o noglob \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command magick \
        -quality 100 \
        -verbose \
        -- \
        "${file-}" \
        "${file%.*}"'.jpg'
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o xtrace
  } 2>/dev/null
}

guetzli_r() {
  set \
    -o noclobber \
    -o noglob \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command -p -- test ! -e "${file%.*}"'-guetzli.jpg' &&
      case "${file-}" in
      *.[Jj][Pp][Ee][Gg] | *.[Jj][Pp][Gg])
        command guetzli \
          --nomemlimit \
          --quality 100 \
          --verbose \
          -- \
          "${file-}" \
          "${file%.*}"'-guetzli.jpg'
        ;;
      *)
        # EX_DATAERR
        return 65
        ;;
      esac
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o xtrace
  } 2>/dev/null
}

## JPEG

jsonlint_r() {
  command npm list --location=global -- '@prantlf/jsonlint' >/dev/null 2>&1 ||
    command npm list --location=project -- '@prantlf/jsonlint' >/dev/null 2>&1 ||
    return "${?:-127}"
  PS4=' ' command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.rbenv' -prune -o \
    -path '*/.venv' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/__pycache__' -prune -o \
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
    -name '*.json.example' -o \
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
    -name '*.tact' -o \
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
    -name 'MODULE.bazel.lock' -o \
    -name 'Package.resolved' -o \
    -name 'Pipfile.lock' -o \
    -name 'proselintrc' -o \
    -name 'tldrrc' \
    ')' \
    -type f \
    -exec sh -x -c 'for file in "${@-}"; do
  command git ls-files --error-unmatch -- "${file-}" >/dev/null 2>&1 ||
    ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
    command npm exec -- @prantlf/jsonlint --in-place --trailing-newline --trim-trailing-commas -- "${file-}"
done
' _ {} +
}

## last
alias -- last_character='tail -c -1'
last_word() {
  while command -p -- test "${#}" -gt 0; do
    command -p -- printf -- '%s\n' "${1##* }"
    shift
  done
}

length_of_longest_line() {
  # https://unix.stackexchange.com/a/523516
  # `$1` is a file as an argument and
  # `-` is stdin
  command awk -- 'BEGIN {max = 0} {if (length($0) > max) {max = length($0)} } END {print max}' "${1:--}"
}
sort_by_line_length() {
  command awk -- '{print length($0), $0}' "${1:--}" |
    LC_ALL='C' command sort -k 1,2 -n "${2:--}"
}
alias -- length_of_line_sort='sort_by_line_length'

# less: install the pager
install_less() {
  (
    set \
      -o verbose \
      -o xtrace
    utility="$(
      command -v -- gmake
    )"
    target="${HOME%/}"'/c/less'
    command -p -- mkdir -p -- "${target-}"

    # because `make -C` is not POSIX... but neither is `make -f`...
    cd -L -- "${target-}" ||
      return 1

    command git -C "${target-}" pull 2>/dev/null ||
      command git -c core.ignoreCase=false clone --progress --recursive --template='' -- https://github.com/gwsw/less "${target-}" 2>&1 |
      command -p -- sed \
        -e 's|'\''.'\''|'"${target-}"'|' \
        -e 's|'"${custom-}"'|$\custom|' \
        -e 's|'"${DOTFILES-}"'|$\DOTFILES|' \
        -e 's|'"${XDG_CONFIG_HOME-}"'|$\XDG_CONFIG_HOME|' \
        -e 's|'"${HOME%/}"'|~|'
    command -p -- rm -f -r -- "${target-}"'/.gitingore'
    command "${utility:-make}" -C "${target-}" -f Makefile.aut distfiles
    command "${utility:-make}" -C "${target-}" -f Makefile.aut distfiles
    if command -p -- test -w '/usr/local/bin'; then
      bindir='/usr/local/bin'
    elif command -p -- mkdir -p -- "${HOME%/}"'/.local/bin' 2>/dev/null; then
      bindir="${HOME%/}"'/.local/bin'
    fi
    if command -p -- test -w '/usr/local/share/man'; then
      mandir='/usr/local/share/man'
    elif command -p -- mkdir -p -- "${HOME%/}"'/.local/share/man' 2>/dev/null; then
      mandir="${HOME%/}"'/.local/share/man'
    fi
    # `pcre-config`, `pcre2-config` require `--version` to return a zero exit code
    if command pcre2-config --version >/dev/null 2>&1; then
      with_regex='pcre2'
    elif command pcre-config --version >/dev/null 2>&1; then
      with_regex='pcre'
    fi
    command -p -- sh ./configure --with-editor="${EDITOR:-vi}" --with-regex="${with_regex:-auto}" bindir="${bindir-}" mandir="${mandir-}"
    command "${utility:-make}" install
    {
      set \
        +o verbose \
        +o xtrace
    } 2>/dev/null
    unset bindir 2>/dev/null || bindir=''
    unset mandir 2>/dev/null || mandir=''
    unset target 2>/dev/null || target=''
    unset utility 2>/dev/null || utility=''
    unset with_regex 2>/dev/null || with_regex=''
  )
}
alias -- less_install='install_less'

# linguist
breakdown() {
  utility="$(
    command -v -- github-linguist ||
      command -v -- git-linguist ||
      command -v -- linguist
  )"
  command -p -- test "${utility-}" = '' &&
    return 127
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    return "${?:-1}"
  case "${1-}" in
  -s | --summary)
    shift
    command "${utility-}" "${@-}" "$(
      command git rev-parse --show-toplevel --path-format=relative |
        command -p -- sed -e '1 q'
    )" 2>/dev/null ||
      command "${utility-}" "${@-}" "$(command git rev-parse --show-toplevel)" 2>/dev/null
    ;;
  *)
    command "${utility-}" --breakdown "${@-}" "$(
      command git rev-parse --show-toplevel --path-format=relative |
        command -p -- sed -e '1 q'
    )" 2>/dev/null ||
      command "${utility-}" --breakdown "${@-}" "$(command git rev-parse --show-toplevel)" 2>/dev/null |
      command -p -- sed \
        -e '$ d'
    ;;
  esac
  unset utility 2>/dev/null || utility=''
}
alias -- \
  bdo='breakdown' \
  bdos='breakdown --summary'

# list files
alias -- ld >/dev/null 2>&1 &&
  unalias -- ld
alias -- l >/dev/null 2>&1 &&
  unalias -- l
if command eza --color=auto >/dev/null 2>&1; then
  alias -- \
    l='command eza --all --bytes --classify --color-scale=all --color=auto --icons --long --no-permissions --no-user --octal-permissions --time-style=long-iso' \
    ld='command eza --color=auto --color-scale=all --all --bytes --classify --icons --long --no-permissions --no-user --octal-permissions --time-style=long-iso --total-size --only-dirs' \
    lg='command eza --all --bytes --classify --color-scale=all --color=auto --git --icons --long --no-permissions --no-user --octal-permissions --time-style=long-iso' \
    lgs='command eza --all --bytes --classify --color-scale=all --color=auto --git --icons --long --no-permissions --no-user --octal-permissions --time-style=long-iso --sort=size' \
    lm='command eza --all --bytes --classify --color-scale=all --color=auto --icons --long --no-permissions --no-user --octal-permissions --time-style=long-iso --sort=modified'
elif command gls --color=auto >/dev/null 2>&1; then
  alias -- \
    l='command gls -A -F -g -o --color=auto --time-style=+%Y-%m-%d\ %l:%M:%S\ %P' \
    ld='command find -- . -path '\''./*/*'\'' -prune -o -path '\''*/.git'\'' -prune -o -path '\''./*'\'' -type d -exec gls -A -F -d -g -o --color=auto --time-style=+%Y-%m-%d\ %l:%M:%S\ %P -- {} +'
elif command ls --color=auto --time-style=+%Y-%m-%d\ %l:%M:%S\ %P >/dev/null 2>&1; then
  alias -- \
    l='command ls -A -F -g -o --color=auto --time-style=+%Y-%m-%d\ %l:%M:%S\ %P' \
    ld='command find -- . -path '\''./*/*'\'' -prune -o -path '\''*/.git'\'' -prune -o -path '\''./*'\'' -type d -exec ls -A -F -d -g -o --color=auto --time-style=+%Y-%m-%d\ %l:%M:%S\ %P -- {} +'
else
  if
    command -p -- test "$(
      command -p -- ls -G --color=always -- "${HOME%/}" |
        command -p -- od
    )" = "$(
      command ls -G --color=always -- "${HOME%/}" |
        command -p -- od
    )" &&
      command -p -- test "$(
        command ls -G --color=always -- "${HOME%/}" |
          command -p -- od
      )" = "$(
        command ls --color=always -- "${HOME%/}" 2>/dev/null |
          command -p -- od
      )"
  then
    alias -- \
      l='command ls -A -F -g -o --color=auto --time-style=+%Y-%m-%d\ %l:%M:%S\ %P' \
      ld='command find -- . -path '\''./*/*'\'' -prune -o -path '\''*/.git'\'' -prune -o -path '\''./*'\'' -type d -exec ls -A -F -d -g -o --color=auto --time-style=+%Y-%m-%d\ %l:%M:%S\ %P -- {} +'
  else
    alias -- \
      l='command ls -A -F -g -o --time-style=+%Y-%m-%d\ %l:%M:%S\ %P' \
      ld='command find -- . -path '\''./*/*'\'' -prune -o -path '\''*/.git'\'' -prune -o -path '\''./*'\'' -type d -exec ls -A -F -d -g -o --color=auto --time-style=+%Y-%m-%d\ %l:%M:%S\ %P -- {} +'
  fi
  # TODO: `ls -o` (`ls -l` without group) is not POSIX
  alias -- \
    l='command -p -- ls -A -F -G -g -o' \
    ld='command find -- . -path '\''./*/*'\'' -prune -o -path '\''*/.git'\'' -prune -o -path '\''./*'\'' -type d -exec ls -A -F -G -d -g -o -- {} +'
fi

list_functions() {
  # print the names of functions found in a shell script file
  for file in "${@-}"; do
    command -p -- sed \
      -e '# does the first non-empty line resemble a shell directive?' \
      -e '/./,$! d' \
      -e '1 q' \
      "${file-}" |
      command -p -- grep \
        -e '^#!.*bin.*[^c]sh' \
        -e '^[[:space:]]*\(function[[:space:]]\)\{0,1\}[[:space:]]*[A-Za-z_][-A-Za-z_0-9]*()[[:space:]]*{.*$' \
        -e 'autoload' \
        -e 'compdef' \
        -e 'openrc' \
        >/dev/null 2>&1 &&
      LC_ALL='C' command -p -- sed \
        -n \
        -e '# https://github.com/jschauma/cs615asa/commit/2a54687425' \
        -e '# the last dot star is for one-line functions like in hblock but has not been well tested' \
        -e 's/^\([[:alpha:]_][[:alpha:][:digit:]_]*\)()[[:space:]]*{.*/\1/p' \
        "${file-}" |
      LC_ALL='C' command -p -- sort -f
  done
}

alias -- list_all_functions='print ${(F)${(-)${(k)functions}}}'

list_uniform_type_identifiers() {
  # https://github.com/moretension/duti/blob/46a5b28913/duti.1#L295-L300
  command -p -- find -- /System/Library/Frameworks \
    -name 'lsregister' \
    -type f \
    -exec sh -c '{} -dump' ';' |
    command awk -- '/^uti:/ && ! seen[$2]++ {print $2}' |
    LC_ALL='C' command -p -- sort -f
}
alias -- list_utis='list_uniform_type_identifiers'

literoj() {
  LC_ALL='eo' command -p -- printf -- 'ĈĉĜĝĤĥĴĵŜŝŬŭ\n'
}

# list --octal
ls8() {
  # https://github.com/xero/dotfiles/blob/fd651dbdc7/zsh/.config/zsh/06-aliases.zsh#L19
  command -p -- ls -A -F -G -g -h --color=always -- "${@-}" |
    command -p -- sed \
      -e 's/--x/1/g' \
      -e 's/-w-/2/g' \
      -e 's/-wx/3/g' \
      -e 's/r--/4/g' \
      -e 's/r-x/5/g' \
      -e 's/rw-/6/g' \
      -e 's/rwx/7/g' \
      -e 's/---/0/g' \
      -e 's/rwt/7/g' |
    command -p -- sed -e 's/^\(....\) [[:digit:]] /\1 /'

  command -p -- ls -l |
    command -p -- sed \
      -e 's/rwx/7/g' \
      -e 's/rw-/6/g' \
      -e 's/r-x/5/g' \
      -e 's/r--/4/g' \
      -e 's/-wx/3/g' \
      -e 's/-w-/2/g' \
      -e 's/--x/1/g' \
      -e 's/---/0/g'
}

# list --others
lso() {
  command git -c color.status=always -c core.quotePath=false ls-files --exclude-standard --others "${@-}" |
    command awk -- '{print "./" $0}'
}

## M4A
to_m4a() {
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    # https://stackoverflow.com/a/55478355
    command ffmpeg \
      -nostdin \
      -i "${file-}" \
      -b:a 320k \
      -c:a alac \
      -c:v copy \
      -- \
      "${file%.*}"'.m4a'
  done
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

## any audio to MP3
to_mp3() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    # `-vn`: no video if any
    # `-c:a libmp3lame` a high-quality MP3 encoder
    # `-q:a 0`: 0 = lossless
    # "${file%.*}": filename without extension
    command ffmpeg \
      -i "${file-}" \
      -vn \
      -c:a libmp3lame \
      -q:a 0 \
      "${file%.*}"'.mp3'
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

to_mp4() {
  set \
    -o noclobber \
    -o noglob \
    -o xtrace
  # https://stackoverflow.com/a/66248591
  for file in "${@-}"; do
    command ffmpeg \
      -i "${file-}" \
      -crf 0 \
      "${file%.*}"'mp4' ||
      command ffmpeg \
        -i "${file-}" \
        -crf 18 \
        -filter:v format=yuv420p \
        "${file%.*}"'.mp4'
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o xtrace
  } 2>/dev/null
}

## mackup
mu() {
  {
    command -v -- mackup >/dev/null 2>&1 &&
      cd -- "${DOTFILES-}"
  } ||
    return 1
  command -v -- cleanup >/dev/null 2>&1 &&
    cleanup "${@-}"
  command mackup backup --force --root --verbose |
    command -p -- sed \
      -e 's|'"${custom-}"'|$\custom|' \
      -e 's|'"${DOTFILES-}"'|$\DOTFILES|' \
      -e 's|'"${XDG_CONFIG_HOME-}"'|$\XDG_CONFIG_HOME|' \
      -e 's|'"${HOME%/}"'|~|'
  command git fetch --all --keep --multiple --progress --prune --verbose --update-shallow
  command git submodule update --init --recursive
  command git submodule sync --recursive
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no |
    command -p -- sed \
      -e '$ d'
}

# dotfiles
dot() {
  cd -- "${DOTFILES-}" ||
    return 1
  l 2>/dev/null ||
    command -p -- ls -A -F -g -o 2>/dev/null
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no 2>/dev/null |
    command -p -- sed \
      -e '$ d'
}
alias -- \
  .f='{ command -p -- mkdir -p -- "${HOME%/}"'\''/c/.f'\'' && cd -- "${HOME%/}"'\''/c/.f'\''; } || return "${?:-1}"' \
  .m='{ command -p -- mkdir -p -- "${HOME%/}"'\''/c/.m'\'' && cd -- "${HOME%/}"'\''/c/.m'\''; } || return "${?:-1}"' \
  .g='{ command -p -- mkdir -p -- "${_GITHUB:-${HOME%/}/c/.g}" && cd -- "${_GITHUB:-${HOME%/}/c/.g}"; } || return "${?:-1}"'

## Maestral && 1Password somehow
command -v -- maestral >/dev/null 2>&1 && {
  command -v -- _maestral >/dev/null 2>&1 || {
    command maestral completion "$(command -p -- basename -- "${SHELL%%[0-9-]*}")" >/dev/null 2>&1 &&
      command -p -- test "${FPATH-}" != '' &&
      case ':'"${FPATH-}"':' in
      *:/usr/local/share/"$(command -p -- basename -- "${SHELL%%[0-9-]*}")"/site-functions:*)
        command maestral completion "$(command -p -- basename -- "${SHELL%%[0-9-]*}")" >/usr/local/share/"$(command -p -- basename -- "${SHELL%%[0-9-]*}")"/site-functions/_maestral
        ;;
      *) ;;
      esac
  }
}
ms() {
  command maestral status |
    command -p -- sed \
      -e '/^$/ N' \
      -e '/\\n$/ D' \
      -e '/Path *Error/,$ d'
}
command -v -- op >/dev/null 2>&1 && {
  command -v -- _op >/dev/null 2>&1 || {
    command op completion "$(command -p -- basename -- "${SHELL%%[0-9]*}")" >/dev/null 2>&1 &&
      command -p -- test "${FPATH-}" != '' &&
      case ':'"${FPATH-}"':' in
      *:/usr/local/share/"$(command -p -- basename -- "${SHELL%%[0-9]*}")"/site-functions:*)
        command op completion "$(command -p -- basename -- "${SHELL%%[0-9]*}")" >/usr/local/share/"$(command -p -- basename -- "${SHELL%%[0-9]*}")"/site-functions/_op
        ;;
      *) ;;
      esac
  }
}

# batman
man() {

  # the `compdef` probably belongs after the `batman` check, but
  # I want it available immediately. It might even
  # belong outside the function or
  # even in `~/.zshenv` 2024-05
  compdef -- batman='man'

  if command -v -- batman >/dev/null 2>&1; then
    command batman "${@-}"
  else
    command -p -- man "${@-}"
  fi
}

man_pdf() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  if command -v -- ps2pdf >/dev/null 2>&1; then
    while command -p -- test "${#}" -gt 0; do
      command man -t -- "${1-}" 2>/dev/null |
        command ps2pdf - - | command open -a Preview -f
      shift
    done
  elif command -v -- mandoc >/dev/null 2>&1 && {
    command -p -- test -x /System/Applications/Preview.app/Contents/MacOS/Preview ||
      command -p -- test -x /Applications/Preview.app/Contents/MacOS/Preview
  }; then
    while command -p -- test "${#}" -gt 0; do
      command mandoc -T pdf "$(command man -w "${1-}" 2>/dev/null)" |
        command open -a Preview -f
    done
  fi
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}
command -v -- _man >/dev/null 2>&1 &&
  compdef -- man_pdf='man'

markdownlint_r() {
  set \
    -o verbose \
    -o xtrace
  { command -p -- test -e "${XDG_CONFIG_HOME:-${HOME%/}/.config}"'/markdownlint/config.json' &&
    configuration='--config='"${XDG_CONFIG_HOME:-${HOME%/}/.config}"'/markdownlint/config.json'; } ||
    { command -p -- test -e "${XDG_CONFIG_HOME-}"'/markdownlint/config.json' &&
      configuration='--config='"${XDG_CONFIG_HOME-}"'/markdownlint/config.json'; } ||
    { command -p -- test -e "${HOME%/}"'/.markdownlint.json' &&
      configuration='--config='"${HOME%/}"'/.markdownlint.json'; } ||
    { command -p -- test -e "${HOME%/}"'/.markdownlint.yml' &&
      configuration='--config='"${HOME%/}"'/.markdownlint.yml'; }
  export configuration
  # Markdown filename extensions
  # https://github.com/github/linguist/blob/7503f7588c/lib/linguist/languages.yml#L3707-L3718
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
    -name '*.md' -o \
    -name '*.livemd' -o \
    -name '*.markdn' -o \
    -name '*.markdown' -o \
    -name '*.mdown' -o \
    -name '*.mdwn' -o \
    -name '*.mdx' -o \
    -name '*.mkd' -o \
    -name '*.mkdn' -o \
    -name '*.mkdown' -o \
    -name '*.ronn' -o \
    -name '*.scd' -o \
    -name '*.workbook' -o \
    -name 'contents.lr' \
    ')' \
    -type f \
    -print \
    -exec sh -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command markdownlint "${configuration-}" --disable MD013 MD033 --dot --fix -- "${1-}"' _ {} ';'
  unset configuration 2>/dev/null || configuration=''
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
  unset configuration 2>/dev/null || configuration=''
}

## mindepth and maxdepth
# not defined by POSIX, but these are equivalent
maxdepth() {
  # instead of `find . -maxdepth 2 -print`, use `find . -path './*/*/*' -prune -o -print`
  path_argument='./*'
  depth="${1:-0}"
  while command -p -- test "${depth-}" -gt 0; do
    path_argument="${path_argument-}"'/*' &&
      depth="$((depth - 1))"
  done
  command -p -- printf -- '#!/usr/bin/env sh\ncommand -p -- find -- . -path \047%s\047 -prune -o -print\n' "${path_argument-}"
  unset path_argument 2>/dev/null || path_argument=''
  unset depth 2>/dev/null || depth=''
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
  unset path_argument 2>/dev/null || path_argument=''
  unset depth 2>/dev/null || depth=''
}
m1m1() {
  {
    command -p -- printf -- '#!/usr/bin/env sh\n'
    command -p -- printf -- 'command -p -- find -- . -path \047./*/*\047 -prune -o -path \047./*\047 -print\n'
  } | command bat \
    --color=auto \
    --decorations=never \
    --language=sh \
    --paging=never \
    -- \
    - 2>/dev/null ||
    command -p -- cat \
      -- \
      -
}

# https://unix.stackexchange.com/a/30950
# TODO removing `command` to figure out if I need `compdef` 2022-05-29
alias -- mv='mv -v -i'

# find files with non-ASCII characters
non_ascii() {
  # file names
  # https://unix.stackexchange.com/a/109753

  if command -p -- test "$(
    LC_ALL='C' command find -- "${@:-.}" \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -path './*' \
      '(' \
      ! -name '*[[:alnum:]]*' -o \
      -name '*[[:space:]]*' \
      -name '*[! -~]*' \
      ')' \
      -print
  )" != ''; then

    command -p -- printf -- 'non-ASCII file names:\n'
    LC_ALL='C' command find -- "${@:-.}" \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -path './*' \
      '(' \
      ! -name '*[[:alnum:]]*' -o \
      -name '*[[:space:]]*' \
      -name '*[! -~]*' \
      ')' \
      -print
  fi

  # horizontal rule
  command -p -- printf -- '\055\055\055\n'

  # file content
  # https://stackoverflow.com/a/9395552
  # `-I`: exclude binary files
  # `-e`: search expression
  if LC_ALL='C' command git --no-pager grep -I --no-index --max-depth=0 --exclude-standard --perl-regexp --quiet --recursive -e '[\200-\377]|[^\t -~]'; then
    command -p -- printf -- 'file content i.\n'
    LC_ALL='C' command git --no-pager grep -I --no-index --max-depth=0 --exclude-standard --perl-regexp --line-number --recursive -e '[\200-\377]|[^\t -~]'
  fi
  #  # https://stackoverflow.com/a/3208902
  #  LC_ALL='C' command -p -- grep --color -r -e '[^ -~]' >/dev/null 2>&1 &&
  #    command -p -- printf -- 'file content ii.\n' &&
  #    LC_ALL='C' command -p -- grep --color -n -r -e '[^ -~]'
}
non_ascii_filenames() {
  LC_ALL='C' command find -- "${@:-.}" \
    -path '*/.git' -prune -o \
    -path '*/node_modules' -prune -o \
    -path './*' \
    '(' \
    ! -name '*[[:alnum:]]*' -o \
    -name '*[[:space:]]*' \
    -name '*[! -~]*' \
    ')' \
    -print
  # not sure why this prints WITHOUT using the C locale, but that happens to be what I want
}

nslookup_r() {
  # repeated nameserver lookup like itools.com/internet of olden times
  while command -p -- test "${#}" -gt 0; do
    output="$(command nslookup "${1-}" 2>&1)"
    command -p -- printf -- '%s\n' "${output-}" | command -p -- grep -A 1 -e 'Name' | command -p -- tail -n 1 | command awk -- '{print $2}'
    command -p -- printf -- '%s\n' "${output-}" | command -p -- grep -e 'name' | command awk -- '{print $4}'
    shift
  done
} && # YIPES / @TODO!?
  command -v -- _nslookup >/dev/null 2>&1 &&
  compdef -- nslookup_r='nslookup'

odb() {
  # odb: convert hexadecimal escapes to octal escapes
  # usage: `odb <string>` or `echo <string> | odb`
  # test for standard input or if not, then use arguments
  { {
    command -p -- test "${#}" -eq 0 && command -p -- cat -- -
    # while this is ultra clever and succinct, this could be made cleverer yet perhaps by
    # checking if `$1` = `-` which is standard input
    # https://git.sr.ht/~q3cpma/scripts/tree/64fee0c02b9/item/util.sh#L39-49
  } || command -p -- printf -- '%s' "${@-}"; } |
    # `-A n` hide the address base
    # `-t o1` convert to octal
    command -p -- od \
      -A n \
      -t o1 |
    command -p -- sed \
      -n \
      -e '# move the results onto one line' \
      -e 'H' \
      -e '$ {' \
      -e '  x' \
      -e '  # remove trailing final spaces, tabs, and newlines' \
      -e '  s/[[:space:]]*$//' \
      -e '  # replace all remaining strings of spaces, tabs, or newlines with a single backslash "\"' \
      -e '  s/[[:space:]][[:space:]]*/\\/gp' \
      -e '}'
}

ocr() {
  command -v -- ocrmypdf >/dev/null 2>&1 ||
    return "${?:-1}"
  #
  # TODO! make this work on all PDFs in folder if no argument is provided
  #
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "${file-}" in
      *.[Pp][Dd][Ff])
        # useful when processing multiple files
        command -p -- printf -- '\n%s\n' "${file-}" >&2 &&
          command ocrmypdf \
            --deskew \
            --language eng \
            --optimize 0 \
            --pdfa-image-compression lossless \
            --rotate-pages \
            --skip-text \
            -- \
            "${file-}" "${file-}"
        ;;
      *)
        shift 1
        ;;
      esac
  done
}
ocr_eo() {
  command -v -- ocrmypdf >/dev/null 2>&1 ||
    return "${?:-1}"
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "${file-}" in
      *.[Pp][Dd][Ff])
        command -p -- printf -- '\n%s\n' "${file-}" >&2 &&
          command ocrmypdf \
            --deskew \
            --language eng+epo \
            --optimize 0 \
            --pdfa-image-compression lossless \
            --rotate-pages \
            --skip-text \
            -- \
            "${file-}" "${file-}"
        ;;
      *)
        shift 1
        ;;
      esac
  done
}

# open current directory if no argument is given
open() {
  if command -p -- test "${#}" -eq 0; then
    command open -- "${PWD:-.}"
  else
    case "${1-}" in
    P)
      { command -p -- test "${2-}" != '' &&
        command open -- 'https://pubs.opengroup.org/onlinepubs/9799919799/utilities/'"${2-}"'.html'; } ||
        command open -- 'https://pubs.opengroup.org/onlinepubs/9799919799/idx/utilities.html'
      ;;
    p)
      { command -p -- test "${2-}" != '' &&
        command open -- 'https://pubs.opengroup.org/onlinepubs/9699919799/utilities/'"${2-}"'.html'; } ||
        command open -- 'https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html'
      ;;
    B)
      { command -p -- test "${2-}" != '' &&
        command open -- 'https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#'"${2-}"; } ||
        command open -- 'https://pubs.opengroup.org/onlinepubs/9799919799/idx/sbi.html'
      ;;
    b)
      { command -p -- test "${2-}" != '' &&
        command open -- 'https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#'"${2-}"; } ||
        command open -- 'https://pubs.opengroup.org/onlinepubs/9699919799/idx/sbi.html'
      ;;
    g)
      shift &&
        gopen "${@-}"
      ;;
    sc*)
      command open -- 'https://github.com/koalaman/shellcheck/wiki/SC'"${1#sc}"
      ;;
    SC*)
      command open -- 'https://github.com/koalaman/shellcheck/wiki/'"${1-}"
      ;;
    so*)
      # like cheat.sh’s `so/q/33041363`
      command open -- 'https://stackoverflow.com/'"${1#so/}"
      ;;
    *)
      command open "${@-}"
      ;;
    esac
  fi
}
# if there is no `xdg-open`, then alias it to `open`
command -v -- xdg-open >/dev/null 2>&1 ||
  alias -- xdg-open='open'

## pax
unpax() {
  while command -p -- test "${#}" -gt 0; do
    command -p -- uncompress -f -v -- "${1-}" &&
      set -- "${1%.Z}"
    command -p -- pax -r -v -f "${1-}"
    shift
  done
}

## pasteboard
pbc() {
  # gather content, but also print it
  command pbcopy &&
    command pbpaste
}
# https://github.com/ferrarimarco/dotfiles/commit/dc9e378f37
command -v -- pbcopy >/dev/null 2>&1 ||
  alias -- pbcopy='xclip -selection clipboard'
command -v -- pbpaste >/dev/null 2>&1 ||
  alias -- pbpaste='xclip -selection clipboard -o'

pdf_images() {
  ## extract images from a PDF
  # requires `pdfimages` from `poppler`
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "${file-}" in
      *.[Pp][Dd][Ff])
        # -p: add page numbers to filenames
        # -print-filenames: to standard output
        command pdfimages \
          -all \
          -p \
          -print-filenames \
          "${file-}" \
          "${file%.*}"-
        ;;
      *) ;;
      esac
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

perltidy_r() {
  set \
    -o noclobber \
    -o noglob \
    -o nounset \
    -o verbose \
    -o xtrace
  command -v -- find_perl_files >/dev/null 2>&1 &&
    command -v -- perltidy >/dev/null 2>&1 ||
    return 127
  find_perl_files | while IFS='' read -r -- file; do
    command git ls-files --error-unmatch -- "${file-}" >/dev/null 2>&1 ||
      ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
      command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/perltidy' &&
      command -p -- cp -f -p -- "${file-}" "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/perltidy/'"${file##*/}" &&
      command perltidy --outfile "${file-}" "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/perltidy/'"${file##*/}"
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o nounset \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

permissions() {
  # restore default file and directory permissions and
  # set owner and group to current user
  set \
    -o xtrace
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    return "${?:-1}"
  command -p -- chown -R "$(command -p -- id -u)":"$(command -p -- id -g)" .
  # make all directories traversable
  command -p -- find -- . -type d -exec chmod -- 755 {} +
  # set non-dotfiles to read-only
  command -p -- find -- . -path '*/.*' -prune -o -type f -exec chmod -- 644 {} +
  # make git hooks to executable
  command -p -- find -- . -path '*/.git/hooks/*' -type f -exec chmod -- 755 {} +
  command -p -- find -- . -path '*/.git/objects' -prune -o -path '*/.git/hooks' -prune -o -type f -exec chmod -- 644 {} +
  command -p -- find -- . -path '*/.git/objects/*' -type f -exec chmod -- 444 {} +
  {
    set \
      +o xtrace
  } 2>/dev/null
}

posix_character_classes() {
  set -- 'https://pubs.opengroup.org/onlinepubs/9699919799/utilities/tr.html'
  {
    command wget \
      --hsts-file=/dev/null \
      --output-document=- \
      --quiet \
      -- \
      "${1-}" ||
      command curl \
        --fail \
        --location \
        --show-error \
        --silent \
        --url "${1-}"
  } 2>/dev/null |
    command -p -- sed \
      -n \
      -e '/"tent"/ {' \
      -e '  s/.*>\([[:alpha:]]\{1,\}\).*/[:\1:]/p' \
      -e '}' |
    LC_ALL='C' command -p -- sort -u
  shift
}

posix_special_utilities_list() {
  # break colon continue dot eval exec exit export readonly return set
  # shift times trap unset
  command -p -- printf -- 'break colon continue dot eval exec exit export readonly return set shift times trap unset\n'
}
alias -- posix_builtins_list='posix_special_utilities_list'
posix_utilities_list() {
  # admin alias ar asa at awk basename batch bc bg c̸9̸9̸ [c17] cal cat cd cflow
  # chgrp chmod chown cksum cmp comm command compress cp crontab csplit
  # ctags cut cxref date dd delta df diff dirname du echo ed env ex expand
  # expr false fc fg file find fold f̸o̸r̸t̸7̸7̸ fuser gencat get getconf getopts [gettext]
  # grep hash head iconv id ipcrm ipcs jobs join kill lex link ln locale
  # localedef logger logname lp ls m4 mailx make man mesg mkdir mkfifo more [msgfmt]
  # mv newgrp [ngettext] nice nl nm nohup od paste patch pathchk pax pr printf prs ps
  # pwd q̸a̸l̸t̸e̸r̸ q̸d̸e̸l̸ q̸h̸o̸l̸d̸ q̸m̸o̸v̸e̸ q̸m̸s̸g̸ q̸r̸e̸r̸u̸n̸ q̸r̸l̸s̸ q̸s̸e̸l̸e̸c̸t̸ q̸s̸i̸g̸ q̸s̸t̸a̸t̸ q̸s̸u̸b̸
  # read [readlink] [realpath] renice rm rmdel rmdir sact sccs sed sh sleep sort split strings
  # strip stty tabs tail talk tee test time [timeout] touch tput tr true tsort tty
  # type ulimit umask unalias uname uncompress unexpand unget uniq unlink
  # uucp uudecode uuencode uustat uux val vi wait wc what who write xargs [xgettext]
  # yacc zcat
  command curl \
    --show-error \
    --silent \
    --url 'https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html' |
    # https://archive.today/2022.10.19-184853/https://cyberciti.biz/faq/?p=12818
    command -p -- sed \
      -e ':a' \
      -e 'N' \
      -e '$! b a' \
      -e 's/\n/ /g' \
      -e '# remove Utilities headers' \
      -e 's/.*<ul>//' \
      -e '# remove elements, even if successive' \
      -e 's/\( *<[^>]*>\)*\([[:alnum:]]*\)/\2 /g' \
      -e '# remove the last trailing spaces' \
      -e 's/[[:space:]]*$//' \
      -e 's/c99 /c17 /' \
      -e 's/fort77 //' \
      -e 's/getopts /getopts gettext /' \
      -e 's/more /more msgfmt /' \
      -e 's/newgrp /newgrp ngettext /' \
      -e 's/qalter //' \
      -e 's/qdel //' \
      -e 's/qhold //' \
      -e 's/qmove //' \
      -e 's/qmsg //' \
      -e 's/qrerun //' \
      -e 's/qrls //' \
      -e 's/qselect //' \
      -e 's/qsig //' \
      -e 's/qstat //' \
      -e 's/qsub //' \
      -e 's/read /read readlink realpath /' \
      -e 's/time /time timeout /' \
      -e 's/xargs /xargs xgettext /'
}

posix_variables_list() {
  # 77 “frequently exported” variables in “wide[] use[]”
  # https://gitlab.opengroup.org/the-austin-group/sus_html/blob/2af5dfdd37/html/basedefs/V1_chap08.html#L98-389
  # ARFLAGS CC CDPATH CFLAGS CHARSET COLUMNS DATEMSK DEAD EDITOR ENV EXINIT \
  # FC FCEDIT FFLAGS GET GFLAGS HISTFILE HISTORY HISTSIZE HOME IFS LANG \
  # LC_ALL LC_COLLATE LC_CTYPE LC_MESSAGES LC_MONETARY LC_NUMERIC LC_TIME \
  # LDFLAGS LEX LFLAGS LINENO LINES LISTER LOGNAME LPDEST MAIL MAILCHECK \
  # MAILER MAILPATH MAILRC MAKEFLAGS MAKESHELL MANPATH MBOX MORE MSGVERB \
  # NLSPATH NPROC OLDPWD OPTARG OPTERR OPTIND PAGER PATH PPID PRINTER \
  # PROCLANG PROJECTDIR PS1 PS2 PS3 PS4 PWD RANDOM SECONDS SHELL TERM \
  # TERMCAP TERMINFO TMPDIR TZ USER VISUAL YACC YFLAGS
  set -- 'https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html'
  {
    command wget --hsts-file=/dev/null --output-document=- --quiet -- "${1-}" ||
      command curl --fail --show-error --silent --url "${1-}"
  } 2>/dev/null |
    command -p -- sed \
      -n \
      -e '/"tent"/ {' \
      -e '  s/.*>\([[:upper:]]\{1,\}[[:upper:]_]*\).*/\1/p' \
      -e '}' |
    LC_ALL='C' command -p -- sort -u - |
    LC_ALL='C' command -p -- sort -f |
    while IFS='' read -r -- variable; do
      # escape even backslashes in double-quoted strings (OILS-ERR-12)
      command -p -- test "$(eval " command -p -- printf -- '%s\\n' \$${variable-}" 2>/dev/null)" = '' ||
        command -p -- printf -- '%s:\t%s\n' "${variable-}" "$(eval " command -p -- printf -- '%s\\n' \$${variable-}")"
    done
  shift
  #   @TODO:
  #   printf -- 'ADMIN:%-12s%s\n' "${ADMIN-}"
  #   because the longest variable names are 11 characters long
  for variable in ARFLAGS IFS MAILPATH PS1 CC LANG MAILRC PS2 CDPATH LC_ALL MAKEFLAGS PS3 CFLAGS LC_COLLATE MAKESHELL PS4 CHARSET LC_CTYPE MANPATH PWD COLUMNS LC_MESSAGES MBOX RANDOM DATEMSK LC_MONETARY MORE SECONDS DEAD LC_NUMERIC MSGVERB SHELL EDITOR LC_TIME NLSPATH TERM ENV LDFLAGS NPROC TERMCAP EXINIT LEX OLDPWD TERMINFO FC LFLAGS OPTARG TMPDIR FCEDIT LINENO OPTERR TZ FFLAGS LINES OPTIND USER GET LISTER PAGER VISUAL GFLAGS LOGNAME PATH YACC HISTFILE LPDEST PPID YFLAGS HISTORY MAIL PRINTER HISTSIZE MAILCHECK PROCLANG HOME MAILER PROJECTDIR; do
    eval " echo ${variable-}:		\$${variable-}" 2>/dev/null
  done
}

# duplicate lines only
print_duplicate_lines() {
  command -p -- test -s "${1-}" ||
    return "${?:-1}"
  LC_ALL='C' command -p -- sort "${1-}" |
    command -p -- sed \
      -e '# https://pement.org/sed/sed1line.txt' \
      -e '$! N' \
      -e 's/^\(.*\)\n\1$/\1/' \
      -e 't' \
      -e 'D' |
    LC_ALL='C' command -p -- sort -u |
    LC_ALL='C' command -p -- sort -f

  # https://github.com/gongchengra/hacker/blob/master/bash/sed_vs_awk.txt#L583
  command awk -- 'a[$0]++' "${1-}" |
    LC_ALL='C' command -p -- sort -u |
    LC_ALL='C' command -p -- sort -f
}

## iCloud
priority() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  case "${1-}" in
  a)
    set -- 'American'
    ;;
  e)
    set -- 'Euro'
    ;;
  *)
    set -- "${1:-bird}"
    ;;
  esac
  command sudo -- renice -n -20 -p "$(
    command -p -- ps -a -u "$(
      command -p -- id -u
    )" |
      command awk -vquery="${1-}" -- '$0 ~ query {print $2; exit}'
  )" ||
    return "${?:-1}"
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

pledit() {
  # based on Joe Block’s `pledit`
  # Convert a binary plist file to XML and open with `$EDITOR`
  # Copyright 2017, Joe Block <jpb@unixorn.net>
  # https://github.com/unixorn/tumult.plugin.zsh/blob/2f83fb8287/bin/pledit
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "$(LC_ALL='C' command -p -- file -- "${file-}")" in
      *'Apple binary property list'*)
        restore=1
        ;;
      *'XML 1.0 document'*)
        restore=0
        ;;
      *)
        # EX_DATAERR
        return 65
        ;;
      esac
    # convert the binary file to XML
    command plutil -convert xml1 -- "${file-}" &&
      # open with the default editor
      command "${EDITOR:-${VISUAL:-vi}}" -- "${file-}" &&
      # if the file was binary before editing, then restore it
      command -p -- test "${restore-}" -eq 1 &&
      command plutil -convert binary1 -- "${file-}"
  done
  unset restore 2>/dev/null || restore=''
}

# .plist
plist_r() {
  command -v -- plutil >/dev/null 2>&1 ||
    return 127
  set \
    -o verbose \
    -o xtrace
  case "$(command -p -- pwd -P)" in
  "${HOME%/}" | */trash)
    command -p -- printf -- 'permission error\n' >&2
    command -p -- printf -- 'do not run command \140%s\140 ' "${0##*/}" >&2
    command -p -- printf -- 'from directory \140%s/\140\n' "${PWD##*/}" >&2
    # EX_NOPERM
    return 77
    ;;
  *)
    if command -p -- test "${#}" -eq 0; then
      # https://bit.ly/apple_property_list_filename_extensions
      command find -- . \
        -path '*/Library' -prune -o \
        -path "${DOTFILES-}"'/*' -prune -o \
        -path '*/Trash' -prune -o \
        -path '*/trash' -prune -o \
        '(' \
        -name '*.plist' -o \
        -name '*.aae' -o \
        -name '*.appex' -o \
        -name '*.bbColorScheme' -o \
        -name '*.caar' -o \
        -name '*.codesnippet' -o \
        -name '*.entitlements' -o \
        -name '*.fileloc' -o \
        -name '*.glyphs' -o \
        -name '*.idekeybindings' -o \
        -name '*.inetloc' -o \
        -name '*.intentdefinition' -o \
        -name '*.itermcolors' -o \
        -name '*.loctable' -o \
        -name '*.mobileconfig' -o \
        -name '*.mom' -o \
        -name '*.plist.in' -o \
        -name '*.scriptSuite' -o \
        -name '*.strings' -o \
        -name '*.stringsdict' -o \
        -name '*.stTheme' -o \
        -name '*.tagpool' -o \
        -name '*.tagset' -o \
        -name '*.textClipping' -o \
        -name '*.tmCommand' -o \
        -name '*.tmLanguage' -o \
        -name '*.tmMacro' -o \
        -name '*.tmPreferences' -o \
        -name '*.tmSnippet' -o \
        -name '*.tmTheme' -o \
        -name '*.ttps' -o \
        -name '*.waveform' -o \
        -name '*.webarchive' -o \
        -name '*.webloc' -o \
        -name '*.xccheckout' -o \
        -name '*.xccolortheme' -o \
        -name '*.xccurrentversion' -o \
        -name '*.xcprivacy' -o \
        -name '*.xcsettings' -o \
        -name '*.xcuserstate' \
        ')' \
        -type f \
        -print \
        -exec sh -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 || ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 && command plutil -convert xml1 -o /tmp/"${1##*/}" -- "${1-}" && command -p -- sed -e '\''# replace tabs with two spaces each'\'' -e '\''s/\t/  /g'\'' -e '\''# insert each indented line by two more spaces'\'' -e '\''s/^  /    /'\'' -e '\''# indent top-level <dict> elements by two spaces'\'' -e '\''s/^\(<\/\{0,1\}dict>\)/  \1/'\'' /tmp/"${1##*/}" >"${1-}"' _ {} ';'
    else
      while command -p -- test "${#}" -gt 0; do
        command plutil -convert xml1 -o "${TMPDIR:-/tmp}"'/'"${1##*/}" -- "${1-}" &&
          command -p -- sed \
            -e '# replace tabs with two spaces each' \
            -e 's/\t/  /g' \
            -e '# insert each indented line by two more spaces' \
            -e 's/^  /    /' \
            -e '# indent top-level <dict> elements by two spaces' \
            -e 's/^\(<\/\{0,1\}dict>\)/  \1/' \
            "${TMPDIR:-/tmp}"'/'"${1##*/}" >"${1-}"
        shift 1
      done
    fi
    ;;
  esac
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

# PlistBuddy
test -x '/usr/libexec/PlistBuddy' &&
  # https://apple.stackexchange.com/a/414774
  alias -- plistbuddy='command /usr/libexec/PlistBuddy'

## PNG
to_png() {
  set \
    -o noclobber \
    -o noglob \
    -o xtrace
  for file in "${@-}"; do
    command magick \
      -background none \
      -density "${d:-2048}" \
      -quality 100 \
      -verbose \
      -- \
      "${file-}" \
      "${file%.*}"'.transparent.png' &&
      command magick \
        -background white \
        -density "${d:-2048}" \
        -quality 100 \
        -verbose \
        -- \
        "${file-}" \
        "${file%.*}"'.white.png'
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o xtrace
  } 2>/dev/null
}

# AdvPNG (AdvanceCOMP)
advpng_r() {
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "${file-}" in
      *.[Pp][Nn][Gg])
        command advpng \
          --recompress \
          --shrink-insane \
          --iter 1024 \
          -- \
          "${file-}"
        ;;
      *) ;;
      esac
  done
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

# OptiPNG
optipng_r() {
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "${file-}" in
      *.[Pp][Nn][Gg])
        command optipng \
          -fix \
          -force \
          -nb \
          -nc \
          -np \
          -nx \
          -o 7 \
          -out "${file%.*}"'-optipng.png' \
          -strip all \
          -verbose \
          -zm 1-9 \
          -- \
          "${file-}"
        ;;
      *) ;;
      esac
  done
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

# OxiPNG
oxipng_r() {
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "${file-}" in
      *.[Pp][Nn][Gg])
        command oxipng \
          --filters=0,9 \
          --opt=max \
          --out="${file%.*}"'-oxipng.png' \
          --strip=all \
          --verbose \
          --verbose \
          --zopfli \
          -- \
          "${file-}"
        ;;
      *) ;;
      esac
  done
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

# pngcrush
pngcrush_r() {
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "${file-}" in
      *-pngcrush.png)
        shift
        ;;
      *.[Pp][Nn][Gg])
        command pngcrush \
          -brute \
          -fix \
          -force \
          -reduce \
          -v \
          -- \
          "${file-}" \
          "${file%.*}"'-pngcrush.png'
        ;;
      *) ;;
      esac
  done
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

pngout_r() {
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command pngout \
        -b0 \
        -d0 \
        -f4 \
        -k0 \
        -s0 \
        -v \
        -y \
        "${file-}" \
        "${file%.*}"'-pngout.png'
  done
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

# $?
question_mark() {
  # `??`: return a specific error in the very unlikely even that `$?` is not set
  command -p -- printf -- '%d\n' "${??}"
}
alias -- '?'='question_mark'

# QuickLook
ql() {
  command -v -- qlmanage >/dev/null 2>&1 ||
    return 127
  case "${1-}" in
  -r)
    command find -- . \
      -path './*/*' -prune -o \
      -path './*.*.*' -prune -o \
      -path './* *' -prune -o \
      '(' \
      -path './[Rr][Ee][Aa][Dd]*[Mm][Ee]*' -o \
      -path './[Cc][Ll][Ii][Cc][Kk]*[Mm][Ee]*' -o \
      -path './[Kk][Ee][Ee][Pp]*[Mm][Ee]*' \
      ')' \
      -type f \
      -exec sh -c 'case "${1-}" in
*.asciidoc | *.adoc | *.asc)
  command bat \
    --color=auto \
    --decorations=never \
    --language=asciidoc \
    --paging=never \
    -- \
    "${1-}" 2>/dev/null ||
    command -p -- cat \
    -- \
    "${1-}" 2>/dev/null
  ;;
*)
  command qlmanage -p -- "${1-}" >/dev/null 2>&1 ||
    command bat \
      --color=auto \
      --decorations=never \
      --paging=never \
      -- \
      "${1-}" 2>/dev/null ||
    command -p -- cat \
    -- \
    "${1-}" 2>/dev/null
  ;;
esac' _ {} +
    ;;
  *)
    while command -p -- test "${#}" -ne 0; do
      command qlmanage -p -- "${1-}" >/dev/null 2>&1 &&
        shift
    done
    ;;
  esac
}
alias -- qlr='ql -r'

RANDOM() {
  # https://shellcheck.net/wiki/SC3028/1f83d59#correct-code
  command -p -- awk -vmax="$(
    command -p -- getconf -- SHRT_MAX
  )" -- 'BEGIN {
  srand()
  printf "%d\n", int(rand() * max)
}'
}

random_r() {
  set \
    -o noclobber \
    -o noglob \
    -o nounset \
    -o verbose \
    -o xtrace
  command -p -- printf -- '%s:powershell:pwsh\n' "${SHELLS-}" |
    command -p -- sed \
      -e '# posh lacks support' \
      -e 's/^posh://' \
      -e 's/:posh$//' \
      -e 's/:posh://' |
    command -p -- sed -e 's/:/\n/g' | while IFS='' read -r -- shell; do
    { eval " $(command -p -- printf -- 'command %s -c \047\042%s\140t\044(Get-Random)\042\047\n' "${shell-}" "${shell-}")" ||
      eval " $(command -p -- printf -- 'command %s -c \047command -p -- printf -- \047\134\047\047%s\134t\045s\134n\047\134\047\047 "\044{RANDOM}"\047\n' "${shell-}" "${shell-}")"; } |
      command -p -- sed \
        -n \
        -e '/[[:space:]][[:digit:]]/p' \
        -e 'q' |
      LC_ALL='C' command -p -- sort
  done 2>/dev/null
  command -p -- awk -vmax="$(
    command -p -- getconf -- SHRT_MAX
  )" -- 'BEGIN {
  srand()
  printf "awk\t%d\n", int(rand() * max)
}'
  {
    set \
      +o noclobber \
      +o noglob \
      +o nounset \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

random_string() {
  # ensure `/dev/random` is a character special
  command -p -- test -c /dev/random ||
    # EX_OSFILE
    return 72
  # print all non-space ASCII characters from standard input
  LC_ALL='C' command -p -- tr -c -d '\41-\176' </dev/random |
    # default to 10 characters
    command -p -- dd bs=1 count="${1:-10}" 2>/dev/null &&
    command -p -- printf -- '\n'

  # https://github.com/hectorm/hblock/commit/7b9518ad14
  command -p -- true &
  command awk -vN="${!:--1}" -- '
BEGIN {
  srand()
  printf("%08x%06x", rand() * 2^31-1,N)
}'

  command -p -- true &
  command awk -vINT_MAX="$(command -p -- printf -- '%d\n' "${INT_MAX:-$(
    exponent=31
    result=1
    while command -p -- test "${exponent-}" -gt 0; do
      result="$((result * 2))"
      exponent="$((exponent - 1))"
    done
    command -p -- printf -- '%d\n' "$((result - 1))"
    unset exponent 2>/dev/null || exponent=''
    unset result 2>/dev/null || result=''
  )}" 2>/dev/null)" -vN="${!}" -- 'BEGIN{srand(); printf("%08x%06x\n", rand() * INT_MAX, N)}'
}

rbenv_update_r() {
  set \
    -o verbose \
    -o xtrace
  # for file in "$(command rbenv prefix)"/bin/**/*; do
  #   command gem install --verbose "${file##*/}"
  # done
  command find -- "$(command rbenv prefix)"'/bin' \
    -path "$(command rbenv prefix)"'/bin/*/*' -prune -o \
    -type f \
    -exec sh -x -c 'for file in "${@-}"; do
  command -p -- test -x "${file-}" &&
    command gem install --verbose "${file##*/}"
done
' {} +
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}
alias -- gem_update_r='rbenv_update_r'

## Rectangle
# set ⌘⌥F to maximize the focused window
alias -- rectangle_shortcut='command defaults write com.knollsoft.Rectangle maximize -dict-add keyCode -float 3 modifierFlags -float 1572864 2>/dev/null'

remove_trailing_slash() {
  # POSIX-compliant remove trailing slashes
  # https://stackoverflow.com/a/5471032
  while command -p -- test "${#}" -gt 0; do
    while command -p -- test "${1-}" != "${1%/}" && command -p -- test "${1-}" != '/'; do
      set -- "${1%/}"
    done
    command -p -- printf -- '%s\n' "${1-}"
    shift
  done
}

## rename
rename_install() {
  set -- "${DOTFILES-}"'/bin/rename' 'https://github.com/ap/rename/raw/HEAD/rename' &&
    command -p -- mkdir -p -- "${1##*/}" &&
    {
      command wget --hsts-file=/dev/null --quiet --output-document="${1-}" -- "${2-}" ||
        command curl --fail --location --show-error --silent --output --url "${2-}" -- "${1-}"
    } 2>/dev/null &&
    command -p -- chmod -- 755 "${1-}"
}
# brew install rename
# https://github.com/ap/rename
rename_sanitize() {
  # usage rename_sanitize [ -f ] [ -l ] [ location ]
  # -f: force overwrite
  # -l: rename using lowercase
  # -n: dry run
  # location: directory with files to rename (default current directory and below)

  while getopts filn opt; do
    case "${opt-}" in
    f)
      f='--force'
      ;;
    i)
      set \
        -o verbose \
        -o xtrace
      command find -- . \
        -depth \
        ! -path '*/.git/*' \
        ! -path '*/.well-known/*' \
        ! -path '*/Library/*' \
        ! -path '*/node_modules/*' \
        ! -path '*/t/*' \
        ! -path '*/Test*' \
        ! -path '*/test*' \
        ! -path '*/tst*' \
        ! -path '*copilot*' \
        ! -path '*dummy*' \
        ! -path '*vscode*' \
        ! -name '*.icloud' \
        ! -name '.DS_Store' \
        -name '.*~imageoptim.*' \
        -type f \
        -print 2>/dev/null | while IFS='' read -r -- filename; do
        command -p -- mv -f -- "${filename-}" "${filename%/*}"/"$(
          command -p -- printf -- '%s' "${filename##*/}" |
            command -p -- sed \
              -e '# does ↓ this with ##*/ above work if the file is in a subdirectory?' \
              -e 's/^\.//' \
              -e 's/~imageoptim//'
        )"
      done
      unset filename 2>/dev/null || filename=''
      {
        set \
          +o verbose \
          +o xtrace
      } 2>/dev/null
      return 0
      ;;
    l)
      l='--lower-case'
      ;;
    n)
      n='--dry-run'
      ;;
    *)
      unset f 2>/dev/null || f=''
      unset l 2>/dev/null || l=''
      unset n 2>/dev/null || n=''
      ;;
    esac
  done
  shift "$((OPTIND - 1))"

  command find -- . \
    -depth \
    ! -path '*/.git/*' \
    ! -path '*/.well-known/*' \
    ! -path '*/Library/*' \
    ! -path '*/node_modules/*' \
    ! -path '*/t/*' \
    ! -path '*/Test*' \
    ! -path '*/test*' \
    ! -path '*/tst*' \
    ! -path '*copilot*' \
    ! -path '*dummy*' \
    ! -path '*vscode*' \
    ! -name '*.icloud' \
    ! -name '.DS_Store' \
    -exec rename \
    --make-dirs \
    --sanitize \
    --subst '_at_' '_' \
    --subst 'libgen.li' '' \
    --subst-all '+' '_' \
    --subst-all '__' '_' \
    --subst-all '_.' '.' \
    --subst-all '-.' '.' \
    --transcode=ascii \
    --urlesc \
    --verbose \
    "${f-}" \
    "${l-}" \
    "${n-}" \
    -- \
    {} +
}
alias -- \
  deimageoptim='rename_sanitize -i' \
  de_io='deimageoptim' \
  deio='de_io'
rename_r() {
  case "${#}" in
  2)
    command find -- . \
      -depth \
      ! -path '*/.git/*' \
      ! -path '*/.well-known/*' \
      ! -path '*/Library/*' \
      ! -path '*/node_modules/*' \
      ! -path '*/t/*' \
      ! -path '*/Test*' \
      ! -path '*/test*' \
      ! -path '*/tst*' \
      ! -path '*copilot*' \
      ! -path '*dummy*' \
      ! -path '*vscode*' \
      -exec rename \
      --verbose \
      --make-dirs \
      --subst-all "${1-}" "${2-}" \
      -- \
      {} +
    ;;
  0)
    command find -- . \
      -depth \
      ! -path '*/.git/*' \
      ! -path '*/.well-known/*' \
      ! -path '*/Library/*' \
      ! -path '*/node_modules/*' \
      ! -path '*/t/*' \
      ! -path '*/Test*' \
      ! -path '*/test*' \
      ! -path '*/tst*' \
      ! -path '*copilot*' \
      ! -path '*dummy*' \
      ! -path '*vscode*' \
      -type f \
      -exec rename \
      --force \
      --make-dirs \
      --sanitize \
      --subst '_at_' '_' \
      --subst-all '+' '_' \
      --subst-all '__' '_' \
      --transcode=ascii \
      --urlesc \
      --verbose \
      -- \
      {} +
    ;;
  *)
    return 1
    ;;
  esac
}

rename_with_dimensions() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
      command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&

      # if extracting the image dimensions works...
      command exiftool -ImageSize -short3 -- "${file-}" >/dev/null 2>&1 &&

      # then rename the file
      command -p -- mv -i -- \
        "${file-}" \
        "${file%.*}"'.'"$(command exiftool -ImageSize -short3 -- "${file-}")"'.'"${file##*.}"
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

# remove
rm() {
  command -p -- test "${#}" -eq 0 &&
    # EX_USAGE after `command -p -- rm --`’s response
    return 64
  (
    PS4=' '
    set \
      -o verbose \
      -o xtrace
    if command -p -- test -d "${HOME%/}"'/.Trash'; then
      target="${HOME%/}"'/.Trash'
    elif command -p -- mkdir -p -- "${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash' 2>/dev/null; then
      target="${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash'
    elif command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/.Trash' 2>/dev/null; then
      target="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/.Trash'
    else
      # EX_CANTCREAT
      return 73
    fi
    now="$(command -p -- date -- '+%Y%m%d%H%M%S')"
    case "${1-}" in
    --)
      shift
      ;;
    -o | --others)
      # prevent `rm --others file`
      command -p -- test "${2-}" = '' ||
        # EX_USAGE
        return 64
      command git ls-files -z --others |
        command -p -- tr -s -- '\0' '\n' |
        while IFS='' read -r -- file; do
          command -p -- mkdir -p -- "${target%/}"'/'"${file%/*}"'_'"${now-}"
          command -p -- mv -f -- "${file-}" "${target%/}"'/'"${file%/*}"'_'"${now-}"'/'"${file##*/}" 2>/dev/null ||
            command trash -- "${file-}" 2>/dev/null ||
            command -p -- rm -i -v -- "${file-}"
        done
      shift
      ;;
    *)
      for file in "${@-}"; do
        command trash -- "${file-}" 2>/dev/null || {
          command -p -- mkdir -p -- "${target%/}"'/'"${file%/*}"'_'"${now-}"
          command -p -- mv -f -- "${file-}" "${target%/}"'/'"${file%/*}"'_'"${now-}"'/'"${file##*/}"
        }
        command git rm -r --force -- "${file-}" 2>/dev/null
      done
      ;;
    esac
  )
}
alias -- \
  rmo='rm --others' \
  rmf='command -p -- rm -f -r'

rsync_r() {
  command -v -- rsync >/dev/null 2>&1 ||
    return 127
  case "${1-}" in
  c | k | o)
    target='kevoc7@oconnor.nyc:/home/kevoc7/.local/share/Trash/'"${2##*/}"
    ;;
  f)
    target='llarson@freeshell.de:/home/l/llarson/.local/share/Trash/'"${2##*/}"
    ;;
  l)
    target='lucaslarson@lucaslarson.net:/home/lucaslarson/.local/share/Trash/'"${2##*/}"
    ;;
  s)
    target='ll@tty.sdf.org:/sdf/arpa/gm/l/ll/.local/share/Trash/'"${2##*/}"
    ;;
  *)
    # EX_USAGE
    return 64
    ;;
  esac
  shift
  while command -p -- test "${#}" -gt 0; do
    command rsync --archive --compress --partial --progress --verbose -- "${1-}" "${target-}"
    shift
  done
  unset target 2>/dev/null || target=''
}

## rubocop
rubocop_r() {
  command -v -- find_ruby_files >/dev/null 2>&1 &&
    command -v -- rubocop >/dev/null 2>&1 ||
    return 127
  find_ruby_files | while IFS='' read -r -- file; do
    command git ls-files --error-unmatch -- "${file-}" >/dev/null 2>&1 ||
      ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
      command rubocop \
        --autocorrect-all \
        --extra-details \
        --format github \
        --format progress \
        -- \
        "${file-}"
  done
}

## rustfmt
rustfmt_r() {
  set \
    -o verbose \
    -o xtrace
  command find -- . \
    -name '*.rs' \
    -type f \
    -exec sh -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command rustfmt --emit files --verbose -- "${1-}"
' _ {} ';'
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

sc() {
  for file in "${@:-${DOTFILES}/custom/aliases.sh}"; do
    case "${file-}" in
    --) shift && continue ;;
    -h* | --help)
      command -p -- printf -- 'Usage: %s [--] [file ...]\n' "${0##*/}" >&2
      # EX_OK
      return 0
      ;;
    *)
      command test -f "${file-}" ||
        {
          command -p -- printf -- '%s: %s: No such file\n' "${0##*/}" "${file-}" >&2
          # EX_NOINPUT
          return 66
        }
      command -p -- printf -- '%s\n' "${SHELLS-}" |
        command -p -- sed \
          -e 's/:/\n/g' |
        while IFS='' read -r -- shell; do
          command -v -- "${shell-}" >/dev/null 2>&1 &&
            {
              PS4=' '
              set -o xtrace
              "${shell-}" -C -e -n -u -x -o noglob -- "${file-}"
              { set +o xtrace; } 2>/dev/null
            } 2>&1 |
            command -p -- sed \
              -e 's/^/  /' \
              -e 's/-- .*\//-- /'
        done
      sca "${file-}"
      ;;
    esac
  done
}

sca() {
  while getopts s: opt; do
    case "${opt-}" in
    s)
      shell="${OPTARG:-sh}"
      ;;
    *)
      command -p -- printf -- 'usage: %s [-s [bash|dash|ksh|sh]] [--] [file]\n' "${0##*/}" >&2
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
      command -p -- printf -- '%s...\n' "${file##*/}"
      for test in \
        'shellcheck --color=always --enable=all --exclude=SC1071,SC1091,SC2123,SC2312,SC3040 --external-sources --format=gcc --source-path=/dev/null --shell='"${shell:-sh}" \
        'zsh            -C -e    -n -u    -o pipefail -o noglob' \
        'ash            -C -e -f -n -u -x -o pipefail' \
        'bash           -C -e -f -n -u -x -o pipefail -o functrace' \
        'dash           -C -e -f -n -u -x' \
        'dtksh       -b -C -e -f -n -u -x -o pipefail -o posix -o functrace' \
        'fizsh          -C -e    -n -u    -o pipefail -o noglob -o posix_aliases -o posix_arg_zero -o posix_builtins -o posix_cd -o posix_identifiers -o posix_jobs -o posix_strings -o posix_traps' \
        'ksh         -b -C -e -f -n -u -x -o pipefail' \
        'ksh88       -b -C -e -f -n -u -x -o pipefail -o posix -o functrace' \
        'ksh93       -b -C -e -f -n -u -x -o pipefail' \
        'ksh2020     -b -C -e -f -n -u -x -o pipefail' \
        'mksh        -b -C -e -f -n -u -x -o pipefail -o posix' \
        'mksh-static -b -C -e -f -n -u -x -o pipefail -o posix' \
        'nksh93      -b -C -e -f -n -u -x -o pipefail -o posix -o functrace' \
        'oksh        -b -C -e -f -n -u -x -o pipefail -o posix' \
        'osh            -C -e -f -n -u -x -o pipefail -o posix --ast-format none' \
        'pdksh       -b -C -e -f -n -u -x -o pipefail -o posix' \
        'pfksh       -b -C -e -f -n -u -x -o pipefail -o posix' \
        'posh           -C -e -f -n -u -x' \
        'psh            -C -e -f -n -u -x -o pipefail' \
        'rbash          -C -e -f -n -u -x -o pipefail -o functrace' \
        'rksh        -b -C -e -f -n -u -x -o pipefail' \
        'rksh93      -b -C -e -f -n -u -x -o pipefail' \
        'rksh2020    -b -C -e -f -n -u -x -o pipefail' \
        'scsh           -C -e -f -n -u -x -o pipefail' \
        'yash           -C -e -f -n -u -x -o pipefail -o posixly-correct' \
        '# https://oilshell.org/release/latest/doc/ref/chap-option.html#Debugging:~:text=From%20bash%3A-,extdebug,-Interactive' \
        '# ysh          -C -e -f -n -u -x -o pipefail -o command_sub_errexit -o extdebug -o inherit_errexit -o noclobber -o parse_at -o parse_brace -o parse_equals -o parse_paren -o parse_proc -o parse_sh_arith -o parse_triple_quote -o parse_ysh_string -o process_sub_fail -o sigpipe_status_ok -o simple_echo -o simple_eval_builtin -o simple_test_builtin -o simple_word_eval -o strict_argv -o strict_array -o strict_control_flow +o strict_errexit -o strict_glob -o strict_nameref -o strict_tilde -o strict_word_eval -o verbose -o verbose_errexit -o xtrace_details -o xtrace_rich --ast-format none' \
        'ysh            -C -e -f -n -u -x -o pipefail -o command_sub_errexit             -o inherit_errexit -o noclobber -o parse_at -o parse_brace -o parse_equals -o parse_paren -o parse_proc -o parse_sh_arith -o parse_triple_quote -o parse_ysh_string -o process_sub_fail -o sigpipe_status_ok -o simple_echo -o simple_eval_builtin -o simple_test_builtin -o simple_word_eval -o strict_argv -o strict_array -o strict_control_flow +o strict_errexit -o strict_glob -o strict_nameref -o strict_tilde -o strict_word_eval -o verbose -o verbose_errexit -o xtrace_details -o xtrace_rich --ast-format none' \
        '# sh        -C    -e -f -n -u -x -o pipefail' \
        'sh          -C    -e -f -n -u -x' \
        'zsh         -C    -e    -n -u    -o pipefail -o noglob -o posix_aliases -o posix_arg_zero -o posix_builtins -o posix_cd -o posix_identifiers -o posix_jobs -o posix_strings -o posix_traps'; do
        if command -v -- "${test%% *}" >/dev/null 2>&1; then
          { {
            eval " command ${test-} -- \"${file-}\"" 2>&1 &&
              command -p -- printf -- '  passed %s\n' "${test%% *}"
          } ||
            command -p -- printf -- '    %s failed %s\n' "${file##*/}" "${test%% *}"; } |
            # paths in descending specificity:
            command -p -- sed \
              -e '/^AST not printed\./ d' \
              -e 's|'"${custom-}"'|$\custom|' \
              -e 's|'"${DOTFILES-}"'|$\DOTFILES|' \
              -e 's|'"${XDG_CONFIG_HOME-}"'|$\XDG_CONFIG_HOME|' \
              -e 's|'"${HOME%/}"'|~|'
        fi
      done
      ;;
    esac
  done
  unset opt 2>/dev/null || opt=''
}

scour_r() {
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
      command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      case "${file-}" in
      *.[Ss][Vv][Gg])
        command scour \
          --create-groups \
          --disable-embed-rasters \
          --enable-comment-stripping \
          --enable-id-stripping \
          --enable-viewboxing \
          --indent=none \
          --nindent=0 \
          --no-line-breaks \
          --protect-ids-noninkscape \
          --remove-descriptions \
          --remove-descriptive-elements \
          --remove-metadata \
          --remove-titles \
          --set-precision="$(command -p -- getconf -- CHAR_MAX)" \
          --strip-xml-prolog \
          --strip-xml-space \
          --verbose \
          -i "${file-}" \
          -o "${file%.*}"'-scour.svg'
        ;;
      *)
        shift
        ;;
      esac
  done
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

## SDKPATH
# if this from zshrc_commented doesn’t work, then try: https://stackoverflow.com/a/60002595
# DEFER? This is me attempting to defer `SDKPATH` until after the first load of `~/.zshrc`. ¯\_(ツ)_/¯
# I feel like I’ve done this accidentally before (was it Python) and it worked, but I can’t remember
if command -v -- xcrun >/dev/null 2>&1; then
  SDKPATH="$(command xcrun --show-sdk-path)" &&
    export SDKPATH &&
    command -p -- test -d "${SDKPATH%/}"'/usr/share/man' &&
    MANPATH="${MANPATH:+${MANPATH-}:}${SDKPATH%/}"'/usr/share/man'
fi

sed_help() {
  # @mislav and @arp242
  # # https://github.com/arp242/dotfiles/blob/9ade674954/local/script/tz
  command -p -- sed \
    -e '1,2 d' \
    -e '/^[^#]/ q' \
    -e 's/^# //' \
    -e 's/^#//' \
    "${@-}"
}

sed_pretty() {
  command -p -- printf -- '\n' |
    command gsed \
      --debug \
      --posix \
      --sandbox "$(
        command -p -- printf -- '%s\n' "${@-}" |
          command -p -- sed \
            -e '# duplicate incoming backslashes for specially escaped characters' \
            -e '# https://web.archive.org/web/0id_/gnu.org/s/bash/manual/html_node/ANSI_002dC-Quoting' \
            -e 's/\\\([abfnrtv]\)/\\\\\1/g' 2>&1
      )" |
    command -p -- sed \
      -e '# replace double backslashes with singles' \
      -e 's/\\\\/\\/g' \
      -e '# replace single quotes with escaped single quotes' \
      -e "$(command -p -- printf -- 's/\047/\047\\\\\047\047/g')" \
      -e '# remove INPUT: and everything after it' \
      -e "$(command -p -- printf -- '/INPUT:/,\044 {\nd\n}\n')" \
      -e '# surround each line with single quotes and prepend -e' \
      -e 's/\([^[:space:]].*\)$/-e '\''\1'\'' \\/' \
      -e '# add shebang and call sed' \
      -e '1 s/.*/#!\/usr\/bin\/env sh\ncommand -p -- sed \\/' |
    command shfmt \
      --indent 2 \
      --language-dialect bash \
      --simplify \
      -- \
      - | {
    command bat \
      --color=auto \
      --decorations=never \
      --language=sh \
      --paging=never \
      -- \
      - 2>/dev/null ||
      command -p -- cat \
        -- \
        -
  }
  command -p -- printf -- '%s\n' "${@-}" |
    command gsed \
      --debug \
      --posix \
      --sandbox \
      -e '# duplicate incoming backslashes for specially escaped characters' \
      -e '# https://web.archive.org/web/0id_/gnu.org/s/bash/manual/html_node/ANSI_002dC-Quoting' \
      -e 's/\\\([abfnrtv]\)/\\\\\1/g' \
      2>&1 |
    command -p -- sed \
      -e '# replace double backslashes with singles' \
      -e 's/\\\\/\\/g' \
      -e '# replace single quotes with escaped single quotes' \
      -e "$(command -p -- printf -- 's/\047/\047\\\\\047\047/g')" \
      -e '# remove INPUT: and everything after it' \
      -e "$(command -p -- printf -- '/INPUT:/,\044 {\nd\n}\n')" \
      -e '# surround each line with single quotes and prepend -e' \
      -e 's/\([^[:space:]].*\)$/-e '\''\1'\'' \\/' \
      -e '# add shebang and call sed' \
      -e '1 s/.*/#!\/usr\/bin\/env sh\ncommand -p -- sed \\/' |
    command shfmt \
      --indent 2 \
      --language-dialect bash \
      --simplify \
      -- \
      - | {
    command bat \
      --color=auto \
      --decorations=never \
      --language=sh \
      --paging=never \
      -- \
      - 2>/dev/null ||
      command -p -- cat \
        -- \
        -
  }
}
alias -- sed_debug='sed_pretty'

shellcheck_d() {
  set \
    -o noglob \
    -o verbose \
    -o xtrace
  while command -p -- test "${#}" -gt 0; do
    command -p -- test -s "${1-}" &&
      command -p -- test ! -L "${1-}" &&
      command -p -- rm -f -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/'"${1##*/}" &&
      command -p -- cp -f -p -- "${1-}" "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/'"${1##*/}" &&
      command -p -- sed \
        -e '/\#[[:blank:]][[:blank:]]*shellcheck[[:blank:]][[:blank:]]*disable/ d' \
        -e 's/[[:blank:]]*\#[[:blank:]][[:blank:]]*shellcheck[[:blank:]][[:blank:]]*shell=\(.*\)sh/#!\/usr\/bin\/env \1sh/' \
        "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/'"${1##*/}" \
        >"${1-}"
    shift
  done
  {
    set \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

shellcheck_markdown() {
  # test shell syntax of Markdown code snippets
  # https://github.com/dylanaraps/pure-sh-bible/commit/9d54e96011

  # Markdown filename extensions
  # https://github.com/github/linguist/blob/7503f7588c/lib/linguist/languages.yml#L3707-L3718

  # run shellcheck on the extracted code blocks
  # SC1071: allow conforming shells besides sh, bash, ksh, dash
  # SC1090: allow linking to a dynamic location
  # SC1091: allow linking to, but not following, linked scripts
  # SC2123: allow `$PATH` modification
  # SC2312: allow masking return values
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
    -name '*.md' -o \
    -name '*.livemd' -o \
    -name '*.markdn' -o \
    -name '*.markdown' -o \
    -name '*.mdown' -o \
    -name '*.mdwn' -o \
    -name '*.mdx' -o \
    -name '*.mkd' -o \
    -name '*.mkdn' -o \
    -name '*.mkdown' -o \
    -name '*.ronn' -o \
    -name '*.scd' -o \
    -name '*.workbook' -o \
    -name 'contents.lr' \
    ')' \
    -type f \
    -exec sh -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 || ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 && while IFS='\'''\'' read -r -- line; do command -p -- test "${code-}" = '\''1'\'' && command -p -- test "${line-}" != '\''```'\'' && command -p -- printf -- '\''%s\n'\'' "${line-}"; case "${line-}" in '\''```sh'\'' | '\''```bash'\'' | '\''```shell'\'' | '\''```zsh'\'' ) code=1 ;; '\''```'\'') code='\'''\'' ;; *) ;; esac; done <"${1-}"' _ {} ';' |
    command shellcheck \
      --check-sourced \
      --enable=all \
      --exclude='SC1071,SC1090,SC1091,SC2123,SC2312' \
      --norc \
      --severity=style \
      --shell=sh \
      --source-path=/dev/null \
      -- \
      - ||
    return "${?:-1}"
}

shellharden_r() {
  set \
    -o noglob \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command git ls-files --error-unmatch -- "${file-}" >/dev/null 2>&1 &&
      command shellharden --transform -- "${file-}" >"${TMPDIR:-/tmp}"'/'"${file##*/}" &&
      command -p -- sed \
        -e 's/\([[:space:]]*\)\((*\)"\(\\\)"/\1\2'\''\3'\''/g' \
        -e '# replace two double quotes with two single quotes' \
        -e "$(command -p -- printf -- 's/ \042\042/ \047\047/g')" \
        "${TMPDIR:-/tmp}"'/'"${file##*/}" >"${file-}"
  done
  {
    set \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

# create the function that will restore options
restore_shell_options() {

  # save options
  {
    set_o="$(set +o)" &&
      export set_o &&
      export set_options_long="${set_o-}" &&
      set_hyphen="${--}" &&
      export set_hyphen &&
      export set_options_short="${set_hyphen-}"
  } ||
    return "${?:-1}"

  # restore options
  command -p -- test "${set_o-}" != '' &&
    command printf -- '%s\n' "${set_o-}" | command "${SHELL-}" -C -e -n -u -x -o noglob - 2>/dev/null &&
    { eval " ${set_o-}" >/dev/null 2>&1 || command true; }
  unset set_o 2>/dev/null || set_o=''

  command -p -- test "${set_hyphen-}" != '' &&
    command printf -- '%s' "${set_hyphen-}" |
    command sed -e 's/\(.\)/\1\n/g' | while IFS='' read -r -- option; do
      { eval " set -${option-}" >/dev/null 2>&1 || command true; }
    done

  unset set_hyphen 2>/dev/null || set_hyphen=''
  unset option 2>/dev/null || option=''
}
alias -- shell_options_restore='restore_shell_options'

shf() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command shfmt --indent 2 --language-dialect bash --simplify --write -- "${file-}"
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

shfmt_r() {
  set \
    -o xtrace
  find_shell_scripts |
    while IFS='' read -r -- file; do
      command git ls-files --error-unmatch -- "${file-}" >/dev/null 2>&1 &&
        command shfmt --indent "${@:-2}" --language-dialect bash --simplify --write -- "${file-}" &&
        command -p -- test -s "${file-}" &&
        command -p -- test ! -L "${file-}" &&
        command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp' &&
        command -p -- cp -f -p -- "${file-}" "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" &&
        # prevent `shfmt` from breaking Zsh (($+foo)) constructions
        command -p -- sed \
          -e '# undo shfmt damage to Zshism' \
          -e '# TO DELETE superseded by next line s/(([[:space:]]*\$[[:space:]]*+[[:space:]]*\([^)]*\)))/(($+\1))/g' \
          -e 's/((\$ + \([^)]*\)/(( $+\1 /g' \
          -e '# replace uncommented eval "foo with eval " foo' \
          -e 's/\(^[^#]*eval "\)\([^[:space:]]\)/\1 \2/g' \
          -e '# replace uncommented, non-awk "printf foo" with "printf -- foo"' \
          -e '# TODO: skip fucking with gfind -printf' \
          -e '/awk/! s/\(^[^#]*printf \)\('\''\)/\1-- \2/g' \
          -e '# replace uncommented [ foo ] and [[ foo ]] with test foo' \
          -e 's/^\([^#\[]*\)\[\{1,2\}\( [^]]*\) \]\{1,2\}/\1test\2/g' \
          -e '# silence ksh family ((math+1)) warnings, but hide dollar-sign-then-open-parenthesis from shellcheck' \
          -e 's/^\([^#]*=\)\($[(](.*))\)$/\1"\2"/g' \
          -e '# replace 1>&2 with >&2' \
          -e 's/ 1\(>&2\)/ \1/g' \
          -e '# replace uncommented test -n "" with test != ""; \3 is null to hide the ＄{ from shellcheck' \
          -e 's/^\([^#]*\)\(test \)-n \("\$\(\){[^}]*-*}"\)/\1\2\3 != '\''\4'\''/g' \
          -e '# replace uncommented test -z "" with test = ""; \3 is null but hides the ＄{ from shellcheck' \
          -e 's/^\([^#]*\)\(test \)-z \("\$\(\){[^}]*-*}"\)/\1\2\3 = '\''\4'\''/g' \
          -e '# replace cd foo with cd -- foo unless cd is to the right of a single quote or is commented' \
          -e 's/^\([^#'\'']*cd \)\([^-][^-] *\)/\1-- \2/g' \
          -e '# replace all strings like ＄＄ with "＄{＄:--1}"' \
          -e 's/ "\{0,1\}\(\$\){\{0,1\}\(\$\):\{0,1\}-\{0,2\}[[:digit:]]*}\{0,1\}"\{0,1\}/ "\1{\2:--1}"/g' \
          -e '# replace all strings like ＄? with "＄{＄:-1}" ' \
          -e 's/ "\{0,1\}\(\$\){\{0,1\}\(?\):\{0,1\}-\{0,1\}[[:digit:]]\{0,3\}}\{0,1\}"\{0,1\}/ "\1{\2:-1}"/g' \
          -e '# add two single quotes to uncommented trailing equals signs at EOL' \
          -e 's/^\([^#]*=\)$/\1'\'''\''/' \
          -e '# add two single quotes to uncommented variable-assigning equals signs followed by non-EOL' \
          -e 's/^\([^#]* \{0,1\}\)\([[:alpha:]_]\{1,\}[[:alnum:]_]*=\) /\1\2'\'''\'' /g' \
          -e '# replace non-awk, uncommented, double equals signs for test or for [[ or for [, with singles' \
          -e '# DELETE ME /awk/! s/^\([^#]* =\)=/\1/' \
          -e '/awk/! s/^\([^#] *\)\{0,1\}\(test [^=[:space:]]* =\)\{0,1\}\(\[\[ [^=[:space:]]* =\)\{0,1\}\(\[ [^=[:space:]]* =\)\{0,1\}= /\1\2\3\4 /g' \
          -e '# add end-of-options parameter to read' \
          -e 's/\(read -r\)\([[:space:]]\{1,\}[^-][^-][^[:space:]].*\)/\1 --\2/g' \
          -e '#' \
          -e '##' \
          -e '# TODO consider replacing "＄{@-}" with test "＄{#}" -gt 0 ﹠﹠ "＄{@-}"' \
          -e '# https://github.com/jtmoon79/dotfiles/blob/058b607e81/install.sh#L22-L23' \
          -e '##' \
          -e '# TODO consider allowing for Zsh "＄{＄{..."' \
          -e '##' \
          -e '# TODO consider basename and dirname replacements using parameter expansion' \
          -e '##' \
          "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" >"${file-}"
    done
  {
    set \
      +o xtrace
  } 2>/dev/null
}
shfmt_r_() {
  set \
    -o xtrace
  for file in "${@-}"; do
    command shfmt --indent 2 --language-dialect bash --simplify --write -- "${file-}" &&
      command -p -- test -s "${file-}" &&
      # prevent overwriting symlinks and turning them into regular files
      command -p -- test ! -L "${file-}" &&
      command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp' &&
      command -p -- cp -f -p -- "${file-}" "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" &&
      command awk -- 'match($0,/((\$ \+ .*]))/) { tgt=substr($0,RSTART,RLENGTH); gsub(/ /,"",tgt); $0=substr($0,1,RSTART-1) tgt substr($0,RSTART+RLENGTH) } 1; {gsub(/\(\($\+commands\[(.+)\]\)\)/, "\\1")}' "${file-}" >"${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" &&
      command sed \
        -e 's/\$\([a-zA-Z1-9_][a-zA-Z0-9_]*\(\[[^]]\{1,\}\]\)\{0,1\}\)/\${\1}/g' \
        -e 's/(([[:space:]]*\$[[:space:]]*+[[:space:]]*\([^)]*\)))/(($+\1))/g' \
        -e 's/\[\([^[:space:]]*\)[[:space:]]*\([^[:space:]]*\)[[:space:]]*\([^[:space:]]*\)\]/\[\1\2\3\]/g' \
        "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" >"${file-}"
  done
  {
    set \
      +o xtrace
  } 2>/dev/null
}
shfmt_r_r_() {
  set \
    -o xtrace
  for file in "${@-}"; do
    command shfmt --indent 2 --language-dialect bash --simplify --write -- "${file-}" &&
      command -p -- test -s "${file-}" &&
      # prevent overwriting symlinks and turning them into regular files
      command -p -- test ! -L "${file-}" &&
      command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp' &&
      command -p -- cp -f -p -- "${file-}" "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" &&
      command sed \
        -e 's/^\([^#]*\)\$\([a-zA-Z1-9_][a-zA-Z0-9_]*\(\[[^]]\{1,\}\]\)\{0,1\}\)/\1\${\2}/g' \
        -e 's/^\([^#]*\)\(([[:space:]]*\$[[:space:]]*+[[:space:]]*\([^)]*\))\)/\1(($+\3))/g' \
        -e 's/^\([^#]*\)\[\([^[:space:]]*\)[[:space:]]*\([^[:space:]]*\)[[:space:]]*\([^[:space:]]*\)\]/\1\[\2\3\4\]/g' \
        "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" >"${file-}"
  done
  {
    set \
      +o xtrace
  } 2>/dev/null
}
shfmt_r_r_r() {
  set \
    -o xtrace
  for file in "${@-}"; do
    command shfmt --indent 2 --language-dialect bash --simplify --write -- "${file-}" &&
      command -p -- test -s "${file-}" &&
      # prevent overwriting symlinks and turning them into regular files
      command -p -- test ! -L "${file-}" &&
      command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp' &&
      command -p -- cp -f -p -- "${file-}" "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" &&
      command sed \
        -e 's/^\([^#]*\)\$\([a-zA-Z1-9_][a-zA-Z0-9_]*\(\[[^]]\{1,\}\]\)\{0,1\}\)/\1\${\2}/g' \
        -e 's/^\([^#]*\)\(([[:space:]]*\$[[:space:]]*+[[:space:]]*\([^)]*\))\)/\1(($+\3))/g' \
        -e 's/^\([^#]*\)\[\([^[:space:]]*\)[[:space:]]*\([^[:space:]]*\)[[:space:]]*\([^[:space:]]*\)\]/\1\[\2\3\4\]/g' \
        "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" >"${file-}"
  done
  {
    set \
      +o xtrace
  } 2>/dev/null
}

shlvl() {
  # shellcheck disable=SC3028
  command -p -- printf -- '%d\n' "${SHLVL?}"
}

# shred
shred_r() {
  set \
    -o noclobber \
    -o noglob \
    -o nounset \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      size="$(
        LC_ALL='C' IFS='' command -p -- ls -l -- "${file-}" |
          command awk -- '{printf "%d\n", $5}'
      )" &&
      command shred \
        --force \
        --iterations="$(command -p -- getconf -- CHAR_MAX)" \
        --remove='wipesync' \
        --size="${size-}" \
        --verbose \
        --zero \
        -- \
        "${file-}"
    unset size >/dev/null 2>&1 || size=''
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o nounset \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

signals() {
  # https://docs.google.com/spreadsheets/d/1Pr6IiXP3vv71SMx-PD_DQf6eucwlfJq3WDPnXRwmBgc
  # https://web.archive.org/web/20240704012105id_/dsa.cs.tsinghua.edu.cn/oj/static/unix_signal.html
  # https://web.archive.org/web/20240725101237id_/man7.org/linux/man-pages/man7/signal.7.html
  command -p -- printf -- ' signal    | portable name | value\n'
  command -p -- printf -- ' ----------+---------------+-------\n'
  command -p -- printf -- ' 0         | 0             |     0\n'
  command -p -- printf -- ' SIGHUP    | HUP           |     1\n'
  command -p -- printf -- ' SIGINT    | INT           |     2\n'
  command -p -- printf -- ' SIGQUIT   | QUIT          |     3\n'
  command -p -- printf -- ' SIGILL    | ILL           |     4\n'
  command -p -- printf -- ' SIGTRAP   | TRAP          |     5\n'
  command -p -- printf -- ' SIGABRT   | ABRT          |     6\n'
  command -p -- printf -- ' SIGIOT    | IOT           |     6\n'
  command -p -- printf -- ' SIGBUS    | BUS           |     7\n'
  command -p -- printf -- ' SIGEMT    | EMT           |     7\n'
  command -p -- printf -- ' SIGSTKFLT | STKFLT        |     7\n'
  command -p -- printf -- ' SIGFPE    | FPE           |     8\n'
  command -p -- printf -- ' SIGKILL   | KILL          |     9\n'
  command -p -- printf -- ' SIGBUS    | BUS           |    10\n'
  command -p -- printf -- ' SIGUSR1   | USR1          |    10\n'
  command -p -- printf -- ' SIGSEGV   | SEGV          |    11\n'
  command -p -- printf -- ' SIGSYS    | SYS           |    12\n'
  command -p -- printf -- ' SIGUSR2   | USR2          |    12\n'
  command -p -- printf -- ' SIGXCPU   | XCPU          |    12\n'
  command -p -- printf -- ' SIG       | SIG           |    13\n'
  command -p -- printf -- ' SIGPIPE   | PIPE          |    13\n'
  command -p -- printf -- ' SIGALRM   | ALRM          |    14\n'
  command -p -- printf -- ' SIGTERM   | TERM          |    15\n'
  command -p -- printf -- ' SIGSTKFLT | STKFLT        |    16\n'
  command -p -- printf -- ' SIGURG    | URG           |    16\n'
  command -p -- printf -- ' SIGUSR1   | USR1          |    16\n'
  command -p -- printf -- ' SIGCHLD   | CHLD          |    17\n'
  command -p -- printf -- ' SIGSTOP   | STOP          |    17\n'
  command -p -- printf -- ' SIGUSR2   | USR2          |    17\n'
  command -p -- printf -- ' SIGCHLD   | CHLD          |    18\n'
  command -p -- printf -- ' SIGCLD    | CLD           |    18\n'
  command -p -- printf -- ' SIGCONT   | CONT          |    18\n'
  command -p -- printf -- ' SIGTSTP   | TSTP          |    18\n'
  command -p -- printf -- ' SIGCONT   | CONT          |    19\n'
  command -p -- printf -- ' SIGPWR    | PWR           |    19\n'
  command -p -- printf -- ' SIGSTOP   | STOP          |    19\n'
  command -p -- printf -- ' SIGCHLD   | CHLD          |    20\n'
  command -p -- printf -- ' SIGTSTP   | TSTP          |    20\n'
  command -p -- printf -- ' SIGVTALRM | VTALRM        |    20\n'
  command -p -- printf -- ' SIGWINCH  | WINCH         |    20\n'
  command -p -- printf -- ' SIGPROF   | PROF          |    21\n'
  command -p -- printf -- ' SIGTTIN   | TTIN          |    21\n'
  command -p -- printf -- ' SIGURG    | URG           |    21\n'
  command -p -- printf -- ' SIGIO     | IO            |    22\n'
  command -p -- printf -- ' SIGPOLL   | POLL          |    22\n'
  command -p -- printf -- ' SIGTTOU   | TTOU          |    22\n'
  command -p -- printf -- ' SIGIO     | IO            |    23\n'
  command -p -- printf -- ' SIGPOLL   | POLL          |    23\n'
  command -p -- printf -- ' SIGSTOP   | STOP          |    23\n'
  command -p -- printf -- ' SIGURG    | URG           |    23\n'
  command -p -- printf -- ' SIGWINCH  | WINCH         |    23\n'
  command -p -- printf -- ' SIGSTOP   | STOP          |    24\n'
  command -p -- printf -- ' SIGTSTP   | TSTP          |    24\n'
  command -p -- printf -- ' SIGXCPU   | XCPU          |    24\n'
  command -p -- printf -- ' SIGCONT   | CONT          |    25\n'
  command -p -- printf -- ' SIGTSTP   | TSTP          |    25\n'
  command -p -- printf -- ' SIGXFSZ   | XFSZ          |    25\n'
  command -p -- printf -- ' SIGCONT   | CONT          |    26\n'
  command -p -- printf -- ' SIGTTIN   | TTIN          |    26\n'
  command -p -- printf -- ' SIGVTALRM | VTALRM        |    26\n'
  command -p -- printf -- ' SIGPROF   | PROF          |    27\n'
  command -p -- printf -- ' SIGTTIN   | TTIN          |    27\n'
  command -p -- printf -- ' SIGTTOU   | TTOU          |    27\n'
  command -p -- printf -- ' SIGTTOU   | TTOU          |    28\n'
  command -p -- printf -- ' SIGVTALRM | VTALRM        |    28\n'
  command -p -- printf -- ' SIGWINCH  | WINCH         |    28\n'
  command -p -- printf -- ' SIGINFO   | INFO          |    29\n'
  command -p -- printf -- ' SIGIO     | IO            |    29\n'
  command -p -- printf -- ' SIGLOST   | LOST          |    29\n'
  command -p -- printf -- ' SIGPOLL   | POLL          |    29\n'
  command -p -- printf -- ' SIGPROF   | PROF          |    29\n'
  command -p -- printf -- ' SIGPWR    | PWR           |    29\n'
  command -p -- printf -- ' SIGURG    | URG           |    29\n'
  command -p -- printf -- ' SIGPWR    | PWR           |    30\n'
  command -p -- printf -- ' SIGUSR1   | USR1          |    30\n'
  command -p -- printf -- ' SIGXCPU   | XCPU          |    30\n'
  command -p -- printf -- ' SIGXFSZ   | XFSZ          |    30\n'
  command -p -- printf -- ' SIGSYS    | SYS           |    31\n'
  command -p -- printf -- ' SIGUNUSED | UNUSED        |    31\n'
  command -p -- printf -- ' SIGUSR2   | USR2          |    31\n'
  command -p -- printf -- ' SIGXFSZ   | XFSZ          |    31\n'
}

sk() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  command sudo \
    -- \
    killall -z \
    -- \
    'bird' \
    'corespotlightd' \
    'DropboxFileProvider' \
    'DropboxFileProviderCH' \
    'fileproviderd' \
    'Finder' \
    'Google Drive' \
    'Google Drive Helper' \
    'Maestral' \
    'Spotlight'
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

split_r() {
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  command -p -- test -s "${1-}" &&
    command -p -- split -l "${2:-10000}" -- "${1-}" "${1%.*}"-
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

spotify_request_token() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  SPOTIFY_TOKEN="$(
    # https://web.archive.org/web/2023id_/developer.spotify.com/documentation/web-api/tutorials/getting-started#request-an-access-token
    command curl \
      --data 'grant_type=client_credentials' \
      --data 'client_id='"${SPOTIFY_CLIENT_ID-}" \
      --data 'client_secret='"${SPOTIFY_CLIENT_SECRET-}" \
      --fail \
      --location \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --request 'POST' \
      --show-error \
      --silent \
      --url 'https://accounts.spotify.com/api/token' |
      command -p -- sed \
        -e '# search for the first quotation-marks-surrounded string following token and print only that' \
        -e '# assumption that Spotify returns JSON without optional spaces' \
        -e 's/.*token"[^:]*:[^"]*"\([^"]*\)".*/\1/'
  )" &&
    export SPOTIFY_TOKEN &&
    command -p -- printf -- '%s\n' "${SPOTIFY_TOKEN-}"
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

alias -- \
  sshf='command ssh llarson@freeshell.de' \
  sshk='command ssh kevoc7@oconnor.nyc' \
  sshc='sshk' \
  ssho='sshk' \
  sshl='command ssh lucaslarson@lucaslarson.net' \
  sshs='command ssh ll@tty.sdf.org' \
  sshu='command ssh menu@sdf.org'

sshfs_r() {
  if command -v -- sshfs >/dev/null 2>&1; then

    # https://github.com/microsoft/vscode-docs/blob/4d921d6f46/docs/remote/troubleshooting.md
    export USER_AT_HOST="${1:-lucaslarson@lucaslarson.net}"

    # Create and go to the directory where the remote filesystem will be mounted
    command -p -- mkdir -p -- "${HOME%/}"'/.sshfs/'"${USER_AT_HOST-}" &&
      {
        cd -- "${HOME%/}"'/.sshfs/'"${USER_AT_HOST-}" ||
          command -p -- printf -- 'Failed to create and go to the directory where the remote filesystem will be mounted\n' >&2 &&
          # EX_CANTCREAT
          return 73
      }

    # Mount the remote filesystem
    command sshfs \
      "${USER_AT_HOST-}"':' "${HOME%/}"'/.sshfs/'"${USER_AT_HOST-}" \
      -ovolname="${USER_AT_HOST-}" \
      -p 22 \
      -o workaround=nonodelay \
      -o transform_symlinks \
      -o idmap=user \
      -C # enable compression
  else
    command umount "${HOME%/}"'/.sshfs/'"${USER_AT_HOST-}" 2>/dev/null ||
      command -p -- printf -- 'Failed to unmount the remote filesystem\n' >&2
  fi
  unset USER_AT_HOST 2>/dev/null || USER_AT_HOST=''
}

standard_r() {
  {
    command npm ls -- standard >/dev/null 2>&1 ||
      command npm ls --location=global -- standard >/dev/null 2>&1 ||
      #       npm install --loglevel=verbose --no-fund -- standard ||
      #       npm install --location=global --loglevel=verbose --no-fund -- standard ||
      # EX_UNAVAILABLE
      return 69
  } &&
    PS4=' ' command find -- . \
      -path '*/.git' -prune -o \
      -path '*/node_modules' -prune -o \
      -path '*/coverage' -prune -o \
      -path '*/vendor' -prune -o \
      '(' \
      -name '*.js' -o \
      -name '*._js' -o \
      -name '*.bones' -o \
      -name '*.cjs' -o \
      -name '*.es' -o \
      -name '*.es6' -o \
      -name '*.frag' -o \
      -name '*.gjs' -o \
      -name '*.gs' -o \
      -name '*.jake' -o \
      -name '*.javascript' -o \
      -name '*.jsb' -o \
      -name '*.jscad' -o \
      -name '*.jsfl' -o \
      -name '*.jslib' -o \
      -name '*.jsm' -o \
      -name '*.jspre' -o \
      -name '*.jss' -o \
      -name '*.jsx' -o \
      -name '*.mjs' -o \
      -name '*.njs' -o \
      -name '*.pac' -o \
      -name '*.sjs' -o \
      -name '*.ssjs' -o \
      -name '*.xsjs' -o \
      -name '*.xsjslib' -o \
      -name 'Jakefile' \
      ')' \
      ! -name '*-min.js' \
      ! -name '*.min.js' \
      -type f \
      -exec sh -C -e -f -u -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command npm exec -- standard --fix -- "${1-}"
' _ {} ';'
}

string_contains_alternative() {
  (
    # in subshell to avoid polluting the environment
    # https://github.com/koalaman/shellcheck/wiki/SC2081/e2c255237339bb0479d090494ea8b316ab9430f5#rationale
    set \
      -o xtrace
    case "${#}" in
    2)
      string="${1-}"
      substring="${2-}"
      command -p -- test "${string-}" != "${string#"${substring-}"}" ||
        return 1
      ;;
    *)
      command -p -- printf -- 'Usage: %s <string> <substring>\n' "${0##*/}"
      ;;
    esac
  )
}

subdomains() {
  # TODO: merklemap.com API, begun at $custom/subdomains_merklemap.sh
  command curl \
    --fail \
    --location \
    --show-error \
    --silent \
    --url 'https://api.subdomain.center/?domain='"${1-}" |
    command -p -- sed \
      -e '# replace capital letters' \
      -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' \
      -e '# remove all string values that begin with "www."' \
      -e 's/"www\.[^"]*"//g' \
      -e '# remove all double quotation marks' \
      -e 's/"//g' \
      -e '# remove all opening square brackets' \
      -e 's/\[//g' \
      -e '# replace all strings of commas with a single newline' \
      -e 's/,\{1,\}/\n/g' \
      -e '# replace all closing square brackets with a newline' \
      -e 's/\]/\n/g' |
    LC_ALL='C' command -p -- sort -u |
    LC_ALL='C' command -p -- sort -f
}

substring_bash() {
  #  Copyright 2002 Chester Ramey under GNU GPL v2.0+
  # -l == remove shortest from left
  # -L == remove longest from left
  # -r == remove shortest from right (the default)
  # -R == remove longest from right
  usage="usage: substring -lLrR pattern string or substring string pattern"
  options="l:L:r:R:"

  OPTIND=1
  while getopts "${options-}" c; do
    case "${c-}" in
    l | L | r | R)
      flag="-${c-}"
      pattern="${OPTARG-}"
      ;;
    -* | '?')
      command -p -- printf -- '%s\n' "${usage-}"
      return 1
      ;;
    *)
      flag="-r"
      pattern="${OPTARG-}"
      ;;
    esac
  done

  if command -p -- test "${OPTIND-}" -gt 1; then
    shift $((OPTIND - 1))
  fi

  if command -p -- test "${#}" -eq 0 || command -p -- test "${#}" -gt 2; then
    command -p -- printf -- 'substring: bad argument count\n' >&2
    return 2
  fi

  string="${1-}"

  # We don't want `set -f`/`set -o noglob`, but we don't want to turn it back on if
  # we didn't have it already
  case "${-}" in
  "*f*") ;;
  *)
    fng=1
    set \
      -o noglob
    ;;
  esac

  case "${flag-}" in
  -l)
    string="${string#"${pattern-}"}" # substring -l pattern string
    ;;
  -L)
    string="${string##"${pattern-}"}" # substring -L pattern string
    ;;
  -r)
    string="${string%"${pattern-}"}" # substring -r pattern string
    ;;
  -R)
    string="${string%%"${pattern-}"}" # substring -R pattern string
    ;;
  *)
    string="${string%"${2-}"}" # substring string pattern
    ;;
  esac

  command -p -- printf -- '%s\n' "${string-}"

  # If we had `set -f` when we started, re-enable it
  if command -p -- test "${fng-}" -eq 1; then
    set \
      +o noglob
  fi
  unset flag 2>/dev/null || flag=''
  unset c 2>/dev/null || c=''
  unset fng 2>/dev/null || fng=''
  unset options 2>/dev/null || options=''
  unset pattern 2>/dev/null || pattern=''
  unset string 2>/dev/null || string=''
  unset usage 2>/dev/null || usage=''
}

substring_contains() {
  (
    # does string/$1 contain substring/$2?
    # returns 0 if the specified string contains the specified substring,
    # otherwise returns 1
    # in subshell to avoid polluting the environment without bash `local`
    set \
      -o verbose \
      -o xtrace
    exit_code=0

    case "${1-}" in
    -h | --help)
      command -p -- printf -- 'Usage: %s string substring\n' "${0##*/}"
      ;;
    *)
      if command -p -- test "${#}" -eq 2; then
        string="$(
          command -p -- printf -- '%s' "${1-}" |
            command -p -- sed -e 's/\/*$//'
        )"
        substring="${2-}"
        # equivalent to bash:
        #   [[ $string == *$substring* ]]
        #   [[ $string =~ *$substring  ]]
        #   [[ $string =~ *$substring* ]]
        #   [[ $string =~  $substring  ]]
        #   [[ $string =~  $substring* ]]
        #   [[ $string =  *$substring* ]]
        # https://stackoverflow.com/a/8811800
        if command -p -- test "${string-}" != "${string#"${substring-}"}"; then
          # $substring is in $string
          exit_code=0
        else
          # $substring is not in $string
          exit_code=1
        fi
      else
        # argument count is not 2
        # `return 3` because `return 1` means `$1` does not contain `$2`
        exit_code=3
        command "${0-}" --help >&2
      fi
      ;;
    esac
    return "${exit_code:-126}"
    # unset string substring exit_code
    # {
    #   set \
    #     +o verbose \
    #     +o xtrace
    # } 2>/dev/null
  )
}
alias -- string_contains='substring_contains'

alias -- sudo='sudo '

string_length() {
  # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
  for string in "${@-}"; do
    command -p -- printf -- '%d\n' "${#string}"
  done
}

string_starts_with() {
  command -p -- test "${#}" -eq 2 ||
    return 1
  # https://stackoverflow.com/a/48913862
  case "${1-}" in
  "${2-}"*)
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}

string_ends_with() {
  # string=$1
  # ends_with=$2
  case "${1-}" in
  *"${2-}")
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}
alias -- substring_ends_with='string_ends_with'

string_starts_with_gitflow() {
  # https://github.com/nvie/gitflow/blob/e0d8af3bec/gitflow-common#L34-L35
  command -p -- test "${1-}" != "${1#"${2-}"}"
}
alias -- substring_starts_with_gitflow='string_starts_with_gitflow'
string_ends_with_gitflow() {
  # https://github.com/nvie/gitflow/blob/e0d8af3bec/gitflow-common#L34-L35
  command -p -- test "${1-}" != "${1%"${2-}"}"
}
alias -- substring_ends_with_gitflow='string_ends_with_gitflow'

strikethrough() {
  command -p -- printf -- '%s\n' "${@-}" |
    command -p -- sed \
      -e 's/[[:graph:]]/&̸/g'
}

stylelint_r() {
  command -v -- stylelint >/dev/null 2>&1 ||
    # EX_UNAVAILABLE
    return 69
  set \
    -o verbose \
    -o xtrace
  configuration="$(
    command find -L -- "${XDG_CONFIG_HOME:-${HOME%/}/.config}"'/stylelint' \
      '(' \
      -path "${XDG_CONFIG_HOME:-${HOME%/}/.config}"'/stylelint/.stylelintrc' -o \
      -path "${XDG_CONFIG_HOME:-${HOME%/}/.config}"'/stylelint/.stylelintrc.cjs' -o \
      -path "${XDG_CONFIG_HOME:-${HOME%/}/.config}"'/stylelint/.stylelintrc.js' -o \
      -path "${XDG_CONFIG_HOME:-${HOME%/}/.config}"'/stylelint/.stylelintrc.json' -o \
      -path "${XDG_CONFIG_HOME:-${HOME%/}/.config}"'/stylelint/.stylelintrc.yaml' -o \
      -path "${XDG_CONFIG_HOME:-${HOME%/}/.config}"'/stylelint/.stylelintrc.yml' \
      ')' \
      -type f \
      -exec ls -1 -S -- {} + 2>/dev/null |
      command -p -- sed -e '1 q'
  )" &&
    export configuration='--config='"${configuration-}"
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/Empty' -prune -o \
    -path '*/Library' -prune -o \
    -path '*/node_modules' -prune -o \
    -path '*/t' -prune -o \
    -path '*/Test*' -prune -o \
    -path '*/test*' -prune -o \
    -path '*/tst*' -prune -o \
    -path '*copilot*' -prune -o \
    -path '*dummy*' -prune -o \
    -path '*vscode*' -prune -o \
    -name '*.css' \
    -type f \
    -exec sh -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command npm exec -- stylelint --allow-empty-input --color "${configuration-}" --fix --formatter=verbose --ignore-disables --report-descriptionless-disables --report-invalid-scope-disables --report-needless-disables -- "${1-}"
' _ {} ';'
  unset configuration 2>/dev/null || configuration=''
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

super_linter_r() {
  # https://github.com/super-linter/super-linter/issues/5383#issuecomment-1998289936
  command docker run \
    --env DEFAULT_WORKSPACE="${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash/lint' \
    --env IGNORE_GITIGNORED_FILES=true \
    --env LOG_LEVEL=DEBUG \
    --env LOG_TRACE=true \
    --env MULTI_STATUS=true \
    --env RUN_LOCAL=true \
    --env SUPPRESS_POSSUM=true \
    --env USE_FIND_ALGORITHM=true \
    --env VALIDATE_ALL_CODEBASE=true \
    --env VALIDATE_BASH=true \
    --env VALIDATE_CSS=true \
    --env VALIDATE_DOCKERFILE_HADOLINT=true \
    --env VALIDATE_ENV=true \
    --env VALIDATE_HTML=true \
    --env VALIDATE_JAVASCRIPT_STANDARD=true \
    --env VALIDATE_JSON=true \
    --env VALIDATE_LANGUAGE=true \
    --env VALIDATE_MARKDOWN=true \
    --env VALIDATE_NATURAL_LANGUAGE=true \
    --env VALIDATE_PYTHON_BLACK=true \
    --env VALIDATE_RUBY=true \
    --env VALIDATE_YAML=true \
    --volume "$(command git rev-parse --show-toplevel)"':'"${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash/lint' \
    ghcr.io/super-linter/super-linter:latest
  # https://github.com/github/super-linter/commit/c01d0bc870
  command docker run \
    --env ACTIONS_RUNNER_DEBUG=true \
    --env DISABLE_ERRORS=false \
    --env ERROR_ON_MISSING_EXEC_BIT=true \
    --env LOG_LEVEL=DEBUG \
    --env LOG_TRACE=true \
    --env LINTER_RULES_PATH=. \
    --env MULTI_STATUS=false \
    --env RUN_LOCAL=true \
    --env VALIDATE_ALL_CODEBASE=true \
    --volume "$(command -p -- pwd)":/tmp/lint \
    ghcr.io/super-linter/super-linter:latest
}

swiftlint_r() {
  command -v -- swiftlint >/dev/null 2>&1 ||
    # EX_UNAVAILABLE
    return 69
  # {} + was finding too many files.... so moved to {} \; and then to
  # -exec sh with too many flags
  IFS=' ' command find -- . \
    -name '*.swift' \
    -type f \
    -exec sh -C -f -u -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command swiftlint lint --enable-all-rules --fix --format --progress --strict -- "${1-}"
' _ {} ';'
}

tabs_to_spaces() {
  for file in "${@-}"; do
    # apply to any file, except for
    # - zero-length files
    command -p -- test -s "${file-}" &&
      # - symlinks
      command -p -- test ! -L "${file-}" &&
      # - binary property lists using `grep` without `-q` support
      command -p -- grep -v -e 'bplist' -- "${file-}" >/dev/null 2>&1 &&
      command -p -- file -- "${file-}" |
      command -p -- grep -v -e 'binary' >/dev/null 2>&1 &&
      command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp' &&
      command -p -- cp -f -p -- "${file-}" "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" &&
      command -p -- sed -e 's/\t/  /g' "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp/'"${file##*/}" >"${file-}"
  done
}

tabs_to_spaces_ed() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command -p -- grep -v -e 'bplist' -- "${file-}" >/dev/null 2>&1 &&
      LC_ALL='C' command -p -- file -- "${file-}" |
      command -p -- grep -v -e 'binary' >/dev/null 2>&1 &&
      command -p -- ed -s -- "${file-}" <<EOF
1,\$ s/	/  /g
w
q
EOF
  done |
    command -p -- sed \
      -e '# suppress ed question mark-only lines' \
      -e '/^?$/ d'
  {
    set \
      +o noclobber \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

tail() {
  case "${1-}" in
  -*)
    command -p -- tail "${@-}"
    ;;
  *)
    command -p -- tail -n "$((${LINES:-"$(
      command -p -- tput -- lines 2>/dev/null ||
        command -p -- printf -- '10 + 2'
    )"} - 3))" "${@-}"
    ;;
  esac
}

# take: mkdir && cd
take() {
  while command -p -- test "${#}" -gt 0; do
    if command -p -- test -d "${1-}"; then
      command -p -- printf -- 'directory \342\200\230%s\342\200\231 exists...\n' "${1-}" >&2
    elif command -p -- printf -- 'creating directory \342\200\230%s\342\200\231... ' "${1##*"${PWD}"/}" >&2 &&
      command -p -- mkdir -p -- "${1-}"; then
      command -p -- printf -- 'done\n' >&2
    fi
    # POSIX-compliant `${@:$#}`-style string indexing (SC3057)
    # https://stackoverflow.com/q/1853946
    command -p -- test "${#}" -eq 1 &&
      command -p -- printf -- 'entering directory \342\200\230%s\342\200\231\n' "${1##*"${PWD}"/}" >&2 &&
      cd -- "${1-}" ||
      return "${?:-1}"
    shift
  done
}
alias -- md >/dev/null 2>&1 &&
  unalias -- md
alias -- md='command -p -- mkdir -p'

tdt() {
  case "${1-}" in
  --evil)
    {
      target="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp.trash/evil-'"$(command -p -- date -- '+%Y%m%d%H%M%S')"
      command -p -- mkdir -p -- "${target-}" &&
        cd -- "${target-}"
    } ||
      return 1
    ;;
  *)
    {
      command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp.trash' &&
        cd -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/tmp.trash'
    } ||
      return 1
    ;;
  esac
  command git status 2>/dev/null ||
    command -p -- true
  unset target 2>/dev/null || target=''
}
alias -- tet='tdt --evil'

# temperature: return the CPU temperature in degrees Fahrenheit
temperature() {
  set \
    -o noclobber \
    -o noglob
  # 𝑛 + narrow non-breaking space + degree sign + F
  command -p -- printf -- '%d\342\200\257\302\260F\n' "$(
    command sudo -- powermetrics --samplers smc |
      # `command awk` instead of `command -p awk` for SC2016
      command awk -- '/CPU die temperature/ {printf "%f * 9 / 5 + 32\n", $4; exit}' |
      command -p -- bc
  )"
  {
    set \
      +o noclobber \
      +o noglob
  } 2>/dev/null
}
alias -- temp='temperature'

textlint_r() {
  command -p -- test -d "$(command npm config --location=global -- get prefix)"'/lib/node_modules/textlint-rule-terminology' >/dev/null 2>&1 || {
    command npm install --location=global --loglevel=verbose --no-fund -- textlint
    command npm install --location=global --loglevel=verbose --no-fund -- textlint-rule-terminology
  } || return 127
  set \
    -o xtrace
  # find all Markdown text files, then run `textlint` on them
  command find -- . \
    -path '*/.git' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/Empty' -prune -o \
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
    -name '*.md' -o \
    -name '*.livemd' -o \
    -name '*.markdn' -o \
    -name '*.markdown' -o \
    -name '*.mdown' -o \
    -name '*.mdwn' -o \
    -name '*.mdx' -o \
    -name '*.mkd' -o \
    -name '*.mkdn' -o \
    -name '*.mkdown' -o \
    -name '*.ronn' -o \
    -name '*.scd' -o \
    -name '*.workbook' -o \
    -name 'contents.lr' -o \
    -name '*.txt' -o \
    -name '*.fr' -o \
    -name '*.nb' -o \
    -name '*.ncl' -o \
    -name '*.no' -o \
    -name 'CITATION' -o \
    -name 'CITATIONS' -o \
    -name 'click.me' -o \
    -name 'COPYING' -o \
    -name 'COPYING.regex' -o \
    -name 'COPYRIGHT.regex' -o \
    -name 'delete.me' -o \
    -name 'FONTLOG' -o \
    -name 'INSTALL' -o \
    -name 'INSTALL.mysql' -o \
    -name 'keep.me' -o \
    -name 'LICENSE' -o \
    -name 'LICENSE.mysql' -o \
    -name 'NEWS' -o \
    -name 'package.mask' -o \
    -name 'package.use.mask' -o \
    -name 'package.use.stable.mask' -o \
    -name 'read.me' -o \
    -name 'readme.1st' -o \
    -name 'README.me' -o \
    -name 'README.mysql' -o \
    -name 'README.nss' -o \
    -name 'test.me' -o \
    -name 'use.mask' -o \
    -name 'use.stable.mask' \
    ')' \
    -type f \
    -exec sh -x -c 'command git ls-files --error-unmatch -- "${1-}" >/dev/null 2>&1 ||
  ! command git rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command npm exec -- textlint --experimental --fix --rule terminology -- "${1-}"
' _ {} ';'
  {
    set \
      +o xtrace
  } 2>/dev/null
}

transfer() {
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      {
        command curl --fail --form 'expires=1' --form 'file=@'"${file-}" --form 'secret='\'''\''' --location --show-error --silent --url https://0x0.st ||
          {
            command curl --fail --location --show-error --silent --upload-file "${file-}" --url 'https://bashupload.com' |
              command -p -- sed -n -e '/http/ s/wget //p'
          } ||
          command curl --fail --form 'file=@'"${file-}" --location --show-error --silent --write-out='\n' --url 'https://tmpfiles.org/api/v1/upload' ||
          command curl --fail --form 'file=@'"${file-}" --location --show-error --silent --write-out='\n' --url 'https://temp.sh/upload' ||
          command wget --hsts-file=/dev/null --post-file="${file-}" --quiet 'https://temp.sh/upload' ||
          command curl --fail --location --silent --show-error --upload-file "${file-}" --write-out='\n' --url 'https://temp.sh' ||
          command curl --fail --location --silent --show-error --upload-file - --write-out='\n' --url 'https://temp.sh/'"${file-}" ||
          command curl --fail --location --silent --show-error --upload-file "${file-}" --write-out='\n' --url 'https://temp.sh/'"${file##*/}" ||
          command wget --body-file="${file-}" --hsts-file=/dev/null --method=PUT --output-document=- --quiet 'https://temp.sh/'"${file##*/}" ||
          command curl --fail --location --show-error --silent --upload-file "${file-}" --write-out='\n' --url 'https://transfer.sh/'"${file##*/}" ||
          command wget --body-file="${file-}" --hsts-file=/dev/null --method=PUT --output-document=- --quiet 'https://transfer.sh/'"${file##*/}"
      }
  done
}

trash_developer() {
  set \
    -o noclobber \
    -o noglob \
    -o verbose \
    -o xtrace
  if command -p -- test -d "${HOME%/}"'/.Trash'; then
    target="${HOME%/}"'/.Trash'
  elif command -p -- mkdir -p -- "${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash' 2>/dev/null; then
    target="${XDG_DATA_HOME:-${HOME%/}/.local/share}"'/Trash'
  elif command -p -- mkdir -p -- "${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/.Trash' 2>/dev/null; then
    target="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"'/.Trash'
  else
    # EX_CANTCREAT
    return 73
  fi
  trash_date="$(command -p -- date -- '+%Y%m%d%H%M%S')"
  command -p -- mkdir -p -- "${HOME%/}"'/Library/Developer/Xcode/DerivedData' &&
    command -p -- mv -f -i -- "${HOME%/}"'/Library/Developer/Xcode/DerivedData' "${target-}"'/Xcode-'"${trash_date-}"
  command -p -- mkdir -p -- "${HOME%/}"'/Library/Developer/Xcode/UserData/IB Support' &&
    command -p -- mv -f -i -- "${HOME%/}"'/Library/Developer/Xcode/UserData/IB Support' "${target-}"'/Xcode⁄UserData⁄IB Support-'"${trash_date-}"
  command -p -- mkdir -p -- "${HOME%/}"'/Library/Caches/JetBrains' &&
    command -p -- mv -f -i -- "${HOME%/}"'/Library/Caches/JetBrains' "${target-}"'/JetBrains-'"${trash_date-}"
  command -p -- mkdir -p -- "${HOME%/}"'/Library/Caches/org.carthage.CarthageKit/DerivedData' &&
    command -p -- mv -f -i -- "${HOME%/}"'/Library/Caches/org.carthage.CarthageKit/DerivedData' "${target-}"'/Carthage-'"${trash_date-}"
  command -p -- mkdir -p -- "${HOME%/}"'/Library/Caches/Homebrew/downloads' &&
    command -p -- mv -f -i -- "${HOME%/}"'/Library/Caches/Homebrew/downloads' "${target-}"'/Homebrew-'"${trash_date-}"
  command -v -- brew >/dev/null 2>&1 && {
    command brew autoremove --verbose
    command brew cleanup --prune=all --verbose
  }
  command -v -- gem >/dev/null 2>&1 &&
    command gem cleanup --verbose
  case "$(
    command -v -- xcrun >/dev/null 2>&1 &&
      command xcrun simctl list -j devices unavailable |
      command -p -- sed \
        -n \
        -e 'H' \
        -e '$ {' \
        -e '  x' \
        -e '  s/[[:space:]]//gp' \
        -e '}'
  )" in
  *{}*) ;;
  *)
    # this may require `sudo` and
    # this may be on a virtual but ejectable disk
    command xcrun simctl delete unavailable
    ;;
  esac &&
    {
      set \
        +o noclobber \
        +o noglob \
        +o verbose \
        +o xtrace
    } 2>/dev/null
  unset target 2>/dev/null || target=''
  unset trash_date 2>/dev/null || trash_date=''
  command -p -- printf -- '\n\360\237\232\256  data successfully trashed\n' >&2
}

update_changelog() {
  command -v -- gem >/dev/null 2>&1 && {
    command -p -- test "${CHANGELOG_GITHUB_TOKEN-}" != '' ||
      command -p -- test "${GITHUB_API_TOKEN-}" != '' ||
      command -p -- test "${GITHUB_OAUTH_TOKEN-}" != '' ||
      command -p -- test "${GITHUB_TOKEN-}" != ''
  } && {
    command -v -- github_changelog_generator >/dev/null 2>&1 ||
      command gem install github_changelog_generator
  } && {
    command -v -- markdownlint >/dev/null 2>&1 ||
      command npm install --location=global --no-fund -- markdownlint
  } ||
    return 1
  # find one existing changelog once
  file="$(
    cd -- "$(
      # attempt relative-path access
      command git rev-parse \
        --show-toplevel \
        --path-format=relative |
        command -p -- sed \
          -e '1 q'
    )" 2>/dev/null ||
      cd -- "$(
        command git rev-parse \
          --show-toplevel
      )" ||
      return "${?:-1}"
    # find the Markdown changelog with the latest commit
    command find -- . \
      -path './[Cc][Hh][Aa][Nn][Gg][Ee]*[Ll][Oo][Gg]*.[Mm]*[Dd]*' \
      -type f \
      -exec sh -c 'command git log --max-count=1 --pretty=tformat:'\''%at '\''"${1-}"' _ {} ';' |
      LC_ALL='C' command -p -- sort -n -r |
      command -p -- sed \
        -e '# print only the second field of the first line' \
        -e '1 s/.*\///g' \
        -e '1 q'
  )"
  # define changelog location if none is found
  file="${file:=changelog.md}"
  # ensure the file exists
  command -p -- touch -- "${file-}"
  # create local changes
  command gem exec github_changelog_generator \
    --user "$(
      command git ls-remote --get-url |
        command -p -- sed \
          -e '# replace colons with forward slashes' \
          -e 's/:/\//g' \
          -e '# remove everything except the second-to-last' \
          -e '# forward slash-delimited field' \
          -e 's/.*\/\([^/]*\)\/[^/]*/\1/'
    )" \
    --project "$(
      command git ls-remote --get-url |
        command -p -- sed \
          -e 's/.*\///' \
          -e 's/\.git$//'
    )" \
    --token "${CHANGELOG_GITHUB_TOKEN:-${GITHUB_TOKEN:-${GITHUB_API_TOKEN:-${GITHUB_OAUTH_TOKEN-}}}}" \
    --exclude-labels 'duplicate,question,invalid,wontfix,nodoc' \
    --output "${file-}" ||
    return 1
  # repair changelog credit
  command -p -- sed \
    -e 's/This Changelog/This changelog/' \
    -e 's/automatically generated/\[automatically generated\]()/' \
    -e 's/\]()/\](.\/.github\/workflows\/changelog.yml)/' \
    -e 's/generator)\*/generator).\*/' \
    ./"${file-}" >./"${file%.*}"_temporary."${file##*.}" &&
    command -p -- mv -f -- \
      ./"${file%.*}"_temporary."${file##*.}" ./"${file-}"
  # get linting configuration
  {
    command -p -- test -s "${HOME%/}"'/.markdownlint.json' &&
      configuration='--config='"${HOME%/}"'/.markdownlint.json'
  } || {
    command -p -- test -s "${HOME%/}"'/.markdownlint.yml' &&
      configuration='--config='"${HOME%/}"'/.markdownlint.yml'
  } ||
    configuration='--disable MD013 MD033'
  export configuration
  # lint changelog
  command -p -- test ! -e "${HOME%/}"'/.markdownlint.json' ||
    configuration='--config='"${HOME%/}"'/.markdownlint.json' ||
    configuration='--disable MD013'
  command markdownlint "${configuration-}" --fix -- "${file-}"
  unset file 2>/dev/null || file=''
  unset configuration 2>/dev/null || configuration=''
  # ensure nothing else is staged
  command git reset --quiet HEAD -- .
  # stage and commit files
  command git add --verbose -- ./"${file-}"
  command git commit \
    --author='GitHub <actions@github.com>' \
    --message='update changelog' \
    --verbose ||
    return 0
}

# Unix epoch seconds
alias -- unixtime='command awk -- '\''BEGIN {srand(); print srand()}'\'''
unixtime_set() {
  # force weekday matching when only 1970 to 1999 are available using perpetual calendar
  # UNIX 5.0: `date [ mmddhhmm[yy] ]`
  # fail if called before 2000, after 2066
  # https://web.archive.org/web/0id_/i.pinimg.com/originals/8a/23/99/8a2399cf3774165dddc728641a6b0c06.jpg
  year="$(LC_ALL='C' command -p -- date -- '+%Y')" &&
    command -p -- test 2000 -le "${year-}" &&
    command -p -- test "${year-}" -le 2066 &&
    if command -p -- test "${year-}" -lt 2026; then
      year="$((year + 72 - 2000))" # 2000’s calendar matches 1972’s... 2025’s matches 1997’s
    else
      year="$((year + 44 - 2000))" # 2026’s calendar matches 1970's... 2066’s matches 1999’s
    fi &&
    command -p -- printf -- 'UNIX date to force a matching weekday:\n' >&2 &&
    command -p -- printf -- '          \ndate \047%s%s\047\n' "${year-}" "$(LC_ALL='C' command -p -- date -- '+%m%d%H%M.%S')" &&
    command -p -- printf -- '# UNIX 5.0\ndate \047%s%s\047\n' "$(LC_ALL='C' command -p -- date -- '+%m%d%H%M')" "${year-}"
  unset year 2>/dev/null || year=''
}
alias -- unixdate_set='unixtime_set'

url_to_filename() {
  command -p -- test "${#}" -gt 0 ||
    # EX_NOINPUT
    return 66
  command -p -- printf -- '%s\n' "${*-}" |
    command -p -- sed \
      -e '# remove https/http/chrome/brave protocol and www' \
      -e 's|.*://\(w*\.\)*||g' \
      -e '# remove leading github.com/ or gitlab.com/' \
      -e 's|git..b\.com/||g' \
      -e '# remove “/blob”, “/-/blob”, “/tree”, “/-/tree”, “/commit”, “/-/commit”' \
      -e 's|/*-*/blob/|/|' \
      -e 's|/*-*/tree/|/|' \
      -e 's|/*-*/commit/|/|' \
      -e '# replace slash plus up to 40 hexadecimal characters with “@” plus their first 7' \
      -e '# https://chat.com/share/67cdc568-5cec-8007-99a4-57fb960a96e3' \
      -e 's|/\([[:xdigit:]]\)\([[:xdigit:]]\)\([[:xdigit:]]\)\([[:xdigit:]]\)\([[:xdigit:]]\)\([[:xdigit:]]\)\([[:xdigit:]]\)[[:xdigit:]]\{33\}|@\1\2\3\4\5\6\7|g' \
      -e '# replace slashes with “∕”' \
      -e 's|/|'"$(LC_ALL='C' command -p -- printf -- '\342\210\225')"'|g' \
      -e '# replace question marks with “︖”' \
      -e 's|?|'"$(LC_ALL='C' command -p -- printf -- '\357\270\226')"'|g' \
      -e '# replace exclamation points with “！”' \
      -e 's|!|'"$(LC_ALL='C' command -p -- printf -- '\357\274\201')"'|g' \
      -e '# replace ampersands with “＆”' \
      -e 's|&|'"$(LC_ALL='C' command -p -- printf -- '\357\274\206')"'|g' \
      -e '# replace parentheses with fullwidth punctuation' \
      -e 's|(|'"$(LC_ALL='C' command -p -- printf -- '\357\274\210')"'|g' \
      -e 's|)|'"$(LC_ALL='C' command -p -- printf -- '\357\274\211')"'|g' \
      -e '# replace [especially Wikipedia] “File:” with “File：”' \
      -e 's|:|'"$(LC_ALL='C' command -p -- printf -- '\357\274\232')"'|g' \
      -e '# replace asterisks with asterisk operator (“∗”)' \
      -e 's|*|'"$(LC_ALL='C' command -p -- printf -- '\342\210\227')"'|g' \
      -e '# replace spaces with underscores' \
      -e 's| |_|g' \
      -e '# remove trailing hashmarks if any' \
      -e 's|#*$||g' \
      -e '# replace non-trailing hashmarks with fullwidth number signs' \
      -e 's|#|'"$(LC_ALL='C' command -p -- printf -- '\357\274\203')"'|g' \
      -e '# remove trailing slashes if any' \
      -e 's|/*$||g'
}

user() {
  command -p -- test "${LOGNAME:-${USER-}}" != '' ||
    return "${?:-1}"
  command -p -- printf -- '%s\n' "${LOGNAME:-${USER-}}"
}

variable_value() {
  for possible_variable in "${@:-HOME}"; do
    command -p -- test "$(eval " command -p -- printf -- '%s' \"\${${possible_variable-}-}\"")" != '' &&
      command -p -- printf -- '%s:\t%s\n' "${possible_variable-}" "$(eval " echo \$${possible_variable-}")"
  done
}
# return string's value as a variable if so set
value_of_variable() {
  set \
    -o verbose \
    -o xtrace
  if eval " $(
    command -p -- printf -- '%s\n' "${1-}" |
      command -p -- sed -e 's/^\(.*\)=.*$/echo "\1=\1"/'
  )"; then
    command -p -- printf -- '%s\n' "${1-}"
  fi
  query="${1-}"
  if command -p -- test "${query-}" != ''; then
    eval " $(
      command -p -- printf -- '%s' "${query-}" &&
        command -p -- printf -- '\n'
    )"
  fi
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

# Visual Studio Code
command -v -- _code >/dev/null 2>&1 &&
  compdef -- code-insiders='code'
code() {
  if command -v -- code-insiders >/dev/null 2>&1; then
    utility='code-insiders'
  elif command -p -- test -x '/usr/bin/code-insiders'; then
    utility='/usr/bin/code-insiders'
  elif command -p -- test -x "${HOMEBREW_PREFIX-}"'/bin/code-insiders'; then
    utility="${HOMEBREW_PREFIX-}"'/bin/code-insiders'
  elif command -p -- test -x '/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code'; then
    utility='/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code'
  elif command -p -- test -x '/usr/bin/code'; then
    utility='/usr/bin/code'
  elif command -p -- test -x "${HOMEBREW_PREFIX-}"'/bin/code'; then
    utility="${HOMEBREW_PREFIX-}"'/bin/code'
  elif command -p -- test -x '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'; then
    utility='/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
  fi
  {
    command "${utility-}" "${@:-.}" ||
      command open -a 'Visual Studio Code - Insiders' "${@:-.}" ||
      command open -n -a 'Visual Studio Code - Insiders' "${@:-.}" ||
      command open -a 'Visual Studio Code' "${@:-.}" ||
      command open -n -a 'Visual Studio Code' "${@:-.}"
  } 2>/dev/null # vomiting this kind of garbage since about late 2023
  # [0302/150701.624151:ERROR:codesign_util.cc(108)] SecCodeCheckValidity: Error Domain=NSOSStatusErrorDomain Code=-67062 "(null)" (-67062)
  # [0302/150702.727990:ERROR:codesign_util.cc(108)] SecCodeCheckValidity: Error Domain=NSOSStatusErrorDomain Code=-67062 "(null)" (-67062)
  unset utility 2>/dev/null || utility=''
}

wayback() {
  command open -- 'https://web.archive.org/web/'"${1-}"
}
alias -- archive='wayback'

wayback_r() {
  (
    set \
      -o verbose \
      -o xtrace
    command -v -- gem >/dev/null 2>&1 ||
      return 127
    command -v -- wayback_machine_downloader >/dev/null 2>&1 ||
      command gem install --verbose wayback_machine_downloader
    command wayback_machine_downloader --all-timestamps "${1-}"
  )
}

webp_r() {
  set \
    -o noclobber \
    -o noglob \
    -o nounset \
    -o verbose \
    -o xtrace
  for file in "${@-}"; do
    command -p -- test -s "${file-}" &&
      command -p -- test ! -L "${file-}" &&
      command cwebp \
        -alpha_filter best \
        -lossless \
        -m 6 \
        -mt \
        -progress \
        -q 100 \
        -qrange 100 100 \
        -v \
        -z 9 \
        -o "${file%.*}"'.webp' \
        -- \
        "${file-}"
  done
  {
    set \
      +o noclobber \
      +o noglob \
      +o nounset \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

## website troubleshooting
troubleshoot_website() {
  {
    command -p -- printf -- '# https://web.archive.org/web/20221203151931/help.dreamhost.com/hc/en-us/articles/215867298-Commands-to-troubleshoot-your-websites\n'
    command -p -- printf -- 'command uptime\n'
    command -p -- printf -- 'command lsof -u "\044{LOGNAME:-\044{USER-}}" | command -p -- grep -e '\''php'\'' | command -p -- grep -e '\''/home'\''\n'
    command -p -- printf -- 'command watch "command lsof -u "\044{LOGNAME:-\044{USER-}}" | command -p -- grep -e '\''php'\'' | command -p -- grep -e '\''/home'\'' | command -p -- tee -a -- ./results.txt"\n'
    command -p -- printf -- 'command -p -- cat -- ./results.txt\n'
    command -p -- printf -- '# https://web.archive.org/web/20221005032620/help.dreamhost.com/hc/en-us/articles/115000683852-Using-the-top-command-to-troubleshoot-your-website\n'
    command -p -- printf -- 'top\n'
    command -p -- printf -- '# https://web.archive.org/web/20221004111114/help.dreamhost.com/hc/en-us/articles/214880098-Using-the-ps-command-to-troubleshoot-your-website\n'
    command -p -- printf -- '# cpu\n'
    command -p -- printf -- 'command -p -- ps -A -o pcpu,pid,user,args | LC_ALL='\''C'\'' command -p -- sort -k 1 -r | command -p -- head -n 10\n'
    command -p -- printf -- '# memory\n'
    command -p -- printf -- 'command -p -- ps -A -o pmem,pid,user,args | LC_ALL='\''C'\'' command -p -- sort -k 1 -r | command -p -- head -n 10\n'
    command -p -- printf -- '# https://web.archive.org/web/20221203051014/help.dreamhost.com/hc/en-us/articles/216105097-Viewing-and-examining-your-access-log-via-SSH\n'
    command -p -- printf -- 'cd -- "\044{HOME\045/}"'\''/logs/'\''"\044{LOGNAME:-\044{USER-}}"'\''.net'\''\n'
    command -p -- printf -- '# list the last 10,000 site hits\n'
    command -p -- printf -- 'command find -L -- . -name '\''access.log'\'' -type f -exec tail -n 10000 -- {} + | command awk -- '\''{print \0441}'\'' | LC_ALL='\''C'\'' command -p -- sort | command -p -- uniq -c | LC_ALL='\''C'\'' command -p -- sort -n\n'
    command -p -- printf -- '# watch the server log in real time\n'
    command -p -- printf -- 'command -p -- tail -f -- **/*access.log\n'
    command -p -- printf -- '# list files being called the most\n'
    command -p -- printf -- 'command awk '\''{print \0447}'\'' ./access.log | command -p -- cut -d? -f 1 | LC_ALL='\''C'\'' command -p -- sort | command -p -- uniq -c | LC_ALL='\''C'\'' command -p -- sort -k -n 1 | command -p -- tail -n 10\n'
    command -p -- printf -- '# list traffic for all user domains on server\n'
    command -p -- printf -- 'cd -- "\044{HOME\045/}"'\''/logs\n && for k in \044(ls -S */https/access.log); do command -p -- wc -l -- "\044{k-}" | LC_ALL='\''C'\'' command -p -- sort -n -r; done\n'
  } | {
    command bat \
      --decorations=never \
      --language=sh \
      --paging=never \
      -- \
      - 2>/dev/null ||
      command -p -- cat \
        -- \
        -
  }
}
alias -- website_troubleshoot='troubleshoot_website'

# wget
wget_download() {
  set \
    -o verbose \
    -o xtrace
  wget_server="${1-}"
  command -v -- wget >/dev/null 2>&1 ||
    return 127

  # either the two files’ [targets] match
  command -p -- test "$(command stat -L -c %d:%i -- "${HOME%/}"'/Code/'"${wget_server-}"'/.https')" = "$(command stat -L -c %d:%i -- "${HOME%/}"'/Sites/'"${wget_server-}")" ||
    # or we create that symlink
    command -p -- ln -f -s "${HOME%/}"'/Code/'"${wget_server-}"'/.https' "${HOME%/}"'/Sites/'"${wget_server-}" ||
    # or we fail
    return 11

  cd -- "${HOME%/}"'/Sites' ||
    return 13

  # user agent
  # https://web.archive.org/web/0id_/developers.google.com/search/blog/2019/10/updating-user-agent-of-googlebot#the-new-evergreen-googlebot-and-its-user-agent
  command wget \
    --adjust-extension \
    --append-output="${wget_server-}"'.log' \
    --continue \
    --convert-links \
    --debug \
    --directory-prefix="${HOME%/}"'/Sites/'"${wget_server-}" \
    --domains="$(command -p -- printf -- '%s' "${1-}" | command -p -- sed -e 's/.*@//' -e 's/https\{0,1\}:\/\///' -e 's/www\.//' -e 's/[:/].*//')" \
    --execute robots=off \
    --force-directories \
    --hsts-file=/dev/null \
    --keep-session-cookies \
    --level=0 \
    --mirror \
    --no-check-certificate \
    --no-host-directories \
    --no-parent \
    --no-robots \
    --page-requisites \
    --progress=bar \
    --random-wait \
    --recursive \
    --referer='https://www.google.com/search' \
    --restrict-file-names=nocontrol \
    --server-response \
    --timestamping \
    --user-agent='Mozilla/5.0 (compatible; Googlebot/2.1; +https://www.google.com/bot.html)' \
    'https://'"${wget_server-}" ||
    return 17
  unset wget_server 2>/dev/null || wget_server=''
  {
    set \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}

which() {
  if builtin which "${@-}" >/dev/null 2>&1; then
    builtin which -a -s -x 2 "${@-}"
  elif command "${HOMEBREW_PREFIX-}"'/bin/which' "${@-}" >/dev/null 2>&1; then
    command "${HOMEBREW_PREFIX-}"'/bin/which' "${@-}"
  elif command '/usr/bin/which' "${@-}" >/dev/null 2>&1; then
    command '/usr/bin/which' "${@-}"
  elif command '/bin/which' "${@-}" >/dev/null 2>&1; then
    command '/bin/which' "${@-}"
  else
    return 1
  fi
}
alias -- all='which -a'

whois() {
  # whois a domain or a URL
  # https://github.com/paulirish/dotfiles/blob/86ab0fa/.functions#L57-L69

  # get domain from URL
  domain="$(
    command -p -- printf -- '%s' "${1-}" |
      command -p -- sed \
        -e 's/.*@//' \
        -e 's/https\{0,1\}:\/\///' \
        -e 's/www\.//' \
        -e 's/[:/].*//'
  )"

  command -p -- test "${domain-}" = '' &&
    domain="${1-}"

  # this is the best whois server
  command whois --host whois.internic.net "${domain-}" |

    # strip boilerplate footer
    command -p -- grep -e '^   '

  unset domain 2>/dev/null || domain=''
}

wikipedia() {
  set -- 'https://lucaslarson.net/wiki/'"${*-}"
  command xdg-open -- "${1-}" 2>/dev/null ||
    command open -- "${1-}"
}

yamllint_r() {
  command -v -- yamllint >/dev/null 2>&1 ||
    { command -v -- brew >/dev/null 2>&1 && command brew install -- yamllint; } ||
    command python -m pip install -- yamllint 2>/dev/null ||
    command python3 -m pip install -- yamllint 2>/dev/null ||
    return "${?:-127}"
  # @TODO: does this find command skip the config files because they’re outside git?
  command find -- \
    "${HOME%/}"'/.config/yamllint/config' \
    "${XDG_CONFIG_HOME-}"'/yamllint/config' \
    . \
    -path '*/.git' -prune -o \
    -path '*/.well-known' -prune -o \
    -path '*/Empty' -prune -o \
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
    -path "${HOME%/}"'/.config/yamllint/config' -o \
    -path "${XDG_CONFIG_HOME-}"'/yamllint/config' -o \
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
    -name '.clangd' -o \
    -name '.gemrc' -o \
    -name '.yamllint' -o \
    -name 'docker_fish_history' -o \
    -name 'fish_history' -o \
    -name 'glide.lock' -o \
    -name 'pixi.lock' -o \
    -name 'yarn.lock' \
    ')' \
    ! -type d \
    -exec sh -c 'for file in "${@-}"; do
  command git ls-files --error-unmatch -- "${file-}" >/dev/null 2>&1 ||
  ! command git -C "${file%/*}" rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
  command yamllint --format colored --strict -- "${file-}"
done' _ {} ';'
}

# YouTube downloader
yt() {
  command -v -- yt-dlp >/dev/null 2>&1 ||
    # EX_UNAVAILABLE
    return 69
  case "${1-}" in
  --video)
    shift &&
      for video in "${@-}"; do
        # removing `--format`/`-f` ensures the best quality video
        command yt-dlp --verbose --console-title --abort-on-error --break-on-existing --restrict-filenames --windows-filenames --no-overwrites --write-annotations --write-thumbnail --audio-quality=0 --keep-video --embed-thumbnail --add-metadata --xattrs --fixup=detect_or_warn -- "${video-}"
      done
    ;;
  *)
    for video in "${@-}"; do
      # try for m4a first
      command yt-dlp --verbose --console-title --abort-on-error --break-on-existing --restrict-filenames --windows-filenames --no-overwrites --write-annotations --write-thumbnail --audio-quality=0 --keep-video --embed-thumbnail --add-metadata --xattrs --fixup=detect_or_warn --format=m4a -- "${video-}" ||
        # if not then try mp3
        command yt-dlp --verbose --console-title --abort-on-error --break-on-existing --restrict-filenames --windows-filenames --no-overwrites --write-annotations --write-thumbnail --audio-quality=0 --keep-video --embed-thumbnail --add-metadata --xattrs --fixup=detect_or_warn --format=mp3 -- "${video-}" ||
        # if not then this mess which changes `--format` into `--list-formats`
        command yt-dlp --verbose --console-title --abort-on-error --break-on-existing --restrict-filenames --windows-filenames --no-overwrites --write-annotations --write-thumbnail --audio-quality=0 --keep-video --embed-thumbnail --add-metadata --xattrs --fixup=detect_or_warn --list-formats -- "${video-}"
    done
    ;;
  esac
}

## zero
# https://stackoverflow.com/a/23259585
# https://github.com/zdharma-continuum/Zsh-100-Commits-Club/blob/1f880d03ec/Zsh-Plugin-Standard.adoc#zero-handling
# @TODO! https://docs.google.com/spreadsheets/d/e/2PACX-1vRmk1GBk-8XwtC6wTek9h63_dpsapDIlnBOK8cEU5vSD-0nN6_Pg7R6LQxYObdqbPYyeTRFqfd3lqDq/pubhtml
zero() {
  {
    command -p -- printf -- '#!/usr/bin/env zsh\n'
    command -p -- printf -- '# https://bit.ly/zshzero\n'
    #                        0="${ZERO:-${${${(M)${0::=${(%):-%x}}:#/*}:-$PWD/$0}:A}}"
    command -p -- printf -- '0="\044{ZERO:-\044{\044{\044{(M)\044{0::=\044{(\045):-\045x}}:#/*}:-\044PWD/\0440}:A}}"\n'
  } | {
    command bat \
      --decorations=never \
      --language=zsh \
      --paging=never \
      -- \
      - 2>/dev/null ||
      command -p -- cat \
        -- \
        -
  }
  # https://github.com/powerline/fonts/blob/74dad88f8b/install.sh#L4
  command -p -- printf -- '%s\n' "$(
    cd -- "$(
      command -p -- dirname -- "${1-}"
    )" &&
      command -p -- pwd
  )"
}

zsh_make_zsh() {
  # sed -e 's/[",]//g;s/enable-etcdir.*/disable-etcdir/g;s/\#{HOMEBREW_PREFIX}\(.*\)/"\$\{HOME%\/\}"'\''\/.local\1'\''/g;s/\#{pkgshare}\(.*\)/"\$\{HOME%\/\}"'\''\/.local\/share\1'\''/g;s/\#{prefix}\(.*\)/"\$\{HOME%\/\}"'\''\/.local\1'\''/g;s/^\([[:space:]]*\)system[[:space:]]*/\1/' ~/c/Homebrew-core/Formula/zsh.rb
  cd -- "${HOME%/}"'/c/zsh' ||
    return "${?:-1}"
  command -p -- rm -f -r -- "${HOME%/}"'/c/zsh/.gitignore'
  (
    set \
      -o verbose \
      -o xtrace
    ./Util/preconfig &&
      command -p -- make configure &&
      # CC='c99' ./configure \
      CC='clang' ./configure \
        --disable-etcdir \
        --enable-cap \
        --enable-cflags=-O0 \
        --enable-fndir="${HOME%/}"'/.local/share/functions' \
        --enable-libs \
        --enable-multibyte \
        --enable-pcre \
        --enable-runhelpdir="${HOME%/}"'/.local/share/help' \
        --enable-scriptdir="${HOME%/}"'/.local/share/scripts' \
        --enable-site-fndir="${HOME%/}"'/.local/share/zsh/site-functions' \
        --enable-site-scriptdir="${HOME%/}"'/.local/share/zsh/site-scripts' \
        --enable-unicode9 \
        --enable-zsh-debug \
        --enable-zsh-hash-debug \
        --enable-zsh-mem \
        --enable-zsh-mem-debug \
        --enable-zsh-mem-warning \
        --enable-zsh-secure-free \
        --prefix="${HOME%/}"'/.local' \
        --with-tcsetpgrp \
        DL_EXT=bundle &&
      ./config.status --recheck &&
      command -p -- make \
        CFLAGS='-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include -Wno-implicit-function-declaration' \
        CPATH='/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include:/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include' \
        CPLUS_INCLUDE_PATH='/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include' \
        CPPFLAGS='-I/usr/local/opt/llvm/include -I/usr/local/opt/libarchive/include -I/usr/local/opt/openssl/include -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include -I/usr/local/opt/ruby/include' \
        CXXFLAGS='-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include' \
        LDFLAGS='-L/usr/local/opt/llvm/lib/c++ -Wl,-rpath,/usr/local/opt/llvm/lib/c++ -L/usr/local/opt/llvm/lib -L/usr/local/opt/libarchive/lib -L/usr/local/opt/openssl/lib -L/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib -L/usr/local/opt/ruby/lib' \
        LIBRARY_PATH='/usr/local/lib:/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib' \
        LIBS='-l/usr/local/lib -l/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib' \
        PKG_CONFIG_PATH='/usr/local/opt/libarchive/lib/pkgconfig:/usr/local/opt/openssl/lib/pkgconfig' &&
      command -p -- make check &&
      command -p -- make install &&
      command -p -- make install.modules &&
      command -p -- make install.fns
  )
}

ohmyzsh() {
  cd -- "${ZSH:-${HOME%/}/.oh-my-zsh}" ||
    return 1
  {
    command -v -- l >/dev/null 2>&1 &&
      l
  } ||
    command -p -- ls -A -F -g -o
  command git -c color.status=always -c core.quotePath=false status --untracked-files=no 2>/dev/null |
    command -p -- sed \
      -e '$ d'
}

zshabbr() {
  set \
    -o noglob \
    -o verbose \
    -o xtrace
  if command -p -- test -s "${ABBR_USER_ABBREVIATIONS_FILE-}"; then
    target="${ABBR_USER_ABBREVIATIONS_FILE-}"
  elif command -p -- test -s "${XDG_CONFIG_HOME-}"'/zsh-abbr/user-abbreviations'; then
    target="${XDG_CONFIG_HOME-}"'/zsh-abbr/user-abbreviations'
  elif command -p -- test -s "${XDG_CONFIG_HOME-}"'/zsh/abbreviations'; then
    target="${XDG_CONFIG_HOME-}"'/zsh/abbreviations'
  else
    # EX_NOINPUT
    return 66
  fi
  command "${EDITOR:-vi}" -- "${target-}" &&
    command shfmt --indent 2 --language-dialect bash --simplify --write -- "${target-}" &&
    abbr load
  unset target 2>/dev/null || target=''
  {
    set \
      +o noglob \
      +o verbose \
      +o xtrace
  } 2>/dev/null
}
alias -- \
  zshenv='command "${EDITOR:-vi}" -- "${ZDOTDIR:-${HOME%/}}"/."$(command -p -- basename -- "${SHELL%%[0-9-]*}")"env && exec - "${SHELL##*/}"' \
  zlogin='command "${EDITOR:-vi}" -- "${ZDOTDIR:-${HOME%/}}"'\''/.'\''"$(command -p -- printf -- '\''%.1slogin'\'' "${SHELL##*/}")" && exec - "${SHELL##*/}"' \
  zlogout='command "${EDITOR:-vi}" -- "${ZDOTDIR:-${HOME%/}}"'\''/.'\''"$(command -p -- printf -- '\''%.1slogout'\'' "${SHELL##*/}")" && exec - "${SHELL##*/}"' \
  zlogout='command "${EDITOR:-vi}" -- "${ZDOTDIR:-${HOME%/}}"'\''/.'\''"$(command -p -- printf -- '\''%.1slogout'\'' "${SHELL##*/}")" && exec - "${SHELL##*/}"' \
  zprofile='command "${EDITOR:-vi}" -- "${ZDOTDIR:-${HOME%/}}"'\''/.'\''"$(command -p -- printf -- '\''%.1sprofile'\'' "${SHELL##*/}")" && exec - "${SHELL##*/}"' \
  zshrc='command "${EDITOR:-vi}" -- "${ZDOTDIR:-${HOME%/}}"'\''/.'\''"$(command -p -- basename -- "${SHELL%%[0-9-]*}")"'\''rc'\'' && exec - "${SHELL##*/}"' \
  z='. "${ZDOTDIR:-${HOME%/}}"'\''/.'\''"$(command -p -- basename -- "${SHELL%%[0-9-]*}")"'\''rc'\''' \
  zshdebug='( builtin emulate -R zsh -C -v -x -c '\''. "${ZDOTDIR:-${HOME%/}}"'\''/.'\''"$(command -p -- basename -- "${SHELL%%[0-9-]*}")"'\''rc'\'';'\''; );' \
  zshdebug_rc='( builtin emulate -R zsh -C -v -x -c '\''zmodload zsh/zprof; . "${ZDOTDIR:-${HOME%/}}"'\''/.'\''"$(command -p -- basename -- "${SHELL%%[0-9-]*}")"rc; zprof;'\''; );' \
  zshdebug_env='( builtin emulate -R zsh -C -v -x -c '\''zmodload zsh/zprof; . "${ZDOTDIR:-${HOME%/}}"'\''/.'\''"$(command -p -- basename -- "${SHELL%%[0-9-]*}")"env; zprof;'\''; );'

# history recovery
# https://unix.stackexchange.com/a/551083
zsh_history_recovery() {
  reset="$(
    set +o
  )"
  set \
    -o noclobber \
    -o verbose \
    -o xtrace
  builtin fc -W "${1:-./.zsh_history_recovery_$(command -p -- date -- '+%Y%m%d_%H%M%S')}"
  builtin eval " ${reset-}"
  {
    set \
      +o noclobber \
      +o verbose \
      +o xtrace
  } 2>/dev/null
  unset reset 2>/dev/null || reset=''
}
alias -- \
  history_restore='zsh_history_recovery' \
  restore_history='zsh_history_recovery'

## zero-width space
# copy to macOS clipboard
alias -- \
  zwsp='command -p -- printf -- '\''​'\'' | command pbcopy' \
  shrug='command -p -- printf -- '\''\302\257\134_(\343\203\204)_/\302\257'\'' | command -p -- pbcopy && command -p -- printf -- '\''\302\257\134_(\343\203\204)_/\302\257\n'\''' \
  sparkle='command -p -- printf -- '\''\342\234\250'\'' | command pbcopy && command -p -- printf -- '\''\342\234\250\n'\'''

## Zsh options after everything else while testing ~/c/soak/git-trap 2024-03
set_o="$(set +o)" &&
  export set_o &&
  set_hyphen="${--}" &&
  export set_hyphen
