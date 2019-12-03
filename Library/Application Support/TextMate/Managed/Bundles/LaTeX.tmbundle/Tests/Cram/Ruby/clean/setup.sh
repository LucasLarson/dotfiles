#!/usr/bin/env sh

# -- Variables -----------------------------------------------------------------

export BUNDLE_DIRECTORY="`cd "${TESTDIR}/../../../../";pwd`";
export PATH=$PATH:/Library/TeX/texbin:${BUNDLE_DIRECTORY}/Support/bin/
export TEX_DIRECTORY="${BUNDLE_DIRECTORY}/Tests/TeX"
