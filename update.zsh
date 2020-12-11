#!/usr/bin/env zsh

update=1
clear && clear


printf '                 .___       __\n'
printf ' __ ________   __\x7c _\x2f____ _\x2f  \x7c_  ____\n'
printf '\x7c  \x7c  \x5c____ \x5c \x2f __ \x7c\x5c__  \x5c\x5c   __\x5c\x2f __ \x5c\n'
printf '\x7c  \x7c  \x2f  \x7c_\x3e \x3e \x2f_\x2f \x7c \x2f __ \x5c\x7c  \x7c \x5c  ___\x2f\n'
printf '\x7c____\x2f\x7c   __\x2f\x5c____ \x7c\x28____  \x2f__\x7c  \x5c___  \x3e\n'
printf '      \x7c__\x7c        \x5c\x2f     \x5c\x2f          \x5c\x2f\n'
printf ' a Lucas Larson production\n\n'

sleep 1.0


# Homebrew
if command -v brew >/dev/null 2>&1; then
  printf '\xf0\x9f\x8d\xba checking for Homebrew updates...\n'
  brew update
  brew upgrade
  brew upgrade --cask
fi  # brew


# Xcode
if command -v xcrun >/dev/null 2>&1; then
  xcrun simctl delete unavailable
fi  # xcrun


# Rust
if command -v rustup >/dev/null 2>&1; then
  rustup update
fi  # rustup


# Atom
if command -v apm >/dev/null 2>&1; then
  apm upgrade --no-confirm
fi  # apm


if [ Darwin = "$(uname)" ]; then

  printf '\n\xf0\x9f\x93\xa1 verifying network connectivity...\n'
  sleep 0.5
  (
    ping -q -i1 -c1 one.one.one.one &>/dev/null && ping -q -i1 -c1 8.8.8.8 &>/dev/null
  ) || (
    printf 'No internet connection was detected.\nAborting update.\n' && return "${update}"
  )


  npm install npm --global
  npm update --global --verbose


  gem update --system
  gem update
  rbenv rehash

  if command -v pip3 >/dev/null 2>&1; then
    printf '\n\xf0\x9f\x90\x8d verifying Python\xe2\x80\x99s packager is up to date...\n'
    python3 -m pip install --upgrade pip

    printf '\n\xf0\x9f\x90\x8d generating list of outdated Python packages...\n'
    pip3 list --outdated --format freeze | grep -v '^\-e' | cut --delimiter = --fields 1 | xargs -n1 pip3 install --upgrade

    printf '\n\xf0\x9f\x90\x8d upgrading all Python packages...\n'
    pip3 install --upgrade $(pip3 freeze | cut --delimiter '=' --fields 1)
  fi  # pip3

  command -v pyenv >/dev/null 2>&1 && pyenv rehash


elif [ Linux = "$(uname)" ]; then


  sleep 1.0

  printf '\n\xf0\x9f\x93\xa1 verifying network connectivity'

  sleep 0.5

  (
    ping -q -i1 -c1 one.one.one.one &>/dev/null
    ping -q -i1 -c1 8.8.8.8 &>/dev/null
  ) || (
    printf '\n\nNo internet connection was detected.\nAborting update.\n' && return "${update}"
  )

  for (( i = 0; i < 1024; i++ )) do
    if (( (i / 3) % 2 == 0 )); then
      printf '.'
    else
      printf '\b'
    fi
  done

  printf '\n\n'

  ping -q -w1 -c1 one.one.one.one &>/dev/null

  ping -q -w1 -c1 8.8.8.8 &>/dev/null

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
  fi  # apk

  if command -v pip3 >/dev/null 2>&1; then
    printf '\n\xf0\x9f\x90\x8d verifying Python\xe2\x80\x99s packager is up to date...\n'
    pip3 install --upgrade pip

    printf '\n\xf0\x9f\x90\x8d upgrading all Python packages...\n'
    pip3 install --upgrade $(pip3 freeze | cut --delimiter '=' --fields 1)
  fi  # pip3

fi  # Linux

omz update


. "${HOME}/.${SHELL##*/}rc" && rehash


unset update
printf '\n\n\xe2%s\x9c\x85 done\x21\n\n' "${update}"


exec "${SHELL##*/}" --login
