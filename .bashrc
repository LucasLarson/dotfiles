#!/usr/bin/env bash

test -r "${HOME-}"'/.'"${SHELL##*[-./]}"'env' &&
  . "${HOME-}"'/.'"${SHELL##*[-./]}"'env'
