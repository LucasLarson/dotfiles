#!/usr/bin/env bash

# ------------------------------------------------------------------------------
#           Run cram tests for all Python commands
#
# This script will be called by `tox` to test the bundle commands written in
# Python using different versions of `python`.
# ------------------------------------------------------------------------------

find Tests/Cram/Python -name '*.t' -type f -exec cram '{}' +
