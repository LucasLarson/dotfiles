#!/usr/bin/env zsh

## Powerlevel10k
# shellcheck disable=SC1090
. "${XDG_CACHE_HOME:-${HOME%/}/.cache}"'/p10k-instant-prompt-'"${USER-}"'.zsh' 2>/dev/null
# shellcheck disable=SC1091
. "${DOTFILES-}"'/custom/themes/powerlevel10k/powerlevel10k.zsh-theme' 2>/dev/null &&
  export ZSH_THEME='powerlevel10k/powerlevel10k'

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

## History
HISTFILE="${HOME%/}"'/.'"${SHELL##*/}"'_history'
SAVEHIST="$(command getconf -- UINT_MAX)"
HISTSIZE="${SAVEHIST-}"
export HISTFILE SAVEHIST HISTSIZE

## zsh compdump
export ZSH_COMPDUMP="${HOME%/}"'/.zcompdump'

## Plugins
PLUGINS='gunstage:samefile:git-default-branch:zsh-abbr:zsh-diff-so-fancy:zsh-autosuggestions'"${PLUGINS:+:${PLUGINS-}}"
# plugin: fast-syntax-highlighting
PLUGINS='fast-syntax-highlighting'"${PLUGINS:+:${PLUGINS-}}"
# plugin: zsh-history-substring-search
PLUGINS='zsh-history-substring-search'"${PLUGINS:+:${PLUGINS-}}" && {
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down
}
export PLUGINS

## Keyboard shortcuts
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
export EDITOR
alias e='command "${EDITOR-}"'
export VISUAL="${VISUAL:-${EDITOR-}}"

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

  # curl
  test -d "${HOMEBREW_PREFIX-}"'/opt/curl/bin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/curl/bin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/curl/share/man' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/curl/share/man'"${MANPATH:+:${MANPATH-}}"

  # GNU coreutils
  test -d "${HOMEBREW_PREFIX-}"'/opt/coreutils/libexec/gnubin' &&
    PATH="${HOMEBREW_PREFIX-}"'/opt/coreutils/libexec/gnubin'"${PATH:+:${PATH-}}"
  test -d "${HOMEBREW_PREFIX-}"'/opt/coreutils/libexec/gnuman' &&
    MANPATH="${HOMEBREW_PREFIX-}"'/opt/coreutils/libexec/gnuman'"${MANPATH:+:${MANPATH-}}"

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

  ## Node
  # version 16 at head of `PATH` to support GitHub Copilot
  test -d "${HOMEBREW_PREFIX-}"'/opt/node@16/bin' &&
    PATH='/usr/local/opt/node@16/bin'"${PATH:+:${PATH-}}" &&
    MANPATH='/usr/local/opt/node@16/share/man'"${MANPATH:+:${MANPATH-}}" &&
    export LDFLAGS="${LDFLAGS:+${LDFLAGS-} }"'-L'"${HOMEBREW_PREFIX-}"'/opt/node@16/lib' &&
    export CPPFLAGS="${CPPFLAGS:+${CPPFLAGS-} }"'-I'"${HOMEBREW_PREFIX-}"'/opt/node@16/include'

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
fi

## Rust
test -d "${HOME%/}"'/.cargo/bin' &&
  PATH="${HOME%/}"'/.cargo/bin'"${PATH:+:${PATH-}}"

## Bashhub
. "${HOME%/}"'/.bashhub/bashhub.'"${SHELL##*[-./]}" 2>/dev/null

## npm
NPM_PACKAGES="${HOME%/}"'/.npm-packages'
test -d "${NPM_PACKAGES-}"'/bin' &&
  PATH="${PATH:+${PATH-}:}${NPM_PACKAGES-}"'/bin'
test -d "${NPM_PACKAGES-}"'/share/man' &&
  MANPATH="${MANPATH:+${MANPATH-}:}${NPM_PACKAGES-}"'/share/man'

zstyle ':completion:*' special-dirs false
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %B%F"{green}"%d%f%b

## plugin: zsh-completions
test -d "${ZSH_CUSTOM-}"'/plugins/zsh-completions/src' &&
  FPATH="${FPATH:+${FPATH-}:}${ZSH_CUSTOM-}"'/plugins/zsh-completions/src'

autoload -U compinit &&
  compinit

## Options
set -o always_to_end
set -o complete_in_word
set +o flow_control
set -o autocd
set -o hist_ignore_dups
set -o hist_ignore_space
set -o histverify
# include hidden files in tab completion
set -o dotglob
# share all commands from everywhere
set -o share_history
# permit inline comments
set -o interactive_comments

## C, C++
if test -n "$(command xcrun --show-sdk-path 2>/dev/null)"; then
  CPATH="$(command xcrun --show-sdk-path)"'/usr/include'"${CPATH:+:${CPATH-}}"
  export CPATH
fi

## cpplint
# `$LIBRARY_PATH` || ld: library not found for -lSystem
if test -d '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib'; then
  export LIBRARY_PATH='/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib'"${LIBRARY_PATH:+:${LIBRARY_PATH-}}"
fi

## Go
test -n "${GOPATH-}" &&
  test -d "${GOPATH-}"'/bin' &&
  PATH="${GOPATH-}"'/bin'"${PATH:+:${PATH-}}"

## rbenv
test -d "${HOME%/}"'/.rbenv/shims' &&
  PATH="${HOME%/}"'/.rbenv/shims'"${PATH:+:${PATH-}}"

## PATHs
# prevent duplicate entries
test -n "${ZSH-}" &&
  export -U \
    PATH path \
    CDPATH cdpath \
    FPATH fpath \
    MANPATH manpath

## Powerlevel10k
. "${HOME%/}"'/.p10k.zsh' 2>/dev/null
