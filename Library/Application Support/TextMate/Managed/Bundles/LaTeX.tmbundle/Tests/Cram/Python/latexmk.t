-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

  $ export TM_FILEPATH="external_bibliography.tex"

We try to process the files using `latexmk`.

  $ texmate.py -suppressview latex -latexmk yes -e pdflatex -options ' -8bit' \
  > | grep -e 'All.*up-to-date' | countlines
  1

Check if clean removes all auxiliary files.

  $ texmate.py clean > /dev/null; exit_success_or_discard
  $ ls | grep -E $auxiliary_files_regex
  [1]

-- Cleanup --------------------------------------------------------------------

Restore the file changes made by previous commands.

  $ restore_aux_files_git

Remove the generated PDF files

  $ rm -f *.pdf
