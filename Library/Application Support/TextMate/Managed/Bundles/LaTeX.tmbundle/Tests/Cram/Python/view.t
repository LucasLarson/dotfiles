-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

  $ export TM_FILEPATH="external_bibliography.tex"

Generate the PDF

  $ pdflatex "$TM_FILEPATH" > /dev/null 2>&1

-- Tests ----------------------------------------------------------------------

Check if opening the PDF works with the current viewer

  $ texmate.py view > /dev/null; exit_success_or_discard

Check if clean removes all auxiliary files.

  $ texmate.py clean > /dev/null; exit_success_or_discard
  $ ls | grep -E $auxiliary_files_regex
  [1]

-- Cleanup --------------------------------------------------------------------

Restore the file changes made by previous commands.

  $ restore_aux_files_git

Remove the generated files

  $ rm -f *.ilg *.ind *.pdf
