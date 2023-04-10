#!/usr/bin/env bash

## Locale
export LC_ALL="${LC_ALL:=en_US.UTF-8}"

## Bash completions
{
  # shellcheck disable=1090
  . '/etc/profile.d/bash_completion.sh'
  . '/usr/local/etc/profile.d/bash_completion.sh'
  . '/opt/local/etc/profile.d/bash_completion.sh'
} 2>/dev/null

## Bashhub
# shellcheck disable=1091
. "${HOME%/}"'/.bashhub/bashhub.sh' 2>/dev/null
