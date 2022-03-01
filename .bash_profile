#!/usr/bin/env bash

# Tidy for Mac OS X by balthisar.com is adding the new path for Tidy.
export PATH=/usr/local/bin:$PATH

## Bashhub
# this should be EOF
# https://bashhub.com/docs
test -r "${HOME-}"'/.bashhub/bashhub.sh' &&
  . "${HOME-}"'/.bashhub/bashhub.sh'
