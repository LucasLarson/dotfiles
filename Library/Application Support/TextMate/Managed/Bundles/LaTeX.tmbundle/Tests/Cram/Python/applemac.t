-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

Try to translate a file with the encoding “Mac OS Roman”

  $ export TM_FILEPATH="applemac.tex"

Just try to translate the program using `pdflatex`

  $ texmate.py -suppressview latex -latexmk no -engine pdflatex | \
  > grep 'Output written' > /dev/null

Check if clean removes all auxiliary files.

  $ texmate.py clean > /dev/null; exit_success_or_discard
  $ ls | grep -E $auxiliary_files_regex
  [1]

-- Cleanup --------------------------------------------------------------------

Restore the file changes made by previous commands.

  $ restore_aux_files_git

Remove the generated PDF

  $ rm -f *.pdf
