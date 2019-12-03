-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

Try to translate a file that contains non ASCII characters, uses the utf-8
inputencoding and contains an error.

  $ export TM_FILEPATH="unicode_error.tex"

Just try to translate the program using `latexmk`

  $ texmate.py -s latex -latexmk yes | grep 'Output written' | countlines
  1

Check if texparser is able to parse the resulting log file

  $ texparser.py unicode_error.log unicode_error.tex | \
  >  grep '4.*Undefined control sequence.' > /dev/null

Check if clean removes all auxiliary files.

  $ texmate.py clean > /dev/null; exit_success_or_discard
  $ ls | grep -E $auxiliary_files_regex
  [1]

-- Cleanup --------------------------------------------------------------------

Restore the file changes made by previous commands.

  $ restore_aux_files_git

Remove the generated PDF

  $ rm -f *.dvi *.pdf *.ps
