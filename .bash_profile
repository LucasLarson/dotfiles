#!/usr/bin/env bash

## Locale
export LC_ALL="${LC_ALL:=en_US.UTF-8}"

## Bash completions
{
  . '/etc/profile.d/bash_completion.sh'
  . '/usr/local/etc/profile.d/bash_completion.sh'
  . '/opt/local/etc/profile.d/bash_completion.sh'
} 2>/dev/null

## Bashhub
. "${HOME-}"'/.bashhub/bashhub.sh' 2>/dev/null
