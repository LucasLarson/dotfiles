#!/usr/bin/env bash

# ensure `/usr/local/bin` is in `PATH`
test -d '/usr/local/bin' &&
  export PATH="/usr/local/bin:${PATH:+:${PATH-}}"

## Bashhub
# this should be EOF
# https://bashhub.com/docs
test -r "${HOME-}"'/.bashhub/bashhub.sh' &&
  . "${HOME-}"'/.bashhub/bashhub.sh'
