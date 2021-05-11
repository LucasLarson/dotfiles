#!/usr/bin/env zsh

# XDG
# https://specifications.freedesktop.org/basedir-spec/0.7/ar01s03.html
export XDG_DATA_HOME=${XDG_DATA_HOME:=${HOME}/.local/share}
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:=${HOME}/.config}
export XDG_DATA_DIRS=${XDG_DATA_DIRS:=/usr/local/share/:/usr/share/}
export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:=/etc/xdg}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:=${HOME}/.cache}
