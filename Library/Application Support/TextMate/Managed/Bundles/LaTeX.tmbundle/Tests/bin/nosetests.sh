#!/usr/bin/env bash

# ------------------------------------------------------------------------------
#           Run nose tests for all Python commands
# ------------------------------------------------------------------------------

export PATH=/Library/TeX/texbin:$PATH
nosetests --with-doctest Support/lib/Python/*.py Support/bin/*.py
