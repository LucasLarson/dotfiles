#!/usr/bin/env bash

# redo as root — repeat the previous command with sudo
# https://meyerweb.com/eric/thoughts/2020/09/29/polite-bash-commands/#comment-3717745
# https://twitter.com/liamosaur/status/506975850596536320
please () {
  cmd=$(fc -ln -1)
  cmd="sudo ${cmd#*  }"
  printf '%s' "${cmd}"

  # Append the sudo-ed command to this shell's history, so that the Up arrow
  # can be used to find it, rather than just the rr command. Weirdly this seems
  # to cause rr itself not to end up in the history, which is an unexpected
  # bonus:
  history -s "${cmd}"

  # The quotes are needed to preserve any quotes in $cmd, and eval to parse
  # them:
  eval "${cmd}"
}
