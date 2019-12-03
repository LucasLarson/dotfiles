#!/usr/bin/env sh

# -----------------------------------------------------------------------------
# This script setups common variables and aliases for cram tests.
# -----------------------------------------------------------------------------

# -- Variables ----------------------------------------------------------------

BUNDLE_DIR="$TESTDIR/../../.."
TM_BUNDLE_DIR="$HOME/Library/Application Support/TextMate/Managed/Bundles"
PYTHON_GRAMMAR_DIR="${TM_BUNDLE_DIR}/Python.tmbundle/Syntaxes"
JS_GRAMMAR_DIR="${TM_BUNDLE_DIR}/JavaScript.tmbundle/Syntaxes"

export TM_SUPPORT_PATH="$TM_BUNDLE_DIR/Bundle Support.tmbundle/Support/shared"
export TM_BUNDLE_SUPPORT="$BUNDLE_DIR/Support"
export PATH=/Library/TeX/texbin:"$BUNDLE_DIR/Support/bin":$PATH
export TM_SELECTION='1:1'

auxiliary_files_regex='./(aux|acr|alg|bbl|bcf|blg|fdb_latexmk|fls|fmt|glg|gls|'
auxiliary_files_regex+='ini|log|out|maf|mtc|mtc1|pdfsync|run.xml|synctex.gz|'
auxiliary_files_regex+='toc)'

grammars=(
    "${BUNDLE_DIR}/Syntaxes/LaTeX.plist"
    "${BUNDLE_DIR}/Syntaxes/TeX.plist"
    "${PYTHON_GRAMMAR_DIR}"/{Python,"Regular Expressions (Python)"}.tmlanguage
    "${TM_BUNDLE_DIR}/SQL.tmbundle/Syntaxes/SQL.plist"
    "${TM_BUNDLE_DIR}/Java.tmbundle/Syntaxes/Java.plist"
    "${TM_BUNDLE_DIR}/JavaDoc.tmbundle/Syntaxes/JavaDoc.tmLanguage"
    "${TM_BUNDLE_DIR}/HTML.tmbundle/Syntaxes/HTML.plist"
    "${TM_BUNDLE_DIR}/CSS.tmbundle/Syntaxes/CSS.plist"
    "${JS_GRAMMAR_DIR}/JavaScript.plist"
    "${JS_GRAMMAR_DIR}/Regular Expressions (JavaScript).tmLanguage"
    "${TM_BUNDLE_DIR}/R.tmbundle/Syntaxes/R.plist"
)

# -- Aliases ------------------------------------------------------------------

# Remove leading and trailing whitespace
alias strip="sed -e 's/^ *//' -e 's/ *$//'"
alias countlines="wc -l | strip"
alias exit_success_or_discard="echo $? | grep -E '^0|200$' > /dev/null"
alias restore_aux_files_git='git checkout *.aux *.idx'
