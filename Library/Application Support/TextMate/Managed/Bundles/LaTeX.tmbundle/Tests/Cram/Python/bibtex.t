-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

  $ export TM_FILEPATH="external_bibliography.tex"

Check if building the bibliography works without producing any error

  $ texmate.py bibtex > /dev/null; exit_success_or_discard
