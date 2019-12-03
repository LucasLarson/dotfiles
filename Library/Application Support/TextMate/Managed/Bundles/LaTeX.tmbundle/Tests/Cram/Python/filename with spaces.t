-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

Try to translate a file with spaces in the filename. The file contains one error

  $ export TM_FILEPATH="filename with spaces.tex"

Just try to translate the program using `pdflatex`

  $ texmate.py -suppressview latex -latexmk no -engine pdflatex | \
  > grep '.*filename with spaces.tex:7.*Undefined control sequence.' > /dev/null

Check if texparser is able to parse the resulting log file

  $ texparser.py 'filename with spaces.log' 'filename with spaces.tex' | \
  >  grep '.*:7.*Undefined control sequence.' > /dev/null

Check if clean removes all auxiliary files.

  $ texmate.py clean > /dev/null; exit_success_or_discard
  $ ls | grep -E $auxiliary_files_regex
  [1]

-- Cleanup --------------------------------------------------------------------

Restore the file changes made by previous commands.

  $ restore_aux_files_git

Remove the generated PDF

  $ rm -f *.pdf
