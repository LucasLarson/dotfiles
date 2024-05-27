#!/usr/bin/env zsh

## Powerlevel10k
# shellcheck disable=SC1090
. "${XDG_CACHE_HOME:-${HOME%/}/.cache}"'/p10k-instant-prompt-'"${LOGNAME:-${USER-}}"'.zsh' 2>/dev/null

## PATH
PATH="$(command -p -- getconf -- PATH)${PATH:+:${PATH-}}"
test -d '/usr/local/sbin' &&
  PATH='/usr/local/sbin'"${PATH:+:${PATH-}}"
test -d '/usr/local/bin' &&
  PATH='/usr/local/bin'"${PATH:+:${PATH-}}"
test -d "${HOME%/}"'/bin' &&
  PATH="${HOME%/}"'/bin'"${PATH:+:${PATH-}}"
test -d "${HOME%/}"'/.local/bin' &&
  PATH="${HOME%/}"'/.local/bin'"${PATH:+:${PATH-}}"
test -d "${DOTFILES-}"'/bin' &&
  PATH="${DOTFILES-}"'/bin'"${PATH:+:${PATH-}}"

## Plugin manager
test -d "${HOME%/}"'/.oh-my-zsh' &&
  export ZSH="${HOME%/}"'/.oh-my-zsh'

## Theme
if test -r "${ZSH_CUSTOM-}"'/themes/powerlevel10k/powerlevel10k.zsh-theme' &&
  {
    test "$(command uname)" = 'Darwin' ||
      test "$((COLUMNS * LINES))" -gt "$((80 * 24))"
  }; then
  . "${ZSH_CUSTOM-}"'/themes/powerlevel10k/powerlevel10k.zsh-theme'
  export ZSH_THEME='powerlevel10k/powerlevel10k'
fi

## History size
SAVEHIST="$(printf -- '2 ^ 32 - 1\n' | command bc)"
HISTSIZE="$((SAVEHIST / 2))"
export SAVEHIST HISTSIZE

## zsh compdump
export ZSH_COMPDUMP="${HOME%/}"'/.zcompdump'

## Plugins
plugins+=(
  gunstage
  git-default-branch
  zsh-abbr
  zsh-diff-so-fancy
  zsh-autosuggestions
)

# plugin: fast-syntax-highlighting
plugins+=(
  fast-syntax-highlighting
)
# plugin: zsh-history-substring-search
plugins+=(
  zsh-history-substring-search
) && {
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down
}

## Options
set -o always_to_end
set -o complete_in_word
set +o flow_control
set -o autocd
set -o extended_history
set -o hist_ignore_dups
set -o hist_ignore_space
set -o histverify

## shell navigation without the mouse
bindkey '^?' backward-delete-char
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[Z' reverse-menu-complete

## Oh My Zsh
. "${ZSH-}"'/oh-my-zsh.sh'
for file in "${ZSH_CUSTOM-}"/plugins/**/*.plugin.*sh; do
  . "${file-}" 2>/dev/null &&
    FPATH="${FPATH:+${FPATH-}:}${file%/*}"
done
unset -v -- file
for file in "${ZSH_CUSTOM-}"/*sh; do
  . "${file-}"
done
unset -v -- file

## MANPATH
test -d '/usr/local/man' &&
  MANPATH='/usr/local/man'"${MANPATH:+:${MANPATH-}}"
test -d '/usr/share/man' &&
  MANPATH='/usr/share/man'"${MANPATH:+:${MANPATH-}}"
command man -w >/dev/null 2>&1 &&
  MANPATH="${MANPATH:+${MANPATH-}:}$(command man -w)"

## EDITOR
EDITOR="$(
  command -v -- nvim ||
    command -v -- vim ||
    command -v -- vi
)"
if test "${EDITOR-}" != ''; then
  export EDITOR
  alias e='command "${EDITOR:-vi}"'
  export VISUAL="${VISUAL:-${EDITOR:-vi}}"
fi

## Homebrew
if command -v -- brew >/dev/null 2>&1; then
  HOMEBREW_PREFIX="$(command brew --prefix)"
  test -d "${HOMEBREW_PREFIX-}"'/sbin' &&
    PATH="${HOMEBREW_PREFIX-}"'/sbin'"${PATH:+:${PATH-}}"

  # GNU bc
  test -d "${HOMEBREW_PREFIX-}"'/opt/bc/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/bc/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/bc/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/bc/share/man'"${MANPATH:+:${MANPATH-}}"

  # uutils coreutils
  test -d "${HOMEBREW_PREFIX-}"'/opt/uutils-coreutils/libexec/uubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/uutils-coreutils/libexec/uubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/uutils-coreutils/libexec/uuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/uutils-coreutils/libexec/uuman'"${MANPATH:+:${MANPATH-}}"

  # curl
  test -d "${HOMEBREW_PREFIX-}"'/opt/curl/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/curl/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/curl/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/curl/share/man'"${MANPATH:+:${MANPATH-}}"

  # file
  test -d "${HOMEBREW_PREFIX-}"'/opt/file/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/file/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/file/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/file/share/man'"${MANPATH:+:${MANPATH-}}"

  # GNU findutils
  test -d "${HOMEBREW_PREFIX-}"'/opt/findutils/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/findutils/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/findutils/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/findutils/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"

  # GNU grep
  test -d "${HOMEBREW_PREFIX-}"'/opt/grep/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/grep/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/grep/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/grep/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"

  # libarchive
  test -d "${HOMEBREW_PREFIX-}"'/opt/libarchive/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/libarchive/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/libarchive/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/libarchive/share/man'"${MANPATH:+:${MANPATH-}}"

  # GNU make
  test -d "${HOMEBREW_PREFIX-}"'/opt/make/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/make/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/make/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/make/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"

  # openssl
  test -d "${HOMEBREW_PREFIX-}"'/opt/openssl/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/openssl/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/openssl/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/openssl/share/man'"${MANPATH:+:${MANPATH-}}"
  export LDFLAGS="${LDFLAGS:+${LDFLAGS-} }"'-L'"${HOMEBREW_PREFIX-}"'/opt/openssl/lib'
  export CPPFLAGS="${CPPFLAGS:+${CPPFLAGS-} }"'-I'"${HOMEBREW_PREFIX-}"'/opt/openssl/include'
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH:+${PKG_CONFIG_PATH-}:}${HOMEBREW_PREFIX-}"'/opt/openssl/lib/pkgconfig'

  # GNU sed
  test -d "${HOMEBREW_PREFIX-}"'/opt/gnu-sed/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/gnu-sed/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/gnu-sed/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/gnu-sed/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"

  # GNU tar
  # otherwise `tar` requires `tar --no-mac-metadata`
  test -d "${HOMEBREW_PREFIX-}"'/opt/gnu-tar/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/gnu-tar/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/gnu-tar/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/gnu-tar/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"
fi

## Rust
test -d "${HOME%/}"'/.cargo/bin' &&
  PATH="${HOME%/}"'/.cargo/bin'"${PATH:+:${PATH-}}"

## npm
NPM_PACKAGES="${HOME%/}"'/.npm-packages'
test -d "${NPM_PACKAGES-}"'/bin' &&
  PATH="${PATH:+${PATH-}:}${NPM_PACKAGES-}"'/bin'
test -d "${NPM_PACKAGES-}"'/share/man' &&
  MANPATH="${MANPATH:+${MANPATH-}:}${NPM_PACKAGES-}"'/share/man'

# include hidden files in tab completion
set -o dotglob
zstyle ':completion:*' special-dirs false
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %B%F"{green}"%d%f%b

## plugin: zsh-completions
test -d "${ZSH_CUSTOM-}"'/plugins/zsh-completions/src' &&
  FPATH="${FPATH:+${FPATH-}:}${ZSH_CUSTOM-}"'/plugins/zsh-completions/src'

autoload -U compinit &&
  compinit

# share all commands from everywhere
set -o share_history
# permit inline comments
set -o interactive_comments

## C, C++
if test "$(command xcrun --show-sdk-path 2>/dev/null)" != ''; then
  CPATH="$(command xcrun --show-sdk-path)"'/usr/include'"${CPATH:+:${CPATH-}}"
  export CPATH
fi

## cpplint
# `$LIBRARY_PATH` || ld: library not found for -lSystem
if test -d '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib'; then
  LIBRARY_PATH='/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib'"${LIBRARY_PATH:+:${LIBRARY_PATH-}}"
  export LIBRARY_PATH
fi

## Go
test "${GOPATH-}" != '' &&
  test -d "${GOPATH-}"'/bin' &&
  PATH="${GOPATH-}"'/bin'"${PATH:+:${PATH-}}"

## rbenv
test -d "${HOME%/}"'/.rbenv/shims' &&
  PATH="${HOME%/}"'/.rbenv/shims'"${PATH:+:${PATH-}}"
rbenv() {
  eval " $(command rbenv init - --no-rehash "${SHELL##*[-./]}")"
  rbenv "$@"
}

## PATHs
# prevent duplicate entries
test "${ZSH-}" != '' &&
  export -U \
    PATH path \
    CDPATH cdpath \
    FPATH fpath \
    MANPATH manpath

## Powerlevel10k
test "${ZSH_THEME-}" = 'powerlevel10k/powerlevel10k' &&
  . "${HOME%/}"'/.p10k.zsh'
