#!/usr/bin/env bash

## Locale
# https://github.com/fastlane/docs/commit/f0b8da3fbf
# https://unix.stackexchange.com/a/576706
export LC_ALL="${LC_ALL:=en_US.UTF-8}"

## Bash completions
for file in \
  '/etc/profile.d/bash_completion.sh' \
  '/usr/local/etc/profile.d/bash_completion.sh' \
  '/opt/local/etc/profile.d/bash_completion.sh'; do
  # shellcheck disable=SC1090
  test -r "${file-}" &&
    . "${file-}"
done

## Bashhub
# this should be EOF
# https://bashhub.com/docs
test -r "${HOME%/}"'/.bashhub/bashhub.sh' &&
  . "${HOME%/}"'/.bashhub/bashhub.sh'
