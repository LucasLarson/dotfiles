-- Setup ----------------------------------------------------------------------

  $ cd "$TESTDIR"
  $ source ../../lib/setup_cram.sh
  $ cd ../../TeX/

-- Tests ----------------------------------------------------------------------

  $ export TM_FILEPATH="makeindex.tex"

Generate the index for the file

  $ texmate.py index | grep 'Output written' | countlines
  1

Translate the LaTeX file

  $ texmate.py -s latex -e pdflatex -l no 2>&- | grep 'Output written' | \
  > countlines
  1

-- Cleanup --------------------------------------------------------------------

Remove the generated files

  $ rm -f *.dvi *.ilg *.ind *.log *.pdf *.ps

