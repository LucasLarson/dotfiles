-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

  $ export TM_FILEPATH="makeglossaries.tex"

Translate the file to create the files needed by `makeglossaries`

  $ texmate.py -suppressview latex -latexmk yes -engine latex 2>&- \
  > | grep "All targets .* are up-to-date" | countlines
  1

Generate the index for the file

  $ texmate.py index | grep "Output written in .*.gls" | countlines
  1

Check if clean removes all auxiliary files.

  $ texmate.py clean > /dev/null; exit_success_or_discard
  $ ls | grep -E $auxiliary_files_regex
  [1]

-- Cleanup --------------------------------------------------------------------

Restore the file changes made by previous commands.

  $ restore_aux_files_git

Remove the generated files

  $ rm -f *.dvi *.pdf *.ps

