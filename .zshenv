#!/usr/bin/env sh

## Dotfiles and templates
command mkdir -p -- "${HOME%/}"'/Library/CloudStorage/Dropbox/dotfiles' &&
  export DOTFILES="${HOME%/}"'/Library/CloudStorage/Dropbox/dotfiles' &&
  command mkdir -p -- "${DOTFILES-}"'/custom' &&
  export ZSH_CUSTOM="${DOTFILES-}"'/custom' &&
  export custom="${DOTFILES-}"'/custom' &&
  command mkdir -p -- "${DOTFILES-}"'/../Template' &&
  export TEMPLATE="${DOTFILES-}"'/../Template' &&
  command mkdir -p -- "${DOTFILES-}"'/../Default' &&
  export DEFAULT="${DOTFILES-}"'/../Default'

## XDG
# https://specifications.freedesktop.org/basedir-spec/0.7/ar01s03.html
command mkdir -p -- "${HOME%/}"'/.local/share' &&
  export XDG_DATA_HOME="${HOME%/}"'/.local/share'
command mkdir -p -- "${HOME%/}"'/.config' &&
  export XDG_CONFIG_HOME="${HOME%/}"'/.config'
command mkdir -p -- "${HOME%/}"'/.local/state' &&
  export XDG_STATE_HOME="${HOME%/}"'/.local/state'
command mkdir -p -- '/usr/local/share' &&
  export XDG_DATA_DIRS="${XDG_DATA_DIRS:+${XDG_DATA_DIRS-}:}"'/usr/local/share'
command mkdir -p -- '/usr/share' &&
  # this trailing slash is prescribed
  export XDG_DATA_DIRS="${XDG_DATA_DIRS:+${XDG_DATA_DIRS-}:}"'/usr/share/'
command mkdir -p -- '/etc/xdg' &&
  export XDG_CONFIG_DIRS='/etc/xdg'
command mkdir -p -- "${HOME%/}"'/.cache' &&
  export XDG_CACHE_HOME="${HOME%/}"'/.cache' &&
  command touch -- "${XDG_CACHE_HOME-}"'/p10k-instant-prompt-'"${LOGNAME:-${USER-}}"'.zsh'

# `XDG_RUNTIME_DIR` has no default and requires `700` permissions
command mkdir -p -- "${TMPDIR:-/tmp}"'/xdg_runtime_dir-'"${LOGNAME:-${USER-}}" &&
  command chmod -- 700 "${TMPDIR:-/tmp}"'/xdg_runtime_dir-'"${LOGNAME:-${USER-}}" &&
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:=${TMPDIR:-/tmp}/xdg_runtime_dir-${LOGNAME:-${USER-}}}"

## $CDPATH
export CDPATH="${CDPATH:+${CDPATH-}:}${HOME%/}"

## Git
export GIT_MERGE_VERBOSITY=4

## GitHub
export GITHUB_ORG="${LOGNAME:-${USER-}}"

## GitLab
# for `gitlab_create_repository`
export GITLAB_USERNAME="${LOGNAME:-${USER-}}"

## Go
export GOPATH="${HOME%/}"'/.go'

## iCloud
test -d "${HOME%/}"'/Library/Mobile Documents' &&
  export ICLOUD="${HOME%/}"'/Library/Mobile Documents'

## Input Field Separators
# https://unix.stackexchange.com/a/220658
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_05_03
IFS="$(printf -- ' \t\n|')" &&
  export IFS="${IFS%'|'}"

## Locale
export LC_ALL='en_US.UTF-8'

## PAGER
export PAGER='less --file-size --ignore-case'
export MANPAGER="${PAGER-}"

## POSIX
# activated when set to any value (even empty)
# https://gnu.org/s/autoconf/manual/autoconf#index-POSIXLY_005fCORRECT
export POSIXLY_CORRECT="${POSIXLY_CORRECT:-1}"

## Rust
# https://github.com/mkrasnitski/git-power-rs/tree/2fc2906#installing
export CARGO_HOME="${HOME%/}"'/.cargo'

## SSH, GPG
command -p -- find -- \
  "${DOTFILES-}"'/.gnupg' \
  "${DOTFILES-}"'/.ssh' \
  "${HOME%/}"'/.gnupg' \
  "${HOME%/}"'/.ssh' \
  -path "${DOTFILES-}"'/.gnupg/*' -prune -o \
  -path "${DOTFILES-}"'/.ssh/*' -prune -o \
  -path "${HOME%/}"'/.gnupg/*' -prune -o \
  -path "${HOME%/}"'/.ssh/*' -prune -o \
  -type d \
  -print 2>/dev/null | while IFS='' read -r -- directory; do
  command -p -- find -- "${directory-}" \
    -type f \
    -exec chmod -- 600 {} +
  command -p -- find -- "${directory-}" \
    -name '*.pub' \
    -type f \
    -exec chmod -- 644 {} +
  command -p -- find -- "${directory-}" \
    -type d \
    -exec chmod -- 700 {} +
done
# GPG
export GPG_TTY="${TTY-}"

## private
# shellcheck disable=SC1091
command touch -- "${HOME%/}"'/.env' &&
  command chmod -- 400 "${HOME%/}"'/.env' &&
  . "${HOME%/}"'/.env'
