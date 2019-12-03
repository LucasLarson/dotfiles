-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

  $ export TM_FILEPATH="external_bibliography.tex"

  $ texmate.py version -engine latex
  pdfTeX .* (re)

  $ texmate.py version packages.tex
  XeTeX .* (re)
